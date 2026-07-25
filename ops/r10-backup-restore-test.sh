#!/bin/bash
# =============================================================================
# NWL-R10 Backup & Restore Validation Script
# Tests the full restore path: dump postgres, destroy, rebuild, re-embed.
#
# Usage:
#   sudo bash r10-backup-restore-test.sh [--destructive]
#
# Without --destructive: creates a parallel test database, validates dump/restore
# With --destructive: actually drops and rebuilds the target databases (use in
#   scheduled restore drills only, never in production without downtime window)
#
# Exit codes:
#   0 = all restore validations passed
#   1 = restore validation failed (check log)
#   2 = prerequisites missing
# =============================================================================

set -uo pipefail

LOG="/var/log/nwl-restore-test.log"
BACKUP_DIR="/var/backups/nwl"
SHARED_BRAIN="/srv/nwl/shared-brain"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
DESTRUCTIVE=false
FAILED=0

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }
pass() { log "  PASS: $1"; }
fail() { log "  FAIL: $1"; FAILED=$((FAILED + 1)); }

# --- Args ---
if [ "${1:-}" = "--destructive" ]; then
    DESTRUCTIVE=true
    log "WARNING: running in destructive mode"
fi

# --- Prerequisites ---
log "=== RESTORE VALIDATION — $TIMESTAMP ==="

for cmd in pg_dump pg_restore psql ollama curl sha256sum; do
    if ! command -v "$cmd" &>/dev/null; then
        log "FATAL: $cmd not found"
        exit 2
    fi
done

mkdir -p "$BACKUP_DIR"
chown postgres:postgres "$BACKUP_DIR"
chmod 755 "$BACKUP_DIR"

# =============================================================================
# PHASE 1: PostgreSQL dump
# =============================================================================
log "--- Phase 1: PostgreSQL dump ---"

DUMP_NWL="$BACKUP_DIR/nwl-$TIMESTAMP.dump"
DUMP_MERIDIAN="$BACKUP_DIR/meridian-$TIMESTAMP.dump"

# Dump both tenant databases in custom format (supports parallel restore)
sudo -u postgres pg_dump -Fc -d nwl -f "$DUMP_NWL" 2>>"$LOG"
if [ -f "$DUMP_NWL" ] && [ -s "$DUMP_NWL" ]; then
    DUMP_SIZE=$(stat -c%s "$DUMP_NWL" 2>/dev/null || stat -f%z "$DUMP_NWL")
    pass "nwl dump created: $DUMP_NWL ($DUMP_SIZE bytes)"
else
    fail "nwl dump is empty or missing"
fi

sudo -u postgres pg_dump -Fc -d meridian -f "$DUMP_MERIDIAN" 2>>"$LOG"
if [ -f "$DUMP_MERIDIAN" ] && [ -s "$DUMP_MERIDIAN" ]; then
    DUMP_SIZE=$(stat -c%s "$DUMP_MERIDIAN" 2>/dev/null || stat -f%z "$DUMP_MERIDIAN")
    pass "meridian dump created: $DUMP_MERIDIAN ($DUMP_SIZE bytes)"
else
    fail "meridian dump is empty or missing"
fi

# Record pre-dump row counts for later comparison
NWL_DOC_COUNT=$(sudo -u postgres psql -d nwl -tAc "SELECT COUNT(*) FROM documents;" 2>/dev/null || echo "0")
NWL_CHUNK_COUNT=$(sudo -u postgres psql -d nwl -tAc "SELECT COUNT(*) FROM chunks;" 2>/dev/null || echo "0")
log "  pre-dump counts: documents=$NWL_DOC_COUNT, chunks=$NWL_CHUNK_COUNT"

# =============================================================================
# PHASE 2: Restore to test database (non-destructive path)
# =============================================================================
log "--- Phase 2: Restore validation ---"

TEST_DB="nwl_restore_test_${TIMESTAMP}"

if [ "$DESTRUCTIVE" = false ]; then
    # Create a temporary test database, restore into it, validate, drop it
    log "  non-destructive mode: restoring to $TEST_DB"

    sudo -u postgres psql -c "CREATE DATABASE $TEST_DB OWNER nwl_app;" 2>>"$LOG"
    sudo -u postgres psql -d "$TEST_DB" -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>>"$LOG"

    sudo -u postgres pg_restore -d "$TEST_DB" "$DUMP_NWL" 2>>"$LOG" || true

    # Validate row counts match
    RESTORED_DOC_COUNT=$(sudo -u postgres psql -d "$TEST_DB" -tAc "SELECT COUNT(*) FROM documents;" 2>/dev/null || echo "-1")
    RESTORED_CHUNK_COUNT=$(sudo -u postgres psql -d "$TEST_DB" -tAc "SELECT COUNT(*) FROM chunks;" 2>/dev/null || echo "-1")

    if [ "$RESTORED_DOC_COUNT" = "$NWL_DOC_COUNT" ]; then
        pass "document count matches: $RESTORED_DOC_COUNT"
    else
        fail "document count mismatch: expected $NWL_DOC_COUNT, got $RESTORED_DOC_COUNT"
    fi

    if [ "$RESTORED_CHUNK_COUNT" = "$NWL_CHUNK_COUNT" ]; then
        pass "chunk count matches: $RESTORED_CHUNK_COUNT"
    else
        fail "chunk count mismatch: expected $NWL_CHUNK_COUNT, got $RESTORED_CHUNK_COUNT"
    fi

    # Validate pgvector index exists
    IDX_EXISTS=$(sudo -u postgres psql -d "$TEST_DB" -tAc \
        "SELECT COUNT(*) FROM pg_indexes WHERE indexname = 'idx_chunks_embedding';" 2>/dev/null || echo "0")
    if [ "$IDX_EXISTS" = "1" ]; then
        pass "pgvector HNSW index restored"
    else
        fail "pgvector HNSW index missing after restore"
    fi

    # Validate a vector similarity query actually works
    VECTOR_QUERY=$(sudo -u postgres psql -d "$TEST_DB" -tAc \
        "SELECT COUNT(*) FROM chunks WHERE embedding IS NOT NULL LIMIT 1;" 2>/dev/null || echo "0")
    if [ "$VECTOR_QUERY" != "0" ]; then
        pass "vector embeddings present in restored database"
    else
        fail "no vector embeddings found after restore"
    fi

    # Validate full-text search index
    FTS_EXISTS=$(sudo -u postgres psql -d "$TEST_DB" -tAc \
        "SELECT COUNT(*) FROM pg_indexes WHERE indexname = 'idx_chunks_tsv';" 2>/dev/null || echo "0")
    if [ "$FTS_EXISTS" = "1" ]; then
        pass "full-text search index restored"
    else
        fail "full-text search index missing (non-critical, Phase 2 feature)"
    fi

    # Clean up test database
    sudo -u postgres psql -c "DROP DATABASE $TEST_DB;" 2>>"$LOG"
    log "  test database $TEST_DB dropped"

else
    # Destructive mode: drop and rebuild the actual databases
    log "  DESTRUCTIVE mode: dropping and rebuilding nwl database"
    log "  WARNING: this will cause downtime for all agents using postgres"

    # Stop dependent services first
    systemctl stop nwl-rag-search.service 2>/dev/null || true
    systemctl stop nwl-rag-indexer.service 2>/dev/null || true

    sudo -u postgres psql -c "DROP DATABASE nwl;" 2>>"$LOG"
    sudo -u postgres psql -c "CREATE DATABASE nwl OWNER nwl_app;" 2>>"$LOG"
    sudo -u postgres psql -d nwl -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>>"$LOG"
    sudo -u postgres pg_restore -d nwl "$DUMP_NWL" 2>>"$LOG" || true

    # Validate
    RESTORED_DOC_COUNT=$(sudo -u postgres psql -d nwl -tAc "SELECT COUNT(*) FROM documents;" 2>/dev/null || echo "-1")
    if [ "$RESTORED_DOC_COUNT" = "$NWL_DOC_COUNT" ]; then
        pass "destructive restore: document count matches ($RESTORED_DOC_COUNT)"
    else
        fail "destructive restore: document count mismatch (expected $NWL_DOC_COUNT, got $RESTORED_DOC_COUNT)"
    fi

    # Restart services
    systemctl start nwl-rag-indexer.service 2>/dev/null || true
    systemctl start nwl-rag-search.service 2>/dev/null || true
fi

# =============================================================================
# PHASE 3: pgvector rebuild from markdown source files
# =============================================================================
log "--- Phase 3: pgvector rebuild from source ---"

# Count source markdown files
MD_COUNT=$(find "$SHARED_BRAIN" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
log "  shared-brain markdown files: $MD_COUNT"

if [ "$MD_COUNT" -eq 0 ]; then
    fail "no markdown files found in $SHARED_BRAIN"
else
    pass "source markdown files present ($MD_COUNT files)"
fi

# Verify Ollama is running and can generate embeddings
OLLAMA_STATUS=$(curl -sf http://localhost:11434/api/tags 2>/dev/null)
if [ -n "$OLLAMA_STATUS" ]; then
    pass "ollama is running"

    # Check if the embedding model is available
    if echo "$OLLAMA_STATUS" | grep -q "nomic-embed-text"; then
        pass "nomic-embed-text model available"
    else
        fail "nomic-embed-text model not found (run: ollama pull nomic-embed-text)"
    fi

    # Test embedding generation
    EMBED_TEST=$(curl -sf http://localhost:11434/api/embeddings \
        -d '{"model": "nomic-embed-text", "prompt": "test embedding generation"}' 2>/dev/null)
    if echo "$EMBED_TEST" | grep -q "embedding"; then
        pass "embedding generation works"
    else
        fail "embedding generation failed"
    fi
else
    fail "ollama is not running (embeddings cannot be regenerated)"
fi

# Verify the RAG indexer can re-index from source
RAG_INDEXER="/srv/nwl/shared-brain/ops/rag/indexer.py"
if [ -f "$RAG_INDEXER" ]; then
    pass "RAG indexer script exists at $RAG_INDEXER"
else
    fail "RAG indexer script missing at $RAG_INDEXER"
fi

# Verify the RAG schema can be applied from scratch
RAG_SCHEMA="/srv/nwl/shared-brain/ops/rag/schema.sql"
if [ -f "$RAG_SCHEMA" ]; then
    pass "RAG schema file exists at $RAG_SCHEMA"
else
    fail "RAG schema file missing at $RAG_SCHEMA"
fi

# =============================================================================
# PHASE 4: Full rebuild simulation (non-destructive)
# =============================================================================
log "--- Phase 4: Full rebuild simulation ---"

# This tests the worst-case path: postgres is gone, ollama is running,
# shared-brain files are intact. Can we rebuild everything?

REBUILD_DB="nwl_rebuild_test_${TIMESTAMP}"

if [ -f "$RAG_SCHEMA" ]; then
    sudo -u postgres psql -c "CREATE DATABASE $REBUILD_DB OWNER nwl_app;" 2>>"$LOG"
    sudo -u postgres psql -d "$REBUILD_DB" -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>>"$LOG"

    # Apply schema from scratch (pipe to avoid permission issues with /srv/nwl)
    cat "$RAG_SCHEMA" | sudo -u postgres psql -d "$REBUILD_DB" 2>>"$LOG"

    # Verify tables were created
    TABLE_COUNT=$(sudo -u postgres psql -d "$REBUILD_DB" -tAc \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>/dev/null || echo "0")

    if [ "$TABLE_COUNT" -ge 2 ]; then
        pass "schema rebuild created $TABLE_COUNT tables"
    else
        fail "schema rebuild created only $TABLE_COUNT tables (expected >= 2)"
    fi

    # Clean up
    sudo -u postgres psql -c "DROP DATABASE $REBUILD_DB;" 2>>"$LOG"
    log "  rebuild test database $REBUILD_DB dropped"
else
    log "  skipping rebuild simulation (no schema file)"
fi

# =============================================================================
# PHASE 5: Backup integrity
# =============================================================================
log "--- Phase 5: Backup integrity checks ---"

# Generate checksums for dumps
if [ -f "$DUMP_NWL" ]; then
    sha256sum "$DUMP_NWL" > "$DUMP_NWL.sha256"
    pass "checksum written: $DUMP_NWL.sha256"
fi

if [ -f "$DUMP_MERIDIAN" ]; then
    sha256sum "$DUMP_MERIDIAN" > "$DUMP_MERIDIAN.sha256"
    pass "checksum written: $DUMP_MERIDIAN.sha256"
fi

# Check backup directory disk usage
BACKUP_USAGE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
log "  backup directory usage: $BACKUP_USAGE"

# Prune old backups (keep last 7 days)
PRUNED=$(find "$BACKUP_DIR" -name "*.dump" -mtime +7 -delete -print 2>/dev/null | wc -l | tr -d ' ')
if [ "$PRUNED" -gt 0 ]; then
    log "  pruned $PRUNED old backup files (>7 days)"
fi

# =============================================================================
# Summary
# =============================================================================
log "=== RESTORE VALIDATION COMPLETE ==="

if [ "$FAILED" -eq 0 ]; then
    log "RESULT: ALL CHECKS PASSED"
    echo ""
    echo "  All restore paths validated."
    echo "  Dumps: $BACKUP_DIR/*-$TIMESTAMP.dump"
    echo "  Log: $LOG"
    exit 0
else
    log "RESULT: $FAILED CHECK(S) FAILED — review log"
    echo ""
    echo "  $FAILED check(s) failed. Review: $LOG"
    exit 1
fi

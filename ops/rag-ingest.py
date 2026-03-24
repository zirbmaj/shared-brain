#!/usr/bin/env python3
"""
Nowhere Labs — RAG Ingestion Pipeline
Scans shared-brain docs, chunks them, embeds via Gemini, upserts to Supabase.

Usage:
    python3 rag-ingest.py                          # ingest all shared-brain docs
    python3 rag-ingest.py --dir ~/shared-brain/ops  # ingest specific directory
    python3 rag-ingest.py --file ~/shared-brain/ROADMAP.md  # ingest one file
    python3 rag-ingest.py --dry-run                # show what would be ingested
    python3 rag-ingest.py --query "how do we deploy?"  # test search after ingestion

Requires:
    pip install google-genai supabase python-dotenv

Env vars:
    GEMINI_API_KEY    — Google AI API key (free tier works)
    SUPABASE_URL      — Supabase project URL
    SUPABASE_KEY      — Supabase service role key (for inserts)
"""

import os
import sys
import json
import hashlib
import re
import time
from pathlib import Path
from datetime import datetime

# Lazy imports — only needed for non-dry-run modes
genai = None
types = None
supabase_mod = None


def _ensure_deps():
    """Import API dependencies on first use (not needed for --dry-run)."""
    global genai, types, supabase_mod
    if genai is None:
        try:
            from google import genai as _genai
            from google.genai import types as _types
            genai = _genai
            types = _types
        except ImportError:
            print("ERROR: pip install google-genai")
            sys.exit(1)
    if supabase_mod is None:
        try:
            from supabase import create_client as _cc
            supabase_mod = _cc
        except ImportError:
            print("ERROR: pip install supabase")
            sys.exit(1)

# --- Config ---

EMBEDDING_MODEL = "gemini-embedding-2-preview"
EMBEDDING_DIM = 1536
CHUNK_SIZE = 500  # target tokens per chunk (~2000 chars)
CHUNK_OVERLAP = 50  # overlap tokens between chunks
SHARED_BRAIN_DIR = Path.home() / "shared-brain"

# Source type classification based on directory
SOURCE_TYPE_MAP = {
    "ops": "operations",
    "projects": "product",
    "retros": "retrospective",
    "brand": "brand",
    "agents": "agent-spec",
    "ideas": "ideation",
    "references": "reference",
    "requests": "request",
}


# --- Text Chunking ---


def estimate_tokens(text):
    """Rough token estimate: ~4 chars per token for English."""
    return len(text) // 4


def chunk_markdown(text, source_path):
    """Split markdown into chunks, respecting section boundaries.

    Strategy: split on headings first, then split large sections by paragraphs,
    then by sentences if still too large. Preserves heading context in each chunk.
    """
    chunks = []

    # Split by top-level headings (## or #)
    sections = re.split(r'\n(?=#{1,2}\s)', text)

    current_heading = ""

    for section in sections:
        section = section.strip()
        if not section:
            continue

        # Extract heading if present
        heading_match = re.match(r'^(#{1,2}\s+.+)', section)
        if heading_match:
            current_heading = heading_match.group(1)

        tokens = estimate_tokens(section)

        if tokens <= CHUNK_SIZE:
            # Section fits in one chunk
            chunks.append(section)
        else:
            # Split by paragraphs
            paragraphs = section.split('\n\n')
            current_chunk = ""

            for para in paragraphs:
                para = para.strip()
                if not para:
                    continue

                combined = f"{current_chunk}\n\n{para}" if current_chunk else para

                if estimate_tokens(combined) <= CHUNK_SIZE:
                    current_chunk = combined
                else:
                    if current_chunk:
                        chunks.append(current_chunk)

                    # If single paragraph is too large, split by sentences
                    if estimate_tokens(para) > CHUNK_SIZE:
                        sentences = re.split(r'(?<=[.!?])\s+', para)
                        current_chunk = ""
                        for sentence in sentences:
                            combined = f"{current_chunk} {sentence}" if current_chunk else sentence
                            if estimate_tokens(combined) <= CHUNK_SIZE:
                                current_chunk = combined
                            else:
                                if current_chunk:
                                    chunks.append(current_chunk)
                                current_chunk = sentence
                    else:
                        current_chunk = para

            if current_chunk:
                chunks.append(current_chunk)

    # Add heading context to chunks that don't start with one
    result = []
    for chunk in chunks:
        if not chunk.startswith('#') and current_heading:
            chunk = f"{current_heading}\n\n{chunk}"
        result.append(chunk)

    return result if result else [text]  # fallback: whole doc as one chunk


def classify_source_type(filepath):
    """Determine source_type from file path."""
    rel = str(filepath)
    for dir_name, source_type in SOURCE_TYPE_MAP.items():
        if f"/{dir_name}/" in rel or rel.startswith(f"{dir_name}/"):
            return source_type

    # Top-level files
    filename = Path(filepath).stem.upper()
    if filename in ("ROADMAP", "STATUS", "GOALS", "PHILOSOPHY"):
        return "strategy"

    return "general"


def extract_title(text, filepath):
    """Extract title from first heading or filename."""
    match = re.match(r'^#\s+(.+)', text)
    if match:
        return match.group(1).strip()
    return Path(filepath).stem.replace('-', ' ').replace('_', ' ').title()


# --- Embedding ---


def create_gemini_client():
    """Create Gemini client from env var."""
    _ensure_deps()
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("ERROR: GEMINI_API_KEY not set")
        sys.exit(1)
    return genai.Client(api_key=api_key)


def embed_text(client, text, max_retries=5):
    """Generate embedding for a text chunk with rate limit retry."""
    for attempt in range(max_retries):
        try:
            result = client.models.embed_content(
                model=EMBEDDING_MODEL,
                contents=[text],
                config=types.EmbedContentConfig(
                    task_type="RETRIEVAL_DOCUMENT",
                    output_dimensionality=EMBEDDING_DIM,
                ),
            )
            return result.embeddings[0].values
        except Exception as e:
            if "429" in str(e) or "RESOURCE_EXHAUSTED" in str(e):
                wait = min(2 ** attempt * 5, 60)
                print(f"    rate limited, waiting {wait}s...")
                time.sleep(wait)
            else:
                raise
    raise Exception("embed_text: max retries exceeded")


def embed_query(client, query):
    """Generate embedding for a search query."""
    result = client.models.embed_content(
        model=EMBEDDING_MODEL,
        contents=[query],
        config=types.EmbedContentConfig(
            task_type="RETRIEVAL_QUERY",
            output_dimensionality=EMBEDDING_DIM,
        ),
    )
    return result.embeddings[0].values


# --- Supabase ---


def create_supabase_client():
    """Create Supabase client from env vars."""
    _ensure_deps()
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_KEY")
    if not url or not key:
        print("ERROR: SUPABASE_URL and SUPABASE_KEY must be set")
        sys.exit(1)
    return supabase_mod(url, key)


def get_existing_hashes(sb, source_path):
    """Fetch content hashes for all chunks of a file already in the DB.
    Returns dict of {chunk_index: content_hash}."""
    try:
        result = sb.table("knowledge_documents").select(
            "chunk_index,metadata"
        ).eq("source_path", source_path).execute()
        hashes = {}
        for row in result.data or []:
            idx = row.get("chunk_index", -1)
            meta = row.get("metadata") or {}
            h = meta.get("content_hash", "")
            if h:
                hashes[idx] = h
        return hashes
    except Exception:
        return {}


def upsert_document(sb, source_path, source_type, title, chunk_index, content, embedding, metadata):
    """Upsert a document chunk into knowledge_documents.

    Uses the unique constraint on (source_path, chunk_index) for conflict resolution.
    """
    sb.table("knowledge_documents").upsert(
        {
            "source_path": source_path,
            "source_type": source_type,
            "title": title,
            "chunk_index": chunk_index,
            "content": content,
            "content_embedding": embedding,
            "metadata": metadata,
            "updated_at": datetime.utcnow().isoformat(),
        },
        on_conflict="source_path,chunk_index",
    ).execute()


def delete_stale_chunks(sb, source_path, max_chunk_index):
    """Delete chunks beyond the current max (file was shortened)."""
    sb.table("knowledge_documents").delete().eq(
        "source_path", source_path
    ).gt("chunk_index", max_chunk_index).execute()


def search_documents(sb, query_embedding, top_k=5, source_type=None):
    """Search knowledge_documents via match_documents RPC."""
    params = {
        "query_embedding": query_embedding,
        "match_threshold": 0.5,
        "match_count": top_k,
    }
    if source_type:
        params["filter_type"] = source_type

    return sb.rpc("match_documents", params).execute()


# --- Pipeline ---


def collect_files(base_dir, specific_file=None):
    """Collect markdown files to ingest."""
    if specific_file:
        p = Path(specific_file)
        if p.exists() and p.suffix == '.md':
            return [p]
        else:
            print(f"ERROR: {specific_file} not found or not a .md file")
            return []

    base = Path(base_dir)
    if not base.exists():
        print(f"ERROR: {base_dir} not found")
        return []

    files = sorted(base.rglob("*.md"))
    # Skip git internals and node_modules
    files = [f for f in files if '.git/' not in str(f) and 'node_modules/' not in str(f)]
    return files


def content_hash(text):
    """Hash content to detect changes."""
    return hashlib.sha256(text.encode()).hexdigest()[:16]


def ingest_file(gemini_client, sb, filepath, base_dir, dry_run=False):
    """Ingest a single file: chunk, embed, upsert."""
    rel_path = str(filepath.relative_to(Path(base_dir).parent)) if base_dir else str(filepath)

    with open(filepath, 'r', encoding='utf-8') as f:
        text = f.read()

    if not text.strip():
        return 0

    title = extract_title(text, filepath)
    source_type = classify_source_type(rel_path)
    chunks = chunk_markdown(text, filepath)

    if dry_run:
        print(f"  {rel_path}: {len(chunks)} chunks, type={source_type}, title='{title}'")
        for i, chunk in enumerate(chunks):
            tokens = estimate_tokens(chunk)
            preview = chunk[:80].replace('\n', ' ')
            print(f"    [{i}] ~{tokens} tokens: {preview}...")
        return len(chunks)

    # Fetch existing hashes to skip unchanged chunks (saves embedding API quota)
    existing_hashes = get_existing_hashes(sb, rel_path)
    skipped = 0

    for i, chunk in enumerate(chunks):
        c_hash = content_hash(chunk)

        # Skip if chunk content hasn't changed
        if existing_hashes.get(i) == c_hash:
            skipped += 1
            continue

        metadata = {
            "content_hash": c_hash,
            "token_estimate": estimate_tokens(chunk),
            "ingested_at": datetime.utcnow().isoformat(),
            "file_modified": datetime.fromtimestamp(filepath.stat().st_mtime).isoformat(),
        }

        embedding = embed_text(gemini_client, chunk)
        time.sleep(0.7)  # ~85 requests/min, under 100/min free tier limit

        upsert_document(
            sb,
            source_path=rel_path,
            source_type=source_type,
            title=title,
            chunk_index=i,
            content=chunk,
            embedding=embedding,
            metadata=metadata,
        )

    # Clean up stale chunks if file was shortened
    delete_stale_chunks(sb, rel_path, len(chunks) - 1)

    ingested = len(chunks) - skipped
    if skipped > 0:
        print(f"    ({skipped} chunks unchanged, skipped)")
    return ingested


def run_query(query_text):
    """Test the RAG search after ingestion."""
    gemini_client = create_gemini_client()
    sb = create_supabase_client()

    print(f"Query: {query_text}\n")

    query_vec = embed_query(gemini_client, query_text)
    results = search_documents(sb, query_vec, top_k=5)

    if not results.data:
        print("No results found.")
        return

    print(f"Results ({len(results.data)}):\n")
    for r in results.data:
        sim = r.get('similarity', 0)
        print(f"  [{sim:.3f}] {r['source_type']} — {r['title']}")
        print(f"          {r['source_path']}")
        preview = r['content'][:150].replace('\n', ' ')
        print(f"          {preview}...")
        print()


# --- Main ---


def main():
    args = sys.argv[1:]

    dry_run = "--dry-run" in args
    if dry_run:
        args.remove("--dry-run")

    # Query mode
    if "--query" in args:
        idx = args.index("--query")
        query_text = " ".join(args[idx + 1:])
        if not query_text:
            print("Usage: --query 'your search query'")
            sys.exit(1)
        run_query(query_text)
        return

    # Determine target
    specific_file = None
    target_dir = SHARED_BRAIN_DIR

    if "--file" in args:
        idx = args.index("--file")
        if idx + 1 < len(args):
            specific_file = args[idx + 1]
    elif "--dir" in args:
        idx = args.index("--dir")
        if idx + 1 < len(args):
            target_dir = Path(args[idx + 1])

    # Collect files
    files = collect_files(target_dir, specific_file)
    if not files:
        print("No files to ingest.")
        sys.exit(1)

    print(f"Nowhere Labs RAG Ingestion")
    print(f"  Target: {specific_file or target_dir}")
    print(f"  Files: {len(files)}")
    print(f"  Embedding: {EMBEDDING_MODEL} ({EMBEDDING_DIM}d)")
    print(f"  Dry run: {dry_run}")
    print()

    if dry_run:
        total_chunks = 0
        for f in files:
            total_chunks += ingest_file(None, None, f, target_dir, dry_run=True)
        print(f"\nTotal: {len(files)} files → {total_chunks} chunks")
        return

    # Initialize clients
    gemini_client = create_gemini_client()
    sb = create_supabase_client()

    total_chunks = 0
    errors = 0

    for filepath in files:
        rel = str(filepath.relative_to(Path(target_dir).parent)) if target_dir != filepath else filepath.name
        try:
            n = ingest_file(gemini_client, sb, filepath, target_dir)
            total_chunks += n
            print(f"  ✓ {rel} ({n} chunks)")
        except Exception as e:
            errors += 1
            print(f"  ✗ {rel}: {e}")

    print(f"\nDone. {len(files)} files → {total_chunks} chunks ingested. {errors} errors.")

    if total_chunks > 0 and errors == 0:
        print("\nTest with: python3 rag-ingest.py --query 'how do we deploy?'")


if __name__ == "__main__":
    main()

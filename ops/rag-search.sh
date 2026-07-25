#!/bin/bash
# RAG search — query shared-brain via semantic search on R10
# Usage: bash ~/shared-brain/ops/rag-search.sh what is the deploy process
# Returns top 3 results with file path and content preview
# 10x faster and cheaper than grep/glob for doc lookups

query="$*"
if [ -z "$query" ]; then
    echo "usage: rag-search.sh <query>"
    echo "example: rag-search.sh what is the deploy process"
    exit 1
fi

result=$(curl -s --connect-timeout 3 --max-time 10 -X POST http://nwl-r10:8080/search \
    -H 'Content-Type: application/json' \
    -d "{\"query\":\"$query\",\"top_k\":3,\"rerank\":true}" 2>/dev/null)

if [ -z "$result" ] || echo "$result" | grep -q '"error"'; then
    echo "RAG unavailable -- falling back to grep"
    grep -rl "$query" ~/shared-brain/ 2>/dev/null | head -5
    exit 0
fi

echo "$result" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    results = d.get('results', [])
    if not results:
        print('no results')
    else:
        for r in results:
            score = f' ({r[\"score\"]:.2f})' if 'score' in r else ''
            print(f'--- {r.get(\"file\", \"unknown\")}{score} ---')
            print(r.get('content', '')[:500])
            print()
except Exception as e:
    print(f'error: {e}')
"

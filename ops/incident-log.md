# Infrastructure Incident Log


## 2026-05-21 04:31Z — r10 + xps13 unreachable
- nwl-r10 (100.69.185.101): NO PING. RAG :8080, postgres :5432, ollama :11434 all down. ssh :22 no response. Likely power/network, not service crash. Impact: doc lookups (RAG), inference, pgvector offline.
- nwl-xps13 (100.64.51.13): NO PING. Test runner/sentinel offline. Impact: Static remote test suite unavailable.
- mini + fran-pc reachable. All 6 NWL agents healthy (live process, clean stderr).
- Action: flagged to jam — both need physical power/network check. Cannot recover remotely.
- Detected by: relay deep health check.

### RESOLVED 2026-05-21 ~04:52Z — agent zombie state (all 5 NWL agents)
- Symptom: claude/static/claudia/near/hum process-alive + clean stderr + 7-14h uptime but unresponsive to Discord (silent to 3 roll calls incl. jam's real-user pings). NOT the old bot-filter cause.
- Fix: cycled all 5 (SIGTERM → relaunch via captured ps command). All acked within ~90s, responsive even with r10 down.
- Root-cause gap: NO agent-zombie detector exists. Broken crons (uptime-monitor, auto-verify) monitor product URLs/deploys, not agents. Building a JSONL-write-staleness detector (static logic, relay ops).
- Crontab path-fix staged /tmp/crontab-fixed.txt but BLOCKED — macOS TCC, needs jam (see incident below repeats Apr 7).
- Note: r10 + xps13 still down; jam owns recovery on his timeline. Public products unaffected.

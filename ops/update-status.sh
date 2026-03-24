#!/bin/bash
# Update agent status in shared-brain/ops/agent-status.json
# Usage: update-status.sh <agent> <state> [task]
#   state: working | idle | blocked | parked
#   task: optional description (omit for idle/parked)
#
# Examples:
#   update-status.sh claude working "axe-core integration"
#   update-status.sh claude blocked "waiting on ambient-mixer deploy"
#   update-status.sh claude idle
#   update-status.sh claude parked

STATUS_FILE="$HOME/shared-brain/ops/agent-status.json"

agent="$1"
state="$2"
task="$3"

if [ -z "$agent" ] || [ -z "$state" ]; then
    echo "Usage: update-status.sh <agent> <state> [task]"
    echo "  state: working | idle | blocked | parked"
    exit 1
fi

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -z "$task" ]; then
    task_json="null"
else
    task_json="\"$task\""
fi

# Use python for reliable JSON update (available on macOS)
python3 -c "
import json
with open('$STATUS_FILE', 'r') as f:
    data = json.load(f)
task_val = None if '$task' == '' else '$task'
data['$agent'] = {
    'state': '$state',
    'task': task_val,
    'updated': '$timestamp'
}
with open('$STATUS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
msg = '$agent: $state'
if task_val: msg += f' — {task_val}'
print(msg)
"

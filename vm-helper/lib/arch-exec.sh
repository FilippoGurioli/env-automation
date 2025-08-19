#!/bin/bash

VM_NAME="arch"

if [ $# -eq 0 ]; then
    echo "Usage: arch-exec <command>"
    exit 1
fi

# Start the command inside the guest
PID=$(virsh qemu-agent-command "$VM_NAME" '{
    "execute": "guest-exec",
    "arguments": {
        "path": "/bin/bash",
        "arg": ["-c", "'"$*"'"],
        "capture-output": true
    }
}' | jq -r '.return.pid')

# Poll until process finishes
while true; do
    STATUS=$(virsh qemu-agent-command "$VM_NAME" '{
        "execute": "guest-exec-status",
        "arguments": {"pid": '"$PID"'}
    }')

    EXITED=$(echo "$STATUS" | jq -r '.return.exited')

    if [ "$EXITED" == "true" ]; then
        echo "$STATUS" | jq -r '.return["out-data"] // empty' | base64 -d
        echo "$STATUS" | jq -r '.return["err-data"] // empty' | base64 -d >&2
        exit $(echo "$STATUS" | jq -r '.return.exitcode')
    fi

    sleep 1
done

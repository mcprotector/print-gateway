#!/bin/bash
echo "Content-Type: text/plain"
echo

queue="$HTTP_X_QUEUE"
file="$HTTP_X_FILE"
filename="$HTTP_X_FILENAME"
task_id=$(date +%s%N | cut -b1-13)

cat > "/tasks/pending/task_${task_id}.json" <<EOF
{
  "id": "$task_id",
  "queue": "$queue",
  "file": "$file",
  "filename": "$filename",
  "timestamp": $(date +%s),
  "retry": 0
}
EOF

echo "Queued: task_${task_id}"

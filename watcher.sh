#!/bin/bash

inotifywait -m -q -e create -e moved_to --format '%w%f' /tasks/pending/ \
| while read task_file; do
  if [[ $task_file == *.json ]]; then

    queue=$(jq -r .queue "$task_file")
    pdf_path=$(jq -r .file "$task_file")
    base=$(basename "$task_file")
    fail_log="/tasks/retry/${base%.json}.log"

    # Запускаем print.sh и сохраняем stdout+stderr
    output=$(/scripts/print.sh "$queue" "$pdf_path" 2>&1)
    status=$?

    if [[ $status -eq 0 ]]; then
      mv "$task_file" "/tasks/printed/$base"
    else
      # сохраняем вывод ошибки
      echo "$output" > "$fail_log"
      mv "$task_file" "/tasks/retry/$base"
    fi
  fi
done

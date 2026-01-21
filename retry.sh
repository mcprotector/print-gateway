#!/bin/bash
set -euo pipefail

BASE="/tasks"
RETRY_DIR="$BASE/retry"
PENDING_DIR="$BASE/pending"
FAILED_DIR="$BASE/failed"

# задержки в секундах
delays=(60 360 960)   # retry 0 → 1m, retry 1 → 6m, retry 2 → 16m

now=$(date +%s)

for json in "$RETRY_DIR"/*.json; do
    [[ -e "$json" ]] || continue  # если нет файлов

    filename=$(basename "$json")
    name="${filename%.json}"
    log="$RETRY_DIR/$name.log"

    # читаем retry и timestamp
    retry=$(jq -r '.retry' "$json")
    ts=$(jq -r '.timestamp' "$json")

    # если retry >= 3 → переносим в failed
    if (( retry >= 3 )); then
        echo "[$(date)] $filename: retry=$retry → moving to failed"

        mv "$json" "$FAILED_DIR/"
        [[ -f "$log" ]] && mv "$log" "$FAILED_DIR/"

        continue
    fi

    # вычисляем минимальное время ожидания
    required_delay=${delays[$retry]}
    elapsed=$(( now - ts ))

    if (( elapsed < required_delay )); then
        # ещё рано
        continue
    fi

    # пора переносить в pending
    new_retry=$(( retry + 1 ))

    echo "[$(date)] $filename: retry=$retry → $new_retry (elapsed ${elapsed}s)"

    # обновляем retry в JSON
    tmp=$(mktemp)
    jq ".retry = $new_retry" "$json" > "$tmp"
    mv "$tmp" "$json"

    # удаляем лог, если есть
    [[ -f "$log" ]] && rm -f "$log"

    # переносим json в pending
    mv "$json" "$PENDING_DIR/"
done

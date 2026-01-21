#!/bin/bash

# ==========================================
# КОНФИГУРАЦИЯ
# ==========================================

# Список директорий для очистки
# Добавляйте новые пути в круглые скобки
TARGET_DIRS=(
    "/tmp/uploads"
	"/tasks/retry"
    "/tasks/failed"
    "/tasks/printed"
)

# ==========================================
# ЛОГИКА
# ==========================================

# Перебираем все директории из массива
for CURRENT_DIR in "${TARGET_DIRS[@]}"; do
    
    # Проверяем, существует ли директория
    if [ -d "$CURRENT_DIR" ]; then
        
        # (Опционально) Вывод в лог для отладки
        # echo "Cleaning: $CURRENT_DIR"

        # 1. Удаляем файлы (type f) старше 1 дня (>24 часов)
        find "$CURRENT_DIR" -type f -mtime +0 -delete

        # 2. Удаляем пустые директории (type d)
        # Опция -delete подразумевает -depth (сначала вложенные)
        find "$CURRENT_DIR" -type d -empty -delete
        
    else
        # Вывод в stderr, если директория не найдена (полезно для логов)
        echo "Warning: Directory not found: $CURRENT_DIR" >&2
    fi

done

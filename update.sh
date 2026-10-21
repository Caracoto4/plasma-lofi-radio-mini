#!/usr/bin/env bash
#
# Lofi Radio Mini — auto-updater.
# Автоматическое обновление виджета

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# Переходим в /tmp
cd /tmp || exit 1

# Удаляем старую директорию если есть
info "Очищаю старую директорию..."
rm -rf plasma-lofi-radio-mini

# Клонируем репозиторий
info "Клонирую репозиторий..."
if ! git clone https://github.com/Caracoto4/plasma-lofi-radio-mini.git; then
    die "Не удалось клонировать репозиторий"
fi

# Переходим в директорию
cd plasma-lofi-radio-mini || exit 1

# Делаем скрипты исполняемыми
info "Настраиваю права доступа..."
chmod +x install.sh

# Запускаем установку
info "Устанавливаю виджет..."
if ! ./install.sh; then
    die "Не удалось установить виджет"
fi

# Перезапускаем Plasma
info "Перезапускаю Plasma..."
systemctl --user restart plasma-plasmashell.service

# Очищаем временную директорию
info "Очищаю временные файлы..."
cd /tmp
rm -rf plasma-lofi-radio-mini

info "Обновление завершено!"
exit 0

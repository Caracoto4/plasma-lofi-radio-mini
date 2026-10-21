#!/usr/bin/env bash
#
# Lofi Radio Mini — auto-updater.
# Автоматическое обновление виджета
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# Переходим в /tmp
cd /tmp

# Удаляем старую директорию если есть
info "Очищаю старую директорию..."
rm -rf plasma-lofi-radio-mini

# Клонируем репозиторий
info "Клонирую репозиторий..."
git clone https://github.com/Caracoto4/plasma-lofi-radio-mini.git

# Переходим в директорию
cd plasma-lofi-radio-mini

# Делаем скрипты исполняемыми
info "Настраиваю права доступа..."
chmod +x install.sh

# Запускаем установку
info "Устанавливаю виджет..."
./install.sh

# Перезапускаем Plasma
info "Перезапускаю Plasma..."
systemctl --user restart plasma-plasmashell.service

# Очищаем временную директорию
info "Очищаю временные файлы..."
cd /tmp
rm -rf plasma-lofi-radio-mini

info "Обновление завершено!"

#!/usr/bin/env bash
#
# Lofi Radio Mini — updater.
# Обновляет виджет после git pull
set -euo pipefail

PKG_ID="org.koda.lofiradio.mini"
UNIT_NAME="lofi-nowplaying.service"

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
HELPER_DIR="$DATA_HOME/lofi-radio-mini"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

[ -f "$SRC_DIR/package/metadata.json" ] || die "не найден package/metadata.json — запускайте скрипт из корня репозитория."

# --- 1. Обновление виджета --------------------------------------------------
info "Обновляю виджет $PKG_ID"
if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$PKG_ID"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$SRC_DIR/package"
    info "Виджет обновлён"
else
    warn "Виджет не установлен. Запустите install.sh"
    exit 1
fi

# --- 2. Обновление helper ---------------------------------------------------
info "Обновляю helper"
install -m 755 "$SRC_DIR/helper/lofi-nowplaying.py" "$HELPER_DIR/lofi-nowplaying.py"

# --- 3. Перезапуск сервисов -------------------------------------------------
if command -v systemctl >/dev/null 2>&1; then
    info "Перезапускаю сервис"
    systemctl --user restart "$UNIT_NAME" 2>/dev/null || warn "сервис не был запущен"
    
    info "Перезапускаю Plasma"
    systemctl --user restart plasma-plasmashell.service
fi

cat <<EOF

Готово! Виджет обновлён.

Если виджет не появился — перезапустите оболочку:
  systemctl --user restart plasma-plasmashell.service
EOF

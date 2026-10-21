#!/usr/bin/env bash
#
# Lofi Radio Mini — updater (self-contained).
#
# Called by the widget ("Установить обновление") via the helper service,
# or manually. Pulls the latest sources and reinstalls the widget.
#
# This script is deployed into ~/.local/share/lofi-radio-mini/ alongside
# the helper, so it must work without any external install.sh.
set -uo pipefail

REPO_URL="https://github.com/Caracoto4/plasma-lofi-radio-mini.git"
PKG_ID="org.koda.lofiradio.mini"
UNIT_NAME="lofi-nowplaying.service"

# Where this script lives (deployed by install.sh)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
HELPER_DIR="$DATA_HOME/lofi-radio-mini"
UNIT_DIR="$CONFIG_HOME/systemd/user"
PLASMA_PKG_DIR="$DATA_HOME/plasma/plasmoids"

# Clone target — always the same dir so repeated runs reuse it
CLONE_DIR="$DATA_HOME/lofi-radio-mini-src"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

need() {
    command -v "$1" >/dev/null 2>&1 || die "не найден «$1»."
}

need git
need kpackagetool6
need python3

# --- 1. pull repo ----------------------------------------------------------
if [ -d "$CLONE_DIR/.git" ]; then
    info "Обновляю клон в $CLONE_DIR"
    git -C "$CLONE_DIR" fetch --depth 1 origin main || die "git fetch не удался (нет сети?)"
    git -C "$CLONE_DIR" reset --hard FETCH_HEAD || die "git reset не удался"
else
    info "Клонирую репозиторий в $CLONE_DIR"
    rm -rf "$CLONE_DIR"
    mkdir -p "$(dirname "$CLONE_DIR")"
    git clone --depth 1 "$REPO_URL" "$CLONE_DIR" || die "git clone не удался"
fi

# --- 2. install widget -----------------------------------------------------
info "Устанавливаю виджет $PKG_ID"
if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$PKG_ID"; then
    kpackagetool6 --type Plasma/Applet --upgrade "$CLONE_DIR/package"
    info "Обновил существующую установку"
else
    kpackagetool6 --type Plasma/Applet --install "$CLONE_DIR/package"
fi

# --- 3. install helper (copy files) ----------------------------------------
info "Устанавливаю helper в $HELPER_DIR"
install -d -m 755 "$HELPER_DIR"
install -m 755 "$CLONE_DIR/helper/lofi-nowplaying.py" "$HELPER_DIR/lofi-nowplaying.py"
install -m 755 "$CLONE_DIR/install.sh" "$HELPER_DIR/install.sh"
install -m 755 "$CLONE_DIR/update.sh" "$HELPER_DIR/update.sh"

# --- 4. install systemd unit -----------------------------------------------
info "Устанавливаю systemd-юнит $UNIT_NAME"
install -d -m 755 "$UNIT_DIR"
sed "s|^ExecStart=.*|ExecStart=$(command -v python3) $HELPER_DIR/lofi-nowplaying.py|" \
    "$CLONE_DIR/helper/$UNIT_NAME" > "$UNIT_DIR/$UNIT_NAME"
chmod 644 "$UNIT_DIR/$UNIT_NAME"

# --- 5. restart plasma, then the helper ------------------------------------
# Этот скрипт запущен как дочерний процесс lofi-nowplaying.service, поэтому
# перезапускать сервис напрямую нельзя — systemd убьёт вместе с ним и нас.
# Отложенная команда через systemd-run попадает в отдельный transient-юнит и
# переживает остановку helper.
if command -v systemctl >/dev/null 2>&1; then
    info "Перезапускаю оболочку Plasma"
    systemctl --user restart plasma-plasmashell.service || warn "не удалось перезапустить plasmashell"

    info "Запланировал перезапуск $UNIT_NAME"
    systemctl --user daemon-reload
    if command -v systemd-run >/dev/null 2>&1 \
        && systemd-run --user --quiet --collect /bin/systemctl --user restart "$UNIT_NAME"; then
        info "Сервис перезапустится через пару секунд"
    else
        systemctl --user enable --now "$UNIT_NAME" || warn "перезапустите сервис вручную: systemctl --user restart $UNIT_NAME"
    fi
else
    warn "systemctl не найден — перезапустите сессию и helper вручную"
fi

info "Готово!"


#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  Kitty Monero Theme — Installer
# ─────────────────────────────────────────────────────────────

set -euo pipefail

KITTY_CFG="$HOME/.config/kitty"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD="\033[1m"
ORANGE="\033[38;2;255;102;0m"
GREEN="\033[32m"
RED="\033[31m"
RESET="\033[0m"

header() { echo -e "\n${ORANGE}${BOLD}▶ $1${RESET}"; }
ok()     { echo -e "  ${GREEN}✔${RESET}  $1"; }
warn()   { echo -e "  ${RED}✘${RESET}  $1"; }

echo -e "${ORANGE}${BOLD}"
cat << 'EOF'
  __  __                      
 |  \/  | ___  _ __   ___ _ __ ___  
 | |\/| |/ _ \| '_ \ / _ \ '__/ _ \ 
 | |  | | (_) | | | |  __/ | | (_) |
 |_|  |_|\___/|_| |_|\___|_|  \___/ 
  Kitty Terminal Theme — Installer
EOF
echo -e "${RESET}"

# ── Check dependencies ─────────────────────────────────────────
header "Checking dependencies"

if ! command -v kitty &>/dev/null; then
  warn "kitty not found. Install it from https://sw.kovidgoyal.net/kitty/"
  exit 1
fi
ok "kitty found: $(kitty --version 2>/dev/null | head -1)"

if ! command -v python3 &>/dev/null; then
  warn "python3 not found — required for the ASCII animation."
  exit 1
fi
ok "python3 found"

# ── Backup existing config ─────────────────────────────────────
header "Backing up existing config"

if [ -f "$KITTY_CFG/kitty.conf" ]; then
  BACKUP="$KITTY_CFG/kitty.conf.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$KITTY_CFG/kitty.conf" "$BACKUP"
  ok "Existing kitty.conf backed up → $BACKUP"
else
  ok "No existing kitty.conf — nothing to back up"
fi

# ── Install files ──────────────────────────────────────────────
header "Installing theme files"

mkdir -p "$KITTY_CFG"

# kitty.conf — replace placeholder with real config dir path
sed "s|KITTY_CONFIG_DIR|$KITTY_CFG|g" \
  "$REPO_DIR/kitty.conf" > "$KITTY_CFG/kitty.conf"
ok "kitty.conf installed"

cp "$REPO_DIR/startup.session"       "$KITTY_CFG/startup.session"
ok "startup.session installed"

cp "$REPO_DIR/monero_art.sh"         "$KITTY_CFG/monero_art.sh"
chmod +x "$KITTY_CFG/monero_art.sh"
ok "monero_art.sh installed (executable)"

cp "$REPO_DIR/padded-Monero-Logo.png" "$KITTY_CFG/padded-Monero-Logo.png"
ok "padded-Monero-Logo.png installed"

# ── Font notice ────────────────────────────────────────────────
header "Font requirement"
echo -e "  This theme uses ${BOLD}3270 Nerd Font Mono${RESET}."
echo -e "  Download it from: ${ORANGE}https://www.nerdfonts.com/font-downloads${RESET}"
echo -e "  (Search for '3270' — install and set it in your system/kitty)"

# ── Done ───────────────────────────────────────────────────────
echo -e "\n${ORANGE}${BOLD}  ✔ All done! Restart kitty to see your theme.${RESET}\n"

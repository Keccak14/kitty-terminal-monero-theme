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

if ! command -v curl &>/dev/null; then
  echo -e "  curl not found — attempting to install..."
  if command -v apt &>/dev/null; then
    sudo apt install -y curl
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y curl
  elif command -v yum &>/dev/null; then
    sudo yum install -y curl
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm curl
  else
    warn "Could not install curl automatically. Please install it manually and re-run."
    exit 1
  fi
fi
ok "curl found"

# ── Install JetBrainsMono Nerd Font ───────────────────────────
header "Installing JetBrainsMono Nerd Font"

FONT_DIR="$HOME/.local/share/fonts"

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  ok "JetBrainsMono Nerd Font already installed"
else
  if command -v curl &>/dev/null; then
    mkdir -p "$FONT_DIR"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    echo -e "  Downloading JetBrainsMono Nerd Font..."
    curl -sL "$FONT_URL" -o /tmp/JetBrainsMono.zip
    unzip -q -o /tmp/JetBrainsMono.zip "*.ttf" -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
    fc-cache -f "$FONT_DIR"
    ok "JetBrainsMono Nerd Font installed"
  else
    warn "curl not found — skipping font install. Download manually from https://www.nerdfonts.com"
  fi
fi

# ── Backup existing kitty config ───────────────────────────────
header "Backing up existing kitty config"

if [ -f "$KITTY_CFG/kitty.conf" ]; then
  BACKUP="$KITTY_CFG/kitty.conf.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$KITTY_CFG/kitty.conf" "$BACKUP"
  ok "Existing kitty.conf backed up → $BACKUP"
else
  ok "No existing kitty.conf — nothing to back up"
fi

# ── Install kitty theme files ──────────────────────────────────
header "Installing kitty theme files"

mkdir -p "$KITTY_CFG"

sed "s|KITTY_CONFIG_DIR|$KITTY_CFG|g" \
  "$REPO_DIR/kitty.conf" > "$KITTY_CFG/kitty.conf"
ok "kitty.conf installed"

cp "$REPO_DIR/startup.session"        "$KITTY_CFG/startup.session"
ok "startup.session installed"

cp "$REPO_DIR/monero_art.sh"          "$KITTY_CFG/monero_art.sh"
chmod +x "$KITTY_CFG/monero_art.sh"
ok "monero_art.sh installed (executable)"

cp "$REPO_DIR/padded-Monero-Logo.png" "$KITTY_CFG/padded-Monero-Logo.png"
ok "padded-Monero-Logo.png installed"

cp "$REPO_DIR/moneroskullandboneslogo.gif" "$KITTY_CFG/moneroskullandboneslogo.gif"
ok "moneroskullandboneslogo.gif installed"

# ── Install Starship prompt ────────────────────────────────────
header "Installing Starship prompt"

if command -v starship &>/dev/null; then
  ok "Starship already installed: $(starship --version | head -1)"
else
  if command -v curl &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    ok "Starship installed"
  else
    warn "curl not found — skipping Starship. Install manually from https://starship.rs"
  fi
fi

# ── Install Starship config ────────────────────────────────────
header "Installing Starship config"

mkdir -p "$HOME/.config"

if [ -f "$HOME/.config/starship.toml" ]; then
  STAR_BACKUP="$HOME/.config/starship.toml.bak.$(date +%Y%m%d_%H%M%S)"
  cp "$HOME/.config/starship.toml" "$STAR_BACKUP"
  ok "Existing starship.toml backed up → $STAR_BACKUP"
fi

cp "$REPO_DIR/starship.toml" "$HOME/.config/starship.toml"

# Fix powerline glyph (U+E0B0) which can get stripped in file transfers
python3 -c "
content = open('$HOME/.config/starship.toml').read()
content = content.replace('[ \$path ](bold bg:#ff6600 fg:#000000)[](fg:#ff6600 bg:black)', '[ \$path ](bold bg:#ff6600 fg:#000000)[\ue0b0](fg:#ff6600 bg:black)')
open('$HOME/.config/starship.toml', 'w').write(content)
"
ok "starship.toml installed"

# ── Patch shell rc files ───────────────────────────────────────
header "Configuring shell"

patch_rc() {
  local RC_FILE="$1"
  local SHELL_NAME="$2"

  if [ -f "$RC_FILE" ]; then
    if grep -q "starship init" "$RC_FILE"; then
      ok "$RC_FILE already has Starship init — skipping"
    else
      echo "" >> "$RC_FILE"
      echo "# Starship prompt" >> "$RC_FILE"
      echo "eval \"\$(starship init $SHELL_NAME)\"" >> "$RC_FILE"
      ok "Starship init added to $RC_FILE"
    fi
  fi
}

patch_rc "$HOME/.bashrc" "bash"
patch_rc "$HOME/.zshrc"  "zsh"

# ── Done ───────────────────────────────────────────────────────
echo -e "\n${ORANGE}${BOLD}  ✔ All done!${RESET}"
echo -e "  • Restart kitty to see your theme and animation"
echo -e "  • Open a new shell tab to activate the Starship prompt\n"

# 🟠 Kitty Terminal — Monero Theme

A custom [kitty](https://sw.kovidgoyal.net/kitty/) terminal theme built around the Monero aesthetic — deep black background, vivid Monero orange (`#ff6600`), and a Matrix-style ASCII rain animation that resolves into the Monero logo every time you open a new terminal.

---

## ✨ Features

- **Startup animation** — orange character rain cascades down and locks into the Monero ASCII logo, followed by a flash-pulse settle effect
- **Monero color palette** — `#ff6600` orange on pure black, used for cursor, borders, tabs, and foreground
- **Watermark logo** — the Monero logo sits quietly in the bottom-right corner of every window
- **Starship prompt** — matching orange/grey prompt, no special fonts required. Style: `~ > Downloads > ISO ❯`
- **Powerline tab bar** — styled in Monero orange and dark grey
- **Slight background opacity** — `0.95` transparency for a subtle desktop bleed-through

---

## 📋 Requirements

| Requirement | Notes |
|---|---|
| [kitty](https://sw.kovidgoyal.net/kitty/) | Any recent version |
| `python3` | Used by the startup animation |
| `curl` | Used to install Starship automatically |

---

## 🚀 Installation

```bash
git clone https://github.com/Keccak14/kitty-terminal-monero-theme.git
cd kitty-terminal-monero-theme
chmod +x install.sh
./install.sh
```

Then **restart kitty** and open a new shell tab. The animation plays on launch and the prompt activates in any new shell.

> **Note:** If you have an existing `kitty.conf` or `starship.toml`, the installer backs them up with a timestamp before overwriting.

---

## 📁 File Overview

```
kitty-terminal-monero-theme/
├── install.sh              # One-command installer
├── kitty.conf              # Full kitty config with Monero theme
├── startup.session         # Kitty session: runs animation then drops to shell
├── monero_art.sh           # Bash/Python ASCII rain animation
├── starship.toml           # Starship prompt config (Monero colors)
└── padded-Monero-Logo.png  # Window watermark logo
```

---

## 🎨 Color Palette

| Role | Hex |
|---|---|
| Background | `#000000` |
| Foreground / Cursor | `#ff6600` |
| Active border / tab | `#ff6600` |
| Inactive border / tab | `#4C4C4C` |

---

## 💻 Prompt Style

The Starship prompt uses no special fonts — just standard unicode:

```
~ > Downloads > ISO ❯
~/projects/myrepo on main ❯
```

Works with **bash and zsh**. The installer auto-detects which shell(s) you have and patches the correct rc file.

---

## 🔧 Manual Installation

If you prefer not to use the installer, copy the files manually:

```bash
KITTY_CFG="$HOME/.config/kitty"
mkdir -p "$KITTY_CFG"

cp kitty.conf startup.session monero_art.sh padded-Monero-Logo.png "$KITTY_CFG/"
chmod +x "$KITTY_CFG/monero_art.sh"

# Fix the logo path in kitty.conf
sed -i "s|KITTY_CONFIG_DIR|$KITTY_CFG|g" "$KITTY_CFG/kitty.conf"

# Install Starship
curl -sS https://starship.rs/install.sh | sh
cp starship.toml "$HOME/.config/starship.toml"

# Add to your ~/.bashrc or ~/.zshrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc
```

---

## 🎬 How the Animation Works

`monero_art.sh` is a self-contained Bash/Python script with three phases:

1. **Rain phase** — randomized orange characters fall in columns across the full terminal height
2. **Resolve phase** — columns lock into place column-by-column, revealing the Monero ASCII art underneath
3. **Pulse phase** — the logo flashes between warm white and orange 3 times before settling

After the animation completes, your interactive shell starts normally.

---

## 🪙 About Monero

[Monero (XMR)](https://getmonero.org) is a private, decentralized cryptocurrency. This theme is a fan project and is not affiliated with the Monero project.

---

## 📄 License

MIT — do whatever you want with it.

#!/usr/bin/env bash
# setup-oled-extras.sh — Install optional extras for the OLED theme
# Safe to run multiple times (idempotent)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_DIR="$HOME/.config/ghostty"
GTK4_DIR="$HOME/.config/gtk-4.0"

# Detect current theme variant
CURRENT_THEME=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "")
if [[ "$CURRENT_THEME" == "oled-light" ]]; then
  VARIANT="light"
else
  VARIANT="dark"
fi

echo "=== OLED Extras Setup ($VARIANT variant) ==="
echo

# --- Monocraft Nerd Font ---
FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="Monocraft"

if [ -f "$FONT_DIR/Monocraft-nerd-fonts-patched.ttc" ]; then
  echo "[ok] $FONT_NAME already installed (skipped)"
else
  mkdir -p "$FONT_DIR"
  cp "$SCRIPT_DIR"/Monocraft-nerd-fonts-patched.ttc "$FONT_DIR/"
  echo "[ok] Copied Monocraft Nerd Font to $FONT_DIR/"
  fc-cache -f
  echo "[ok] Font cache rebuilt"
fi

if command -v omarchy-font-set &>/dev/null; then
  omarchy-font-set "$FONT_NAME"
  echo "[ok] Set system font to $FONT_NAME via omarchy-font-set"
else
  echo "[!!] omarchy-font-set not found — set your terminal font to '$FONT_NAME' manually"
fi

echo

# --- Ghostty OLED glow shader ---
if [ -d "$GHOSTTY_DIR" ]; then
  GHOSTTY_CONF="$GHOSTTY_DIR/config"

  if [[ "$VARIANT" == "dark" ]]; then
    cp "$SCRIPT_DIR/oled-glow.glsl" "$GHOSTTY_DIR/oled-glow.glsl"
    echo "[ok] Copied oled-glow.glsl to $GHOSTTY_DIR/"

    if [ -f "$GHOSTTY_CONF" ]; then
      # Remove any existing custom-shader lines (and their comments) before adding ours
      sed -i '/^#.*shader/d; /^custom-shader/d; /^custom-shader-animation/d' "$GHOSTTY_CONF"
      # Remove trailing blank lines left behind
      sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$GHOSTTY_CONF"
      printf '\n# OLED glow shader\ncustom-shader = ~/.config/ghostty/oled-glow.glsl\ncustom-shader-animation = false\n' >> "$GHOSTTY_CONF"
      echo "[ok] Replaced custom-shader lines in $GHOSTTY_CONF"
    else
      echo "[!!] No ghostty config found at $GHOSTTY_CONF — add these lines manually:"
      echo '    custom-shader = ~/.config/ghostty/oled-glow.glsl'
      echo '    custom-shader-animation = false'
    fi
  else
    # Light variant — remove glow shader (it's designed for dark backgrounds)
    if [ -f "$GHOSTTY_CONF" ]; then
      sed -i '/^#.*shader/d; /^custom-shader/d; /^custom-shader-animation/d' "$GHOSTTY_CONF"
      sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$GHOSTTY_CONF"
      echo "[ok] Removed glow shader from $GHOSTTY_CONF (not suited for light variant)"
    fi
  fi
else
  echo "[skip] Ghostty config directory not found at $GHOSTTY_DIR"
fi

echo

# --- GTK4 / libadwaita overrides ---
mkdir -p "$GTK4_DIR"

if [[ "$VARIANT" == "dark" ]]; then
  GTK_SRC="$SCRIPT_DIR/gtk4-oled.css"
else
  GTK_SRC="$SCRIPT_DIR/oled-light/gtk4-oled-light.css"
fi

if [ -f "$GTK4_DIR/gtk.css" ] && ! grep -q "OLED" "$GTK4_DIR/gtk.css"; then
  BACKUP="$GTK4_DIR/gtk.css.bak.$(date +%s)"
  cp "$GTK4_DIR/gtk.css" "$BACKUP"
  echo "[ok] Backed up existing gtk.css to $BACKUP"
fi
cp "$GTK_SRC" "$GTK4_DIR/gtk.css"
echo "[ok] Installed $VARIANT OLED gtk.css to $GTK4_DIR/"

echo
echo "=== Done ==="
echo
echo "NOTE: These extras live OUTSIDE the omarchy theme system."
echo "When switching between dark/light, re-run this script to update."
echo "When you switch to a different theme entirely, remove them manually:"
echo
echo "  rm ~/.local/share/fonts/Monocraft-nerd-fonts-patched.ttc && fc-cache -f"
echo "  omarchy-font-set <your-preferred-font>"
echo "  rm ~/.config/gtk-4.0/gtk.css"
if [[ "$VARIANT" == "dark" ]]; then
  echo "  rm ~/.config/ghostty/oled-glow.glsl"
  echo
  echo "And remove these lines from ~/.config/ghostty/config:"
  echo "  custom-shader = ~/.config/ghostty/oled-glow.glsl"
  echo "  custom-shader-animation = false"
fi

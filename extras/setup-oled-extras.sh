#!/usr/bin/env bash
# setup-oled-extras.sh — Install optional extras for the OLED theme
# Safe to run multiple times (idempotent)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GHOSTTY_DIR="$HOME/.config/ghostty"
GTK4_DIR="$HOME/.config/gtk-4.0"

echo "=== OLED Extras Setup ==="
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
  cp "$SCRIPT_DIR/oled-glow.glsl" "$GHOSTTY_DIR/oled-glow.glsl"
  echo "[ok] Copied oled-glow.glsl to $GHOSTTY_DIR/"

  GHOSTTY_CONF="$GHOSTTY_DIR/config"
  if [ -f "$GHOSTTY_CONF" ]; then
    if ! grep -q "^custom-shader.*oled-glow.glsl" "$GHOSTTY_CONF"; then
      printf '\n# OLED glow shader\ncustom-shader = ~/.config/ghostty/oled-glow.glsl\ncustom-shader-animation = false\n' >> "$GHOSTTY_CONF"
      echo "[ok] Added custom-shader lines to $GHOSTTY_CONF"
    else
      echo "[ok] custom-shader already configured in $GHOSTTY_CONF (skipped)"
    fi
  else
    echo "[!!] No ghostty config found at $GHOSTTY_CONF — add these lines manually:"
    echo '    custom-shader = ~/.config/ghostty/oled-glow.glsl'
    echo '    custom-shader-animation = false'
  fi
else
  echo "[skip] Ghostty config directory not found at $GHOSTTY_DIR"
fi

echo

# --- GTK4 / libadwaita overrides ---
mkdir -p "$GTK4_DIR"
if [ -f "$GTK4_DIR/gtk.css" ]; then
  if grep -q "OLED" "$GTK4_DIR/gtk.css"; then
    echo "[ok] gtk.css already contains OLED overrides (skipped)"
  else
    BACKUP="$GTK4_DIR/gtk.css.bak.$(date +%s)"
    cp "$GTK4_DIR/gtk.css" "$BACKUP"
    echo "[ok] Backed up existing gtk.css to $BACKUP"
    cp "$SCRIPT_DIR/gtk4-oled.css" "$GTK4_DIR/gtk.css"
    echo "[ok] Installed OLED gtk.css to $GTK4_DIR/"
  fi
else
  cp "$SCRIPT_DIR/gtk4-oled.css" "$GTK4_DIR/gtk.css"
  echo "[ok] Installed OLED gtk.css to $GTK4_DIR/"
fi

echo

# --- GTK4 / libadwaita overrides (light variant) ---
LIGHT_CSS="$SCRIPT_DIR/oled-light/gtk4-oled-light.css"
if [ -f "$LIGHT_CSS" ]; then
  echo "To use the light GTK4 overrides with oled-light, run:"
  echo "  cp $LIGHT_CSS $GTK4_DIR/gtk.css"
  echo "(This replaces the dark OLED gtk.css installed above)"
fi

echo
echo "=== Done ==="
echo
echo "NOTE: These extras live OUTSIDE the omarchy theme system."
echo "When you switch to a different theme, remove them manually:"
echo
echo "  rm ~/.local/share/fonts/Monocraft-nerd-fonts-patched.ttc && fc-cache -f"
echo "  omarchy-font-set <your-preferred-font>"
echo "  rm ~/.config/ghostty/oled-glow.glsl"
echo "  rm ~/.config/gtk-4.0/gtk.css"
echo
echo "And remove these lines from ~/.config/ghostty/config:"
echo "  custom-shader = ~/.config/ghostty/oled-glow.glsl"
echo "  custom-shader-animation = false"

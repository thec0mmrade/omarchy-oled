# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

This is **OLED**, a true-black high-contrast dark theme for [Omarchy](https://omarchy.com) (a Hyprland-based Linux desktop). Inspired by Rockbox player themes (CrazyBitMono, SNAZZA) and OLED display aesthetics — true black backgrounds, crisp pixel edges, and cyan accents.

## Theme Installation

```bash
omarchy-theme-install https://github.com/thec0mmrade/omarchy-oled
omarchy-theme-set oled
```

Optional extras (Monocraft Nerd Font, Ghostty glow shader, and GTK4 overrides) are installed separately via `./extras/setup-oled-extras.sh`.

## Architecture

The theme is a flat collection of config files consumed by `omarchy-theme-set`. Each file targets a specific application:

- **`colors.toml`** — Canonical color palette (TOML). Terminal colors (color0–color15) plus accent, cursor, foreground, background, selection colors. This is the **single source of truth** for the palette; all other files should use these same hex values.
- **`hyprland.conf`** — Hyprland window manager overrides: border colors, rounding=0 for pixel-perfect crispness, shadow disabled, blur disabled.
- **`waybar.css`** / **`walker.css`** / **`swayosd.css`** — CSS overrides for Waybar, Walker (launcher), and SwayOSD respectively. No text-shadow (crisp OLED look).
- **`btop.theme`** — btop++ color theme using `theme[key]="hex"` syntax.
- **`neovim.lua`** — LazyVim plugin spec that installs and sets the `cyberdream` colorscheme with true black bg override.
- **`vscode.json`** — VS Code theme reference (`{"name": "...", "extension": "..."}`).
- **`chromium.theme`** — Chromium toolbar RGB values (comma-separated).
- **`icons.theme`** — GTK icon theme name.
- **No `light.mode`** — Absence triggers dark mode / Adwaita-dark.
- **`backgrounds/`** — Wallpaper images. Numbered filenames (e.g., `1-oled-black.png`) set ordering; the first is the default.

### Extras (outside omarchy theme system)

Files in `extras/` are **not** managed by `omarchy-theme-set` and must be installed/removed manually:

- **`extras/Monocraft-nerd-fonts-patched.ttc`** — Nerd Font-patched Monocraft font (Minecraft-inspired chunky pixel font). Installed to `~/.local/share/fonts/` and set as system font via `omarchy-font-set`.
- **`extras/oled-glow.glsl`** — GLSL fragment shader for Ghostty: subtle cyan-tinted bloom around bright text on dark background (inverse of a drop shadow), plus faint scanline overlay. Uses Ghostty's iChannel0/iResolution API.
- **`extras/gtk4-oled.css`** — libadwaita/GTK4 color overrides for apps like Nautilus. Uses layered near-black shades (#000000, #050505, #0A0A0A) for depth.
- **`extras/setup-oled-extras.sh`** — Idempotent install script for the above extras.
- **`extras/oled-light/`** — Complete light variant theme directory (bg=#FFFFFF, fg=#000000, accent=#008BAD). Copy to `~/.config/omarchy/themes/oled-light` and activate with `omarchy-theme-set oled-light`.

## Key Color Values

| Role          | Hex       |
|---------------|-----------|
| Background    | `#000000` |
| Foreground    | `#E8E8E8` |
| Accent        | `#00D4FF` |
| Cursor        | `#00D4FF` |
| Selection FG  | `#000000` |
| Selection BG  | `#00D4FF` |

### Light Variant

| Role          | Hex       |
|---------------|-----------|
| Background    | `#FFFFFF` |
| Foreground    | `#000000` |
| Accent        | `#008BAD` |

## Design Principles

- **No shadows, no blur, no rounding** — pixel-perfect crispness throughout.
- **True black #000000** — not near-black, for maximum OLED contrast and power saving.
- **Cyan is the only color accent** — everything else is grayscale. Muted red/green/yellow only for semantic signals (errors, diffs, warnings).
- **Layered blacks for depth** — in GTK4 overrides: headerbar #0A0A0A, sidebar #050505, content #000000.
- **Light variant uses darker cyan** (#008BAD) for WCAG AA contrast on white background.

When editing theme files, ensure hex values stay consistent with `colors.toml`.

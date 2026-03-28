#!/bin/bash
# install.sh — installs the GPU Mode Switcher plasmoid for CachyOS KDE Plasma 6
set -e

PLASMOID_ID="org.kde.envycontrol.gpuswitcher"
PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/$PLASMOID_ID"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== GPU Mode Switcher — Installer ==="
echo ""

# ── 1. Check envycontrol is installed ────────────────────────────────────────
if ! command -v envycontrol &>/dev/null; then
    echo "[!] envycontrol not found. Install it first:"
    echo "    sudo pacman -S envycontrol"
    exit 1
fi
echo "[✓] envycontrol found: $(which envycontrol)"

# ── 2. Install the helper script to /usr/local/bin ───────────────────────────
echo "[*] Installing helper script to /usr/local/bin/envycontrol-switch.sh ..."
sudo install -m 755 "$SCRIPT_DIR/envycontrol-switch.sh" /usr/local/bin/envycontrol-switch.sh
echo "[✓] Helper script installed"

# ── 3. Install polkit policy ──────────────────────────────────────────────────
echo "[*] Installing polkit policy ..."
sudo install -m 644 "$SCRIPT_DIR/org.kde.envycontrol.switch.policy" \
    /usr/share/polkit-1/actions/org.kde.envycontrol.switch.policy
echo "[✓] Polkit policy installed"

# ── 4. Install the plasmoid ───────────────────────────────────────────────────
echo "[*] Installing plasmoid to $PLASMOID_DIR ..."
rm -rf "$PLASMOID_DIR"
mkdir -p "$PLASMOID_DIR"
cp -r "$SCRIPT_DIR/plasmoid/"* "$PLASMOID_DIR/"
echo "[✓] Plasmoid files installed"

# ── 5. Register with Plasma ───────────────────────────────────────────────────
echo "[*] Registering plasmoid with Plasma ..."
kbuildsycoca6 --noincremental 2>/dev/null || true
echo "[✓] Done"

echo ""
echo "=== Installation complete! ==="
echo ""
echo "To add the widget:"
echo "  1. Right-click your system tray (bottom-right clock area)"
echo "  2. Click 'Configure System Tray...'"
echo "  3. Go to the 'Extra Items' tab"
echo "  4. Find 'GPU Mode Switcher' and enable it"
echo ""
echo "Or: right-click the desktop → Add Widgets → search 'GPU Mode Switcher'"
echo ""
echo "The widget icon will appear in your system tray."
echo "Left-click or right-click it to open the GPU switcher menu."

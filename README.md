# gpu-mode-switcher-kde
a KDE Plasma widget for laptop GPU mode switching (iGPU, dGPU and hybrid)

---

## Requirements

- KDE Plasma 6
- [`envycontrol`](https://github.com/bayasdev/envycontrol) installed system-wide
- A laptop with NVIDIA + Intel/AMD (Optimus)

```bash
sudo pacman -S envycontrol   # Arch
```

---

## Installation

**1. Download and extract**

```bash
cd gpu-mode-switcher
```

**2. Run the installer**

```bash
bash install.sh
```

This will:
- Install the helper script to `/usr/local/bin/`
- Install the polkit policy (enables the graphical sudo prompt)
- Register the plasmoid with Plasma

**3. Add to your panel**

Right-click the desktop → **Add Widgets** → search **GPU Mode Switcher** → drag it to your panel.

---

## Usage

Click the tray icon to open the switcher. Select a mode and confirm — a native KDE password prompt will appear. After switching, you'll be asked to reboot.

| Mode | Description |
|------|-------------|
| **Integrated** | iGPU only (Intel/AMD) — best battery life |
| **NVIDIA** | dGPU only — max performance |
| **Hybrid** | iGPU renders, dGPU available on-demand via PRIME |

---

## Troubleshooting

**Widget doesn't appear in search**
```bash
kbuildsycoca6 --noincremental
killall plasmashell; nohup plasmashell > /dev/null 2>&1 &
```

**Test the widget standalone**
```bash
plasmawindowed org.kde.envycontrol.gpuswitcher
```

**Mode shows as "unknown"**
Make sure `envycontrol` is installed as a system package, not just in a virtualenv or pipx.

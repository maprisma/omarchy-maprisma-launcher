# Maprisma Launcher for Omarchy

![Maprisma Launcher preview](preview.png)

A bar icon and shell companion for **Maprisma Launcher** — the theme-aware application launcher, AI package advisor, global shortcut manager, and optional dock built for **Omarchy** as an AI-driven Linux desktop.

---

## Highlights

### ✦ Ask AI — Cloud Coding Agents & Local LLMs on Your PC
One `✦` button in the header connects your launcher to the AI tools already on your Omarchy desktop:
- **Cloud & CLI agents:** **Claude Code** (`claude`), **Codex** (`codex`), **Antigravity** (`agy`), **Hermes** (`hermes`), and **pi** (`pi` online models).
- **100% Local LLMs on your PC:** Picks up local models configured in `~/.pi/agent/models.json` served by **Ollama** (`127.0.0.1:11434`) or **llama.cpp** (`127.0.0.1:8080`), starting the user service on demand when you click Ask — zero tokens, nothing leaves your computer.
- **Find, install, update, explain, hide or unhide:** Ask for the right tool (*"Suggest a fast RAW photo editor"*, *"What can I update?"*, *"List my hidden apps"*). The core checks every suggested package against your real package managers (`pacman`, Flatpak, and optionally AUR).
- **Safe by design:** Helpers run locked down without file, shell, or MCP tools. Nothing is installed, updated, removed, or hidden without your click, and every package command is shown first and executed in the built-in terminal. Can be turned off anytime in **Settings › Apps & AI** (the `✦` button then opens direct package search).

### ⌨ Global Shortcuts & Live Owner-Coloured Key Map
Right-click any app and choose **Shortcut…** to manage global Hyprland keybindings without hand-editing config files:
- **Visual keyboard map coloured by owner:** Select modifiers (`Super`, `Shift`, `Ctrl`, `Alt`) and see every key on your keyboard coloured live:
  - **Green (`free`):** Available to assign immediately.
  - **Yellow (`yours`):** Already assigned in your custom bindings or Maprisma Launcher.
  - **Orange (`Omarchy default`):** Used by an Omarchy default binding (shows the exact action, e.g. *Omarchy's "Toggle window grouping"*).
- **Safe one-click Rebind:** Rebinding an Omarchy key cleanly unbinds the default only while your shortcut exists; removing your shortcut automatically brings the Omarchy default back.
- **One-step & two-step submap shortcuts:** Supports both direct keys (`Super + B`) and two-step chords (`Super + Alt + Space`, then `N`), plus app-specific desktop actions (e.g. *New Private Window*).
- **Validated by Hyprland:** Writes a single managed file sourced from `~/.config/hypr/bindings.conf` and validates with Hyprland before applying.

### ⬡ Deep Omarchy Integration
- **Launch & organise your way:** Narrow **List** view (A–Z, by group, or by origin) and wide views (**Folders**, **Cards** with package sizes and sources, **Icons**, and an interactive **3D Cube** that flips between your groups and app origins).
- **Window & workspace control:** See running instance counts at a glance; right-click to **Open in floating window**, **Open on workspace 1–10**, **Switch to window**, or **Close window** (with per-window or *Close all* submenu when multiple windows are open).
- **AI coding tools on the desktop:** Automatically discovers installed CLI coding agents (`claude`, `codex`, `pi`, `hermes`, `cursor-agent`, `opencode`, `aider`, `gemini`, `qwen`, …) so you can launch, group, or bind them like any desktop app.
- **Native Omarchy look & behaviour:** Follows your active Omarchy theme colours and Hyprland window corner rounding live; closes when clicking outside on Hyprland (configurable in **Settings › General**); supports 8 interface languages (`en`, `de`, `es`, `fr`, `it`, `ja`, `pt`, `zh`) and `F12` window screenshots with notes.
- **Optional Layer-Shell Dock:** Enable **Settings › Dock** for an Omarchy screen-edge dock with pinned apps, running indicators, auto-hide, and hover magnification (uses `gtk-layer-shell`).

---

## ✦ Coming Soon: Maprisma for AI Management

**Maprisma Launcher** is the first companion in the **Maprisma** desktop suite for Omarchy. Coming soon: **Maprisma** — a dedicated visual control centre for managing AI coding agents, cloud providers, local LLM servers (`llama.cpp` / Ollama), MCP servers, skills, rules, and live token/VRAM telemetry across your Omarchy workstation.

---

## Install

Add the plugin:

```sh
omarchy plugin add https://github.com/maprisma/omarchy-maprisma-launcher
```

Then **click the Maprisma Launcher icon in the bar**. The app is not there yet, so a small panel opens instead:

1. Click **Install Maprisma Launcher**. The panel downloads the official AppImage (version 0.1.3, 10.9 MB) from the [GitHub release](https://github.com/maprisma/launcher/releases), shows the progress and checks its SHA-256 fingerprint.
2. Click **Open Maprisma Launcher**. From now on, the bar icon opens and closes the app.

No administrator rights are needed: the app is saved for your user only, as `~/.local/bin/maprisma-launcher`. Without FUSE 2 the AppImage still runs (it unpacks itself first).

<details>
<summary>Install the app by hand instead</summary>

```sh
v=0.1.3; f=Maprisma-Launcher-$v-x86_64.AppImage
cd "$(mktemp -d)"
curl -fLO "https://github.com/maprisma/launcher/releases/download/v$v/$f"
echo "88b092e79c9186653f01912237282c46b174f7bfa7b3bffab86dab586578ae31  $f" | sha256sum -c
[ ! -e ~/.local/bin/maprisma-launcher ] && [ ! -L ~/.local/bin/maprisma-launcher ] && install -Dm755 "$f" ~/.local/bin/maprisma-launcher
```

</details>

To remove the app: `rm ~/.local/bin/maprisma-launcher` (your settings stay in `~/.config/maprisma-launcher`). To remove the plugin:

```sh
omarchy plugin remove ubruckhaus.maprisma-launcher
```

(Removing the plugin leaves the `maprisma-launcher` application and your settings intact.)

---

## What the plugin does

A click on the bar icon runs `maprisma-launcher-toggle --check`. When the app is installed, `maprisma-launcher-toggle` invokes `maprisma-launcher --toggle` (the app keeps a single window and shows or hides it). When it is not, the widget opens its install panel (`Panel.qml`).

**Installer (only on the panel's Install button):** `maprisma-launcher-install` downloads one fixed file, `https://github.com/maprisma/launcher/releases/download/v0.1.3/Maprisma-Launcher-0.1.3-x86_64.AppImage`, with `curl` (HTTPS only, also for redirects; size and time limits). It keeps the file only if its size and SHA-256 match the values pinned in the script, and places it as `~/.local/bin/maprisma-launcher` with a hard link that fails instead of replacing anything: if a file, link or folder is already there, nothing is changed. It also stops before writing anything when `~/.local/bin` is not a real folder of the user that only the user may write to, or when a folder above it is a symlink or may be changed by other accounts (root-owned sticky folders such as `/tmp` are fine). It takes no arguments and never asks for root or administrator rights. Failed downloads and normal interruptions clean up the temporary file; an uncatchable kill may leave a temporary folder. This is the plugin's only network access, and it happens only after that click.

When the shell starts, the widget also runs `maprisma-launcher-toggle --dock` to launch the optional dock if enabled in **Settings › Dock** (off by default; requires the `gtk-layer-shell` package). With the dock disabled, the process exits immediately; without the app installed, nothing happens. The plugin starts no background daemon and takes no text input.

## Languages

The install panel follows the system language (English, German, French, Spanish, Italian, Portuguese, Dutch, Polish), with English as the fallback. The app has its own language setting.

All settings, groups, and history belong to the app (`~/.config/maprisma-launcher`). On first run, the app imports existing groups and settings from the older App Manager plugin if present, leaving the old files untouched.

## Tests

`sh tests/test-toggle.sh` tests the toggle script with a mock app binary and notifier.

## License

MIT, see [LICENSE](LICENSE).

# Maprisma Launcher for Omarchy

A bar icon that opens and closes **Maprisma Launcher**: all your apps in one theme-aware window.

- **Launch:** type to filter, Enter starts the app; Esc clears, then closes.
- **Organise:** groups or "by origin" when narrow; folders, cards or icons when wide, with your groups in a
  bar at the bottom; drag apps between groups.
- **See at a glance:** what is running, new installs (★), available updates, size and where each app
  comes from.
- **Install and remove:** search the package managers you allow (pacman, Flatpak, AUR off by default, …);
  every install shows the exact command first and runs in your terminal.
- **Ask AI (optional):** Claude Code, Codex or Antigravity suggest real packages for what you need; nothing
  happens without your click and the same review.
- Follows the Omarchy theme and window corners; 8 languages; F12 saves a screenshot with a note.

## Install

This plugin is only the bar icon. Install the app itself first:

```sh
yay -S maprisma-launcher-bin
```

or download the AppImage from <https://github.com/maprisma/launcher/releases>, make it executable and put it
on your PATH as `maprisma-launcher`.

Then add the plugin: `omarchy plugin add https://github.com/maprisma/omarchy-maprisma-launcher`.
Remove it again with `omarchy plugin remove ubruckhaus.maprisma-launcher` (the app stays installed).

## What the plugin does

`BarWidget.qml` runs `maprisma-launcher-toggle` on a click. The script starts `maprisma-launcher --toggle`
(the app keeps a single window and shows or hides it). If the app is not installed, it shows a plain-text
notification with the line above.

When the shell loads, the widget also runs `maprisma-launcher-toggle --dock`: the app's optional dock
(Settings › Dock in the app, off by default; it needs the `gtk-layer-shell` package). With the dock off the
process ends at once; without the app nothing happens. The plugin installs nothing, starts no service, opens no network
connection and takes no input.

Its settings, groups and history are the app's (`~/.config/maprisma-launcher`). On its first start the app
copies the settings of the older App Manager plugin, if there are any; the old files stay untouched.

## Tests

`sh tests/test-toggle.sh`: the script with a fake app and a fake notifier.

## License

MIT, see LICENSE.

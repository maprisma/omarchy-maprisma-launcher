import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "I18n.js" as I18n

BarWidget {
  id: root

  moduleName: "ubruckhaus.maprisma-launcher"

  readonly property string togglePath: Qt.resolvedUrl("maprisma-launcher-toggle").toString().replace(/^file:\/\//, "")
  readonly property string installPath: Qt.resolvedUrl("maprisma-launcher-install").toString().replace(/^file:\/\//, "")

  // The panel's language: the system's (LC_ALL → LC_MESSAGES → LANG), else English.
  readonly property string systemLang: I18n.systemLanguage(Quickshell.env("LC_ALL"), Quickshell.env("LC_MESSAGES"), Quickshell.env("LANG"))
  readonly property string lang: I18n.resolve("auto", systemLang)
  function t(key, args) { return I18n.tr(lang, key, args) }

  // The install (maprisma-launcher-install, only from the panel's button):
  // "idle", "running", "done" or "error"; its step, bytes and error code.
  property string installState: "idle"
  property string installStep: ""
  property real downloaded: 0
  property real total: 0
  property string errorCode: ""

  function startInstall() {
    if (installer.running) return
    root.installState = "running"
    root.installStep = "download"
    root.downloaded = 0
    root.errorCode = ""
    installer.running = true
  }

  Process {
    id: installer
    command: [root.installPath]
    stdout: SplitParser {
      onRead: function(line) {
        var parts = String(line).trim().split(" ")
        if (parts[0] === "step") root.installStep = parts[1] || ""
        else if (parts[0] === "progress") { root.downloaded = Number(parts[1]) || 0; root.total = Number(parts[2]) || 0 }
        else if (parts[0] === "error") root.errorCode = /^[a-z0-9]{1,20}$/.test(parts[1] || "") ? parts[1] : "other"
      }
    }
    onExited: function(code) {
      if (code === 0) root.installState = "done"
      else {
        if (!root.errorCode) root.errorCode = "other"
        root.installState = "error"
      }
    }
  }

  // A click: open the app when it is installed, else the install panel.
  Process {
    id: check
    command: [root.togglePath, "--check"]
    onExited: function(code) {
      if (code === 0 && root.installState !== "running") Quickshell.execDetached([root.togglePath])
      else root.open()
    }
  }

  function openApp() {
    root.close()
    Quickshell.execDetached([root.togglePath])
  }

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  // Shape contract for shell summon/hide/toggle routing.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false
  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function toggle() { if (panelLoader.item) panelLoader.item.toggle() }
  function closeForPopoutSwitch() { if (panelLoader.item) panelLoader.item.closeForPopoutSwitch() }

  // The app's optional dock (Settings › Dock in the app): started with the shell. It quits at
  // once when switched off, and a second start only makes a running dock re-read its settings.
  Component.onCompleted: Quickshell.execDetached([root.togglePath, "--dock"])
  onBarChanged: injectPanel()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Loader {
    id: panelLoader
    active: true
    // A per-load query defeats the QML component cache, so a hot reload picks up a changed Panel.qml.
    source: Qt.resolvedUrl("Panel.qml") + "?load=" + Date.now()
    visible: false
    onLoaded: { root.injectPanel(); Qt.callLater(root.injectPanel) }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: root.opened ? "" : "Maprisma Launcher"

    onPressed: function(mouseButton) {
      if (!root.bar) return
      // Detached toggle, so a click is never dropped; the panel only when the app is missing.
      if (root.opened) { root.close(); return }
      if (!check.running) check.running = true
    }
  }
}

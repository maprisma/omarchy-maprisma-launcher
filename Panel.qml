pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.Commons
import qs.Commons as Commons
import qs.Ui

// The install panel: shown by a click on the bar icon while the Maprisma
// Launcher app is not installed. One button downloads and checks the AppImage
// (maprisma-launcher-install, run by BarWidget.qml); afterwards the bar icon
// opens the app. Everything shown is plain text.
Panel {
  id: root
  moduleName: "ubruckhaus.maprisma-launcher"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property color fg: Commons.Color.popups.text
  readonly property color dim: Qt.darker(fg, 1.45)
  readonly property string font: root.bar ? root.bar.fontFamily : Style.font.family

  readonly property string installState: hostWidget ? hostWidget.installState : "idle"
  readonly property string step: hostWidget ? hostWidget.installStep : ""
  readonly property real downloaded: hostWidget ? hostWidget.downloaded : 0
  readonly property real total: hostWidget ? hostWidget.total : 0
  readonly property string version: "0.1.3"
  readonly property string sizeMb: "10.9"
  function t(key, args) { return hostWidget ? hostWidget.t(key, args) : key }
  function mb(bytes) { return (Number(bytes || 0) / 1000000).toFixed(1) }
  function errorText(code) {
    var key = { download: "errDownload", checksum: "errChecksum", exists: "errExists", arch: "errArch", curl: "errCurl" }[code]
    return key ? t(key) : t("errOther", [code || "?"])
  }

  function open() { root.controller.show() }
  function close() { root.controller.hide() }
  function toggle() { if (root.opened) root.close(); else root.open() }

  component Para: Text {
    textFormat: Text.PlainText
    width: parent ? parent.width : 300
    wrapMode: Text.Wrap
    color: root.fg
    font.family: root.font
    font.pixelSize: Style.font.bodySmall
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(column.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onActivateRequested: {
        if (root.installState === "done") root.hostWidget.openApp()
        else if (root.installState !== "running" && root.hostWidget) root.hostWidget.startInstall()
      }
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: scroller
        anchors.fill: parent
        contentWidth: width
        contentHeight: column.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height

        Column {
          id: column
          width: scroller.width
          spacing: Style.space(10)

          PanelHero {
            foreground: root.fg
            fontFamily: root.font
            title: "Maprisma Launcher"
            meta: root.installState === "done" ? root.t("installedPill") : root.t("notInstalled")
            detail: root.installState === "running" ? root.t("installing") : (root.installState === "done" ? root.t("installedPill") : "")
          }

          PanelSeparator {}

          Para { text: root.installState === "done" ? root.t("doneText") : root.t("intro") }
          Para {
            visible: root.installState !== "done"
            color: root.dim
            font.pixelSize: Style.font.caption
            text: root.t("explain", [root.version, root.sizeMb])
          }

          // Progress while it runs.
          Item {
            visible: root.installState === "running"
            width: parent.width
            height: progressLabel.height + Style.space(10)
            Text {
              id: progressLabel
              textFormat: Text.PlainText
              color: root.dim
              font.family: root.font
              font.pixelSize: Style.font.caption
              text: root.step === "verify"
                ? root.t("verifying")
                : root.t("downloading", [root.mb(root.downloaded), root.mb(root.total || 10922488)])
            }
            Rectangle {
              anchors.bottom: parent.bottom
              width: parent.width
              height: Style.space(5)
              radius: height / 2
              color: Qt.rgba(root.fg.r, root.fg.g, root.fg.b, 0.12)
              Rectangle {
                width: parent.width * (root.step === "verify" ? 1 : Math.max(0, Math.min(1, root.total > 0 ? root.downloaded / root.total : 0)))
                height: parent.height
                radius: parent.radius
                color: Commons.Color.accent
              }
            }
          }

          Para {
            visible: root.installState === "error"
            color: Commons.Color.urgent
            text: root.errorText(root.hostWidget ? root.hostWidget.errorCode : "")
          }

          PanelSeparator {}

          Row {
            spacing: Style.space(8)
            Button {
              visible: root.installState === "idle" || root.installState === "error"
              text: root.installState === "error" ? root.t("tryAgain") : root.t("install")
              iconText: "\u{F01DA}"
              bordered: true
              foreground: root.fg
              fontFamily: root.font
              tooltipText: root.t("installTip")
              onClicked: if (root.hostWidget) root.hostWidget.startInstall()
            }
            Button {
              visible: root.installState === "done"
              text: root.t("open")
              iconText: "\u{F0BAD}"
              bordered: true
              foreground: root.fg
              fontFamily: root.font
              onClicked: if (root.hostWidget) root.hostWidget.openApp()
            }
          }

          Para {
            visible: root.installState === "done"
            color: root.dim
            font.pixelSize: Style.font.caption
            text: root.t("removeHint")
          }
        }
      }
    }
  }
}

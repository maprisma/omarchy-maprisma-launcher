import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarWidget {
  id: root

  moduleName: "ubruckhaus.maprisma-launcher"

  readonly property string togglePath: Qt.resolvedUrl("maprisma-launcher-toggle").toString().replace(/^file:\/\//, "")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "Maprisma Launcher"

    onPressed: function(mouseButton) {
      if (!root.bar) return
      // Detached so a click is never dropped while a previous toggle still runs.
      Quickshell.execDetached([root.togglePath])
    }
  }
}

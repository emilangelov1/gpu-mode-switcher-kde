import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

Item {
    id: compactRoot

    // Icon changes based on current GPU mode
    property string iconName: {
        switch (plasmoid.rootItem.currentMode) {
            case "integrated":  return "battery-good-symbolic"
            case "nvidia":      return "video-display-symbolic"
            case "hybrid":      return "monitor-symbolic"
            default:            return "video-display-symbolic"
        }
    }

    // Accent color dot overlay
    property color accentColor: {
        switch (plasmoid.rootItem.currentMode) {
            case "integrated":  return "#22c55e"
            case "nvidia":      return "#76b900"
            case "hybrid":      return "#f59e0b"
            default:            return "#888888"
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: plasmoid.expanded = !plasmoid.expanded
    }

    Kirigami.Icon {
        id: icon
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.8
        height: width
        source: compactRoot.iconName

        opacity: plasmoid.rootItem.isQuerying ? 0.5 : 1.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    // Small colored dot indicator
    Rectangle {
        width: 7
        height: 7
        radius: 3.5
        color: compactRoot.accentColor
        anchors.right: icon.right
        anchors.bottom: icon.bottom
        anchors.rightMargin: -1
        anchors.bottomMargin: -1
        visible: plasmoid.rootItem.currentMode !== "unknown"

        // Pulsing animation when switching
        SequentialAnimation on opacity {
            running: plasmoid.rootItem.isSwitching
            loops: Animation.Infinite
            NumberAnimation { to: 0.2; duration: 600 }
            NumberAnimation { to: 1.0; duration: 600 }
        }
    }

    // Tooltip
    PlasmaComponents.ToolTip {
        text: {
            var mode = plasmoid.rootItem.currentMode
            if (mode === "unknown") return "GPU Mode Switcher\nStatus unknown — click to check"
            return "GPU Mode Switcher\nCurrent: " + mode.charAt(0).toUpperCase() + mode.slice(1)
        }
    }
}

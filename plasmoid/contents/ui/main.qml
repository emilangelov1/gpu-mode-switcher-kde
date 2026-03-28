import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    toolTipMainText: "GPU Mode Switcher"
    toolTipSubText: "Current mode: " + currentMode.toUpperCase()

    Plasmoid.icon: currentMode === "nvidia"  ? "preferences-desktop-display" :
                   currentMode === "hybrid"  ? "computer-laptop" :
                                               "battery-good"

    property string currentMode:   "unknown"
    property bool   isSwitching:   false
    property string statusMessage: ""

    // ── Plasma5Support DataSource — correct API for Plasma 6 ─────────────────
    Plasma5Support.DataSource {
        id: querySource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            var out = (data["stdout"] || "").trim().toLowerCase()
            if      (out.indexOf("integrated") !== -1) root.currentMode = "integrated"
            else if (out.indexOf("nvidia")      !== -1) root.currentMode = "nvidia"
            else if (out.indexOf("hybrid")      !== -1) root.currentMode = "hybrid"
            else                                         root.currentMode = "unknown"
            disconnectSource(source)
        }
    }

    Plasma5Support.DataSource {
        id: switchSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            root.isSwitching = false
            var exit = data["exit code"] !== undefined ? data["exit code"] : 1
            if (exit === 0) {
                root.statusMessage = "Done! Reboot to apply."
                rebootTimer.start()
            } else {
                root.statusMessage = "Error — is envycontrol installed?"
            }
            disconnectSource(source)
        }
    }

    Timer {
        id: rebootTimer
        interval: 600
        onTriggered: rebootDialog.open()
    }

    Component.onCompleted: querySource.connectSource("envycontrol --query")

    // ── Popup ─────────────────────────────────────────────────────────────────
    fullRepresentation: Item {
        implicitWidth:  Kirigami.Units.gridUnit * 18
        implicitHeight: col.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: col
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.smallSpacing

            PlasmaExtras.Heading {
                level: 3
                text: "GPU Mode Switcher"
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "dialog-information"
                    implicitWidth:  Kirigami.Units.iconSizes.small
                    implicitHeight: Kirigami.Units.iconSizes.small
                }
                PlasmaComponents.Label {
                    text: root.isSwitching
                          ? "Switching…"
                          : "Active: " + (root.currentMode === "unknown"
                                          ? "detecting…"
                                          : root.currentMode.toUpperCase())
                    opacity: 0.75
                }
            }

            PlasmaComponents.Label {
                visible:  root.statusMessage !== ""
                text:     root.statusMessage
                color:    root.statusMessage.startsWith("Error")
                          ? Kirigami.Theme.negativeTextColor
                          : Kirigami.Theme.positiveTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Kirigami.Separator { Layout.fillWidth: true }

            Repeater {
                model: [
                    { mode: "integrated", label: "Integrated (iGPU)",  desc: "Intel/AMD only · best battery",      icon: "battery-good" },
                    { mode: "nvidia",     label: "NVIDIA (dGPU)",       desc: "Full GPU · max performance",         icon: "preferences-desktop-display" },
                    { mode: "hybrid",     label: "Hybrid (PRIME)",      desc: "iGPU renders · dGPU on-demand",     icon: "computer-laptop" }
                ]
                delegate: PlasmaComponents.Button {
                    Layout.fillWidth: true
                    enabled:     !root.isSwitching && root.currentMode !== modelData.mode
                    highlighted: root.currentMode === modelData.mode
                    icon.name:   modelData.icon
                    text:        modelData.label
                    PlasmaComponents.ToolTip { text: modelData.desc }
                    onClicked: {
                        root.isSwitching   = true
                        root.statusMessage = ""
                        switchSource.connectSource(
                            "pkexec /usr/local/bin/envycontrol-switch.sh " + modelData.mode
                        )
                    }
                }
            }

            Kirigami.Separator { Layout.fillWidth: true }

            PlasmaComponents.Button {
                Layout.fillWidth: true
                icon.name: "view-refresh"
                text:      "Refresh status"
                onClicked: {
                    root.currentMode   = "unknown"
                    root.statusMessage = ""
                    querySource.connectSource("envycontrol --query")
                }
            }
        }
    }

    Kirigami.PromptDialog {
        id: rebootDialog
        title:    "Reboot required"
        subtitle: "GPU mode changed. Reboot now to apply?"
        standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
        onAccepted: switchSource.connectSource("systemctl reboot")
    }
}

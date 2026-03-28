import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    // Compact representation — the panel icon
    compactRepresentation: CompactRepresentation {}

    // Full representation — the popup
    fullRepresentation: FullRepresentation {}

    // Shared state
    property string currentMode: "unknown"
    property bool isQuerying: false
    property bool isSwitching: false
    property string statusMessage: ""
    property bool statusIsError: false

    // Query current GPU mode on startup and after switching
    function queryCurrentMode() {
        isQuerying = true
        statusMessage = ""
        queryProcess.start()
    }

    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            var stdout = data["stdout"].trim()
            var stderr = data["stderr"].trim()
            var exitCode = data["exit code"]

            disconnectSource(sourceName)

            if (sourceName.indexOf("envycontrol --query") !== -1) {
                root.isQuerying = false
                if (exitCode === 0 && stdout !== "") {
                    root.currentMode = stdout.toLowerCase()
                } else {
                    root.currentMode = "unknown"
                }
            } else if (sourceName.indexOf("envycontrol -s") !== -1) {
                root.isSwitching = false
                if (exitCode === 0) {
                    root.statusMessage = "Mode set! Reboot to apply."
                    root.statusIsError = false
                    root.queryCurrentMode()
                } else {
                    root.statusMessage = stderr !== "" ? stderr : "Failed to switch mode."
                    root.statusIsError = true
                }
            }
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }

    // Use a Timer to query on startup (DataSource needs a moment)
    Timer {
        interval: 500
        running: true
        repeat: false
        onTriggered: root.queryCurrentMode()
    }

    function queryCurrentMode() {
        isQuerying = true
        statusMessage = ""
        executable.exec("envycontrol --query")
    }

    function switchMode(mode) {
        if (isSwitching) return
        isSwitching = true
        statusMessage = "Switching to " + mode + "..."
        statusIsError = false
        executable.exec("pkexec envycontrol -s " + mode)
    }

    function reboot() {
        executable.exec("systemctl reboot")
    }
}

//@ pragma Env QT_WAYLAND_DISABLE_WINDOWDECORATION=1

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    readonly property string home: Quickshell.env("HOME") || "/home/ro"
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    readonly property string stateDir: `${runtimeDir}/dms-dictation`
    readonly property string toggleScript: Quickshell.env("DMS_DICTATION_TOGGLE") || `${home}/.local/bin/dms-dictation-toggle`

    property string state: "idle"
    property string message: "ready"
    property string transcript: ""
    property string error: ""
    property string dmsFontFamily: "Inter Variable"
    readonly property bool active: state === "listening" || state === "stopping" || state === "transcribing" || state === "setup"
    readonly property bool failed: state === "error"
    readonly property real minAudioBarHeight: 3
    readonly property real maxAudioBarHeight: 14
    readonly property real audioBarHeightRange: maxAudioBarHeight - minAudioBarHeight
    property var audioBarHeights: [minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight]
    readonly property color idleChip: "#3c3836"
    readonly property color idleChipHover: "#504945"
    readonly property color recordingChip: "#d65d0e"
    readonly property color busyChip: "#d79921"
    readonly property color errorChip: "#cc241d"
    readonly property color barInk: "#ebdbb2"
    readonly property string statusLabel: {
        if (state === "listening")
            return "Stop";
        if (state === "stopping")
            return "Stopping";
        if (state === "transcribing")
            return "Transcribing";
        if (state === "setup")
            return "Preparing";
        if (state === "error")
            return message || "Dictation failed";
        return "Dictate";
    }
    readonly property string statusHint: {
        if (state === "listening")
            return "finish dictation";
        if (state === "stopping")
            return "finishing capture";
        if (state === "transcribing")
            return "processing audio";
        if (state === "setup")
            return "getting ready";
        if (state === "error")
            return error || "tap to retry";
        return "tap to start";
    }

    function refreshStatus(): void {
        if (statusProcess.running)
            return;
        statusProcess.command = ["bash", "-lc", `cat '${stateDir}/status.json' 2>/dev/null || printf '{"state":"idle","message":"ready"}\\n'`];
        statusProcess.running = true;
    }

    function activate(): void {
        const action = state === "listening" ? "finish" : "toggle";
        Quickshell.execDetached([toggleScript, action]);
        refreshSoon.restart();
    }

    function applyStatus(payload: string): void {
        try {
            const data = JSON.parse(payload || "{}");
            state = data.state || "idle";
            message = data.message || "ready";
            transcript = data.text || "";
            error = data.error || "";
        } catch (e) {
            state = "error";
            message = "bad status";
            error = String(e);
        }
    }

    function randomizeAudioBars(): void {
        const levels = [];
        for (let i = 0; i < 6; i++)
            levels.push(minAudioBarHeight + Math.sqrt(Math.random()) * audioBarHeightRange);
        audioBarHeights = levels;
    }

    function resetAudioBars(): void {
        audioBarHeights = [minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight, minAudioBarHeight];
    }

    function refreshDmsFont(): void {
        if (fontProcess.running)
            return;
        fontProcess.command = ["bash", "-lc", `jq -r '.fontFamily // "Inter Variable"' '${home}/.config/DankMaterialShell/settings.json' 2>/dev/null || printf 'Inter Variable\\n'`];
        fontProcess.running = true;
    }

    Process {
        id: statusProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.applyStatus(text.trim())
        }
    }

    Process {
        id: fontProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const family = text.trim();
                root.dmsFontFamily = family.length > 0 ? family : "Inter Variable";
            }
        }
    }

    Timer {
        id: refreshTimer
        interval: 400
        running: true
        repeat: true
        onTriggered: root.refreshStatus()
    }

    Timer {
        id: refreshSoon
        interval: 80
        repeat: false
        onTriggered: root.refreshStatus()
    }

    Timer {
        id: audioTimer
        interval: 110
        running: root.state === "listening"
        repeat: true
        onTriggered: root.randomizeAudioBars()
        onRunningChanged: {
            if (running)
                root.randomizeAudioBars();
            else
                root.resetAudioBars();
        }
    }

    Component.onCompleted: {
        Quickshell.watchFiles = true;
        root.refreshDmsFont();
        root.refreshStatus();
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: pillWindow
            required property var modelData

            screen: modelData
            color: "transparent"
            visible: true
            implicitWidth: shell.width
            implicitHeight: shell.height

            WlrLayershell.namespace: "dms:dictation"
            WlrLayershell.layer: WlrLayershell.Overlay
            WlrLayershell.exclusiveZone: -1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors {
                left: true
                bottom: true
            }

            WlrLayershell.margins {
                left: Math.max(0, ((modelData?.width || 1920) - shell.width) / 2)
                bottom: 12
            }

            Item {
                id: shell

                readonly property bool recording: root.state === "listening"
                readonly property bool stopPreview: recording && mouse.containsMouse
                readonly property bool expanded: root.active || root.failed || mouse.containsMouse
                readonly property real revealProgress: Math.max(0, Math.min(1, (width - 128) / 36))

                width: recording ? 172 : (expanded ? 172 : 90)
                height: expanded ? 42 : 34
                clip: true

                Behavior on width {
                    NumberAnimation {
                        duration: 95
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on height {
                    NumberAnimation {
                        duration: 95
                        easing.type: Easing.OutCubic
                    }
                }

                Rectangle {
                    id: pill

                    anchors.centerIn: parent
                    width: shell.recording ? (shell.stopPreview ? 112 : 58) : (shell.expanded ? parent.width : 58)
                    height: shell.recording ? 32 : (shell.expanded ? 34 : 24)
                    radius: height / 2
                    color: {
                        if (shell.recording)
                            return root.recordingChip;
                        if (root.state === "stopping" || root.state === "transcribing" || root.state === "setup")
                            return root.busyChip;
                        if (root.failed)
                            return root.errorChip;
                        return mouse.containsMouse ? root.idleChipHover : root.idleChip;
                    }
                    border.width: 1
                    border.color: {
                        if (shell.recording)
                            return "#fe8019";
                        if (root.state === "stopping" || root.state === "transcribing" || root.state === "setup")
                            return "#fabd2f";
                        if (root.failed)
                            return "#fb4934";
                        return mouse.containsMouse ? "#928374" : "#665c54";
                    }
                    opacity: shell.expanded ? 0.98 : 0.94

                    Behavior on width {
                        NumberAnimation {
                            duration: 95
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 95
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    id: stateDot

                    anchors.left: pill.left
                    anchors.leftMargin: 13
                    anchors.verticalCenter: pill.verticalCenter
                    width: 10
                    height: 10
                    radius: 5
                    color: root.failed ? "#ffd0d0" : root.barInk
                    visible: (shell.expanded && !shell.recording) || shell.stopPreview
                    opacity: root.failed ? 0.9 : 0.78 * (shell.stopPreview ? 1 : shell.revealProgress)

                    SequentialAnimation on scale {
                        running: root.state === "listening"
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: 1.34
                            duration: 520
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 1.0
                            duration: 520
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Column {
                    anchors.left: stateDot.right
                    anchors.leftMargin: 8
                    anchors.right: pill.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: pill.verticalCenter
                    spacing: -1
                    visible: (shell.expanded && !shell.recording) || shell.stopPreview
                    opacity: shell.stopPreview ? 1 : shell.revealProgress
                    clip: true

                    Text {
                        width: parent.width
                        text: root.statusLabel
                        color: "#ffffff"
                        font.family: root.dmsFontFamily
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        width: parent.width
                        text: root.statusHint
                        color: "#f3f3f3"
                        opacity: 0.76
                        font.family: root.dmsFontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: root.statusHint.length > 0
                    }
                }

                Row {
                    id: audioDots

                    anchors.centerIn: pill
                    height: root.maxAudioBarHeight
                    spacing: 2
                    visible: (!shell.expanded || shell.recording) && !shell.stopPreview

                    Repeater {
                        model: 6

                        delegate: Rectangle {
                            required property int index

                            anchors.verticalCenter: parent.verticalCenter
                            width: 3
                            height: shell.recording ? (root.audioBarHeights[index] || root.minAudioBarHeight) : 3
                            radius: 1.5
                                color: root.barInk
                                opacity: 0.96

                            Behavior on height {
                                enabled: shell.recording
                                NumberAnimation {
                                    duration: 100
                                    easing.type: Easing.Linear
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouseEvent => {
                        mouseEvent.accepted = true;
                        root.activate();
                    }
                }
            }
        }
    }
}

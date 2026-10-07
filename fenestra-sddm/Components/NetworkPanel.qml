import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import "Strings.js" as Str

/**
 * NetworkPanel.qml - Network indicator (wired / Wi-Fi) for the login screen.
 *
 * SDDM has no access to NetworkManager like a normal Plasma session (the
 * greeter runs before any user session, in a very restricted environment).
 * This component works around it by reading the kernel files under
 * /sys/class/net/ directly, which anyone can read without special permission:
 *   - the list of network interfaces (through FolderListModel)
 *   - the state of each one ("operstate" file: "up" = connected)
 *   - the interface type, guessed from the standard Linux naming scheme
 *     (systemd predictable network names): "en*"/"eth*" = wired,
 *     "wl*" = Wi-Fi. This covers the vast majority of systems, but is not
 *     guaranteed on very unusual setups.
 *
 * Requires QML_XHR_ALLOW_FILE_READ=1 in the greeter environment
 * (see extras/zz-fenestra-sddm.conf).
 */
Item {
    id: networkPanel

    // Like sessionPanel in Main.qml: without this, the Item keeps a width/height
    // of 0, and the neighbours' anchors ("right: networkPanel.left") are computed
    // at the wrong place → overlap with the next button.
    implicitWidth: networkButton.width
    implicitHeight: networkButton.height

    // ── Detected network state ──────────────────────────────────────────────
    property string currentState: "none" // "wired" | "wifi" | "none"

    FolderListModel {
        id: netFolderModel
        folder: "file:///sys/class/net"
        showDirs: true
        showFiles: false
        showDotAndDotDot: false
        sortField: FolderListModel.Name
    }

    // Re-reads the state of every interface found and works out the overall state
    function refreshNetworkState() {
        var wiredUp = false
        var wifiUp = false
        var pending = netFolderModel.count

        if (pending === 0) {
            networkPanel.currentState = "none"
            return
        }

        for (var i = 0; i < netFolderModel.count; i++) {
            var ifaceName = netFolderModel.get(i, "fileName")
            if (ifaceName === "lo")
                continue

            var isWifi = ifaceName.indexOf("wl") === 0
            var isWired = ifaceName.indexOf("en") === 0 || ifaceName.indexOf("eth") === 0

            if (!isWifi && !isWired)
                continue

            var xhr = new XMLHttpRequest()
            xhr.open("GET", "file:///sys/class/net/" + ifaceName + "/operstate", false) // synchronous: tiny local file, no network latency
            try {
                xhr.send()
                var state = (xhr.responseText || "").trim()
                if (state === "up") {
                    if (isWired) wiredUp = true
                    if (isWifi) wifiUp = true
                }
            } catch (e) {
                console.warn("[NetworkPanel] erreur lecture", ifaceName, e)
            }
        }

        if (wiredUp)
            networkPanel.currentState = "wired"
        else if (wifiUp)
            networkPanel.currentState = "wifi"
        else
            networkPanel.currentState = "none"
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: networkPanel.refreshNetworkState()
    }

    Connections {
        target: netFolderModel
        function onCountChanged() { networkPanel.refreshNetworkState() }
    }

    // ── Button (same style as PowerPanel / sessionButton) ───────────────
    Button {
        id: networkButton
        width: 40
        height: networkButton.width
        hoverEnabled: true

        Image {
            id: networkIcon
            width: 26
            height: 26
            anchors.centerIn: networkButton
            fillMode: Image.PreserveAspectFit
            smooth: true
            source: networkPanel.currentState === "wifi" ? Qt.resolvedUrl("../Assets/network-wireless.svg")
                : networkPanel.currentState === "wired" ? Qt.resolvedUrl("../Assets/network-wired.svg")
                : Qt.resolvedUrl("../Assets/network-none.svg")
            // The Breeze "network-wired" SVG faces the wrong way for this layout
            // (plug at the top left instead of the top right)
            // → mirrored horizontally to fix it.
            mirror: networkPanel.currentState === "wired"
        }

        ToolTip {
            id: networkButtonTip

            delay: 1000
            timeout: 4800
            leftPadding: 9
            rightPadding: 9
            topPadding: 7
            bottomPadding: 7
            // The button sits at the bottom edge of the screen: showing the
            // tooltip BELOW it (like sessionButton/powerButton) pushes it off
            // screen and it gets cut. It is shown above instead.
            y: -height - 5
            z: 2
            visible: networkButton.hovered

            contentItem: Text {
                text: networkPanel.currentState === "wired" ? Str.t("networkWired") :
                      networkPanel.currentState === "wifi"  ? Str.t("networkWifi") :
                      Str.t("networkNone")
                font.family: "Inter"
                renderType: Text.NativeRendering
                color: "#4A4A4A"
            }

            background: Rectangle {
                color: "#EDEDED"
                radius: 6
                border.width: 1
                border.color: "#CFCFCF"
            }
        }

        background: Rectangle {
            id: networkButtonBackground
            color: "transparent"
            radius: 5
        }

        states: [
            State {
                name: "hovered"
                when: networkButton.hovered
                PropertyChanges {
                    target: networkButtonBackground
                    color: "#25FFFFFF"
                }
            },
            State {
                name: "pressed"
                when: networkButton.down
                PropertyChanges {
                    target: networkButtonBackground
                    color: "#50FFFFFF"
                }
            }
        ]
    }
}

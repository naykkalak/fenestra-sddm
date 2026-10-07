import QtQuick
import QtQuick.Controls

Item {
    implicitHeight: layoutButton.height
    implicitWidth: layoutButton.width

    // As on Windows: the keyboard layout indicator is only shown when several
    // layouts are installed. With a single one (e.g. French only), it stays
    // hidden AND disabled (so it no longer blocks hover/tooltips).
    visible: keyboard.layouts.length > 1
    enabled: keyboard.layouts.length > 1

    signal valueChanged(int id)

    // ── Normalizes a keyboard.layouts entry, which can be either an
    // object { longName, shortName, ... } ("classic" API) or a plain string,
    // depending on the installed SDDM version. Without this, "entry.longName"
    // silently fails (undefined) on versions that return plain strings.
    function getLongName(entry) {
        if (entry === undefined || entry === null)
            return "";
        if (typeof entry === "string")
            return entry;
        if (typeof entry === "object" && entry.longName !== undefined)
            return entry.longName;
        return String(entry);
    }

    // all of this is because keyboard.layouts[keyboard.currentLayout].shortName doesn't work btw. https://github.com/sddm/sddm/issues/2153
        function getLayoutCode(longName) {
            if (!longName) return "??";

            var cleanName = longName.toLowerCase().trim();

            var match = cleanName.match(/\(([^)]+)\)/);
            if (match) {
                return match[1].toUpperCase().substring(0, 2);
            }

            const map = {
                "american": "US",
                "arabic": "SA",
                "australian": "AU",
                "austrian": "AT",
                "belgian": "BE",
                "brazilian": "BR",
                "british": "GB",
                "bulgarian": "BG",
                "canadian": "CA",
                "chinese": "CN",
                "croatian": "HR",
                "czech": "CZ",
                "danish": "DK",
                "dutch": "NL",
                "english": "US",
                "estonian": "EE",
                "farsi": "IR",
                "filipino": "PH",
                "finnish": "FI",
                "french": "FR",
                "german": "DE",
                "greek": "GR",
                "hebrew": "IL",
                "hindi": "IN",
                "hungarian": "HU",
                "icelandic": "IS",
                "indonesian": "ID",
                "irish": "IE",
                "italian": "IT",
                "japanese": "JP",
                "korean": "KR",
                "latvian": "LV",
                "lithuanian": "LT",
                "malay": "MY",
                "mexican": "MX",
                "newzealand": "NZ",
                "norwegian": "NO",
                "polish": "PL",
                "portuguese": "PT",
                "romanian": "RO",
                "russian": "RU",
                "serbian": "RS",
                "slovak": "SK",
                "slovenian": "SI",
                "spanish": "ES",
                "swedish": "SE",
                "swiss": "CH",
                "thai": "TH",
                "turkish": "TR",
                "ukrainian": "UA",
                "vietnamese": "VN"
            };

            if (map[cleanName]) return map[cleanName];

            return longName.substring(0, 2).toUpperCase();
        }

        onValueChanged: (id) => {
            keyboard.currentLayout = id
        }

    DelegateModel {
        id: layoutWrapper

        model: keyboard.layouts
        delegate: ItemDelegate {
            id: layoutEntry
            width: parent.width
            height: 34
            highlighted: layoutList.currentIndex == index

            contentItem: Text {
                renderType: Text.NativeRendering
                font.family: "Inter"
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                color: "white"
                text: getLongName(modelData)
            }

            background: Rectangle {
                id: layoutEntryBackground
                color: "transparent"
            }

            states: [
                State {
                    name: "focused"
                    when: layoutEntry.focus
                    PropertyChanges {
                        target: layoutEntryBackground
                        color: config.color
                    }
                },

                State {
                    name: "hovered"
                    when: layoutEntry.hovered
                    PropertyChanges {
                    target: layoutEntryBackground
                    color: "#343434"
                    }
                }
            ]

            MouseArea {
                anchors.fill: parent

                onPressed: {
                    layoutEntryBackground.color = "#35FFFFFF"
                }

                onReleased: {
                    if (layoutEntry.focus) {
                        layoutEntryBackground.color = config.color
                    }
                    else {
                        layoutEntryBackground.color = "#1E1E1E"
                    }
                }

                onClicked: {
                    layoutList.currentIndex = index
                    layoutPopup.close()
                    valueChanged(layoutList.currentIndex)
                }
            }
        }
    }

    Button {
        id: layoutButton
        width: 40
        height: layoutButton.width
        hoverEnabled: true

        Text {
            color: "white"
            text: getLayoutCode(getLongName(keyboard.layouts[keyboard.currentLayout]))
            font.family: "Inter"
            font.capitalization: Font.AllUppercase
            renderType: Text.NativeRendering
            font.pointSize: 12

            anchors {
                horizontalCenter: layoutButton.horizontalCenter
                verticalCenter: layoutButton.verticalCenter
            }
        }

        ToolTip {
            id: layoutButtonTip

            delay: 1000
            timeout: 4800
            leftPadding: 9
            rightPadding: 9
            topPadding: 7
            bottomPadding: 7
            y: layoutButton.height + 5
            z: 2
            visible: layoutButton.hovered

            contentItem: Text {
                text: getLongName(keyboard.layouts[keyboard.currentLayout])
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
            id: layoutButtonBackground
            color: "transparent"
            radius: 5
        }

        states: [
            State {
                name: "pressed"
                when: layoutButton.down
                PropertyChanges {
                    target: layoutButtonBackground
                    color: "#50FFFFFF"
                }
            },
            State {
                name: "hovered"
                when: layoutButton.hovered
                PropertyChanges {
                    target: layoutButtonBackground
                    color: "#25FFFFFF"
                }
            },
            State {
                name: "selection"
                when: layoutPopup.visible
                PropertyChanges {
                    target: layoutButtonBackground
                    color: "transparent"
                }
            }
        ]

        onClicked: {
            layoutPopup.visible ? layoutPopup.close() : layoutPopup.open()
            layoutPopup.visible === layoutPopup.open ; layoutButton.state = "selection"
            layoutButtonTip.hide()
        }
    }

    Popup {
        id: layoutPopup
        width: 121
        x: Math.round((parent.width - width) / 2)
        y: Math.round(-layoutButton.height -(layoutPopup.height) + 35)
        topPadding: 5
        bottomPadding: 5
        leftPadding: 0
        rightPadding: 0

        background: Rectangle {
            color: "#1E1E1E"
        }

        contentItem: ListView {
            id: layoutList
            implicitHeight: contentHeight
            model: layoutWrapper
            currentIndex: keyboard.currentLayout
            clip: true
            interactive: false
        }

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.OutCirc
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.OutCirc
            }
        }
    }
}

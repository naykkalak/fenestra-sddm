import QtQuick
import QtQuick.Controls
import "Strings.js" as Str

Item {
    Button {
        id: powerButton
        width: 40
        height: powerButton.width
        hoverEnabled: true

        Image {
            anchors.centerIn: powerButton
            property color color: "white"
            source: Qt.resolvedUrl("../Assets/icons/power.svg")
            width: 20
            height: 20
            sourceSize.width: 40
            sourceSize.height: 40
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        ToolTip {
            id: powerButtonTip

            delay: 1000
            timeout: 4800
            leftPadding: 9
            rightPadding: 9
            topPadding: 7
            bottomPadding: 7
            y: powerButton.height + 5
            z: 2
            visible: powerButton.hovered

            contentItem: Text {
                text: Str.t("powerOptions")
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
            id: powerButtonBackground
            color: "transparent"
            radius: 5
        }

        states: [
            State {
                name: "pressed"
                when: powerButton.down
                PropertyChanges {
                    target: powerButtonBackground
                    color: "#50FFFFFF"
                }
            },

            State {
                name: "hovered"
                when: powerButton.hovered
                PropertyChanges {
                    target: powerButtonBackground
                    color: "#25FFFFFF"
                }
            },

            State {
                name: "selection"
                when: powerPopup.visible
                PropertyChanges {
                    target: powerButtonBackground
                    color: "transparent"
                }
            }
        ]

        onClicked: {
            powerPopup.visible ? powerPopup.close() : powerPopup.open()
            powerPopup.visible === powerPopup.open ; powerButton.state = "selection"
            powerButtonTip.hide()
        }
    }

    Popup {
        id: powerPopup
        width: 175
        height: poweroffButton.height + rebootButton.height + sleepButton.height + 40
        x: Math.round((powerButton.width - width) / 2) - 48
        y: -135
        z: 3
        topPadding: 10

        background: Rectangle {
            color: "#E6303030"
            border.color: "#66000000"
            border.width: 1
            radius: 5
        }

        Button {
            id: poweroffButton
            width: 155
            height: 30
            hoverEnabled: true

            background: Rectangle {
                id: poweroffButtonBackground
                color: "transparent"
                radius: 5
                width: parent.width
                height: parent.height

                anchors {
                    right: parent.right
                    rightMargin: -5
                }
            }

            ToolTip {
                id: poweroffTip

                delay: 1000
                timeout: 4800
                leftPadding: 9
                rightPadding: 9
                topPadding: 7
                bottomPadding: 7
                visible: poweroffButton.hovered

                contentItem: Text {
                    text: Str.t("shutdownDesc")
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

            Text {
                id: powerText
                text: Str.t("shutdown")
                color: "white"

                font.family: "Inter"
                font.pointSize: 10
                leftPadding: 10
                renderType: Text.NativeRendering

                anchors {
                    left: poweroffIcon.right
                    verticalCenter: poweroffButton.verticalCenter
                }
            }

            Image {
                id: poweroffIcon

                anchors {
                    right: poweroffButton.left
                    rightMargin: -30
                    verticalCenter: poweroffButton.verticalCenter
                }
                property color color: "white"
                source: Qt.resolvedUrl("../Assets/icons/power.svg")
                width: 17
                height: 17
                sourceSize.width: 34
                sourceSize.height: 34
                fillMode: Image.PreserveAspectFit
                smooth: true
            }


            states: [
                State {
                    name: "hovered"
                    when: poweroffButton.hovered
                    PropertyChanges {
                        target: poweroffButtonBackground
                        color: "#15FFFFFF"
                    }
                }
            ]

            onClicked: sddm.powerOff()
        }

        Button {
            id: rebootButton
            width: 155
            height: 30
            hoverEnabled: true

            anchors {
                topMargin: 10
                top: poweroffButton.bottom
                right: parent.right
                rightMargin: 2
            }

            background: Rectangle {
                id: rebootButtonBackground
                color: "transparent"
                radius: 5
                width: parent.width
                height: parent.height
            }

            ToolTip {
                id: rebootButtonTip

                delay: 1000
                timeout: 4800
                leftPadding: 9
                rightPadding: 9
                topPadding: 7
                bottomPadding: 7
                visible: rebootButton.hovered

                contentItem: Text {
                    text: Str.t("restartDesc")             // I had to make it like this, so it's normal, don't touch.
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

            Text {
                id: rebootText
                text: Str.t("restart")
                color: "white"

                font.family: "Inter"
                font.pointSize: 10
                leftPadding: 10
                renderType: Text.NativeRendering

                anchors {
                    left: rebootIcon.right
                    verticalCenter: parent.verticalCenter
                }
            }

            Image {
                id: rebootIcon

                anchors {
                    right: rebootButton.left
                    rightMargin: -25
                    verticalCenter: rebootButton.verticalCenter
                }
                property color color: "white"
                source: Qt.resolvedUrl("../Assets/icons/reboot.svg")
                width: 17
                height: 17
                sourceSize.width: 34
                sourceSize.height: 34
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            states: [
                State {
                name: "hovered"
                when: rebootButton.hovered
                    PropertyChanges {
                        target: rebootButtonBackground
                        color: "#15FFFFFF"
                    }
                }
            ]

            onClicked: sddm.reboot()
        }

        Button {
            id: sleepButton
            width: 155
            height: 30
            hoverEnabled: true

            anchors {
                topMargin: 10
                top: rebootButton.bottom
                right: parent.right
                rightMargin: 2
            }

            background: Rectangle {
                id: sleepButtonBackground
                color: "transparent"
                radius: 5
                width: parent.width
                height: parent.height

                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
            }

            ToolTip {
                id: sleepButtonTip

                delay: 1000
                timeout: 4800
                leftPadding: 9
                rightPadding: 9
                topPadding: 7
                bottomPadding: 7
                visible: sleepButton.hovered

                contentItem: Text {
                    text: Str.t("sleepDesc")      // Again, it had to be like this, don't touch.
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

            Text {
                id: sleepText
                text: Str.t("sleep")
                color: "white"

                font.family: "Inter"
                font.pointSize: 10
                leftPadding: 10
                renderType: Text.NativeRendering

                anchors {
                    left: sleepIcon.right
                    verticalCenter: parent.verticalCenter
                }
            }

            Image {
                id: sleepIcon

                anchors {
                    right: sleepButton.left
                    rightMargin: -25
                    verticalCenter: sleepButton.verticalCenter
                }
                property color color: "white"
                source: Qt.resolvedUrl("../Assets/icons/sleep.svg")
                width: 17
                height: 17
                sourceSize.width: 34
                sourceSize.height: 34
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            states: [
                State {
                name: "hovered"
                when: sleepButton.hovered
                    PropertyChanges {
                        target: sleepButtonBackground
                        color: "#15FFFFFF"
                    }
                }
            ]

            onClicked: sddm.suspend()
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

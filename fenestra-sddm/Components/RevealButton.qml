import QtQuick
import QtQuick.Controls

Button {
    id: revealButton
    hoverEnabled: true
    width: 26
    height: 22

    Image {
        id: revealText
        anchors.centerIn: parent
        property color color: "white"
        source: Qt.resolvedUrl("../Assets/icons/reveal.svg")
        width: 16
        height: 16
        sourceSize.width: 32
        sourceSize.height: 32
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    background: Rectangle {
        id: revealButtonBackground
        color: "transparent"
        radius: 4

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    states: [
        State {
            name: "on"
            when: revealButton.down
            PropertyChanges {
                target: passwordField
                echoMode: TextInput.Normal
            }
            PropertyChanges {
                target: passwordFieldPin
                echoMode: TextInput.Normal
            }
            PropertyChanges {
                target: revealText
                color: "white"
            }
        },
        State {
            name: "off"
            PropertyChanges {
                target: passwordField
                echoMode: TextInput.Password
            }
            PropertyChanges {
                target: passwordFieldPin
                echoMode: TextInput.Password
            }
        },
        State {
            name: "hovered"
            when: revealButton.hovered
            PropertyChanges {
                target: revealButtonBackground
                color: "#15FFFFFF"
            }
        }
    ]
}

import QtQuick
import QtQuick.Controls

Button {
    id: loginButton
    hoverEnabled: true
    width: 30
    height: 24

    Image {
        id: loginText
        anchors.centerIn: parent
        property color color: "white"
        source: Qt.colorEqual(loginText.color, "black") ? Qt.resolvedUrl("../Assets/icons/login-black.svg") : Qt.resolvedUrl("../Assets/icons/login.svg")
        width: 17
        height: 17
        sourceSize.width: 34
        sourceSize.height: 34
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    background: Rectangle {
        id: loginbuttonBackground
        width: parent.width
        height: parent.height
        color: "transparent"
        radius: 4
    }

    states: [
       State {
            name: "pressed"
            when: loginButton.down
            PropertyChanges {
                target: loginbuttonBackground
                color: config.color
                width: 32
                height: 26
                x: -1
                y: -1
            }
            PropertyChanges {
                target: loginText
                color: "black"
            }
        },

        State {
            name: "hovered"
            when: loginButton.hovered
            PropertyChanges {
                target: loginbuttonBackground
                color: config.color
            }
            PropertyChanges {
                target: loginText
                color: "black"
            }
        }
    ]
}

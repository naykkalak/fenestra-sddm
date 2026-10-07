import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings
import "Components"
import "Components/Strings.js" as Str

Item {
    FontLoader { source: "fonts/Inter-Regular.ttf" }
    FontLoader { source: "fonts/Inter-SemiBold.ttf" }
    FontLoader { source: "fonts/Inter-Bold.ttf" }
    id: root
    width: Screen.width
    height: Screen.height

    property string randomWallpaper: "Backgrounds/default.jpg"

    Rectangle {
        id: background
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Image {
            id: bgimg
            anchors.fill: parent
            width: parent.width
            height: parent.height
            source: root.randomWallpaper
            visible: false
        }

        GaussianBlur {
            anchors.fill: bgimg
            source: bgimg
            radius: 60
            samples: 50
        }

        Rectangle {
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: "#1A000000"
        }
    }

    Rectangle {
        id: startupBg
        width: Screen.width
        height: Screen.height
        color: "transparent"
        z: 4

        Image {
            id: startupBgImage
            anchors.fill: parent
            width: Screen.width
            height: Screen.height
            smooth: true
            source: root.randomWallpaper
        }

        Rectangle {
            anchors.fill: parent
            width: parent.width
            height: parent.height
            color: "#1A000000"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            drag.target: timeDate
            drag.axis: Drag.YAxis
            drag.minimumY: -Screen.height / 2
            drag.maximumY: 0
            focus: true

            onClicked: {
                listView.focus = true
                mouseArea.focus = false
                mouseArea.enabled = false
                customReturnTimer.restart()
                seqStart.start()
                parStart.start()
            }

            Keys.onPressed: {
                listView.focus = true
                mouseArea.focus = false
                mouseArea.enabled = false
                customReturnTimer.restart()
                seqStart.start()
                parStart.start()
            }

            property bool dragActive: drag.active

            onDragActiveChanged: {
                if(drag.active) {}
                else {
                    listView.focus = true
                    mouseArea.focus = false
                    mouseArea.enabled = false
                    customReturnTimer.restart()
                    seqStart.start()
                    parslideStart.start()
                }
            }
        }

        ParallelAnimation {
            id: parStart
            running: false

            NumberAnimation {
                target: timeDate
                properties: "y"
                from: 0
                to: -100
                duration: 150
            }

            NumberAnimation {
                target: timeDate
                properties: "visible"
                from: 1
                to: 0
                duration: 175
            }

            NumberAnimation {
                target: startupBg
                properties: "opacity"
                from: 1
                to: 0
                duration: 180
            }
        }

        ParallelAnimation {
            id: parslideStart
            running: false

            NumberAnimation {
                target: startupBg
                properties: "opacity"
                from: 1
                to: 0
                duration: 100
            }
        }

        SequentialAnimation {
            id: seqStart
            running: false

            ParallelAnimation {

                ScaleAnimator {
                    target: background
                    from: 1
                    to: 1.01
                    duration: 250
                }

                NumberAnimation {
                    target: centerPanel
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: 225
                }

                NumberAnimation {
                    target: rightPanel
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }

                NumberAnimation {
                    target: leftPanel
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: 100
                }
            }
        }

        Rectangle {
            id: timeDate
            width: parent.width
            height: parent.height
            color: "transparent"

            Column {
                id: timeContainer

                anchors {
                    top: parent.top
                    topMargin: 145
                    horizontalCenter: parent.horizontalCenter
                }

                property date dateTime: new Date()

                Timer {
                    interval: 100; running: true; repeat: true;
                    onTriggered: timeContainer.dateTime = new Date()
                }

                Text {
                    id: time

                    color: "white"
                    font.pointSize: 94
                    font.family: "Inter"
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                    text: Qt.formatTime(timeContainer.dateTime, "hh:mm")

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    id: spacingRect
                    color: "transparent"
                    width: 5
                    height: 5

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Text {
                    id: date

                    color: "white"
                    font.pointSize: 19
                    font.family: "Inter"
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                    horizontalAlignment: Text.AlignLeft
                    text: timeContainer.dateTime.toLocaleDateString(Qt.locale(), Locale.LongFormat)

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    Item {
        id: centerPanel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.width / 1.75
        z: 2
        opacity: 0

        Item {
            Item {
                id: keyboardContainer
                parent: root
                z: 100

                width: Screen.width / 2
                height: inputPanel.height

                x: (Screen.width - width) / 2
                y: (Screen.height / 2) + 150

                Rectangle {
                    id: dragBar
                    height: 30
                    width: parent.width
                    color: "white"
                    x: 8

                    anchors.bottom: inputPanel.top
                    anchors.bottomMargin: 0

                    state: "off"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.SizeAllCursor

                        drag.target: keyboardContainer
                        drag.axis: Drag.XAndYAxis
                        drag.minimumX: -Screen.width
                        drag.maximumX: Screen.width
                        drag.minimumY: -Screen.height
                        drag.maximumY: Screen.height
                    }

                    Image {
                        source: "Assets/osk-icon.png"
                        width: 17
                        height: 17
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.top: parent.top
                        anchors.topMargin: 8
                    }

                    Text {
                        text: Str.t("onScreenKeyboard")
                        anchors.left: parent.left
                        anchors.leftMargin: 35
                        anchors.verticalCenter: parent.verticalCenter
                        color: "black"
                        font.pointSize: 9
                        font.family: "Inter"
                        renderType: Text.NativeRendering
                    }

                    Rectangle {
                        id: closeBtn
                        width: 46
                        height: parent.height - 1
                        anchors.right: parent.right
                        anchors.top: parent.top

                        color: closeT.containsMouse ? "#C42B1C" : "transparent"

                        Text {
                            text: "×"
                            color: closeT.containsMouse ? "white" : "#040404"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: -6
                            anchors.bottomMargin: 1
                            font.pixelSize: 27
                            font.family: "Inter Light"
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: closeT
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: true

                            onClicked: {
                                keyboardText.text = "off"
                            }
                        }
                    }

                    Rectangle {
                        id: maxBtn
                        width: 46
                        height: parent.height - 1
                        anchors.right: closeBtn.left
                        anchors.top: parent.top

                        Text {
                            text: "▢"
                            color: "#80686868"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            font.pixelSize: 13
                            font.family: "Inter Light"
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: maxT
                            anchors.fill: parent
                            hoverEnabled: true
                            preventStealing: true
                        }
                    }

                    Rectangle {
                        id: minBtn
                        width: 46
                        height: parent.height - 1
                        anchors.right: maxBtn.left
                        anchors.top: parent.top

                        color: minT.containsMouse ? "#E9E9E9" : "transparent"

                        Text {
                            text: "–"
                            color: "#040404"
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.bottomMargin: 1
                            font.pixelSize: 20
                            font.family: "Inter Light"
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: minT
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            preventStealing: true

                            onClicked: {
                                keyboardText.text = "off"
                            }
                        }
                    }

                    states: [
                        State {
                            name: "on"
                            when: sessionText.text  === "on"
                            PropertyChanges { target: dragBar; visible: true; enabled: true }
                        },
                        State {
                            name: "off"
                            when: sessionText.text  === "off"
                            PropertyChanges { target: dragBar; visible: false; enabled: false }
                        }
                    ]
                }

                InputPanel {
                    id: inputPanel
                    Timer {
                        id: langueClavier
                        property bool fait: false
                        interval: 150
                        repeat: true
                        running: inputPanel.visible && !fait
                        onTriggered: {
                            var dispo = VirtualKeyboardSettings.availableLocales
                            if (dispo.length === 0)
                                return
                            var systeme = Qt.locale().name
                            if (dispo.indexOf(systeme) < 0) {
                                var langue = systeme.split("_")[0]
                                var trouve = ""
                                for (var i = 0; i < dispo.length; i++)
                                    if (dispo[i].indexOf(langue + "_") === 0) { trouve = dispo[i]; break }
                                systeme = trouve !== "" ? trouve : "en_US"
                            }
                            if (dispo.indexOf(systeme) < 0)
                                systeme = dispo[0]
                            VirtualKeyboardSettings.locale = systeme
                            fait = true
                        }
                    }
                    width: parent.width
                    x: 8

                    states: [
                        State {
                            name: "on"
                            when: sessionText.text === "on"
                            PropertyChanges { target: inputPanel; visible: true; enabled: true }
                        },
                        State {
                            name: "off"
                            when: sessionText.text === "off"
                            PropertyChanges { target: inputPanel; visible: false; enabled: false }
                        }
                    ]
                }
            }

            Component {
                id: userDelegate

                FocusScope {
                    anchors.centerIn: parent
                    name: (model.realName === "") ? model.name : model.realName
                    icon: "/var/lib/AccountsService/icons/" + model.name

                    property alias icon: icon.source

                    property alias name: name.text

                    property alias password: passwordField.text

                    property alias passwordpin: passwordFieldPin.text

                    property int session: sessionPanel.session

                    visible: ListView.isCurrentItem
                    enabled: ListView.isCurrentItem
                    height: 0
                    width: 296

                    Connections {
                      target: sddm

                        function onLoginFailed() {
                            truePass.visible = false

                            passwordField.visible = false
                            passwordField.enabled = false
                            passwordField.focus = false

                            passwordFieldPin.visible = false
                            passwordFieldPin.enabled = false
                            passwordFieldPin.focus = false

                            rightPanel.visible = false
                            leftPanel.visible = false

                            falsePass.visible = true
                            falsePass.focus = true

                            bootani.stop()
                        }

                        function onLoginSucceeded() {}
                    }

                    Image {
                        id: icon
                        width: 192
                        height: 192
                        smooth: true
                        visible: false

                        onStatusChanged: {
                            if (icon.status == Image.Error)
                                icon.source = "Assets/user-192.png"
                            else
                                "/var/lib/AccountsService/icons/" + name
                        }

                        x: -(icon.width / 2)
                        y: -(icon.width * 2) + (icon.width * 0.8)
                    }

                    OpacityMask {
                        anchors.fill: icon
                        source: icon
                        maskSource: mask
                    }

                    Item {
                        id: mask
                        width: icon.width
                        height: icon.height
                        layer.enabled: true
                        visible: false

                        Rectangle {
                            width: icon.width
                            height: icon.height
                            radius: width / 2
                            color: "black"
                        }
                    }

                    Text {
                        id: name
                        color: "white"
                        font.pointSize: 23
                        font.family: "Inter"
                        font.weight: Font.DemiBold
                        renderType: Text.NativeRendering

                        anchors {
                            topMargin: 15
                            horizontalCenter: icon.horizontalCenter
                            top: icon.bottom
                        }
                    }

                    PasswordField {
                        id: passwordField
                        // Back to the clock screen: clear what was typed
                        Connections {
                            target: customReturnTimer
                            function onTriggered() { passwordField.text = "" }
                        }
                        onTextChanged: customReturnTimer.restart()
                        visible: config.PinMode === "off" ? true : false
                        enabled: config.PinMode === "off" ? true : false
                        focus: config.PinMode === "off" ? true : false
                        x: -135

                        anchors {
                            topMargin: 25
                            top: name.bottom
                        }

                        Keys.onReturnPressed: {
                            keyboardText.text = "off"
                            truePass.visible = true
                            passwordField.visible = false
                            passwordField.enabled = false
                            passwordFieldPin.visible = false
                            passwordFieldPin.enabled = false
                            rightPanel.visible = false
                            leftPanel.visible = false
                            sddm.login(model.name, password, session)

                            bootani.start()

                            capsOn.z = -1
                        }

                        Keys.onEnterPressed: {
                            keyboardText.text = "off"
                            truePass.visible = true
                            passwordField.visible = false
                            passwordField.enabled = false
                            passwordFieldPin.visible = false
                            passwordFieldPin.enabled = false
                            rightPanel.visible = false
                            leftPanel.visible = false
                            sddm.login(model.name, password, session)

                            bootani.start()

                            capsOn.z = -1
                        }
                    }

                    PasswordFieldPin {
                        id: passwordFieldPin
                        // Back to the clock screen: clear what was typed
                        Connections {
                            target: customReturnTimer
                            function onTriggered() { passwordFieldPin.text = "" }
                        }
                        visible: config.PinMode === "off" ? false : true
                        enabled: config.PinMode === "off" ? false : true
                        focus: config.PinMode === "off" ? false : true

                        x: -135

                        property int pinSize: config.PinSize

                        function calculateTopValue(size) {
                            return Math.pow(10, size) - 1;
                        }

                        validator: RegularExpressionValidator {
                            regularExpression: new RegExp("\\d{1," + passwordFieldPin.pinSize + "}")
                        }

                        onTextChanged: {
                            customReturnTimer.restart()
                            if (passwordFieldPin.text !== "") {
                                passwordFieldPin.width = 225
                                revealButton.visible = true
                            }

                            else {
                                passwordFieldPin.width = 296
                                revealButton.visible = false
                            }

                            if (config.PinSize === passwordFieldPin.length) {
                                keyboardText.text = "off"
                                falsePass.visible = true
                                passwordField.visible = false
                                passwordField.enabled = false
                                passwordFieldPin.visible = false
                                passwordFieldPin.enabled = false
                                rightPanel.visible = false
                                leftPanel.visible = false
                                sddm.login(model.name, password, session)

                                bootani.start()

                                capsOn.z = -1
                            }
                        }

                        RevealButton {
                            id: revealButton
                            visible: false
                            y: 7

                            anchors {
                                right: passFieldBackgroundPin.right
                                rightMargin: 7
                            }
                        }

                        background: Rectangle {
                            id: passFieldBackgroundPin
                            color: "#BF1C1C1C"
                            border.color: "#15FFFFFF"
                            border.width: 2
                            x: -5
                            width: 296
                            height: parent.height
                            radius: 6
                        }

                        Rectangle {
                            id: passFieldBackground2
                            visible: false
                            border.color: config.color
                            border.width: 2
                            width: 292
                            height: parent.height
                            radius: 6
                        }

                        Rectangle {
                            id: passField2
                            visible: false
                            x: -4
                            y: 33
                            color: config.color
                            width: 294
                            radius: 6
                            height: 2
                        }

                        OpacityMask {
                            anchors.fill: passField2
                            source: passField2
                            maskSource: passFieldBackground2
                        }

                        anchors {
                            topMargin: 25
                            top: name.bottom
                        }
                    }

                    FalsePass {
                        id: falsePass
                        visible: false

                        anchors {
                            topMargin: 25
                            top: name.bottom
                        }
                    }

                    Rectangle {
                        id: truePass
                        color: "transparent"
                        visible: false

                        anchors {
                            topMargin: 35
                            top: name.bottom
                        }

                        Text {
                            id: welcome
                            color: "white"
                            font.family: "Inter"
                            text: Str.t("welcome")
                            renderType: Text.NativeRendering
                            font.weight: Font.DemiBold
                            font.pointSize: 17
                            anchors.centerIn: parent

                            topPadding: 125
                        }

                        Rectangle {
                            id: trueButton
                            color: "transparent"

                            BootSpinner {
                                id: bootani
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: -7
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 12
                            }
                        }
                    }

                    CapsOn {
                        id: capsOn
                        visible: false
                        z: 2

                        state: keyboard.capsLock ? "on" : "off"

                        states: [
                            State {
                                name: "on"
                                PropertyChanges {
                                    target: capsOn
                                    visible: true
                                }
                            },

                            State {
                                name: "off"
                                PropertyChanges {
                                    target: capsOn
                                    visible: false
                                    z: -1
                                }
                            }
                        ]

                        anchors {
                            top: passwordField.bottom
                            topMargin: 25
                        }
                    }
                }

            }

            Button {
                id: prevUser
                anchors.left: parent.left
                enabled: false
                visible: false
            }

            ListView {
                id: listView
                focus: true
                model: userModel
                delegate: userDelegate
                currentIndex: userModel.lastIndex
                interactive: false

                anchors {
                    left: prevUser.right
                    right: nextUser.left
                }
            }

            Button {
                id: nextUser
                anchors.right: parent.right
                enabled: false
                visible: false
            }
        }
    }

    Item {
        id: rightPanel
        z: 2
        opacity: 0

        anchors {
            bottom: parent.bottom
            right: parent.right
            margins: 65
        }

        PowerPanel {
            id: powerPanel
        }

        Item {
            id: sessionPanel

            anchors {
                right: powerPanel.left
                rightMargin: 10
            }

            Text {
                id: sessionText
                text: keyboardText.text
                visible: false
            }

            property int session: sessionList.currentIndex

            implicitHeight: sessionButton.height
            implicitWidth: sessionButton.width

            DelegateModel {
                id: sessionWrapper
                model: sessionModel
                delegate: ItemDelegate {
                    id: sessionEntry
                    width: parent.width
                    height: 25
                    highlighted: sessionList.currentIndex == index
                    contentItem: Text {
                        renderType: Text.NativeRendering
                        font.weight: Font.Normal
                        font.family: "Inter"
                        font.pointSize: 10
                        verticalAlignment: Text.AlignVCenter
                        color: "white"
                        text: name

                        Text {
                            id: offon
                            text: Str.t("off")
                            color: "white"
                            font.family: "Inter"
                            font.pointSize: 10
                            font.weight: Font.DemiBold
                            renderType: Text.NativeRendering

                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: sessionLever.left
                                rightMargin: 10
                            }
                        }

                        Button {
                            id: sessionLever
                            width: 44
                            height: 20
                            z: 3

                            anchors {
                                right: parent.right
                                rightMargin: 5
                            }

                            background: Rectangle {
                                id: sessionLeverBackground
                                color: "transparent"
                                border.color: "white"
                                border.width: 2
                                radius: 180
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    sessionList.currentIndex = index
                                }
                            }

                            Button {
                                id: leftblackLever
                                width: 10
                                height: 10

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 5
                                }

                                background: Rectangle {
                                    color: "white"
                                    radius: 180
                                }

                                MouseArea {
                                    anchors.fill: parent

                                    onClicked: {
                                        sessionList.currentIndex = index
                                    }
                                }
                            }

                            Button {
                                id: rightblackLever
                                width: 10
                                height: 10
                                visible: false

                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: 5
                                }

                                background: Rectangle {
                                    color: "white"
                                    radius: 180
                                }
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    sessionList.currentIndex = index
                                }
                            }
                        }
                    }

                    background: Rectangle {
                        id: sessionEntryBackground
                        color: "transparent"
                    }

                    states: [
                        State {
                            name: "focused"
                            when: sessionEntry.focus
                            PropertyChanges {
                                target: sessionLeverBackground
                                color: config.color
                                border.color: config.color
                            }
                            PropertyChanges {
                                target: rightblackLever
                                visible: true
                            }
                            PropertyChanges {
                                target: leftblackLever
                                visible: false
                            }
                            PropertyChanges {
                                target: offon
                                text: Str.t("on")
                            }
                        },

                        State {
                            name: "pressed"
                            when: sessionLever.down
                            PropertyChanges {
                                target: sessionLeverBackground
                                color: "#B5B5B5"
                            }
                        }
                    ]
                }
            }

            Button {
                id: sessionButton
                width: 40
                height: sessionButton.width
                hoverEnabled: true

                Image {
                    anchors.centerIn: sessionButton
                    property color color: "white"
                    source: Qt.resolvedUrl("Assets/icons/accessibility.svg")
                    width: 20
                    height: 20
                    sourceSize.width: 40
                    sourceSize.height: 40
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                ToolTip {
                    id: sessionButtonTip

                    delay: 1000
                    timeout: 4800
                    leftPadding: 9
                    rightPadding: 9
                    topPadding: 7
                    bottomPadding: 7
                    y: sessionButton.height + 5
                    z: 2
                    visible: sessionButton.hovered

                    contentItem: Text {
                        text: Str.t("accessibility")
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
                    id: sessionButtonBackground
                    color: "transparent"
                    radius: 5
                }

                states: [
                    State {
                        name: "pressed"
                        when: sessionButton.down
                        PropertyChanges {
                            target: sessionButtonBackground
                            color: "#50FFFFFF"
                        }
                    },

                    State {
                        name: "hovered"
                        when: sessionButton.hovered
                        PropertyChanges {
                            target: sessionButtonBackground
                            color: "#25FFFFFF"
                        }
                    },

                    State {
                        name: "selection"
                        when: sessionPopup.visible
                        PropertyChanges {
                            target: sessionButtonBackground
                            color: "transparent"
                        }
                    }
                ]

                onClicked: {
                    sessionPopup.visible ? sessionPopup.close() : sessionPopup.open()
                    sessionPopup.visible === sessionPopup.open ; sessionButton.state = "selection"
                    sessionButtonTip.hide()
                }
            }

            Popup {
                id: sessionPopup
                width: 250
                height: 100
                x: Math.round((parent.width - width) + 70)
                y: Math.round(-sessionButton.height -(sessionPopup.height) + 35)
                z: 3

                topPadding: 10

                background: Rectangle {
                    color: "#E6303030"
                    border.width: 1
                    border.color: "#66000000"
                    radius: 4

                    Button {
                        id: screenKeyboard
                        width: parent.width - 2
                        height: 41
                        x: 1
                        y: 54
                        z: 3
                        visible: true
                        enabled: true
                        Text {
                            color: "white"
                            text: Str.t("onScreenKeyboard")
                            renderType: Text.NativeRendering
                            font.family: "Inter"
                            font.pointSize: 10
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 11
                                right: koffon.left
                                rightMargin: 10
                            }
                        }

                        Text {
                            id: keyboardText
                            color: "transparent"
                            text: "off"
                            visible: false
                        }

                        states: [
                            State {
                                name: "on"
                                PropertyChanges { target: keyboardText; text: "on" }
                            },

                            State {
                                name: "off"
                                PropertyChanges { target: keyboardText; text: "off" }
                            }
                        ]

                        background: Rectangle {
                            id: screenKeyboardBackground
                            color: "transparent"
                        }

                        Text {
                            id: koffon
                            text: keyboardText.text === "on" ? Str.t("on") : Str.t("off")
                            color: "white"
                            font.family: "Inter"
                            font.pointSize: 10
                            font.weight: Font.DemiBold
                            renderType: Text.NativeRendering

                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: screenKeyboardLever.left
                                rightMargin: 10
                            }
                        }

                        Button {
                            id: screenKeyboardLever
                            width: 44
                            height: 20
                            z: 3

                            anchors {
                                right: parent.right
                                rightMargin: 16
                                verticalCenter: parent.verticalCenter
                            }

                            background: Rectangle {
                                id: screenKeyboardLeverBackground
                                color: keyboardText.text === "on" ? config.color : "transparent"
                                border.color: keyboardText.text === "on" ? config.color : "white"
                                border.width: 2
                                radius: 180
                            }

                            MouseArea {
                                anchors.fill: screenKeyboardLever
                                onClicked: { keyboardText.text = (keyboardText.text === "off" ? "on" : "off") }
                            }

                            Button {
                                id: kleftblackLever
                                width: 10
                                height: 10
                                visible: keyboardText.text === "off"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    leftMargin: 5
                                }

                                background: Rectangle {
                                    color: "white"
                                    radius: 180
                                }

                                MouseArea {
                                    anchors.fill: kleftblackLever
                                    onClicked: keyboardText.text = "on"
                                }
                            }

                            Button {
                                id: krightblackLever
                                width: 10
                                height: 10
                                visible: keyboardText.text === "on"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    right: parent.right
                                    rightMargin: 5
                                }
                                background: Rectangle {
                                    color: "white"
                                    radius: 180
                                }
                                MouseArea {
                                    anchors.fill: krightblackLever
                                    onClicked: keyboardText.text = "off"
                                }
                            }
                        }
                    }
                }

                contentItem: ListView {
                    id: sessionList
                    implicitHeight: contentHeight + 11
                    model: sessionWrapper
                    currentIndex: sessionModel.lastIndex
                    clip: true
                    spacing: 23
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

        NetworkPanel {
            id: networkPanel

            anchors {
                right: sessionPanel.left
                rightMargin: 10
            }
        }

        LayoutPanel {
            id: layoutPanel

            anchors {
                right: networkPanel.left
                rightMargin: 10
            }
        }
    }

    Rectangle {
        id: leftPanel
        color: "transparent"
        anchors.fill: parent
        z: 2
        opacity: 0

        visible: listView2.count > 1 ? true : false
        enabled: listView2.count > 1 ? true : false

        Component {
            id: userDelegate2

            UserList {
                id: userList
                name: (model.realName === "") ? model.name : model.realName
                icon: "/var/lib/AccountsService/icons/" + model.name

                anchors {
                    horizontalCenter: parent.horizontalCenter
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        listView2.currentIndex = index
                        listView2.focus = true
                        listView.currentIndex = index
                        listView.focus = true
                    }
                }
            }
        }

        Rectangle {
            width: 150
            height: listView2.count > 17 ? Screen.height - 68 : 58 * listView2.count
            color: "transparent"
            clip: true

            anchors {
                bottom: parent.bottom
                bottomMargin: 35
                left: parent.left
                leftMargin: 35
            }

            Item {
                id: usersContainer2
                width: 255
                height: parent.height

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }

                Button {
                    id: prevUser2
                    visible: true
                    enabled: false
                    width: 0

                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }
                }

                ListView {
                    id: listView2
                    height: parent.height
                    focus: true
                    model: userModel
                    currentIndex: userModel.lastIndex
                    delegate: userDelegate2
                    verticalLayoutDirection: ListView.TopToBottom
                    orientation: ListView.Vertical
                    interactive: listView2.count > 17 ? true : false
                    spacing: 4

                    anchors {
                        left: prevUser2.right
                        right: nextUser2.left
                    }
                }

                Button {
                    id: nextUser2
                    visible: true
                    width: 0
                    enabled: false

                    anchors {
                        bottom: parent.bottom
                        right: parent.right
                    }
                }
            }
        }
    }
    // Any real mouse movement restarts the 30 s countdown
    HoverHandler {
        property point dernierePosition: Qt.point(-100, -100)
        onPointChanged: {
            var p = point.position
            if (Math.abs(p.x - dernierePosition.x) > 2 || Math.abs(p.y - dernierePosition.y) > 2) {
                dernierePosition = Qt.point(p.x, p.y)
                customReturnTimer.restart()
            }
        }
    }

    // Idle timer: running as soon as the screen is shown
    Timer {
        id: customReturnTimer
        running: true
        interval: 30000 // 30 seconds, clock screen included
        repeat: true

        onTriggered: {
            // Only act when the password panel is visible, so typing is never blocked
                if (centerPanel.opacity === 1) {
                    // 1. Reset the base visual states
                    startupBg.opacity = 1
                    timeDate.visible = true
                    timeDate.y = 0
                    centerPanel.opacity = 0

                    // 2. Force-stop the previous animations so they can run again on click
                    seqStart.stop()
                    parStart.stop()

                    // 3. Re-enable the full-screen click area
                    mouseArea.enabled = true
                    mouseArea.focus = true
                    loginScreenRoot.uiVisible = true
                }


        }
        }
}

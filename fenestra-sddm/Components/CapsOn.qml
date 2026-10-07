import QtQuick
import QtQuick.Controls
import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import "Strings.js" as Str

Rectangle {
    id: capsButton
    color: "transparent"
    x: -50

    KeyboardIndicator.KeyState {
        id: capsLockState
        key: Qt.Key_CapsLock
    }

    // The whole component follows the Caps Lock state directly
    opacity: capsLockState.locked ? 1 : 0
    visible: capsLockState.locked

    Text {
        color: "white"
        font.family: "Inter"
        text: Str.t("capsLock")
        renderType: Text.NativeRendering
        font.weight: Font.Bold
        font.pointSize: 12
    }
}

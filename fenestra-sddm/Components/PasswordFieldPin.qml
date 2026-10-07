import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "Strings.js" as Str

TextField {
    id: passwordFieldPin
    focus: true
    visible: true
    selectByMouse: true
    placeholderText: Str.t("pin")
    placeholderTextColor: "white"

    // property alias text: passwordFieldPin.text

    echoMode: TextInput.Password ? TextInput.Password : TextInput.Normal
    selectionColor: config.color

    font.family: "Inter"
    font.pointSize: 10.5
    renderType: Text.NativeRendering

    color: "white"

    horizontalAlignment: TextInput.AlignLeft
    width: 296
    height: 36
}

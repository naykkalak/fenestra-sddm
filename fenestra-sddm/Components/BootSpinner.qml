import QtQuick
import QtQuick.Shapes

// Windows 11 style busy ring: a rotating white arc of varying length.
Item {
    id: spinner
    property real size: 36
    property real lineWidth: 4
    property color color: "white"
    property color trackColor: "#26FFFFFF"
    property bool running: false
    property real turn: 0
    property real sweep: 40

    width: size
    height: size
    visible: running

    function start() { running = true }
    function stop() { running = false }

    NumberAnimation on turn {
        from: 0
        to: 360
        duration: 1300
        loops: Animation.Infinite
        running: spinner.running
    }

    SequentialAnimation on sweep {
        loops: Animation.Infinite
        running: spinner.running
        NumberAnimation { from: 40; to: 240; duration: 650; easing.type: Easing.InOutSine }
        NumberAnimation { from: 240; to: 40; duration: 650; easing.type: Easing.InOutSine }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        ShapePath {
            strokeColor: spinner.trackColor
            strokeWidth: spinner.lineWidth
            fillColor: "transparent"
            PathAngleArc {
                centerX: spinner.size / 2
                centerY: spinner.size / 2
                radiusX: (spinner.size - spinner.lineWidth) / 2
                radiusY: (spinner.size - spinner.lineWidth) / 2
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            strokeColor: spinner.color
            strokeWidth: spinner.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: spinner.size / 2
                centerY: spinner.size / 2
                radiusX: (spinner.size - spinner.lineWidth) / 2
                radiusY: (spinner.size - spinner.lineWidth) / 2
                startAngle: spinner.turn - 90
                sweepAngle: spinner.sweep
            }
        }
    }
}

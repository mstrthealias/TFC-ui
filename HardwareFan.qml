import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    width: 260
    height: 80

    Text {
        text: title
        width: 240
        height: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
    }

    GridLayout {
        x: 0
        y: 20
        width: 240
        height: 60
        columns: 2

        TextField {
            id: fieldPinPWM
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("PWM Pin")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Teensy pin number (must support PWM). Set to 0 if not connected, or to not control fan's PWM signal.")
            }
            text: fan.pinPWM

            Binding {
                target: fan; property: "pinPWM"; value: fieldPinPWM.text
            }
        }

        TextField {
            id: fieldPinRPM
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("RPM Pin")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Teensy pin number (must support interrupts). Set to 0 if not connected, or to not monitor fan's RPM.")
            }
            text: fan.pinRPM

            Binding {
                target: fan; property: "pinRPM"; value: fieldPinRPM.text
            }
        }

    }
}

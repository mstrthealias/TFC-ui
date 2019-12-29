import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    width: 260
    height: 140

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
        height: 100
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

        TextField {
            id: fieldMode
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Control Mode")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Fan Control Mode: 1 for PID, 0 for %-table.")
            }
            text: fan.mode

            Binding {
                target: fan; property: "mode"; value: fieldMode.text
            }
        }

        TextField {
            id: fieldRatio
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Ratio")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Fan Ratio: set a value less than 1 to reduce this fan's speed, set a value greater than 1 to increase this fan's speed. Note: fan ratio is applied after PID and %-table calculations.")
            }
            text: fan.ratio

            Binding {
                target: fan; property: "ratio"; value: fieldRatio.text
            }
        }
    }

}

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    property int fieldMinWidth: 115

    Layout.fillWidth: true
    height: 129

    Text {
        id: titleText
        text: title
        height: 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 18
        font.bold: true
    }

    GridLayout {
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        columns: 2

        TextFieldExt {
            id: fieldPinPWM

            minWidth: fieldMinWidth
            label: qsTr("PWM Pin")
            tooltip: qsTr("Teensy pin number (must support PWM). Set to 0 if not connected.")
            text: fan.pinPWM

            Binding {
                target: fan; property: "pinPWM"; value: fieldPinPWM.text
            }
        }

        TextFieldExt {
            id: fieldPinRPM

            minWidth: fieldMinWidth
            label: qsTr("RPM Pin")
            tooltip: qsTr("Teensy pin number (must support interrupts). Set to 0 if not connected.")
            text: fan.pinRPM

            Binding {
                target: fan; property: "pinRPM"; value: fieldPinRPM.text
            }
        }

    }
}

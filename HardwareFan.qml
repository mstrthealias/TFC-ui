import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    property int fieldMinWidth: 115
    property int lblTopMargin: 8

    Layout.fillWidth: true
    height: 89

    Label {
        id: titleText
        text: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: lblTopMargin
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
    }

    GridLayout {
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 2

        columns: 2

        TextFieldExt {
            id: fieldPinPWM

            minWidth: fieldMinWidth
            label: qsTr("PWM Pin")
            tooltip: qsTr("Teensy pin number (must support PWM). Set to 0 if not connected.")
            text: fan.pinPWM

            target: fan
            property: "pinPWM"
        }

        TextFieldExt {
            id: fieldPinRPM

            minWidth: fieldMinWidth
            label: qsTr("RPM Pin")
            tooltip: qsTr("Teensy pin number (must support interrupts). Set to 0 if not connected.")
            text: fan.pinRPM

            target: fan
            property: "pinRPM"
        }

    }
}

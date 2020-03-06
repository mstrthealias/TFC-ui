import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var sensor
    property real deltaT: 0
    property bool showDeltaT: false
    property bool hasSetpointData: false

    property int fieldMinWidth: 115

    Layout.fillWidth: true
    height: 59

    RowLayout {
        anchors.fill: parent

        Text {
            text: title
            lineHeightMode: Text.FixedHeight
            lineHeight: 63
            Layout.minimumWidth: 105
            Layout.maximumWidth: 105
            verticalAlignment: Text.AlignTop
            font.pixelSize: 16
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 165
            autoSelectText: false
            minWidth: fieldMinWidth
            label: qsTr("°C")
            text: sensor.pvTemp
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 165
            autoSelectText: false
            minWidth: fieldMinWidth
            label: qsTr("Setpoint (°C)")
            text: sensor.pvSetpoint || ""
            labelColor: hasSetpointData ? undefined : "#9a9a9a"
            visible: sensor.hasPid
        }
        Item {
            Layout.preferredHeight: 59
            Layout.minimumHeight: 59
            Layout.minimumWidth: fieldMinWidth
            Layout.maximumWidth: 165
            Layout.fillWidth: true
            visible: !sensor.hasPid
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 165
            autoSelectText: false
            minWidth: fieldMinWidth
            label: qsTr("DeltaT")
            text: deltaT
            visible: showDeltaT
        }
        Item {
            Layout.preferredHeight: 59
            Layout.minimumHeight: 59
            Layout.minimumWidth: fieldMinWidth
            Layout.maximumWidth: 165
            Layout.fillWidth: true
            visible: !showDeltaT
        }

        // force left alignment as width grows
        Item {
            Layout.preferredHeight: 59
            Layout.minimumHeight: 59
            Layout.minimumWidth: 0
            Layout.fillWidth: true
        }
    }
}

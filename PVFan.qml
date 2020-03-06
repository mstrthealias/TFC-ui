import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    property int fieldMinWidth: 85

    Layout.fillWidth: true
    height: 59

    function renderMode(mode) {
        switch (mode) {
        case 0:
            return "%-table";
        case 1:
            return "PID";
        case 2:
            return "Fixed";
        case 3:
            return "Off";
        }
        return "ERR";
    }

    function renderSource(source) {
        switch (source) {
        case 0:
            return "Water Supply Temp";
        case 1:
            return "Water Return Temp";
        case 2:
            return "Case Temp";
        case 3:
            return "Aux1 Temp";
        case 4:
            return "Aux2 Temp";
        case 5:
            return "DeltaT";
        }
        return "ERR";
    }

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
            label: qsTr("RPM")
            text: fan.pv.rpm
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 165
            autoSelectText: false
            minWidth: fieldMinWidth
            label: qsTr("PWM")
            text: fan.pv.pct + '%'
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 165
            autoSelectText: false
            minWidth: fieldMinWidth
            label: qsTr("Mode")
            text: qsTr(renderMode(fan.pv.mode))
        }

        TextFieldExt {
            readOnly: true
            Layout.maximumWidth: 235
            autoSelectText: false
            minWidth: 155
            label: qsTr("Source")
            text: qsTr(renderSource(fan.pv.source))
            visible: fan.pv.mode < 2
        }
        Item {
            Layout.preferredHeight: 59
            Layout.minimumHeight: 59
            Layout.minimumWidth: 155
            Layout.maximumWidth: 235
            Layout.fillWidth: true
            height: 20
            visible: fan.pv.mode >= 2
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

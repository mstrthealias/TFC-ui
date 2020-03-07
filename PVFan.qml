import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import BackEnd 1.0

Item {
    property string title
    property var fan

    property int fieldMinWidth: 85

    Layout.fillWidth: true
    height: 59

    function renderMode(mode) {
        switch (mode) {
        case BackEnd.ControlMode.Tbl:
            return "%-table";
        case BackEnd.ControlMode.PID:
            return "PID";
        case BackEnd.ControlMode.Fixed:
            return "Fixed";
        case BackEnd.ControlMode.Off:
            return "Off";
        }
        return "ERR";
    }

    function renderSource(source) {
        switch (source) {
        case BackEnd.WaterSupplyTemp:
            return "Water Supply Temp";
        case BackEnd.WaterReturnTemp:
            return "Water Return Temp";
        case BackEnd.CaseTemp:
            return "Case Temp";
        case BackEnd.Aux1Temp:
            return "Aux1 Temp";
        case BackEnd.Aux2Temp:
            return "Aux2 Temp";
        case BackEnd.VirtualDeltaT:
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
            visible: fan.pv.mode < BackEnd.ControlMode.Fixed
        }
        Item {
            Layout.preferredHeight: 59
            Layout.minimumHeight: 59
            Layout.minimumWidth: 155
            Layout.maximumWidth: 235
            Layout.fillWidth: true
            height: 20
            visible: fan.pv.mode >= BackEnd.ControlMode.Fixed
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

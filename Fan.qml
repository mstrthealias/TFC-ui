import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import BackEnd 1.0

Item {
    property string title
    property int fanNo
    property var fan

    Layout.fillWidth: true
    height: 149

    Connections {
        target: backEnd
        onConfigDownloaded: function() {
            populateSourceOptions();
        }
    }

    function populateSourceOptions() {
        let idx = fieldSource.currentIndex,
            mdl = fieldSource.model,
            record = mdl.get(idx),
            firstVal = null,
            selVal = record ? record.val : BackEnd.WaterSupplyTemp,  // uses initial ListElements
            cur = 0;
        idx = 0;
        function appendElement(obj) {
            if (firstVal === null)
                firstVal = obj.val;
            mdl.append({ val: obj.val, text: obj.text });
            if (obj.val === selVal)
                idx = cur;
            cur++;
        }

        mdl.clear();
        if (backEnd.sensor1.pin)
            appendElement({ val: BackEnd.WaterSupplyTemp, text: qsTr("Water Supply Temp") });
        if (backEnd.sensor2.pin)
            appendElement({ val: BackEnd.WaterReturnTemp, text: qsTr("Water Return Temp") });
        if (backEnd.sensor3.pin)
            appendElement({ val: BackEnd.CaseTemp, text: qsTr("Case Temp") });
        if (backEnd.sensor4.pin)
            appendElement({ val: BackEnd.Aux1Temp, text: qsTr("Aux1 Temp") });
        if (backEnd.sensor5.pin)
            appendElement({ val: BackEnd.Aux2Temp, text: qsTr("Aux2 Temp") });
        if (backEnd.sensor1.pin && backEnd.sensor2.pin)
            appendElement({ val: BackEnd.VirtualDeltaT, text: qsTr("DeltaT (Return - Supply Temp)") });
        fieldSource.currentIndex = idx;
        fieldSource.val = (idx !== 0 ? selVal : firstVal) || BackEnd.WaterSupplyTemp;
        fan.source = fieldSource.val  // make sure config is up to date
    }

    function showFanPID(source, fanNo) {
        let valid = true,
            pid, pidTitle;
        switch (source) {
        case BackEnd.WaterSupplyTemp:
            pidTitle = "Supply Temp PID"
            pid = backEnd.pid1
            break;
        case BackEnd.CaseTemp:
            pidTitle = "Case Temp PID"
            pid = backEnd.pid2
            break;
        case BackEnd.Aux1Temp:
            pidTitle = "Aux1 Temp PID"
            pid = backEnd.pid3
            break;
        case BackEnd.Aux2Temp:
            pidTitle = "Aux2 Temp PID"
            pid = backEnd.pid4
            break;
        default:
            pidTitle = "INVALID TEMP SOURCE"
            pid = undefined
            valid = false
            break;
        }
        stackView.push("fan_pid.qml", {
                           fanTitle: qsTr("Fan " + fanNo),
                           pidTitle: qsTr(pidTitle),
                           pid: pid
                       })
    }

    function showFanTbl(fan, fanNo) {
        let tblTitle;
        switch (fan.source) {
        case BackEnd.WaterSupplyTemp:
            tblTitle = "Supply Temp - % Table"
            break;
        case BackEnd.WaterReturnTemp:
            tblTitle = "Return Temp - % Table"
            break;
        case BackEnd.CaseTemp:
            tblTitle = "Case Temp - % Table"
            break;
        case BackEnd.Aux1Temp:
            tblTitle = "Aux1 Temp - % Table"
            break;
        case BackEnd.Aux2Temp:
            tblTitle = "Aux2 Temp - % Table"
            break;
        case BackEnd.VirtualDeltaT:
            tblTitle = "DeltaT - % Table"
            break;
        }
        stackView.push("fan_tbl.qml", {
                           fanTitle: qsTr("Fan " + fanNo),
                           tblTitle: qsTr(tblTitle),
                           fan: fan
                       })
        stackView.currentItem.load()
    }

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

        columns: 1

        RowLayout {
            ComboBox {
                id: fieldMode
                Layout.minimumWidth: 115
                Layout.maximumWidth: 255
                Layout.fillWidth: true
                currentIndex: fan.mode

                model: ListModel {
                    ListElement { text: qsTr("Temp-% Table") }
                    ListElement { text: "PID" }
                    ListElement { text: qsTr("Fixed") }
                    ListElement { text: qsTr("Off") }
                }

                onActivated: {
                    fan.mode = fieldMode.currentIndex
                }
            }

            ComboBox {
                property int val: BackEnd.WaterSupplyTemp

                id: fieldSource
                visible: fan.mode === BackEnd.ControlMode.Tbl || fan.mode === BackEnd.ControlMode.PID
                Layout.minimumWidth: 175
                Layout.fillWidth: true
                textRole: "text"

                currentIndex: fan.source

                model: ListModel {
                    ListElement { val: BackEnd.WaterSupplyTemp; text: qsTr("Water Supply Temp") }
                    ListElement { val: BackEnd.WaterReturnTemp; text: qsTr("Water Return Temp") }
                    ListElement { val: BackEnd.CaseTemp; text: qsTr("Case Temp") }
                    ListElement { val: BackEnd.Aux1Temp; text: qsTr("Aux1 Temp") }
                    ListElement { val: BackEnd.Aux2Temp; text: qsTr("Aux2 Temp") }
                    ListElement { val: BackEnd.VirtualDeltaT; text: qsTr("DeltaT (Return - Supply Temp)") }
                }

                onActivated: {
                    let rec = fieldSource.model.get(index);
                    if (rec)
                        fieldSource.val = rec.val;
                    fan.source = fieldSource.val;
                }

                Component.onCompleted: {
                    populateSourceOptions();
                }
            }
        }

        RowLayout {
            ToolButton {
                id: editTblButton
                visible: fan.mode === BackEnd.ControlMode.Tbl
                text: qsTr("Edit Table")
                font.pixelSize: 16
                Layout.margins: 4
                onClicked: {
                    showFanTbl(fan, fanNo)
                }
            }

            ToolButton {
                id: editPIDButton
                visible: fan.mode === BackEnd.ControlMode.PID
                text: qsTr("Edit PID Settings")
                font.pixelSize: 16
                Layout.margins: 4
                onClicked: {
                    showFanPID(fan.source, fanNo)
                }
            }

            Item {
                Layout.fillWidth: true
                visible: fan.mode !== BackEnd.ControlMode.Fixed
            }

            TextFieldExt {
                id: fieldRatio
                visible: fan.mode === BackEnd.ControlMode.PID || fan.mode === BackEnd.ControlMode.Fixed
                horizontalAlignment: Qt.AlignHRight
                Layout.minimumWidth: 95
                Layout.maximumWidth: 95

                label: qsTr("Ratio")
                tooltip: qsTr("Fan Ratio: set a value less than 1 to reduce this fan's speed, set a value greater than 1 to increase this fan's speed. Note: fan ratio is applied after PID and %-table calculations.")
                text: fan.ratio

                target: fan
                property: "ratio"
            }
        }
    }
}

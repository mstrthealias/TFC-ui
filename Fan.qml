import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property int fanNo
    property var fan

    Layout.fillWidth: true
    height: 149

    function showFanPID(source, fanNo) {
        let valid = true,
            pid, pidTitle;
        switch (source) {
        case 0:
            pidTitle = "Supply Temp PID"
            pid = backEnd.pid1
            break;
        case 2:
            pidTitle = "Case Temp PID"
            pid = backEnd.pid2
            break;
        case 3:
            pidTitle = "Aux1 Temp PID"
            pid = backEnd.pid3
            break;
        case 4:
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
        case 0:
            tblTitle = "Supply Temp - % Table"
            break;
        case 1:
            tblTitle = "Return Temp - % Table"
            break;
        case 2:
            tblTitle = "Case Temp - % Table"
            break;
        case 3:
            tblTitle = "Aux1 Temp - % Table"
            break;
        case 4:
            tblTitle = "Aux2 Temp - % Table"
            break;
        case 5:
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

                Binding {
                    target: fan; property: "mode"; value: fieldMode.currentIndex
                }
            }

            ComboBox {
                property int val: 0

                id: fieldSource
                visible: fan.mode === 0 || fan.mode === 1
                Layout.minimumWidth: 175
                Layout.fillWidth: true
                textRole: "text"

                currentIndex: fan.source

                model: ListModel {
                    ListElement { val: 0; text: qsTr("Water Supply Temp") }
                    ListElement { val: 1; text: qsTr("Water Return Temp") }
                    ListElement { val: 2; text: qsTr("Case Temp") }
                    ListElement { val: 3; text: qsTr("Aux1 Temp") }
                    ListElement { val: 4; text: qsTr("Aux2 Temp") }
                    ListElement { val: 5; text: qsTr("DeltaT (Return - Supply Temp)") }
                }

                onActivated: {
                    let rec = fieldSource.model.get(index);
                    if (rec)
                        fieldSource.val = rec.val;
                }

                Component.onCompleted: {
                    let idx = fieldSource.currentIndex,
                        mdl = fieldSource.model,
                        record = mdl.get(idx),
                        selVal = record ? record.val : 0,  // uses initial ListElements
                        cur = 0;

                    function appendElement(obj) {
                        mdl.append({ val: obj.val, text: obj.text });
                        if (obj.val === selVal)
                            idx = cur;
                        cur++;
                    }

                    mdl.clear();
                    if (backEnd.sensor1.pin)
                        appendElement({ val: 0, text: qsTr("Water Supply Temp") });
                    if (backEnd.sensor2.pin)
                        appendElement({ val: 1, text: qsTr("Water Return Temp") });
                    if (backEnd.sensor3.pin)
                        appendElement({ val: 2, text: qsTr("Case Temp") });
                    if (backEnd.sensor4.pin)
                        appendElement({ val: 3, text: qsTr("Aux1 Temp") });
                    if (backEnd.sensor5.pin)
                        appendElement({ val: 4, text: qsTr("Aux2 Temp") });
                    if (backEnd.sensor1.pin && backEnd.sensor2.pin)
                        appendElement({ val: 5, text: qsTr("DeltaT (Return - Supply Temp)") });
                    fieldSource.currentIndex = idx;
                    fieldSource.val = selVal;
                }

                Binding {
                    target: fan; property: "source"; value: fieldSource.val
                }
            }
        }

        RowLayout {
            ToolButton {
                id: editTblButton
                visible: fan.mode === 0
                text: qsTr("Edit Table")
                font.pixelSize: 16
                Layout.margins: 4
                onClicked: {
                    showFanTbl(fan, fanNo)
                }
            }

            ToolButton {
                id: editPIDButton
                visible: fan.mode === 1
                text: qsTr("Edit PID")
                font.pixelSize: 16
                Layout.margins: 4
                onClicked: {
                    showFanPID(fan.source, fanNo)
                }
            }

            Item {
                Layout.fillWidth: true
                visible: fan.mode !== 2
            }

            TextFieldExt {
                id: fieldRatio
                visible: fan.mode === 1 || fan.mode === 2
                horizontalAlignment: Qt.AlignHRight
                Layout.minimumWidth: 95
                Layout.maximumWidth: 95

                label: qsTr("Ratio")
                tooltip: qsTr("Fan Ratio: set a value less than 1 to reduce this fan's speed, set a value greater than 1 to increase this fan's speed. Note: fan ratio is applied after PID and %-table calculations.")
                text: fan.ratio

                Binding {
                    target: fan; property: "ratio"; value: fieldRatio.text
                }
            }
        }
    }
}

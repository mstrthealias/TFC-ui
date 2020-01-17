import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property int fanNo
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
        width: 445
        height: 100
        columns: 1

        RowLayout {
            ComboBox {
                id: fieldMode
                Layout.preferredWidth: 165
                Layout.minimumWidth: 115
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
                id: fieldSource
                visible: fan.mode === 0 || fan.mode === 1
                Layout.preferredWidth: 275
                Layout.minimumWidth: 175
                currentIndex: fan.source

                model: ListModel {
                    ListElement { text: qsTr("Water Supply Temp") }
                    ListElement { text: qsTr("Water Return Temp") }
                    ListElement { text: qsTr("Case Temp") }
                    ListElement { text: qsTr("Aux1 Temp") }
                    ListElement { text: qsTr("Aux2 Temp") }
                    ListElement { text: qsTr("DeltaT (Return - Supply Temp)"); }
                }

                Binding {
                    target: fan; property: "source"; value: fieldSource.currentIndex
                }
            }
        }

        RowLayout {
            ToolButton {
                id: editTblButton
                visible: fan.mode === 0
                text: qsTr("Edit Table")
                font.pixelSize: Qt.application.font.pixelSize
                onClicked: {
                    fanPageHolder.showTbl(fan, fanNo)
                }
            }

            ToolButton {
                id: editPIDButton
                visible: fan.mode === 1
                text: qsTr("Edit PID")
                font.pixelSize: Qt.application.font.pixelSize
                onClicked: {
                    fanPageHolder.showPID(fan.source)
                }
            }

            TextField {
                id: fieldRatio
                visible: fan.mode === 1 || fan.mode === 2
                horizontalAlignment: Qt.AlignHRight
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
}

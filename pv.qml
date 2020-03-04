import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("Present Values")

    ScrollView {
        anchors.fill: parent

        Page {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            implicitHeight: tempsGrid.height + fansGrid.height + 60

            GridLayout {
                id: tempsGrid

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                columns: 3

                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Supply Temp"
                    readOnly: true
                    text: backEnd.supplyTemp
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Return Temp"
                    readOnly: true
                    text: backEnd.returnTemp
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "DeltaT"
                    readOnly: true
                    text: backEnd.deltaT
                }

                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Set Point (PID)"
                    readOnly: true
                    text: backEnd.setpoint
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Case Temp"
                    readOnly: true
                    text: backEnd.caseTemp
                }
                Item {
                    width: 90
                }

                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Aux1 Temp"
                    readOnly: true
                    text: backEnd.aux1Temp
                }

                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "Aux2 Temp"
                    readOnly: true
                    text: backEnd.aux2Temp
                }

//                TextFieldExt {
//                    autoSelectText: false
//                    label: "Fan Percent (PID)"
//                    readOnly: true
//                    text: backEnd.fanPercentPID
//                }
//                TextFieldExt {
//                    autoSelectText: false
//                    label: "Fan Percent (%-table)"
//                    readOnly: true
//                    text: backEnd.fanPercentTbl
//                }
            }

            GridLayout {
                id: fansGrid
                anchors.top: tempsGrid.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 36

                columns: 3
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM1"
                    readOnly: true
                    visible: !!backEnd.fan1.pinRPM
                    text: backEnd.fan1.rpm
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM2"
                    readOnly: true
                    visible: !!backEnd.fan2.pinRPM
                    text: backEnd.fan2.rpm
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM3"
                    readOnly: true
                    visible: !!backEnd.fan3.pinRPM
                    text: backEnd.fan3.rpm
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM4"
                    readOnly: true
                    visible: !!backEnd.fan4.pinRPM
                    text: backEnd.fan4.rpm
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM5"
                    readOnly: true
                    visible: !!backEnd.fan5.pinRPM
                    text: backEnd.fan5.rpm
                }
                TextFieldExt {
                    autoSelectText: false
                    Layout.maximumWidth: 165
                    label: "RPM6"
                    readOnly: true
                    visible: !!backEnd.fan6.pinRPM
                    text: backEnd.fan6.rpm
                }
            }
        }
    }

}

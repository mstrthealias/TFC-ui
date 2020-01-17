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
            anchors.fill: parent
            anchors.margins: 12

            GridLayout {
                id: tempsGrid

                anchors.top: parent.top
                anchors.left: parent.left
//                anchors.right: parent.right

                columns: 3

                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Supply Temp"
                    }
                    readOnly: true
                    text: backEnd.supplyTemp
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Return Temp"
                    }
                    readOnly: true
                    text: backEnd.returnTemp
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "DeltaT"
                    }
                    readOnly: true
                    text: backEnd.deltaT
                }

                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Set Point (PID)"
                    }
                    readOnly: true
                    text: backEnd.setpoint
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Case Temp"
                    }
                    readOnly: true
                    text: backEnd.caseTemp
                }
                Item {
                    width: 90
                }

                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Aux1 Temp"
                    }
                    readOnly: true
                    text: backEnd.aux1Temp
                }

                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "Aux2 Temp"
                    }
                    readOnly: true
                    text: backEnd.aux2Temp
                }

//                TextField {
//                    Layout.preferredWidth: 135
//                    Layout.minimumWidth: 90
//                    Label {
//                        text: "Fan Percent (PID)"
//                    }
//                    readOnly: true
//                    text: backEnd.fanPercentPID
//                }
//                TextField {
//                    Layout.preferredWidth: 135
//                    Layout.minimumWidth: 90
//                    Label {
//                        text: "Fan Percent (%-table)"
//                    }
//                    readOnly: true
//                    text: backEnd.fanPercentTbl
//                }
            }

            GridLayout {
                anchors.top: tempsGrid.bottom
                anchors.left: parent.left
//                anchors.right: parent.right
                anchors.topMargin: 24

                columns: 3
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM1"
                    }
                    readOnly: true
                    text: backEnd.fan1.rpm
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM2"
                    }
                    readOnly: true
                    text: backEnd.fan2.rpm
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM3"
                    }
                    readOnly: true
                    text: backEnd.fan3.rpm
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM4"
                    }
                    readOnly: true
                    text: backEnd.fan4.rpm
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM5"
                    }
                    readOnly: true
                    text: backEnd.fan5.rpm
                }
                TextField {
                    Layout.preferredWidth: 135
                    Layout.minimumWidth: 90
                    Label {
                        text: "RPM6"
                    }
                    readOnly: true
                    text: backEnd.fan6.rpm
                }
            }
        }
    }

}

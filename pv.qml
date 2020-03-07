import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: "Teensy Fan Controller"

    ScrollView {
        anchors.fill: parent

        Page {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            implicitHeight: tempsGrid.height + fansGrid.height + 60

            ColumnLayout {
                id: tempsGrid
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    text: qsTr("Sensors")
                    lineHeight: 1.2
                    Layout.minimumWidth: 105
                    Layout.maximumWidth: 105
                    verticalAlignment: Text.AlignTop
                    font.pixelSize: 16
                    font.bold: true
                }

                PVSensor {
                    title: qsTr("Water Supply")
                    sensor: backEnd.sensor1
                    visible: !!backEnd.sensor1.pin
                    deltaT: backEnd.deltaT
                    showDeltaT: !!backEnd.sensor2.pin
                    hasSetpointData: true
                }
                PVSensor {
                    title: qsTr("Water Return")
                    sensor: backEnd.sensor2
                    visible: !!backEnd.sensor2.pin
                }
                PVSensor {
                    title: qsTr("Case")
                    sensor: backEnd.sensor3
                    visible: !!backEnd.sensor3.pin
                }
                PVSensor {
                    title: qsTr("Aux1")
                    sensor: backEnd.sensor4
                    visible: !!backEnd.sensor4.pin
                    hasSetpointData: true
                }
                PVSensor {
                    title: qsTr("Aux2")
                    sensor: backEnd.sensor5
                    visible: !!backEnd.sensor5.pin
                }
            }

            ColumnLayout {
                id: fansGrid
                anchors.top: tempsGrid.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: 12

                Text {
                    text: qsTr("Fans")
                    lineHeight: 1.2
                    Layout.minimumWidth: 105
                    Layout.maximumWidth: 105
                    verticalAlignment: Text.AlignTop
                    font.pixelSize: 16
                    font.bold: true
                }

                PVFan {
                    title: qsTr("Fan 1")
                    visible: !!backEnd.fan1.pinRPM
                    fan: backEnd.fan1
                }
                PVFan {
                    title: qsTr("Fan 2")
                    visible: !!backEnd.fan2.pinRPM
                    fan: backEnd.fan2
                }
                PVFan {
                    title: qsTr("Fan 3")
                    visible: !!backEnd.fan3.pinRPM
                    fan: backEnd.fan3
                }
                PVFan {
                    title: qsTr("Fan 4")
                    visible: !!backEnd.fan4.pinRPM
                    fan: backEnd.fan4
                }
                PVFan {
                    title: qsTr("Fan 5")
                    visible: !!backEnd.fan5.pinRPM
                    fan: backEnd.fan5
                }
                PVFan {
                    title: qsTr("Fan 6")
                    visible: !!backEnd.fan6.pinRPM
                    fan: backEnd.fan6
                }
            }
        }
    }

}

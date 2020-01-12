import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("Hardware Setup")

    ScrollView {
        anchors.fill: parent

        GridLayout {
            id: fansGrid

            anchors.fill: parent
            anchors.margins: 12

            columns: 2

            HardwareSensor {
                title: qsTr("Water Supply Temp Sensor")
                sensor: backEnd.sensor1
            }
            HardwareSensor {
                title: qsTr("Water Return Temp Sensor")
                sensor: backEnd.sensor2
            }
            HardwareSensor {
                title: qsTr("Case Temp Sensor")
                sensor: backEnd.sensor3
            }
            HardwareSensor {
                title: qsTr("Aux1 Temp Sensor")
                sensor: backEnd.sensor4
            }
            HardwareSensor {
                title: qsTr("Aux2 Temp Sensor")
                sensor: backEnd.sensor5
            }
            Item {
                width: 50
            }

            HardwareFan {
                title: qsTr("Fan 1")
                fan: backEnd.fan1
            }
            HardwareFan {
                title: qsTr("Fan 2")
                fan: backEnd.fan2
            }
            HardwareFan {
                title: qsTr("Fan 3")
                fan: backEnd.fan3
            }
            HardwareFan {
                title: qsTr("Fan 4")
                fan: backEnd.fan4
            }
            HardwareFan {
                title: qsTr("Fan 5")
                fan: backEnd.fan5
            }
            HardwareFan {
                title: qsTr("Fan 6")
                fan: backEnd.fan6
            }
        }
    }
}

import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("PID Setup")

    ScrollView {
        anchors.fill: parent

        Page {
            anchors.fill: parent
            anchors.margins: 12

            GridLayout {
                id: fansGrid

                anchors.fill: parent

                columns: 2

                ControlPID {
                    title: "Supply Temp PID"
                    pid: backEnd.pid1
                }
                ControlPID {
                    title: "Case Temp PID"
                    pid: backEnd.pid2
                }
                ControlPID {
                    title: "Aux1 Temp PID"
                    pid: backEnd.pid3
                }
//                ControlPID {
//                    title: "Aux2 Temp PID"
//                    pid: backEnd.pid4
//                }
            }
        }
    }
}

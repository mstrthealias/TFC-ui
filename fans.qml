import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("Fan Setup")

    ScrollView {
        anchors.fill: parent

        GridLayout {
            id: fansGrid
            anchors.margins: 12
            anchors.fill: parent

            columns: 1

            Fan {
                title: qsTr("Fan 1")
                fan: backEnd.fan1
                fanNo: 1
                visible: !!backEnd.fan1.pinPWM
            }
            Fan {
                title: qsTr("Fan 2")
                fan: backEnd.fan2
                fanNo: 2
                visible: !!backEnd.fan2.pinPWM
            }
            Fan {
                title: qsTr("Fan 3")
                fan: backEnd.fan3
                fanNo: 3
                visible: !!backEnd.fan3.pinPWM
            }
            Fan {
                title: qsTr("Fan 4")
                fan: backEnd.fan4
                fanNo: 4
                visible: !!backEnd.fan4.pinPWM
            }
            Fan {
                title: qsTr("Fan 5")
                fan: backEnd.fan5
                fanNo: 5
                visible: !!backEnd.fan5.pinPWM
            }
            Fan {
                title: qsTr("Fan 6")
                fan: backEnd.fan6
                fanNo: 6
                visible: !!backEnd.fan6.pinPWM
            }
        }
    }
}

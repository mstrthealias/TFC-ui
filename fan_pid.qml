import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    property var pid
    property string fanTitle
    property string pidTitle

    id: pidPage

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("PID Setup")

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12

            ControlPID {
                title: pidTitle
                pid: pidPage.pid
            }
        }
    }
}

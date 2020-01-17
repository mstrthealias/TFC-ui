import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    property var pid
    property string pidTitle

    id: pidPage
    visible: true
    anchors.fill: parent

    Text {
        text: qsTr("PID Setup")
        width: 240
        height: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
    }

    ControlPID {
        y: 20
        title: pidPage.pidTitle
        pid: pidPage.pid
    }
}

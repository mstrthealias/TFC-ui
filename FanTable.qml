import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    property var fan
    property string tblTitle

    id: tblPage
    visible: false
    anchors.fill: parent

    function load() {
        tblView.load()
    }

    Text {
        text: qsTr("Table Setup")
        width: 240
        height: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
    }

    ControlTable {
        id: tblView
        y: 20
        title: tblPage.tblTitle
        fan: tblPage.fan
    }
}


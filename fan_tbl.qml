import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    property var fan
    property string fanTitle
    property string tblTitle

    id: tblPage

    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: fanTitle + " > " + qsTr("Percent Table Setup")

    function load() {
        tblView.load()
    }

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12

            ControlTable {
                id: tblView
                title: tblTitle + ' (' + fanTitle + ')'
                fan: tblPage.fan
            }
        }
    }
}


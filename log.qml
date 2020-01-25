import QtQuick 2.13
import QtQuick.Controls 2.13
import LogListModel 0.1

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("Controller Log")

    ScrollView {
        anchors.fill: parent

        ListView {
            id: serialLog
            anchors.fill: parent
            anchors.margins: 12

            model: LogListModel {
                id: serialLogModel
            }
            delegate: Text {
                text: model.display
            }
            Connections {
                target: backEnd
                onLogAppend: function(str) {
                    serialLogModel.add(str);
                    serialLog.positionViewAtIndex(serialLogModel.rowCount() - 1, ListView.End);
                }
                onHidConnectFailure: function(isDataConnection) {
                    if (isDataConnection) {
                        serialLogModel.add('Data connection failed');
                    }
                    else {
                        serialLogModel.add('Log connection failed');
                    }
                    serialLog.positionViewAtIndex(serialLogModel.rowCount() - 1, ListView.End);
                }
            }
        }
    }

}

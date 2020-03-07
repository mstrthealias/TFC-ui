import QtQuick 2.13
import QtQuick.Window 2.3
import QtQuick.Controls 2.13
import BackEnd 1.0
import LogListModel 0.1

ApplicationWindow {
    id: logWindow

    width: 555
    height: 800

    title: qsTr("Log")

    header: ToolBar {
        id: logToolbar
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "\u25C0"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                logWindow.close()
            }
        }

        Label {
            id: logHdrLabel
            text: qsTr("Log")
            anchors.centerIn: parent
        }

        ToolButton {
            id: statusButton
            icon.source: "images/worldwide.svg"
            icon.height: 20
            icon.width: 20
            icon.color: uiState === BackEnd.Offline ? 'red' : (uiState === BackEnd.Online ? '#ededed' : (uiState === BackEnd.Connecting ? 'gray' : 'yellow'))
            display: AbstractButton.IconOnly
            anchors.left: logHdrLabel.right

            ToolTip {
                visible: parent.hovered
                text: qsTr(uiState === BackEnd.Offline ? "Log Not Connected\nData Not Connected" : (uiState === BackEnd.Connecting ? 'Connecting' : (uiState === BackEnd.NoLog ? 'Log Not Connected' : (uiState === BackEnd.NoData ? 'Data Not Connected' : 'Connected'))))
            }

            onClicked: {
                if (uiState !== BackEnd.Online && uiState !== BackEnd.Connecting) {
                    doReconnect();
                }
            }
        }
    }

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
                onHidConnectStatus: function(connecting, dataOnline, logOnline) {
                    if (!connecting && !dataOnline) {
                        serialLogModel.add('Data connection failed');
                    }
                    if (!connecting && !logOnline) {
                        serialLogModel.add('Log connection failed');
                    }
                    serialLog.positionViewAtIndex(serialLogModel.rowCount() - 1, ListView.End);
                }
            }
        }
    }

    Rectangle {
        visible: uiState === BackEnd.Connecting || uiState === BackEnd.Offline || uiState === BackEnd.NoLog
        height: 25
        width: 135
        anchors.right: parent.right
        anchors.top: logToolbar.bottom
        color: "transparent"
        Label {
            text: qsTr("\u26a0 NOT CONNECTED")
            color: "#333333"
            anchors.centerIn: parent
            font.pixelSize: Qt.application.font.pixelSize * 1.4
        }
    }

    // Darken screen when log is Not Connected
    Rectangle {
        anchors.fill: parent
        opacity: 0.35
        color: 'gray'
        visible: uiState !== BackEnd.Online && uiState !== BackEnd.NoData
    }

}

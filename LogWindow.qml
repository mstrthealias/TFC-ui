import QtQuick 2.13
import QtQuick.Window 2.3
import QtQuick.Controls 2.13
import BackEnd 1.0
import LogListModel 0.1

ApplicationWindow {
    property int logMargin: 8

    id: logWindow

    title: qsTr("Log")

    width: 455
    height: 645

    header: ToolBar {
        id: logToolbar
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: "\u25C0"
            onClicked: {
                logWindow.close()
            }
        }

        Label {
            id: logHdrLabel
            text: qsTr("Log")
            anchors.centerIn: parent
            font.capitalization: Font.AllUppercase
        }

        ToolButton {
            id: statusButton
            icon.source: "images/worldwide.svg"
            icon.height: 20
            icon.width: 20
            icon.color: {
                return uiState === BackEnd.Offline
                        ? 'red'
                        : (uiState === BackEnd.Online
                           ? '#ededed'
                           : (uiState === BackEnd.Connecting ? 'gray' : 'yellow'))
            }
            display: AbstractButton.IconOnly
            anchors.left: logHdrLabel.right

            ToolTip {
                visible: parent.hovered
                text: {
                    return qsTr(uiState === BackEnd.Offline
                                ? "Log Not Connected\nData Not Connected"
                                : (uiState === BackEnd.Connecting
                                   ? 'Connecting'
                                   : (uiState === BackEnd.NoLog
                                      ? 'Log Not Connected'
                                      : (uiState === BackEnd.NoData ? 'Data Not Connected' : 'Connected')))) +
                            (uiState !== BackEnd.Online && uiState !== BackEnd.Connecting ? "\nClick to retry connection" : '')
                }
            }

            onClicked: {
                if (uiState !== BackEnd.Online && uiState !== BackEnd.Connecting) {
                    doReconnect();
                }
            }
        }
    }

    ListView {
        id: serialLog
        anchors.fill: parent

        // for top/bottom margin
        header: Item {
            height: logMargin
        }
        footer: Item {
            height: logMargin
        }

        // allow scroll in both directions, display scrollbars
        flickableDirection: Flickable.AutoFlickIfNeeded
        ScrollBar.vertical: ScrollBar { }
        ScrollBar.horizontal: ScrollBar { }

        model: LogListModel {
            id: serialLogModel
        }

        delegate: Text {
            text: model.display
            leftPadding: logMargin
            rightPadding: logMargin
            Component.onCompleted: {
                serialLog.contentWidth = Math.max(serialLog.contentWidth, contentWidth + leftPadding + rightPadding)
            }
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

    Rectangle {
        visible: uiState === BackEnd.Connecting || uiState === BackEnd.Offline || uiState === BackEnd.NoLog
        height: 25
        width: 155
        anchors.right: parent.right
        anchors.top: logToolbar.bottom
        color: "transparent"
        Label {
            text: qsTr("\u26a0 Not Connected")
            color: "#333333"
            anchors.centerIn: parent
            font.capitalization: Font.AllUppercase
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

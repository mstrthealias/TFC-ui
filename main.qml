import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Material 2.1
import QtQuick.Window 2.0
import BackEnd 1.0

ApplicationWindow {
    property int uiState: BackEnd.Connecting
    property int hidState: BackEnd.HidData

    // triggered when save is clicked; components optionally connected-to for before-save validation
    signal beforeSave()
    // trigger when a view is closed
    signal beforeClose()

    id: window
    title: qsTr("Teensy Fan Controller")
    visible: true

    width: 575
    height: 645

    BackEnd {
        id: backEnd
        objectName: 'backEnd'
    }

    // log window is always active when application is running (shown using hdr button)
    LogWindow {
        id: logWindow
        visible: false
        x: window.width + window.x - 5
        y: window.y
        onVisibleChanged: {
            logPageButton.highlighted = visible;
        }
    }

    Connections {
        target: backEnd
        onHidConnectStatus: function(connecting, dataOnline, logOnline) {
            if (connecting)
                uiState = BackEnd.Connecting;
            else if (dataOnline && logOnline)
                uiState = BackEnd.Online;
            else if (logOnline)
                uiState = BackEnd.NoData;
            else if (dataOnline)
                uiState = BackEnd.NoLog;
            else
                uiState = BackEnd.Offline;
        }
        onHidState: function(state) {
            if (state === hidState)
                return;
            hidState = state;
        }
    }

    function doReconnect() {
        uiState = BackEnd.Connecting;
        console.log('Reset connection retry limits');
        backEnd.reconnect();
    }

    header: ToolBar {
        id: mainToolbar
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            onClicked: {
                if (stackView.depth > 1) {
                    if (stackView.depth == 2)
                        editToolbar.visible = false;
                    beforeClose()  // make sure any changes are not list
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            id: hdrLabel
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        ToolButton {
            id: statusButton
            visible: stackView.depth <= 1
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
            anchors.left: hdrLabel.right

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
                if (hidState !== BackEnd.HidData)
                    return;
                if (uiState !== BackEnd.Online && uiState !== BackEnd.Connecting) {
                    doReconnect();
                }
            }
        }

        ToolButton {
            id: logPageButton
            icon.source: "images/log.svg"
            icon.height: 20
            icon.width: 20
            display: AbstractButton.IconOnly
            anchors.right: parent.right
            onClicked: {
                if (!highlighted)
                    logWindow.show()
                else
                    logWindow.hide()
            }
        }
    }

    footer: ToolBar {
        id: editToolbar
        visible: false
        contentHeight: saveButton.implicitHeight

        ToolButton {
            id: saveButton
            anchors.right: parent.right
            text: qsTr("Save")
            onClicked: {
                if (hidState !== BackEnd.HidData)
                    return;
                window.beforeSave()
                backEnd.save()
            }
        }
    }

    Drawer {
        id: drawer
        width: Math.max(115, Math.min(window.width * 0.65, 255))
        height: window.height

        Column {
            anchors.fill: parent
            ItemDelegate {
                text: qsTr("Fan Setup")
                width: parent.width
                onClicked: {
                    editToolbar.visible = true
                    stackView.push("fans.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Hardware Setup")
                width: parent.width
                onClicked: {
                    editToolbar.visible = true
                    stackView.push("hardware.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Log")
                width: parent.width
                onClicked: {
                    if (logWindow.visible)
                        logWindow.requestActivate()
                    else
                        logWindow.show()
                    drawer.close()
                }
            }
//            ItemDelegate {
//                text: qsTr("Graph")
//                width: parent.width
//                onClicked: {
//                    stackView.push("history.qml")
//                    drawer.close()
//                }
//            }
        }
    }

    StackView {
        id: stackView
        objectName: 'stackView'
        initialItem: "pv.qml"
        anchors.fill: parent
    }

    // Not Connected indicator
    Rectangle {
        id: uiIndicator
        visible: uiState === BackEnd.Connecting || uiState === BackEnd.Offline || uiState === BackEnd.NoData
        height: 25
        width: 155
        anchors.top: mainToolbar.bottom
        anchors.right: parent.right
        color: "transparent"
        Label {
            text: qsTr("\u26a0 NOT CONNECTED")
            color: "#333333"
            anchors.centerIn: parent
        }
    }

    // Config Download indicator
    Rectangle {
        visible: !uiIndicator.visible && hidState !== BackEnd.HidData
        height: 25
        width: 255
        anchors.top: mainToolbar.bottom
        anchors.right: parent.right
        color: "transparent"
        Label {
            text: qsTr(hidState === BackEnd.HidConfig ? "\u26a0 DOWNLOADING CONFIGURATION" : "\u26a0 SAVING CONFIGURATION")
            color: "#333333"
            anchors.centerIn: parent
        }
    }

    // Darken screen when Not Connected or config download/upload is active
    Rectangle {
        anchors.fill: parent
        opacity: 0.35
        color: 'gray'
        visible: hidState !== BackEnd.HidData || uiState === BackEnd.Connecting
    }

}

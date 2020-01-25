import QtQuick 2.13
import QtQuick.Controls 2.13
import BackEnd 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1200
    height: 800
    title: qsTr("Teensy Fan Controller")

    // triggered when save is clicked; components optionally connected-to for before-save validation
    signal beforeSave()

    BackEnd {
        id: backEnd
        objectName: 'backEnd'
    }

    header: ToolBar {
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font.pixelSize: Qt.application.font.pixelSize * 1.6
            onClicked: {
                if (stackView.depth > 1) {
                    editToolbar.visible = false
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        Rectangle {
            id: noDataConnection
            visible: false
            height: 25
            width: Math.max(155, window.width * 0.35)
            anchors.right: parent.right
            color: "yellow"
            border.color: "#b4b4b4"
            border.width: 1
            Label {
                text: qsTr("NO DATA CONNECTION")
                color: "#333333"
                anchors.centerIn: parent
                font.pixelSize: Qt.application.font.pixelSize * 1.4
            }
        }

        Rectangle {
            id: noLogConnection
            visible: false
            height: 25
            width: Math.max(155, window.width * 0.35)
            anchors.right: parent.right
            anchors.top: noDataConnection.bottom
            anchors.topMargin: 5
            color: "yellow"
            border.color: "#b4b4b4"
            border.width: 1
            Label {
                text: qsTr("NO LOG CONNECTION")
                color: "#333333"
                anchors.centerIn: parent
                font.pixelSize: Qt.application.font.pixelSize * 1.4
            }
        }

        Connections {
            target: backEnd
            onHidConnectFailure: function(isDataConnection) {
                if (isDataConnection) {
                    noDataConnection.visible = true
                }
                else {
                    noLogConnection.visible = true
                }
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
            font.pixelSize: Qt.application.font.pixelSize
            onClicked: {
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
                text: qsTr("Present Values")
                width: parent.width
                onClicked: {
                    stackView.push("pv.qml")
                    drawer.close()
                }
            }
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
//            ItemDelegate {
//                text: qsTr("Serial Log")
//                width: parent.width
//                onClicked: {
//                    editToolbar.visible = false
//                    stackView.push("log.qml")
//                    drawer.close()
//                }
//            }
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
        initialItem: "log.qml"
        anchors.fill: parent
    }
}

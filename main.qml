import QtQuick 2.13
import QtQuick.Controls 2.13
import BackEnd 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 640
    height: 600
    title: qsTr("Teensy Fan Controller")

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
                backEnd.save()
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

//            ItemDelegate {
//                text: qsTr("Present Values")
//                width: parent.width
//                onClicked: {
//                    stackView.push("pv.qml")
//                    drawer.close()
//                }
//            }
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
                text: qsTr("PID Setup")
                width: parent.width
                onClicked: {
                    editToolbar.visible = true
                    stackView.push("pid.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Serial Log")
                width: parent.width
                onClicked: {
                    editToolbar.visible = false
                    stackView.push("log.qml")
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
}

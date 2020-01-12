import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Page {
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    title: qsTr("Fan Setup")

    ScrollView {
        anchors.fill: parent

        RowLayout {
            width: 1200
            anchors.top: parent.top

            GridLayout {
                id: fansGrid
                anchors.margins: 12
                width: 600

                columns: 1

                Fan {
                    title: qsTr("Fan 1")
                    fan: backEnd.fan1
                    fanNo: 1
                }
                Fan {
                    title: qsTr("Fan 2")
                    fan: backEnd.fan2
                    fanNo: 2
                }
                Fan {
                    title: qsTr("Fan 3")
                    fan: backEnd.fan3
                    fanNo: 3
                }
                Fan {
                    title: qsTr("Fan 4")
                    fan: backEnd.fan4
                    fanNo: 4
                }
                Fan {
                    title: qsTr("Fan 5")
                    fan: backEnd.fan5
                    fanNo: 5
                }
                Fan {
                    title: qsTr("Fan 6")
                    fan: backEnd.fan6
                    fanNo: 6
                }
            }

            Page {
                anchors.margins: 12
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 335
                width: 335
                height: 400

                Page {
                    property var pid
                    property string pidTitle

                    id: pidPage
                    visible: false
                    anchors.fill: parent

                    function show(source) {
                        visible = false
                        tblPage.visible = false
                        switch (source) {
                        case 0:
                            pidPage.pidTitle = "Supply Temp PID"
                            pidPage.pid = backEnd.pid1
                            visible = true
                            break;
                        case 2:
                            pidPage.pidTitle = "Case Temp PID"
                            pidPage.pid = backEnd.pid2
                            visible = true
                            break;
                        case 3:
                            pidPage.pidTitle = "Aux1 Temp PID"
                            pidPage.pid = backEnd.pid3
                            visible = true
                            break;
                        case 4:
                            pidPage.pidTitle = "Aux2 Temp PID"
                            pidPage.pid = backEnd.pid4
                            visible = true
                            break;
                        default:
                            pidPage.pidTitle = "INVALID TEMP SOURCE"
                            pidPage.pid = undefined
                            visible = false
                            break;
                        }
                    }

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

                Page {
                    property var fan
                    property string tblTitle

                    id: tblPage
                    visible: false
                    anchors.fill: parent

                    function show(source, fan, fanNo) {
                        visible = false
                        pidPage.visible = false
                        let prefix = "Fan " + fanNo + ": "
                        switch (source) {
                        case 0:
                            tblPage.tblTitle = prefix + "Supply Temp - % Table"
                            break;
                        case 1:
                            tblPage.tblTitle = prefix + "Return Temp - % Table"
                            break;
                        case 2:
                            tblPage.tblTitle = prefix + "Case Temp - % Table"
                            break;
                        case 3:
                            tblPage.tblTitle = prefix + "Aux1 Temp - % Table"
                            break;
                        case 4:
                            tblPage.tblTitle = prefix + "Aux2 Temp - % Table"
                            break;
                        case 5:
                            tblPage.tblTitle = prefix + "DeltaT - % Table"
                            break;
                        }
                        tblPage.fan = fan
                        visible = true
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
            }
        }
    }
}

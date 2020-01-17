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
                id: fanPageHolder
                anchors.margins: 12
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 335
                width: 335
                height: 400

                function showPID(source) {
                    if (!fanStackView.empty)
                        fanStackView.pop();
                    let valid = true,
                        pid, pidTitle;
                    switch (source) {
                    case 0:
                        pidTitle = "Supply Temp PID"
                        pid = backEnd.pid1
                        break;
                    case 2:
                        pidTitle = "Case Temp PID"
                        pid = backEnd.pid2
                        break;
                    case 3:
                        pidTitle = "Aux1 Temp PID"
                        pid = backEnd.pid3
                        break;
                    case 4:
                        pidTitle = "Aux2 Temp PID"
                        pid = backEnd.pid4
                        break;
                    default:
                        pidTitle = "INVALID TEMP SOURCE"
                        pid = undefined
                        valid = false
                        break;
                    }
                    fanStackView.push("FanPID.qml", {
                                          pidTitle: pidTitle,
                                          pid: pid
                                      })
                }

                function showTbl(fan, fanNo) {
                    if (!fanStackView.empty)
                        fanStackView.pop();
                    let prefix = "Fan " + fanNo + ": ",
                        tblTitle;
                    switch (fan.source) {
                    case 0:
                        tblTitle = prefix + "Supply Temp - % Table"
                        break;
                    case 1:
                        tblTitle = prefix + "Return Temp - % Table"
                        break;
                    case 2:
                        tblTitle = prefix + "Case Temp - % Table"
                        break;
                    case 3:
                        tblTitle = prefix + "Aux1 Temp - % Table"
                        break;
                    case 4:
                        tblTitle = prefix + "Aux2 Temp - % Table"
                        break;
                    case 5:
                        tblTitle = prefix + "DeltaT - % Table"
                        break;
                    }
                    fanStackView.push("FanTable.qml", {
                                          tblTitle: tblTitle,
                                          fan: fan
                                      })
                    fanStackView.currentItem.load()
                }

                StackView {
                    id: fanStackView
                    objectName: 'fanStackView'
                    anchors.fill: parent
                }
            }
        }
    }
}

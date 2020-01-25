import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var pid

    width: 455
    height: 435

    Text {
        text: title
        width: 405
        height: 35
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignTop
        font.pixelSize: 14
    }

    GridLayout {
        id: pctGrid
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 35

        columns: 3

        TextField {
            id: fieldPercentMin
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Minimum Fan % (%)")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("The minimum % the PID is allowed to output.")
            }
            text: pid ? pid.percentMin : 0

            Binding {
                target: pid; property: "percentMin"; value: fieldPercentMin.text
            }
        }
        TextField {
            id: fieldPercentMax1
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Maximum Fan % 1 (%)")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("The maximum % the PID is allowed to output, when setpoint < setpoint_max and the setpoint may step up.")
            }
            text: pid ? pid.percentMax1 : 0

            Binding {
                target: pid; property: "percentMax1"; value: fieldPercentMax1.text
            }
        }
        TextField {
            id: fieldPercentMax2
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Maximum Fan % 2 (%)")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("The maximum % the PID is allowed to output, when setpoint = setpoint_max or the setpoint is not allowed to step up (due to case temp delta).")
            }
            text: pid ? pid.percentMax2 : 0

            Binding {
                target: pid; property: "percentMax2"; value: fieldPercentMax2.text
            }
        }
    }
    GridLayout {
        id: pidGrid
        anchors.top: pctGrid.bottom
        anchors.left: parent.left
        anchors.topMargin: 12

        columns: 3

        TextField {
            id: fieldSetpoint
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Setpoint")
            }
//                    // TODO
//                    ToolTip {
//                        visible: parent.hovered
//                        text: qsTr("Water supply temperature setpoint.")
//                    }
            text: pid ? pid.setpoint : 0

            Binding {
                target: pid; property: "setpoint"; value: fieldSetpoint.text
            }
        }
        CheckBox {
            id: fieldAdaptiveSP
            text: qsTr("Automatically Adjust (Setpoint Reset)")
            checked: pid ? pid.adaptiveSP : 0

            Binding {
                target: pid; property: "adaptiveSP"; value: fieldAdaptiveSP.checked
            }
        }
    }
    GridLayout {
        id: gainGrid
        anchors.top: pidGrid.bottom
        anchors.left: parent.left
        anchors.topMargin: 12

        columns: 3

        TextField {
            id: fieldGainP
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Gain (P)")
            }
            text: pid ? pid.gainP : 0

            Binding {
                target: pid; property: "gainP"; value: fieldGainP.text
            }
        }
        TextField {
            id: fieldGainI
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Gain (I)")
            }
            text: pid ? pid.gainI : 0

            Binding {
                target: pid; property: "gainI"; value: fieldGainI.text
            }
        }
        TextField {
            id: fieldGainD
//            Layout.fillWidth: true
            Layout.preferredWidth: 135
            Layout.minimumWidth: 90
            Label {
                text: qsTr("Gain (D)")
            }
            text: pid ? pid.gainD : 0

            Binding {
                target: pid; property: "gainD"; value: fieldGainD.text
            }
        }
    }

    Page {
        anchors.top: gainGrid.bottom
        anchors.left: parent.left
        //anchors.right: parent.right
        anchors.topMargin: 24
        visible: fieldAdaptiveSP.checked

        header: ToolBar{
            height: 20

            Label {
                font.pixelSize: Qt.application.font.pixelSize
                text: "Setpoint Reset"
                anchors.centerIn: parent
            }
        }

        GridLayout {
            anchors.fill: parent

            columns: 3

            TextField {
                id: fieldSetpointMin
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("Setpoint Min (degC)")
                }
                text: pid ? pid.setpointMin : 0

                Binding {
                    target: pid; property: "setpointMin"; value: fieldSetpointMin.text
                }
            }
            TextField {
                id: fieldSetpointMax
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("Setpoint Max (degC)")
                }
                text: pid ? pid.setpointMax : 0

                Binding {
                    target: pid; property: "setpointMax"; value: fieldSetpointMax.text
                }
            }
            TextField {
                id: fieldStepSize
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("Step Size (degC)")
                }
                text: pid ? pid.adaptiveSPStepSize : 0

                Binding {
                    target: pid; property: "adaptiveSPStepSize"; value: fieldStepSize.text
                }
            }

            Item {
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
            }
            Item {
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
            }
            CheckBox {
                id: fieldUseCaseTemp
                text: qsTr("Use Case Temp")
                checked: pid ? pid.adaptiveSPUseCaseTemp : 0

                Binding {
                    target: pid; property: "adaptiveSPUseCaseTemp"; value: fieldUseCaseTemp.checked
                }
            }

            TextField {
                id: fieldStepUpPct
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("Step-Up If Fan % Above (%)")
                }
                text: pid ? pid.adaptiveSPStepUp.pct : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "pct"; value: fieldStepUpPct.text
                }
            }
            TextField {
                id: fieldStepUpDelay
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("For (seconds)")
                }
                text: pid ? pid.adaptiveSPStepUp.delay : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "delay"; value: fieldStepUpDelay.text
                }
            }
            TextField {
                id: fieldStepUpCaseTempDelta
                visible: fieldUseCaseTemp.checked
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("And Case Temp Delta Below (degC)")
                }
                text: pid ? pid.adaptiveSPStepUp.caseTempDelta : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "caseTempDelta"; value: fieldStepUpCaseTempDelta.text
                }
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
            }


            TextField {
                id: fieldStepDownPct
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("Step-Down If Fan % Below (%)")
                }
                text: pid ? pid.adaptiveSPStepDown.pct : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "pct"; value: fieldStepDownPct.text
                }
            }
            TextField {
                id: fieldStepDownDelay
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("For (seconds)")
                }
                text: pid ? pid.adaptiveSPStepDown.delay : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "delay"; value: fieldStepDownDelay.text
                }
            }
            TextField {
                id: fieldStepDownCaseTempDelta
                visible: fieldUseCaseTemp.checked
    //            Layout.fillWidth: true
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
                Label {
                    text: qsTr("And Case Temp Delta Above (degC)")
                }
                text: pid ? pid.adaptiveSPStepDown.caseTempDelta : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "caseTempDelta"; value: fieldStepDownCaseTempDelta.text
                }
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.preferredWidth: 135
                Layout.minimumWidth: 90
            }

        }
    }

}

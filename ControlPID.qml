import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var pid

    Layout.fillWidth: true
    height: titleText.implicitHeight + pctGrid.implicitHeight + pidGrid.implicitHeight + gainGrid.implicitHeight + adjPage.implicitHeight + 155

    Text {
        id: titleText
        text: title
        height: 40
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 18
        font.bold: true
    }

    GridLayout {
        id: pctGrid
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 24

        columns: 3

        TextFieldExt {
            id: fieldPercentMin

            minWidth: 155
            label: qsTr("Minimum Fan % (%)")
            tooltip: qsTr("The minimum % the PID is allowed to output.")
            text: pid ? pid.percentMin : 0

            Binding {
                target: pid; property: "percentMin"; value: fieldPercentMin.text
            }
        }
        TextFieldExt {
            id: fieldPercentMax1
            visible: pid.adaptiveSP

            minWidth: 155
            label: qsTr("Maximum Fan % 1 (%)")
            tooltip: qsTr("The maximum % the PID is allowed to output, when setpoint < setpoint_max and the setpoint may step up.")
            text: pid ? pid.percentMax1 : 0

            Binding {
                target: pid; property: "percentMax1"; value: fieldPercentMax1.text
            }
        }
        TextFieldExt {
            id: fieldPercentMax2

            minWidth: 155
            label: qsTr("Maximum Fan % 2 (%)")
            tooltip: qsTr("The maximum % the PID is allowed to output, when setpoint = setpoint_max or the setpoint is not allowed to step up (due to case temp delta).")
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
        anchors.right: parent.right
        anchors.topMargin: 12

        columns: 3

        TextFieldExt {
            id: fieldSetpoint
            Layout.maximumWidth: 115

            label: qsTr("Setpoint")
            text: pid ? pid.setpoint : 0

            Binding {
                target: pid; property: "setpoint"; value: fieldSetpoint.text
            }
        }
        CheckBox {
            id: fieldAdaptiveSP
            Layout.fillWidth: true
            text: qsTr("Automatically Adjust")
            checked: pid ? pid.adaptiveSP : 0

            Binding {
                target: pid; property: "adaptiveSP"; value: fieldAdaptiveSP.checked
            }
        }
        Item {
            Layout.fillWidth: true
        }
    }
    GridLayout {
        id: gainGrid
        anchors.top: pidGrid.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 12

        columns: 3

        TextFieldExt {
            id: fieldGainP

            label: qsTr("Gain (P)")
            text: pid ? pid.gainP : 0

            Binding {
                target: pid; property: "gainP"; value: fieldGainP.text
            }
        }
        TextFieldExt {
            id: fieldGainI

            label: qsTr("Gain (I)")
            text: pid ? pid.gainI : 0

            Binding {
                target: pid; property: "gainI"; value: fieldGainI.text
            }
        }
        TextFieldExt {
            id: fieldGainD

            label: qsTr("Gain (D)")
            text: pid ? pid.gainD : 0

            Binding {
                target: pid; property: "gainD"; value: fieldGainD.text
            }
        }
    }

    Item {
        id: adjPage
        implicitHeight: subtitleText.height + adjGrid.height + 12
        anchors.top: gainGrid.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 24
        visible: fieldAdaptiveSP.checked

        Text {
            id: subtitleText
            text: qsTr("Setpoint Adjustment")
            height: 33
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 14
            font.bold: true
        }

        GridLayout {
            id: adjGrid
            anchors.top: subtitleText.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12

            columns: 3

            TextFieldExt {
                id: fieldSetpointMin

                minWidth: 125
                label: qsTr("Setpoint Min (°C)")
                text: pid ? pid.setpointMin : 0

                Binding {
                    target: pid; property: "setpointMin"; value: fieldSetpointMin.text
                }
            }
            TextFieldExt {
                id: fieldSetpointMax

                minWidth: 125
                label: qsTr("Setpoint Max (°C)")
                text: pid ? pid.setpointMax : 0

                Binding {
                    target: pid; property: "setpointMax"; value: fieldSetpointMax.text
                }
            }
            TextFieldExt {
                id: fieldStepSize

                minWidth: 125
                label: qsTr("Step Size (°C)")
                text: pid ? pid.adaptiveSPStepSize : 0

                Binding {
                    target: pid; property: "adaptiveSPStepSize"; value: fieldStepSize.text
                }
            }

            Item {
                Layout.minimumWidth: 90
            }
            Item {
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

            TextFieldExt {
                id: fieldStepUpPct

                minWidth: 195
                label: qsTr("Step-Up If Fan % Above (%)")
                text: pid ? pid.adaptiveSPStepUp.pct : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "pct"; value: fieldStepUpPct.text
                }
            }
            TextFieldExt {
                id: fieldStepUpDelay

                minWidth: 85
                label: qsTr("For (seconds)")
                text: pid ? pid.adaptiveSPStepUp.delay : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "delay"; value: fieldStepUpDelay.text
                }
            }
            TextFieldExt {
                id: fieldStepUpCaseTempDelta
                visible: fieldUseCaseTemp.checked

                minWidth: 195
                label: qsTr("And Case Temp Delta Below (°C)")
                text: pid ? pid.adaptiveSPStepUp.caseTempDelta : 0

                Binding {
                    target: pid.adaptiveSPStepUp; property: "caseTempDelta"; value: fieldStepUpCaseTempDelta.text
                }
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.minimumWidth: 90
            }


            TextFieldExt {
                id: fieldStepDownPct

                minWidth: 205
                label: qsTr("Step-Down If Fan % Below (%)")
                text: pid ? pid.adaptiveSPStepDown.pct : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "pct"; value: fieldStepDownPct.text
                }
            }
            TextFieldExt {
                id: fieldStepDownDelay

                minWidth: 85
                label: qsTr("For (seconds)")
                text: pid ? pid.adaptiveSPStepDown.delay : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "delay"; value: fieldStepDownDelay.text
                }
            }
            TextFieldExt {
                id: fieldStepDownCaseTempDelta
                visible: fieldUseCaseTemp.checked

                minWidth: 215
                label: qsTr("And Case Temp Delta Above (°C)")
                text: pid ? pid.adaptiveSPStepDown.caseTempDelta : 0

                Binding {
                    target: pid.adaptiveSPStepDown; property: "caseTempDelta"; value: fieldStepDownCaseTempDelta.text
                }
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.minimumWidth: 90
            }
        }
    }

}

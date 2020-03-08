import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var pid

    Layout.fillWidth: true
    height: titleText.implicitHeight + pctGrid.implicitHeight + pidGrid.implicitHeight + gainGrid.implicitHeight + adjPage.implicitHeight + 155

    Label {
        id: titleText
        text: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
    }

    GridLayout {
        id: pctGrid
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 12

        columns: 3

        TextFieldExt {
            id: fieldPercentMin

            minWidth: 155
            label: qsTr("Minimum Fan % (%)")
            tooltip: qsTr("The minimum % the PID is allowed to output.")
            text: pid ? pid.percentMin : 0

            target: pid
            property: "percentMin"
        }
        TextFieldExt {
            id: fieldPercentMax1
            visible: pid.adaptiveSP

            minWidth: 155
            label: qsTr("Maximum Fan % 1 (%)")
            tooltip: qsTr("The maximum % the PID is allowed to output, when setpoint < setpoint_max and the setpoint may step up.")
            text: pid ? pid.percentMax1 : 0

            target: pid
            property: "percentMax1"
        }
        Item {
            visible: !pid.adaptiveSP
            Layout.minimumWidth: 155
            Layout.fillWidth: true
        }
        TextFieldExt {
            id: fieldPercentMax2

            minWidth: 155
            label: qsTr("Maximum Fan % 2 (%)")
            tooltip: qsTr("The maximum % the PID is allowed to output, when setpoint = setpoint_max or the setpoint is not allowed to step up (due to case temp delta).")
            text: pid ? pid.percentMax2 : 0

            target: pid
            property: "percentMax2"
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

            target: pid
            property: "setpoint"
        }
        CheckBox {
            id: fieldAdaptiveSP
            Layout.fillWidth: true
            text: qsTr("Automatically Adjust")
            checked: pid ? pid.adaptiveSP : 0

            onToggled: {
                pid.adaptiveSP = fieldAdaptiveSP.checked
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

            target: pid
            property: "gainP"
        }
        TextFieldExt {
            id: fieldGainI

            label: qsTr("Gain (I)")
            text: pid ? pid.gainI : 0

            target: pid
            property: "gainI"
        }
        TextFieldExt {
            id: fieldGainD

            label: qsTr("Gain (D)")
            text: pid ? pid.gainD : 0

            target: pid
            property: "gainD"
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

        Label {
            id: subtitleText
            text: qsTr("Setpoint Adjustment")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.capitalization: Font.AllUppercase
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

                target: pid
                property: "setpointMin"
            }
            TextFieldExt {
                id: fieldSetpointMax

                minWidth: 125
                label: qsTr("Setpoint Max (°C)")
                text: pid ? pid.setpointMax : 0

                target: pid
                property: "setpointMax"
            }
            TextFieldExt {
                id: fieldStepSize

                minWidth: 125
                label: qsTr("Step Size (°C)")
                text: pid ? pid.adaptiveSPStepSize : 0

                target: pid
                property: "adaptiveSPStepSize"
            }

            Item {
                Layout.minimumWidth: 125
                Layout.fillWidth: true
            }
            Item {
                Layout.minimumWidth: 125
                Layout.fillWidth: true
            }
            CheckBox {
                id: fieldUseCaseTemp
                text: qsTr("Use Case Temp")
                checked: pid ? pid.adaptiveSPUseCaseTemp : 0

                onToggled: {
                    pid.adaptiveSPUseCaseTemp = fieldUseCaseTemp.checked
                }
            }

            TextFieldExt {
                id: fieldStepUpPct

                minWidth: 195
                label: qsTr("Step-Up If Fan % Above (%)")
                text: pid ? pid.adaptiveSPStepUp.pct : 0

                target: pid.adaptiveSPStepUp
                property: "pct"
            }
            TextFieldExt {
                id: fieldStepUpDelay

                minWidth: 85
                label: qsTr("For (seconds)")
                text: pid ? pid.adaptiveSPStepUp.delay : 0

                target: pid.adaptiveSPStepUp
                property: "delay"
            }
            TextFieldExt {
                id: fieldStepUpCaseTempDelta
                visible: fieldUseCaseTemp.checked

                minWidth: 195
                label: qsTr("And Case Temp Delta Below (°C)")
                text: pid ? pid.adaptiveSPStepUp.caseTempDelta : 0

                target: pid.adaptiveSPStepUp
                property: "caseTempDelta"
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.minimumWidth: 195
                Layout.fillWidth: true
            }


            TextFieldExt {
                id: fieldStepDownPct

                minWidth: 205
                label: qsTr("Step-Down If Fan % Below (%)")
                text: pid ? pid.adaptiveSPStepDown.pct : 0

                target: pid.adaptiveSPStepDown
                property: "pct"
            }
            TextFieldExt {
                id: fieldStepDownDelay

                minWidth: 85
                label: qsTr("For (seconds)")
                text: pid ? pid.adaptiveSPStepDown.delay : 0

                target: pid.adaptiveSPStepDown
                property: "delay"
            }
            TextFieldExt {
                id: fieldStepDownCaseTempDelta
                visible: fieldUseCaseTemp.checked

                minWidth: 215
                label: qsTr("And Case Temp Delta Above (°C)")
                text: pid ? pid.adaptiveSPStepDown.caseTempDelta : 0

                target: pid.adaptiveSPStepDown
                property: "caseTempDelta"
            }
            Item {
                visible: !fieldUseCaseTemp.checked
                Layout.minimumWidth: 215
                Layout.fillWidth: true
            }
        }
    }

}

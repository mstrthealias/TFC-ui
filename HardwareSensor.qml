import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var sensor

    width: 260
    height: 140

    Text {
        text: title
        width: 240
        height: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
    }

    GridLayout {
        x: 0
        y: 20
        width: 240
        height: 100
        columns: 2

        TextField {
            id: fieldPin
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Pin")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Teensy (actual) pin number (must support Analog/ADC).")
            }
            text: sensor.pin

            Binding {
                target: sensor; property: "pin"; value: fieldPin.text
            }
        }

        TextField {
            id: fieldSeriesR
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Series Resistor (Ohm)")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Series resistor used to pull-up thermistor, adjust this to calibrate reading. Note: use a 10k resistor for 10k thermistor.")
            }
            text: sensor.seriesR

            Binding {
                target: sensor; property: "seriesR"; value: fieldSeriesR.text
            }
        }

        TextField {
            id: fieldNominalR
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Thermistor Nominal Resistance (Ohm)")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Thermistor resistance, usually 10000 (for 10K thermistor).")
            }
            text: sensor.nominalR

            Binding {
                target: sensor; property: "nominalR"; value: fieldNominalR.text
            }
        }

        TextField {
            id: fieldBeta
//            Layout.fillWidth: true
            Layout.preferredWidth: 120
            Layout.minimumWidth: 90
            Label {
                width: 120
                text: qsTr("Thermistor Beta Coefficient")
            }
            ToolTip {
                visible: parent.hovered
                text: qsTr("Thermistor Beta coefficient, usually between 3000-4000.")
            }
            text: sensor.beta

            Binding {
                target: sensor; property: "beta"; value: fieldBeta.text
            }
        }
    }

}

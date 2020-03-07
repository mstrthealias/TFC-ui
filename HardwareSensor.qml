import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var sensor

    property int fieldMinWidth: 145

    Layout.fillWidth: true
    height: 189

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
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        columns: 2

        TextFieldExt {
            id: fieldPin
            minWidth: fieldMinWidth
            label: qsTr("Pin")
            tooltip: qsTr("Teensy (actual) pin number (must support Analog/ADC).")
            text: sensor.pin

            Binding {
                target: sensor; property: "pin"; value: fieldPin.text
            }
        }

        TextFieldExt {
            id: fieldSeriesR
            minWidth: fieldMinWidth
            label: qsTr("Series Resistor (Ohm)")
            tooltip: qsTr("Series resistor used to pull-up thermistor, adjust this to calibrate reading.")
            text: sensor.seriesR

            Binding {
                target: sensor; property: "seriesR"; value: fieldSeriesR.text
            }
        }

        TextFieldExt {
            id: fieldNominalR
            minWidth: fieldMinWidth
            label: qsTr("Thermistor Nominal Resistance (Ohm)")
            tooltip: qsTr("Thermistor resistance, usually 10000 (for 10K thermistor).")
            text: sensor.nominalR

            Binding {
                target: sensor; property: "nominalR"; value: fieldNominalR.text
            }
        }

        TextFieldExt {
            id: fieldBeta
            minWidth: fieldMinWidth
            label: qsTr("Thermistor Beta Coefficient")
            tooltip: qsTr("Thermistor Beta coefficient, usually between 3000-4000.")
            text: sensor.beta

            Binding {
                target: sensor; property: "beta"; value: fieldBeta.text
            }
        }
    }

}

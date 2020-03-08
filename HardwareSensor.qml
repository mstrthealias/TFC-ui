import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var sensor

    property int fieldMinWidth: 145
    property int lblTopMargin: 8

    Layout.fillWidth: true
    height: 143

    Label {
        id: titleText
        text: title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: lblTopMargin
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.bold: true
    }

    GridLayout {
        anchors.top: titleText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 2

        columns: 2

        TextFieldExt {
            id: fieldPin
            minWidth: fieldMinWidth
            label: qsTr("Pin")
            tooltip: qsTr("Teensy (actual) pin number (must support Analog/ADC).")
            text: sensor.pin

            target: sensor
            property: "pin"
        }

        TextFieldExt {
            id: fieldSeriesR
            minWidth: fieldMinWidth
            label: qsTr("Series Resistor (Ohm)")
            tooltip: qsTr("Series resistor used to pull-up thermistor, adjust this to calibrate reading.")
            text: sensor.seriesR

            target: sensor
            property: "seriesR"
        }

        TextFieldExt {
            id: fieldNominalR
            minWidth: fieldMinWidth
            label: qsTr("Thermistor Nominal Resistance (Ohm)")
            tooltip: qsTr("Thermistor resistance, usually 10000 (for 10K thermistor).")
            text: sensor.nominalR

            target: sensor
            property: "nominalR"
        }

        TextFieldExt {
            id: fieldBeta
            minWidth: fieldMinWidth
            label: qsTr("Thermistor Beta Coefficient")
            tooltip: qsTr("Thermistor Beta coefficient, usually between 3000-4000.")
            text: sensor.beta

            target: sensor
            property: "beta"
        }
    }

}

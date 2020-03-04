import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

TextField {
    property bool autoSelectText: true
    property string tooltip: ""
    property string label: ""
    property int minWidth: 115

    Layout.preferredHeight: 59
    Layout.minimumHeight: 59

    Layout.minimumWidth: minWidth
    Layout.fillWidth: true

    verticalAlignment: Text.AlignBottom

    Label {
        text: label
        wrapMode: Text.WrapAnywhere
    }

    ToolTip {
        visible: tooltip && parent.hovered
        text: tooltip
    }

    onFocusChanged: {
        if (autoSelectText) {
            if (focus)
                selectAll();
            else
                deselect();
        }
    }

}

import QtQuick 2.0
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

TextField {
    property bool autoSelectText: true
    property string tooltip: ""
    property string label: ""
    property int minWidth: 115
    property var labelColor

    // handle changes internally
    property var target: null
    property string property: ""

    Layout.preferredHeight: 59
    Layout.minimumHeight: 59

    Layout.minimumWidth: minWidth
    Layout.fillWidth: true

    verticalAlignment: Text.AlignBottom

    // flush changes before writing to device (or closing view)
    Connections {
        target: window
        onBeforeSave: function() {
            saveChanges()
        }
        onBeforeClose: function() {
            saveChanges()
        }
    }

    function saveChanges() {
        if (target && property) {
            target[property] = text
        }
    }

    Label {
        text: label
        wrapMode: Text.WrapAnywhere
        color: labelColor || color
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

        // flush changes when focus lost
        if (!focus)
            saveChanges()
    }

}

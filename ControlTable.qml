import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    property var pctChanges
    property var tempChanges

    width: 455
    height: 435

    Connections {
        target: window
        // make sure changes are flushed to config, before writing to device
        onBeforeSave: function() {
            save()
        }
    }

    function load() {
        let lastObj = undefined,
            revTbl = fan.tbl.slice().reverse();
        // loop values backwards, skipping rows that match the previous row
        revTbl.forEach(function(obj) {
            if (!lastObj || lastObj.pct !== obj.pct || lastObj.temp !== obj.temp) {
                tblModel.insert(0, {
                                    temp: obj.temp,
                                    pct: obj.pct
                                });
            }
            lastObj = obj;
        });
        if (!revTbl.length) {
            tblModel.append({
                                temp: 25,
                                pct: 0
                            });
        }
    }

    function save() {
        // first validate table data, incase change made and save clicked without lossing field focus
        validateTable();

        let rec, i,
            newTbl = [];
        // if < 10 rows displayed, populate initial rows with first displayed row's values
        for (i = 0; i < (10 - Math.min(Math.max(tblModel.count, 0), 10)); i++) {
            if (!rec)
                rec = tblModel.get(0);
            if (!rec)
                break;
            newTbl.push({
                            temp: rec.temp,
                            pct: rec.pct
                        });
        }
        // populate remaining rows
        for (i = 0; i < Math.min(Math.max(tblModel.count, 0), 10); i++) {
            rec = tblModel.get(i);
            newTbl.push({
                            temp: rec.temp,
                            pct: rec.pct
                        });
        }
        fan.tbl = newTbl;
    }

    function trackPercentChange(index) {
        if (!Array.isArray(pctChanges))
            pctChanges = [];
        pctChanges.push(index);
    }

    function trackTemperatureChange(index) {
        if (!Array.isArray(tempChanges))
            tempChanges = [];
        tempChanges.push(index);
    }

    function validateTable() {
        // percents must be in ascending order
        if (pctChanges && pctChanges.length) {
            // filter unique indexes
            pctChanges = pctChanges.filter(function onlyUnique(value, index, self) {
                return self.indexOf(value) === index;
            });
            pctChanges.forEach(function(index) {
                if (!tblModel.get(index))
                    return;
                let pct = tblModel.get(index).pct,
                    rec, i;
                // if previous row % > pct, set previous row %s = pct
                for (i = 0; i < Math.min(Math.max(index, 0), 10); i++) {
                    rec = tblModel.get(i);
                    if (rec.pct > pct) {
                        tblModel.setProperty(i, "pct", pct);
                    }
                }
                // if later row % < pct, set later row % = pct
                for (i = index + 1; i < Math.min(Math.max(tblModel.count, 0), 10); i++) {
                    rec = tblModel.get(i);
                    if (rec.pct < pct) {
                        tblModel.setProperty(i, "pct", pct);
                    }
                }
            });
            pctChanges = undefined;
        }

        // temperatures must be in ascending order
        if (tempChanges && tempChanges.length) {
            // filter unique indexes
            tempChanges = tempChanges.filter(function onlyUnique(value, index, self) {
                return self.indexOf(value) === index;
            });
            tempChanges.forEach(function(index) {
                if (!tblModel.get(index))
                    return;
                let temp = tblModel.get(index).temp,
                    rec, i;
                // if previous row temperature > temp, set previous row temperature = temp
                for (i = 0; i < Math.min(Math.max(index, 0), 10); i++) {
                    rec = tblModel.get(i);
                    if (rec.temp > temp) {
                        tblModel.setProperty(i, "temp", temp);
                    }
                }
                // if later row temperature < temp, set later row temperature = temp
                for (i = index + 1; i < Math.min(Math.max(tblModel.count, 0), 10); i++) {
                    rec = tblModel.get(i);
                    if (rec.temp < temp) {
                        tblModel.setProperty(i, "temp", temp);
                    }
                }
            });
            tempChanges = undefined;
        }
    }

    Text {
        id: titleCmp
        text: title
        width: 240
        height: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 14
    }

    ListModel {
        id: tblModel
    }

    Component {
        id: tblDelegate
        Row {
            spacing: 10
            TextField {
                placeholderText: "°C"
                text: temp
                onTextChanged: {
                    if (typeof text !== 'string')
                        return;
                    let temp = Number(text),
                        rec;
                    if (text.length && (temp !== 0 || text === '0') && !isNaN(temp)) {
                        if (temp > 131)
                            temp = 131;  // max temp = 131 degC (2^16/500)
                        else if (temp < 0)
                            temp = 0;  // min temp = 0 degC
                        tblModel.setProperty(index, "temp", temp);

                        trackTemperatureChange(index);  // track change for validation
                    }
                }
                onFocusChanged: {
                    if (focus) {
                        selectAll();
                    }
                    else {
                        deselect();
                        save();  // trigger table validation/update config when focus lost
                    }
                }
            }
            TextField {
                placeholderText: "%"
                text: pct
                inputMask: "000;"
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: {
                    if (typeof text !== 'string')
                        return;
                    let pct = Number(text),
                        rec;
                    if (text.length && (pct !== 0 || text === '0') && !isNaN(pct)) {
                        if (pct > 100)
                            pct = 100;  // max % = 100
                        else if (pct < 0)
                            pct = 0;  // min % = 0
                        tblModel.setProperty(index, "pct", pct);

                        trackPercentChange(index);  // track change for validation
                    }
                }
                onFocusChanged: {
                    if (focus) {
                        selectAll();
                    }
                    else {
                        deselect();
                    }
                    save();  // trigger table validation/update config when focus lost
                }
            }
        }
    }

    ListView {
        id: listView
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: titleCmp.bottom
        model: tblModel
        delegate: tblDelegate
    }

    Button {
        id: addEntryBtn
        text: qsTr("Add")
        anchors.top: listView.bottom
        anchors.right: listView.right
        visible: tblModel.count < 10
        onClicked: {
            if (tblModel.count >= 10) {
                console.log('No more rows supported')
                return;
            }
            let last = tblModel.count ? tblModel.get(tblModel.count - 1) : undefined;
            tblModel.append({
                                temp: last ? last.temp : 25,
                                pct: last ? last.pct : 0
                            });
        }
    }
}

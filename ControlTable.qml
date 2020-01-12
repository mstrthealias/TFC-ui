import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

Item {
    property string title
    property var fan

    width: 455
    height: 435

    function load() {
        fan.tbl.forEach(function(obj) {
            tblModel.append({
                                temp: obj.temp,
                                pct: obj.pct
                            });
        });
        if (!fan.tbl.length) {
            tblModel.append({
                                temp: 25,
                                pct: 0
                            });
        }
    }

    function save() {
        let rec,
            newTbl = [];
        for (let i = 0; i < tblModel.count; i++) {
            rec = tblModel.get(i);
            newTbl.push({
                              temp: rec.temp,
                              pct: rec.pct
                          });
        }
        fan.tbl = newTbl;
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
                placeholderText: "degC"
                text: temp
                onTextChanged: {
                    tblModel.setProperty(index, "temp", Number(text))
                }
            }
            TextField {
                placeholderText: "%"
                text: pct
                onTextChanged: {
                    tblModel.setProperty(index, "pct", Number(text))
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
        id: saveEntryBtn
        text: qsTr("Save")
        anchors.top: listView.bottom
        anchors.right: parent.right
        onClicked: {
            save()
        }
    }
    Button {
        id: addEntryBtn
        text: qsTr("Add")
        anchors.top: listView.bottom
        anchors.right: saveEntryBtn.left
        onClicked: {
            let last = tblModel.count ? tblModel.get(tblModel.count - 1) : undefined;
            tblModel.append({
                                temp: last ? last.temp : 25,
                                pct: last ? last.pct : 0
                            });
        }
    }
}

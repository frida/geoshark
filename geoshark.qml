import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1

import Frida 1.0

ApplicationWindow {
    title: qsTr("Hello World")
    width: 640
    height: 480

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                text: qsTr("Exit")
                onTriggered: Qt.quit();
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        TableView {
            id: processes
            Layout.fillHeight: true
            TableViewColumn {
                role: "smallIcon"
                width: 16
                delegate: Image {
                    source: styleData.value
                    fillMode: Image.Pad
                }
            }
            TableViewColumn { role: "pid"; title: "Pid"; width: 50 }
            TableViewColumn { role: "name"; title: "Name";
                              width: 100 }
            model: processModel
            onActivated: {
                Frida.localSystem.inject(script,
                    processModel.get(currentRow).pid);
            }
        }
        TextArea {
            id: messages
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
        }
        Button {
            Layout.alignment: Qt.AlignBottom
            text: "Request Status"
            onClicked: {
                script.post({name: "request-status"});
            }
        }
    }

    ProcessListModel {
        id: processModel
        device: Frida.localSystem
    }

    Script {
        id: script
        url: Qt.resolvedUrl("./agent.js")
        onMessage: {
            messages.append(JSON.stringify(object) + "\n");
        }
    }
}

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Window 2.0

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

    TableView {
        id: processes
        height: parent.height
        TableViewColumn {
            role: "smallIcon"
            width: 16
            delegate: Image {
                source: styleData.value
                fillMode: Image.Pad
            }
        }
        TableViewColumn { role: "pid"; title: "Pid"; width: 50 }
        TableViewColumn { role: "name"; title: "Name"; width: 100 }
        model: processModel
        onActivated: {
            Frida.localSystem.inject(script,
                processModel.get(currentRow).pid);
        }
    }

    ProcessListModel {
        id: processModel
        device: Frida.localSystem
    }

    Script {
        id: script
        url: Qt.resolvedUrl("./agent.js")
    }
}

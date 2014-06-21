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

    Button {
        text: qsTr("Inject")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            Frida.localSystem.inject(script, 1234);
        }
    }

    Script {
        id: script
        source: "console.log('Hello from Frida!');"
    }
}

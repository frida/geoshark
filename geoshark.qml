import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtWebKit.experimental 1.0

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
        ColumnLayout {
            Layout.fillHeight: true
            spacing: 0
            TableView {
                id: devices
                TableViewColumn {
                    role: "icon"
                    width: 16
                    delegate: Image {
                        source: styleData.value
                        fillMode: Image.Pad
                    }
                }
                TableViewColumn { role: "name"; title: "Name";
                                  width: 100 }
                model: deviceModel
            }
            Item {
                width: processes.width
                Layout.fillHeight: true
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
                    TableViewColumn { role: "pid"; title: "Pid";
                                      width: 50 }
                    TableViewColumn { role: "name"; title: "Name";
                                      width: 100 }
                    model: processModel
                    onActivated: {
                        deviceModel.get(devices.currentRow).inject(
                            script, processModel.get(currentRow).pid);
                    }
                }
                BusyIndicator {
                    anchors.centerIn: parent
                    running: processModel.isLoading
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            WebView {
                id: map
                Layout.fillWidth: true
                Layout.fillHeight: true
                url: Qt.resolvedUrl("./map.html")
                function addMarker(ip, lat, lng) {
                    map.experimental.evaluateJavaScript(
                        "addMarker(\"" + ip + "\", " +
                            lat + ", " + lng + ");"
                    );
                }
            }
            TextArea {
                id: messages
                Layout.fillWidth: true
                height: 200
                readOnly: true
            }
        }
        Button {
            Layout.alignment: Qt.AlignBottom
            text: "Request Status"
            onClicked: {
                script.post({name: "request-status"});
            }
        }
    }

    MessageDialog {
        id: errorDialog
        title: "Error"
        icon: StandardIcon.Critical
    }

    DeviceListModel {
        id: deviceModel
    }

    ProcessListModel {
        id: processModel
        device: devices.currentRow !== -1 ? deviceModel.get(devices.currentRow) : null
        onError: {
            errorDialog.text = message;
            errorDialog.open();
        }
    }

    Script {
        id: script
        url: Qt.resolvedUrl("./agent.js")
        onError: {
            errorDialog.text = message;
            errorDialog.open();
        }
        onMessage: {
            messages.append(JSON.stringify(object) + "\n");
            if (object.type === "send") {
                var stanza = object.payload;
                if (stanza.name === "new-ip-address") {
                    var ip = stanza.payload;
                    var xhr = new XMLHttpRequest();
                    xhr.onreadystatechange = function () {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            var location = JSON.parse(xhr.responseText);
                            messages.append("Resolved " + ip +
                                " to " + JSON.stringify(location) + "\n");
                            map.addMarker(ip, location.latitude, location.longitude);
                        }
                    };
                    xhr.open("GET", "http://freegeoip.net/json/" + ip);
                    xhr.send();
                }
            }
        }
    }
}

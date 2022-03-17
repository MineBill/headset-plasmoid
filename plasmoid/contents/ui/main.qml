import QtQuick 2.4
import QtQuick.Layouts 1.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: main
    
    property string deviceName
    property string batteryPercent
    
    //Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
    Plasmoid.fullRepresentation: ColumnLayout {
        anchors.centerIn: parent
        anchors.fill: parent
        spacing: 0
        Layout.minimumWidth: units.gridUnit * 10
        Layout.maximumWidth: units.gridUnit * 10
        Layout.minimumHeight: units.gridUnit * 13   
        Layout.maximumHeight: units.gridUnit * 13
        
        Rectangle {
            color: "transparent"
            height: units.gridUnit * .1
            Layout.fillWidth: true
            PlasmaComponents.Label {
                height: 1
                id: sidetone_valuetest
                text: i18n(deviceName)
                font.pointSize: 13
                anchors.centerIn: parent
            }
        }
        
        Rectangle {
            color: "transparent"
            height: units.gridUnit * .2
            Layout.fillWidth: true
            PlasmaComponents.Label {
                height: 1
                id: deviceString
                text: i18n(batteryPercent)
                anchors.centerIn: parent
            }
        }
        
        Rectangle {
            color: "transparent"
            height: units.gridUnit * .5
            Layout.fillWidth: true
            PlasmaComponents.Label {
                id: label_sidetone
                text: i18n("Set Sidetone")
                horizontalAlignment: Text.AlignCenter
            }
        }
        
        Rectangle {
            color: "transparent"
            height: units.gridUnit * .1
            Layout.fillWidth: true
            
            PlasmaComponents.Slider {
                id: toneSlider
                width: 150
                anchors.centerIn: parent
                orientation: Qt.Horizontal
                from: 0
                to: 128
                value: 0
                stepSize: 5

                onPressedChanged: {
                    cmd.exec("headsetcontrol -s" + toneSlider.value)
                }
            }
        }

        Rectangle {
            color: "transparent"
            height: units.gridUnit * .1
            Layout.fillWidth: true
            Layout.bottomMargin: 2
            PlasmaComponents.Label {
                id: sidetone_value
                height: 1
                anchors.centerIn: parent
                verticalAlignment: Text.AlignTop
                text: toneSlider.value
            }
        }
        
        PlasmaCore.DataSource {
            id: test
            engine: "executable"

            connectedSources: ["headsetcontrol -b |  grep -i found  | sed  's/Found //g' | tr -d '!'"]
            onNewData: {
                main.deviceName = data.stdout
            }
        }
            
        PlasmaCore.DataSource {
            id: whoami
            engine: "executable"

            connectedSources: ["headsetcontrol -b |  grep -i battery"]
            onNewData: {
                main.batteryPercent = data.stdout
            }
            interval: 5000
        }
    }

    PlasmaCore.DataSource {
        id: cmd
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName)
        }

        function exec(cmdstr) {
            connectSource(cmdstr)
        }

        signal exited(int exitCode, int exitStatus, string stdout, string stderr)
    }

    Plasmoid.toolTipSubText: {
        "Headset Configuration"
    }
}

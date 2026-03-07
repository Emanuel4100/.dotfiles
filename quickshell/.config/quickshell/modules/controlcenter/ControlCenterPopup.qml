import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    visible: false 
    
    anchors.top: true
    anchors.right: true
    margins.top: 55
    margins.right: 12
    implicitWidth: 320
    implicitHeight: 280
    color: "transparent"

    // Process Commands (Now with built-in visual desktop notifications!)
    Process { id: cmdWlogout; command: ["wlogout"] }
    Process { id: cmdNet; command: ["nm-connection-editor"] } 
    Process { id: cmdBt; command: ["blueman-manager"] } 
    Process { 
        id: cmdPower 
        command: ["bash", "-c", "current=$(powerprofilesctl get); if [ \"$current\" = \"balanced\" ]; then next=\"performance\"; elif [ \"$current\" = \"performance\" ]; then next=\"power-saver\"; else next=\"balanced\"; fi; powerprofilesctl set $next; notify-send -u low 'Power Profile' \"Set to $next\""] 
    }
    Process { id: cmdVolUp; command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low 'Volume Up' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}')%\""] }
    Process { id: cmdVolDown; command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low 'Volume Down' \"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}')%\""] }
    Process { id: cmdVolMute; command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -h string:x-canonical-private-synchronous:sys-notify -u low 'Audio Muted/Unmuted'"] }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        border.color: "#cba6f7" // Unified Border
        border.width: 2
        radius: 16

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            Text { 
                text: "Control Center"
                color: "#cdd6f4"
                font.bold: true 
                font.pixelSize: 18
                Layout.alignment: Qt.AlignLeft
            }

            GridLayout {
                columns: 2
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true

                // Wi-Fi
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 60; radius: 12
                    color: netArea.containsMouse ? "#45475a" : "#313244"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: ""; color: "#cba6f7"; font.pixelSize: 20 } // Unified Color
                        Text { text: "Wi-Fi"; color: "#cdd6f4"; font.bold: true; font.pixelSize: 14; Layout.fillWidth: true }
                    }
                    MouseArea { id: netArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdNet.startDetached() }
                }

                // Bluetooth
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 60; radius: 12
                    color: btArea.containsMouse ? "#45475a" : "#313244"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: ""; color: "#cba6f7"; font.pixelSize: 20 } // Unified Color
                        Text { text: "Bluetooth"; color: "#cdd6f4"; font.bold: true; font.pixelSize: 14; Layout.fillWidth: true }
                    }
                    MouseArea { id: btArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdBt.startDetached() }
                }

                // Power Profile (Renamed!)
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 60; radius: 12
                    color: pwrArea.containsMouse ? "#45475a" : "#313244"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: ""; color: "#cba6f7"; font.pixelSize: 20 } // Unified Color
                        Text { text: "Power Profile"; color: "#cdd6f4"; font.bold: true; font.pixelSize: 13; Layout.fillWidth: true }
                    }
                    MouseArea { id: pwrArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdPower.startDetached() }
                }
                
                // Session
                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 60; radius: 12
                    color: sysArea.containsMouse ? "#45475a" : "#313244"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10
                        Text { text: ""; color: "#cba6f7"; font.pixelSize: 20 } // Unified Color
                        Text { text: "Session"; color: "#cdd6f4"; font.bold: true; font.pixelSize: 14; Layout.fillWidth: true }
                    }
                    MouseArea { id: sysArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdWlogout.startDetached() }
                }
            }

            // Volume Controller
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 50
                radius: 12
                color: "#313244"
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    Text { 
                        text: volMuteArea.containsMouse ? "󰝟" : ""
                        color: "#cba6f7" // Unified Color
                        font.pixelSize: 22 
                        MouseArea { id: volMuteArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdVolMute.startDetached() }
                    }
                    
                    Rectangle {
                        implicitWidth: 30; implicitHeight: 30; radius: 6; color: volDownArea.containsMouse ? "#45475a" : "#1e1e2e"
                        Text { anchors.centerIn: parent; text: "−"; color: "#cdd6f4"; font.pixelSize: 18; font.bold: true }
                        MouseArea { id: volDownArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdVolDown.startDetached() }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        implicitWidth: 30; implicitHeight: 30; radius: 6; color: volUpArea.containsMouse ? "#45475a" : "#1e1e2e"
                        Text { anchors.centerIn: parent; text: "+"; color: "#cdd6f4"; font.pixelSize: 18; font.bold: true }
                        MouseArea { id: volUpArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdVolUp.startDetached() }
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: mediaRoot
    color: "#1e1e2e"
    radius: 18
    implicitHeight: 36
    implicitWidth: mediaLayout.implicitWidth + 32

    // Media Commands
    Process { id: prevCmd; command: ["playerctl", "previous"] }
    Process { id: playCmd; command: ["playerctl", "play-pause"] }
    Process { id: nextCmd; command: ["playerctl", "next"] }

    RowLayout {
        id: mediaLayout
        anchors.centerIn: parent
        spacing: 12

        // Unified Mauve Spotify/Music Icon
        Text { text: "󰓇"; color: "#cba6f7"; font.pixelSize: 18 } 
        
        // Separator
        Rectangle { width: 2; height: 16; color: "#313244"; radius: 1 } 

        // Controls
        Text { 
            text: "󰒮"
            color: prevArea.containsMouse ? "#cba6f7" : "#cdd6f4"
            font.pixelSize: 18; Behavior on color { ColorAnimation { duration: 150 } }
            MouseArea { id: prevArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: prevCmd.startDetached() } 
        }
        Text { 
            text: "󰐊"
            color: playArea.containsMouse ? "#cba6f7" : "#cdd6f4"
            font.pixelSize: 18; Behavior on color { ColorAnimation { duration: 150 } }
            MouseArea { id: playArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: playCmd.startDetached() } 
        }
        Text { 
            text: "󰒭"
            color: nextArea.containsMouse ? "#cba6f7" : "#cdd6f4"
            font.pixelSize: 18; Behavior on color { ColorAnimation { duration: 150 } }
            MouseArea { id: nextArea; hoverEnabled: true; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: nextCmd.startDetached() } 
        }
    }
}

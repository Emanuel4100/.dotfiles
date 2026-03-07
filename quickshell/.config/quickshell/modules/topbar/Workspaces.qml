import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
    color: "#1e1e2e" // Dark pill background
    radius: 18       // Material rounded edges
    implicitHeight: 36
    implicitWidth: layout.implicitWidth + 24 // Extra padding

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        // Dynamic Workspaces
        Row {
            spacing: 6
            Repeater {
                model: 10
                Rectangle {
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === (index + 1))
                    
                    visible: (index < 3) || hasWindows || isActive
                    height: 24
                    radius: 12
                    width: isActive ? 36 : 24
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutExpo } }
                    
                    color: isActive ? "#cba6f7" : (hasWindows ? "#45475a" : "transparent")
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: isActive ? "#11111b" : "#cdd6f4"
                        font.bold: true
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }
        }

        // Separator Line
        Rectangle { width: 2; height: 16; color: "#313244"; radius: 1 }

        // Window Title
        Text {
            text: Hyprland.activeWindow ? Hyprland.activeWindow.title : "Desktop"
            color: "#cdd6f4"
            font.pixelSize: 14
            font.bold: true
            Layout.maximumWidth: 300
            elide: Text.ElideRight // Cuts off extremely long titles cleanly
        }
    }
}

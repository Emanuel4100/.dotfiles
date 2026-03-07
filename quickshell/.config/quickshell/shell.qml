import QtQuick
import QtQuick.Layouts
import QtQuick.Controls // Required for the Calendar components
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io // Required to execute shell commands

ShellRoot {
    id: root

    // ==========================================
    // SHELL COMMANDS (Right Area Triggers)
    // ==========================================
    Process { id: cmdWlogout; command: ["wlogout"] }
    Process { id: cmdNet; command: ["nm-connection-editor"] } // Replace with your preferred network GUI
    Process { id: cmdBt; command: ["blueman-manager"] } // Replace with your preferred BT GUI
    // Process { id: cmdPower; command: ["your-power-profile-script"] } 

    // ==========================================
    // MAIN TOP BAR
    // ==========================================
    PanelWindow {
        id: topbar
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 38
        color: "#1e1e2e" // Catppuccin Mocha Background

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            spacing: 0

            // ==========================================
            // LEFT: DYNAMIC WORKSPACES
            // ==========================================
            Row {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: 8

                Repeater {
                    model: 10 // Max workspaces to check

                    Rectangle {
                        // Core Logic: Is it active? Does it exist?
                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                        property bool hasWindows: Hyprland.workspaces.values.some(w => w.id === (index + 1))

                        // Dynamic Visibility: Always show 1, 2, 3. Show others ONLY if occupied or active.
                        visible: (index < 3) || hasWindows || isActive

                        height: 24
                        radius: 12
                        
                        // Animation: Expand width when active
                        width: isActive ? 40 : 24
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
                        
                        // Animation: Smooth color transitions
                        color: isActive ? "#89b4fa" : (hasWindows ? "#45475a" : "#313244")
                        Behavior on color { ColorAnimation { duration: 200 } }

                        Text {
                            anchors.centerIn: parent
                            text: index + 1
                            color: isActive ? "#1e1e2e" : "#cdd6f4"
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

            // ==========================================
            // CENTER: CLOCK & CALENDAR TOGGLE
            // ==========================================
            Item {
                Layout.fillWidth: true
                
                Rectangle {
                    anchors.centerIn: parent
                    implicitWidth: clockText.width + 24
                    implicitHeight: 28
                    radius: 8
                    
                    // Hover effect background
                    color: clockMouseArea.containsMouse || calendarWindow.visible ? "#313244" : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        color: "#cdd6f4"
                        font.pixelSize: 14
                        font.bold: true

                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = new Date().toLocaleTimeString(Qt.locale(), "ddd, MMM d  •  HH:mm")
                        }
                        Component.onCompleted: clockText.text = new Date().toLocaleTimeString(Qt.locale(), "ddd, MMM d  •  HH:mm")
                    }

                    MouseArea {
                        id: clockMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        // Toggle the calendar window visibility
                        onClicked: calendarWindow.visible = !calendarWindow.visible
                    }
                }
            }

            // ==========================================
            // RIGHT: SYSTEM TRAY / BUTTONS
            // ==========================================
            Row {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 16

                // Power Profiles (Placeholder icon for now)
                Text { text: ""; color: "#f9e2af"; font.pixelSize: 18; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor } }
                
                // Bluetooth
                Text { text: ""; color: "#89b4fa"; font.pixelSize: 18; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdBt.start() } }
                
                // Network / Wi-Fi
                Text { text: ""; color: "#a6e3a1"; font.pixelSize: 18; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdNet.start() } }
                
                // Wlogout / Power Menu
                Text { text: ""; color: "#f38ba8"; font.pixelSize: 18; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: cmdWlogout.start() } }
            }
        }
    }

    // ==========================================
    // POPUP: CALENDAR WINDOW
    // ==========================================
    PanelWindow {
        id: calendarWindow
        visible: false // Hidden by default
        
        // In Wayland, anchoring to the top but NOT left/right automatically centers it
        anchors.top: true
        margins.top: 45        
        implicitWidth: 280
        implicitHeight: 310
        color: "#1e1e2e"

        // Outer border for the popup
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#89b4fa"
            border.width: 2
            radius: 12

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 10
                
                // Month & Year Header
                Text { 
                    text: new Date().toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    color: "#cdd6f4"
                    font.bold: true 
                    font.pixelSize: 18
                    Layout.alignment: Qt.AlignHCenter
                }

                // Days of the week (S, M, T, W, etc.)
                DayOfWeekRow {
                    locale: monthGrid.locale
                    Layout.fillWidth: true
                    delegate: Text {
                        text: model.shortName
                        color: "#89b4fa"
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // The actual number grid
                MonthGrid {
                    id: monthGrid
                    month: new Date().getMonth()
                    year: new Date().getFullYear()
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    delegate: Text {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: model.day
                        font.pixelSize: 14
                        // Highlight today's date in Red, current month in White, other months in Gray
                        color: model.today ? "#f38ba8" : (model.month === monthGrid.month ? "#cdd6f4" : "#45475a")
                        font.bold: model.today
                    }
                }
            }
        }
    }
}

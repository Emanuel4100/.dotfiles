import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: panel
    signal toggleCalendar()
    signal toggleControlCenter() 

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins.top: 8 
    implicitHeight: 40
    color: "transparent" 

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12 // Adds spacing between floating pills

        Workspaces { Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter }
        
        // ADDED: The Media Player Pill
        MediaPlayer { Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter }
        
        Item { Layout.fillWidth: true } 

        Clock { 
            Layout.alignment: Qt.AlignCenter | Qt.AlignVCenter 
            onClicked: panel.toggleCalendar() 
        }

        Item { Layout.fillWidth: true } 

        SystemTray { 
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter 
            onToggleControlCenter: panel.toggleControlCenter() 
        }
    }
}

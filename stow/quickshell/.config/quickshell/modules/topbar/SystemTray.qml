import QtQuick
import QtQuick.Layouts

Rectangle {
    id: trayRoot
    signal toggleControlCenter() // Tells the main shell to open the dropdown

    color: trayArea.containsMouse ? "#313244" : "#1e1e2e"
    radius: 18
    implicitHeight: 36
    implicitWidth: trayRow.implicitWidth + 32
    Behavior on color { ColorAnimation { duration: 150 } }

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 12

        // Unified Status Icons
        Text { text: ""; color: "#cdd6f4"; font.pixelSize: 16 }
        Text { text: ""; color: "#cdd6f4"; font.pixelSize: 16 }
        Text { text: ""; color: "#cdd6f4"; font.pixelSize: 16 }
        Text { text: ""; color: "#cdd6f4"; font.pixelSize: 16 }
    }

    MouseArea {
        id: trayArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: trayRoot.toggleControlCenter()
    }
}

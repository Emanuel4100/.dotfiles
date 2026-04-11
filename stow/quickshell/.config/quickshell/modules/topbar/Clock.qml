import QtQuick

Rectangle {
    id: clockRoot
    signal clicked() 

    color: "#1e1e2e" 
    radius: 18
    implicitHeight: 36
    implicitWidth: clockText.width + 32

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: clockMouseArea.containsMouse ? "#313244" : "transparent"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        color: "#cdd6f4"
        font.pixelSize: 14
        font.bold: true

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: clockText.text = new Date().toLocaleString(Qt.locale(), "ddd, MMM d  •  HH:mm")
        }
        Component.onCompleted: clockText.text = new Date().toLocaleString(Qt.locale(), "ddd, MMM d  •  HH:mm")
    }

    MouseArea {
        id: clockMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clockRoot.clicked()
    }
}

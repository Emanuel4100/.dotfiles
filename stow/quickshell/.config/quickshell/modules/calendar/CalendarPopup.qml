import QtQuick
import QtQuick.Layouts
import QtQuick.Controls 
import Quickshell

PanelWindow {
    visible: false 
    
    anchors.top: true
    margins.top: 55 // Drops down perfectly below the floating clock      
    implicitWidth: 280
    implicitHeight: 310
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        border.color: "#cba6f7"
        border.width: 2
        radius: 16

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            
            Text { 
                text: new Date().toLocaleDateString(Qt.locale(), "MMMM yyyy")
                color: "#cdd6f4"
                font.bold: true 
                font.pixelSize: 18
                Layout.alignment: Qt.AlignHCenter
            }

            DayOfWeekRow {
                locale: monthGrid.locale
                Layout.fillWidth: true
                delegate: Text {
                    text: model.shortName
                    color: "#cba6f7"
                    font.bold: true
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                }
            }

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
                    color: model.today ? "#f38ba8" : (model.month === monthGrid.month ? "#cdd6f4" : "#45475a")
                    font.bold: model.today
                }
            }
        }
    }
}

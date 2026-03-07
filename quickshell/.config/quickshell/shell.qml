import QtQuick
import Quickshell
import "modules/topbar"
import "modules/calendar"
import "modules/controlcenter" // Import the new folder

ShellRoot {
    id: root

    TopBar {
        onToggleCalendar: calendarWindow.visible = !calendarWindow.visible
        // Toggle the control center when the right pill is clicked!
        onToggleControlCenter: controlCenterWindow.visible = !controlCenterWindow.visible 
    }

    CalendarPopup {
        id: calendarWindow
    }

    ControlCenterPopup {
        id: controlCenterWindow
    }
}

#Requires AutoHotkey v2.0

#Include <stdlib\calendar>

calendar_example_is_leap := stdlib.calendar.isleap(2024)
calendar_example_february := stdlib.calendar.monthrange(2024, 2)
calendar_example_weeks := stdlib.calendar.monthcalendar(2024, 2)

stdlib.calendar.setfirstweekday(stdlib.calendar.SUNDAY)
try {
    calendar_example_sunday_first := stdlib.calendar.monthcalendar(2024, 2)
} finally {
    stdlib.calendar.setfirstweekday(stdlib.calendar.MONDAY)
}

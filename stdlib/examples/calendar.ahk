#Requires AutoHotkey v2.0

#Include <stdlib\calendar>

calendar_example_is_leap := stdlib.calendar.isleap(2024)
calendar_example_february := stdlib.calendar.monthrange(2024, 2)
calendar_example_weeks := stdlib.calendar.monthcalendar(2024, 2)
calendar_example_header := stdlib.calendar.weekheader(2)
calendar_example_epoch := stdlib.calendar.timegm([1970, 1, 1, 0, 0, 0])
calendar_example_names := [stdlib.calendar.day_name[0], stdlib.calendar.month_name[2]]
calendar_example_calendar := stdlib.calendar.Calendar(stdlib.calendar.SUNDAY)
calendar_example_iterweekdays := []
for weekday in calendar_example_calendar.iterweekdays()
    calendar_example_iterweekdays.Push(weekday)
calendar_example_calendar_weeks := calendar_example_calendar.monthdayscalendar(2024, 2)

stdlib.calendar.setfirstweekday(stdlib.calendar.SUNDAY)
try {
    calendar_example_sunday_first := stdlib.calendar.monthcalendar(2024, 2)
} finally {
    stdlib.calendar.setfirstweekday(stdlib.calendar.MONDAY)
}

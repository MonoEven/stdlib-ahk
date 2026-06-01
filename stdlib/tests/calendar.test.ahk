#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\calendar>

class StdlibCalendarTest
{
    static TestConstantsAndLeapYearRulesFollowPythonCalendar()
    {
        AhkTest.AssertEqual(0, stdlib.calendar.MONDAY)
        AhkTest.AssertEqual(6, stdlib.calendar.SUNDAY)
        AhkTest.AssertEqual(1, stdlib.calendar.January)
        AhkTest.AssertEqual(2, stdlib.calendar.February)

        AhkTest.AssertTrue(stdlib.calendar.isleap(2000))
        AhkTest.AssertFalse(stdlib.calendar.isleap(1900))
        AhkTest.AssertTrue(stdlib.calendar.isleap(2024))
        AhkTest.AssertFalse(stdlib.calendar.isleap(2023))
    }

    static TestDateHelpersFollowPythonCalendar()
    {
        AhkTest.AssertEqual(2, stdlib.calendar.leapdays(2000, 2005))
        AhkTest.AssertEqual(1, stdlib.calendar.leapdays(2001, 2005))
        AhkTest.AssertEqual(3, stdlib.calendar.weekday(2024, 2, 29))
        AhkTest.AssertEqual(0, stdlib.calendar.weekday(2024, 1, 1))
        AhkTest.AssertEqual([3, 29], stdlib.calendar.monthrange(2024, 2))
        AhkTest.AssertEqual([6, 31], stdlib.calendar.monthrange(2023, 1))
        AhkTest.AssertEqual([5, 31], stdlib.calendar.monthrange(0, 1))
    }

    static TestMonthCalendarBuildsMondayFirstWeeks()
    {
        weeks := stdlib.calendar.monthcalendar(2024, 2)

        AhkTest.AssertEqual([0, 0, 0, 1, 2, 3, 4], weeks[1])
        AhkTest.AssertEqual([26, 27, 28, 29, 0, 0, 0], weeks[5])
    }

    static TestFirstWeekdayControlsMonthCalendar()
    {
        AhkTest.AssertEqual(stdlib.calendar.MONDAY, stdlib.calendar.firstweekday())

        stdlib.calendar.setfirstweekday(stdlib.calendar.SUNDAY)
        try {
            AhkTest.AssertEqual(stdlib.calendar.SUNDAY, stdlib.calendar.firstweekday())
            weeks := stdlib.calendar.monthcalendar(2024, 2)
            AhkTest.AssertEqual([0, 0, 0, 0, 1, 2, 3], weeks[1])
            AhkTest.RaisesMatch(
                stdlib.calendar.IllegalWeekdayError,
                "bad weekday number 7; must be 0 \(Monday\) to 6 \(Sunday\)",
                (*) => stdlib.calendar.setfirstweekday(7)
            )
        } finally {
            stdlib.calendar.setfirstweekday(stdlib.calendar.MONDAY)
        }
    }
}

AhkTest.Collect(StdlibCalendarTest)

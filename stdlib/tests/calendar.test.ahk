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

    static TestNamesTimegmWeekheaderAndCalendarClassMatchLocal310()
    {
        savedFirstWeekday := stdlib.calendar.firstweekday()
        try {
            stdlib.calendar.setfirstweekday(stdlib.calendar.MONDAY)
            AhkTest.AssertEqual("Mo Tu We Th Fr Sa Su", stdlib.calendar.weekheader(2))
            AhkTest.AssertEqual("Mon Tue Wed Thu Fri Sat Sun", stdlib.calendar.weekheader(3))
            stdlib.calendar.setfirstweekday(stdlib.calendar.SUNDAY)
            AhkTest.AssertEqual("Su Mo Tu We Th Fr Sa", stdlib.calendar.weekheader(2))
        } finally {
            stdlib.calendar.setfirstweekday(savedFirstWeekday)
        }

        AhkTest.AssertEqual(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], StdlibCalendarTest.Collect(stdlib.calendar.day_name))
        AhkTest.AssertEqual(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], StdlibCalendarTest.Collect(stdlib.calendar.day_abbr))
        AhkTest.AssertEqual("Sunday", stdlib.calendar.day_name[-1])
        AhkTest.AssertEqual("", stdlib.calendar.month_name[0])
        AhkTest.AssertEqual("December", stdlib.calendar.month_name[-1])
        AhkTest.AssertEqual(["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"], StdlibCalendarTest.Collect(stdlib.calendar.month_abbr))

        AhkTest.AssertEqual(0, stdlib.calendar.timegm([1970, 1, 1, 0, 0, 0]))
        AhkTest.AssertEqual(1709168523, stdlib.calendar.timegm([2024, 2, 29, 1, 2, 3]))

        cal := stdlib.calendar.Calendar()
        sundayCal := stdlib.calendar.Calendar(stdlib.calendar.SUNDAY)
        AhkTest.AssertEqual(stdlib.calendar.MONDAY, cal.firstweekday)
        AhkTest.AssertEqual(stdlib.calendar.SUNDAY, sundayCal.getfirstweekday())
        AhkTest.AssertEqual([0, 1, 2, 3, 4, 5, 6], StdlibCalendarTest.Collect(cal.iterweekdays()))
        AhkTest.AssertEqual([6, 0, 1, 2, 3, 4, 5], StdlibCalendarTest.Collect(sundayCal.iterweekdays()))

        days := StdlibCalendarTest.Collect(cal.itermonthdays(2024, 2))
        days2 := StdlibCalendarTest.Collect(cal.itermonthdays2(2024, 2))
        days3 := StdlibCalendarTest.Collect(cal.itermonthdays3(2024, 2))
        days4 := StdlibCalendarTest.Collect(cal.itermonthdays4(2024, 2))

        AhkTest.AssertEqual(35, days.Length)
        AhkTest.AssertEqual([0, 0, 0, 1, 2, 3, 4, 5], StdlibCalendarTest.First(days, 8))
        AhkTest.AssertEqual([25, 26, 27, 28, 29, 0, 0, 0], StdlibCalendarTest.Last(days, 8))
        AhkTest.AssertEqual([[0, 0], [0, 1], [0, 2], [1, 3]], StdlibCalendarTest.First(days2, 4))
        AhkTest.AssertEqual([[2024, 1, 29], [2024, 1, 30], [2024, 1, 31], [2024, 2, 1]], StdlibCalendarTest.First(days3, 4))
        AhkTest.AssertEqual([[2024, 1, 29, 0], [2024, 1, 30, 1], [2024, 1, 31, 2], [2024, 2, 1, 3]], StdlibCalendarTest.First(days4, 4))

        AhkTest.AssertEqual(stdlib.calendar.monthcalendar(2024, 2), cal.monthdayscalendar(2024, 2))
        AhkTest.AssertEqual([[0, 0, 0, 0, 1, 2, 3], [4, 5, 6, 7, 8, 9, 10], [11, 12, 13, 14, 15, 16, 17], [18, 19, 20, 21, 22, 23, 24], [25, 26, 27, 28, 29, 0, 0]], sundayCal.monthdayscalendar(2024, 2))
        AhkTest.AssertEqual([[[0, 0], [0, 1], [0, 2], [1, 3], [2, 4], [3, 5], [4, 6]], [[5, 0], [6, 1], [7, 2], [8, 3], [9, 4], [10, 5], [11, 6]], [[12, 0], [13, 1], [14, 2], [15, 3], [16, 4], [17, 5], [18, 6]], [[19, 0], [20, 1], [21, 2], [22, 3], [23, 4], [24, 5], [25, 6]], [[26, 0], [27, 1], [28, 2], [29, 3], [0, 4], [0, 5], [0, 6]]], cal.monthdays2calendar(2024, 2))
    }

    static Collect(iterable)
    {
        values := []
        for value in iterable
            values.Push(value)
        return values
    }

    static First(values, count)
    {
        result := []
        loop count
            result.Push(values[A_Index])
        return result
    }

    static Last(values, count)
    {
        result := []
        start := values.Length - count + 1
        loop count
            result.Push(values[start + A_Index - 1])
        return result
    }
}

AhkTest.Collect(StdlibCalendarTest)

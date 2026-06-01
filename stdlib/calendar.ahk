#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCalendarIllegalMonthError extends ValueError
{
    __New(month)
    {
        this.month := month
        super.__New("bad month number " month "; must be 1-12", -1)
    }
}

class AhkStdlibCalendarIllegalWeekdayError extends ValueError
{
    __New(weekday)
    {
        this.weekday := weekday
        super.__New("bad weekday number " weekday "; must be 0 (Monday) to 6 (Sunday)", -1)
    }
}

class AhkStdlibCalendar
{
    static _FirstWeekday := 0
    static MONDAY := 0
    static TUESDAY := 1
    static WEDNESDAY := 2
    static THURSDAY := 3
    static FRIDAY := 4
    static SATURDAY := 5
    static SUNDAY := 6
    static January := 1
    static February := 2
    static IllegalMonthError := AhkStdlibCalendarIllegalMonthError
    static IllegalWeekdayError := AhkStdlibCalendarIllegalWeekdayError

    static isleap(year)
    {
        return Mod(year, 4) = 0 && (Mod(year, 100) != 0 || Mod(year, 400) = 0)
    }

    static leapdays(year1, year2)
    {
        return AhkStdlibCalendarLeapsBefore(year2) - AhkStdlibCalendarLeapsBefore(year1)
    }

    static firstweekday()
    {
        return this._FirstWeekday
    }

    static setfirstweekday(firstweekday)
    {
        if firstweekday < this.MONDAY || firstweekday > this.SUNDAY
            throw AhkStdlibCalendarIllegalWeekdayError(firstweekday)
        this._FirstWeekday := firstweekday
    }

    static weekday(year, month, day)
    {
        AhkStdlibCalendarCheckMonth(month)
        AhkStdlibCalendarCheckDay(year, month, day)
        return AhkStdlibCalendarPythonMod(
            AhkStdlibCalendarDaysBeforeYear(year)
            + AhkStdlibCalendarDaysBeforeMonth(year, month)
            + day - 1,
            7
        )
    }

    static monthrange(year, month)
    {
        AhkStdlibCalendarCheckMonth(month)
        return [this.weekday(year, month, 1), AhkStdlibCalendarMonthLength(year, month)]
    }

    static monthcalendar(year, month)
    {
        range := this.monthrange(year, month)
        firstWeekday := range[1]
        daysInMonth := range[2]
        weeks := []
        week := [0, 0, 0, 0, 0, 0, 0]
        position := AhkStdlibCalendarPythonMod(firstWeekday - this._FirstWeekday, 7) + 1

        loop daysInMonth {
            day := A_Index
            week[position] := day
            if position = 7 {
                weeks.Push(week)
                week := [0, 0, 0, 0, 0, 0, 0]
                position := 1
            } else {
                position += 1
            }
        }

        if position != 1
            weeks.Push(week)

        return weeks
    }
}

stdlib.calendar := AhkStdlibCalendar

AhkStdlibCalendarMonthLength(year, month)
{
    if month = 2
        return AhkStdlibCalendar.isleap(year) ? 29 : 28
    return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month]
}

AhkStdlibCalendarDaysBeforeMonth(year, month)
{
    total := 0
    loop month - 1
        total += AhkStdlibCalendarMonthLength(year, A_Index)
    return total
}

AhkStdlibCalendarDaysBeforeYear(year)
{
    previous := year - 1
    return previous * 365
        + AhkStdlibCalendarFloorDiv(previous, 4)
        - AhkStdlibCalendarFloorDiv(previous, 100)
        + AhkStdlibCalendarFloorDiv(previous, 400)
}

AhkStdlibCalendarLeapsBefore(year)
{
    previous := year - 1
    return AhkStdlibCalendarFloorDiv(previous, 4)
        - AhkStdlibCalendarFloorDiv(previous, 100)
        + AhkStdlibCalendarFloorDiv(previous, 400)
}

AhkStdlibCalendarCheckMonth(month)
{
    if month < 1 || month > 12
        throw AhkStdlibCalendarIllegalMonthError(month)
}

AhkStdlibCalendarCheckDay(year, month, day)
{
    if day < 1 || day > AhkStdlibCalendarMonthLength(year, month)
        throw ValueError("day is out of range for month", -1)
}

AhkStdlibCalendarFloorDiv(value, divisor)
{
    return Floor(value / divisor)
}

AhkStdlibCalendarPythonMod(value, divisor)
{
    return value - divisor * AhkStdlibCalendarFloorDiv(value, divisor)
}

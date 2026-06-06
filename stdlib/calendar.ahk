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

class AhkStdlibCalendarNameSequence
{
    __New(values)
    {
        this.Values := values
    }

    Length
    {
        get => this.Values.Length
    }

    __Item[index]
    {
        get {
            if !(index is Integer)
                throw TypeError("list indices must be integers or slices, not " AhkStdlibPythonTypeName(index), -1)
            if index < 0
                index += this.Values.Length
            if index < 0 || index >= this.Values.Length
                throw IndexError("list index out of range", -1)
            return this.Values[index + 1]
        }
    }

    __Enum(numberOfVars)
    {
        return this.Values.__Enum(numberOfVars)
    }
}

class AhkStdlibCalendarCalendar
{
    __New(firstweekday := 0)
    {
        AhkStdlibCalendarCheckWeekday(firstweekday)
        this.firstweekday := firstweekday
    }

    getfirstweekday()
    {
        return this.firstweekday
    }

    iterweekdays()
    {
        weekdays := []
        loop 7
            weekdays.Push(AhkStdlibCalendarPythonMod(this.firstweekday + A_Index - 1, 7))
        return weekdays
    }

    itermonthdays(year, month)
    {
        values := []
        for cell in AhkStdlibCalendarMonthCells(year, month, this.firstweekday)
            values.Push(cell.month = month ? cell.day : 0)
        return values
    }

    itermonthdays2(year, month)
    {
        values := []
        for cell in AhkStdlibCalendarMonthCells(year, month, this.firstweekday)
            values.Push([cell.month = month ? cell.day : 0, cell.weekday])
        return values
    }

    itermonthdays3(year, month)
    {
        values := []
        for cell in AhkStdlibCalendarMonthCells(year, month, this.firstweekday)
            values.Push([cell.year, cell.month, cell.day])
        return values
    }

    itermonthdays4(year, month)
    {
        values := []
        for cell in AhkStdlibCalendarMonthCells(year, month, this.firstweekday)
            values.Push([cell.year, cell.month, cell.day, cell.weekday])
        return values
    }

    monthdayscalendar(year, month)
    {
        return AhkStdlibCalendarMonthCalendar(year, month, this.firstweekday)
    }

    monthdays2calendar(year, month)
    {
        return AhkStdlibCalendarGroupWeeks(this.itermonthdays2(year, month))
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
    static Calendar
    {
        get => AhkStdlibCalendarCalendar
    }

    static Calendar(args*)
    {
        return AhkStdlibCalendarCalendar(args*)
    }

    static day_name := AhkStdlibCalendarNameSequence(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
    static day_abbr := AhkStdlibCalendarNameSequence(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
    static month_name := AhkStdlibCalendarNameSequence(["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"])
    static month_abbr := AhkStdlibCalendarNameSequence(["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"])

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
        AhkStdlibCalendarCheckWeekday(firstweekday)
        this._FirstWeekday := firstweekday
    }

    static weekheader(width)
    {
        return AhkStdlibCalendarWeekHeader(width, this._FirstWeekday)
    }

    static timegm(timeTuple)
    {
        values := AhkStdlibCalendarSequenceToArray(timeTuple)
        year := values[1]
        month := values[2]
        day := values[3]
        hour := values[4]
        minute := values[5]
        second := values[6]
        return (AhkStdlibCalendarDaysBeforeYear(year)
            + AhkStdlibCalendarDaysBeforeMonth(year, month)
            + day
            - AhkStdlibCalendarUnixEpochOrdinal()) * 86400
            + hour * 3600
            + minute * 60
            + second
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
        return AhkStdlibCalendarMonthCalendar(year, month, this._FirstWeekday)
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

AhkStdlibCalendarCheckWeekday(weekday)
{
    if weekday < AhkStdlibCalendar.MONDAY || weekday > AhkStdlibCalendar.SUNDAY
        throw AhkStdlibCalendarIllegalWeekdayError(weekday)
}

AhkStdlibCalendarCheckDay(year, month, day)
{
    if day < 1 || day > AhkStdlibCalendarMonthLength(year, month)
        throw ValueError("day is out of range for month", -1)
}

AhkStdlibCalendarMonthCalendar(year, month, firstWeekdaySetting)
{
    weeks := []
    week := []
    for day in AhkStdlibCalendarCalendar(firstWeekdaySetting).itermonthdays(year, month) {
        week.Push(day)
        if week.Length = 7 {
            weeks.Push(week)
            week := []
        }
    }
    return weeks
}

AhkStdlibCalendarMonthCells(year, month, firstWeekdaySetting)
{
    AhkStdlibCalendarCheckMonth(month)
    monthStartWeekday := AhkStdlibCalendar.weekday(year, month, 1)
    daysInMonth := AhkStdlibCalendarMonthLength(year, month)
    daysBefore := AhkStdlibCalendarPythonMod(monthStartWeekday - firstWeekdaySetting, 7)
    totalCells := Ceil((daysBefore + daysInMonth) / 7) * 7
    cells := []

    loop totalCells {
        ordinalDay := A_Index - daysBefore
        weekday := AhkStdlibCalendarPythonMod(firstWeekdaySetting + A_Index - 1, 7)
        if ordinalDay < 1 {
            prev := AhkStdlibCalendarPreviousMonth(year, month)
            day := AhkStdlibCalendarMonthLength(prev.year, prev.month) + ordinalDay
            cells.Push({ year: prev.year, month: prev.month, day: day, weekday: weekday })
        } else if ordinalDay > daysInMonth {
            next := AhkStdlibCalendarNextMonth(year, month)
            cells.Push({ year: next.year, month: next.month, day: ordinalDay - daysInMonth, weekday: weekday })
        } else {
            cells.Push({ year: year, month: month, day: ordinalDay, weekday: weekday })
        }
    }

    return cells
}

AhkStdlibCalendarPreviousMonth(year, month)
{
    if month = 1
        return { year: year - 1, month: 12 }
    return { year: year, month: month - 1 }
}

AhkStdlibCalendarNextMonth(year, month)
{
    if month = 12
        return { year: year + 1, month: 1 }
    return { year: year, month: month + 1 }
}

AhkStdlibCalendarGroupWeeks(values)
{
    weeks := []
    week := []
    for value in values {
        week.Push(value)
        if week.Length = 7 {
            weeks.Push(week)
            week := []
        }
    }
    return weeks
}

AhkStdlibCalendarWeekHeader(width, firstweekday)
{
    parts := []
    for weekday in AhkStdlibCalendarCalendar(firstweekday).iterweekdays()
        parts.Push(SubStr(AhkStdlibCalendar.day_abbr[weekday], 1, width))
    return AhkStdlibCalendarJoin(parts, " ")
}

AhkStdlibCalendarSequenceToArray(sequence)
{
    values := []
    if sequence is Array {
        for value in sequence
            values.Push(value)
    } else if IsObject(sequence) && HasMethod(sequence, "__Enum") {
        for value in sequence
            values.Push(value)
    } else {
        throw TypeError("'" AhkStdlibPythonTypeName(sequence) "' object is not iterable", -1)
    }

    if values.Length < 6
        throw TypeError("time tuple must be a sequence with at least 6 values", -1)
    return values
}

AhkStdlibCalendarUnixEpochOrdinal()
{
    return AhkStdlibCalendarDaysBeforeYear(1970) + 1
}

AhkStdlibCalendarJoin(values, separator)
{
    result := ""
    for index, value in values {
        if index > 1
            result .= separator
        result .= value
    }
    return result
}

AhkStdlibCalendarFloorDiv(value, divisor)
{
    return Floor(value / divisor)
}

AhkStdlibCalendarPythonMod(value, divisor)
{
    return value - divisor * AhkStdlibCalendarFloorDiv(value, divisor)
}

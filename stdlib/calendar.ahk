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

    static TextCalendar
    {
        get => AhkStdlibCalendarTextCalendar
    }

    static TextCalendar(args*)
    {
        return AhkStdlibCalendarTextCalendar(args*)
    }

    static HTMLCalendar
    {
        get => AhkStdlibCalendarHTMLCalendar
    }

    static HTMLCalendar(args*)
    {
        return AhkStdlibCalendarHTMLCalendar(args*)
    }

    static month(theyear, themonth, w := 0, l := 0)
    {
        return AhkStdlibCalendarTextCalendar(this._FirstWeekday).formatmonth(theyear, themonth, w, l)
    }

    static prmonth(theyear, themonth, w := 0, l := 0)
    {
        FileAppend(this.month(theyear, themonth, w, l), "*")
        return stdlib.None
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

; ---------------------------------------------------------------------------
; TextCalendar — produces month/year strings byte-for-byte matching CPython.
; Algorithm mirrors Lib/calendar.py: formatmonth uses 7*(w+1)-1 column width,
; centers the month name, then rstrips each line.
; ---------------------------------------------------------------------------

class AhkStdlibCalendarTextCalendar extends AhkStdlibCalendarCalendar
{
    formatday(day, weekday, width)
    {
        if day = 0
            s := ""
        else
            s := String(day)
        return AhkStdlibCalendarRJust(s, width)
    }

    formatweek(theweek, width)
    {
        parts := []
        for entry in theweek
            parts.Push(this.formatday(entry[1], entry[2], width))
        return AhkStdlibCalendarJoin(parts, " ")
    }

    formatweekday(day, width)
    {
        if width >= 9
            names := AhkStdlibCalendar.day_name
        else
            names := AhkStdlibCalendar.day_abbr
        return AhkStdlibCalendarCenter(SubStr(names[day], 1, width), width)
    }

    formatweekheader(width)
    {
        parts := []
        for weekday in this.iterweekdays()
            parts.Push(this.formatweekday(weekday, width))
        return AhkStdlibCalendarJoin(parts, " ")
    }

    formatmonthname(theyear, themonth, width, withyear := true)
    {
        if withyear
            s := AhkStdlibCalendar.month_name[themonth] " " String(theyear)
        else
            s := AhkStdlibCalendar.month_name[themonth]
        return AhkStdlibCalendarCenter(s, width)
    }

    formatmonth(theyear, themonth, w := 0, l := 0)
    {
        w := Max(2, w)
        l := Max(1, l)
        ; Header line: month name centered then rstripped (matches CPython).
        s := AhkStdlibCalendarRStrip(this.formatmonthname(theyear, themonth, 7 * (w + 1) - 1))
        s .= AhkStdlibCalendarRepeat("`n", l)
        s .= AhkStdlibCalendarRStrip(this.formatweekheader(w))
        s .= AhkStdlibCalendarRepeat("`n", l)
        for week in this.monthdays2calendar(theyear, themonth) {
            s .= AhkStdlibCalendarRStrip(this.formatweek(week, w))
            s .= AhkStdlibCalendarRepeat("`n", l)
        }
        return s
    }

    formatyear(theyear, w := 2, l := 1, c := 6, m := 3)
    {
        w := Max(2, w)
        l := Max(1, l)
        c := Max(2, c)
        ; Per CPython: header = year centered in colwidth*m + c*(m-1)
        colwidth := (w + 1) * 7 - 1
        v := []
        a := []
        a.Push(AhkStdlibCalendarRepeat(" ", colwidth * m + c * (m - 1)))
        ; rstripped year header centered then padded; CPython uses .rstrip on appended block lines
        header := AhkStdlibCalendarCenter(String(theyear), colwidth * m + c * (m - 1))
        s := AhkStdlibCalendarRStrip(header) AhkStdlibCalendarRepeat("`n", l * 2)
        ; Iterate months in groups of m
        for monthRow in AhkStdlibCalendarChunkRange(12, m) {
            ; Month name row
            names := []
            for monthIdx in monthRow
                names.Push(AhkStdlibCalendarCenter(AhkStdlibCalendar.month_name[monthIdx], colwidth))
            s .= AhkStdlibCalendarRStrip(AhkStdlibCalendarJoin(names, AhkStdlibCalendarRepeat(" ", c)))
            s .= AhkStdlibCalendarRepeat("`n", l)
            ; Header row (weekdays)
            headers := []
            for monthIdx in monthRow
                headers.Push(this.formatweekheader(w))
            s .= AhkStdlibCalendarRStrip(AhkStdlibCalendarJoin(headers, AhkStdlibCalendarRepeat(" ", c)))
            s .= AhkStdlibCalendarRepeat("`n", l)
            ; Week rows: align each month's weeks side-by-side
            monthsWeeks := []
            maxWeeks := 0
            for monthIdx in monthRow {
                weeks := this.monthdays2calendar(theyear, monthIdx)
                monthsWeeks.Push(weeks)
                if weeks.Length > maxWeeks
                    maxWeeks := weeks.Length
            }
            loop maxWeeks {
                weekIdx := A_Index
                rowParts := []
                for weeks in monthsWeeks {
                    if weekIdx <= weeks.Length
                        rowParts.Push(this.formatweek(weeks[weekIdx], w))
                    else
                        rowParts.Push(AhkStdlibCalendarRepeat(" ", colwidth))
                }
                s .= AhkStdlibCalendarRStrip(AhkStdlibCalendarJoin(rowParts, AhkStdlibCalendarRepeat(" ", c)))
                s .= AhkStdlibCalendarRepeat("`n", l)
            }
        }
        return s
    }

    pryear(theyear, w := 0, l := 0, c := 6, m := 3)
    {
        FileAppend(this.formatyear(theyear, w, l, c, m), "*")
        return stdlib.None
    }

    prmonth(theyear, themonth, w := 0, l := 0)
    {
        FileAppend(this.formatmonth(theyear, themonth, w, l), "*")
        return stdlib.None
    }
}

; ---------------------------------------------------------------------------
; HTMLCalendar — best-effort table output matching Python's tag layout.
; ---------------------------------------------------------------------------

class AhkStdlibCalendarHTMLCalendar extends AhkStdlibCalendarCalendar
{
    static cssclasses := ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    static cssclass_noday := "noday"
    static cssclass_month_head := "month"
    static cssclass_month := "month"
    static cssclass_year := "year"
    static cssclass_year_head := "year"

    formatday(day, weekday)
    {
        if day = 0
            return '<td class="' AhkStdlibCalendarHTMLCalendar.cssclass_noday '">&nbsp;</td>'
        return '<td class="' AhkStdlibCalendarHTMLCalendar.cssclasses[weekday + 1] '">' day '</td>'
    }

    formatweek(theweek)
    {
        s := "<tr>"
        for entry in theweek
            s .= this.formatday(entry[1], entry[2])
        s .= "</tr>"
        return s
    }

    formatweekday(day)
    {
        ; day is 0..6 (Mon..Sun); cssclasses is an AHK Array (1-indexed) so use
        ; day+1, but day_abbr is a NameSequence with Python 0-indexing.
        return '<th class="' AhkStdlibCalendarHTMLCalendar.cssclasses[day + 1] '">' AhkStdlibCalendar.day_abbr[day] '</th>'
    }

    formatweekheader()
    {
        s := "<tr>"
        for d in this.iterweekdays()
            s .= this.formatweekday(d)
        s .= "</tr>"
        return s
    }

    formatmonthname(theyear, themonth, withyear := true)
    {
        if withyear
            s := AhkStdlibCalendar.month_name[themonth] " " String(theyear)
        else
            s := AhkStdlibCalendar.month_name[themonth]
        return '<tr><th colspan="7" class="' AhkStdlibCalendarHTMLCalendar.cssclass_month_head '">' s '</th></tr>'
    }

    formatmonth(theyear, themonth, withyear := true)
    {
        s := '<table border="0" cellpadding="0" cellspacing="0" class="' AhkStdlibCalendarHTMLCalendar.cssclass_month '">`n'
        s .= this.formatmonthname(theyear, themonth, withyear) "`n"
        s .= this.formatweekheader() "`n"
        for week in this.monthdays2calendar(theyear, themonth)
            s .= this.formatweek(week) "`n"
        s .= "</table>`n"
        return s
    }
}

; ---------------------------------------------------------------------------
; String helpers for TextCalendar formatting (Python str.center/rstrip parity)
; ---------------------------------------------------------------------------

AhkStdlibCalendarCenter(text, width)
{
    n := StrLen(text)
    if n >= width
        return text
    gap := width - n
    left := gap // 2
    right := gap - left
    return AhkStdlibCalendarRepeat(" ", left) text AhkStdlibCalendarRepeat(" ", right)
}

AhkStdlibCalendarRJust(text, width)
{
    n := StrLen(text)
    if n >= width
        return text
    return AhkStdlibCalendarRepeat(" ", width - n) text
}

AhkStdlibCalendarRStrip(text)
{
    return RegExReplace(text, "[ `t]+$")
}

AhkStdlibCalendarRepeat(text, count)
{
    out := ""
    loop count
        out .= text
    return out
}

AhkStdlibCalendarChunkRange(total, chunk)
{
    rows := []
    i := 1
    while i <= total {
        row := []
        loop chunk {
            if i + A_Index - 1 > total
                break
            row.Push(i + A_Index - 1)
        }
        rows.Push(row)
        i += chunk
    }
    return rows
}

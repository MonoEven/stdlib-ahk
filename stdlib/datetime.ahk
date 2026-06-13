#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\calendar>
#Include <stdlib\time>

class AhkStdlibDateTime
{
    static MINYEAR := 1
    static MAXYEAR := 9999
    static OverflowError := AhkStdlibDateTimeOverflowError
    static date := AhkStdlibDateTimeDate
    static datetime := AhkStdlibDateTimeDateTime
    static time := AhkStdlibDateTimeTime
    static tzinfo := AhkStdlibDateTimeTzInfoClass
    static timezone := AhkStdlibDateTimeTimezoneClass

    static timedelta(options := unset)
    {
        if IsSet(options)
            return AhkStdlibDateTimeTimedelta(options)
        return AhkStdlibDateTimeTimedelta()
    }
}

class AhkStdlibDateTimeOverflowError extends Error
{
}

class AhkStdlibDateTimeTzInfo
{
    __New()
    {
        this.__AhkStdlibDateTimeIsTzInfo := true
    }

    utcoffset(dt)
    {
        throw stdlib.NotImplementedError("a tzinfo subclass must implement utcoffset()", -1)
    }

    dst(dt)
    {
        throw stdlib.NotImplementedError("a tzinfo subclass must implement dst()", -1)
    }

    tzname(dt)
    {
        throw stdlib.NotImplementedError("a tzinfo subclass must implement tzname()", -1)
    }

    fromutc(dt)
    {
        if Type(dt) != "AhkStdlibDateTimeDateTimeValue"
            throw TypeError("fromutc: argument must be a datetime", -1)
        return dt
    }
}

class AhkStdlibDateTimeTzInfoClass
{
    static Call(thisClass, args*)
    {
        if args.Length != 0
            throw TypeError("tzinfo() takes no arguments", -1)
        return AhkStdlibDateTimeTzInfo()
    }
}

class AhkStdlibDateTimeTimezone extends AhkStdlibDateTimeTzInfo
{
    __New(offset, name := unset)
    {
        super.__New()
        if !(offset is AhkStdlibDateTimeTimedelta)
            throw TypeError("timezone() argument 1 must be datetime.timedelta, not " AhkStdlibDateTimePythonTypeName(offset), -1)
        totalSeconds := offset.total_seconds()
        if totalSeconds <= -86400 || totalSeconds >= 86400
            throw ValueError("offset must be a timedelta strictly between -timedelta(hours=24) and timedelta(hours=24), not " AhkStdlibDateTimeTimedeltaRepr(offset) ".", -1)
        if IsSet(name) && !(name is String)
            throw TypeError("timezone() argument 2 must be str, not " AhkStdlibDateTimePythonTypeName(name), -1)
        this.offset := offset
        this.name := IsSet(name) ? name : unset
    }

    ToString()
    {
        return this.tzname(stdlib.None)
    }

    utcoffset(dt)
    {
        return this.offset
    }

    dst(dt)
    {
        return stdlib.None
    }

    tzname(dt)
    {
        if HasProp(this, "name")
            return this.name
        return AhkStdlibDateTimeTimezoneOffsetName(this.offset)
    }
}

class AhkStdlibDateTimeTimezoneClass
{
    static utc := AhkStdlibDateTimeTimezone(AhkStdlibDateTimeTimedelta(), "UTC")

    static Call(thisClass, args*)
    {
        if args.Length = 0
            throw TypeError("timezone() missing required argument 'offset' (pos 1)", -1)
        if args.Length > 2
            throw TypeError("timezone() takes at most 2 arguments (" args.Length " given)", -1)
        return args.Length = 1
            ? AhkStdlibDateTimeTimezone(args[1])
            : AhkStdlibDateTimeTimezone(args[1], args[2])
    }
}

class AhkStdlibDateTimeDate
{
    static min := AhkStdlibDateTimeDateValue(1, 1, 1)
    static max := AhkStdlibDateTimeDateValue(9999, 12, 31)
    static resolution := AhkStdlibDateTimeTimedelta({ days: 1 })

    static Call(thisClass, year, month, day)
    {
        return AhkStdlibDateTimeDateValue(year, month, day)
    }

    static fromordinal(ordinal)
    {
        if !(ordinal is Integer)
            throw TypeError("'" AhkStdlibDateTimePythonTypeName(ordinal) "' object cannot be interpreted as an integer", -1)
        if ordinal < 1
            throw ValueError("ordinal must be >= 1", -1)

        dayCount := ordinal - 1
        year := 1

        while true {
            yearDays := AhkStdlibDateTimeDaysInYear(year)
            if dayCount < yearDays
                break
            dayCount -= yearDays
            year += 1
            if year > 9999
                throw ValueError("year " year " is out of range", -1)
        }

        month := 1
        while true {
            monthDays := AhkStdlibCalendarMonthLength(year, month)
            if dayCount < monthDays
                break
            dayCount -= monthDays
            month += 1
        }

        return AhkStdlibDateTimeDateValue(year, month, dayCount + 1)
    }

    static fromtimestamp(timestamp)
    {
        localTuple := stdlib.time.localtime(timestamp)
        return AhkStdlibDateTimeDateValue(localTuple.tm_year, localTuple.tm_mon, localTuple.tm_mday)
    }

    static fromisoformat(dateString)
    {
        if !(dateString is String)
            throw TypeError("fromisoformat: argument must be str", -1)
        parts := AhkStdlibDateTimeParseIsoDate(dateString)
        return AhkStdlibDateTimeDateValue(parts.year, parts.month, parts.day)
    }

    static today()
    {
        localTuple := stdlib.time.localtime()
        return AhkStdlibDateTimeDateValue(localTuple.tm_year, localTuple.tm_mon, localTuple.tm_mday)
    }
}

class AhkStdlibDateTimeDateTime
{
    static Call(thisClass, year, month, day, hour := 0, minute := 0, second := 0, microsecond := 0)
    {
        return AhkStdlibDateTimeDateTimeValue(year, month, day, hour, minute, second, microsecond)
    }

    static combine(dateValue, timeValue)
    {
        if Type(dateValue) != "AhkStdlibDateTimeDateValue" && Type(dateValue) != "AhkStdlibDateTimeDateTimeValue"
            throw TypeError("combine() argument 1 must be datetime.date, not " AhkStdlibDateTimePythonTypeName(dateValue), -1)
        if Type(timeValue) != "AhkStdlibDateTimeTimeValue"
            throw TypeError("combine() argument 2 must be datetime.time, not " AhkStdlibDateTimePythonTypeName(timeValue), -1)
        return AhkStdlibDateTimeDateTimeValue(dateValue.year, dateValue.month, dateValue.day, timeValue.hour, timeValue.minute, timeValue.second, timeValue.microsecond)
    }

    static fromtimestamp(timestamp)
    {
        if !(timestamp is Number)
            throw TypeError("'" AhkStdlibDateTimePythonTypeName(timestamp) "' object cannot be interpreted as an integer", -1)
        localTuple := stdlib.time.localtime(timestamp)
        wholeSeconds := Floor(timestamp)
        fractionalPart := timestamp - wholeSeconds
        microsecond := Integer(Round(fractionalPart * 1000000))
        if microsecond >= 1000000 {
            microsecond -= 1000000
            wholeSeconds += 1
            localTuple := stdlib.time.localtime(wholeSeconds)
        }
        return AhkStdlibDateTimeDateTimeValue(localTuple.tm_year, localTuple.tm_mon, localTuple.tm_mday, localTuple.tm_hour, localTuple.tm_min, localTuple.tm_sec, microsecond)
    }

    static fromisoformat(dateString)
    {
        if !(dateString is String)
            throw TypeError("fromisoformat: argument must be str", -1)
        parts := AhkStdlibDateTimeParseIsoDateTime(dateString)
        return AhkStdlibDateTimeDateTimeValue(parts.year, parts.month, parts.day, parts.hour, parts.minute, parts.second, parts.microsecond)
    }

    static utcfromtimestamp(timestamp)
    {
        if !(timestamp is Number)
            throw TypeError("'" AhkStdlibDateTimePythonTypeName(timestamp) "' object cannot be interpreted as an integer", -1)
        utcTuple := stdlib.time.gmtime(timestamp)
        wholeSeconds := Floor(timestamp)
        fractionalPart := timestamp - wholeSeconds
        microsecond := Integer(Round(fractionalPart * 1000000))
        if microsecond >= 1000000 {
            microsecond -= 1000000
            wholeSeconds += 1
            utcTuple := stdlib.time.gmtime(wholeSeconds)
        }
        return AhkStdlibDateTimeDateTimeValue(utcTuple.tm_year, utcTuple.tm_mon, utcTuple.tm_mday, utcTuple.tm_hour, utcTuple.tm_min, utcTuple.tm_sec, microsecond)
    }

    static now()
    {
        nowStamp := A_Now
        return AhkStdlibDateTimeDateTimeValue(
            Integer(FormatTime(nowStamp, "yyyy")),
            Integer(FormatTime(nowStamp, "MM")),
            Integer(FormatTime(nowStamp, "dd")),
            Integer(FormatTime(nowStamp, "HH")),
            Integer(FormatTime(nowStamp, "mm")),
            Integer(FormatTime(nowStamp, "ss")),
            A_MSec * 1000
        )
    }

    static utcnow()
    {
        utcStamp := A_NowUTC
        return AhkStdlibDateTimeDateTimeValue(
            Integer(FormatTime(utcStamp, "yyyy")),
            Integer(FormatTime(utcStamp, "MM")),
            Integer(FormatTime(utcStamp, "dd")),
            Integer(FormatTime(utcStamp, "HH")),
            Integer(FormatTime(utcStamp, "mm")),
            Integer(FormatTime(utcStamp, "ss")),
            A_MSec * 1000
        )
    }

    static today()
    {
        return AhkStdlibDateTimeDateTime.now()
    }
}

class AhkStdlibDateTimeTime
{
    static min := AhkStdlibDateTimeTimeValue(0, 0, 0)
    static max := AhkStdlibDateTimeTimeValue(23, 59, 59, 999999)
    static resolution := AhkStdlibDateTimeTimedelta({ microseconds: 1 })

    static Call(thisClass, hour := 0, minute := 0, second := 0, microsecond := 0)
    {
        return AhkStdlibDateTimeTimeValue(hour, minute, second, microsecond)
    }

    static fromisoformat(timeString)
    {
        if !(timeString is String)
            throw TypeError("fromisoformat: argument must be str", -1)

        parts := AhkStdlibDateTimeParseIsoTime(timeString)
        return AhkStdlibDateTimeTimeValue(parts.hour, parts.minute, parts.second, parts.microsecond)
    }
}

class AhkStdlibDateTimeTimedelta
{
    __New(options := unset)
    {
        values := AhkStdlibDateTimeTimedeltaNormalize(options?)
        this.days := values.days
        this.seconds := values.seconds
        this.microseconds := values.microseconds
    }

    ToString()
    {
        return AhkStdlibDateTimeTimedeltaString(this.days, this.seconds, this.microseconds)
    }

    total_seconds()
    {
        return (this.days * 86400) + this.seconds + (this.microseconds / 1000000.0)
    }

    __Compare(other, op)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            return ""
        left := AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
        right := AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)
        if left = right
            return 0
        return left < right ? -1 : 1
    }

    __Add(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            return ""
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
            + AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)
        )
    }

    __Sub(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            return ""
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
            - AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)
        )
    }

    __Neg()
    {
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            -AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
        )
    }

    __Pos()
    {
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
        )
    }

    __Mul(other)
    {
        if !(other is Integer)
            return ""
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds) * other
        )
    }

    add(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            throw TypeError("unsupported operand type(s) for +: 'datetime.timedelta' and '" AhkStdlibDateTimePythonTypeName(other) "'", -1)
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
            + AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)
        )
    }

    sub(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            throw TypeError("unsupported operand type(s) for -: 'datetime.timedelta' and '" AhkStdlibDateTimePythonTypeName(other) "'", -1)
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
            - AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)
        )
    }

    mul(factor)
    {
        if !(factor is Integer)
            throw TypeError("unsupported operand type(s) for *: 'datetime.timedelta' and '" AhkStdlibDateTimePythonTypeName(factor) "'", -1)
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(
            AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds) * factor
        )
    }

    div(divisor)
    {
        if divisor is AhkStdlibDateTimeTimedelta {
            right := AhkStdlibDateTimeTimedeltaTotalMicroseconds(divisor.days, divisor.seconds, divisor.microseconds)
            if right = 0
                throw ZeroDivisionError("division by zero", -1)
            return AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds) / right
        }
        if !(divisor is Integer)
            throw TypeError("unsupported operand type(s) for /: 'datetime.timedelta' and '" AhkStdlibDateTimePythonTypeName(divisor) "'", -1)
        if divisor = 0
            throw ZeroDivisionError("division by zero", -1)
        total := AhkStdlibDateTimeTimedeltaTotalMicroseconds(this.days, this.seconds, this.microseconds)
        rounded := AhkStdlibDateTimeRoundHalfEven(total, divisor)
        return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(rounded)
    }
}

class AhkStdlibDateTimeDateValue
{
    __New(year, month, day)
    {
        AhkStdlibDateTimeRequireInteger(year, "year")
        AhkStdlibDateTimeRequireInteger(month, "month")
        AhkStdlibDateTimeRequireInteger(day, "day")
        AhkStdlibDateTimeCheckDate(year, month, day)
        this.year := year
        this.month := month
        this.day := day
    }

    ToString()
    {
        return this.isoformat()
    }

    isoformat()
    {
        return Format("{:04}-{:02}-{:02}", this.year, this.month, this.day)
    }

    weekday()
    {
        return AhkStdlibCalendar.weekday(this.year, this.month, this.day)
    }

    isoweekday()
    {
        return this.weekday() + 1
    }

    toordinal()
    {
        return AhkStdlibDateTimeDateOrdinal(this.year, this.month, this.day)
    }

    ctime()
    {
        return AhkStdlibDateTimeDateCtime(this)
    }

    isocalendar()
    {
        return AhkStdlibDateTimeDateIsocalendar(this)
    }

    replace(options := unset)
    {
        year := AhkStdlibDateTimeOption(options?, "year", "Year", this.year)
        month := AhkStdlibDateTimeOption(options?, "month", "Month", this.month)
        day := AhkStdlibDateTimeOption(options?, "day", "Day", this.day)
        AhkStdlibDateTimeRequireInteger(year, "year")
        AhkStdlibDateTimeRequireInteger(month, "month")
        AhkStdlibDateTimeRequireInteger(day, "day")
        return AhkStdlibDateTimeDateValue(year, month, day)
    }

    __Compare(other, op)
    {
        if Type(other) != "AhkStdlibDateTimeDateValue"
            return ""
        left := this.toordinal()
        right := other.toordinal()
        if left = right
            return 0
        return left < right ? -1 : 1
    }

    __Add(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            return ""
        return AhkStdlibDateTimeDateAddTimedelta(this, other)
    }

    __Sub(other)
    {
        if other is AhkStdlibDateTimeTimedelta
            return AhkStdlibDateTimeDateAddTimedelta(this, AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(-AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)))
        if Type(other) = "AhkStdlibDateTimeDateValue"
            return AhkStdlibDateTimeTimedelta({ days: this.toordinal() - other.toordinal() })
        return ""
    }
}

class AhkStdlibDateTimeDateTimeValue extends AhkStdlibDateTimeDateValue
{
    __New(year, month, day, hour := 0, minute := 0, second := 0, microsecond := 0)
    {
        super.__New(year, month, day)
        AhkStdlibDateTimeRequireInteger(hour, "hour")
        AhkStdlibDateTimeRequireInteger(minute, "minute")
        AhkStdlibDateTimeRequireInteger(second, "second")
        AhkStdlibDateTimeRequireInteger(microsecond, "microsecond")
        AhkStdlibDateTimeCheckTime(hour, minute, second, microsecond)
        this.hour := hour
        this.minute := minute
        this.second := second
        this.microsecond := microsecond
    }

    ToString()
    {
        return this.isoformat(" ")
    }

    isoformat(sep := "T", timespec := "auto")
    {
        if !(sep is String)
            throw TypeError("isoformat() argument 1 must be a unicode character, not " AhkStdlibDateTimePythonTypeName(sep), -1)
        if StrLen(sep) != 1
            throw TypeError("isoformat() argument 1 must be a unicode character, not str", -1)
        if !(timespec is String)
            throw TypeError("isoformat() argument 2 must be str, not " AhkStdlibDateTimePythonTypeName(timespec), -1)
        return this.date().isoformat()
            . sep
            . AhkStdlibDateTimeTimeIsoformat(this.hour, this.minute, this.second, this.microsecond, timespec)
    }

    date()
    {
        return AhkStdlibDateTimeDateValue(this.year, this.month, this.day)
    }

    time()
    {
        return AhkStdlibDateTimeTimeValue(this.hour, this.minute, this.second, this.microsecond)
    }

    ctime()
    {
        return AhkStdlibDateTimeDateTimeCtime(this)
    }

    strftime(pattern)
    {
        return AhkStdlibDateTimeDateTimeStrftime(this, pattern)
    }

    replace(options := unset)
    {
        year := AhkStdlibDateTimeOption(options?, "year", "Year", this.year)
        month := AhkStdlibDateTimeOption(options?, "month", "Month", this.month)
        day := AhkStdlibDateTimeOption(options?, "day", "Day", this.day)
        hour := AhkStdlibDateTimeOption(options?, "hour", "Hour", this.hour)
        minute := AhkStdlibDateTimeOption(options?, "minute", "Minute", this.minute)
        second := AhkStdlibDateTimeOption(options?, "second", "Second", this.second)
        microsecond := AhkStdlibDateTimeOption(options?, "microsecond", "Microsecond", this.microsecond)
        return AhkStdlibDateTimeDateTimeValue(year, month, day, hour, minute, second, microsecond)
    }

    __Compare(other, op)
    {
        if Type(other) != "AhkStdlibDateTimeDateTimeValue"
            return ""

        left := AhkStdlibDateTimeDateTimeTotalMicroseconds(this)
        right := AhkStdlibDateTimeDateTimeTotalMicroseconds(other)
        if left = right
            return 0
        return left < right ? -1 : 1
    }

    __Add(other)
    {
        if !(other is AhkStdlibDateTimeTimedelta)
            return ""
        return AhkStdlibDateTimeDateTimeAddTimedelta(this, other)
    }

    __Sub(other)
    {
        if other is AhkStdlibDateTimeTimedelta
            return AhkStdlibDateTimeDateTimeAddTimedelta(this, AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(-AhkStdlibDateTimeTimedeltaTotalMicroseconds(other.days, other.seconds, other.microseconds)))
        if Type(other) = "AhkStdlibDateTimeDateTimeValue"
            return AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(AhkStdlibDateTimeDateTimeTotalMicroseconds(this) - AhkStdlibDateTimeDateTimeTotalMicroseconds(other))
        return ""
    }
}

class AhkStdlibDateTimeTimeValue
{
    __New(hour := 0, minute := 0, second := 0, microsecond := 0)
    {
        AhkStdlibDateTimeRequireInteger(hour, "hour")
        AhkStdlibDateTimeRequireInteger(minute, "minute")
        AhkStdlibDateTimeRequireInteger(second, "second")
        AhkStdlibDateTimeRequireInteger(microsecond, "microsecond")
        AhkStdlibDateTimeCheckTime(hour, minute, second, microsecond)
        this.hour := hour
        this.minute := minute
        this.second := second
        this.microsecond := microsecond
    }

    ToString()
    {
        return this.isoformat()
    }

    isoformat(timespec := "auto")
    {
        return AhkStdlibDateTimeTimeIsoformat(this.hour, this.minute, this.second, this.microsecond, timespec)
    }

    replace(options := unset)
    {
        hour := AhkStdlibDateTimeOption(options?, "hour", "Hour", this.hour)
        minute := AhkStdlibDateTimeOption(options?, "minute", "Minute", this.minute)
        second := AhkStdlibDateTimeOption(options?, "second", "Second", this.second)
        microsecond := AhkStdlibDateTimeOption(options?, "microsecond", "Microsecond", this.microsecond)
        return AhkStdlibDateTimeTimeValue(hour, minute, second, microsecond)
    }

    __Compare(other, op)
    {
        if Type(other) != "AhkStdlibDateTimeTimeValue"
            return ""

        left := AhkStdlibDateTimeTimeTotalMicroseconds(this)
        right := AhkStdlibDateTimeTimeTotalMicroseconds(other)
        if left = right
            return 0
        return left < right ? -1 : 1
    }
}

stdlib.datetime := AhkStdlibDateTime

AhkStdlibDateTimeTimedeltaNormalize(options := unset)
{
    days := 0
    seconds := 0
    microseconds := 0

    if IsSet(options) {
        rawWeeks := AhkStdlibDateTimeTimedeltaComponent(options, "weeks", "Weeks", "weeks")
        rawDays := AhkStdlibDateTimeTimedeltaComponent(options, "days", "Days", "days")
        if AhkStdlibDateTimeTimedeltaDaysWouldOverflow(rawWeeks, rawDays)
            throw AhkStdlibDateTimeOverflowError("days=" (rawWeeks * 7 + rawDays) "; must have magnitude <= 999999999", -1)
        days += rawWeeks * 7
        days += rawDays
        seconds += AhkStdlibDateTimeTimedeltaComponent(options, "hours", "Hours", "hours") * 3600
        seconds += AhkStdlibDateTimeTimedeltaComponent(options, "minutes", "Minutes", "minutes") * 60
        seconds += AhkStdlibDateTimeTimedeltaComponent(options, "seconds", "Seconds", "seconds")
        microseconds += AhkStdlibDateTimeTimedeltaComponent(options, "milliseconds", "Milliseconds", "milliseconds") * 1000
        microseconds += AhkStdlibDateTimeTimedeltaComponent(options, "microseconds", "Microseconds", "microseconds")
    }

    totalMicroseconds := AhkStdlibDateTimeTimedeltaTotalMicroseconds(days, seconds, microseconds)
    normalized := AhkStdlibDateTimeTimedeltaSplit(totalMicroseconds)
    if Abs(normalized.days) > 999999999
        throw AhkStdlibDateTimeOverflowError("days=" normalized.days "; must have magnitude <= 999999999", -1)
    return normalized
}

AhkStdlibDateTimeTimezoneOffsetName(offset)
{
    totalSeconds := Integer(offset.total_seconds())
    sign := totalSeconds < 0 ? "-" : "+"
    absSeconds := Abs(totalSeconds)
    hours := Floor(absSeconds / 3600)
    minutes := Floor(Mod(absSeconds, 3600) / 60)
    return "UTC" sign Format("{:02}:{:02}", hours, minutes)
}

AhkStdlibDateTimeTimedeltaRepr(delta)
{
    parts := []
    if delta.days != 0
        parts.Push("days=" delta.days)
    if delta.seconds != 0
        parts.Push("seconds=" delta.seconds)
    if delta.microseconds != 0
        parts.Push("microseconds=" delta.microseconds)
    if parts.Length = 0
        return "datetime.timedelta(0)"
    return "datetime.timedelta(" AhkStdlibDateTimeJoin(parts, ", ") ")"
}

AhkStdlibDateTimeJoin(values, delimiter := "")
{
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

AhkStdlibDateTimeDaysInYear(year)
{
    return AhkStdlibCalendar.isleap(year) ? 366 : 365
}

AhkStdlibDateTimeCheckDate(year, month, day)
{
    if year < 1 || year > 9999
        throw ValueError("year " year " is out of range", -1)
    if month < 1 || month > 12
        throw ValueError("month must be in 1..12", -1)
    if day < 1 || day > AhkStdlibCalendarMonthLength(year, month)
        throw ValueError("day is out of range for month", -1)
}

AhkStdlibDateTimeCheckTime(hour, minute, second, microsecond)
{
    if hour < 0 || hour > 23
        throw ValueError("hour must be in 0..23", -1)
    if minute < 0 || minute > 59
        throw ValueError("minute must be in 0..59", -1)
    if second < 0 || second > 59
        throw ValueError("second must be in 0..59", -1)
    if microsecond < 0 || microsecond > 999999
        throw ValueError("microsecond must be in 0..999999", -1)
}

AhkStdlibDateTimeRequireInteger(value, name)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibDateTimePythonTypeName(value) "' object cannot be interpreted as an integer", -1)
    return value
}

AhkStdlibDateTimeDateOrdinal(year, month, day)
{
    return AhkStdlibCalendarDaysBeforeYear(year) + AhkStdlibCalendarDaysBeforeMonth(year, month) + day
}

AhkStdlibDateTimeDateAddTimedelta(dateValue, delta)
{
    ordinal := dateValue.toordinal()
    newOrdinal := ordinal + delta.days
    if newOrdinal < 1 || newOrdinal > AhkStdlibDateTimeDate.max.toordinal()
        throw AhkStdlibDateTimeOverflowError("date value out of range", -1)
    return AhkStdlibDateTimeDate.fromordinal(newOrdinal)
}

AhkStdlibDateTimeDateCtime(dateValue)
{
    dayNames := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    monthNames := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return dayNames[dateValue.weekday() + 1]
        . " " . monthNames[dateValue.month]
        . " " . Format("{:2}", dateValue.day)
        . " 00:00:00 "
        . Format("{:04}", dateValue.year)
}

AhkStdlibDateTimeDateIsocalendar(dateValue)
{
    isoWeekday := dateValue.isoweekday()
    thursday := AhkStdlibDateTimeDateAddDays(dateValue, 4 - isoWeekday)
    isoYear := thursday.year
    weekOneThursday := AhkStdlibDateTimeDateValue(isoYear, 1, 4)
    week := Floor((thursday.toordinal() - AhkStdlibDateTimeDateAddDays(weekOneThursday, 4 - weekOneThursday.isoweekday()).toordinal()) / 7) + 1
    return [isoYear, week, isoWeekday]
}

AhkStdlibDateTimeDateAddDays(dateValue, days)
{
    return AhkStdlibDateTimeDate.fromordinal(dateValue.toordinal() + days)
}

AhkStdlibDateTimeDateTimeAddTimedelta(datetimeValue, delta)
{
    totalMicroseconds := AhkStdlibDateTimeDateTimeTotalMicroseconds(datetimeValue) + AhkStdlibDateTimeTimedeltaTotalMicroseconds(delta.days, delta.seconds, delta.microseconds)
    return AhkStdlibDateTimeDateTimeFromTotalMicroseconds(totalMicroseconds)
}

AhkStdlibDateTimeDateTimeTotalMicroseconds(datetimeValue)
{
    dayOrdinal := datetimeValue.toordinal() - 1
    dayMicroseconds := 86400 * 1000000
    timeMicroseconds := ((datetimeValue.hour * 3600) + (datetimeValue.minute * 60) + datetimeValue.second) * 1000000 + datetimeValue.microsecond
    return (dayOrdinal * dayMicroseconds) + timeMicroseconds
}

AhkStdlibDateTimeDateTimeFromTotalMicroseconds(totalMicroseconds)
{
    dayMicroseconds := 86400 * 1000000
    maxOrdinal := AhkStdlibDateTimeDate.max.toordinal()
    minTotal := 0
    maxTotal := (maxOrdinal * dayMicroseconds) - 1
    if totalMicroseconds < minTotal || totalMicroseconds > maxTotal
        throw AhkStdlibDateTimeOverflowError("date value out of range", -1)

    dayOrdinal := Floor(totalMicroseconds / dayMicroseconds) + 1
    dayRemainder := Mod(totalMicroseconds, dayMicroseconds)
    if dayRemainder < 0 {
        dayRemainder += dayMicroseconds
        dayOrdinal -= 1
    }

    dateValue := AhkStdlibDateTimeDate.fromordinal(dayOrdinal)
    secondOfDay := Floor(dayRemainder / 1000000)
    microsecond := Mod(dayRemainder, 1000000)
    hour := Floor(secondOfDay / 3600)
    minute := Floor(Mod(secondOfDay, 3600) / 60)
    second := Mod(secondOfDay, 60)
    return AhkStdlibDateTimeDateTimeValue(dateValue.year, dateValue.month, dateValue.day, hour, minute, second, microsecond)
}

AhkStdlibDateTimeDateTimeCtime(datetimeValue)
{
    dayNames := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    monthNames := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return dayNames[datetimeValue.weekday() + 1]
        . " " . monthNames[datetimeValue.month]
        . " " . Format("{:2}", datetimeValue.day)
        . " " . Format("{:02}:{:02}:{:02}", datetimeValue.hour, datetimeValue.minute, datetimeValue.second)
        . " " . Format("{:04}", datetimeValue.year)
}

AhkStdlibDateTimeDateTimeStrftime(datetimeValue, pattern)
{
    if !(pattern is String)
        throw TypeError("strftime() argument 1 must be str, not " AhkStdlibDateTimePythonTypeName(pattern), -1)

    timeTuple := stdlib.time.struct_time([
        datetimeValue.year,
        datetimeValue.month,
        datetimeValue.day,
        datetimeValue.hour,
        datetimeValue.minute,
        datetimeValue.second,
        datetimeValue.weekday(),
        Integer(FormatTime(Format("{:04}{:02}{:02}", datetimeValue.year, datetimeValue.month, datetimeValue.day), "YDay")),
        -1
    ])

    result := ""
    index := 1
    while index <= StrLen(pattern) {
        char := SubStr(pattern, index, 1)
        if char != "%" {
            result .= char
            index += 1
            continue
        }

        index += 1
        if index > StrLen(pattern) {
            result .= "%"
            break
        }

        token := SubStr(pattern, index, 1)
        if token = "f"
            result .= Format("{:06}", datetimeValue.microsecond)
        else
            result .= stdlib.time.strftime("%" token, timeTuple)
        index += 1
    }
    return result
}

AhkStdlibDateTimeParseIsoDateTime(dateString)
{
    parts := AhkStdlibDateTimeParseIsoDate(dateString)
    year := parts.year
    month := parts.month
    day := parts.day
    hour := 0
    minute := 0
    second := 0
    microsecond := 0

    if StrLen(dateString) = 10 {
        return {
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            microsecond: microsecond
        }
    }

    separator := SubStr(dateString, 11, 1)
    if separator != "T" && separator != " "
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)

    timePart := SubStr(dateString, 12)
    if InStr(timePart, ".") {
        timePieces := StrSplit(timePart, ".")
        if timePieces.Length != 2
            throw ValueError("Invalid isoformat string: '" dateString "'", -1)
        fraction := timePieces[2]
        if StrLen(fraction) != 3 && StrLen(fraction) != 6
            throw ValueError("Invalid isoformat string: '" dateString "'", -1)
        if !AhkStdlibDateTimeAllDigits(fraction, StrLen(fraction))
            throw ValueError("Invalid isoformat string: '" dateString "'", -1)
        microsecond := StrLen(fraction) = 3 ? Integer(fraction) * 1000 : Integer(fraction)
        timePart := timePieces[1]
    }

    timePieces := StrSplit(timePart, ":")
    if timePieces.Length != 3
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[1], 2)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[2], 2)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[3], 2)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)

    hour := Integer(timePieces[1])
    minute := Integer(timePieces[2])
    second := Integer(timePieces[3])

    return {
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
    }
}

AhkStdlibDateTimeParseIsoTime(timeString)
{
    hour := 0
    minute := 0
    second := 0
    microsecond := 0

    timePart := timeString
    if InStr(timePart, ".") {
        timePieces := StrSplit(timePart, ".")
        if timePieces.Length != 2
            throw ValueError("Invalid isoformat string: '" timeString "'", -1)
        fraction := timePieces[2]
        if StrLen(fraction) != 3 && StrLen(fraction) != 6
            throw ValueError("Invalid isoformat string: '" timeString "'", -1)
        if !AhkStdlibDateTimeAllDigits(fraction, StrLen(fraction))
            throw ValueError("Invalid isoformat string: '" timeString "'", -1)
        microsecond := StrLen(fraction) = 3 ? Integer(fraction) * 1000 : Integer(fraction)
        timePart := timePieces[1]
    }

    timePieces := StrSplit(timePart, ":")
    if timePieces.Length != 3
        throw ValueError("Invalid isoformat string: '" timeString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[1], 2)
        throw ValueError("Invalid isoformat string: '" timeString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[2], 2)
        throw ValueError("Invalid isoformat string: '" timeString "'", -1)
    if !AhkStdlibDateTimeAllDigits(timePieces[3], 2)
        throw ValueError("Invalid isoformat string: '" timeString "'", -1)

    hour := Integer(timePieces[1])
    minute := Integer(timePieces[2])
    second := Integer(timePieces[3])

    return {
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
    }
}

AhkStdlibDateTimeParseIsoDate(dateString)
{
    if StrLen(dateString) < 10
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if SubStr(dateString, 5, 1) != "-" || SubStr(dateString, 8, 1) != "-"
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)

    datePart := SubStr(dateString, 1, 10)
    datePieces := StrSplit(datePart, "-")
    if datePieces.Length != 3
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(datePieces[1], 4)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(datePieces[2], 2)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)
    if !AhkStdlibDateTimeAllDigits(datePieces[3], 2)
        throw ValueError("Invalid isoformat string: '" dateString "'", -1)

    return {
        year: Integer(datePieces[1]),
        month: Integer(datePieces[2]),
        day: Integer(datePieces[3])
    }
}

AhkStdlibDateTimeAllDigits(value, expectedLength)
{
    if StrLen(value) != expectedLength
        return false
    Loop Parse, value {
        if A_LoopField < "0" || A_LoopField > "9"
            return false
    }
    return true
}

AhkStdlibDateTimeTimeString(hour, minute, second, microsecond)
{
    value := Format("{:02}:{:02}:{:02}", hour, minute, second)
    if microsecond != 0
        value .= Format(".{:06}", microsecond)
    return value
}

AhkStdlibDateTimeTimeIsoformat(hour, minute, second, microsecond, timespec := "auto")
{
    if !(timespec is String)
        throw TypeError("isoformat() argument 1 must be str, not " AhkStdlibDateTimePythonTypeName(timespec), -1)

    switch timespec {
        case "auto":
            if microsecond = 0
                return Format("{:02}:{:02}:{:02}", hour, minute, second)
            return AhkStdlibDateTimeTimeString(hour, minute, second, microsecond)
        case "hours":
            return Format("{:02}", hour)
        case "minutes":
            return Format("{:02}:{:02}", hour, minute)
        case "seconds":
            return Format("{:02}:{:02}:{:02}", hour, minute, second)
        case "milliseconds":
            return Format("{:02}:{:02}:{:02}.{:03}", hour, minute, second, Floor(microsecond / 1000))
        case "microseconds":
            return Format("{:02}:{:02}:{:02}.{:06}", hour, minute, second, microsecond)
    }

    throw ValueError("Unknown timespec value", -1)
}

AhkStdlibDateTimeTimeTotalMicroseconds(timeValue)
{
    return (((timeValue.hour * 60) + timeValue.minute) * 60 + timeValue.second) * 1000000 + timeValue.microsecond
}

AhkStdlibDateTimeTimedeltaDaysWouldOverflow(weeks, days)
{
    totalDays := (weeks * 7) + days
    return Abs(totalDays) > 999999999
}

AhkStdlibDateTimeTimedeltaComponent(options, sourceName, ahkName, errorName)
{
    if !IsSet(options)
        return 0
    value := AhkStdlibDateTimeOption(options, sourceName, ahkName, 0)
    if !(value is Integer)
        throw TypeError("unsupported type for timedelta " errorName " component: " AhkStdlibDateTimePythonTypeName(value), -1)
    return value
}

AhkStdlibDateTimeOption(options, sourceName, ahkName, defaultValue)
{
    if !IsSet(options)
        return defaultValue
    if options is Map {
        if options.Has(sourceName)
            return options[sourceName]
        if options.Has(ahkName)
            return options[ahkName]
        return defaultValue
    }
    if IsObject(options) {
        if options.HasOwnProp(sourceName)
            return options.%sourceName%
        if options.HasOwnProp(ahkName)
            return options.%ahkName%
        return defaultValue
    }
    throw TypeError("timedelta options must be a Map or Object", -1)
}

AhkStdlibDateTimeTimedeltaTotalMicroseconds(days, seconds, microseconds)
{
    return ((days * 86400) + seconds) * 1000000 + microseconds
}

AhkStdlibDateTimeTimedeltaSplit(totalMicroseconds)
{
    microsecondsPerDay := 86400 * 1000000
    days := Floor(totalMicroseconds / microsecondsPerDay)
    remainder := Mod(totalMicroseconds, microsecondsPerDay)
    if remainder < 0 {
        remainder += microsecondsPerDay
    }
    seconds := Floor(remainder / 1000000)
    microseconds := Mod(remainder, 1000000)
    return { days: days, seconds: seconds, microseconds: microseconds }
}

AhkStdlibDateTimeRoundHalfEven(numerator, denominator)
{
    quotient := numerator // denominator
    remainder := numerator - (quotient * denominator)
    if remainder < 0 {
        remainder += Abs(denominator)
        quotient -= 1
    }
    doubled := remainder * 2
    absDen := Abs(denominator)
    if doubled > absDen
        quotient += 1
    else if doubled = absDen && Mod(quotient, 2) != 0
        quotient += 1
    return quotient
}

AhkStdlibDateTimeTimedeltaFromTotalMicroseconds(totalMicroseconds)
{
    values := AhkStdlibDateTimeTimedeltaSplit(totalMicroseconds)
    return AhkStdlibDateTimeTimedelta({ days: values.days, seconds: values.seconds, microseconds: values.microseconds })
}

AhkStdlibDateTimeTimedeltaString(days, seconds, microseconds)
{
    hours := Floor(seconds / 3600)
    minutes := Floor(Mod(seconds, 3600) / 60)
    secs := Mod(seconds, 60)
    clock := hours ":" Format("{:02}:{:02}", minutes, secs)
    if microseconds
        clock .= "." Format("{:06}", microseconds)

    if days = 0
        return clock
    if Abs(days) = 1
        return days " day, " clock
    return days " days, " clock
}

AhkStdlibDateTimePythonTypeName(value)
{
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    if IsObject(value)
        return "object"
    return Type(value)
}

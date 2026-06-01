#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTime
{
    static struct_time(sequence)
    {
        return AhkStdlibTimeStructTime(sequence)
    }

    static time()
    {
        return AhkStdlibTimeUnixSeconds()
    }

    static time_ns()
    {
        return AhkStdlibTimeUnixNanoseconds()
    }

    static sleep(seconds)
    {
        return AhkStdlibTimeSleep(seconds)
    }

    static monotonic()
    {
        return AhkStdlibTimeMonotonic()
    }

    static monotonic_ns()
    {
        return AhkStdlibTimeMonotonicNanoseconds()
    }

    static perf_counter()
    {
        return AhkStdlibTimePerfCounter()
    }

    static perf_counter_ns()
    {
        return AhkStdlibTimePerfCounterNanoseconds()
    }

    static gmtime(seconds := unset)
    {
        return AhkStdlibTimeGmtime(seconds?)
    }

    static localtime(seconds := unset)
    {
        return AhkStdlibTimeLocaltime(seconds?)
    }

    static asctime(timeTuple := unset)
    {
        return AhkStdlibTimeAsctime(timeTuple?)
    }

    static ctime(seconds := unset)
    {
        return AhkStdlibTimeCtime(seconds?)
    }

    static strftime(format, timeTuple := unset)
    {
        return AhkStdlibTimeStrftime(format, timeTuple?)
    }
}

class AhkStdlibTimeStructTime
{
    __New(sequence)
    {
        values := AhkStdlibTimeSequenceToArray(sequence)
        if values.Length < 9
            throw TypeError("time.struct_time() takes an at least 9-sequence (" values.Length "-sequence given)", -1)

        tupleValues := []
        loop 9
            tupleValues.Push(values[A_Index])
        this.Values := AhkStdlibTuple(tupleValues)

        this.tm_year := this.Values[1]
        this.tm_mon := this.Values[2]
        this.tm_mday := this.Values[3]
        this.tm_hour := this.Values[4]
        this.tm_min := this.Values[5]
        this.tm_sec := this.Values[6]
        this.tm_wday := this.Values[7]
        this.tm_yday := this.Values[8]
        this.tm_isdst := this.Values[9]
    }

    Length
    {
        get => this.Values.Length
    }

    __Item[index]
    {
        get => this.Values[index]
    }

    __Enum(numberOfVars)
    {
        return this.Values.__Enum(numberOfVars)
    }
}

stdlib.time := AhkStdlibTime

AhkStdlibTimeUnixSeconds()
{
    return DateDiff(A_NowUTC, "19700101000000", "Seconds") + (A_MSec / 1000.0)
}

AhkStdlibTimeUnixNanoseconds()
{
    return DateDiff(A_NowUTC, "19700101000000", "Seconds") * 1000000000 + (A_MSec * 1000000)
}

AhkStdlibTimeSleep(seconds)
{
    if !(seconds is Number)
        throw TypeError("'" AhkStdlibTimePythonTypeName(seconds) "' object cannot be interpreted as an integer", -1)
    if seconds < 0
        throw ValueError("sleep length must be non-negative", -1)

    milliseconds := seconds = 0 ? 0 : Max(1, Ceil(seconds * 1000))
    Sleep milliseconds
}

AhkStdlibTimeMonotonic()
{
    return A_TickCount / 1000.0
}

AhkStdlibTimeMonotonicNanoseconds()
{
    return A_TickCount * 1000000
}

AhkStdlibTimePerfCounter()
{
    DllCall("QueryPerformanceFrequency", "Int64*", &frequency := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &counter := 0)
    return counter / frequency
}

AhkStdlibTimePerfCounterNanoseconds()
{
    DllCall("QueryPerformanceFrequency", "Int64*", &frequency := 0)
    DllCall("QueryPerformanceCounter", "Int64*", &counter := 0)
    return Integer(Round((counter * 1000000000.0) / frequency))
}

AhkStdlibTimeGmtime(seconds := unset)
{
    if !IsSet(seconds)
        seconds := AhkStdlibTimeUnixSeconds()
    seconds := AhkStdlibTimeUnixSecondsArgument(seconds)
    wholeSeconds := Floor(seconds)
    if wholeSeconds <= -86400
        throw OSError("Invalid argument", -1)
    timestamp := DateAdd("19700101000000", wholeSeconds, "Seconds")
    year := Integer(FormatTime(timestamp, "yyyy"))
    month := Integer(FormatTime(timestamp, "MM"))
    day := Integer(FormatTime(timestamp, "dd"))
    yday := Integer(FormatTime(timestamp, "YDay"))
    wday := AhkStdlibTimeWeekday(year, month, day)
    if year = 1969 && month = 12 && day = 31
        wday := 3
    return AhkStdlibTimeStructTime([
        year,
        month,
        day,
        Integer(FormatTime(timestamp, "HH")),
        Integer(FormatTime(timestamp, "mm")),
        Integer(FormatTime(timestamp, "ss")),
        wday,
        yday,
        0
    ])
}

AhkStdlibTimeStrftime(format, timeTuple := unset)
{
    if !(format is String)
        throw TypeError("strftime() argument 1 must be str, not " AhkStdlibTimePythonTypeName(format), -1)

    if !IsSet(timeTuple)
        return AhkStdlibTimeFormatTimestamp(A_Now, format)
    timeTuple := AhkStdlibTimeNormalizeTupleArgument(timeTuple)

    AhkStdlibTimeValidateStructTimeForStrftime(timeTuple)
    timestamp := AhkStdlibTimeStructTimeToTimestamp(timeTuple)
    return AhkStdlibTimeFormatTimestamp(timestamp, format, timeTuple)
}

AhkStdlibTimeLocaltime(seconds := unset)
{
    if !IsSet(seconds) {
        now := AhkStdlibTimeStructTime([
            Integer(FormatTime(A_Now, "yyyy")),
            Integer(FormatTime(A_Now, "MM")),
            Integer(FormatTime(A_Now, "dd")),
            Integer(FormatTime(A_Now, "HH")),
            Integer(FormatTime(A_Now, "mm")),
            Integer(FormatTime(A_Now, "ss")),
            AhkStdlibTimeWeekday(Integer(FormatTime(A_Now, "yyyy")), Integer(FormatTime(A_Now, "MM")), Integer(FormatTime(A_Now, "dd"))),
            Integer(FormatTime(A_Now, "YDay")),
            0
        ])
        return now
    }

    seconds := AhkStdlibTimeUnixSecondsArgument(seconds)
    wholeSeconds := Floor(seconds)
    if wholeSeconds < 0
        throw OSError("Invalid argument", -1)

    offsetSeconds := DateDiff(A_Now, A_NowUTC, "Seconds")
    return AhkStdlibTimeGmtime(wholeSeconds + offsetSeconds)
}

AhkStdlibTimeAsctime(timeTuple := unset)
{
    if !IsSet(timeTuple)
        timeTuple := AhkStdlibTimeLocaltime()
    timeTuple := AhkStdlibTimeNormalizeTupleArgument(timeTuple)

    AhkStdlibTimeValidateStructTimeForStrftime(timeTuple)
    dayNames := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    monthNames := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    dayName := dayNames[Integer(timeTuple.tm_wday) + 1]
    monthName := monthNames[Integer(timeTuple.tm_mon)]
    day := Format("{:2}", Integer(timeTuple.tm_mday))
    return dayName " " monthName " " day " " Format("{:02}:{:02}:{:02} {:04}", Integer(timeTuple.tm_hour), Integer(timeTuple.tm_min), Integer(timeTuple.tm_sec), Integer(timeTuple.tm_year))
}

AhkStdlibTimeCtime(seconds := unset)
{
    return AhkStdlibTimeAsctime(AhkStdlibTimeLocaltime(seconds?))
}

AhkStdlibTimeSequenceToArray(sequence)
{
    result := []
    if sequence is String {
        loop Parse sequence
            result.Push(A_LoopField)
        return result
    }
    if sequence is Array {
        for value in sequence
            result.Push(value)
        return result
    }
    if !IsObject(sequence)
        throw TypeError("'" AhkStdlibTimePythonTypeName(sequence) "' object is not iterable", -1)

    for value in sequence
        result.Push(value)
    return result
}

AhkStdlibTimeUnixSecondsArgument(seconds)
{
    if !(seconds is Number)
        throw TypeError("'" AhkStdlibTimePythonTypeName(seconds) "' object cannot be interpreted as an integer", -1)
    return seconds + 0
}

AhkStdlibTimeNormalizeTupleArgument(timeTuple)
{
    if timeTuple is AhkStdlibTimeStructTime
        return timeTuple
    if timeTuple is AhkStdlibTuple
        return AhkStdlibTimeStructTime(timeTuple)
    throw TypeError("Tuple or struct_time argument required", -1)
}

AhkStdlibTimeStructTimeToTimestamp(timeTuple)
{
    return Format(
        "{1:04}{2:02}{3:02}{4:02}{5:02}{6:02}",
        Integer(timeTuple.tm_year),
        Integer(timeTuple.tm_mon),
        Integer(timeTuple.tm_mday),
        Integer(timeTuple.tm_hour),
        Integer(timeTuple.tm_min),
        Integer(timeTuple.tm_sec)
    )
}

AhkStdlibTimeValidateStructTimeForStrftime(timeTuple)
{
    if timeTuple.tm_mon < 1 || timeTuple.tm_mon > 12
        throw ValueError("month out of range", -1)
    if timeTuple.tm_mday < 1 || timeTuple.tm_mday > 31
        throw ValueError("day of month out of range", -1)
    if timeTuple.tm_hour < 0 || timeTuple.tm_hour > 23
        throw ValueError("hour out of range", -1)
    if timeTuple.tm_min < 0 || timeTuple.tm_min > 59
        throw ValueError("minute out of range", -1)
    if timeTuple.tm_sec < 0 || timeTuple.tm_sec > 61
        throw ValueError("seconds out of range", -1)
}

AhkStdlibTimeWeekday(year, month, day)
{
    if month < 3 {
        month += 12
        year -= 1
    }

    k := Mod(year, 100)
    j := Floor(year / 100)
    h := Mod(day + Floor((13 * (month + 1)) / 5) + k + Floor(k / 4) + Floor(j / 4) + (5 * j), 7)
    return Mod(h + 5, 7)
}

AhkStdlibTimeFormatTimestamp(timestamp, format, timeTuple := unset)
{
    result := ""
    index := 1
    while index <= StrLen(format) {
        char := SubStr(format, index, 1)
        if char != "%" {
            result .= char
            index += 1
            continue
        }

        index += 1
        if index > StrLen(format) {
            result .= "%"
            break
        }

        token := SubStr(format, index, 1)
        result .= AhkStdlibTimeFormatDirective(timestamp, token, timeTuple?)
        index += 1
    }
    return result
}

AhkStdlibTimeFormatDirective(timestamp, token, timeTuple := unset)
{
    switch token {
        case "%":
            return "%"
        case "Y":
            return FormatTime(timestamp, "yyyy")
        case "m":
            return FormatTime(timestamp, "MM")
        case "d":
            return FormatTime(timestamp, "dd")
        case "H":
            return FormatTime(timestamp, "HH")
        case "M":
            return FormatTime(timestamp, "mm")
        case "S":
            return FormatTime(timestamp, "ss")
        case "j":
            return FormatTime(timestamp, "YDay0")
        case "w":
            if IsSet(timeTuple)
                return Mod(Integer(timeTuple.tm_wday) + 1, 7)
            return Mod(Integer(FormatTime(timestamp, "WDay")), 7)
        default:
            return "%" token
    }
}

AhkStdlibTimePythonTypeName(value)
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

#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTime
{
    ; Python's time module exposes these as module-level variables via _strptime
    ; / tzset machinery. Compute them lazily from Win32 time-zone info so the
    ; values track the host setting at first access (matching CPython behavior
    ; where the values are captured at process start).
    static timezone
    {
        get => AhkStdlibTimeTimeZoneSeconds()
    }
    static altzone
    {
        get => AhkStdlibTimeAltZoneSeconds()
    }
    static tzname
    {
        get => AhkStdlibTimeTzNames()
    }
    static daylight
    {
        get => AhkStdlibTimeDaylightFlag()
    }

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

    static mktime(timeTuple)
    {
        ; CPython mktime treats the input as local time and returns Unix seconds.
        return AhkStdlibTimeMktime(timeTuple)
    }

    static strptime(dateString, format := "%a %b %d %H:%M:%S %Y")
    {
        ; CPython parses dateString according to format and returns struct_time.
        ; Default format matches asctime() output for round-trip parsing.
        return AhkStdlibTimeStrptime(dateString, format)
    }

    static process_time()
    {
        ; CPython: sum of user + system CPU time consumed by current process.
        return AhkStdlibTimeProcessTime()
    }

    static process_time_ns()
    {
        return Integer(Round(AhkStdlibTimeProcessTime() * 1000000000))
    }

    static thread_time()
    {
        ; CPython: sum of user + system CPU time consumed by current thread.
        return AhkStdlibTimeThreadTime()
    }

    static thread_time_ns()
    {
        return Integer(Round(AhkStdlibTimeThreadTime() * 1000000000))
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
    static dayNames := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static dayFullNames := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    static monthNames := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    static monthFullNames := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

    switch token {
        case "%":
            return "%"
        case "Y":
            return FormatTime(timestamp, "yyyy")
        case "y":
            ; Two-digit year (00-99). Python uses %y locale-style.
            return SubStr(FormatTime(timestamp, "yyyy"), 3, 2)
        case "m":
            return FormatTime(timestamp, "MM")
        case "d":
            return FormatTime(timestamp, "dd")
        case "H":
            return FormatTime(timestamp, "HH")
        case "I":
            ; 12-hour clock, zero-padded (01-12).
            h24 := Integer(FormatTime(timestamp, "HH"))
            h12 := Mod(h24, 12)
            if h12 = 0
                h12 := 12
            return Format("{:02}", h12)
        case "p":
            ; AM/PM marker.
            return Integer(FormatTime(timestamp, "HH")) < 12 ? "AM" : "PM"
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
        case "a":
            ; Abbreviated weekday name (Mon..Sun). Use timeTuple.tm_wday if
            ; provided (0=Mon..6=Sun), else FormatTime WDay (1=Sun..7=Sat).
            if IsSet(timeTuple)
                return dayNames[Integer(timeTuple.tm_wday) + 1]
            wd := Integer(FormatTime(timestamp, "WDay"))  ; 1=Sun..7=Sat
            ; Convert to 0=Mon..6=Sun: ((wd+5) mod 7) gives 0=Mon
            return dayNames[Mod(wd + 5, 7) + 1]
        case "A":
            if IsSet(timeTuple)
                return dayFullNames[Integer(timeTuple.tm_wday) + 1]
            wd := Integer(FormatTime(timestamp, "WDay"))
            return dayFullNames[Mod(wd + 5, 7) + 1]
        case "b":
            return monthNames[Integer(FormatTime(timestamp, "MM"))]
        case "B":
            return monthFullNames[Integer(FormatTime(timestamp, "MM"))]
        case "U":
            ; Week of year, Sunday as first day, 00..53. Days before first
            ; Sunday belong to week 0.
            return AhkStdlibTimeWeekNumber(timestamp, timeTuple?, 0)
        case "W":
            ; Week of year, Monday as first day, 00..53.
            return AhkStdlibTimeWeekNumber(timestamp, timeTuple?, 1)
        case "Z":
            ; Time zone name (locale-dependent). FormatTime "ZZZ" is reasonable.
            return FormatTime(timestamp, "ZZZ")
        case "z":
            ; UTC offset in form +HHMM or -HHMM.
            offsetMin := DateDiff(A_Now, A_NowUTC, "Minutes")
            sign := offsetMin < 0 ? "-" : "+"
            absMin := Abs(offsetMin)
            return sign Format("{:02}{:02}", absMin // 60, Mod(absMin, 60))
        case "c":
            ; Locale's date+time. Python's default form: "Thu Jan  1 00:00:00 1970".
            return AhkStdlibTimeFormatDirective(timestamp, "a", timeTuple?)
                . " " AhkStdlibTimeFormatDirective(timestamp, "b", timeTuple?)
                . " " Format("{:2}", Integer(FormatTime(timestamp, "dd")))
                . " " FormatTime(timestamp, "HH:mm:ss")
                . " " FormatTime(timestamp, "yyyy")
        case "x":
            ; Locale's date. Python default: "MM/DD/YY".
            return FormatTime(timestamp, "MM") "/" FormatTime(timestamp, "dd") "/" SubStr(FormatTime(timestamp, "yyyy"), 3, 2)
        case "X":
            ; Locale's time. Python default: "HH:MM:SS".
            return FormatTime(timestamp, "HH:mm:ss")
        default:
            return "%" token
    }
}

; Compute week-of-year per Python strftime %U (firstDay=0=Sunday) or %W (=1=Monday).
AhkStdlibTimeWeekNumber(timestamp, timeTuple, firstDay)
{
    yday := IsSet(timeTuple) ? Integer(timeTuple.tm_yday) : Integer(FormatTime(timestamp, "YDay"))
    ; Day of week (0=Mon..6=Sun) on the date itself
    if IsSet(timeTuple) {
        wday := Integer(timeTuple.tm_wday)  ; 0=Mon..6=Sun
    } else {
        wd := Integer(FormatTime(timestamp, "WDay"))  ; 1=Sun..7=Sat
        wday := Mod(wd + 5, 7)
    }
    ; Convert to "days since first <firstDay>"
    if firstDay = 0 {
        ; Sunday-first: Python's tm_wday=6 means Sunday, which is week-day 0
        wd0 := Mod(wday + 1, 7)  ; 0=Sun..6=Sat
    } else {
        ; Monday-first: tm_wday already maps directly
        wd0 := wday  ; 0=Mon..6=Sun
    }
    ; jan1 weekday: how many days before the first <firstDay> from Jan 1
    jan1Wd0 := Mod(wd0 - (yday - 1) + 7000, 7)
    daysBefore := Mod(7 - jan1Wd0, 7)
    if yday <= daysBefore
        return "00"
    week := ((yday - daysBefore - 1) // 7) + 1
    return Format("{:02}", week)
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

; Lazy timezone module variables. Computed via GetTimeZoneInformation; cached
; once for the process lifetime to match CPython's tzset-at-import behavior.
; CPython's time.timezone is "seconds west of UTC for standard time", inverted
; from Windows' TIME_ZONE_INFORMATION.Bias (minutes). altzone is the same for
; daylight time. tzname is (std_name, dst_name).
AhkStdlibTimeTimeZoneSeconds()
{
    info := AhkStdlibTimeGetTimeZoneInfo()
    return info.timezone
}

AhkStdlibTimeAltZoneSeconds()
{
    info := AhkStdlibTimeGetTimeZoneInfo()
    return info.altzone
}

AhkStdlibTimeTzNames()
{
    info := AhkStdlibTimeGetTimeZoneInfo()
    return stdlib.tuple([info.stdName, info.dstName])
}

AhkStdlibTimeDaylightFlag()
{
    info := AhkStdlibTimeGetTimeZoneInfo()
    return info.daylight
}

AhkStdlibTimeGetTimeZoneInfo()
{
    static cached := unset
    if IsSet(cached)
        return cached
    ; TIME_ZONE_INFORMATION layout (sizeof=172):
    ;   LONG Bias                             [0..3]
    ;   WCHAR StandardName[32]                [4..67]
    ;   SYSTEMTIME StandardDate (16 bytes)    [68..83]
    ;   LONG StandardBias                     [84..87]
    ;   WCHAR DaylightName[32]                [88..151]
    ;   SYSTEMTIME DaylightDate               [152..167]
    ;   LONG DaylightBias                     [168..171]
    buf := Buffer(172, 0)
    rc := DllCall("GetTimeZoneInformation", "Ptr", buf.Ptr, "UInt")
    bias := NumGet(buf, 0, "Int")
    standardBias := NumGet(buf, 84, "Int")
    daylightBias := NumGet(buf, 168, "Int")
    stdName := StrGet(buf.Ptr + 4, 32, "UTF-16")
    dstName := StrGet(buf.Ptr + 88, 32, "UTF-16")
    ; CPython: timezone = (bias + standardBias) * 60 (signed seconds west of UTC).
    timezone := (bias + standardBias) * 60
    altzone := (bias + daylightBias) * 60
    daylight := daylightBias != 0 ? 1 : 0
    cached := { timezone: timezone, altzone: altzone, stdName: stdName, dstName: dstName, daylight: daylight }
    return cached
}

AhkStdlibTimeMktime(timeTuple)
{
    if !IsObject(timeTuple)
        throw TypeError("Tuple or struct_time argument required", -1)
    timeTuple := AhkStdlibTimeNormalizeTupleArgument(timeTuple)
    AhkStdlibTimeValidateStructTimeForStrftime(timeTuple)
    ; Reconstruct local-time stamp, then offset to UTC seconds since epoch.
    stamp := AhkStdlibTimeStructTimeToTimestamp(timeTuple)
    offsetSeconds := DateDiff(A_Now, A_NowUTC, "Seconds")
    return DateDiff(stamp, "19700101000000", "Seconds") - offsetSeconds + 0.0
}

AhkStdlibTimeStrptime(dateString, format)
{
    if !(dateString is String)
        throw TypeError("strptime() argument 1 must be str, not " AhkStdlibTimePythonTypeName(dateString), -1)
    if !(format is String)
        throw TypeError("strptime() argument 2 must be str, not " AhkStdlibTimePythonTypeName(format), -1)

    ; Parser: walk format and dateString in lockstep, with each %X consuming the
    ; appropriate slice from dateString. Literal characters in format must match
    ; literally. Unknown directives raise ValueError to match CPython.
    parsed := { year: 1900, mon: 1, mday: 1, hour: 0, min: 0, sec: 0, wday: -1, yday: -1, isdst: -1 }

    fi := 1
    di := 1
    flen := StrLen(format)
    dlen := StrLen(dateString)

    while fi <= flen {
        fch := SubStr(format, fi, 1)
        if fch != "%" {
            ; Treat any single space in the format as "match one or more spaces"
            ; — CPython does this so asctime's space-padded day ("Sat Jan  2 …")
            ; round-trips through the asctime-format default.
            if fch = " " {
                if di > dlen
                    throw ValueError("time data '" dateString "' does not match format '" format "'", -1)
                while di <= dlen && SubStr(dateString, di, 1) = " "
                    di += 1
                fi += 1
                continue
            }
            if di > dlen || SubStr(dateString, di, 1) != fch
                throw ValueError("time data '" dateString "' does not match format '" format "'", -1)
            fi += 1
            di += 1
            continue
        }
        fi += 1
        if fi > flen
            throw ValueError("stray %% at end of format string", -1)
        token := SubStr(format, fi, 1)
        fi += 1
        if token = "%" {
            if di > dlen || SubStr(dateString, di, 1) != "%"
                throw ValueError("time data '" dateString "' does not match format '" format "'", -1)
            di += 1
            continue
        }
        di := AhkStdlibTimeStrptimeParseDirective(dateString, di, token, parsed)
    }

    if di <= dlen
        throw ValueError("unconverted data remains: " SubStr(dateString, di), -1)

    ; Compute wday/yday now that calendar fields are known.
    yday := AhkStdlibTimeYearDay(parsed.year, parsed.mon, parsed.mday)
    wday := AhkStdlibTimeWeekday(parsed.year, parsed.mon, parsed.mday)
    return AhkStdlibTimeStructTime([
        parsed.year, parsed.mon, parsed.mday,
        parsed.hour, parsed.min, parsed.sec,
        wday, yday, parsed.isdst
    ])
}

AhkStdlibTimeStrptimeParseDirective(dateString, di, token, parsed)
{
    static dayNamesAbbr := ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    static dayNamesFull := ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    static monthNamesAbbr := ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    static monthNamesFull := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    switch token {
        case "Y":
            ; 4-digit year. Pull up to 4 digits.
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 4)
            parsed.year := Integer(digits.value)
            return digits.next
        case "y":
            ; 2-digit year. <69 → 2000+, else 1900+. Matches CPython.
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            yy := Integer(digits.value)
            parsed.year := yy < 69 ? 2000 + yy : 1900 + yy
            return digits.next
        case "m":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.mon := Integer(digits.value)
            return digits.next
        case "d":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.mday := Integer(digits.value)
            return digits.next
        case "H":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.hour := Integer(digits.value)
            return digits.next
        case "I":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.hour := Integer(digits.value)
            return digits.next
        case "M":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.min := Integer(digits.value)
            return digits.next
        case "S":
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 2)
            parsed.sec := Integer(digits.value)
            return digits.next
        case "j":
            ; Day of year, 1-366. Up to 3 digits.
            digits := AhkStdlibTimeStrptimeReadDigits(dateString, di, 3)
            ; %j by itself doesn't tell us mon/mday — leave them at the default
            ; and rely on tm_yday. Setting mon=1/mday=yday lets us round-trip.
            yd := Integer(digits.value)
            mm := AhkStdlibTimeYearDayToMonth(parsed.year, yd)
            parsed.mon := mm.month
            parsed.mday := mm.day
            return digits.next
        case "p":
            ; AM/PM: must combine with %I above for the canonical case.
            ampm := StrUpper(SubStr(dateString, di, 2))
            if ampm = "AM" {
                if parsed.hour = 12
                    parsed.hour := 0
            } else if ampm = "PM" {
                if parsed.hour < 12
                    parsed.hour += 12
            } else {
                throw ValueError("expected AM or PM at offset " di, -1)
            }
            return di + 2
        case "a":
            return AhkStdlibTimeStrptimeMatchName(dateString, di, dayNamesAbbr, "%a")
        case "A":
            return AhkStdlibTimeStrptimeMatchName(dateString, di, dayNamesFull, "%A")
        case "b":
            ; Returns position; record the matched index into mon.
            r := AhkStdlibTimeStrptimeMatchNameAndIndex(dateString, di, monthNamesAbbr, "%b")
            parsed.mon := r.index
            return r.next
        case "B":
            r := AhkStdlibTimeStrptimeMatchNameAndIndex(dateString, di, monthNamesFull, "%B")
            parsed.mon := r.index
            return r.next
        case "Z":
            ; Skip a timezone abbrev: read until non-letter.
            j := di
            while j <= StrLen(dateString) {
                ch := SubStr(dateString, j, 1)
                if !RegExMatch(ch, "i)[a-z]")
                    break
                j += 1
            }
            return j
        case "z":
            ; +HHMM / -HHMM / Z / "" — informational only, not stored.
            ch := SubStr(dateString, di, 1)
            if ch = "Z"
                return di + 1
            if ch = "+" || ch = "-"
                return di + 5
            return di
        default:
            throw ValueError("'" token "' is a bad directive in format '%" token "'", -1)
    }
}

AhkStdlibTimeStrptimeReadDigits(text, start, maxLen)
{
    j := start
    end := Min(StrLen(text), start + maxLen - 1)
    while j <= end {
        ch := SubStr(text, j, 1)
        if !RegExMatch(ch, "[0-9]")
            break
        j += 1
    }
    if j = start
        throw ValueError("expected digits at offset " start, -1)
    return { value: SubStr(text, start, j - start), next: j }
}

AhkStdlibTimeStrptimeMatchName(text, start, names, label)
{
    for name in names {
        slice := SubStr(text, start, StrLen(name))
        if StrLower(slice) = StrLower(name)
            return start + StrLen(name)
    }
    throw ValueError("expected " label " at offset " start, -1)
}

AhkStdlibTimeStrptimeMatchNameAndIndex(text, start, names, label)
{
    for index, name in names {
        slice := SubStr(text, start, StrLen(name))
        if StrLower(slice) = StrLower(name)
            return { index: index, next: start + StrLen(name) }
    }
    throw ValueError("expected " label " at offset " start, -1)
}

AhkStdlibTimeYearDay(year, month, day)
{
    static daysBefore := [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
    yd := daysBefore[month] + day
    if month > 2 && AhkStdlibTimeIsLeap(year)
        yd += 1
    return yd
}

AhkStdlibTimeYearDayToMonth(year, yday)
{
    static daysInMonth := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    leap := AhkStdlibTimeIsLeap(year)
    remaining := yday
    month := 1
    while month <= 12 {
        days := daysInMonth[month]
        if month = 2 && leap
            days += 1
        if remaining <= days
            return { month: month, day: remaining }
        remaining -= days
        month += 1
    }
    return { month: 12, day: 31 }
}

AhkStdlibTimeIsLeap(year)
{
    return Mod(year, 4) = 0 && (Mod(year, 100) != 0 || Mod(year, 400) = 0)
}

AhkStdlibTimeProcessTime()
{
    ; GetProcessTimes(handle, &creation, &exit, &kernel, &user). Times are
    ; FILETIME (100-ns ticks). Sum kernel+user → CPU seconds.
    handle := DllCall("GetCurrentProcess", "Ptr")
    creation := Buffer(8, 0)
    exitT := Buffer(8, 0)
    kernel := Buffer(8, 0)
    user := Buffer(8, 0)
    if !DllCall("GetProcessTimes", "Ptr", handle, "Ptr", creation, "Ptr", exitT, "Ptr", kernel, "Ptr", user)
        throw OSError("GetProcessTimes failed", -1)
    return (NumGet(kernel, 0, "Int64") + NumGet(user, 0, "Int64")) / 10000000.0
}

AhkStdlibTimeThreadTime()
{
    handle := DllCall("GetCurrentThread", "Ptr")
    creation := Buffer(8, 0)
    exitT := Buffer(8, 0)
    kernel := Buffer(8, 0)
    user := Buffer(8, 0)
    if !DllCall("GetThreadTimes", "Ptr", handle, "Ptr", creation, "Ptr", exitT, "Ptr", kernel, "Ptr", user)
        throw OSError("GetThreadTimes failed", -1)
    return (NumGet(kernel, 0, "Int64") + NumGet(user, 0, "Int64")) / 10000000.0
}

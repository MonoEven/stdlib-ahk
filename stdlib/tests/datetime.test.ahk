#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\datetime>
#Include <stdlib\operator>

class StdlibDateTimeTest
{
    static TestTimezoneAndModuleConstantsMatchObservedLocal310()
    {
        AhkTest.AssertEqual(1, stdlib.datetime.MINYEAR)
        AhkTest.AssertEqual(9999, stdlib.datetime.MAXYEAR)

        tzinfo := stdlib.datetime.tzinfo()
        AhkTest.RaisesMatch(stdlib.NotImplementedError, "a tzinfo subclass must implement utcoffset\(\)", (*) => tzinfo.utcoffset(stdlib.None))
        AhkTest.RaisesMatch(stdlib.NotImplementedError, "a tzinfo subclass must implement dst\(\)", (*) => tzinfo.dst(stdlib.None))
        AhkTest.RaisesMatch(stdlib.NotImplementedError, "a tzinfo subclass must implement tzname\(\)", (*) => tzinfo.tzname(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "fromutc: argument must be a datetime", (*) => tzinfo.fromutc(stdlib.None))

        utc := stdlib.datetime.timezone.utc
        plus := stdlib.datetime.timezone(stdlib.datetime.timedelta({ hours: 5, minutes: 30 }), "IST")
        minus := stdlib.datetime.timezone(stdlib.datetime.timedelta({ hours: -4 }))

        AhkTest.AssertEqual("AhkStdlibDateTimeTimezone", Type(utc))
        AhkTest.AssertTrue(utc.__AhkStdlibDateTimeIsTzInfo)
        AhkTest.AssertEqual("UTC", String(utc))
        AhkTest.AssertEqual("UTC", utc.tzname(stdlib.None))
        AhkTest.AssertEqual("0:00:00", String(utc.utcoffset(stdlib.None)))
        AhkTest.AssertSame(stdlib.None, utc.dst(stdlib.None))
        AhkTest.AssertEqual("IST", String(plus))
        AhkTest.AssertEqual("IST", plus.tzname(stdlib.None))
        AhkTest.AssertEqual("5:30:00", String(plus.utcoffset(stdlib.None)))
        AhkTest.AssertSame(stdlib.None, plus.dst(stdlib.None))
        AhkTest.AssertEqual("UTC-04:00", String(minus))
        AhkTest.AssertEqual("UTC-04:00", minus.tzname(stdlib.None))
        AhkTest.AssertEqual("-1 day, 20:00:00", String(minus.utcoffset(stdlib.None)))

        AhkTest.RaisesMatch(TypeError, "timezone\(\) missing required argument 'offset' \(pos 1\)", (*) => stdlib.datetime.timezone())
        AhkTest.RaisesMatch(TypeError, "timezone\(\) argument 1 must be datetime\.timedelta, not int", (*) => stdlib.datetime.timezone(1))
        AhkTest.RaisesMatch(TypeError, "timezone\(\) argument 2 must be str, not int", (*) => stdlib.datetime.timezone(stdlib.datetime.timedelta({ hours: 1 }), 1))
        AhkTest.RaisesMatch(ValueError, "offset must be a timedelta strictly between -timedelta\(hours=24\) and timedelta\(hours=24\), not datetime\.timedelta\(days=1\)\.", (*) => stdlib.datetime.timezone(stdlib.datetime.timedelta({ hours: 24 })))
    }

    static TestDatetimeConstructsFormatsAndReplacesLikePython310()
    {
        value := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)

        AhkTest.AssertEqual(2024, value.year)
        AhkTest.AssertEqual(2, value.month)
        AhkTest.AssertEqual(29, value.day)
        AhkTest.AssertEqual(1, value.hour)
        AhkTest.AssertEqual(2, value.minute)
        AhkTest.AssertEqual(3, value.second)
        AhkTest.AssertEqual(456789, value.microsecond)
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", String(value))
        AhkTest.AssertEqual("2024-02-29T01:02:03.456789", value.isoformat())
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", value.isoformat(" "))
        AhkTest.AssertEqual("2024-02-29", String(value.date()))
        AhkTest.AssertEqual("01:02:03.456789", String(value.time()))
        AhkTest.AssertEqual("2023-03-01 04:05:06.000007", String(value.replace({ year: 2023, month: 3, day: 1, hour: 4, minute: 5, second: 6, microsecond: 7 })))
    }

    static TestDatetimeIsoformatTimespecLikePython310()
    {
        base := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)
        zeroMicros := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3)

        AhkTest.AssertEqual("2024-02-29T01:02:03.456789", base.isoformat())
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", base.isoformat(" "))
        AhkTest.AssertEqual("2024-02-29 01:02:03", zeroMicros.isoformat(" ", "auto"))
        AhkTest.AssertEqual("2024-02-29T01", base.isoformat("T", "hours"))
        AhkTest.AssertEqual("2024-02-29T01:02", base.isoformat("T", "minutes"))
        AhkTest.AssertEqual("2024-02-29T01:02:03", base.isoformat("T", "seconds"))
        AhkTest.AssertEqual("2024-02-29T01:02:03.456", base.isoformat("T", "milliseconds"))
        AhkTest.AssertEqual("2024-02-29T01:02:03.456789", base.isoformat("T", "microseconds"))
    }

    static TestDatetimeIsoformatTimespecRejectsInvalidValues()
    {
        base := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)

        AhkTest.RaisesMatch(TypeError, "isoformat\(\) argument 1 must be a unicode character, not int", (*) => base.isoformat(1))
        AhkTest.RaisesMatch(TypeError, "isoformat\(\) argument 2 must be str, not int", (*) => base.isoformat("T", 1))
        AhkTest.RaisesMatch(ValueError, "Unknown timespec value", (*) => base.isoformat("T", "x"))
    }

    static TestDatetimeNowAndFromtimestampLikePython310()
    {
        fromZero := stdlib.datetime.datetime.fromtimestamp(0)
        fromFraction := stdlib.datetime.datetime.fromtimestamp(1.5)
        now := stdlib.datetime.datetime.now()

        AhkTest.AssertEqual("1970-01-01 08:00:00", String(fromZero))
        AhkTest.AssertEqual("1970-01-01 08:00:01.500000", String(fromFraction))
        AhkTest.AssertEqual(FormatTime(A_Now, "yyyy-MM-dd"), String(now.date()))
        AhkTest.AssertTrue(now.hour >= 0 && now.hour <= 23)
        AhkTest.AssertTrue(now.minute >= 0 && now.minute <= 59)
        AhkTest.AssertTrue(now.second >= 0 && now.second <= 59)
        AhkTest.AssertTrue(now.microsecond >= 0 && now.microsecond <= 999999)
    }

    static TestDatetimeRejectsPython310InvalidArguments()
    {
        AhkTest.RaisesMatch(ValueError, "hour must be in 0..23", (*) => stdlib.datetime.datetime(2024, 2, 29, 24, 0, 0))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.datetime.fromtimestamp("1"))
    }

    static TestDatetimeSupportsTimedeltaArithmeticAndComparisonLikePython310()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)
        earlier := stdlib.datetime.datetime(2024, 2, 28, 23, 2, 3, 456789)
        slightlyEarlier := stdlib.datetime.datetime(2024, 2, 28, 23, 2, 2, 456788)

        AhkTest.AssertEqual("2024-03-01 01:02:05.456789", String(stdlib.operator.add(moment, stdlib.datetime.timedelta({ days: 1, seconds: 2 }))))
        AhkTest.AssertEqual("2024-02-28 23:02:03.456789", String(stdlib.operator.sub(moment, stdlib.datetime.timedelta({ hours: 2 }))))
        AhkTest.AssertEqual("2:00:00", String(stdlib.operator.sub(moment, earlier)))
        AhkTest.AssertEqual("2:00:01.000001", String(stdlib.operator.sub(moment, slightlyEarlier)))
        AhkTest.AssertTrue(stdlib.operator.gt(moment, earlier))
        AhkTest.AssertTrue(stdlib.operator.eq(moment, stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)))
    }

    static TestDatetimeRejectsUnsupportedArithmeticLikePython310()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)

        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for \+: 'datetime\.datetime' and 'str'", (*) => stdlib.operator.add(moment, "x"))
        AhkTest.RaisesMatch(TypeError, "unsupported operand type\(s\) for -: 'datetime\.datetime' and 'str'", (*) => stdlib.operator.sub(moment, "x"))
    }

    static TestDatetimeCrossTypeEqualityReturnsPython310Booleans()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 0, 0, 0)
        leapDay := stdlib.datetime.date(2024, 2, 29)
        day := stdlib.datetime.timedelta({ days: 1 })

        AhkTest.AssertFalse(stdlib.operator.eq(moment, leapDay))
        AhkTest.AssertTrue(stdlib.operator.ne(moment, leapDay))
        AhkTest.AssertFalse(stdlib.operator.eq(leapDay, moment))
        AhkTest.AssertTrue(stdlib.operator.ne(leapDay, moment))
        AhkTest.AssertFalse(stdlib.operator.eq(day, 1))
        AhkTest.AssertTrue(stdlib.operator.ne(day, 1))
    }

    static TestDatetimeTodayCtimeAndStrftimeLikePython310()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)
        today := stdlib.datetime.datetime.today()

        AhkTest.AssertEqual("Thu Feb 29 01:02:03 2024", moment.ctime())
        AhkTest.AssertEqual("2024-02-29 01:02:03", moment.strftime("%Y-%m-%d %H:%M:%S"))
        AhkTest.AssertEqual("456789", moment.strftime("%f"))
        AhkTest.AssertEqual("2024-02-29T01:02:03.456789", moment.strftime("%Y-%m-%dT%H:%M:%S.%f"))
        AhkTest.AssertEqual(FormatTime(A_Now, "yyyy-MM-dd"), String(today.date()))
        AhkTest.AssertTrue(today.hour >= 0 && today.hour <= 23)
        AhkTest.AssertTrue(today.minute >= 0 && today.minute <= 59)
        AhkTest.AssertTrue(today.second >= 0 && today.second <= 59)
        AhkTest.AssertTrue(today.microsecond >= 0 && today.microsecond <= 999999)
    }

    static TestDatetimeStrftimeRejectsInvalidFormatLikePython310()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)

        AhkTest.RaisesMatch(TypeError, "strftime\(\) argument 1 must be str, not int", (*) => moment.strftime(1))
    }

    static TestDatetimeUtcfromtimestampAndUtcnowLikePython310()
    {
        fromZero := stdlib.datetime.datetime.utcfromtimestamp(0)
        fromFraction := stdlib.datetime.datetime.utcfromtimestamp(1.5)
        utcNow := stdlib.datetime.datetime.utcnow()

        AhkTest.AssertEqual("1970-01-01 00:00:00", String(fromZero))
        AhkTest.AssertEqual("1970-01-01 00:00:01.500000", String(fromFraction))
        AhkTest.AssertEqual(FormatTime(A_NowUTC, "yyyy-MM-dd"), String(utcNow.date()))
        AhkTest.AssertTrue(utcNow.hour >= 0 && utcNow.hour <= 23)
        AhkTest.AssertTrue(utcNow.minute >= 0 && utcNow.minute <= 59)
        AhkTest.AssertTrue(utcNow.second >= 0 && utcNow.second <= 59)
        AhkTest.AssertTrue(utcNow.microsecond >= 0 && utcNow.microsecond <= 999999)
    }

    static TestDatetimeUtcfromtimestampRejectsPython310InvalidValues()
    {
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.datetime.utcfromtimestamp("1"))
        AhkTest.RaisesMatch(OSError, "Invalid argument", (*) => stdlib.datetime.datetime.utcfromtimestamp(-86400))
    }

    static TestDatetimeFromisoformatParsesPython310SupportedShapes()
    {
        dateOnly := stdlib.datetime.datetime.fromisoformat("2024-02-29")
        withSpace := stdlib.datetime.datetime.fromisoformat("2024-02-29 01:02:03")
        withMicros := stdlib.datetime.datetime.fromisoformat("2024-02-29T01:02:03.456789")
        withMillis := stdlib.datetime.datetime.fromisoformat("2024-02-29T01:02:03.456")

        AhkTest.AssertEqual("2024-02-29 00:00:00", String(dateOnly))
        AhkTest.AssertEqual("2024-02-29 01:02:03", String(withSpace))
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", String(withMicros))
        AhkTest.AssertEqual("2024-02-29 01:02:03.456000", String(withMillis))
    }

    static TestDatetimeFromisoformatRejectsPython310InvalidShapes()
    {
        AhkTest.RaisesMatch(TypeError, "fromisoformat: argument must be str", (*) => stdlib.datetime.datetime.fromisoformat(1))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: 'x'", (*) => stdlib.datetime.datetime.fromisoformat("x"))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: '2024-02-29T01:02:03.4'", (*) => stdlib.datetime.datetime.fromisoformat("2024-02-29T01:02:03.4"))
        AhkTest.RaisesMatch(ValueError, "day is out of range for month", (*) => stdlib.datetime.datetime.fromisoformat("2024-02-30"))
        AhkTest.RaisesMatch(ValueError, "hour must be in 0..23", (*) => stdlib.datetime.datetime.fromisoformat("2024-02-29T24:00:00"))
    }

    static TestDatetimeTimeObjectAndCombineLikePython310()
    {
        moment := stdlib.datetime.datetime(2024, 2, 29, 1, 2, 3, 456789)
        clock := stdlib.datetime.time(1, 2, 3, 456789)
        combinedFromDate := stdlib.datetime.datetime.combine(stdlib.datetime.date(2024, 2, 29), clock)
        combinedFromDatetime := stdlib.datetime.datetime.combine(stdlib.datetime.datetime(2024, 2, 29, 5, 6, 7), stdlib.datetime.time(1, 2, 3))

        AhkTest.AssertEqual("AhkStdlibDateTimeTimeValue", Type(clock))
        AhkTest.AssertEqual("01:02:03.456789", String(clock))
        AhkTest.AssertEqual("01:02:03.456789", clock.isoformat())
        AhkTest.AssertEqual("01:02:03.456789", String(moment.time()))
        AhkTest.AssertEqual("01:02:03.456789", moment.time().isoformat())
        AhkTest.AssertEqual("2024-02-29 01:02:03.456789", String(combinedFromDate))
        AhkTest.AssertEqual("2024-02-29 01:02:03", String(combinedFromDatetime))
    }

    static TestDatetimeTimeObjectAndCombineRejectInvalidValues()
    {
        AhkTest.RaisesMatch(ValueError, "hour must be in 0..23", (*) => stdlib.datetime.time(24, 0, 0))
        AhkTest.RaisesMatch(TypeError, "combine\(\) argument 1 must be datetime.date, not str", (*) => stdlib.datetime.datetime.combine("x", stdlib.datetime.time(1, 2, 3)))
        AhkTest.RaisesMatch(TypeError, "combine\(\) argument 2 must be datetime.time, not str", (*) => stdlib.datetime.datetime.combine(stdlib.datetime.date(2024, 2, 29), "x"))
    }

    static TestDatetimeTimeFromisoformatReplaceAndCompareLikePython310()
    {
        base := stdlib.datetime.time(1, 2, 3, 456789)
        fromMicros := stdlib.datetime.time.fromisoformat("01:02:03.456789")
        fromMillis := stdlib.datetime.time.fromisoformat("01:02:03.456")
        fromWhole := stdlib.datetime.time.fromisoformat("01:02:03")
        replaced := base.replace({ hour: 4, minute: 5, second: 6, microsecond: 7 })

        AhkTest.AssertEqual("01:02:03.456789", String(fromMicros))
        AhkTest.AssertEqual("01:02:03.456000", String(fromMillis))
        AhkTest.AssertEqual("01:02:03", String(fromWhole))
        AhkTest.AssertEqual("04:05:06.000007", String(replaced))
        AhkTest.AssertTrue(stdlib.operator.lt(stdlib.datetime.time(1, 2, 3), stdlib.datetime.time(1, 2, 4)))
        AhkTest.AssertTrue(stdlib.operator.eq(stdlib.datetime.time(1, 2, 3), stdlib.datetime.time(1, 2, 3)))
        AhkTest.AssertFalse(stdlib.operator.eq(stdlib.datetime.time(1, 2, 3), stdlib.datetime.date(2024, 2, 29)))
        AhkTest.AssertTrue(stdlib.operator.ne(stdlib.datetime.time(1, 2, 3), stdlib.datetime.date(2024, 2, 29)))
    }

    static TestDatetimeTimeFromisoformatReplaceAndCompareRejectInvalidValues()
    {
        AhkTest.RaisesMatch(TypeError, "fromisoformat: argument must be str", (*) => stdlib.datetime.time.fromisoformat(1))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: '1:2:3'", (*) => stdlib.datetime.time.fromisoformat("1:2:3"))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: '01:02:03.4'", (*) => stdlib.datetime.time.fromisoformat("01:02:03.4"))
        AhkTest.RaisesMatch(ValueError, "hour must be in 0..23", (*) => stdlib.datetime.time.fromisoformat("24:00:00"))
        AhkTest.RaisesMatch(ValueError, "hour must be in 0..23", (*) => stdlib.datetime.time(1, 2, 3).replace({ hour: 24 }))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.time(1, 2, 3).replace({ hour: "4" }))
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'datetime.time' and 'datetime.date'", (*) => stdlib.operator.lt(stdlib.datetime.time(1, 2, 3), stdlib.datetime.date(2024, 2, 29)))
    }

    static TestDatetimeTimeIsoformatTimespecAndStaticsLikePython310()
    {
        base := stdlib.datetime.time(1, 2, 3, 456789)

        AhkTest.AssertEqual("01:02:03.456789", base.isoformat())
        AhkTest.AssertEqual("01:02:03", stdlib.datetime.time(1, 2, 3).isoformat("auto"))
        AhkTest.AssertEqual("01", base.isoformat("hours"))
        AhkTest.AssertEqual("01:02", base.isoformat("minutes"))
        AhkTest.AssertEqual("01:02:03", base.isoformat("seconds"))
        AhkTest.AssertEqual("01:02:03.456", base.isoformat("milliseconds"))
        AhkTest.AssertEqual("01:02:03.456789", base.isoformat("microseconds"))
        AhkTest.AssertEqual("00:00:00", String(stdlib.datetime.time.min))
        AhkTest.AssertEqual("23:59:59.999999", String(stdlib.datetime.time.max))
        AhkTest.AssertEqual("0:00:00.000001", String(stdlib.datetime.time.resolution))
        AhkTest.AssertEqual("AhkStdlibDateTimeTimeValue", Type(stdlib.datetime.time.min))
        AhkTest.AssertEqual("AhkStdlibDateTimeTimeValue", Type(stdlib.datetime.time.max))
        AhkTest.AssertEqual("AhkStdlibDateTimeTimedelta", Type(stdlib.datetime.time.resolution))
    }

    static TestDatetimeTimeIsoformatTimespecRejectsInvalidValues()
    {
        base := stdlib.datetime.time(1, 2, 3, 456789)

        AhkTest.RaisesMatch(TypeError, "isoformat\(\) argument 1 must be str, not int", (*) => base.isoformat(1))
        AhkTest.RaisesMatch(ValueError, "Unknown timespec value", (*) => base.isoformat("x"))
    }

    static TestDateConstructsAndExposesPython310CalendarBehavior()
    {
        leapDay := stdlib.datetime.date(2024, 2, 29)
        fromOrdinal := stdlib.datetime.date.fromordinal(738945)

        AhkTest.AssertEqual(2024, leapDay.year)
        AhkTest.AssertEqual(2, leapDay.month)
        AhkTest.AssertEqual(29, leapDay.day)
        AhkTest.AssertEqual("2024-02-29", String(leapDay))
        AhkTest.AssertEqual("2024-02-29", leapDay.isoformat())
        AhkTest.AssertEqual(3, leapDay.weekday())
        AhkTest.AssertEqual(4, leapDay.isoweekday())
        AhkTest.AssertEqual(738945, leapDay.toordinal())
        AhkTest.AssertEqual("2024-02-29", String(fromOrdinal))
        AhkTest.AssertEqual("2023-03-01", String(leapDay.replace({ year: 2023, month: 3, day: 1 })))
    }

    static TestDateSupportsTimedeltaArithmeticAndDateComparisonLikePython310()
    {
        leapDay := stdlib.datetime.date(2024, 2, 29)
        monthStart := stdlib.datetime.date(2024, 2, 1)

        AhkTest.AssertEqual("2024-03-02", String(stdlib.operator.add(leapDay, stdlib.datetime.timedelta({ days: 2 }))))
        AhkTest.AssertEqual("2024-01-30", String(stdlib.operator.sub(leapDay, stdlib.datetime.timedelta({ days: 30 }))))
        AhkTest.AssertEqual("28 days, 0:00:00", String(stdlib.operator.sub(leapDay, monthStart)))
        AhkTest.AssertTrue(stdlib.operator.gt(leapDay, stdlib.datetime.date(2024, 2, 28)))
        AhkTest.AssertTrue(stdlib.operator.eq(leapDay, stdlib.datetime.date(2024, 2, 29)))
    }

    static TestDateRejectsPython310InvalidArgumentsAndRanges()
    {
        AhkTest.RaisesMatch(ValueError, "day is out of range for month", (*) => stdlib.datetime.date(2023, 2, 29))
        AhkTest.RaisesMatch(ValueError, "ordinal must be >= 1", (*) => stdlib.datetime.date.fromordinal(0))
        AhkTest.RaisesMatch(ValueError, "month must be in 1..12", (*) => stdlib.datetime.date(2024, 2, 29).replace({ month: 13 }))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.date.fromordinal("1"))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.date(2024, 2, 29).replace({ month: "3" }))
    }

    static TestDateFromtimestampCtimeAndIsocalendarLikePython310()
    {
        leapDay := stdlib.datetime.date(2024, 2, 29)
        yearBoundary := stdlib.datetime.date(2021, 1, 1)

        AhkTest.AssertEqual("1970-01-01", String(stdlib.datetime.date.fromtimestamp(0)))
        AhkTest.AssertEqual("1970-01-01", String(stdlib.datetime.date.fromtimestamp(1.5)))
        AhkTest.AssertEqual("Thu Feb 29 00:00:00 2024", leapDay.ctime())
        AhkTest.AssertEqual([2024, 9, 4], leapDay.isocalendar())
        AhkTest.AssertEqual([2020, 53, 5], yearBoundary.isocalendar())
    }

    static TestDateFromisoformatParsesPython310SupportedShape()
    {
        leapDay := stdlib.datetime.date.fromisoformat("2024-02-29")

        AhkTest.AssertEqual("2024-02-29", String(leapDay))
        AhkTest.AssertEqual(2024, leapDay.year)
        AhkTest.AssertEqual(2, leapDay.month)
        AhkTest.AssertEqual(29, leapDay.day)
    }

    static TestDateFromtimestampRejectsPython310InvalidValues()
    {
        AhkTest.RaisesMatch(OSError, "Invalid argument", (*) => stdlib.datetime.date.fromtimestamp(-0.1))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.datetime.date.fromtimestamp("1"))
    }

    static TestDateFromisoformatRejectsPython310InvalidShapes()
    {
        AhkTest.RaisesMatch(TypeError, "fromisoformat: argument must be str", (*) => stdlib.datetime.date.fromisoformat(1))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: 'x'", (*) => stdlib.datetime.date.fromisoformat("x"))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: '2024-2-29'", (*) => stdlib.datetime.date.fromisoformat("2024-2-29"))
        AhkTest.RaisesMatch(ValueError, "Invalid isoformat string: '20240229'", (*) => stdlib.datetime.date.fromisoformat("20240229"))
        AhkTest.RaisesMatch(ValueError, "day is out of range for month", (*) => stdlib.datetime.date.fromisoformat("2024-02-30"))
    }

    static TestDateTodayAndStaticBoundsLikePython310()
    {
        today := stdlib.datetime.date.today()

        AhkTest.AssertEqual(FormatTime(A_Now, "yyyy-MM-dd"), today.isoformat())
        AhkTest.AssertEqual("0001-01-01", stdlib.datetime.date.min.isoformat())
        AhkTest.AssertEqual("9999-12-31", stdlib.datetime.date.max.isoformat())
        AhkTest.AssertEqual("1 day, 0:00:00", String(stdlib.datetime.date.resolution))
        AhkTest.AssertEqual("AhkStdlibDateTimeDateValue", Type(stdlib.datetime.date.min))
        AhkTest.AssertEqual("AhkStdlibDateTimeDateValue", Type(stdlib.datetime.date.max))
        AhkTest.AssertEqual("AhkStdlibDateTimeTimedelta", Type(stdlib.datetime.date.resolution))
    }

    static TestTimedeltaConstructsAndNormalizesLikePython310()
    {
        zero := stdlib.datetime.timedelta()
        value := stdlib.datetime.timedelta({ days: 1, seconds: 90000, microseconds: 1000001 })
        weeks := stdlib.datetime.timedelta({ weeks: 1, days: 2 })
        negative := stdlib.datetime.timedelta({ hours: -5 })

        AhkTest.AssertEqual(0, zero.days)
        AhkTest.AssertEqual(0, zero.seconds)
        AhkTest.AssertEqual(0, zero.microseconds)
        AhkTest.AssertEqual(2, value.days)
        AhkTest.AssertEqual(3601, value.seconds)
        AhkTest.AssertEqual(1, value.microseconds)
        AhkTest.AssertEqual("2 days, 1:00:01.000001", String(value))
        AhkTest.AssertApprox(176401.000001, value.total_seconds())
        AhkTest.AssertEqual(9, weeks.days)
        AhkTest.AssertEqual(-1, negative.days)
        AhkTest.AssertEqual(68400, negative.seconds)
        AhkTest.AssertEqual("-1 day, 19:00:00", String(negative))
    }

    static TestTimedeltaSupportsComparisonArithmeticAndUnaryLikePython310()
    {
        day := stdlib.datetime.timedelta({ days: 1 })
        twoSeconds := stdlib.datetime.timedelta({ seconds: 2 })
        fiveHours := stdlib.datetime.timedelta({ hours: 5 })

        AhkTest.AssertTrue(stdlib.operator.gt(day, twoSeconds))
        AhkTest.AssertEqual("1 day, 0:00:02", String(stdlib.operator.add(day, twoSeconds)))
        AhkTest.AssertEqual("23:59:58", String(stdlib.operator.sub(day, twoSeconds)))
        AhkTest.AssertEqual("-1 day, 19:00:00", String(stdlib.operator.neg(fiveHours)))
        AhkTest.AssertEqual("5:00:00", String(stdlib.operator.pos(fiveHours)))
        AhkTest.AssertEqual("0:00:06", String(stdlib.operator.mul(stdlib.datetime.timedelta({ seconds: 2 }), 3)))
    }

    static TestTimedeltaRejectsInvalidComponentTypesAndRangesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "unsupported type for timedelta seconds component: str", (*) => stdlib.datetime.timedelta({ seconds: "1" }))
        AhkTest.RaisesMatch(stdlib.datetime.OverflowError, "days=1000000000; must have magnitude <= 999999999", (*) => stdlib.datetime.timedelta({ days: 1000000000 }))
    }
}

AhkTest.Collect(StdlibDateTimeTest)

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\time>

class StdlibTimeTest
{
    static TestStructTimeBuildsTupleLikePython310()
    {
        value := stdlib.time.struct_time([2024, 1, 2, 3, 4, 5, 1, 2, -1])

        AhkTest.AssertEqual(2024, value.tm_year)
        AhkTest.AssertEqual(1, value.tm_mon)
        AhkTest.AssertEqual(2, value.tm_mday)
        AhkTest.AssertEqual(3, value.tm_hour)
        AhkTest.AssertEqual(4, value.tm_min)
        AhkTest.AssertEqual(5, value.tm_sec)
        AhkTest.AssertEqual(1, value.tm_wday)
        AhkTest.AssertEqual(2, value.tm_yday)
        AhkTest.AssertEqual(-1, value.tm_isdst)
        AhkTest.AssertEqual(9, value.Length)
        AhkTest.AssertEqual([2024, 1, 2, 3, 4, 5, 1, 2, -1], StdlibTimeTest.ToArray(value))
    }

    static TestStructTimeRejectsShortSequencesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "takes an at least 9-sequence", (*) => stdlib.time.struct_time([2024, 1, 2]))
    }

    static TestTimeReturnsUnixEpochSecondsAsFloat()
    {
        before := DateDiff(A_NowUTC, "19700101000000", "Seconds") - 2
        value := stdlib.time.time()
        after := DateDiff(A_NowUTC, "19700101000000", "Seconds") + 2

        AhkTest.AssertEqual("Float", Type(value))
        AhkTest.AssertTrue(value >= before)
        AhkTest.AssertTrue(value <= after)
    }

    static TestTimeDoesNotMoveBackwardsAcrossImmediateCalls()
    {
        first := stdlib.time.time()
        second := stdlib.time.time()

        AhkTest.AssertTrue(second >= first)
    }

    static TestSleepAcceptsZeroAndReturnsNoValue()
    {
        result := stdlib.time.sleep(0)

        AhkTest.AssertEqual("", result)
    }

    static TestSleepRejectsNegativeAndNonNumericValuesLikePython()
    {
        AhkTest.RaisesMatch(ValueError, "sleep length must be non-negative", (*) => stdlib.time.sleep(-1))
        AhkTest.RaisesMatch(TypeError, "object cannot be interpreted as an integer", (*) => stdlib.time.sleep("1"))
    }

    static TestMonotonicReturnsFloatAndDoesNotMoveBackwards()
    {
        first := stdlib.time.monotonic()
        second := stdlib.time.monotonic()

        AhkTest.AssertEqual("Float", Type(first))
        AhkTest.AssertTrue(second >= first)
    }

    static TestMonotonicNsReturnsIntegerAndDoesNotMoveBackwards()
    {
        first := stdlib.time.monotonic_ns()
        second := stdlib.time.monotonic_ns()

        AhkTest.AssertEqual("Integer", Type(first))
        AhkTest.AssertTrue(second >= first)
    }

    static TestPerfCounterReturnsFloatAndDoesNotMoveBackwards()
    {
        first := stdlib.time.perf_counter()
        second := stdlib.time.perf_counter()

        AhkTest.AssertEqual("Float", Type(first))
        AhkTest.AssertTrue(second >= first)
    }

    static TestPerfCounterNsReturnsIntegerAndDoesNotMoveBackwards()
    {
        first := stdlib.time.perf_counter_ns()
        second := stdlib.time.perf_counter_ns()

        AhkTest.AssertEqual("Integer", Type(first))
        AhkTest.AssertTrue(second >= first)
    }

    static TestTimeNsReturnsIntegerAndTracksUnixEpochLikePython310()
    {
        before := (DateDiff(A_NowUTC, "19700101000000", "Seconds") - 2) * 1000000000
        value := stdlib.time.time_ns()
        after := (DateDiff(A_NowUTC, "19700101000000", "Seconds") + 2) * 1000000000

        AhkTest.AssertEqual("Integer", Type(value))
        AhkTest.AssertTrue(value >= before)
        AhkTest.AssertTrue(value <= after)
    }

    static TestGmtimeReturnsUtcStructTimeLikePython310()
    {
        value := stdlib.time.gmtime(0)

        AhkTest.AssertEqual([1970, 1, 1, 0, 0, 0, 3, 1, 0], StdlibTimeTest.ToArray(value))
        AhkTest.AssertEqual(1970, value.tm_year)
        AhkTest.AssertEqual(3, value.tm_wday)
        AhkTest.AssertEqual(1, value.tm_yday)
    }

    static TestLocaltimeReturnsLocalStructTimeLikePython310()
    {
        value := stdlib.time.localtime(0)

        AhkTest.AssertEqual([1970, 1, 1, 8, 0, 0, 3, 1, 0], StdlibTimeTest.ToArray(value))
        AhkTest.AssertEqual(1970, value.tm_year)
        AhkTest.AssertEqual(3, value.tm_wday)
        AhkTest.AssertEqual(1, value.tm_yday)
        AhkTest.AssertEqual(0, value.tm_isdst)
    }

    static TestLocaltimeFloorsFractionalSecondsLikePython310()
    {
        value := stdlib.time.localtime(1.5)

        AhkTest.AssertEqual([1970, 1, 1, 8, 0, 1, 3, 1, 0], StdlibTimeTest.ToArray(value))
    }

    static TestLocaltimeRejectsNegativeAndNonNumericValuesLikePython310()
    {
        AhkTest.RaisesMatch(OSError, "Invalid argument", (*) => stdlib.time.localtime(-0.1))
        AhkTest.RaisesMatch(TypeError, "object cannot be interpreted as an integer", (*) => stdlib.time.localtime("1"))
    }

    static TestAsctimeFormatsStructTimeLikePython310()
    {
        AhkTest.AssertEqual("Thu Jan  1 00:00:00 1970", stdlib.time.asctime(stdlib.time.gmtime(0)))
        AhkTest.AssertEqual("Thu Jan  1 08:00:00 1970", stdlib.time.asctime(stdlib.time.localtime(0)))
    }

    static TestAsctimeAcceptsStdlibTupleLikePython310()
    {
        value := stdlib.tuple([2024, 1, 2, 3, 4, 5, 1, 2, -1])

        AhkTest.AssertEqual("Tue Jan  2 03:04:05 2024", stdlib.time.asctime(value))
    }

    static TestAsctimeUsesCurrentLocalTimeWhenTupleIsOmitted()
    {
        actual := stdlib.time.asctime()

        AhkTest.AssertEqual(24, StrLen(actual))
        AhkTest.AssertTrue(actual ~= "^[A-Z][a-z]{2} [A-Z][a-z]{2} [ \d]\d \d\d:\d\d:\d\d \d{4}$")
    }

    static TestAsctimeRejectsInvalidTupleValuesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "Tuple or struct_time argument required", (*) => stdlib.time.asctime([2024, 1, 2, 3, 4, 5, 1, 2, -1]))
        AhkTest.RaisesMatch(ValueError, "month out of range", (*) => stdlib.time.asctime(stdlib.time.struct_time([2024, 13, 2, 3, 4, 5, 1, 2, -1])))
    }

    static TestCtimeFormatsLocalTimeLikePython310()
    {
        AhkTest.AssertEqual("Thu Jan  1 08:00:00 1970", stdlib.time.ctime(0))
        AhkTest.AssertEqual("Thu Jan  1 08:00:01 1970", stdlib.time.ctime(1.5))
    }

    static TestCtimeRejectsInvalidValuesLikePython310()
    {
        AhkTest.RaisesMatch(OSError, "Invalid argument", (*) => stdlib.time.ctime(-0.1))
        AhkTest.RaisesMatch(TypeError, "object cannot be interpreted as an integer", (*) => stdlib.time.ctime("1"))
    }

    static TestGmtimeFloorsFractionalSecondsLikePython310()
    {
        value := stdlib.time.gmtime(-0.1)

        AhkTest.AssertEqual([1969, 12, 31, 23, 59, 59, 3, 365, 0], StdlibTimeTest.ToArray(value))
    }

    static TestGmtimeRejectsNonNumericValuesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "object cannot be interpreted as an integer", (*) => stdlib.time.gmtime("1"))
        AhkTest.RaisesMatch(OSError, "Invalid argument", (*) => stdlib.time.gmtime(-86400))
    }

    static TestStrftimeFormatsStructTimeLikePython310()
    {
        value := stdlib.time.gmtime(0)

        AhkTest.AssertEqual("1970-01-01 00:00:00 001 4 %", stdlib.time.strftime("%Y-%m-%d %H:%M:%S %j %w %%", value))
    }

    static TestStrftimeAcceptsStdlibTupleLikePython310()
    {
        value := stdlib.tuple([2024, 1, 2, 3, 4, 5, 1, 2, -1])

        AhkTest.AssertEqual("2024-01-02 03:04:05", stdlib.time.strftime("%Y-%m-%d %H:%M:%S", value))
    }

    static TestStrftimeUsesCurrentLocalTimeWhenTupleIsOmitted()
    {
        actual := stdlib.time.strftime("%Y")

        AhkTest.AssertEqual(4, StrLen(actual))
        AhkTest.AssertTrue(actual ~= "^\d{4}$")
    }

    static TestStrftimeRejectsInvalidTupleValuesLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "Tuple or struct_time argument required", (*) => stdlib.time.strftime("%Y", [2024, 1, 2, 3, 4, 5, 1, 2, -1]))
        AhkTest.RaisesMatch(ValueError, "month out of range", (*) => stdlib.time.strftime("%Y", stdlib.time.struct_time([2024, 13, 2, 3, 4, 5, 1, 2, -1])))
    }

    static TestStrftimeFullDirectivesMatchPython310()
    {
        ; Reference values gated against py -3.10 time.strftime(fmt, time.gmtime(0))
        ; gmtime(0) -> 1970-01-01 00:00:00 Thursday, year-day 1.
        ; Build the equivalent struct_time directly to avoid timezone variance.
        t := stdlib.time.struct_time([1970, 1, 1, 0, 0, 0, 3, 1, 0])
        AhkTest.AssertEqual("Thu", stdlib.time.strftime("%a", t))
        AhkTest.AssertEqual("Thursday", stdlib.time.strftime("%A", t))
        AhkTest.AssertEqual("Jan", stdlib.time.strftime("%b", t))
        AhkTest.AssertEqual("January", stdlib.time.strftime("%B", t))
        AhkTest.AssertEqual("AM", stdlib.time.strftime("%p", t))
        AhkTest.AssertEqual("12", stdlib.time.strftime("%I", t))
        AhkTest.AssertEqual("70", stdlib.time.strftime("%y", t))
        AhkTest.AssertEqual("00", stdlib.time.strftime("%U", t))
        AhkTest.AssertEqual("00", stdlib.time.strftime("%W", t))
        AhkTest.AssertEqual("01/01/70", stdlib.time.strftime("%x", t))
        AhkTest.AssertEqual("00:00:00", stdlib.time.strftime("%X", t))

        ; PM marker on a non-zero hour
        t2 := stdlib.time.struct_time([2020, 2, 29, 13, 30, 45, 5, 60, 0])
        AhkTest.AssertEqual("PM", stdlib.time.strftime("%p", t2))
        AhkTest.AssertEqual("01", stdlib.time.strftime("%I", t2))
        AhkTest.AssertEqual("Sat", stdlib.time.strftime("%a", t2))
        AhkTest.AssertEqual("Saturday", stdlib.time.strftime("%A", t2))
        AhkTest.AssertEqual("Feb", stdlib.time.strftime("%b", t2))
    }

    static ToArray(iterable)
    {
        result := []
        for value in iterable
            result.Push(value)
        return result
    }
}

AhkTest.Collect(StdlibTimeTest)

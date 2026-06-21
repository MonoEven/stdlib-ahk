#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\toml>
#Include <stdlib\datetime>

class StdlibTomlTest
{
    static TestTomlDocumentUsesStdlibModuleNamespace()
    {
        doc := stdlib.toml.Toml().read("name = `"codex`"`nscore = 7")

        AhkTest.AssertEqual("Toml", Type(doc))
        AhkTest.AssertEqual("codex", doc.getString("name"))
        AhkTest.AssertEqual(7, doc.getLong("score"))
    }

    static TestInfAndNanMatchReferenceTomlPackage()
    {
        ; The reference `toml` package decodes inf/-inf/+inf/nan as floats.
        parsed := stdlib.toml.loads("a = inf`nb = -inf`nc = +inf`nd = nan")

        AhkTest.AssertEqual("Float", Type(parsed["a"]))
        AhkTest.AssertEqual("inf", String(parsed["a"]))
        AhkTest.AssertEqual("-inf", String(parsed["b"]))
        AhkTest.AssertEqual("inf", String(parsed["c"]))
        ; +inf compares greater than any finite value.
        AhkTest.AssertTrue(parsed["a"] > 1.0e300)
        AhkTest.AssertTrue(parsed["b"] < -1.0e300)
        ; nan is a float that is not equal to itself.
        AhkTest.AssertEqual("Float", Type(parsed["d"]))
        AhkTest.AssertEqual("nan", String(parsed["d"]))
        AhkTest.AssertTrue(parsed["d"] != parsed["d"])
    }

    static TestInfAndNanRoundTripThroughDumps()
    {
        source := Map("a", stdlib.toml.loads("x = inf")["x"], "b", stdlib.toml.loads("x = -inf")["x"], "c", stdlib.toml.loads("x = nan")["x"])
        text := stdlib.toml.dumps(source)
        ; dumps emits bare inf/-inf/nan tokens (matching the reference package).
        AhkTest.AssertTrue(InStr(text, "a = inf") > 0)
        AhkTest.AssertTrue(InStr(text, "b = -inf") > 0)
        AhkTest.AssertTrue(InStr(text, "c = nan") > 0)
    }

    static TestInlineTablesMatchReferenceTomlPackage()
    {
        parsed := stdlib.toml.loads("pt = { x = 1, y = 2 }")
        pt := parsed["pt"]
        AhkTest.AssertEqual("Map", Type(pt))
        AhkTest.AssertEqual(1, pt["x"])
        AhkTest.AssertEqual(2, pt["y"])

        ; nested inline tables + string values
        nested := stdlib.toml.loads("a = { nested = { deep = 3 }, name = `"z`" }")
        a := nested["a"]
        AhkTest.AssertEqual(3, a["nested"]["deep"])
        AhkTest.AssertEqual("z", a["name"])

        ; empty inline table
        empty := stdlib.toml.loads("empty = {}")
        AhkTest.AssertEqual("Map", Type(empty["empty"]))
        AhkTest.AssertEqual(0, empty["empty"].Count)

        ; dotted keys inside an inline table
        dotted := stdlib.toml.loads("p = { a.b = 1 }")
        AhkTest.AssertEqual(1, dotted["p"]["a"]["b"])
    }

    static TestMultilineStringsMatchReferenceTomlPackage()
    {
        ; Basic multiline string with a trimmed leading newline.
        src := "a = `"`"`"`nline one`nline two`"`"`"`nb = 1"
        parsed := stdlib.toml.loads(src)
        AhkTest.AssertEqual("line one`nline two", parsed["a"])
        AhkTest.AssertEqual(1, parsed["b"])

        ; Single-line triple-quoted basic string.
        one := stdlib.toml.loads("a = `"`"`"one line`"`"`"")
        AhkTest.AssertEqual("one line", one["a"])

        ; Multiline literal string ('''): no escape processing, newline kept.
        lit := stdlib.toml.loads("x = '''lit`neral'''")
        AhkTest.AssertEqual("lit`neral", lit["x"])
    }

    static TestDateTimeValuesCoercedToDatetimeObjects()
    {
        parsed := stdlib.toml.loads("d = 1979-05-27`ndt = 1979-05-27T07:32:00`nsp = 1979-05-27 07:32:00`nt = 07:32:00`nfrac = 1979-05-27T07:32:00.123")

        ; bare date -> date
        AhkTest.AssertEqual("AhkStdlibDateTimeDateValue", Type(parsed["d"]))
        AhkTest.AssertEqual(1979, parsed["d"].year)
        AhkTest.AssertEqual(5, parsed["d"].month)
        AhkTest.AssertEqual(27, parsed["d"].day)

        ; date+time (T separator) -> datetime
        AhkTest.AssertEqual("AhkStdlibDateTimeDateTimeValue", Type(parsed["dt"]))
        AhkTest.AssertEqual(7, parsed["dt"].hour)
        AhkTest.AssertEqual(32, parsed["dt"].minute)
        AhkTest.AssertEqual(0, parsed["dt"].second)

        ; space separator also -> datetime
        AhkTest.AssertEqual("AhkStdlibDateTimeDateTimeValue", Type(parsed["sp"]))
        AhkTest.AssertEqual(1979, parsed["sp"].year)

        ; bare time -> time
        AhkTest.AssertEqual("AhkStdlibDateTimeTimeValue", Type(parsed["t"]))
        AhkTest.AssertEqual(7, parsed["t"].hour)
        AhkTest.AssertEqual(32, parsed["t"].minute)

        ; fractional seconds -> microseconds
        AhkTest.AssertEqual(123000, parsed["frac"].microsecond)
    }

    static TestDateTimeRoundTripThroughDumps()
    {
        source := Map("d", stdlib.datetime.date(1979, 5, 27), "dt", stdlib.datetime.datetime(1979, 5, 27, 7, 32, 0), "t", stdlib.datetime.time(7, 32, 0))
        text := stdlib.toml.dumps(source)
        AhkTest.AssertTrue(InStr(text, "d = 1979-05-27") > 0)
        AhkTest.AssertTrue(InStr(text, "dt = 1979-05-27T07:32:00") > 0)
        AhkTest.AssertTrue(InStr(text, "t = 07:32:00") > 0)
    }
}

AhkTest.Collect(StdlibTomlTest)

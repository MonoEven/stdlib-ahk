#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\toml>

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
}

AhkTest.Collect(StdlibTomlTest)

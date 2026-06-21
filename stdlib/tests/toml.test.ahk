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
}

AhkTest.Collect(StdlibTomlTest)

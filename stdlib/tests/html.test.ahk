#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\html>

class StdlibHtmlTest
{
    static TestEscapeAndUnescapeMatchObservedLocal310Surface()
    {
        sample := "<tag>&" Chr(34) "'"
        quotesOnly := Chr(34) "'"

        AhkTest.AssertEqual("&lt;tag&gt;&amp;&quot;&#x27;", stdlib.html.escape(sample))
        AhkTest.AssertEqual("&lt;tag&gt;&amp;" Chr(34) "'", stdlib.html.escape(sample, stdlib.False))
        AhkTest.AssertEqual(Chr(34) "'", stdlib.html.escape(quotesOnly, stdlib.None))
        AhkTest.AssertEqual("&quot;&#x27;", stdlib.html.escape(quotesOnly, stdlib.True))
        AhkTest.AssertEqual("", stdlib.html.escape(""))

        AhkTest.AssertEqual("<tag>&'" Chr(34), stdlib.html.unescape("&lt;tag&gt;&amp;&#x27;&quot;"))
        AhkTest.AssertEqual(Chr(160) "><", stdlib.html.unescape("&nbsp;&gt;&lt;"))
        AhkTest.AssertEqual("&bogus; &", stdlib.html.unescape("&bogus; &amp"))
        AhkTest.AssertEqual(">&", stdlib.html.unescape("&#62;&#38;"))
    }

    static TestObservedErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^escape\(\) missing 1 required positional argument: 's'$", (*) => stdlib.html.escape())
        AhkTest.RaisesMatch(TypeError, "^escape\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.html.escape("a", stdlib.True, 1))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'replace'$", (*) => stdlib.html.escape(1))

        AhkTest.RaisesMatch(TypeError, "^unescape\(\) missing 1 required positional argument: 's'$", (*) => stdlib.html.unescape())
        AhkTest.RaisesMatch(TypeError, "^unescape\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.html.unescape("a", 1))
        AhkTest.RaisesMatch(TypeError, "^argument of type 'int' is not iterable$", (*) => stdlib.html.unescape(1))
    }

    static TestUnescapeFullHtml5NamedTableMatchesLocal310()
    {
        ; Both with-semicolon and legacy no-semicolon named refs (CPython 3.10).
        AhkTest.AssertEqual(Chr(169) " " Chr(169), stdlib.html.unescape("&copy; &COPY;"))
        ; &notin; is a real entity (U+2209); resolves fully.
        AhkTest.AssertEqual(Chr(8713), stdlib.html.unescape("&notin;"))
        ; &notit; is NOT an entity; longest-prefix match resolves &not (U+00AC) then "it;".
        AhkTest.AssertEqual(Chr(172) "it;", stdlib.html.unescape("&notit;"))
        ; Multi-codepoint entity: &fjlig; -> "fj".
        AhkTest.AssertEqual("fj", stdlib.html.unescape("&fjlig;"))
        ; Legacy no-semicolon &gt at end of string.
        AhkTest.AssertEqual(">", stdlib.html.unescape("&gt"))
        ; &amp (no ;) followed immediately by &amp; — first is legacy, second full.
        AhkTest.AssertEqual("&&", stdlib.html.unescape("&amp&amp;"))
    }

    static TestUnescapeNumericCharrefHtml5RulesMatchLocal310()
    {
        ; Astral codepoint -> surrogate pair (2 UTF-16 units in AHK).
        AhkTest.AssertEqual(Chr(0x1D504), stdlib.html.unescape("&#x1D504;"))
        ; Windows-1252 remap: &#128; -> EURO SIGN U+20AC.
        AhkTest.AssertEqual(Chr(0x20AC), stdlib.html.unescape("&#128;"))
        ; &#0; -> U+FFFD REPLACEMENT CHARACTER.
        AhkTest.AssertEqual(Chr(0xFFFD), stdlib.html.unescape("&#0;"))
        ; &#x0d; is a valid charref override -> carriage return.
        AhkTest.AssertEqual(Chr(0x0D), stdlib.html.unescape("&#x0d;"))
        ; &#11; (0x0B) is an invalid codepoint -> dropped (empty).
        AhkTest.AssertEqual("", stdlib.html.unescape("&#11;"))
        ; Surrogate range -> U+FFFD.
        AhkTest.AssertEqual(Chr(0xFFFD), stdlib.html.unescape("&#xD800;"))
        ; Out of range (> 0x10FFFF) -> U+FFFD.
        AhkTest.AssertEqual(Chr(0xFFFD), stdlib.html.unescape("&#x110000;"))
    }

    static TestEntitiesSubmoduleMatchesLocal310()
    {
        entities := stdlib.html.entities

        AhkTest.AssertEqual(2231, entities.html5.Count)
        AhkTest.AssertEqual(252, entities.name2codepoint.Count)
        AhkTest.AssertEqual(252, entities.codepoint2name.Count)
        AhkTest.AssertEqual(252, entities.entitydefs.Count)

        AhkTest.AssertEqual(38, entities.name2codepoint["amp"])
        AhkTest.AssertEqual("amp", entities.codepoint2name[38])
        AhkTest.AssertEqual("&", entities.entitydefs["amp"])
        AhkTest.AssertEqual("fj", entities.html5["fjlig;"])
        AhkTest.AssertEqual(Chr(0xA9), entities.html5["copy;"])
    }
}

AhkTest.Collect(StdlibHtmlTest)

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\textwrap>

class StdlibTextwrapTest
{
    static TestCoveredDedentAndIndentMatchObservedLocal310Surface()
    {
        AhkTest.AssertEqual("a`n  b`n", stdlib.textwrap.dedent("    a`n      b`n"))
        AhkTest.AssertEqual("`na`nb`n", stdlib.textwrap.dedent("`n    a`n    b`n"))
        AhkTest.AssertEqual("`n`n", stdlib.textwrap.dedent("  `n `t`n"))
        AhkTest.AssertEqual("> a`n`n> b", stdlib.textwrap.indent("a`n`nb", "> "))
        AhkTest.AssertEqual("> a`n   `n> `tb`n", stdlib.textwrap.indent("a`n   `n`tb`n", "> "))
        AhkTest.AssertEqual("> a`n> `n>  b", stdlib.textwrap.indent("a`n`n b", "> ", (*) => stdlib.True))
        AhkTest.AssertEqual("a`n`n b", stdlib.textwrap.indent("a`n`n b", "> ", (*) => stdlib.False))
    }

    static TestObservedDedentAndIndentErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^dedent\(\) missing 1 required positional argument: 'text'$", (*) => stdlib.textwrap.dedent())
        AhkTest.RaisesMatch(TypeError, "^dedent\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.textwrap.dedent("a", 1))
        AhkTest.RaisesMatch(TypeError, "^expected string or bytes-like object$", (*) => stdlib.textwrap.dedent(1))
        AhkTest.RaisesMatch(TypeError, "^indent\(\) missing 2 required positional arguments: 'text' and 'prefix'$", (*) => stdlib.textwrap.indent())
        AhkTest.RaisesMatch(TypeError, "^indent\(\) missing 1 required positional argument: 'prefix'$", (*) => stdlib.textwrap.indent("a"))
        AhkTest.RaisesMatch(TypeError, "^indent\(\) takes from 2 to 3 positional arguments but 4 were given$", (*) => stdlib.textwrap.indent("a", "> ", stdlib.None, 1))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'splitlines'$", (*) => stdlib.textwrap.indent(1, "> "))
        AhkTest.RaisesMatch(TypeError, "^unsupported operand type\(s\) for \+: 'int' and 'str'$", (*) => stdlib.textwrap.indent("a", 1))
        AhkTest.RaisesMatch(TypeError, "^'int' object is not callable$", (*) => stdlib.textwrap.indent("a", "> ", 1))
    }

    static TestWrapBreaksTextIntoWidthLimitedLines()
    {
        AhkTest.AssertEqual(["The quick brown", "fox jumped over", "the lazy dog"],
            stdlib.textwrap.wrap("The quick brown fox jumped over the lazy dog", { width: 15 }))
        AhkTest.AssertEqual(["The quick", "brown fox"],
            stdlib.textwrap.wrap("The quick brown fox", { width: 10 }))
    }

    static TestWrapCollapsesWhitespaceLikePython()
    {
        AhkTest.AssertEqual(["a b c"], stdlib.textwrap.wrap("a  b   c", { width: 70 }))
    }

    static TestWrapBreaksLongWordsWhenEnabled()
    {
        AhkTest.AssertEqual(["supercalif", "ragilistic", "word"],
            stdlib.textwrap.wrap("supercalifragilistic word", { width: 10 }))
    }

    static TestFillJoinsWrappedLinesWithNewlines()
    {
        AhkTest.AssertEqual("The quick`nbrown fox", stdlib.textwrap.fill("The quick brown fox", { width: 10 }))
    }

    static TestShortenTruncatesWithPlaceholder()
    {
        AhkTest.AssertEqual("Hello [...]", stdlib.textwrap.shorten("Hello world fo bar", { width: 11 }))
        AhkTest.AssertEqual("[...]", stdlib.textwrap.shorten("Hello world", { width: 10 }))
        AhkTest.AssertEqual("Hello world", stdlib.textwrap.shorten("Hello world", { width: 70 }))
        AhkTest.AssertEqual("Hello world", stdlib.textwrap.shorten("Hello   world", { width: 70 }))
    }

    static TestWrapMaxLinesAppendsPlaceholder()
    {
        AhkTest.AssertEqual(["The quick [...]"],
            stdlib.textwrap.wrap("The quick brown fox jumped over the lazy dog", { width: 15, max_lines: 1 }))
        AhkTest.AssertEqual(["The quick brown", "fox jumped over"],
            stdlib.textwrap.wrap("The quick brown fox jumped over", { width: 15, max_lines: 2 }))
    }
}

AhkTest.Collect(StdlibTextwrapTest)

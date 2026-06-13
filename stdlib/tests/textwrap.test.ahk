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

    static TestTextWrapperDefaultsMatchPython310()
    {
        w := stdlib.textwrap.TextWrapper()
        AhkTest.AssertEqual(70, w.width)
        AhkTest.AssertEqual("", w.initial_indent)
        AhkTest.AssertEqual("", w.subsequent_indent)
        AhkTest.AssertSame(stdlib.True, w.expand_tabs)
        AhkTest.AssertSame(stdlib.True, w.replace_whitespace)
        AhkTest.AssertSame(stdlib.False, w.fix_sentence_endings)
        AhkTest.AssertSame(stdlib.True, w.break_long_words)
        AhkTest.AssertSame(stdlib.True, w.drop_whitespace)
        AhkTest.AssertSame(stdlib.True, w.break_on_hyphens)
        AhkTest.AssertSame(stdlib.None, w.max_lines)
        AhkTest.AssertEqual(" [...]", w.placeholder)
    }

    static TestTextWrapperWrapAndFill()
    {
        w := stdlib.textwrap.TextWrapper({ width: 10 })
        AhkTest.AssertEqual(["the quick", "brown fox"], w.wrap("the quick brown fox"))
        AhkTest.AssertEqual("the quick`nbrown fox", w.fill("the quick brown fox"))
    }

    static TestTextWrapperInitialAndSubsequentIndent()
    {
        w := stdlib.textwrap.TextWrapper({ width: 12, initial_indent: "> ", subsequent_indent: ".. " })
        AhkTest.AssertEqual(["> the quick", ".. brown fox", ".. jumped"],
            w.wrap("the quick brown fox jumped"))
        AhkTest.AssertEqual("> the quick`n.. brown fox`n.. jumped",
            w.fill("the quick brown fox jumped"))
    }

    static TestTextWrapperBreakLongWordsToggle()
    {
        wOn := stdlib.textwrap.TextWrapper({ width: 10, break_long_words: stdlib.True })
        AhkTest.AssertEqual(["supercalif", "ragilistic", "word"],
            wOn.wrap("supercalifragilistic word"))
        wOff := stdlib.textwrap.TextWrapper({ width: 10, break_long_words: stdlib.False })
        AhkTest.AssertEqual(["supercalifragilistic", "word"],
            wOff.wrap("supercalifragilistic word"))
    }

    static TestTextWrapperMaxLines()
    {
        w := stdlib.textwrap.TextWrapper({ width: 15, max_lines: 1 })
        AhkTest.AssertEqual(["The quick [...]"],
            w.wrap("The quick brown fox jumped over the lazy dog"))
    }

    static TestTextWrapperRejectsNonObjectOptions()
    {
        AhkTest.AssertThrows(TypeError, (*) => stdlib.textwrap.TextWrapper(5))
    }
}

AhkTest.Collect(StdlibTextwrapTest)

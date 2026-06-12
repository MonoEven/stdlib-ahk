#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\re>

class StdlibReTest
{
    static TestSearchReturnsMatchObjectWithZeroBasedGroupsAndSpans()
    {
        match := stdlib.re.search("(\w+)=(\d+)", "name=42")

        AhkTest.AssertEqual("name=42", match.group())
        AhkTest.AssertEqual("name=42", match.group(0))
        AhkTest.AssertEqual("name", match.group(1))
        AhkTest.AssertEqual("42", match.group(2))
        AhkTest.AssertEqual(["name", "42"], match.groups())
        AhkTest.AssertEqual(0, match.start())
        AhkTest.AssertEqual(7, match.end())
        AhkTest.AssertEqual([0, 7], match.span())
        AhkTest.AssertEqual([0, 4], match.span(1))
    }

    static TestSearchReturnsBlankWhenThereIsNoMatch()
    {
        AhkTest.AssertEqual("", stdlib.re.search("x", "abc"))
    }

    static TestMatchRequiresStartOfString()
    {
        match := stdlib.re.match("\d+", "123abc")

        AhkTest.AssertEqual("123", match.group(0))
        AhkTest.AssertEqual([0, 3], match.span())
        AhkTest.AssertEqual("", stdlib.re.match("\d+", "abc123"))
    }

    static TestFullmatchRequiresEntireString()
    {
        match := stdlib.re.fullmatch("\d+", "123")

        AhkTest.AssertEqual("123", match.group(0))
        AhkTest.AssertEqual([0, 3], match.span())
        AhkTest.AssertEqual("", stdlib.re.fullmatch("\d+", "123abc"))
        AhkTest.AssertEqual("", stdlib.re.fullmatch("abc$", "abc`n"))
        AhkTest.AssertEqual([0, 3], stdlib.re.search("abc$", "abc`n").span())
    }

    static TestFindallMatchesPythonReturnShapes()
    {
        AhkTest.AssertEqual(["1", "22", "333"], stdlib.re.findall("\d+", "a1 b22 c333"))
        AhkTest.AssertEqual(["1", "22", "333"], stdlib.re.findall("(\d+)", "a1 b22 c333"))
        AhkTest.AssertEqual([["x", "1"], ["y", "22"]], stdlib.re.findall("(\w+)=(\d+)", "x=1 y=22"))
    }

    static TestSubSupportsCountAndBackreferences()
    {
        AhkTest.AssertEqual("a# b# c#", stdlib.re.sub("\d+", "#", "a1 b22 c333"))
        AhkTest.AssertEqual("a# b# c333", stdlib.re.sub("\d+", "#", "a1 b22 c333", 2))
        AhkTest.AssertEqual("x:<1> y:<22>", stdlib.re.sub("(\w+)=(\d+)", "\1:<\2>", "x=1 y=22"))
    }

    static TestCompileReturnsReusablePatternObject()
    {
        pattern := stdlib.re.compile("\d+")

        AhkTest.AssertEqual("12", pattern.search("a12").group(0))
        AhkTest.AssertEqual("", pattern.match("a12"))
        AhkTest.AssertEqual(["1", "22"], pattern.findall("a1 b22"))
        AhkTest.AssertEqual("a#", pattern.sub("#", "a12"))
    }

    static TestFlagsMapToRuntimeFlagSemanticsForCoveredCases()
    {
        match := stdlib.re.search("abc", "xxABC", stdlib.re.IGNORECASE)

        AhkTest.AssertEqual("ABC", match.group(0))
        AhkTest.AssertEqual([2, 5], match.span())
        AhkTest.AssertEqual(256, stdlib.re.ASCII)
        AhkTest.AssertFalse(HasProp(stdlib.re, "NOFLAG"))
        AhkTest.AssertEqual(stdlib.re.IGNORECASE, stdlib.re.I)
    }

    static TestDefaultWordClassIsUnicodeUnlessAsciiFlagIsSet()
    {
        letter := Chr(0xE9)

        AhkTest.AssertEqual(letter, stdlib.re.search("\w+", letter).group(0))
        AhkTest.AssertEqual("", stdlib.re.search("\w+", letter, stdlib.re.ASCII))
    }

    static TestNamedGroupsAreAccessible()
    {
        match := stdlib.re.search("(?P<key>\w+)=(?P<value>\d+)", "name=42")
        groups := match.groupdict()

        AhkTest.AssertEqual("name", match.group("key"))
        AhkTest.AssertEqual("42", match.group("value"))
        AhkTest.AssertEqual("name", groups["key"])
        AhkTest.AssertEqual("42", groups["value"])
    }

    static TestSplitFollowsPythonReturnShapes()
    {
        AhkTest.AssertEqual(["Words", "words", "words", ""], stdlib.re.split("\W+", "Words, words, words."))
        AhkTest.AssertEqual(["Words", ", ", "words", ", ", "words", ".", ""], stdlib.re.split("(\W+)", "Words, words, words."))
        AhkTest.AssertEqual(["Words", "words, words."], stdlib.re.split("\W+", "Words, words, words.", 1))
        AhkTest.AssertEqual(["a", "1", "b", "2", ""], stdlib.re.split("(\d)", "a1b2"))
    }

    static TestSubnReturnsTupleWithCount()
    {
        AhkTest.AssertEqual(["a# b# c#", 3], stdlib.re.subn("\d+", "#", "a1 b22 c333"))
        AhkTest.AssertEqual(["a# b# c333", 2], stdlib.re.subn("\d+", "#", "a1 b22 c333", 2))
    }

    static TestEscapeQuotesSpecialCharacters()
    {
        AhkTest.AssertEqual("a\.b\*c\+\?\[\]", stdlib.re.escape("a.b*c+?[]"))
        AhkTest.AssertEqual("https://x\.y/z", stdlib.re.escape("https://x.y/z"))
    }

    static TestFinditerYieldsMatchObjects()
    {
        spans := []
        for match in stdlib.re.finditer("\d+", "a1 b22 c333")
            spans.Push([match.group(0), match.start(), match.end()])

        AhkTest.AssertEqual([["1", 1, 2], ["22", 4, 6], ["333", 8, 11]], spans)
    }

    static TestExpandSubstitutesGroups()
    {
        match := stdlib.re.search("(\w+) (\w+)", "foo bar")

        AhkTest.AssertEqual("bar foo", match.expand("\2 \1"))
        AhkTest.AssertEqual("bar foo", match.expand("\g<2> \g<1>"))
    }
}

AhkTest.Collect(StdlibReTest)

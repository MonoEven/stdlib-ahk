#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\keyword>

class StdlibKeywordTest
{
    static TestKeywordListsAndPredicatesMatchObservedLocal310Surface()
    {
        AhkTest.AssertEqual(
            ["False", "None", "True", "and", "as", "assert", "async", "await", "break", "class", "continue", "def", "del", "elif", "else", "except", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "nonlocal", "not", "or", "pass", "raise", "return", "try", "while", "with", "yield"],
            stdlib.keyword.kwlist
        )
        AhkTest.AssertEqual(["_", "case", "match"], stdlib.keyword.softkwlist)
        AhkTest.AssertTrue(stdlib.keyword.iskeyword("for"))
        AhkTest.AssertFalse(stdlib.keyword.iskeyword("match"))
        AhkTest.AssertTrue(stdlib.keyword.issoftkeyword("match"))
        AhkTest.AssertFalse(stdlib.keyword.issoftkeyword("for"))
        AhkTest.AssertFalse(stdlib.keyword.iskeyword(1))
        AhkTest.AssertFalse(stdlib.keyword.issoftkeyword(1))
    }

    static TestObservedKeywordErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^frozenset\.__contains__\(\) takes exactly one argument \(0 given\)$", (*) => stdlib.keyword.iskeyword())
        AhkTest.RaisesMatch(TypeError, "^frozenset\.__contains__\(\) takes exactly one argument \(2 given\)$", (*) => stdlib.keyword.iskeyword("for", "x"))
        AhkTest.RaisesMatch(TypeError, "^frozenset\.__contains__\(\) takes exactly one argument \(0 given\)$", (*) => stdlib.keyword.issoftkeyword())
        AhkTest.RaisesMatch(TypeError, "^frozenset\.__contains__\(\) takes exactly one argument \(2 given\)$", (*) => stdlib.keyword.issoftkeyword("for", "x"))
    }
}

AhkTest.Collect(StdlibKeywordTest)

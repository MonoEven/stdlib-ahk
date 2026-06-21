#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\pprint>
#Include <stdlib\io>
#Include <stdlib\collections>

class StdlibPprintTest
{
    static TestPformatMatchesObservedLocal310Shapes()
    {
        AhkTest.AssertEqual("[1, 'two', [3]]", stdlib.pprint.pformat([1, "two", [3]]))
        AhkTest.AssertEqual("{'a': 2, 'b': 1}", stdlib.pprint.pformat(Map("b", 1, "a", 2)))
        AhkTest.AssertEqual("[ {'a': 1, 'b': 2},`n  {'c': 3}]", stdlib.pprint.pformat([Map("a", 1, "b", 2), Map("c", 3)], 2, 20))
        AhkTest.AssertEqual("[1, [2, [...]]]", stdlib.pprint.pformat([1, [2, [3, [4]]]], 1, 80, 2))
        AhkTest.AssertEqual("[[1, 2],`n [3, 4],`n [5, 6]]", stdlib.pprint.pformat([[1, 2], [3, 4], [5, 6]], 1, 12, stdlib.None, true))
    }

    static TestPprintAndPpWriteExpectedLinesToStringIO()
    {
        sortedStream := stdlib.io.StringIO()
        unsortedStream := stdlib.io.StringIO()

        AhkTest.AssertSame(stdlib.None, stdlib.pprint.pprint(Map("b", 1, "a", 2), unsortedStream))
        AhkTest.AssertEqual("{'a': 2, 'b': 1}`n", unsortedStream.getvalue())
        AhkTest.AssertSame(stdlib.None, stdlib.pprint.pp(Map("b", 1, "a", 2), sortedStream))
        AhkTest.AssertEqual("{'a': 2, 'b': 1}`n", sortedStream.getvalue())
    }

    static TestPrettyPrinterSupportsObservedConstructorAndPformat()
    {
        printer := stdlib.pprint.PrettyPrinter(2, 20)

        AhkTest.AssertEqual("{ 'a': [1, 2, 3],`n  'b': 1}", printer.pformat(Map("b", 1, "a", [1, 2, 3])))
    }

    static TestPprintRejectsObservedInvalidArguments()
    {
        AhkTest.RaisesMatch(ValueError, "invalid literal for int\(\) with base 10: 'x'", (*) => stdlib.pprint.PrettyPrinter("x"))
        AhkTest.RaisesMatch(ValueError, "invalid literal for int\(\) with base 10: 'x'", (*) => stdlib.pprint.PrettyPrinter(1, "x"))
        AhkTest.RaisesMatch(AttributeError, "'int' object has no attribute 'write'", (*) => stdlib.pprint.pprint(Map("a", 1), 1))
    }

    static TestSafeReprMatchesObservedLocal310()
    {
        ; saferepr sorts dict keys (sort_dicts=True default in _safe_repr).
        AhkTest.AssertEqual("{'a': 2, 'b': 1}", stdlib.pprint.saferepr(Map("b", 1, "a", 2)))
        AhkTest.AssertEqual("[1, 'two', [3]]", stdlib.pprint.saferepr([1, "two", [3]]))
        AhkTest.AssertEqual("[]", stdlib.pprint.saferepr([]))
        AhkTest.AssertEqual("{}", stdlib.pprint.saferepr(Map()))
        AhkTest.AssertEqual("'hi'", stdlib.pprint.saferepr("hi"))
        AhkTest.AssertEqual("42", stdlib.pprint.saferepr(42))
    }

    static TestIsReadableMatchesObservedLocal310()
    {
        AhkTest.AssertSame(stdlib.True, stdlib.pprint.isreadable([1, 2, 3]))
        AhkTest.AssertSame(stdlib.True, stdlib.pprint.isreadable(Map("a", 1)))
        AhkTest.AssertSame(stdlib.True, stdlib.pprint.isreadable("hi"))
    }

    static TestIsRecursiveMatchesObservedLocal310()
    {
        AhkTest.AssertSame(stdlib.False, stdlib.pprint.isrecursive([1, 2, 3]))

        ; A self-referencing list is recursive; saferepr emits the recursion marker.
        cyclic := [1, 2]
        cyclic.Push(cyclic)
        AhkTest.AssertSame(stdlib.True, stdlib.pprint.isrecursive(cyclic))
        AhkTest.AssertSame(stdlib.False, stdlib.pprint.isreadable(cyclic))
        AhkTest.AssertEqual(true, InStr(stdlib.pprint.saferepr(cyclic), "<Recursion on list with id=") > 0)
    }

    static TestTupleFormattingMatchesObservedLocal310()
    {
        AhkTest.AssertEqual("(1, 2, 3)", stdlib.pprint.pformat(stdlib.tuple([1, 2, 3])))
        ; single-element tuple keeps the trailing comma
        AhkTest.AssertEqual("(1,)", stdlib.pprint.pformat(stdlib.tuple([1])))
        AhkTest.AssertEqual("()", stdlib.pprint.pformat(stdlib.tuple()))
        ; tuples nested in lists / dicts
        AhkTest.AssertEqual("[(1, 2), (3, 4)]", stdlib.pprint.pformat([stdlib.tuple([1, 2]), stdlib.tuple([3, 4])]))
        AhkTest.AssertEqual("{'t': (1, 2)}", stdlib.pprint.pformat(Map("t", stdlib.tuple([1, 2]))))
        ; saferepr handles tuples + nested tuples and the single-element comma
        AhkTest.AssertEqual("(1, 'two', (3,))", stdlib.pprint.saferepr(stdlib.tuple([1, "two", stdlib.tuple([3])])))
    }

    static TestNamedTupleFormattingMatchesObservedLocal310()
    {
        Point := stdlib.collections.namedtuple("Point", ["x", "y"])
        AhkTest.AssertEqual("Point(x=1, y=2)", stdlib.pprint.pformat(Point(1, 2)))
        AhkTest.AssertEqual("[Point(x=1, y=2), Point(x=3, y=4)]", stdlib.pprint.pformat([Point(1, 2), Point(3, 4)]))
        AhkTest.AssertEqual("{'p': Point(x=1, y=2)}", stdlib.pprint.pformat(Map("p", Point(1, 2))))
        AhkTest.AssertEqual("Point(x=1, y='two')", stdlib.pprint.saferepr(Point(1, "two")))
    }
}

AhkTest.Collect(StdlibPprintTest)

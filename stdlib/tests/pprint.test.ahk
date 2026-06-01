#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\pprint>
#Include <stdlib\io>

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
}

AhkTest.Collect(StdlibPprintTest)

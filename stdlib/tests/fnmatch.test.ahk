#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\fnmatch>

class StdlibFnmatchTest
{
    static TestCoveredFnmatchSurfaceMatchesObservedLocal310()
    {
        AhkTest.AssertTrue(stdlib.fnmatch.fnmatch("A.TXT", "*.txt"))
        AhkTest.AssertFalse(stdlib.fnmatch.fnmatchcase("A.TXT", "*.txt"))
        AhkTest.AssertTrue(stdlib.fnmatch.fnmatch("dir/file.txt", "DIR\*.TXT"))
        AhkTest.AssertEqual(["A.TXT", "b.txt"], stdlib.fnmatch.filter(["A.TXT", "b.txt", "c.bin"], "*.txt"))
        AhkTest.AssertEqual("(?s:.*\.txt)\Z", stdlib.fnmatch.translate("*.txt"))
        AhkTest.AssertEqual("(?s:[^a].*\.txt)\Z", stdlib.fnmatch.translate("[!a]*.txt"))
        AhkTest.AssertTrue(stdlib.fnmatch.fnmatch("b.txt", "[!a]*.txt"))
        AhkTest.AssertTrue(stdlib.fnmatch.fnmatch("ab", "a?"))
    }

    static TestObservedFnmatchErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^fnmatch\(\) missing 2 required positional arguments: 'name' and 'pat'$", (*) => stdlib.fnmatch.fnmatch())
        AhkTest.RaisesMatch(TypeError, "^fnmatch\(\) missing 1 required positional argument: 'pat'$", (*) => stdlib.fnmatch.fnmatch("a"))
        AhkTest.RaisesMatch(TypeError, "^fnmatch\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.fnmatch.fnmatch("a", "b", "c"))
        AhkTest.RaisesMatch(TypeError, "^expected str, bytes or os\.PathLike object, not int$", (*) => stdlib.fnmatch.fnmatch(1, "*"))
        AhkTest.RaisesMatch(TypeError, "^expected str, bytes or os\.PathLike object, not int$", (*) => stdlib.fnmatch.fnmatch("a", 1))
        AhkTest.RaisesMatch(TypeError, "^filter\(\) missing 2 required positional arguments: 'names' and 'pat'$", (*) => stdlib.fnmatch.filter())
        AhkTest.RaisesMatch(TypeError, "^filter\(\) missing 1 required positional argument: 'pat'$", (*) => stdlib.fnmatch.filter(["a"]))
        AhkTest.RaisesMatch(TypeError, "^filter\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.fnmatch.filter(["a"], "*", "x"))
        AhkTest.RaisesMatch(TypeError, "^translate\(\) missing 1 required positional argument: 'pat'$", (*) => stdlib.fnmatch.translate())
        AhkTest.RaisesMatch(TypeError, "^translate\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.fnmatch.translate("*", "x"))
        AhkTest.RaisesMatch(TypeError, "^cannot use a bytes pattern on a string-like object$", (*) => stdlib.fnmatch.fnmatch("a", Buffer(1)))
    }
}

AhkTest.Collect(StdlibFnmatchTest)

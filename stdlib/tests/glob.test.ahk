#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\glob>
#Include <stdlib\tempfile>
#Include <stdlib\pathlib>

class StdlibGlobTest
{
    static TestCoveredGlobSurfaceMatchesObservedLocal310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-glob-", stdlib.tempfile.gettempdir())
        previousWorkingDir := A_WorkingDir

        try {
            stdlib.pathlib.Path(root, "alpha.txt").write_text("a")
            stdlib.pathlib.Path(root, "beta.bin").write_text("b")
            stdlib.pathlib.Path(root, "sub").mkdir()
            stdlib.pathlib.Path(root, "sub", "gamma.txt").write_text("g")
            stdlib.pathlib.Path(root, "sub", "delta.bin").write_text("d")
            stdlib.pathlib.Path(root, "sub", "nested").mkdir()
            stdlib.pathlib.Path(root, "sub", "nested", "omega.txt").write_text("o")

            SetWorkingDir root

            AhkTest.AssertEqual(["alpha.txt"], stdlib.glob.glob("*.txt"))
            AhkTest.AssertEqual(["sub\gamma.txt"], stdlib.glob.glob("sub/*.txt"))
            AhkTest.AssertEqual(["alpha.txt", "sub\gamma.txt", "sub\nested\omega.txt"], stdlib.glob.glob("**/*.txt", { recursive: true }))
            AhkTest.AssertEqual(["sub\gamma.txt", "sub\nested\omega.txt"], stdlib.glob.glob("sub/**/*.txt", { recursive: true }))
            AhkTest.AssertEqual(["sub\delta.bin", "sub\gamma.txt", "sub\nested"], stdlib.glob.glob("sub/*"))
            AhkTest.AssertEqual("[[][*]][?].txt", stdlib.glob.escape("[*]?.txt"))
            AhkTest.AssertTrue(stdlib.glob.has_magic("*.txt"))
            AhkTest.AssertFalse(stdlib.glob.has_magic("plain.txt"))
        } finally {
            SetWorkingDir previousWorkingDir
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestObservedGlobErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^glob\(\) missing 1 required positional argument: 'pathname'$", (*) => stdlib.glob.glob())
        AhkTest.RaisesMatch(TypeError, "^glob\(\) takes 1 positional argument but 3 were given$", (*) => stdlib.glob.glob("*.txt", stdlib.True, stdlib.False))
        AhkTest.RaisesMatch(TypeError, "^escape\(\) missing 1 required positional argument: 'pathname'$", (*) => stdlib.glob.escape())
        AhkTest.RaisesMatch(TypeError, "^has_magic\(\) missing 1 required positional argument: 's'$", (*) => stdlib.glob.has_magic())
    }
}

AhkTest.Collect(StdlibGlobTest)

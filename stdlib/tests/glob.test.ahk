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

            collected := []
            for path in stdlib.glob.iglob("*.txt")
                collected.Push(path)
            AhkTest.AssertEqual(["alpha.txt"], collected)

            recursed := []
            for path in stdlib.glob.iglob("**/*.txt", { recursive: true })
                recursed.Push(path)
            AhkTest.AssertEqual(["alpha.txt", "sub\gamma.txt", "sub\nested\omega.txt"], recursed)
        } finally {
            SetWorkingDir previousWorkingDir
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestRootDirReturnsRelativePathsLocal310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-glob-root-", stdlib.tempfile.gettempdir())
        previousWorkingDir := A_WorkingDir

        try {
            stdlib.pathlib.Path(root, "alpha.txt").write_text("a")
            stdlib.pathlib.Path(root, "beta.bin").write_text("b")
            stdlib.pathlib.Path(root, "sub").mkdir()
            stdlib.pathlib.Path(root, "sub", "gamma.txt").write_text("g")
            stdlib.pathlib.Path(root, "sub", "delta.bin").write_text("d")
            stdlib.pathlib.Path(root, "sub", "nested").mkdir()
            stdlib.pathlib.Path(root, "sub", "nested", "omega.txt").write_text("o")

            ; Move CWD elsewhere so results can only be relative to root_dir.
            SetWorkingDir stdlib.tempfile.gettempdir()

            AhkTest.AssertEqual(["alpha.txt"], stdlib.glob.glob("*.txt", { root_dir: root }))
            AhkTest.AssertEqual(["sub\gamma.txt"], stdlib.glob.glob("sub/*.txt", { root_dir: root }))
            AhkTest.AssertEqual(["alpha.txt", "sub\gamma.txt", "sub\nested\omega.txt"], stdlib.glob.glob("**/*.txt", { root_dir: root, recursive: true }))
            AhkTest.AssertEqual(["sub\delta.bin", "sub\gamma.txt", "sub\nested"], stdlib.glob.glob("sub/*", { root_dir: root }))
            AhkTest.AssertEqual(["alpha.txt"], stdlib.glob.glob("alpha.txt", { root_dir: root }))

            ; root_dir=None behaves like cwd; nonexistent root_dir yields no matches via iglob too.
            collected := []
            for path in stdlib.glob.iglob("sub/*.txt", { root_dir: root })
                collected.Push(path)
            AhkTest.AssertEqual(["sub\gamma.txt"], collected)
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
        AhkTest.RaisesMatch(TypeError, "^iglob\(\) missing 1 required positional argument: 'pathname'$", (*) => stdlib.glob.iglob())
    }
}

AhkTest.Collect(StdlibGlobTest)

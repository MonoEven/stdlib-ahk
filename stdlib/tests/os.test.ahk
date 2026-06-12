#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\os>

class StdlibOsTest
{
    static TestSystemReturnsShellExitCode()
    {
        AhkTest.AssertEqual(0, stdlib.os.system("exit /b 0"))
        AhkTest.AssertEqual(7, stdlib.os.system("exit /b 7"))
    }

    static TestSystemRunsThroughShellRedirection()
    {
        root := A_Temp "\stdlib-os-system-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        outputPath := root "\result.txt"

        try {
            exitCode := stdlib.os.system("echo stdlib-ok > " stdlib_os_test_quote_cmd_arg(outputPath))

            AhkTest.AssertEqual(0, exitCode)
            AhkTest.AssertTrue(FileExist(outputPath) != "")
            AhkTest.AssertContains("stdlib-ok", FileRead(outputPath, "UTF-8"))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestSystemRejectsNonStringAndEmbeddedNull()
    {
        AhkTest.RaisesMatch(TypeError, "system\(\) argument 'command' must be str", (*) => stdlib.os.system(123))
        AhkTest.RaisesMatch(TypeError, "system\(\) argument 'command' must be str", (*) => stdlib.os.system(Buffer(1, 0)))
        AhkTest.RaisesMatch(ValueError, "embedded null character", (*) => stdlib.os.system("echo a" Chr(0) "b"))
    }

    static TestConstantsMatchPython310()
    {
        AhkTest.AssertEqual("\", stdlib.os.sep)
        AhkTest.AssertEqual("/", stdlib.os.altsep)
        AhkTest.AssertEqual(".", stdlib.os.extsep)
        AhkTest.AssertEqual(";", stdlib.os.pathsep)
        AhkTest.AssertEqual("`r`n", stdlib.os.linesep)
        AhkTest.AssertEqual("nt", stdlib.os.name)
        AhkTest.AssertEqual(".", stdlib.os.curdir)
        AhkTest.AssertEqual("..", stdlib.os.pardir)
    }

    static TestGetcwdMatchesWorkingDir()
    {
        AhkTest.AssertEqual(A_WorkingDir, stdlib.os.getcwd())
    }

    static TestChdirAndListdir()
    {
        root := StdlibOsTest.MakeTempDir()
        original := A_WorkingDir
        try {
            FileAppend "x", root "\one.txt"
            FileAppend "y", root "\two.txt"
            DirCreate root "\sub"

            names := stdlib.os.listdir(root)
            AhkTest.AssertEqual(3, names.Length)
            sorted := StdlibOsTest.SortStrings(names)
            AhkTest.AssertEqual("one.txt", sorted[1])
            AhkTest.AssertEqual("sub", sorted[2])
            AhkTest.AssertEqual("two.txt", sorted[3])

            stdlib.os.chdir(root)
            AhkTest.AssertEqual(StrLower(root), StrLower(A_WorkingDir))
        } finally {
            SetWorkingDir original
            DirDelete root, true
        }
    }

    static TestListdirMissingRaises()
    {
        AhkTest.RaisesMatch(OSError, "cannot find", (*) => stdlib.os.listdir(A_Temp "\stdlib-os-missing-" A_TickCount))
    }

    static TestScandirYieldsEntries()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            FileAppend "x", root "\file.txt"
            DirCreate root "\folder"

            files := 0
            dirs := 0
            for entry in stdlib.os.scandir(root) {
                if entry.is_dir().Value
                    dirs += 1
                if entry.is_file().Value
                    files += 1
            }
            AhkTest.AssertEqual(1, files)
            AhkTest.AssertEqual(1, dirs)
        } finally {
            DirDelete root, true
        }
    }

    static TestMakedirsAndRemovedirs()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            deep := root "\a\b\c"
            stdlib.os.makedirs(deep)
            AhkTest.AssertTrue(DirExist(deep) != "")

            ; exist_ok=false raises
            AhkTest.RaisesMatch(OSError, "already exists", (*) => stdlib.os.makedirs(deep))
            ; exist_ok=true is silent
            stdlib.os.makedirs(deep, 511, true)
        } finally {
            DirDelete root, true
        }
    }

    static TestRemoveAndRename()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            src := root "\a.txt"
            FileAppend "data", src
            stdlib.os.rename(src, root "\b.txt")
            AhkTest.AssertTrue(FileExist(root "\b.txt") != "")
            AhkTest.AssertTrue(FileExist(src) = "")

            stdlib.os.remove(root "\b.txt")
            AhkTest.AssertTrue(FileExist(root "\b.txt") = "")

            AhkTest.RaisesMatch(OSError, "cannot find", (*) => stdlib.os.remove(root "\nope.txt"))
        } finally {
            DirDelete root, true
        }
    }

    static TestStatReportsSize()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            FileAppend "hello", root "\f.txt"
            st := stdlib.os.stat(root "\f.txt")
            AhkTest.AssertEqual(5, st.st_size)
            AhkTest.AssertTrue(st.st_mtime > 0)
        } finally {
            DirDelete root, true
        }
    }

    static TestWalkVisitsTree()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            DirCreate root "\sub"
            FileAppend "1", root "\top.txt"
            FileAppend "2", root "\sub\inner.txt"

            seenRoots := []
            for triple in stdlib.os.walk(root)
                seenRoots.Push(triple[1])
            AhkTest.AssertEqual(2, seenRoots.Length)
        } finally {
            DirDelete root, true
        }
    }

    static TestGetenvAndPutenv()
    {
        key := "STDLIB_OS_TEST_VAR_" A_TickCount
        AhkTest.AssertTrue(AhkStdlibIsNone(stdlib.os.getenv(key, stdlib.None)))
        stdlib.os.putenv(key, "hello")
        AhkTest.AssertEqual("hello", stdlib.os.getenv(key))
        AhkTest.AssertEqual("fallback", stdlib.os.getenv("STDLIB_OS_MISSING_" A_TickCount, "fallback"))
        stdlib.os.unsetenv(key)
    }

    static TestGetpidAndCpuCount()
    {
        AhkTest.AssertTrue(stdlib.os.getpid() > 0)
        AhkTest.AssertTrue(stdlib.os.cpu_count() >= 1)
    }

    static TestUrandomReturnsBuffer()
    {
        buf := stdlib.os.urandom(16)
        AhkTest.AssertEqual(16, buf.Size)
        AhkTest.RaisesMatch(ValueError, "negative", (*) => stdlib.os.urandom(-1))
    }

    ; --- os.path ---

    static TestPathJoinMatchesPython310()
    {
        AhkTest.AssertEqual("a\b\c", stdlib.os.path.join("a", "b", "c"))
        AhkTest.AssertEqual("/c", stdlib.os.path.join("a/b", "/c"))
        AhkTest.AssertEqual("a\b\", stdlib.os.path.join("a", "b\"))
    }

    static TestPathSplitMatchesPython310()
    {
        parts := stdlib.os.path.split("a/b/c")
        AhkTest.AssertEqual("a/b", parts[1])
        AhkTest.AssertEqual("c", parts[2])

        AhkTest.AssertEqual("c.txt", stdlib.os.path.basename("a/b/c.txt"))
        AhkTest.AssertEqual("a/b", stdlib.os.path.dirname("a/b/c.txt"))
    }

    static TestPathSplitextMatchesPython310()
    {
        ext := stdlib.os.path.splitext("archive.tar.gz")
        AhkTest.AssertEqual("archive.tar", ext[1])
        AhkTest.AssertEqual(".gz", ext[2])

        hidden := stdlib.os.path.splitext(".bashrc")
        AhkTest.AssertEqual(".bashrc", hidden[1])
        AhkTest.AssertEqual("", hidden[2])
    }

    static TestPathSplitdriveMatchesPython310()
    {
        d := stdlib.os.path.splitdrive("c:/a/b")
        AhkTest.AssertEqual("c:", d[1])
        AhkTest.AssertEqual("/a/b", d[2])

        unc := stdlib.os.path.splitdrive("//host/share/x")
        AhkTest.AssertEqual("//host/share", unc[1])
        AhkTest.AssertEqual("/x", unc[2])
    }

    static TestPathNormpathMatchesPython310()
    {
        AhkTest.AssertEqual("a\c", stdlib.os.path.normpath("a/./b/../c"))
        AhkTest.AssertEqual("..", stdlib.os.path.normpath("a/b/../../.."))
        AhkTest.AssertEqual("C:\b", stdlib.os.path.normpath("C:\a\..\b"))
    }

    static TestPathIsabsMatchesPython310()
    {
        AhkTest.AssertTrue(stdlib.os.path.isabs("C:/x").Value)
        AhkTest.AssertTrue(!stdlib.os.path.isabs("x").Value)
        AhkTest.AssertTrue(stdlib.os.path.isabs("/x").Value)
    }

    static TestPathExistsIsfileIsdir()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            FileAppend "x", root "\f.txt"
            AhkTest.AssertTrue(stdlib.os.path.exists(root "\f.txt").Value)
            AhkTest.AssertTrue(stdlib.os.path.isfile(root "\f.txt").Value)
            AhkTest.AssertTrue(!stdlib.os.path.isdir(root "\f.txt").Value)
            AhkTest.AssertTrue(stdlib.os.path.isdir(root).Value)
            AhkTest.AssertTrue(!stdlib.os.path.exists(root "\none").Value)
        } finally {
            DirDelete root, true
        }
    }

    static TestPathCommonprefixAndCommonpath()
    {
        AhkTest.AssertEqual("ab", stdlib.os.path.commonprefix(["abc", "abd"]))
        AhkTest.AssertEqual("C:\a", stdlib.os.path.commonpath(["C:/a/b", "C:/a/c"]))
    }

    static TestPathRelpath()
    {
        AhkTest.AssertEqual("b\c", stdlib.os.path.relpath("C:/a/b/c", "C:/a"))
    }

    static TestPathExpandvars()
    {
        key := "STDLIB_OS_EXP_" A_TickCount
        stdlib.os.putenv(key, "VAL")
        AhkTest.AssertEqual("x_VAL_y", stdlib.os.path.expandvars("x_%" key "%_y"))
        stdlib.os.unsetenv(key)
    }

    static TestPathGetsize()
    {
        root := StdlibOsTest.MakeTempDir()
        try {
            FileAppend "hello", root "\f.txt"
            AhkTest.AssertEqual(5, stdlib.os.path.getsize(root "\f.txt"))
        } finally {
            DirDelete root, true
        }
    }

    ; --- helpers ---

    static MakeTempDir()
    {
        dir := A_Temp "\stdlib-os-" A_TickCount "-" Random(100000, 999999)
        DirCreate dir
        return dir
    }

    static SortStrings(items)
    {
        arr := []
        for item in items
            arr.Push(item)
        n := arr.Length
        Loop n - 1 {
            i := A_Index
            Loop n - i {
                j := A_Index
                if StrCompare(arr[j], arr[j + 1]) > 0 {
                    tmp := arr[j]
                    arr[j] := arr[j + 1]
                    arr[j + 1] := tmp
                }
            }
        }
        return arr
    }
}

stdlib_os_test_quote_cmd_arg(value)
{
    return "`"" StrReplace(value, "`"", "`"`"") "`""
}

AhkTest.Collect(StdlibOsTest)

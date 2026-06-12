#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\tempfile>

class StdlibTempfileTest
{
    static TestGetTempDirAndPrefixFollowPythonDefaults()
    {
        tempdir := stdlib.tempfile.gettempdir()

        AhkTest.AssertTrue(DirExist(tempdir) != "")
        AhkTest.AssertTrue(RegExMatch(tempdir, "i)^[a-z]:\\") || SubStr(tempdir, 1, 2) = "\\")
        AhkTest.AssertEqual("tmp", stdlib.tempfile.gettempprefix())
    }

    static TestMkdtempCreatesUniqueDirectoryWithPrefixSuffixAndDir()
    {
        root := A_Temp "\stdlib-tempfile-test-" A_TickCount "-" Random(100000, 999999)
        DirCreate root

        try {
            first := stdlib.tempfile.mkdtemp("-suf", "pre-", root)
            second := stdlib.tempfile.mkdtemp("-suf", "pre-", root)

            AhkTest.AssertNotEqual(first, second)
            AhkTest.AssertTrue(DirExist(first) != "")
            AhkTest.AssertTrue(DirExist(second) != "")
            AhkTest.AssertContains(root "\pre-", first)
            AhkTest.AssertContains("-suf", first)
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestMkdtempPreservesRelativeDirReturnLikePython310()
    {
        root := A_Temp "\stdlib-tempfile-relative-" A_TickCount "-" Random(100000, 999999)
        previousWorkingDir := A_WorkingDir
        DirCreate root "\relbase"

        try {
            SetWorkingDir root
            path := stdlib.tempfile.mkdtemp("", "rel-", "relbase")

            AhkTest.AssertTrue(RegExMatch(path, "^relbase\\rel-"))
            AhkTest.AssertTrue(DirExist(root "\" path) != "")
        } finally {
            SetWorkingDir previousWorkingDir
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestTemporaryDirectoryCleansRecursivelyAndIsIdempotent()
    {
        root := A_Temp "\stdlib-tempfile-td-" A_TickCount "-" Random(100000, 999999)
        DirCreate root

        try {
            directory := stdlib.tempfile.TemporaryDirectory("-done", "td-", root)
            nested := directory.name "\child"
            DirCreate nested
            FileAppend "payload", nested "\data.txt", "UTF-8"

            AhkTest.AssertTrue(DirExist(directory.name) != "")
            AhkTest.AssertContains(root "\td-", directory.name)
            AhkTest.AssertContains("-done", directory.name)

            directory.cleanup()
            AhkTest.AssertFalse(DirExist(directory.name) != "")
            directory.cleanup()
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestTemporaryDirectoryCleanupIgnoresAlreadyRemovedDirectory()
    {
        root := A_Temp "\stdlib-tempfile-td-missing-" A_TickCount "-" Random(100000, 999999)
        DirCreate root

        try {
            directory := stdlib.tempfile.TemporaryDirectory("", "td-", root)
            DirDelete directory.name, true

            directory.cleanup()
            AhkTest.AssertFalse(DirExist(directory.name) != "")
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestMkstempCreatesFileAndReturnsPath()
    {
        root := A_Temp "\stdlib-tempfile-mkstemp-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            result := stdlib.tempfile.mkstemp(".txt", "mk-", root)
            path := result[2]
            AhkTest.AssertTrue(FileExist(path) != "")
            AhkTest.AssertTrue(InStr(path, "\mk-") > 0)
            AhkTest.AssertEqual(".txt", SubStr(path, -4))
            ; Second call yields a distinct path.
            result2 := stdlib.tempfile.mkstemp(".txt", "mk-", root)
            AhkTest.AssertTrue(path != result2[2])
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestNamedTemporaryFileWritesReadsAndDeletesOnClose()
    {
        root := A_Temp "\stdlib-tempfile-named-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            handle := stdlib.tempfile.NamedTemporaryFile({ dir: root, prefix: "nt-", suffix: ".dat" })
            name := handle.name
            AhkTest.AssertTrue(FileExist(name) != "")
            handle.write("hello")
            handle.seek(0)
            AhkTest.AssertEqual("hello", handle.read())
            handle.close()
            ; delete=True by default removes the file on close.
            AhkTest.AssertFalse(FileExist(name) != "")
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestNamedTemporaryFileKeepsFileWhenDeleteFalse()
    {
        root := A_Temp "\stdlib-tempfile-keep-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            handle := stdlib.tempfile.NamedTemporaryFile({ dir: root, delete: false })
            name := handle.name
            handle.write("x")
            handle.close()
            AhkTest.AssertTrue(FileExist(name) != "")
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }
}

AhkTest.Collect(StdlibTempfileTest)

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
}

AhkTest.Collect(StdlibTempfileTest)

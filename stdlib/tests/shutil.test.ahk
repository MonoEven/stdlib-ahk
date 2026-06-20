#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\shutil>
#Include <stdlib\tempfile>
#Include <stdlib\pathlib>
#Include <stdlib\io>
#Include <stdlib\io>

class StdlibShutilTest
{
    static TestCopyfileCopyAndMoveOperateOnRealFilesLikePython310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-", stdlib.tempfile.gettempdir())

        try {
            src := stdlib.pathlib.Path(root, "src.txt")
            dst := stdlib.pathlib.Path(root, "dst.txt")
            copyPath := stdlib.pathlib.Path(root, "copy.txt")
            dirTarget := stdlib.pathlib.Path(root, "folder")
            movedDir := stdlib.pathlib.Path(root, "movedir")

            src.write_text("alpha")
            dirTarget.mkdir()
            movedDir.mkdir()

            AhkTest.AssertEqual(String(dst), stdlib.shutil.copyfile(src, dst))
            AhkTest.AssertEqual("alpha", dst.read_text())
            AhkTest.AssertEqual(String(copyPath), stdlib.shutil.copy(src, copyPath))
            AhkTest.AssertEqual("alpha", copyPath.read_text())
            AhkTest.AssertEqual(String(dirTarget.joinpath("src.txt")), stdlib.shutil.copy(src, dirTarget))
            AhkTest.AssertEqual("alpha", dirTarget.joinpath("src.txt").read_text())
            AhkTest.AssertEqual(String(movedDir.joinpath("src.txt")), stdlib.shutil.move(src, movedDir))
            AhkTest.AssertFalse(src.exists())
            AhkTest.AssertEqual("alpha", movedDir.joinpath("src.txt").read_text())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestRmtreeDeletesDirectoriesRecursivelyLikePython310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-tree-", stdlib.tempfile.gettempdir())

        try {
            tree := stdlib.pathlib.Path(root, "tree")
            nested := tree.joinpath("nested")
            file := nested.joinpath("payload.txt")

            nested.mkdir({ Parents: true })
            file.write_text("payload")

            AhkTest.AssertEqual("", stdlib.shutil.rmtree(tree))
            AhkTest.AssertFalse(tree.exists())
            AhkTest.RaisesMatch(OSError, "No such file or directory", (*) => stdlib.shutil.rmtree(tree))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestShutilRaisesPythonStyleErrorsForInvalidCopyTargets()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-errors-", stdlib.tempfile.gettempdir())

        try {
            src := stdlib.pathlib.Path(root, "src.txt")
            dirTarget := stdlib.pathlib.Path(root, "folder")
            fileTarget := stdlib.pathlib.Path(root, "dircopy.txt")
            src.write_text("alpha")
            dirTarget.mkdir()

            AhkTest.RaisesMatch(stdlib.shutil.SameFileError, "are the same file", (*) => stdlib.shutil.copyfile(src, src))
            AhkTest.RaisesMatch(OSError, "No such file or directory", (*) => stdlib.shutil.copyfile(stdlib.pathlib.Path(root, "missing.txt"), stdlib.pathlib.Path(root, "x.txt")))
            AhkTest.RaisesMatch(OSError, "Permission denied", (*) => stdlib.shutil.copyfile(src, dirTarget))
            AhkTest.RaisesMatch(OSError, "Permission denied", (*) => stdlib.shutil.copyfile(dirTarget, fileTarget))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestCopy2PreservesContentAndModificationTimeLikePython310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-copy2-", stdlib.tempfile.gettempdir())

        try {
            src := stdlib.pathlib.Path(root, "src.txt")
            dst := stdlib.pathlib.Path(root, "dst.txt")
            src.write_text("beta")

            srcPath := String(src)
            FileSetTime "20200102030405", srcPath, "M"

            result := stdlib.shutil.copy2(src, dst)
            AhkTest.AssertEqual(String(dst), result)
            AhkTest.AssertEqual("beta", dst.read_text())
            AhkTest.AssertEqual(FileGetTime(srcPath, "M"), FileGetTime(String(dst), "M"))
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestCopyfileobjCopiesBetweenFileLikeObjectsLikePython310()
    {
        srcObj := stdlib.io.StringIO("hello world payload")
        dstObj := stdlib.io.StringIO()

        result := stdlib.shutil.copyfileobj(srcObj, dstObj, 4)
        AhkTest.AssertTrue(AhkStdlibIsNone(result))
        AhkTest.AssertEqual("hello world payload", dstObj.getvalue())
    }

    static TestCopytreeRecursivelyCopiesTreeLikePython310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-copytree-", stdlib.tempfile.gettempdir())

        try {
            srcTree := stdlib.pathlib.Path(root, "src")
            nested := srcTree.joinpath("nested")
            nested.mkdir({ Parents: true })
            srcTree.joinpath("top.txt").write_text("top")
            nested.joinpath("deep.txt").write_text("deep")

            dstTree := stdlib.pathlib.Path(root, "dst")
            stdlib.shutil.copytree(srcTree, dstTree)

            AhkTest.AssertTrue(dstTree.joinpath("top.txt").exists())
            AhkTest.AssertEqual("top", dstTree.joinpath("top.txt").read_text())
            AhkTest.AssertEqual("deep", dstTree.joinpath("nested", "deep.txt").read_text())

            ; existing target without dirs_exist_ok raises
            AhkTest.RaisesMatch(OSError, "already exists", (*) => stdlib.shutil.copytree(srcTree, dstTree))
            ; with dirs_exist_ok it succeeds
            stdlib.shutil.copytree(srcTree, dstTree, { dirs_exist_ok: true })
            AhkTest.AssertEqual("top", dstTree.joinpath("top.txt").read_text())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestCopytreeHonorsIgnorePatternsLikePython310()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-ignore-", stdlib.tempfile.gettempdir())

        try {
            srcTree := stdlib.pathlib.Path(root, "src")
            srcTree.mkdir()
            srcTree.joinpath("keep.txt").write_text("keep")
            srcTree.joinpath("skip.pyc").write_text("skip")

            dstTree := stdlib.pathlib.Path(root, "dst")
            stdlib.shutil.copytree(srcTree, dstTree, { ignore: stdlib.shutil.ignore_patterns("*.pyc") })

            AhkTest.AssertTrue(dstTree.joinpath("keep.txt").exists())
            AhkTest.AssertFalse(dstTree.joinpath("skip.pyc").exists())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestDiskUsageReturnsPlausibleTotalsLikePython310()
    {
        usage := stdlib.shutil.disk_usage(stdlib.tempfile.gettempdir())
        AhkTest.AssertEqual(3, usage.Length)

        total := usage[1]
        used := usage[2]
        free := usage[3]

        AhkTest.AssertTrue(total > 0)
        AhkTest.AssertTrue(free >= 0)
        AhkTest.AssertTrue(free <= total)
        AhkTest.AssertEqual(total, used + free)
    }

    static TestWhichFindsExecutableOnPathLikePython310()
    {
        ; cmd.exe is on PATH; reference: shutil.which("cmd") finds it
        found := stdlib.shutil.which("cmd")
        AhkTest.AssertFalse(AhkStdlibIsNone(found))
        AhkTest.AssertTrue(InStr(found, "cmd.exe") > 0 || InStr(found, "cmd.EXE") > 0)
        AhkTest.AssertTrue(FileExist(found) != "")

        ; nonexistent command returns None
        AhkTest.AssertTrue(AhkStdlibIsNone(stdlib.shutil.which("definitely-not-a-real-command-xyz")))
    }

    static TestGetTerminalSizeReturnsFallbackWithoutConsoleLikePython310()
    {
        ; No console attached during test runs, so the fallback is returned.
        size := stdlib.shutil.get_terminal_size()
        AhkTest.AssertEqual(2, size.Length)
        AhkTest.AssertEqual(80, size[1])
        AhkTest.AssertEqual(24, size[2])

        custom := stdlib.shutil.get_terminal_size([120, 40])
        AhkTest.AssertEqual(120, custom[1])
        AhkTest.AssertEqual(40, custom[2])
    }

    static TestCopystatPreservesMtimeAndReadonly()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-stat-", stdlib.tempfile.gettempdir())
        try {
            src := root "\src.txt"
            dst := root "\dst.txt"
            FileAppend "alpha", src
            FileAppend "beta", dst
            FileSetTime "20200102030405", src, "M"
            FileSetAttrib "+R", src
            stdlib.shutil.copystat(src, dst)
            AhkTest.AssertEqual(FileGetTime(src, "M"), FileGetTime(dst, "M"))
            AhkTest.AssertContains("R", FileGetAttrib(dst))
            FileSetAttrib "-R", src
            FileSetAttrib "-R", dst
        } finally {
            DirDelete root, true
        }
    }

    static TestGetArchiveFormatsListsZipAndTarSorted()
    {
        formats := stdlib.shutil.get_archive_formats()
        names := []
        for entry in formats
            names.Push(entry[1])
        AhkTest.AssertContains("zip", AhkStdlibShutilTestJoin(names))
        AhkTest.AssertContains("gztar", AhkStdlibShutilTestJoin(names))
        AhkTest.AssertEqual("bztar", names[1])
    }

    static TestMakeAndUnpackZipArchiveRoundTrips()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-zip-", stdlib.tempfile.gettempdir())
        try {
            srcDir := root "\payload"
            DirCreate srcDir
            FileAppend "hello-zip", srcDir "\a.txt"
            base := root "\bundle"
            archive := stdlib.shutil.make_archive(base, "zip", srcDir)
            AhkTest.AssertTrue(FileExist(archive) != "")

            outDir := root "\out"
            stdlib.shutil.unpack_archive(archive, outDir)
            AhkTest.AssertTrue(FileExist(outDir "\a.txt") != "")
            AhkTest.AssertEqual("hello-zip", FileRead(outDir "\a.txt"))
        } finally {
            DirDelete root, true
        }
    }

    static TestMakeAndUnpackTarArchiveRoundTrips()
    {
        root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-tar-", stdlib.tempfile.gettempdir())
        try {
            srcDir := root "\payload"
            DirCreate srcDir
            FileAppend "hello-tar", srcDir "\b.txt"
            base := root "\bundle"
            archive := stdlib.shutil.make_archive(base, "gztar", srcDir)
            AhkTest.AssertTrue(FileExist(archive) != "")

            outDir := root "\out"
            stdlib.shutil.unpack_archive(archive, outDir)
            AhkTest.AssertTrue(FileExist(outDir "\b.txt") != "")
            AhkTest.AssertEqual("hello-tar", FileRead(outDir "\b.txt"))
        } finally {
            DirDelete root, true
        }
    }

    static TestChownReproducesPython310WindowsBehavior()
    {
        ; CPython 3.10's shutil.chown exists on Windows but cannot function:
        ; no pwd/grp database, and os.chown is undefined. We reproduce its
        ; exact observed errors.
        ; Neither user nor group set -> ValueError.
        AhkTest.RaisesMatch(ValueError, "^user and/or group must be set$", (*) => stdlib.shutil.chown("anything"))

        ; String user/group: name resolution fails -> LookupError.
        AhkTest.RaisesMatch(LookupError, "^no such user: 'x'$", (*) => stdlib.shutil.chown("anything", "x"))
        AhkTest.RaisesMatch(LookupError, "^no such group: 'g'$", (*) => stdlib.shutil.chown("anything", , "g"))

        ; Integer id: skips name lookup, reaches the absent os.chown -> AttributeError.
        AhkTest.RaisesMatch(AttributeError, "module 'os' has no attribute 'chown'", (*) => stdlib.shutil.chown("anything", 1000))
        AhkTest.RaisesMatch(AttributeError, "module 'os' has no attribute 'chown'", (*) => stdlib.shutil.chown("anything", 1000, 1000))

        ; LookupError is the base of KeyError in our hierarchy (matching CPython).
        AhkTest.AssertTrue(KeyError("k") is LookupError)
    }
}

AhkStdlibShutilTestJoin(arr)
{
    out := ""
    for value in arr
        out .= value ","
    return out
}

AhkTest.Collect(StdlibShutilTest)

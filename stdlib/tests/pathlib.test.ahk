#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\pathlib>

class StdlibPathlibTest
{
    static TestPathPartsAndJoiningFollowWindowsPath()
    {
        path := stdlib.pathlib.Path("alpha", "beta.txt")

        AhkTest.AssertEqual("alpha\beta.txt", String(path))
        AhkTest.AssertEqual("beta.txt", path.name)
        AhkTest.AssertEqual("beta", path.stem)
        AhkTest.AssertEqual(".txt", path.suffix)
        AhkTest.AssertEqual("alpha", String(path.parent))
        AhkTest.AssertEqual("alpha\beta\gamma.txt", String(stdlib.pathlib.Path("alpha").joinpath("beta", "gamma.txt")))
        AhkTest.AssertEqual("C:\child", String(stdlib.pathlib.Path("C:/base").joinpath("/child")))
        AhkTest.AssertEqual("D:\child", String(stdlib.pathlib.Path("C:/base").joinpath("D:/child")))
    }

    static TestPathReadsWritesAndDeletesTextFiles()
    {
        root := A_Temp "\stdlib-pathlib-test-" A_TickCount "-" Random(100000, 999999)
        file := stdlib.pathlib.Path(root, "dir", "payload.txt")

        try {
            AhkTest.AssertFalse(file.exists())
            AhkTest.AssertFalse(file.is_file())
            AhkTest.AssertFalse(file.is_dir())

            file.parent.mkdir({ parents: true, exist_ok: true })
            AhkTest.AssertTrue(file.parent.exists())
            AhkTest.AssertTrue(file.parent.is_dir())

            AhkTest.AssertEqual(5, file.write_text("hello", "UTF-8"))
            AhkTest.AssertTrue(file.exists())
            AhkTest.AssertTrue(file.is_file())
            AhkTest.AssertFalse(file.is_dir())
            AhkTest.AssertEqual("hello", file.read_text("UTF-8"))

            file.unlink()
            AhkTest.AssertFalse(file.exists())
            file.unlink({ missing_ok: true })
            file.parent.rmdir()
            AhkTest.AssertFalse(file.parent.exists())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestWriteTextRequiresExistingParentLikePython()
    {
        root := A_Temp "\stdlib-pathlib-missing-parent-" A_TickCount "-" Random(100000, 999999)
        file := stdlib.pathlib.Path(root, "missing", "payload.txt")

        try {
            AhkTest.AssertThrows(OSError, (*) => file.write_text("hello", "UTF-8"))
            AhkTest.AssertFalse(file.parent.exists())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestPartsAnchorDriveRootFollowPython310()
    {
        path := stdlib.pathlib.Path("C:/a/b/file.tar.gz")
        AhkTest.AssertEqual("C:\,a,b,file.tar.gz", StdlibPathlibTest.JoinParts(path.parts))
        AhkTest.AssertEqual("C:", path.drive)
        AhkTest.AssertEqual("\", path.root)
        AhkTest.AssertEqual("C:\", path.anchor)
        AhkTest.AssertTrue(path.is_absolute())
        AhkTest.AssertFalse(stdlib.pathlib.Path("a/b").is_absolute())
    }

    static TestSuffixesAndWithMethodsFollowPython310()
    {
        path := stdlib.pathlib.Path("C:/a/b/file.tar.gz")
        AhkTest.AssertEqual(".tar,.gz", StdlibPathlibTest.JoinParts(path.suffixes))
        AhkTest.AssertEqual("C:\a\b\x.txt", String(path.with_name("x.txt")))
        AhkTest.AssertEqual("C:\a\b\file.tar.zip", String(path.with_suffix(".zip")))
        AhkTest.AssertEqual("C:\a\b\y.gz", String(path.with_stem("y")))
    }

    static TestParentsYieldsAncestorChain()
    {
        path := stdlib.pathlib.Path("C:/a/b/c")
        chain := []
        for p in path.parents
            chain.Push(String(p))
        AhkTest.AssertEqual("C:\a\b", chain[1])
        AhkTest.AssertEqual("C:\a", chain[2])
        AhkTest.AssertEqual("C:\", chain[3])
    }

    static TestRelativeToAndMatch()
    {
        AhkTest.AssertEqual("b\c", String(stdlib.pathlib.Path("C:/a/b/c").relative_to("C:/a")))
        AhkTest.AssertTrue(AhkStdlibTruthValue(stdlib.pathlib.Path("a/b.txt").match("*.txt")))
        AhkTest.AssertFalse(AhkStdlibTruthValue(stdlib.pathlib.Path("a/b.txt").match("*.md")))
    }

    static TestIterdirAndGlob()
    {
        root := A_Temp "\stdlib-pathlib-glob-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            FileAppend "a", root "\a.txt"
            FileAppend "b", root "\b.txt"
            FileAppend "c", root "\c.log"
            DirCreate root "\sub"
            FileAppend "d", root "\sub\d.txt"

            base := stdlib.pathlib.Path(root)

            names := []
            for entry in base.iterdir()
                names.Push(entry.name)
            AhkTest.AssertEqual(4, names.Length)

            txt := []
            for entry in base.glob("*.txt")
                txt.Push(entry.name)
            AhkTest.AssertEqual(2, txt.Length)

            allTxt := []
            for entry in base.rglob("*.txt")
                allTxt.Push(entry.name)
            AhkTest.AssertEqual(3, allTxt.Length)
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestReadWriteBytesAndTouch()
    {
        root := A_Temp "\stdlib-pathlib-bytes-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            file := stdlib.pathlib.Path(root, "data.bin")
            buf := Buffer(3, 0)
            NumPut("UChar", 1, buf, 0)
            NumPut("UChar", 2, buf, 1)
            NumPut("UChar", 255, buf, 2)
            AhkTest.AssertEqual(3, file.write_bytes(buf))

            readBack := file.read_bytes()
            AhkTest.AssertEqual(3, readBack.Size)
            AhkTest.AssertEqual(255, NumGet(readBack, 2, "UChar"))

            touched := stdlib.pathlib.Path(root, "touched.txt")
            touched.touch()
            AhkTest.AssertTrue(touched.exists())
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static TestStatReturnsOsStatResult()
    {
        root := A_Temp "\stdlib-pathlib-stat-" A_TickCount "-" Random(100000, 999999)
        DirCreate root
        try {
            file := stdlib.pathlib.Path(root, "test.txt")
            file.write_text("hello", "UTF-8")
            st := file.stat()
            ; UTF-8 with BOM: 3 BOM bytes + 5 chars = 8 bytes
            AhkTest.AssertTrue(st.st_size > 0)
            AhkTest.AssertTrue(st.st_mtime > 0)
            ; lstat returns the same shape on Windows (no real symlink semantics)
            AhkTest.AssertEqual(st.st_size, file.lstat().st_size)
        } finally {
            if DirExist(root)
                DirDelete root, true
        }
    }

    static JoinParts(iterable)
    {
        out := ""
        for item in iterable
            out := out = "" ? String(item) : out "," String(item)
        return out
    }
}

AhkTest.Collect(StdlibPathlibTest)

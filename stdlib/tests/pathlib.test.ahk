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
}

AhkTest.Collect(StdlibPathlibTest)

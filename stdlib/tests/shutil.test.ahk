#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\shutil>
#Include <stdlib\tempfile>
#Include <stdlib\pathlib>

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
}

AhkTest.Collect(StdlibShutilTest)

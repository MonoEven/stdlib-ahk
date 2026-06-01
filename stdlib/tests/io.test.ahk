#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\io>

class StdlibIoTest
{
    static TestStringIOReadsWritesAndTracksPositionLikePython310()
    {
        stream := stdlib.io.StringIO("abc`ndef")

        AhkTest.AssertEqual("abc`ndef", stream.getvalue())
        AhkTest.AssertEqual("ab", stream.read(2))
        AhkTest.AssertEqual(2, stream.tell())
        AhkTest.AssertEqual("c`n", stream.readline())
        AhkTest.AssertEqual(4, stream.tell())
        AhkTest.AssertEqual(0, stream.seek(0))
        AhkTest.AssertEqual("abc`ndef", stream.read())

        writer := stdlib.io.StringIO()
        AhkTest.AssertEqual(2, writer.write("ab"))
        AhkTest.AssertEqual(2, writer.tell())
        AhkTest.AssertEqual("ab", writer.getvalue())
        AhkTest.AssertEqual(1, writer.seek(1))
        AhkTest.AssertEqual(1, writer.write("Z"))
        AhkTest.AssertEqual("aZ", writer.getvalue())
        AhkTest.AssertEqual(10, writer.seek(10))
        AhkTest.AssertEqual(1, writer.write("x"))
        AhkTest.AssertEqual("aZ" Chr(0) Chr(0) Chr(0) Chr(0) Chr(0) Chr(0) Chr(0) Chr(0) "x", writer.getvalue())
    }

    static TestStringIOSeekTruncateAndCloseFollowPython310()
    {
        stream := stdlib.io.StringIO("abcde")

        AhkTest.AssertEqual(3, stream.seek(3))
        AhkTest.AssertEqual(3, stream.tell())
        AhkTest.AssertEqual(5, stream.seek(0, stdlib.io.SEEK_END))
        AhkTest.AssertEqual(0, stream.seek(0, stdlib.io.SEEK_SET))
        AhkTest.AssertEqual(0, stream.seek(0, stdlib.io.SEEK_CUR))
        AhkTest.AssertEqual(2, stream.seek(2))
        AhkTest.AssertEqual(2, stream.truncate())
        AhkTest.AssertEqual("ab", stream.getvalue())
        AhkTest.AssertEqual(2, stream.tell())
        AhkTest.AssertEqual(5, stdlib.io.StringIO("abc").truncate(5))
        AhkTest.AssertEqual(2, stdlib.io.StringIO("abc").truncate(2))

        stream.close()
        AhkTest.AssertTrue(stream.closed)
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.read())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.write("x"))
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.getvalue())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.seek(0))
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.tell())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file", (*) => stream.truncate())
    }

    static TestStringIORejectsPythonStyleInvalidArguments()
    {
        AhkTest.AssertEqual("", stdlib.io.StringIO(stdlib.None).getvalue())
        AhkTest.RaisesMatch(TypeError, "initial_value must be str or None, not int", (*) => stdlib.io.StringIO(1))
        AhkTest.RaisesMatch(TypeError, "string argument expected, got 'Integer'", (*) => stdlib.io.StringIO("abc").write(1))
        AhkTest.RaisesMatch(ValueError, "Negative seek position -1", (*) => stdlib.io.StringIO().seek(-1))
        AhkTest.RaisesMatch(ValueError, "Invalid whence \(99, should be 0, 1 or 2\)", (*) => stdlib.io.StringIO().seek(0, 99))
        AhkTest.RaisesMatch(ValueError, "Negative size value -1", (*) => stdlib.io.StringIO("abc").truncate(-1))
        AhkTest.RaisesMatch(OSError, "Can't do nonzero cur-relative seeks", (*) => stdlib.io.StringIO("abc").seek(1, stdlib.io.SEEK_CUR))
        AhkTest.RaisesMatch(OSError, "Can't do nonzero cur-relative seeks", (*) => stdlib.io.StringIO("abc").seek(1, stdlib.io.SEEK_END))
    }
}

AhkTest.Collect(StdlibIoTest)

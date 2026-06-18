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

    static TestBytesIOReadsWritesAndTracksPositionLikePython310()
    {
        AhkTest.AssertEqual([], stdlib.io.BytesIO(stdlib.None).getvalue())
        AhkTest.AssertEqual([], stdlib.io.BytesIO().getvalue())
        AhkTest.AssertEqual([0, 97, 255], stdlib.io.BytesIO([0, 97, 255]).getvalue())

        stream := stdlib.io.BytesIO([97, 98, 99, 10, 120, 121])
        AhkTest.AssertEqual([97, 98], stream.read(2))
        AhkTest.AssertEqual(2, stream.tell())
        AhkTest.AssertEqual([99, 10], stream.readline())
        AhkTest.AssertEqual(4, stream.tell())
        AhkTest.AssertEqual([120, 121], stream.read())

        writer := stdlib.io.BytesIO()
        AhkTest.AssertEqual(2, writer.write([97, 98]))
        AhkTest.AssertEqual(5, writer.seek(5))
        AhkTest.AssertEqual(1, writer.write([120]))
        AhkTest.AssertEqual([97, 98, 0, 0, 0, 120], writer.getvalue())
        AhkTest.AssertEqual(6, writer.tell())

        overwrite := stdlib.io.BytesIO([97, 98, 99, 100, 101, 102])
        AhkTest.AssertEqual(2, overwrite.seek(2))
        AhkTest.AssertEqual(2, overwrite.write([90, 90]))
        AhkTest.AssertEqual([97, 98, 90, 90, 101, 102], overwrite.getvalue())
        AhkTest.AssertEqual(4, overwrite.tell())
    }

    static TestBytesIOReadlineReadlinesSeekTruncateAndCloseLikePython310()
    {
        lineStream := stdlib.io.BytesIO([97, 10, 98, 98, 10, 99, 99, 99])
        AhkTest.AssertEqual([97, 10], lineStream.readline())
        AhkTest.AssertEqual([98], lineStream.readline(1))
        AhkTest.AssertEqual([[98, 10], [99, 99, 99]], lineStream.readlines())

        AhkTest.AssertEqual(3, stdlib.io.BytesIO([97, 98, 99]).seek(0, stdlib.io.SEEK_END))
        AhkTest.AssertEqual(0, stdlib.io.BytesIO([97, 98, 99]).seek(0, stdlib.io.SEEK_CUR))
        AhkTest.AssertEqual(1, stdlib.io.BytesIO([97, 98, 99]).seek(1, stdlib.io.SEEK_CUR))

        truncate := stdlib.io.BytesIO([97, 98, 99, 100, 101])
        AhkTest.AssertEqual(3, truncate.seek(3))
        AhkTest.AssertEqual(3, truncate.truncate())
        AhkTest.AssertEqual([97, 98, 99], truncate.getvalue())
        AhkTest.AssertEqual(3, truncate.tell())

        truncateExtend := stdlib.io.BytesIO([97, 98, 99])
        AhkTest.AssertEqual(5, truncateExtend.truncate(5))
        AhkTest.AssertEqual([97, 98, 99], truncateExtend.getvalue())

        closed := stdlib.io.BytesIO([97, 98, 99])
        AhkTest.AssertSame(stdlib.None, closed.close())
        AhkTest.AssertTrue(closed.closed)
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.read())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.write([120]))
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.getvalue())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.seek(0))
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.tell())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.truncate())
    }

    static TestBytesIORejectsPythonStyleInvalidArguments()
    {
        AhkTest.RaisesMatch(TypeError, "a bytes-like object is required, not 'str'", (*) => stdlib.io.BytesIO("abc"))
        AhkTest.RaisesMatch(TypeError, "a bytes-like object is required, not 'int'", (*) => stdlib.io.BytesIO(1))
        AhkTest.RaisesMatch(TypeError, "a bytes-like object is required, not 'str'", (*) => stdlib.io.BytesIO().write("x"))
        AhkTest.RaisesMatch(TypeError, "argument should be integer or None, not 'str'", (*) => stdlib.io.BytesIO([97, 98, 99]).read("x"))
        AhkTest.RaisesMatch(ValueError, "negative seek value -1", (*) => stdlib.io.BytesIO([97, 98, 99]).seek(-1))
        AhkTest.RaisesMatch(ValueError, "invalid whence \(99, should be 0, 1 or 2\)", (*) => stdlib.io.BytesIO([97, 98, 99]).seek(0, 99))
        AhkTest.RaisesMatch(ValueError, "negative size value -1", (*) => stdlib.io.BytesIO([97, 98, 99]).truncate(-1))
        AhkTest.RaisesMatch(ValueError, "byte must be in range\(0, 256\)", (*) => stdlib.io.BytesIO([256]))
    }

    static TestBytesIOFileLikeMethodsFollowPython310()
    {
        stream := stdlib.io.BytesIO([97, 98, 99, 100, 101, 102])

        AhkTest.AssertTrue(stream.readable())
        AhkTest.AssertTrue(stream.writable())
        AhkTest.AssertTrue(stream.seekable())
        AhkTest.AssertFalse(stream.isatty())
        AhkTest.AssertSame(stdlib.None, stream.flush())
        AhkTest.AssertEqual([97, 98], stream.read1(2))
        AhkTest.AssertEqual([99, 100, 101, 102], stream.read1())

        readintoTarget := Buffer(4, 0)
        readintoStream := stdlib.io.BytesIO([97, 98, 99, 100, 101, 102])
        AhkTest.AssertEqual(4, readintoStream.readinto(readintoTarget))
        AhkTest.AssertEqual([97, 98, 99, 100], StdlibIoTest.BufferBytes(readintoTarget))
        AhkTest.AssertEqual(4, readintoStream.tell())

        readintoLimitedTarget := Buffer(4, 0)
        readintoLimitedStream := stdlib.io.BytesIO([120, 121])
        AhkTest.AssertEqual(2, readintoLimitedStream.readinto(readintoLimitedTarget))
        AhkTest.AssertEqual([120, 121, 0, 0], StdlibIoTest.BufferBytes(readintoLimitedTarget))
        AhkTest.AssertEqual(2, readintoLimitedStream.tell())

        readinto1Target := Buffer(3, 0)
        readinto1Stream := stdlib.io.BytesIO([97, 98, 99, 100, 101, 102])
        AhkTest.AssertEqual(3, readinto1Stream.readinto1(readinto1Target))
        AhkTest.AssertEqual([97, 98, 99], StdlibIoTest.BufferBytes(readinto1Target))
        AhkTest.AssertEqual(3, readinto1Stream.tell())

        writer := stdlib.io.BytesIO()
        lineBytes := Buffer(1, 0)
        NumPut("UChar", 100, lineBytes, 0)
        AhkTest.AssertSame(stdlib.None, writer.writelines([[97, 98], [99], lineBytes]))
        AhkTest.AssertEqual([97, 98, 99, 100], writer.getvalue())

        AhkTest.RaisesMatch(stdlib.io.UnsupportedOperation, "^fileno$", (*) => stdlib.io.BytesIO().fileno())
        AhkTest.RaisesMatch(stdlib.io.UnsupportedOperation, "^detach$", (*) => stdlib.io.BytesIO().detach())
        AhkTest.RaisesMatch(TypeError, "readinto\(\) argument must be read-write bytes-like object, not str", (*) => stdlib.io.BytesIO([97, 98, 99]).readinto("xxxx"))
        AhkTest.RaisesMatch(TypeError, "a bytes-like object is required, not 'str'", (*) => stdlib.io.BytesIO().writelines(["x"]))

        closed := stdlib.io.BytesIO([97, 98, 99])
        closed.close()
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.readable())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.writable())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.seekable())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.isatty())
        AhkTest.RaisesMatch(ValueError, "I/O operation on closed file\.", (*) => closed.flush())
    }

    static BufferBytes(buffer)
    {
        bytes := []
        loop buffer.Size
            bytes.Push(NumGet(buffer, A_Index - 1, "UChar"))
        return bytes
    }

    static TestStringIOReadlinesWritelinesAndDefaultBufferSize()
    {
        AhkTest.AssertEqual(8192, stdlib.io.DEFAULT_BUFFER_SIZE)

        AhkTest.AssertEqual(["a`n", "b`n", "c"], stdlib.io.StringIO("a`nb`nc").readlines())
        AhkTest.AssertEqual(["a`n", "b"], stdlib.io.StringIO("a`nb").readlines())
        AhkTest.AssertEqual(["a`n", "b`n"], stdlib.io.StringIO("a`nb`n").readlines())
        AhkTest.AssertEqual([], stdlib.io.StringIO("").readlines())
        AhkTest.AssertEqual(["abc"], stdlib.io.StringIO("abc").readlines(0))
        AhkTest.AssertEqual(["aa`n", "bb`n"], stdlib.io.StringIO("aa`nbb`ncc`n").readlines(3))

        mid := stdlib.io.StringIO("a`nb`nc")
        mid.read(1)
        AhkTest.AssertEqual(["`n", "b`n", "c"], mid.readlines())

        writer := stdlib.io.StringIO()
        AhkTest.AssertSame(stdlib.None, writer.writelines(["a`n", "b"]))
        AhkTest.AssertEqual("a`nb", writer.getvalue())

        AhkTest.RaisesMatch(TypeError, "string argument expected, got 'Integer'", (*) => stdlib.io.StringIO().writelines([1]))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.io.StringIO().writelines(5))
    }

    static TestOpenWritesAndReadsTempFileLikePython310()
    {
        path := A_Temp "\ahk_io_open_probe.txt"
        if FileExist(path)
            FileDelete(path)

        try {
            writer := stdlib.io.open(path, "w")
            AhkTest.AssertEqual(11, writer.write("hello`nworld"))
            writer.close()

            reader := stdlib.io.open(path, "r")
            AhkTest.AssertEqual("hello`nworld", reader.read())
            AhkTest.AssertEqual(0, reader.seek(0))
            AhkTest.AssertEqual("hello`n", reader.readline())
            AhkTest.AssertEqual(["world"], reader.readlines())
            reader.close()

            appender := stdlib.io.open(path, "a")
            appender.write("!")
            appender.close()
            after := stdlib.io.open(path, "r")
            AhkTest.AssertEqual("hello`nworld!", after.read())
            after.close()
        } finally {
            if FileExist(path)
                FileDelete(path)
        }

        AhkTest.RaisesMatch(ValueError, "invalid mode: 'q'", (*) => stdlib.io.open(path, "q"))
        AhkTest.RaisesMatch(OSError, "No such file or directory", (*) => stdlib.io.open(A_Temp "\ahk_io_missing_xyz.txt", "r"))
    }

    static TestTextIOWrapperOverByteBuffer()
    {
        buf := stdlib.io.BytesIO([104, 105, 10, 98, 121, 101])
        wrapper := stdlib.io.TextIOWrapper(buf)
        AhkTest.AssertEqual("hi`nbye", wrapper.read())
        AhkTest.AssertEqual(0, wrapper.seek(0))
        AhkTest.AssertEqual("hi`n", wrapper.readline())

        writeBuf := stdlib.io.BytesIO()
        writeWrapper := stdlib.io.TextIOWrapper(writeBuf)
        AhkTest.AssertEqual(2, writeWrapper.write("ab"))
        AhkTest.AssertEqual([97, 98], writeBuf.getvalue())
    }

    static TestTextIOWrapperUniversalNewlinesOnRead()
    {
        ; \r\n collapses to \n on read (universal newlines), matching CPython.
        bytes := []
        for ch in StrSplit("line1`r`nline2`r`n")
            bytes.Push(Ord(ch) & 0xFF)
        buf := stdlib.io.BytesIO(bytes)
        wrapper := stdlib.io.TextIOWrapper(buf, "UTF-8")
        AhkTest.AssertEqual("line1`nline2`n", wrapper.read())
    }

    static TestTextIOWrapperUtf8RoundTrip()
    {
        buf := stdlib.io.BytesIO()
        w := stdlib.io.TextIOWrapper(buf, "UTF-8")
        w.write("caf" Chr(0xE9))            ; "café"
        ; UTF-8 encodes é as two bytes 0xC3 0xA9.
        raw := buf.getvalue()
        AhkTest.AssertEqual(0xC3, raw[4])
        AhkTest.AssertEqual(0xA9, raw[5])
        ; Reading it back through a fresh wrapper restores the text.
        buf2 := stdlib.io.BytesIO(raw)
        r := stdlib.io.TextIOWrapper(buf2, "UTF-8")
        AhkTest.AssertEqual("caf" Chr(0xE9), r.read())
    }

    static TestBufferedWriterReaderRoundTripThroughFile()
    {
        path := A_Temp "\ahk_io_buftest_" Random(100000, 999999) ".bin"
        try {
            raw := stdlib.io.FileIO(path, "w")
            bw := stdlib.io.BufferedWriter(raw)
            payload := Buffer(5)
            loop 5
                NumPut("UChar", 64 + A_Index, payload, A_Index - 1)   ; A B C D E
            bw.write(payload)
            bw.close()

            rraw := stdlib.io.FileIO(path, "r")
            br := stdlib.io.BufferedReader(rraw)
            got := br.read(-1)
            br.close()
            AhkTest.AssertEqual(5, got.Size)
            AhkTest.AssertEqual(65, NumGet(got, 0, "UChar"))
            AhkTest.AssertEqual(69, NumGet(got, 4, "UChar"))
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }

    static TestUnsupportedOperationOnNonSeekableStream()
    {
        ; A BufferedWriter wrapping a writable-only FileIO is not readable; read
        ; raises UnsupportedOperation.
        path := A_Temp "\ahk_io_unsupported_" Random(100000, 999999) ".bin"
        try {
            raw := stdlib.io.FileIO(path, "w")
            AhkTest.AssertThrows(stdlib.io.UnsupportedOperation, (*) => raw.read(1))
            raw.close()
        } finally {
            if FileExist(path)
                FileDelete path
        }
    }
}

AhkTest.Collect(StdlibIoTest)

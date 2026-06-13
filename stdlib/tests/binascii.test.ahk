#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\binascii>

class StdlibBinasciiTest
{
    static TestCoveredHexlifyAndUnhexlifyMatchObservedLocal310Surface()
    {
        AhkTest.AssertSame(stdlib.binascii.Error, stdlib.binascii.Error)
        AhkTest.AssertFalse(stdlib.binascii.Error == stdlib.binascii.Incomplete)
        AhkTest.AssertTrue(stdlib.binascii.Error() is Error)
        AhkTest.AssertTrue(stdlib.binascii.Incomplete() is Error)

        AhkTest.AssertEqual("616263", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"))))
        AhkTest.AssertEqual("616263", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_hex(StdlibBinasciiTest.Bytes("abc"))))
        AhkTest.AssertEqual("", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes(""))))
        AhkTest.AssertEqual("61:62:63", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"), StdlibBinasciiTest.Bytes(":"), 1)))
        AhkTest.AssertEqual("6162:6364", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abcd"), StdlibBinasciiTest.Bytes(":"), 2)))
        AhkTest.AssertEqual("616263", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"), StdlibBinasciiTest.Bytes(":"), 0)))
        AhkTest.AssertEqual("616263", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"), StdlibBinasciiTest.Bytes(":"), stdlib.False)))
        AhkTest.AssertEqual("61:62:63", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"), StdlibBinasciiTest.Bytes(":"), stdlib.True)))
        AhkTest.AssertEqual("61:62:63", StdlibBinasciiTest.BufferText(stdlib.binascii.hexlify(StdlibBinasciiTest.Bytes("abc"), ":", 1)))

        AhkTest.AssertEqual("abc", StdlibBinasciiTest.BufferText(stdlib.binascii.unhexlify("616263")))
        AhkTest.AssertEqual("abc", StdlibBinasciiTest.BufferText(stdlib.binascii.unhexlify(StdlibBinasciiTest.Bytes("616263"))))
        AhkTest.AssertEqual("ABC", StdlibBinasciiTest.BufferText(stdlib.binascii.unhexlify("414243")))
        AhkTest.AssertEqual("", StdlibBinasciiTest.BufferText(stdlib.binascii.unhexlify("")))
        AhkTest.AssertEqual("abc", StdlibBinasciiTest.BufferText(stdlib.binascii.a2b_hex("616263")))
    }

    static TestObservedBinasciiErrorsMatchLocal310()
    {
        bytes := StdlibBinasciiTest.Bytes("abc")
        colon := StdlibBinasciiTest.Bytes(":")

        AhkTest.RaisesMatch(TypeError, "^hexlify\(\) missing required argument 'data' \(pos 1\)$", (*) => stdlib.binascii.hexlify())
        AhkTest.RaisesMatch(TypeError, "^hexlify\(\) takes at most 3 arguments \(4 given\)$", (*) => stdlib.binascii.hexlify(bytes, colon, 1, 2))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.binascii.hexlify("abc"))
        AhkTest.RaisesMatch(TypeError, "^object of type 'int' has no len\(\)$", (*) => stdlib.binascii.hexlify(bytes, 58))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.binascii.hexlify(bytes, colon, "x"))
        AhkTest.RaisesMatch(TypeError, "^'NoneType' object cannot be interpreted as an integer$", (*) => stdlib.binascii.hexlify(bytes, colon, stdlib.None))
        AhkTest.RaisesMatch(ValueError, "^sep must be length 1\.$", (*) => stdlib.binascii.hexlify(bytes, StdlibBinasciiTest.Bytes("")))
        AhkTest.RaisesMatch(ValueError, "^sep must be length 1\.$", (*) => stdlib.binascii.hexlify(bytes, StdlibBinasciiTest.Bytes("::")))

        AhkTest.RaisesMatch(TypeError, "^binascii\.unhexlify\(\) takes exactly one argument \(0 given\)$", (*) => stdlib.binascii.unhexlify())
        AhkTest.RaisesMatch(TypeError, "^binascii\.unhexlify\(\) takes exactly one argument \(2 given\)$", (*) => stdlib.binascii.unhexlify("61", "62"))
        AhkTest.RaisesMatch(TypeError, "^argument should be bytes, buffer or ASCII string, not 'int'$", (*) => stdlib.binascii.unhexlify(1))
        AhkTest.RaisesMatch(stdlib.binascii.Error, "^Odd-length string$", (*) => stdlib.binascii.unhexlify("abc"))
        AhkTest.RaisesMatch(stdlib.binascii.Error, "^Non-hexadecimal digit found$", (*) => stdlib.binascii.unhexlify("zz"))
    }

    static TestCrc32MatchesLocal310()
    {
        AhkTest.AssertEqual(891568578, stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("abc")))
        AhkTest.AssertEqual(0, stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("")))
        AhkTest.AssertEqual(1826356594, stdlib.binascii.crc32(StdlibBinasciiTest.ByteValues([0x00, 0xff])))
        AhkTest.AssertEqual(887499765, stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("abc"), 1))
        AhkTest.AssertEqual(899311407, stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("abc"), -1))

        AhkTest.RaisesMatch(TypeError, "^crc32 expected at least 1 argument, got 0$", (*) => stdlib.binascii.crc32())
        AhkTest.RaisesMatch(TypeError, "^crc32 expected at most 2 arguments, got 3$", (*) => stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("abc"), 1, 2))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.binascii.crc32("abc"))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.binascii.crc32(StdlibBinasciiTest.Bytes("abc"), "1"))
    }

    static TestBase64HelpersMatchLocal310()
    {
        AhkTest.AssertEqual("YWJj`n", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_base64(StdlibBinasciiTest.Bytes("abc"))))
        AhkTest.AssertEqual("`n", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_base64(StdlibBinasciiTest.Bytes(""))))
        AhkTest.AssertEqual("+/8=`n", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_base64(StdlibBinasciiTest.ByteValues([0xfb, 0xff]))))
        AhkTest.AssertEqual("YWJj", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_base64(StdlibBinasciiTest.Bytes("abc"), { newline: false })))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.binascii.b2a_base64("abc"))

        AhkTest.AssertEqual("abc", StdlibBinasciiTest.BufferText(stdlib.binascii.a2b_base64(StdlibBinasciiTest.Bytes("YWJj`n"))))
        AhkTest.AssertEqual("abc", StdlibBinasciiTest.BufferText(stdlib.binascii.a2b_base64("YWJj`n")))
        AhkTest.AssertEqual("fbff", StdlibBinasciiTest.BufferHex(stdlib.binascii.a2b_base64(StdlibBinasciiTest.Bytes("+/8=`n"))))
        AhkTest.AssertEqual("", StdlibBinasciiTest.BufferHex(stdlib.binascii.a2b_base64(StdlibBinasciiTest.Bytes("!!!!"))))
    }

    static TestCrcHqxMatchesPython310()
    {
        AhkTest.AssertEqual(50018, stdlib.binascii.crc_hqx(StdlibBinasciiTest.Bytes("hello"), 0))
        AhkTest.AssertEqual(65535, stdlib.binascii.crc_hqx(StdlibBinasciiTest.Bytes(""), 0xffff))
        AhkTest.AssertEqual(31879, stdlib.binascii.crc_hqx(StdlibBinasciiTest.Bytes("a"), 0))
        AhkTest.RaisesMatch(TypeError, "crc_hqx", (*) => stdlib.binascii.crc_hqx(StdlibBinasciiTest.Bytes("a")))
    }

    static TestQpEncodeDecodeRoundTripMatchesPython310()
    {
        ; b2a_qp simple ASCII -> unchanged
        AhkTest.AssertEqual("hi", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_qp(StdlibBinasciiTest.Bytes("hi"))))
        ; b2a_qp with '=' -> =3D
        AhkTest.AssertEqual("a=3Db", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_qp(StdlibBinasciiTest.Bytes("a=b"))))
        ; b2a_qp non-ASCII (0xE9) -> =E9
        nonAscii := Buffer(4, 0)
        NumPut("UChar", Ord("c"), nonAscii, 0)
        NumPut("UChar", Ord("a"), nonAscii, 1)
        NumPut("UChar", Ord("f"), nonAscii, 2)
        NumPut("UChar", 0xE9, nonAscii, 3)
        AhkTest.AssertEqual("caf=E9", StdlibBinasciiTest.BufferText(stdlib.binascii.b2a_qp(nonAscii)))

        ; a2b_qp =XX -> bytes
        AhkTest.AssertEqual("hi", StdlibBinasciiTest.BufferText(stdlib.binascii.a2b_qp(StdlibBinasciiTest.Bytes("=68=69"))))
        ; a2b_qp soft line break (=\n) drops both
        softBreak := Buffer(4, 0)
        NumPut("UChar", Ord("a"), softBreak, 0)
        NumPut("UChar", Ord("="), softBreak, 1)
        NumPut("UChar", 0x0A, softBreak, 2)
        NumPut("UChar", Ord("b"), softBreak, 3)
        AhkTest.AssertEqual("ab", StdlibBinasciiTest.BufferText(stdlib.binascii.a2b_qp(softBreak)))
    }

    static Bytes(text)
    {
        size := StrPut(text, "UTF-8") - 1
        bytes := Buffer(size, 0)
        if size > 0
            StrPut(text, bytes, "UTF-8")
        return bytes
    }

    static BufferText(bytes)
    {
        return bytes.Size > 0 ? StrGet(bytes, "UTF-8") : ""
    }

    static ByteValues(values)
    {
        bytes := Buffer(values.Length, 0)
        for index, value in values
            NumPut("UChar", value, bytes, index - 1)
        return bytes
    }

    static BufferHex(bytes)
    {
        output := ""
        loop bytes.Size
            output .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return output
    }
}

AhkTest.Collect(StdlibBinasciiTest)

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
}

AhkTest.Collect(StdlibBinasciiTest)

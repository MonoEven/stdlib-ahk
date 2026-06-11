#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\base64>

class StdlibBase64Test
{
    static TestCoveredB64EncodeDecodeMatchObservedLocal310Surface()
    {
        AhkTest.AssertEqual("YWJj", StdlibBase64Test.BufferText(stdlib.base64.b64encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("", StdlibBase64Test.BufferText(stdlib.base64.b64encode(StdlibBase64Test.Bytes(""))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b64decode(StdlibBase64Test.Bytes("YWJj"))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b64decode("YWJj")))
        AhkTest.AssertEqual("a", StdlibBase64Test.BufferText(stdlib.base64.b64decode(StdlibBase64Test.Bytes("YQ=="))))
        AhkTest.AssertEqual("??", StdlibBase64Test.BufferText(stdlib.base64.b64decode(StdlibBase64Test.Bytes("Pz8="), StdlibBase64Test.Bytes("-_"))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b64decode(StdlibBase64Test.Bytes("YWJj"), stdlib.None, stdlib.True)))
    }

    static TestObservedB64EncodeDecodeErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^b64encode\(\) missing 1 required positional argument: 's'$", (*) => stdlib.base64.b64encode())
        AhkTest.RaisesMatch(TypeError, "^b64encode\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.base64.b64encode(StdlibBase64Test.Bytes("abc"), StdlibBase64Test.Bytes("-_"), 1))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.base64.b64encode("abc"))
        AhkTest.RaisesMatch(TypeError, "^b64decode\(\) missing 1 required positional argument: 's'$", (*) => stdlib.base64.b64decode())
        AhkTest.RaisesMatch(TypeError, "^argument should be a bytes-like object or ASCII string, not 'int'$", (*) => stdlib.base64.b64decode(1))
        AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^b'!'$", (*) => stdlib.base64.b64encode(StdlibBase64Test.Bytes("abc"), StdlibBase64Test.Bytes("!")))
        AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^b'!'$", (*) => stdlib.base64.b64decode(StdlibBase64Test.Bytes("YWJj"), StdlibBase64Test.Bytes("!")))
    }

    static TestUrlsafeB64EncodeDecodeMatchLocal310()
    {
        AhkTest.AssertEqual("YWJj", StdlibBase64Test.BufferText(stdlib.base64.urlsafe_b64encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("-_8=", StdlibBase64Test.BufferText(stdlib.base64.urlsafe_b64encode(StdlibBase64Test.ByteValues([0xfb, 0xff]))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.urlsafe_b64decode("YWJj")))
        AhkTest.AssertEqual("fbff", StdlibBase64Test.BufferHex(stdlib.base64.urlsafe_b64decode(StdlibBase64Test.Bytes("-_8="))))

        AhkTest.RaisesMatch(TypeError, "^urlsafe_b64encode\(\) missing 1 required positional argument: 's'$", (*) => stdlib.base64.urlsafe_b64encode())
        AhkTest.RaisesMatch(TypeError, "^urlsafe_b64encode\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.base64.urlsafe_b64encode(StdlibBase64Test.Bytes("abc"), StdlibBase64Test.Bytes("-_")))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.base64.urlsafe_b64encode("abc"))
        AhkTest.RaisesMatch(TypeError, "^urlsafe_b64decode\(\) missing 1 required positional argument: 's'$", (*) => stdlib.base64.urlsafe_b64decode())
        AhkTest.RaisesMatch(TypeError, "^urlsafe_b64decode\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.base64.urlsafe_b64decode(StdlibBase64Test.Bytes("YWJj"), StdlibBase64Test.Bytes("-_")))
        AhkTest.RaisesMatch(TypeError, "^argument should be a bytes-like object or ASCII string, not 'int'$", (*) => stdlib.base64.urlsafe_b64decode(1))
    }

    static TestStandardBytesAndBase16SurfaceMatchLocal310()
    {
        AhkTest.AssertEqual("YWJj", StdlibBase64Test.BufferText(stdlib.base64.standard_b64encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.standard_b64decode(StdlibBase64Test.Bytes("YWJj"))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.standard_b64decode("YWJj")))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.base64.standard_b64encode("abc"))

        AhkTest.AssertEqual("YWJj`n", StdlibBase64Test.BufferText(stdlib.base64.encodebytes(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("", StdlibBase64Test.BufferText(stdlib.base64.encodebytes(StdlibBase64Test.Bytes(""))))
        AhkTest.AssertEqual("YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh`nYQ==`n", StdlibBase64Test.BufferText(stdlib.base64.encodebytes(StdlibBase64Test.RepeatByte("a", 58))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.decodebytes(StdlibBase64Test.Bytes("YWJj`n"))))
        AhkTest.RaisesMatch(TypeError, "^expected bytes-like object, not str$", (*) => stdlib.base64.decodebytes("YWJj"))

        binary := StdlibBase64Test.ByteValues([0x41, 0x42, 0x43, 0x00, 0xff])
        AhkTest.AssertEqual("41424300FF", StdlibBase64Test.BufferText(stdlib.base64.b16encode(binary)))
        AhkTest.AssertEqual("41424300ff", StdlibBase64Test.BufferHex(stdlib.base64.b16decode(StdlibBase64Test.Bytes("41424300FF"))))
        AhkTest.AssertEqual("41424300ff", StdlibBase64Test.BufferHex(stdlib.base64.b16decode("41424300FF")))
        AhkTest.AssertEqual("", StdlibBase64Test.BufferHex(stdlib.base64.b16decode(StdlibBase64Test.Bytes(""))))
        AhkTest.RaisesMatch(Error, "^Non-base16 digit found$", (*) => stdlib.base64.b16decode(StdlibBase64Test.Bytes("41424300ff")))
        AhkTest.AssertEqual("41424300ff", StdlibBase64Test.BufferHex(stdlib.base64.b16decode(StdlibBase64Test.Bytes("41424300ff"), true)))
    }

    static TestBase32AndBase32HexSurfaceMatchLocal310()
    {
        AhkTest.AssertEqual(57, stdlib.base64.MAXBINSIZE)
        AhkTest.AssertEqual(76, stdlib.base64.MAXLINESIZE)

        binary := StdlibBase64Test.ByteValues([0x00, 0x01, 0x02, 0xfd, 0xfe, 0xff])
        AhkTest.AssertEqual("", StdlibBase64Test.BufferText(stdlib.base64.b32encode(StdlibBase64Test.Bytes(""))))
        AhkTest.AssertEqual("MFRGG===", StdlibBase64Test.BufferText(stdlib.base64.b32encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("AAAQF7P674======", StdlibBase64Test.BufferText(stdlib.base64.b32encode(binary)))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32decode(StdlibBase64Test.Bytes("MFRGG==="))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32decode("MFRGG===")))
        AhkTest.RaisesMatch(Error, "^Non-base32 digit found$", (*) => stdlib.base64.b32decode("mfrgg==="))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32decode("mfrgg===", stdlib.True)))
        AhkTest.AssertEqual("abc9", StdlibBase64Test.BufferText(stdlib.base64.b32decode("MFRGG00=", stdlib.False, StdlibBase64Test.Bytes("I"))))
        AhkTest.RaisesMatch(Error, "^Incorrect padding$", (*) => stdlib.base64.b32decode("MFRGG"))
        AhkTest.RaisesMatch(TypeError, "^argument should be a bytes-like object or ASCII string, not 'int'$", (*) => stdlib.base64.b32decode(1))

        AhkTest.AssertEqual("C5H66===", StdlibBase64Test.BufferText(stdlib.base64.b32hexencode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("000G5VFUVS======", StdlibBase64Test.BufferText(stdlib.base64.b32hexencode(binary)))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32hexdecode(StdlibBase64Test.Bytes("C5H66==="))))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32hexdecode("C5H66===")))
        AhkTest.RaisesMatch(Error, "^Non-base32 digit found$", (*) => stdlib.base64.b32hexdecode("c5h66==="))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b32hexdecode("c5h66===", stdlib.True)))
    }

    static TestBase85AndAscii85SurfaceMatchLocal310()
    {
        binary := StdlibBase64Test.ByteValues([0x00, 0x01, 0x02, 0xfd, 0xfe, 0xff])

        AhkTest.AssertEqual("", StdlibBase64Test.BufferText(stdlib.base64.b85encode(StdlibBase64Test.Bytes(""))))
        AhkTest.AssertEqual("VPaz", StdlibBase64Test.BufferText(stdlib.base64.b85encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("009F1{{H", StdlibBase64Test.BufferText(stdlib.base64.b85encode(binary)))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.b85decode("VPaz")))
        AhkTest.AssertEqual("000102fdfeff", StdlibBase64Test.BufferHex(stdlib.base64.b85decode(StdlibBase64Test.Bytes("009F1{{H"))))
        AhkTest.AssertEqual("VPazd", StdlibBase64Test.BufferText(stdlib.base64.b85encode(StdlibBase64Test.Bytes("abc"), true)))
        AhkTest.AssertEqual("61626300", StdlibBase64Test.BufferHex(stdlib.base64.b85decode("VPazd")))
        AhkTest.RaisesMatch(TypeError, "^argument should be a bytes-like object or ASCII string, not 'int'$", (*) => stdlib.base64.b85decode(1))

        AhkTest.AssertEqual("", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.Bytes(""))))
        AhkTest.AssertEqual("@:E^", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.Bytes("abc"))))
        AhkTest.AssertEqual("!!*0`"rr2", StdlibBase64Test.BufferText(stdlib.base64.a85encode(binary)))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.a85decode("@:E^")))
        AhkTest.AssertEqual("000102fdfeff", StdlibBase64Test.BufferHex(stdlib.base64.a85decode(StdlibBase64Test.Bytes("!!*0`"rr2"))))
        AhkTest.AssertEqual("<~@:E^~>", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.Bytes("abc"), { adobe: true })))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.a85decode("<~@:E^~>", { adobe: true })))
        AhkTest.AssertEqual("y", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.Bytes("    "), { foldspaces: true })))
        AhkTest.AssertEqual("    ", StdlibBase64Test.BufferText(stdlib.base64.a85decode("y", { foldspaces: true })))
        AhkTest.AssertEqual("z", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.ByteValues([0, 0, 0, 0]))))
        AhkTest.AssertEqual("00000000", StdlibBase64Test.BufferHex(stdlib.base64.a85decode("z")))
        AhkTest.AssertEqual("@:E^H", StdlibBase64Test.BufferText(stdlib.base64.a85encode(StdlibBase64Test.Bytes("abc"), { pad: true })))
        AhkTest.AssertEqual("61626300", StdlibBase64Test.BufferHex(stdlib.base64.a85decode("@:E^H")))
        AhkTest.AssertEqual("abc", StdlibBase64Test.BufferText(stdlib.base64.a85decode("@:`nE^")))
        AhkTest.RaisesMatch(TypeError, "^argument should be a bytes-like object or ASCII string, not 'int'$", (*) => stdlib.base64.a85decode(1))
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

    static RepeatByte(text, count)
    {
        repeated := ""
        loop count
            repeated .= text
        return StdlibBase64Test.Bytes(repeated)
    }

    static BufferHex(bytes)
    {
        output := ""
        loop bytes.Size
            output .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return output
    }
}

AhkTest.Collect(StdlibBase64Test)

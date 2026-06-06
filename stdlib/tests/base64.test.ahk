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

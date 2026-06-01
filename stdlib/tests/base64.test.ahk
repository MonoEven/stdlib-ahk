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
        AhkTest.RaisesMatch(AssertionError, "^b'!'$", (*) => stdlib.base64.b64encode(StdlibBase64Test.Bytes("abc"), StdlibBase64Test.Bytes("!")))
        AhkTest.RaisesMatch(AssertionError, "^b'!'$", (*) => stdlib.base64.b64decode(StdlibBase64Test.Bytes("YWJj"), StdlibBase64Test.Bytes("!")))
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

AhkTest.Collect(StdlibBase64Test)

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\quopri>

class StdlibQuopriTest
{
    static TestCoveredEncodeDecodeMatchObservedLocal310Surface()
    {
        AhkTest.AssertEqual("abc", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("abc"))))
        AhkTest.AssertEqual("", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes(""))))
        AhkTest.AssertEqual("a=20", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a "))))
        AhkTest.AssertEqual("a=09b", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a`t" "b"), stdlib.True)))
        AhkTest.AssertEqual("a_b", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a b"), stdlib.False, stdlib.True)))
        AhkTest.AssertEqual("a=20b", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a b"), stdlib.True, stdlib.True)))
        AhkTest.AssertEqual("a=5Fb", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a_b"), stdlib.False, stdlib.True)))
        AhkTest.AssertEqual("=00=09`n`r=1F=3D~=FF", StdlibQuopriTest.BufferText(stdlib.quopri.encodestring(StdlibQuopriTest.ByteValues([0, 9, 10, 13, 31, 61, 126, 255]))))

        AhkTest.AssertEqual("abc=", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("abc=3D"))))
        AhkTest.AssertEqual("abc", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring("abc")))
        AhkTest.AssertEqual("a b=", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("a_b=3D"), stdlib.True)))
        AhkTest.AssertEqual("abcd", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("ab=`ncd"))))
        AhkTest.AssertEqual("=XZ", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("=XZ"))))
        AhkTest.AssertEqual("abc", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("abc="))))
        AhkTest.AssertEqual("=", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("=="))))
        AhkTest.AssertEqual("", StdlibQuopriTest.BufferText(stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("=`r`n"))))
    }

    static TestObservedQuopriErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^encodestring\(\) missing 1 required positional argument: 's'$", (*) => stdlib.quopri.encodestring())
        AhkTest.RaisesMatch(TypeError, "^encodestring\(\) takes from 1 to 3 positional arguments but 4 were given$", (*) => stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a"), stdlib.False, stdlib.False, stdlib.False))
        AhkTest.RaisesMatch(TypeError, "^a bytes-like object is required, not 'str'$", (*) => stdlib.quopri.encodestring("abc"))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a"), "x"))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.quopri.encodestring(StdlibQuopriTest.Bytes("a"), stdlib.False, "x"))

        AhkTest.RaisesMatch(TypeError, "^decodestring\(\) missing 1 required positional argument: 's'$", (*) => stdlib.quopri.decodestring())
        AhkTest.RaisesMatch(TypeError, "^decodestring\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("a"), stdlib.False, stdlib.False))
        AhkTest.RaisesMatch(TypeError, "^argument should be bytes, buffer or ASCII string, not 'int'$", (*) => stdlib.quopri.decodestring(1))
        AhkTest.RaisesMatch(ValueError, "^string argument should contain only ASCII characters$", (*) => stdlib.quopri.decodestring(Chr(233)))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.quopri.decodestring(StdlibQuopriTest.Bytes("a"), "x"))
    }

    static Bytes(text)
    {
        size := StrPut(text, "UTF-8") - 1
        bytes := Buffer(size, 0)
        if size > 0
            StrPut(text, bytes, "UTF-8")
        return bytes
    }

    static ByteValues(values)
    {
        bytes := Buffer(values.Length, 0)
        loop values.Length
            NumPut("UChar", values[A_Index], bytes, A_Index - 1)
        return bytes
    }

    static BufferText(bytes)
    {
        return bytes.Size > 0 ? StrGet(bytes, bytes.Size, "UTF-8") : ""
    }
}

AhkTest.Collect(StdlibQuopriTest)

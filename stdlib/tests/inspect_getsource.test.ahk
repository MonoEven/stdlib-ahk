#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\inspect>

StdlibInspectGsProbeUniqueFunction(a, b)
{
    return a + b
}

class StdlibInspectGsProbeUniqueClass
{
    static value := 1
}

class StdlibInspectGetSourceTest
{
    static TestGetSourceReturnsFunctionDefinition()
    {
        src := stdlib.inspect.getsource(StdlibInspectGsProbeUniqueFunction)
        AhkTest.AssertEqual("StdlibInspectGsProbeUniqueFunction(a, b)`n{`n    return a + b`n}`n", src)
    }

    static TestGetSourceReturnsClassDefinition()
    {
        src := stdlib.inspect.getsource(StdlibInspectGsProbeUniqueClass)
        AhkTest.AssertEqual("class StdlibInspectGsProbeUniqueClass`n{`n    static value := 1`n}`n", src)
    }

    static TestGetSourceLinesReturnsLinesAndStart()
    {
        result := stdlib.inspect.getsourcelines(StdlibInspectGsProbeUniqueFunction)
        lines := result[1]
        start := result[2]
        AhkTest.AssertEqual(4, lines.Length)
        AhkTest.AssertEqual("StdlibInspectGsProbeUniqueFunction(a, b)`n", lines[1])
        AhkTest.AssertEqual("}`n", lines[4])
        ; start line is where the def appears in this file (>0)
        AhkTest.AssertTrue(start > 0)
    }

    static TestGetSourceFileReturnsPath()
    {
        path := stdlib.inspect.getsourcefile(StdlibInspectGsProbeUniqueFunction)
        AhkTest.AssertTrue(InStr(path, "inspect_getsource.test.ahk") > 0)
        ; getfile returns the same path
        AhkTest.AssertEqual(path, stdlib.inspect.getfile(StdlibInspectGsProbeUniqueFunction))
    }

    static TestUnsupportedTypeRaisesTypeError()
    {
        AhkTest.RaisesMatch(TypeError, "module, class, method, function", (*) => stdlib.inspect.getsource(42))
        AhkTest.RaisesMatch(TypeError, "module, class, method, function", (*) => stdlib.inspect.getsource("text"))
    }

    static TestUnlocatableSourceRaisesOSError()
    {
        ; A closure carries no name -> source cannot be located -> OSError
        closure := (z) => z + 1
        AhkTest.RaisesMatch(OSError, "could not get source code", (*) => stdlib.inspect.getsource(closure))
        ; getsourcefile returns None for an unlocatable object
        AhkTest.AssertSame(stdlib.None, stdlib.inspect.getsourcefile(closure))
    }
}

AhkTest.Collect(StdlibInspectGetSourceTest)

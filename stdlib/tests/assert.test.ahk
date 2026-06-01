#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\assert>

class StdlibAssertTest
{
    static TestAssertUsesStdlibModuleNamespace()
    {
        value := { Name: "kept" }

        AhkTest.AssertSame(value, stdlib.assert.assert(value))
        constructed := stdlib.assert.AssertionError("custom assertion")
        AhkTest.AssertEqual("AssertionError", Type(constructed))
        AhkTest.AssertEqual("custom assertion", constructed.Message)
        err := AhkTest.RaisesMatch(stdlib.assert.AssertionError, "^stdlib assertion failed$", (*) => stdlib.assert.assert(false, "stdlib assertion failed"))
        AhkTest.AssertEqual("stdlib assertion failed", err.Message)
    }
}

AhkTest.Collect(StdlibAssertTest)

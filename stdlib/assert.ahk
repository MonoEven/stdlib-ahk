#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCoreAssert
{
    static AssertionError
    {
        get => AssertionError
    }

    static AssertionError(args*)
    {
        return AssertionError(args*)
    }

    static assert(value, message := "")
    {
        return AhkStdlibAssert(value, message)
    }
}

class AssertionError extends Error
{
    __New(message := "AssertionError", what := -1, extra := "")
    {
        super.__New(message, what, extra)
    }
}

AhkStdlibAssert(value, message := "")
{
    if !value
        throw AssertionError(message != "" ? message : "AssertionError", -1)
    return value
}

stdlib.assert := AhkStdlibCoreAssert

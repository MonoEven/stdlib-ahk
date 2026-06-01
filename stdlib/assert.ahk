#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCoreAssert
{
    static assert(value, message := "")
    {
        return assert(value, message)
    }
}

class AssertionError extends Error
{
    __New(message := "AssertionError", what := -1, extra := "")
    {
        super.__New(message, what, extra)
    }
}

assert(value, message := "")
{
    if !value
        throw AssertionError(message != "" ? message : "AssertionError", -1)
    return value
}

stdlib.assert := AhkStdlibCoreAssert

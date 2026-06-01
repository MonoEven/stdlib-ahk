#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibAsyncio
{
    class CancelledError extends Error
    {
    }

    class InvalidStateError extends Error
    {
    }

    static Future(args*)
    {
        return AhkStdlibAsyncioFuture(args*)
    }

    static isfuture(args*)
    {
        if args.Length < 1
            throw TypeError("isfuture() missing 1 required positional argument: 'obj'", -1)
        if args.Length > 1
            throw TypeError("isfuture() takes 1 positional argument but " args.Length " were given", -1)
        return args[1] is AhkStdlibAsyncioFuture
    }

    static new_event_loop()
    {
        return AhkStdlibAsyncioEventLoop()
    }
}

class AhkStdlibAsyncioEventLoop
{
    __New()
    {
        this.AhkStdlibDebug := false
    }

    get_debug()
    {
        return this.AhkStdlibDebug
    }
}

class AhkStdlibAsyncioFuture
{
    __New(args*)
    {
        this.AhkStdlibState := "pending"
        this.AhkStdlibResult := stdlib.None
        this.AhkStdlibException := stdlib.None
        this.AhkStdlibLoop := stdlib.None

        if args.Length > 0 && !AhkStdlibAsyncioIsPlainKeywordObject(args[1])
            throw TypeError("Future() takes no positional arguments", -1)
        if args.Length > 1
            throw TypeError("Future() takes at most 1 keyword argument (" args.Length " given)", -1)
        if args.Length = 0
            return

        options := args[1]
        keywordCount := 0
        invalidKey := unset
        hasLoop := false
        for key, value in options.OwnProps() {
            keywordCount += 1
            if key = "loop" {
                hasLoop := true
                this.AhkStdlibLoop := value
                continue
            }
            if !IsSet(invalidKey)
                invalidKey := key
        }
        if keywordCount > 1
            throw TypeError("Future() takes at most 1 keyword argument (" keywordCount " given)", -1)
        if IsSet(invalidKey)
            throw TypeError("'" invalidKey "' is an invalid keyword argument for Future()", -1)
        if hasLoop && !AhkStdlibIsNone(this.AhkStdlibLoop) {
            if !HasMethod(this.AhkStdlibLoop, "get_debug")
                throw stdlib.AttributeError("'" AhkStdlibPythonTypeName(this.AhkStdlibLoop) "' object has no attribute 'get_debug'", -1)
            this.AhkStdlibLoop.get_debug()
        }
    }

    done()
    {
        return this.AhkStdlibState != "pending"
    }

    cancelled()
    {
        return this.AhkStdlibState = "cancelled"
    }

    cancel()
    {
        if this.done()
            return false
        this.AhkStdlibState := "cancelled"
        return true
    }

    result()
    {
        if this.AhkStdlibState = "pending"
            throw AhkStdlibAsyncio.InvalidStateError("Result is not set.", -1)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibAsyncio.CancelledError("", -1)
        if this.AhkStdlibState = "exception"
            throw this.AhkStdlibException
        return this.AhkStdlibResult
    }

    exception()
    {
        if this.AhkStdlibState = "pending"
            throw AhkStdlibAsyncio.InvalidStateError("Exception is not set.", -1)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibAsyncio.CancelledError("", -1)
        if this.AhkStdlibState = "exception"
            return this.AhkStdlibException
        return stdlib.None
    }

    set_result(value := unset)
    {
        if !IsSet(value)
            throw TypeError("Future.set_result() takes exactly one argument (0 given)", -1)
        if this.done()
            throw AhkStdlibAsyncio.InvalidStateError("invalid state", -1)
        this.AhkStdlibState := "result"
        this.AhkStdlibResult := value
        this.AhkStdlibException := stdlib.None
        return stdlib.None
    }

    set_exception(value := unset)
    {
        if !IsSet(value)
            throw TypeError("Future.set_exception() takes exactly one argument (0 given)", -1)
        if this.done()
            throw AhkStdlibAsyncio.InvalidStateError("invalid state", -1)
        exception := AhkStdlibAsyncioNormalizeException(value)
        this.AhkStdlibState := "exception"
        this.AhkStdlibException := exception
        this.AhkStdlibResult := stdlib.None
        return stdlib.None
    }

    __Repr()
    {
        switch this.AhkStdlibState {
            case "pending":
                return "<Future pending>"
            case "cancelled":
                return "<Future cancelled>"
            case "result":
                return "<Future finished result=" AhkStdlibAsyncioRepr(this.AhkStdlibResult) ">"
            case "exception":
                return "<Future finished exception=" AhkStdlibAsyncioExceptionRepr(this.AhkStdlibException) ">"
            default:
                return "<Future pending>"
        }
    }
}

stdlib.asyncio := AhkStdlibAsyncio

AhkStdlibAsyncioIsPlainKeywordObject(value)
{
    return Type(value) = "Object"
}

AhkStdlibAsyncioNormalizeException(value)
{
    if value is Error
        return value
    if IsObject(value) && HasMethod(value, "Call") {
        try {
            created := value()
        } catch {
            throw TypeError("invalid exception object", -1)
        }
        if created is Error
            return created
    }
    throw TypeError("invalid exception object", -1)
}

AhkStdlibAsyncioRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is Integer || value is Float
        return String(value)
    if value is String
        return "'" StrReplace(StrReplace(value, "\", "\\"), "'", "\'") "'"
    if HasMethod(value, "__Repr")
        return value.__Repr()
    return "<" Type(value) " object>"
}

AhkStdlibAsyncioExceptionRepr(err)
{
    if !(err is Error)
        return AhkStdlibAsyncioRepr(err)
    name := Type(err)
    if err.Message = ""
        return name "()"
    return name "('" StrReplace(StrReplace(err.Message, "\", "\\"), "'", "\'") "')"
}

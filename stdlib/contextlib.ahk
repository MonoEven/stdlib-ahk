#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibContextlib
{
    static nullcontext(args*)
    {
        if args.Length > 1
            throw TypeError("nullcontext.__init__() takes from 1 to 2 positional arguments but " (args.Length + 1) " were given", -1)
        enterResult := args.Length = 1 ? args[1] : stdlib.None
        return AhkStdlibContextlibNullcontext(enterResult)
    }

    static suppress(args*)
    {
        return AhkStdlibContextlibSuppress(args)
    }

    static closing(args*)
    {
        if args.Length = 0
            throw TypeError("closing() missing 1 required positional argument: 'thing'", -1)
        if args.Length > 1
            throw TypeError("closing() takes 1 positional argument but " args.Length " were given", -1)
        return AhkStdlibContextlibClosing(args[1])
    }

    static ContextDecorator(context := unset)
    {
        return AhkStdlibContextlibContextDecorator(IsSet(context) ? context : unset)
    }

    static ExitStack(args*)
    {
        if args.Length > 0
            throw TypeError("ExitStack() takes no arguments", -1)
        return AhkStdlibContextlibExitStack()
    }

    static redirect_stdout(new_target)
    {
        return AhkStdlibContextlibRedirectStream(new_target, "stdout")
    }

    static redirect_stderr(new_target)
    {
        return AhkStdlibContextlibRedirectStream(new_target, "stderr")
    }
}

class AhkStdlibContextlibNullcontext
{
    __New(enterResult)
    {
        this.AhkStdlibEnterResult := enterResult
    }

    __enter()
    {
        return this.AhkStdlibEnterResult
    }

    __exit(excType, exc, tb)
    {
        return false
    }

    __Repr()
    {
        return "<contextlib.nullcontext object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

class AhkStdlibContextlibSuppress
{
    __New(exceptions)
    {
        this.AhkStdlibExceptions := exceptions
    }

    __enter()
    {
        return this
    }

    __exit(excType, exc, tb)
    {
        if AhkStdlibIsNone(excType)
            return false
        for handled in this.AhkStdlibExceptions {
            if !IsObject(handled)
                throw TypeError("issubclass() arg 2 must be a class, a tuple of classes, or a union", -1)
            if exc is handled
                return true
        }
        return false
    }

    __Repr()
    {
        return "<contextlib.suppress object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

class AhkStdlibContextlibClosing
{
    __New(thing)
    {
        this.AhkStdlibThing := thing
    }

    __enter()
    {
        return this.AhkStdlibThing
    }

    __exit(excType, exc, tb)
    {
        if !HasMethod(this.AhkStdlibThing, "close")
            throw AttributeError("'" AhkStdlibPythonTypeName(this.AhkStdlibThing) "' object has no attribute 'close'", -1)
        this.AhkStdlibThing.close()
        return false
    }

    __Repr()
    {
        return "<contextlib.closing object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

class AhkStdlibContextlibContextDecorator
{
    __New(context := unset)
    {
        this.AhkStdlibContext := IsSet(context) ? context : this
    }

    Call(func)
    {
        if !IsObject(func) || !HasMethod(func, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(func) "' object is not callable", -1)
        return AhkStdlibContextlibDecoratedCallable(this.AhkStdlibContext, func)
    }

    __enter()
    {
        return this
    }

    __exit(excType, exc, tb)
    {
        return false
    }

    __Repr()
    {
        return "<contextlib.ContextDecorator object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

class AhkStdlibContextlibDecoratedCallable
{
    __New(context, func)
    {
        this.AhkStdlibContext := context
        this.AhkStdlibFunc := func
    }

    Call(args*)
    {
        context := this.AhkStdlibContext
        context.__enter()
        try {
            result := this.AhkStdlibFunc.Call(args*)
        } catch as err {
            if context.__exit(AhkStdlibContextlibExceptionType(err), err, stdlib.None)
                return stdlib.None
            throw err
        }
        context.__exit(stdlib.None, stdlib.None, stdlib.None)
        return result
    }
}

class AhkStdlibContextlibExitStack
{
    __New()
    {
        this.AhkStdlibExitCallbacks := []
    }

    __enter()
    {
        return this
    }

    __exit(excType, exc, tb)
    {
        suppressed := false
        while this.AhkStdlibExitCallbacks.Length {
            callback := this.AhkStdlibExitCallbacks.Pop()
            if callback.__exit(excType, exc, tb) {
                suppressed := true
                excType := stdlib.None
                exc := stdlib.None
                tb := stdlib.None
            }
        }
        return suppressed
    }

    enter_context(cm)
    {
        result := cm.__enter()
        this.push(cm)
        return result
    }

    push(exit)
    {
        if !HasMethod(exit, "__exit")
            throw TypeError("'" AhkStdlibPythonTypeName(exit) "' object does not support the context manager protocol", -1)
        this.AhkStdlibExitCallbacks.Push(AhkStdlibContextlibExitCallback(exit))
        return exit
    }

    callback(func, args*)
    {
        if !IsObject(func) || !HasMethod(func, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(func) "' object is not callable", -1)
        this.AhkStdlibExitCallbacks.Push(AhkStdlibContextlibPlainCallback(func, args))
        return func
    }

    close()
    {
        return this.__exit(stdlib.None, stdlib.None, stdlib.None)
    }

    __Repr()
    {
        return "<contextlib.ExitStack object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

class AhkStdlibContextlibExitCallback
{
    __New(context)
    {
        this.AhkStdlibContext := context
    }

    __exit(excType, exc, tb)
    {
        return this.AhkStdlibContext.__exit(excType, exc, tb)
    }
}

class AhkStdlibContextlibPlainCallback
{
    __New(func, args)
    {
        this.AhkStdlibFunc := func
        this.AhkStdlibArgs := args
    }

    __exit(excType, exc, tb)
    {
        this.AhkStdlibFunc.Call(this.AhkStdlibArgs*)
        return false
    }
}

class AhkStdlibContextlibRedirectStream
{
    __New(newTarget, streamName)
    {
        this.AhkStdlibNewTarget := newTarget
        this.AhkStdlibStreamName := streamName
    }

    __enter()
    {
        return this.AhkStdlibNewTarget
    }

    __exit(excType, exc, tb)
    {
        return false
    }

    write(text)
    {
        if !HasMethod(this.AhkStdlibNewTarget, "write")
            throw AttributeError("'" AhkStdlibPythonTypeName(this.AhkStdlibNewTarget) "' object has no attribute 'write'", -1)
        return this.AhkStdlibNewTarget.write(text)
    }

    __Repr()
    {
        return "<contextlib.redirect_" this.AhkStdlibStreamName " object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

stdlib.contextlib := AhkStdlibContextlib

AhkStdlibContextlibHexAddress(value)
{
    return Format("{:016X}", ObjPtr(value))
}

AhkStdlibContextlibExceptionType(err)
{
    typeName := Type(err)
    switch typeName {
        case "ValueError":
            return ValueError
        case "KeyError":
            return KeyError
        case "TypeError":
            return TypeError
        case "AttributeError":
            return stdlib.AttributeError
        case "RuntimeError":
            return RuntimeError
        default:
            return typeName
    }
}

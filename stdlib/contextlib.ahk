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
}

class AhkStdlibContextlibNullcontext
{
    __New(enterResult)
    {
        this.AhkStdlibEnterResult := enterResult
    }

    __enter__()
    {
        return this.AhkStdlibEnterResult
    }

    __exit__(excType, exc, tb)
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

    __enter__()
    {
        return this
    }

    __exit__(excType, exc, tb)
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

    __enter__()
    {
        return this.AhkStdlibThing
    }

    __exit__(excType, exc, tb)
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

stdlib.contextlib := AhkStdlibContextlib

AhkStdlibContextlibHexAddress(value)
{
    return Format("{:016X}", ObjPtr(value))
}

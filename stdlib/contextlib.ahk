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

    ; contextmanager(genfunc) — CPython decorates a *generator function* with this
    ; and `with cm():` drives the generator: __enter__ advances to the single
    ; yield, __exit__ resumes it (or throws an exception in). AHK has no `yield`,
    ; but — exactly as collections.abc.Generator recognizes a hand-written
    ; generator-protocol object — this DRIVES one: genfunc returns an object with
    ; __next__()/throw(exc)/close() that yields exactly once. The produced context
    ; manager plugs into ExitStack/enter_context and the __enter/__exit protocol
    ; like every other CM here. (Driving the protocol needs no language primitive;
    ; only *creating* a generator from `yield` does — which is why this is
    ; feasible while async-generator-based asynccontextmanager is not.)
    static contextmanager(genfunc)
    {
        if !IsObject(genfunc) || !HasMethod(genfunc, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(genfunc) "' object is not callable", -1)
        return AhkStdlibContextlibContextManagerFactory(genfunc)
    }

    ; chdir(path) (3.11+, implemented ahead like itertools.batched) — a context
    ; manager that changes the working directory on enter and restores the prior
    ; one on exit. CPython's is a reentrant stack; this one captures the cwd at
    ; enter and restores it at exit (correct for nested use too).
    static chdir(path)
    {
        return AhkStdlibContextlibChdir(path)
    }

    ; asynccontextmanager(genfunc) — the async analog of contextmanager. genfunc
    ; returns a hand-written async generator object: __anext__()/athrow(exc) return
    ; single-step awaitables (driven by the asyncio loop / stdlib.await). The
    ; produced async CM's __aenter__/__aexit__ return awaitables, exactly the
    ; protocol AsyncExitStack.enter_async_context consumes. (Same accommodation as
    ; the sync version: an explicit generator-protocol object stands in for `async
    ; def ... yield`, which AHK lacks; driving the protocol needs no new primitive.)
    static asynccontextmanager(genfunc)
    {
        if !IsObject(genfunc) || !HasMethod(genfunc, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(genfunc) "' object is not callable", -1)
        return AhkStdlibContextlibAsyncContextManagerFactory(genfunc)
    }

    static AsyncExitStack(args*)
    {
        if args.Length > 0
            throw TypeError("AsyncExitStack() takes no arguments", -1)
        return AhkStdlibContextlibAsyncExitStack()
    }
}

class AhkStdlibContextlibChdir
{
    __New(path)
    {
        this.AhkStdlibTarget := AhkStdlibContextlibPathString(path)
        this.AhkStdlibSaved := []
    }

    __enter()
    {
        this.AhkStdlibSaved.Push(A_WorkingDir)
        try {
            SetWorkingDir(this.AhkStdlibTarget)
        } catch as err {
            this.AhkStdlibSaved.Pop()
            throw OSError("No such file or directory: '" this.AhkStdlibTarget "'", -1)
        }
        return stdlib.None
    }

    __exit(excType, exc, tb)
    {
        if this.AhkStdlibSaved.Length
            SetWorkingDir(this.AhkStdlibSaved.Pop())
        return false
    }

    __Repr()
    {
        return "<contextlib.chdir object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

; Returned by contextmanager(genfunc): a callable factory. Calling it with args
; produces a fresh generator (genfunc(args*)) wrapped in a driver CM, mirroring
; CPython's helper(*args, **kwds) -> _GeneratorContextManager(func, args, kwds).
class AhkStdlibContextlibContextManagerFactory
{
    __New(genfunc)
    {
        this.AhkStdlibGenFunc := genfunc
    }

    Call(args*)
    {
        generator := this.AhkStdlibGenFunc.Call(args*)
        if !IsObject(generator) || !HasMethod(generator, "__next__")
            throw TypeError("@contextmanager function must return a generator-protocol object (with __next__)", -1)
        return AhkStdlibContextlibGeneratorCM(generator)
    }
}

; Faithful port of CPython's _GeneratorContextManager.__enter__/__exit__.
class AhkStdlibContextlibGeneratorCM
{
    __New(generator)
    {
        this.AhkStdlibGen := generator
    }

    __enter()
    {
        ; Advance to the first yield; a generator that never yields is an error.
        try {
            return this.AhkStdlibGen.__next__()
        } catch as err {
            if err is StopIteration
                throw RuntimeError("generator didn't yield", -1)
            throw err
        }
    }

    __exit(excType, exc, tb)
    {
        if AhkStdlibIsNone(excType) {
            ; No exception in the body: resume; the generator must now stop.
            try {
                this.AhkStdlibGen.__next__()
            } catch as err {
                if err is StopIteration
                    return false
                throw err
            }
            throw RuntimeError("generator didn't stop", -1)
        }

        ; Exception in the body: throw it into the generator at the yield point.
        try {
            this.AhkStdlibGen.throw(exc)
        } catch as thrown {
            ; Generator caught it and ran to completion -> suppress (StopIteration).
            if thrown is StopIteration
                return true
            ; Generator re-raised the SAME exception -> do not suppress.
            if thrown == exc
                return false
            ; A different exception -> propagate it.
            throw thrown
        }
        ; Generator yielded again instead of stopping.
        throw RuntimeError("generator didn't stop after throw()", -1)
    }

    __Repr()
    {
        return "<contextlib._GeneratorContextManager object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

; A single-step awaitable: when the asyncio loop steps it, it runs `thunk` once
; and the result becomes the awaited value (a thrown StopIteration signals
; completion, like any coroutine). This is the bridge that lets __aenter__/
; __aexit__ be awaited via stdlib.await / the event loop.
class AhkStdlibContextlibAsyncStep
{
    __New(thunk)
    {
        this.AhkStdlibThunk := thunk
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        return this.AhkStdlibThunk.Call()
    }
}

; Returned by asynccontextmanager(genfunc): a callable factory producing an
; async CM wrapping a fresh async generator object (genfunc(args*)).
class AhkStdlibContextlibAsyncContextManagerFactory
{
    __New(genfunc)
    {
        this.AhkStdlibGenFunc := genfunc
    }

    Call(args*)
    {
        generator := this.AhkStdlibGenFunc.Call(args*)
        if !IsObject(generator) || !HasMethod(generator, "__anext__")
            throw TypeError("@asynccontextmanager function must return an async-generator object (with __anext__)", -1)
        return AhkStdlibContextlibAsyncGeneratorCM(generator)
    }
}

; Async analog of _GeneratorContextManager. __aenter__/__aexit__ return awaitables
; (driven by the loop). The faithful semantics mirror the sync version: enter
; advances to the single ayield (RuntimeError if none); exit resumes (must stop)
; or throws the exception in (StopIteration -> suppress, same exception ->
; propagate, didn't-stop -> RuntimeError).
class AhkStdlibContextlibAsyncGeneratorCM
{
    __New(generator)
    {
        this.AhkStdlibGen := generator
    }

    __aenter__()
    {
        return AhkStdlibContextlibAsyncStep(ObjBindMethod(this, "AhkStdlibDoEnter"))
    }

    __aexit__(excType, exc, tb)
    {
        bound := ObjBindMethod(this, "AhkStdlibDoExit", excType, exc, tb)
        return AhkStdlibContextlibAsyncStep(bound)
    }

    AhkStdlibDoEnter()
    {
        ; Drive the async generator's first awaitable to the ayield value. The
        ; common case has synchronous setup, so __anext__'s awaitable resolves in
        ; one step; we drive it via the running loop's synchronous advance.
        try {
            return AhkStdlibContextlibDriveAwaitable(this.AhkStdlibGen.__anext__())
        } catch as err {
            if err is StopIteration
                throw RuntimeError("generator didn't yield", -1)
            throw err
        }
    }

    AhkStdlibDoExit(excType, exc, tb)
    {
        if AhkStdlibIsNone(excType) {
            try {
                AhkStdlibContextlibDriveAwaitable(this.AhkStdlibGen.__anext__())
            } catch as err {
                if err is StopIteration
                    return false
                throw err
            }
            throw RuntimeError("generator didn't stop", -1)
        }

        try {
            AhkStdlibContextlibDriveAwaitable(this.AhkStdlibGen.athrow(exc))
        } catch as thrown {
            if thrown is StopIteration
                return true
            if thrown == exc
                return false
            throw thrown
        }
        throw RuntimeError("generator didn't stop after athrow()", -1)
    }

    __Repr()
    {
        return "<contextlib._AsyncGeneratorContextManager object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

; Drive a single-step awaitable (the async generator's __anext__/athrow result) to
; its value without a nested event loop: step it once. A non-awaitable result is
; returned as-is; StopIteration propagates to signal generator completion.
AhkStdlibContextlibDriveAwaitable(awaitable)
{
    if IsObject(awaitable) && HasMethod(awaitable, "AhkStdlibAsyncioStep")
        return awaitable.AhkStdlibAsyncioStep(stdlib.None)
    return awaitable
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

; AsyncExitStack (3.10) — async analog of ExitStack. enter_async_context awaits a
; CM's __aenter__ (via stdlib.await) and registers its __aexit__; aclose() unwinds
; the stack, awaiting each async __aexit__ and calling sync callbacks. Async exits
; return awaitables driven through the loop, so the stack is fully exercisable
; through asyncio.run / stdlib.await together with asynccontextmanager.
class AhkStdlibContextlibAsyncExitStack
{
    __New()
    {
        this.AhkStdlibExitCallbacks := []
    }

    __aenter__()
    {
        return AhkStdlibContextlibAsyncStep(() => this)
    }

    __aexit__(excType, exc, tb)
    {
        return AhkStdlibContextlibAsyncStep(ObjBindMethod(this, "AhkStdlibDoAclose", excType, exc, tb))
    }

    enter_async_context(cm)
    {
        if !HasMethod(cm, "__aenter__") || !HasMethod(cm, "__aexit__")
            throw TypeError("'" AhkStdlibPythonTypeName(cm) "' object does not support the asynchronous context manager protocol", -1)
        ; Awaiting __aenter__ yields the entered value; return an awaitable so the
        ; caller awaits it like CPython's `await stack.enter_async_context(cm)`.
        return AhkStdlibContextlibAsyncStep(() => this.AhkStdlibEnterAndRegister(cm))
    }

    AhkStdlibEnterAndRegister(cm)
    {
        result := AhkStdlibContextlibDriveAwaitable(cm.__aenter__())
        this.AhkStdlibExitCallbacks.Push(AhkStdlibContextlibAsyncExitCallback(cm))
        return result
    }

    push_async_exit(cm)
    {
        if !HasMethod(cm, "__aexit__")
            throw TypeError("'" AhkStdlibPythonTypeName(cm) "' object does not support the asynchronous context manager protocol", -1)
        this.AhkStdlibExitCallbacks.Push(AhkStdlibContextlibAsyncExitCallback(cm))
        return cm
    }

    push_async_callback(func, args*)
    {
        if !IsObject(func) || !HasMethod(func, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(func) "' object is not callable", -1)
        this.AhkStdlibExitCallbacks.Push(AhkStdlibContextlibAsyncPlainCallback(func, args))
        return func
    }

    ; Synchronous registrations are also allowed (CPython AsyncExitStack inherits
    ; enter_context/push/callback from ExitStack).
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

    aclose()
    {
        return AhkStdlibContextlibAsyncStep(ObjBindMethod(this, "AhkStdlibDoAclose", stdlib.None, stdlib.None, stdlib.None))
    }

    AhkStdlibDoAclose(excType, exc, tb)
    {
        suppressed := false
        while this.AhkStdlibExitCallbacks.Length {
            callback := this.AhkStdlibExitCallbacks.Pop()
            if HasProp(callback, "AhkStdlibAsyncAware") && callback.AhkStdlibAsyncAware
                handled := AhkStdlibContextlibDriveAwaitable(callback.AhkStdlibAsyncExit(excType, exc, tb))
            else
                handled := callback.__exit(excType, exc, tb)
            if handled {
                suppressed := true
                excType := stdlib.None
                exc := stdlib.None
                tb := stdlib.None
            }
        }
        return suppressed
    }

    __Repr()
    {
        return "<contextlib.AsyncExitStack object at 0x" AhkStdlibContextlibHexAddress(this) ">"
    }
}

; Wraps an async CM so the stack can await its __aexit__ during unwind.
class AhkStdlibContextlibAsyncExitCallback
{
    __New(cm)
    {
        this.AhkStdlibCM := cm
        this.AhkStdlibAsyncAware := true
    }

    AhkStdlibAsyncExit(excType, exc, tb)
    {
        return this.AhkStdlibCM.__aexit__(excType, exc, tb)
    }
}

; Wraps a plain async callback (run during unwind; no awaiting needed here since
; the callback body is synchronous in this model).
class AhkStdlibContextlibAsyncPlainCallback
{
    __New(func, args)
    {
        this.AhkStdlibFunc := func
        this.AhkStdlibArgs := args
        this.AhkStdlibAsyncAware := true
    }

    AhkStdlibAsyncExit(excType, exc, tb)
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

; Coerce a path argument (string or os.PathLike-ish object with a Path/__fspath__)
; to a plain string for SetWorkingDir.
AhkStdlibContextlibPathString(path)
{
    if !IsObject(path)
        return path ""
    if HasProp(path, "Path")
        return path.Path
    if HasMethod(path, "__fspath__")
        return path.__fspath__()
    return String(path)
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

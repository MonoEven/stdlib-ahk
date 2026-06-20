#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\contextlib>
#Include <stdlib\io>
#Include <stdlib\asyncio>

class StdlibContextlibTestCloser
{
    __New()
    {
        this.closed := false
    }

    close()
    {
        this.closed := true
    }
}

class StdlibContextlibTestStackContext
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("enter")
        return "entered"
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

class StdlibContextlibTestDecoratorCore
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("decorator-enter")
        return this
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["decorator-exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

; A hand-written single-yield generator object (no AHK `yield`): a small state
; machine implementing __next__/throw/close. setup runs before the yield,
; teardown after. CPython would write this as a @contextmanager generator
; function; here the same protocol is expressed explicitly and driven identically.
class StdlibContextlibTestGen
{
    __New(events, value, catchThrow := false)
    {
        this.events := events
        this.value := value
        this.catchThrow := catchThrow
        this.state := "start"
    }

    __next__()
    {
        if this.state = "start" {
            this.events.Push("setup")
            this.state := "yielded"
            return this.value
        }
        ; Resume after the (single) yield: run teardown then stop.
        if this.state = "yielded" {
            this.events.Push("teardown")
            this.state := "done"
            throw StopIteration("", -1)
        }
        throw StopIteration("", -1)
    }

    throw(exc)
    {
        ; Exception thrown in at the yield point.
        if this.state = "yielded" {
            this.state := "done"
            if this.catchThrow {
                this.events.Push("caught")
                this.events.Push("teardown")
                throw StopIteration("", -1)   ; caught + ran to completion
            }
            this.events.Push("teardown")
            throw exc                          ; re-raise the same exception
        }
        throw exc
    }

    close()
    {
    }
}

; A generator that never yields (state machine stops immediately).
class StdlibContextlibTestEmptyGen
{
    __next__()
    {
        throw StopIteration("", -1)
    }
    throw(exc)
    {
        throw exc
    }
    close()
    {
    }
}

; A hand-written async generator object: __anext__/athrow return single-step
; awaitables (the asyncio model's awaitable shape). One ayield, sync setup/teardown.
class StdlibContextlibTestAsyncGen
{
    __New(events, value, catchThrow := false)
    {
        this.events := events
        this.value := value
        this.catchThrow := catchThrow
        this.state := "start"
    }

    __anext__()
    {
        return StdlibContextlibTestAsyncStep(ObjBindMethod(this, "AhkAdvance"))
    }

    athrow(exc)
    {
        return StdlibContextlibTestAsyncStep(ObjBindMethod(this, "AhkThrowIn", exc))
    }

    AhkAdvance()
    {
        if this.state = "start" {
            this.events.Push("setup")
            this.state := "yielded"
            return this.value
        }
        this.events.Push("teardown")
        this.state := "done"
        throw StopIteration("", -1)
    }

    AhkThrowIn(exc)
    {
        this.state := "done"
        if this.catchThrow {
            this.events.Push("caught")
            this.events.Push("teardown")
            throw StopIteration("", -1)
        }
        this.events.Push("teardown")
        throw exc
    }
}

class StdlibContextlibTestAsyncStep
{
    __New(thunk)
    {
        this.thunk := thunk
        this.idx := 0
    }
    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.idx != 0
            return value
        this.idx += 1
        return this.thunk.Call()
    }
}

class StdlibContextlibTest
{
    static TestCoveredNullcontextSuppressAndClosingMatchObservedLocal310()
    {
        nullctx := stdlib.contextlib.nullcontext("seed")
        closer := StdlibContextlibTestCloser()
        closingCtx := stdlib.contextlib.closing(closer)

        AhkTest.AssertEqual("seed", nullctx.__enter())
        AhkTest.AssertEqual("<contextlib.nullcontext object at 0x" . AhkStdlibContextlibHexAddress(nullctx) . ">", nullctx.__Repr())

        AhkTest.AssertFalse(closer.closed)
        AhkTest.AssertSame(closer, closingCtx.__enter())
        AhkTest.AssertEqual("<contextlib.closing object at 0x" . AhkStdlibContextlibHexAddress(closingCtx) . ">", closingCtx.__Repr())
        AhkTest.AssertTrue(!closingCtx.__exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertTrue(closer.closed)

        suppressCtx := stdlib.contextlib.suppress(ValueError, KeyError)
        AhkTest.AssertEqual("<contextlib.suppress object at 0x" . AhkStdlibContextlibHexAddress(suppressCtx) . ">", suppressCtx.__Repr())
        AhkTest.AssertTrue(suppressCtx.__exit(ValueError, ValueError("x", -1), stdlib.None))
        AhkTest.AssertFalse(suppressCtx.__exit(TypeError, TypeError("y", -1), stdlib.None))

        emptySuppress := stdlib.contextlib.suppress()
        AhkTest.AssertFalse(emptySuppress.__exit(ValueError, ValueError("x", -1), stdlib.None))
    }

    static TestObservedContextlibErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^nullcontext\.__init__\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.contextlib.nullcontext(1, 2))
        AhkTest.RaisesMatch(TypeError, "^issubclass\(\) arg 2 must be a class, a tuple of classes, or a union$", (*) => stdlib.contextlib.suppress(1).__exit(ValueError, ValueError("z", -1), stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^closing\(\) missing 1 required positional argument: 'thing'$", (*) => stdlib.contextlib.closing())
        AhkTest.RaisesMatch(TypeError, "^nullcontext\.__init__\(\) takes from 1 to 2 positional arguments but 4 were given$", (*) => stdlib.contextlib.nullcontext(1, 2, 3))
    }

    static TestStackDecoratorAndRedirectCorePublicSurface()
    {
        events := []
        stdoutTarget := stdlib.io.StringIO()
        stderrTarget := stdlib.io.StringIO()

        stdoutRedirect := stdlib.contextlib.redirect_stdout(stdoutTarget)
        stderrRedirect := stdlib.contextlib.redirect_stderr(stderrTarget)
        AhkTest.AssertSame(stdoutTarget, stdoutRedirect.__enter())
        stdoutTarget.write("out-line`n")
        AhkTest.AssertFalse(stdoutRedirect.__exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertSame(stderrTarget, stderrRedirect.__enter())
        stderrTarget.write("err-line`n")
        AhkTest.AssertFalse(stderrRedirect.__exit(stdlib.None, stdlib.None, stdlib.None))

        stack := stdlib.contextlib.ExitStack()
        AhkTest.AssertSame(stack, stack.__enter())
        stack.callback(StdlibContextlibTestCallback, events, "one")
        stack.callback(StdlibContextlibTestCallback, events, "two")
        entered := stack.enter_context(StdlibContextlibTestStackContext(events))
        events.Push(["stack-body", entered])
        AhkTest.AssertFalse(stack.__exit(stdlib.None, stdlib.None, stdlib.None))

        decorator := stdlib.contextlib.ContextDecorator(StdlibContextlibTestDecoratorCore(events))
        decorated := decorator.Call((value) => StdlibContextlibTestDecoratedCall(events, value))

        AhkTest.AssertEqual("out-line`n", stdoutTarget.getvalue())
        AhkTest.AssertEqual("err-line`n", stderrTarget.getvalue())
        AhkTest.AssertEqual(42, decorated.Call(21))
        AhkTest.AssertEqual([
            "enter",
            ["stack-body", "entered"],
            ["exit", stdlib.None],
            ["callback", "two"],
            ["callback", "one"],
            "decorator-enter",
            ["decorated-call", 21],
            ["decorator-exit", stdlib.None]
        ], events)
    }

    static TestContextManagerDrivesGeneratorObjectLikePython310()
    {
        ; @contextmanager over a hand-written single-yield generator object.
        events := []
        factory := stdlib.contextlib.contextmanager((evts, val) => StdlibContextlibTestGen(evts, val))

        cm := factory(events, 5)
        ; __enter advances to the yield and returns the yielded value.
        yielded := cm.__enter()
        AhkTest.AssertEqual(5, yielded)
        events.Push(["body", yielded])
        ; __exit with no exception resumes the generator, running teardown.
        AhkTest.AssertFalse(cm.__exit(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertEqual(["setup", ["body", 5], "teardown"], events)
    }

    static TestContextManagerSuppressesWhenGeneratorCatchesThrow()
    {
        ; Generator that catches the thrown exception and completes -> suppressed.
        events := []
        factory := stdlib.contextlib.contextmanager((evts) => StdlibContextlibTestGen(evts, 1, true))
        cm := factory(events)
        cm.__enter()
        suppressed := cm.__exit(ValueError, ValueError("boom", -1), stdlib.None)
        AhkTest.AssertTrue(suppressed)
        AhkTest.AssertEqual(["setup", "caught", "teardown"], events)
    }

    static TestContextManagerRepropagatesWhenGeneratorReraises()
    {
        ; Generator that re-raises the same exception -> NOT suppressed.
        events := []
        factory := stdlib.contextlib.contextmanager((evts) => StdlibContextlibTestGen(evts, 1, false))
        cm := factory(events)
        cm.__enter()
        err := ValueError("boom", -1)
        suppressed := cm.__exit(ValueError, err, stdlib.None)
        AhkTest.AssertFalse(suppressed)
        AhkTest.AssertEqual(["setup", "teardown"], events)
    }

    static TestContextManagerRaisesWhenGeneratorDoesNotYield()
    {
        factory := stdlib.contextlib.contextmanager((*) => StdlibContextlibTestEmptyGen())
        cm := factory()
        AhkTest.RaisesMatch(RuntimeError, "^generator didn't yield$", (*) => cm.__enter())
    }

    static TestContextManagerComposesWithExitStack()
    {
        ; A @contextmanager CM plugs into ExitStack.enter_context like any other.
        events := []
        factory := stdlib.contextlib.contextmanager((evts) => StdlibContextlibTestGen(evts, "res"))
        stack := stdlib.contextlib.ExitStack()
        stack.__enter()
        resource := stack.enter_context(factory(events))
        AhkTest.AssertEqual("res", resource)
        events.Push(["body", resource])
        stack.__exit(stdlib.None, stdlib.None, stdlib.None)
        AhkTest.AssertEqual(["setup", ["body", "res"], "teardown"], events)
    }

    static TestContextManagerRejectsNonCallable()
    {
        AhkTest.RaisesMatch(TypeError, "object is not callable", (*) => stdlib.contextlib.contextmanager(5))
    }

    static TestChdirChangesAndRestoresWorkingDirLikePython311()
    {
        original := A_WorkingDir
        tempRoot := EnvGet("TEMP")
        cm := stdlib.contextlib.chdir(tempRoot)
        cm.__enter()
        ; Inside: cwd is the target (compare case-insensitively, trim trailing \).
        AhkTest.AssertEqual(StrLower(RTrim(tempRoot, "\")), StrLower(RTrim(A_WorkingDir, "\")))
        cm.__exit(stdlib.None, stdlib.None, stdlib.None)
        ; Restored afterwards.
        AhkTest.AssertEqual(original, A_WorkingDir)

        ; Restores even when the body raised (exit always runs in the protocol).
        cm2 := stdlib.contextlib.chdir(tempRoot)
        cm2.__enter()
        cm2.__exit(ValueError, ValueError("x", -1), stdlib.None)
        AhkTest.AssertEqual(original, A_WorkingDir)

        ; Missing directory raises on enter.
        AhkTest.RaisesMatch(OSError, "No such file or directory", (*) => stdlib.contextlib.chdir(tempRoot "\does-not-exist-zzz").__enter())
    }

    static TestAsyncContextManagerDrivesAsyncGeneratorObject()
    {
        ; @asynccontextmanager over a hand-written single-ayield async generator.
        events := []
        factory := stdlib.contextlib.asynccontextmanager((evts, v) => StdlibContextlibTestAsyncGen(evts, v))
        cm := factory(events, 7)
        ; __aenter__ returns an awaitable -> driven via stdlib.await -> yielded value.
        yielded := stdlib.await(cm.__aenter__())
        AhkTest.AssertEqual(7, yielded)
        events.Push(["body", yielded])
        ; __aexit__ returns an awaitable; no exception -> teardown, returns false.
        suppressed := stdlib.await(cm.__aexit__(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertFalse(suppressed)
        AhkTest.AssertEqual(["setup", ["body", 7], "teardown"], events)
    }

    static TestAsyncContextManagerSuppressesAndRepropagates()
    {
        ; Caught-and-completed -> suppressed.
        events := []
        f1 := stdlib.contextlib.asynccontextmanager((evts) => StdlibContextlibTestAsyncGen(evts, 1, true))
        cm1 := f1(events)
        stdlib.await(cm1.__aenter__())
        AhkTest.AssertTrue(stdlib.await(cm1.__aexit__(ValueError, ValueError("boom", -1), stdlib.None)))
        AhkTest.AssertEqual(["setup", "caught", "teardown"], events)

        ; Re-raised same exception -> not suppressed.
        events2 := []
        f2 := stdlib.contextlib.asynccontextmanager((evts) => StdlibContextlibTestAsyncGen(evts, 1, false))
        cm2 := f2(events2)
        stdlib.await(cm2.__aenter__())
        err := ValueError("boom", -1)
        AhkTest.AssertFalse(stdlib.await(cm2.__aexit__(ValueError, err, stdlib.None)))
        AhkTest.AssertEqual(["setup", "teardown"], events2)
    }

    static TestAsyncExitStackEntersAndUnwindsAsyncContextManagers()
    {
        events := []
        f := stdlib.contextlib.asynccontextmanager((evts, tag) => StdlibContextlibTestAsyncGen(evts, tag))
        stack := stdlib.contextlib.AsyncExitStack()
        stdlib.await(stack.__aenter__())
        ; enter_async_context returns an awaitable yielding the entered value.
        r1 := stdlib.await(stack.enter_async_context(f(events, "a")))
        r2 := stdlib.await(stack.enter_async_context(f(events, "b")))
        AhkTest.AssertEqual("a", r1)
        AhkTest.AssertEqual("b", r2)
        events.Push(["body", r1, r2])
        ; aclose unwinds in LIFO order (b torn down before a).
        stdlib.await(stack.aclose())
        AhkTest.AssertEqual(["setup", "setup", ["body", "a", "b"], "teardown", "teardown"], events)
    }

    static TestAsyncExitStackPushCallbackAndProtocolErrors()
    {
        events := []
        stack := stdlib.contextlib.AsyncExitStack()
        stack.push_async_callback(StdlibContextlibTestAsyncCallback, events, "done")
        stdlib.await(stack.aclose())
        AhkTest.AssertEqual([["acallback", "done"]], events)

        ; Non-async-CM rejected by enter_async_context.
        AhkTest.RaisesMatch(TypeError, "asynchronous context manager protocol", (*) => stack.enter_async_context({ x: 1 }))
        ; Non-callable factory rejected.
        AhkTest.RaisesMatch(TypeError, "object is not callable", (*) => stdlib.contextlib.asynccontextmanager(5))
    }
}

StdlibContextlibTestCallback(events, label)
{
    events.Push(["callback", label])
}

StdlibContextlibTestDecoratedCall(events, value)
{
    events.Push(["decorated-call", value])
    return value * 2
}

StdlibContextlibTestAsyncCallback(events, label)
{
    events.Push(["acallback", label])
}

AhkTest.Collect(StdlibContextlibTest)

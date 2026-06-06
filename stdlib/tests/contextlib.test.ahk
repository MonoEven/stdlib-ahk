#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\contextlib>
#Include <stdlib\io>

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

    __enter__()
    {
        this.events.Push("enter")
        return "entered"
    }

    __exit__(excType, exc, tb)
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

    __enter__()
    {
        this.events.Push("decorator-enter")
        return this
    }

    __exit__(excType, exc, tb)
    {
        this.events.Push(["decorator-exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

class StdlibContextlibTest
{
    static TestCoveredNullcontextSuppressAndClosingMatchObservedLocal310()
    {
        nullctx := stdlib.contextlib.nullcontext("seed")
        closer := StdlibContextlibTestCloser()
        closingCtx := stdlib.contextlib.closing(closer)

        AhkTest.AssertEqual("seed", nullctx.__enter__())
        AhkTest.AssertEqual("<contextlib.nullcontext object at 0x" . AhkStdlibContextlibHexAddress(nullctx) . ">", nullctx.__Repr())

        AhkTest.AssertFalse(closer.closed)
        AhkTest.AssertSame(closer, closingCtx.__enter__())
        AhkTest.AssertEqual("<contextlib.closing object at 0x" . AhkStdlibContextlibHexAddress(closingCtx) . ">", closingCtx.__Repr())
        AhkTest.AssertTrue(!closingCtx.__exit__(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertTrue(closer.closed)

        suppressCtx := stdlib.contextlib.suppress(ValueError, KeyError)
        AhkTest.AssertEqual("<contextlib.suppress object at 0x" . AhkStdlibContextlibHexAddress(suppressCtx) . ">", suppressCtx.__Repr())
        AhkTest.AssertTrue(suppressCtx.__exit__(ValueError, ValueError("x", -1), stdlib.None))
        AhkTest.AssertFalse(suppressCtx.__exit__(TypeError, TypeError("y", -1), stdlib.None))

        emptySuppress := stdlib.contextlib.suppress()
        AhkTest.AssertFalse(emptySuppress.__exit__(ValueError, ValueError("x", -1), stdlib.None))
    }

    static TestObservedContextlibErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(TypeError, "^nullcontext\.__init__\(\) takes from 1 to 2 positional arguments but 3 were given$", (*) => stdlib.contextlib.nullcontext(1, 2))
        AhkTest.RaisesMatch(TypeError, "^issubclass\(\) arg 2 must be a class, a tuple of classes, or a union$", (*) => stdlib.contextlib.suppress(1).__exit__(ValueError, ValueError("z", -1), stdlib.None))
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
        AhkTest.AssertSame(stdoutTarget, stdoutRedirect.__enter__())
        stdoutTarget.write("out-line`n")
        AhkTest.AssertFalse(stdoutRedirect.__exit__(stdlib.None, stdlib.None, stdlib.None))
        AhkTest.AssertSame(stderrTarget, stderrRedirect.__enter__())
        stderrTarget.write("err-line`n")
        AhkTest.AssertFalse(stderrRedirect.__exit__(stdlib.None, stdlib.None, stdlib.None))

        stack := stdlib.contextlib.ExitStack()
        AhkTest.AssertSame(stack, stack.__enter__())
        stack.callback(StdlibContextlibTestCallback, events, "one")
        stack.callback(StdlibContextlibTestCallback, events, "two")
        entered := stack.enter_context(StdlibContextlibTestStackContext(events))
        events.Push(["stack-body", entered])
        AhkTest.AssertFalse(stack.__exit__(stdlib.None, stdlib.None, stdlib.None))

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

AhkTest.Collect(StdlibContextlibTest)

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\contextlib>

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
}

AhkTest.Collect(StdlibContextlibTest)

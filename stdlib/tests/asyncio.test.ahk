#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\asyncio>

class StdlibAsyncioTest
{
    static TestFutureTracksPendingFinishedCancelledAndPredicateLikeLocal310()
    {
        pending := stdlib.asyncio.Future()
        eventLoopPending := stdlib.asyncio.Future({ loop: stdlib.asyncio.new_event_loop() })
        finished := stdlib.asyncio.Future()
        cancelled := stdlib.asyncio.Future()

        AhkTest.AssertFalse(pending.done())
        AhkTest.AssertFalse(pending.cancelled())
        AhkTest.AssertEqual("<Future pending>", pending.__Repr())
        AhkTest.AssertFalse(eventLoopPending.done())
        AhkTest.AssertEqual("<Future pending>", eventLoopPending.__Repr())
        AhkTest.AssertTrue(stdlib.asyncio.isfuture(pending))
        AhkTest.AssertFalse(stdlib.asyncio.isfuture(1))

        AhkTest.AssertSame(stdlib.None, finished.set_result(42))
        AhkTest.AssertTrue(finished.done())
        AhkTest.AssertFalse(finished.cancelled())
        AhkTest.AssertEqual(42, finished.result())
        AhkTest.AssertSame(stdlib.None, finished.exception())
        AhkTest.AssertEqual("<Future finished result=42>", finished.__Repr())

        AhkTest.AssertTrue(cancelled.cancel())
        AhkTest.AssertTrue(cancelled.done())
        AhkTest.AssertTrue(cancelled.cancelled())
        AhkTest.AssertFalse(cancelled.cancel())
        AhkTest.AssertEqual("<Future cancelled>", cancelled.__Repr())
        AhkTest.Raises(stdlib.asyncio.CancelledError, (*) => cancelled.result())
        AhkTest.Raises(stdlib.asyncio.CancelledError, (*) => cancelled.exception())
    }

    static TestFutureSupportsExceptionStateLikeLocal310()
    {
        future := stdlib.asyncio.Future()
        err := RuntimeError("boom", -1)

        AhkTest.AssertSame(stdlib.None, future.set_exception(err))
        AhkTest.AssertTrue(future.done())
        AhkTest.AssertFalse(future.cancelled())
        AhkTest.RaisesMatch(RuntimeError, "^boom$", (*) => future.result())
        AhkTest.AssertSame(err, future.exception())
        AhkTest.AssertRegex(future.__Repr(), "^<Future finished exception=RuntimeError\('boom'\)>$")
    }

    static TestFutureRejectsObservedInvalidArguments()
    {
        pending := stdlib.asyncio.Future()
        finished := stdlib.asyncio.Future()
        badLoop := stdlib.asyncio.new_event_loop()
        finished.set_result(1)

        AhkTest.RaisesMatch(stdlib.asyncio.InvalidStateError, "^Result is not set\.$", (*) => pending.result())
        AhkTest.RaisesMatch(stdlib.asyncio.InvalidStateError, "^Exception is not set\.$", (*) => pending.exception())
        AhkTest.RaisesMatch(TypeError, "^Future\(\) takes no positional arguments$", (*) => stdlib.asyncio.Future(1))
        AhkTest.RaisesMatch(TypeError, "^'extra' is an invalid keyword argument for Future\(\)$", (*) => stdlib.asyncio.Future({ extra: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Future\(\) takes at most 1 keyword argument \(2 given\)$", (*) => stdlib.asyncio.Future({ loop: badLoop, extra: 1 }))
        AhkTest.RaisesMatch(AttributeError, "^'int' object has no attribute 'get_debug'$", (*) => stdlib.asyncio.Future({ loop: 1 }))
        AhkTest.RaisesMatch(TypeError, "^Future\.set_result\(\) takes exactly one argument \(0 given\)$", (*) => pending.set_result())
        AhkTest.RaisesMatch(TypeError, "^Future\.set_exception\(\) takes exactly one argument \(0 given\)$", (*) => pending.set_exception())
        AhkTest.RaisesMatch(stdlib.asyncio.InvalidStateError, "^invalid state$", (*) => finished.set_result(2))
        AhkTest.RaisesMatch(stdlib.asyncio.InvalidStateError, "^invalid state$", (*) => finished.set_exception(RuntimeError("again", -1)))
        AhkTest.RaisesMatch(TypeError, "^isfuture\(\) missing 1 required positional argument: 'obj'$", (*) => stdlib.asyncio.isfuture())
        AhkTest.RaisesMatch(TypeError, "^isfuture\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.asyncio.isfuture(1, 2))
    }
}

AhkTest.Collect(StdlibAsyncioTest)

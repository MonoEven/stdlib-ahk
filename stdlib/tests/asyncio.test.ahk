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

    static TestFutureGetLoopCancelMessageAndArityMatchLocal310()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        explicit := stdlib.asyncio.Future({ loop: eventLoop })
        implicit := stdlib.asyncio.Future()

        AhkTest.AssertSame(eventLoop, explicit.get_loop())
        AhkTest.AssertTrue(HasMethod(implicit.get_loop(), "get_debug"))
        AhkTest.RaisesMatch(TypeError, "^Future\.get_loop\(\) takes no arguments \(1 given\)$", (*) => explicit.get_loop(1))
        AhkTest.RaisesMatch(TypeError, "^Future\.done\(\) takes no arguments \(1 given\)$", (*) => explicit.done(1))
        AhkTest.RaisesMatch(TypeError, "^Future\.cancelled\(\) takes no arguments \(1 given\)$", (*) => explicit.cancelled(1))
        AhkTest.RaisesMatch(TypeError, "^Future\.result\(\) takes no arguments \(1 given\)$", (*) => explicit.result(1))
        AhkTest.RaisesMatch(TypeError, "^Future\.exception\(\) takes no arguments \(1 given\)$", (*) => explicit.exception(1))

        cancelled := stdlib.asyncio.Future({ loop: eventLoop })
        AhkTest.AssertTrue(cancelled.cancel("payload"))
        AhkTest.AssertTrue(cancelled.done())
        AhkTest.AssertTrue(cancelled.cancelled())
        AhkTest.RaisesMatch(stdlib.asyncio.CancelledError, "^payload$", (*) => cancelled.result())
        AhkTest.RaisesMatch(stdlib.asyncio.CancelledError, "^payload$", (*) => cancelled.exception())
        AhkTest.RaisesMatch(TypeError, "^cancel\(\) takes at most 1 argument \(2 given\)$", (*) => stdlib.asyncio.Future({ loop: eventLoop }).cancel("one", "two"))

        finished := stdlib.asyncio.Future({ loop: eventLoop })
        finished.set_result("done")
        AhkTest.AssertFalse(finished.cancel("ignored"))
        AhkTest.AssertEqual("done", finished.result())
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

    static TestPolicyLoopConstantsAndQueueFunctionSurfaceMatchLocal310()
    {
        AhkTest.AssertEqual("FIRST_COMPLETED", stdlib.asyncio.FIRST_COMPLETED)
        AhkTest.AssertEqual("FIRST_EXCEPTION", stdlib.asyncio.FIRST_EXCEPTION)
        AhkTest.AssertEqual("ALL_COMPLETED", stdlib.asyncio.ALL_COMPLETED)
        AhkTest.AssertTrue(stdlib.asyncio.TimeoutError != TimeoutError)
        AhkTest.AssertTrue(HasBase(stdlib.asyncio.SendfileNotAvailableError.Prototype, RuntimeError.Prototype))

        oldPolicy := stdlib.asyncio.get_event_loop_policy()
        policy := stdlib.asyncio.DefaultEventLoopPolicy()
        eventLoop := stdlib.asyncio.new_event_loop()
        try {
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio.set_event_loop_policy(policy))
            AhkTest.AssertSame(policy, stdlib.asyncio.get_event_loop_policy())
            AhkTest.AssertFalse(eventLoop.get_debug())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio.set_event_loop(eventLoop))
            AhkTest.AssertSame(eventLoop, stdlib.asyncio.get_event_loop())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio._get_running_loop())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio._set_running_loop(eventLoop))
            AhkTest.AssertSame(eventLoop, stdlib.asyncio._get_running_loop())
            AhkTest.AssertSame(eventLoop, stdlib.asyncio.get_running_loop())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio._set_running_loop(stdlib.None))
            AhkTest.RaisesMatch(RuntimeError, "^no running event loop$", (*) => stdlib.asyncio.get_running_loop())
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop_policy(oldPolicy)
        }

        queue := stdlib.asyncio.Queue({ maxsize: 2 })
        AhkTest.AssertTrue(queue.empty())
        AhkTest.AssertFalse(queue.full())
        AhkTest.AssertEqual(0, queue.qsize())
        AhkTest.AssertSame(stdlib.None, queue.put_nowait("a"))
        AhkTest.AssertSame(stdlib.None, queue.put_nowait("b"))
        AhkTest.AssertTrue(queue.full())
        AhkTest.Raises(stdlib.asyncio.QueueFull, (*) => queue.put_nowait("c"))
        AhkTest.AssertEqual("a", queue.get_nowait())
        AhkTest.AssertEqual("b", queue.get_nowait())
        AhkTest.Raises(stdlib.asyncio.QueueEmpty, (*) => queue.get_nowait())

        lifo := stdlib.asyncio.LifoQueue()
        lifo.put_nowait("a")
        lifo.put_nowait("b")
        AhkTest.AssertEqual("b", lifo.get_nowait())
        AhkTest.AssertEqual("a", lifo.get_nowait())

        priority := stdlib.asyncio.PriorityQueue()
        priority.put_nowait([2, "b"])
        priority.put_nowait([1, "a"])
        AhkTest.AssertEqual([1, "a"], priority.get_nowait())
        AhkTest.AssertEqual([2, "b"], priority.get_nowait())
    }

    static TestChildWatcherSurfaceMatchesLocalWindows310()
    {
        AhkTest.Raises(stdlib.NotImplementedError, (*) => stdlib.asyncio.get_child_watcher())
        AhkTest.Raises(stdlib.NotImplementedError, (*) => stdlib.asyncio.set_child_watcher(stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^get_child_watcher\(\) takes 0 positional arguments but 1 was given$", (*) => stdlib.asyncio.get_child_watcher(1))
        AhkTest.RaisesMatch(TypeError, "^set_child_watcher\(\) missing 1 required positional argument: 'watcher'$", (*) => stdlib.asyncio.set_child_watcher())
        AhkTest.RaisesMatch(TypeError, "^set_child_watcher\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.asyncio.set_child_watcher(stdlib.None, stdlib.None))
    }

    static TestCoreEventLoopFutureCallbacksSleepAndGather()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        stdlib.asyncio.set_event_loop(eventLoop)
        try {
            order := []
            handle := eventLoop.call_soon((label) => order.Push(label), "soon")
            cancelled := eventLoop.call_soon((*) => order.Push("cancelled"))
            timer := eventLoop.call_later(0, (label) => order.Push(label), "later0")
            threadsafeHandle := eventLoop.call_soon_threadsafe((label) => order.Push(label), "threadsafe")
            AhkTest.AssertEqual("AhkStdlibAsyncioHandle", Type(handle))
            AhkTest.AssertEqual("AhkStdlibAsyncioHandle", Type(threadsafeHandle))
            AhkTest.AssertEqual("AhkStdlibAsyncioTimerHandle", Type(timer))
            AhkTest.AssertSame(stdlib.None, cancelled.cancel())
            AhkTest.AssertTrue(cancelled.cancelled())
            AhkTest.AssertSame(stdlib.None, stdlib.await(stdlib.asyncio.sleep(0), { loop: eventLoop }))
            AhkTest.AssertEqual(["soon", "threadsafe", "later0"], order)

            future := eventLoop.create_future()
            callbackOrder := []
            AhkTest.AssertSame(stdlib.None, future.add_done_callback((doneFuture) => callbackOrder.Push(["done", doneFuture.result()])))
            AhkTest.AssertEqual(0, future.remove_done_callback((*) => stdlib.None))
            AhkTest.AssertSame(stdlib.None, future.set_result("value"))
            AhkTest.AssertTrue(future.done())
            AhkTest.AssertEqual([], callbackOrder)
            AhkTest.AssertSame(stdlib.None, stdlib.await(stdlib.asyncio.sleep(0), { loop: eventLoop }))
            AhkTest.AssertEqual([["done", "value"]], callbackOrder)

            finished := eventLoop.create_future()
            finished.set_result(7)
            AhkTest.AssertEqual(7, stdlib.await(finished, { loop: eventLoop }))

            failed := eventLoop.create_future()
            failed.set_exception(RuntimeError("boom", -1))
            AhkTest.RaisesMatch(RuntimeError, "^boom$", (*) => stdlib.await(failed, { loop: eventLoop }))

            AhkTest.AssertEqual("slept", stdlib.await(stdlib.asyncio.sleep(0, "slept"), { loop: eventLoop }))
            left := eventLoop.create_future()
            right := eventLoop.create_future()
            gathered := stdlib.asyncio.gather(left, right)
            left.set_result("a")
            right.set_result("b")
            AhkTest.AssertEqual(["a", "b"], stdlib.await(gathered, { loop: eventLoop }))

            threadsafe := stdlib.asyncio.run_coroutine_threadsafe(StdlibAsyncioTaskBody([]), eventLoop)
            AhkTest.AssertTrue(stdlib.asyncio.isfuture(threadsafe))
            AhkTest.AssertFalse(threadsafe.done())
            AhkTest.AssertEqual("task-result", stdlib.await(threadsafe, { loop: eventLoop }))

            threadsafeFailed := stdlib.asyncio.run_coroutine_threadsafe(StdlibAsyncioThreadsafeFailureBody(), eventLoop)
            AhkTest.RaisesMatch(RuntimeError, "^threadsafe-boom$", (*) => stdlib.await(threadsafeFailed, { loop: eventLoop }))

            threadsafeCancelled := stdlib.asyncio.run_coroutine_threadsafe(StdlibAsyncioThreadsafeNeverBody(), eventLoop)
            AhkTest.AssertTrue(threadsafeCancelled.cancel())
            AhkTest.Raises(stdlib.asyncio.CancelledError, (*) => stdlib.await(threadsafeCancelled, { loop: eventLoop }))
            AhkTest.AssertTrue(threadsafeCancelled.cancelled())

            AhkTest.RaisesMatch(TypeError, "^run_coroutine_threadsafe\(\) missing 2 required positional arguments: 'coro' and 'loop'$", (*) => stdlib.asyncio.run_coroutine_threadsafe())
            AhkTest.RaisesMatch(TypeError, "^run_coroutine_threadsafe\(\) takes 2 positional arguments but 3 were given$", (*) => stdlib.asyncio.run_coroutine_threadsafe(StdlibAsyncioTaskBody([]), eventLoop, eventLoop))
            AhkTest.RaisesMatch(TypeError, "^A coroutine object is required$", (*) => stdlib.asyncio.run_coroutine_threadsafe(1, eventLoop))
            AhkTest.RaisesMatch(stdlib.AttributeError, "^'int' object has no attribute 'call_soon_threadsafe'$", (*) => stdlib.asyncio.run_coroutine_threadsafe(StdlibAsyncioTaskBody([]), 1))
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop(stdlib.None)
        }
    }

    static TestEventLoopLifecycleTimeAndCallAtLikeLocal310()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        stdlib.asyncio.set_event_loop(eventLoop)
        try {
            beforeTime := eventLoop.time()
            events := []

            AhkTest.AssertFalse(eventLoop.is_running())
            AhkTest.AssertFalse(eventLoop.is_closed())
            AhkTest.AssertEqual("Float", Type(beforeTime))
            eventLoop.call_soon((label) => events.Push(["soon", label]), "first")
            atHandle := eventLoop.call_at(eventLoop.time(), (label) => events.Push(["at", label]), "now")
            laterHandle := eventLoop.call_at(eventLoop.time() + 0.001, (label) => events.Push(["later", label]), "tick")
            AhkTest.AssertEqual("AhkStdlibAsyncioTimerHandle", Type(atHandle))
            AhkTest.AssertEqual("AhkStdlibAsyncioTimerHandle", Type(laterHandle))

            result := eventLoop.run_until_complete(StdlibAsyncioLoopLifecycleBody(eventLoop, events))
            AhkTest.AssertEqual("done", result)
            AhkTest.AssertFalse(eventLoop.is_running())
            AhkTest.AssertFalse(eventLoop.is_closed())
            AhkTest.AssertEqual([
                ["soon", "first"],
                ["inside_running", true, false],
                ["at", "now"],
            ], events)

            AhkTest.AssertEqual("spin", eventLoop.run_until_complete(stdlib.asyncio.sleep(0.01, "spin")))
            AhkTest.AssertFalse(eventLoop.is_running())
            AhkTest.AssertFalse(eventLoop.is_closed())
            AhkTest.AssertTrue(eventLoop.time() >= beforeTime)
            AhkTest.AssertEqual([
                ["soon", "first"],
                ["inside_running", true, false],
                ["at", "now"],
                ["later", "tick"],
            ], events)

            AhkTest.AssertSame(stdlib.None, eventLoop.close())
            AhkTest.AssertFalse(eventLoop.is_running())
            AhkTest.AssertTrue(eventLoop.is_closed())
            AhkTest.RaisesMatch(RuntimeError, "^Event loop is closed$", (*) => eventLoop.call_soon((*) => stdlib.None))
            AhkTest.RaisesMatch(RuntimeError, "^Event loop is closed$", (*) => eventLoop.run_until_complete(StdlibAsyncioLoopLifecycleBody(eventLoop, [])))
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop(stdlib.None)
        }
    }

    static TestEventLoopRunUntilCompleteReturnAndExceptionLikeLocal310()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        stdlib.asyncio.set_event_loop(eventLoop)
        try {
            finished := eventLoop.create_future()
            finished.set_result(7)
            AhkTest.AssertEqual(7, eventLoop.run_until_complete(finished))

            failed := eventLoop.create_future()
            failed.set_exception(RuntimeError("boom", -1))
            AhkTest.RaisesMatch(RuntimeError, "^boom$", (*) => eventLoop.run_until_complete(failed))
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop(stdlib.None)
        }
    }

    static TestFutureCombinatorsForSingleThreadedCore()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        stdlib.asyncio.set_event_loop(eventLoop)
        try {
            first := eventLoop.create_future()
            AhkTest.AssertSame(first, stdlib.asyncio.ensure_future(first))
            AhkTest.AssertSame(first, stdlib.asyncio.wrap_future(first))
            AhkTest.AssertSame(first, stdlib.asyncio.wrap_future(first, { loop: eventLoop }))
            AhkTest.RaisesMatch(TypeError, "^wrap_future\(\) missing 1 required positional argument: 'future'$", (*) => stdlib.asyncio.wrap_future())
            AhkTest.RaisesMatch(TypeError, "^wrap_future\(\) takes 1 positional argument but 3 were given$", (*) => stdlib.asyncio.wrap_future(first, eventLoop, eventLoop))
            AhkTest.RaisesMatch(Error, "^concurrent\.futures\.Future is expected, got 1$", (*) => stdlib.asyncio.wrap_future(1, { loop: eventLoop }))
            AhkTest.AssertTrue(stdlib.asyncio.isfuture(stdlib.asyncio.shield(first)))
            first.set_result("ready")
            AhkTest.AssertEqual("ready", stdlib.await(stdlib.asyncio.shield(first), { loop: eventLoop }))

            waitLeft := eventLoop.create_future()
            waitRight := eventLoop.create_future()
            waitLeft.set_result("left")
            waitRight.set_result("right")
            waitResult := stdlib.await(stdlib.asyncio.wait([waitLeft, waitRight]), { loop: eventLoop })
            AhkTest.AssertEqual(2, waitResult[1].Length)
            AhkTest.AssertEqual(0, waitResult[2].Length)
            waitValues := [waitResult[1][1].result(), waitResult[1][2].result()]
            AhkTest.AssertEqual(["left", "right"], waitValues)

            waitForFuture := eventLoop.create_future()
            waitForFuture.set_result("wf")
            AhkTest.AssertEqual("wf", stdlib.await(stdlib.asyncio.wait_for(waitForFuture, { timeout: 1 }), { loop: eventLoop }))

            timeoutFuture := eventLoop.create_future()
            AhkTest.Raises(stdlib.asyncio.TimeoutError, (*) => stdlib.await(stdlib.asyncio.wait_for(timeoutFuture, { timeout: 0 }), { loop: eventLoop }))
            AhkTest.AssertTrue(timeoutFuture.cancelled())

            acLeft := eventLoop.create_future()
            acRight := eventLoop.create_future()
            completed := stdlib.asyncio.as_completed([acLeft, acRight])
            acLeft.set_result("a")
            acRight.set_result("b")
            AhkTest.AssertEqual("a", stdlib.await(completed[1], { loop: eventLoop }))
            AhkTest.AssertEqual("b", stdlib.await(completed[2], { loop: eventLoop }))

            AhkTest.AssertSame(stdlib.None, stdlib.asyncio.current_task({ loop: eventLoop }))
            AhkTest.AssertEqual([], stdlib.asyncio.all_tasks({ loop: eventLoop }))
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop(stdlib.None)
        }
    }

    static TestTaskDrivesCooperativeAwaitablesAndTracksRunningTaskLikeLocal310()
    {
        eventLoop := stdlib.asyncio.new_event_loop()
        stdlib.asyncio.set_event_loop(eventLoop)
        try {
            events := []
            body := StdlibAsyncioTaskBody(events)
            task := eventLoop.create_task(body)

            AhkTest.AssertTrue(stdlib.asyncio.isfuture(task))
            AhkTest.AssertSame(eventLoop, task.get_loop())
            AhkTest.AssertFalse(task.done())
            AhkTest.AssertFalse(task.cancelled())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio.current_task({ loop: eventLoop }))
            AhkTest.AssertTrue(StdlibAsyncioTestContains(stdlib.asyncio.all_tasks({ loop: eventLoop }), task))

            AhkTest.AssertEqual("task-result", stdlib.await(task, { loop: eventLoop }))
            AhkTest.AssertEqual([
                ["current_task_is_task", true],
                ["all_tasks_contains_task", true],
                ["after_sleep", "slept", true],
            ], events)
            AhkTest.AssertTrue(task.done())
            AhkTest.AssertFalse(task.cancelled())
            AhkTest.AssertEqual("task-result", task.result())
            AhkTest.AssertSame(stdlib.None, task.exception())
            AhkTest.AssertSame(stdlib.None, stdlib.asyncio.current_task({ loop: eventLoop }))
            AhkTest.AssertEqual([], stdlib.asyncio.all_tasks({ loop: eventLoop }))

            childEvents := []
            parent := eventLoop.create_task(StdlibAsyncioParentTaskBody(childEvents))
            AhkTest.AssertEqual("child-result", stdlib.await(parent, { loop: eventLoop }))
            AhkTest.AssertEqual([
                ["parent-created-child", true],
                "child-start",
                "child-end",
                ["parent-after-child", "child-result"],
            ], childEvents)

            cancelledTask := eventLoop.create_task(StdlibAsyncioNeverStartedTaskBody())
            AhkTest.AssertTrue(cancelledTask.cancel("bye"))
            AhkTest.AssertFalse(cancelledTask.done())
            AhkTest.AssertFalse(cancelledTask.cancelled())
            AhkTest.Raises(stdlib.asyncio.CancelledError, (*) => stdlib.await(cancelledTask, { loop: eventLoop }))
            AhkTest.AssertTrue(cancelledTask.done())
            AhkTest.AssertTrue(cancelledTask.cancelled())
            AhkTest.AssertFalse(cancelledTask.cancel())
        } finally {
            stdlib.asyncio._set_running_loop(stdlib.None)
            stdlib.asyncio.set_event_loop(stdlib.None)
        }
    }

    static TestRunCreateTaskAndCoroutineIntrospectionLikeLocal310()
    {
        AhkTest.AssertFalse(stdlib.asyncio.iscoroutine(1))
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutine(StdlibAsyncioTaskBody([])))
        AhkTest.AssertFalse(stdlib.asyncio.iscoroutinefunction(StdlibAsyncioPlainFunction))
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutinefunction(StdlibAsyncioCoroutineFunction))

        AhkTest.AssertEqual("task-result", stdlib.asyncio.run(StdlibAsyncioTaskBody([])))
        AhkTest.RaisesMatch(ValueError, "^a coroutine was expected, got 1$", (*) => stdlib.asyncio.run(1))
        AhkTest.RaisesMatch(RuntimeError, "^no running event loop$", (*) => stdlib.asyncio.create_task(StdlibAsyncioTaskBody([])))
        AhkTest.RaisesMatch(TypeError, "^coroutine\(\) missing 1 required positional argument: 'func'$", (*) => stdlib.asyncio.coroutine())
        AhkTest.RaisesMatch(TypeError, "^coroutine\(\) takes 1 positional argument but 2 were given$", (*) => stdlib.asyncio.coroutine(StdlibAsyncioPlainFunction, StdlibAsyncioPlainFunction))

        decoratedPlain := stdlib.asyncio.coroutine(StdlibAsyncioPlainFunction)
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutinefunction(decoratedPlain))
        decoratedResult := decoratedPlain.Call()
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutine(decoratedResult))
        AhkTest.AssertEqual("plain", stdlib.await(decoratedResult))

        decoratedCoroutine := stdlib.asyncio.coroutine(StdlibAsyncioCoroutineFunction)
        AhkTest.AssertSame(StdlibAsyncioCoroutineFunction, decoratedCoroutine)
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutinefunction(decoratedCoroutine))

        AhkTest.RaisesMatch(TypeError, "^to_thread\(\) missing 1 required positional argument: 'func'$", (*) => stdlib.asyncio.to_thread())
        toThreadResult := stdlib.asyncio.to_thread(StdlibAsyncioToThreadWorker, "payload", "-suffix")
        AhkTest.AssertTrue(stdlib.asyncio.iscoroutine(toThreadResult))
        AhkTest.RaisesMatch(stdlib.NotImplementedError, "^asyncio\.to_thread\(\) requires a Windows DLL worker backend for true thread offload$", (*) => stdlib.await(toThreadResult))

        nestedResult := stdlib.asyncio.run(StdlibAsyncioNestedRunBody())
        AhkTest.AssertEqual(["RuntimeError", "asyncio.run() cannot be called from a running event loop"], nestedResult)
    }

    static TestSyncPrimitivesAndAsyncQueueWaitersLikeLocal310()
    {
        syncEvents := stdlib.await(StdlibAsyncioSyncPrimitiveBody())
        AhkTest.AssertEqual([
            ["lock_initial", false],
            ["lock_acquire_result", true, true],
            ["lock_waiter_pending", false],
            ["lock_waiter_after_release", true, true, true],
            ["lock_after_second_release", false],
            ["lock_release_error", "RuntimeError", "Lock is not acquired."],
            ["event_initial", false],
            ["event_waiter_pending", false],
            ["event_after_set", true, true, true],
            ["event_after_clear", false],
            ["sem_initial_locked", false],
            ["sem_acquire_result", true, true],
            ["sem_waiter_pending", false],
            ["sem_after_release", true, true, true],
            ["sem_after_extra_release", false],
            ["bounded_extra_release_error", "ValueError", "BoundedSemaphore released too many times"],
        ], syncEvents)

        queueEvents := stdlib.await(StdlibAsyncioAsyncQueueBody())
        AhkTest.AssertEqual([
            ["queue_initial", 0, true, false],
            ["queue_put_result", stdlib.None, 1, true],
            ["queue_putter_pending", false],
            ["queue_get_result", "a", 0, true],
            ["queue_putter_after_get", true, stdlib.None, 1, true],
            ["queue_get_nowait_after_putter", "b"],
            ["queue_getter_pending", false],
            ["queue_getter_after_put", true, "c", true],
            ["queue_join_result", stdlib.None],
            ["queue_task_done_error", "ValueError", "task_done() called too many times"],
        ], queueEvents)
    }

    static TestConditionWaitNotifyAndErrorsLikeLocal310()
    {
        events := stdlib.await(StdlibAsyncioConditionBody())
        AhkTest.AssertEqual([
            ["initial_locked", false],
            ["acquire_result", true, true],
            ["after_release", false],
            ["pending_before_notify", false, false, false],
            ["notify_return", stdlib.None, true],
            ["waiter-one", true, true],
            ["after_notify_one", true, false],
            ["notify_all_return", stdlib.None, true],
            ["waiter-two", true, true],
            ["after_notify_all", true, true, false],
            ["wait_unlocked_error", "RuntimeError", "cannot wait on un-acquired lock"],
            ["notify_unlocked_error", "RuntimeError", "cannot notify on un-acquired lock"],
            ["release_unlocked_error", "RuntimeError", "Lock is not acquired."],
        ], events)
    }

    static TestWaitWaitForAndAsCompletedResolvePendingInputsLikeLocal310()
    {
        events := stdlib.await(StdlibAsyncioPendingWaitBody())
        AhkTest.AssertEqual([
            ["wait_pending_initial", false],
            ["wait_after_one", false],
            ["wait_after_all", 2, 0, ["left", "right"]],
            ["wait_for_timeout", "AhkStdlibAsyncio.TimeoutError", "", true],
            ["wait_for_pending_initial", false],
            ["wait_for_result", "delayed-result"],
            ["as_completed_initial", [false, false]],
            ["as_completed_after_second", [false, false]],
            ["as_completed_results", ["second", "first"]],
        ], events)
    }
}

AhkTest.Collect(StdlibAsyncioTest)

StdlibAsyncioTestContains(items, needle)
{
    for item in items {
        if item == needle
            return true
    }
    return false
}

class StdlibAsyncioTaskBody
{
    __New(events)
    {
        this.Events := events
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            this.Events.Push(["current_task_is_task", stdlib.asyncio.current_task() == task])
            this.Events.Push(["all_tasks_contains_task", StdlibAsyncioTestContains(stdlib.asyncio.all_tasks(), task)])
            return stdlib.asyncio.sleep(0, "slept")
        }

        this.Events.Push(["after_sleep", value, stdlib.asyncio.current_task() == task])
        return "task-result"
    }
}

class StdlibAsyncioParentTaskBody
{
    __New(events)
    {
        this.Events := events
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            child := stdlib.asyncio.create_task(StdlibAsyncioChildTaskBody(this.Events))
            this.Events.Push(["parent-created-child", stdlib.asyncio.isfuture(child)])
            return child
        }

        this.Events.Push(["parent-after-child", value])
        return value
    }
}

class StdlibAsyncioChildTaskBody
{
    __New(events)
    {
        this.Events := events
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            this.Events.Push("child-start")
            return stdlib.asyncio.sleep(0)
        }

        this.Events.Push("child-end")
        return "child-result"
    }
}

class StdlibAsyncioNeverStartedTaskBody
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        return "should-not-run"
    }
}

class StdlibAsyncioThreadsafeFailureBody
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        throw RuntimeError("threadsafe-boom", -1)
    }
}

class StdlibAsyncioThreadsafeNeverBody
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        return task.get_loop().create_future()
    }
}

class StdlibAsyncioLoopLifecycleBody
{
    __New(eventLoop, events)
    {
        this.EventLoop := eventLoop
        this.Events := events
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        this.Events.Push(["inside_running", this.EventLoop.is_running(), this.EventLoop.is_closed()])
        return "done"
    }
}

StdlibAsyncioPlainFunction()
{
    return "plain"
}

StdlibAsyncioCoroutineFunction()
{
    return StdlibAsyncioTaskBody([])
}

StdlibAsyncioToThreadWorker(value, suffix)
{
    return value suffix
}

StdlibAsyncioToThreadFailure()
{
    throw RuntimeError("to-thread-boom", -1)
}

class StdlibAsyncioNestedRunBody
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        try {
            stdlib.asyncio.run(StdlibAsyncioTaskBody([]))
        } catch Error as err {
            return [Type(err), err.Message]
        }
        return ["", ""]
    }
}

class StdlibAsyncioSyncPrimitiveBody
{
    __New()
    {
        this.Events := []
        this.StepIndex := 0
        this.Lock := unset
        this.LockWaiter := unset
        this.Event := unset
        this.EventWaiter := unset
        this.Semaphore := unset
        this.SemaphoreWaiter := unset
        this.Bounded := unset
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Lock := stdlib.asyncio.Lock()
                this.Events.Push(["lock_initial", this.Lock.locked()])
                return this.Lock.acquire()
            case 1:
                this.StepIndex += 1
                this.Events.Push(["lock_acquire_result", value, this.Lock.locked()])
                this.LockWaiter := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(this.Lock.acquire()))
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                this.Events.Push(["lock_waiter_pending", this.LockWaiter.done()])
                this.Lock.release()
                return stdlib.asyncio.sleep(0)
            case 3:
                this.StepIndex += 1
                this.Events.Push(["lock_waiter_after_release", this.LockWaiter.done(), this.LockWaiter.result(), this.Lock.locked()])
                this.Lock.release()
                this.Events.Push(["lock_after_second_release", this.Lock.locked()])
                try {
                    this.Lock.release()
                } catch Error as err {
                    this.Events.Push(["lock_release_error", Type(err), err.Message])
                }

                this.Event := stdlib.asyncio.Event()
                this.Events.Push(["event_initial", this.Event.is_set()])
                this.EventWaiter := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(this.Event.wait()))
                return stdlib.asyncio.sleep(0)
            case 4:
                this.StepIndex += 1
                this.Events.Push(["event_waiter_pending", this.EventWaiter.done()])
                this.Event.set()
                return stdlib.asyncio.sleep(0)
            case 5:
                this.StepIndex += 1
                this.Events.Push(["event_after_set", this.Event.is_set(), this.EventWaiter.done(), this.EventWaiter.result()])
                this.Event.clear()
                this.Events.Push(["event_after_clear", this.Event.is_set()])

                this.Semaphore := stdlib.asyncio.Semaphore(1)
                this.Events.Push(["sem_initial_locked", this.Semaphore.locked()])
                return this.Semaphore.acquire()
            case 6:
                this.StepIndex += 1
                this.Events.Push(["sem_acquire_result", value, this.Semaphore.locked()])
                this.SemaphoreWaiter := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(this.Semaphore.acquire()))
                return stdlib.asyncio.sleep(0)
            case 7:
                this.StepIndex += 1
                this.Events.Push(["sem_waiter_pending", this.SemaphoreWaiter.done()])
                this.Semaphore.release()
                return stdlib.asyncio.sleep(0)
            case 8:
                this.StepIndex += 1
                this.Events.Push(["sem_after_release", this.SemaphoreWaiter.done(), this.SemaphoreWaiter.result(), this.Semaphore.locked()])
                this.Semaphore.release()
                this.Events.Push(["sem_after_extra_release", this.Semaphore.locked()])

                this.Bounded := stdlib.asyncio.BoundedSemaphore(1)
                return this.Bounded.acquire()
            case 9:
                this.Bounded.release()
                try {
                    this.Bounded.release()
                } catch Error as err {
                    this.Events.Push(["bounded_extra_release_error", Type(err), err.Message])
                }
                return this.Events
        }
    }
}

class StdlibAsyncioAsyncQueueBody
{
    __New()
    {
        this.Events := []
        this.StepIndex := 0
        this.Queue := unset
        this.Putter := unset
        this.Getter := unset
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Queue := stdlib.asyncio.Queue({ maxsize: 1 })
                this.Events.Push(["queue_initial", this.Queue.qsize(), this.Queue.empty(), this.Queue.full()])
                return this.Queue.put("a")
            case 1:
                this.StepIndex += 1
                this.Events.Push(["queue_put_result", value, this.Queue.qsize(), this.Queue.full()])
                this.Putter := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(this.Queue.put("b")))
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                this.Events.Push(["queue_putter_pending", this.Putter.done()])
                return this.Queue.get()
            case 3:
                this.StepIndex += 1
                this.Events.Push(["queue_get_result", value, this.Queue.qsize(), this.Queue.empty()])
                this.Queue.task_done()
                return stdlib.asyncio.sleep(0)
            case 4:
                this.StepIndex += 1
                this.Events.Push(["queue_putter_after_get", this.Putter.done(), this.Putter.result(), this.Queue.qsize(), this.Queue.full()])
                this.Events.Push(["queue_get_nowait_after_putter", this.Queue.get_nowait()])
                this.Queue.task_done()
                this.Getter := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(this.Queue.get()))
                return stdlib.asyncio.sleep(0)
            case 5:
                this.StepIndex += 1
                this.Events.Push(["queue_getter_pending", this.Getter.done()])
                this.Queue.put_nowait("c")
                return stdlib.asyncio.sleep(0)
            case 6:
                this.StepIndex += 1
                this.Events.Push(["queue_getter_after_put", this.Getter.done(), this.Getter.result(), this.Queue.empty()])
                this.Queue.task_done()
                this.Queue.put_nowait("task")
                this.Queue.task_done()
                return this.Queue.join()
            case 7:
                this.Events.Push(["queue_join_result", value])
                try {
                    this.Queue.task_done()
                } catch Error as err {
                    this.Events.Push(["queue_task_done_error", Type(err), err.Message])
                }
                return this.Events
        }
    }
}

class StdlibAsyncioAwaitFutureBody
{
    __New(future)
    {
        this.Future := future
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            return this.Future
        }
        return value
    }
}

class StdlibAsyncioConditionBody
{
    __New()
    {
        this.Events := []
        this.StepIndex := 0
        this.Condition := unset
        this.First := unset
        this.Second := unset
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Condition := stdlib.asyncio.Condition()
                this.Events.Push(["initial_locked", this.Condition.locked()])
                return this.Condition.acquire()
            case 1:
                this.StepIndex += 1
                this.Events.Push(["acquire_result", value, this.Condition.locked()])
                this.Condition.release()
                this.Events.Push(["after_release", this.Condition.locked()])
                this.First := stdlib.asyncio.create_task(StdlibAsyncioConditionWaiterBody(this.Condition, this.Events, "waiter-one"))
                this.Second := stdlib.asyncio.create_task(StdlibAsyncioConditionWaiterBody(this.Condition, this.Events, "waiter-two"))
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                return stdlib.asyncio.sleep(0)
            case 3:
                this.StepIndex += 1
                this.Events.Push(["pending_before_notify", this.First.done(), this.Second.done(), this.Condition.locked()])
                return this.Condition.acquire()
            case 4:
                this.StepIndex += 1
                this.Events.Push(["notify_return", this.Condition.notify(), this.Condition.locked()])
                this.Condition.release()
                return stdlib.asyncio.sleep(0)
            case 5:
                this.StepIndex += 1
                return stdlib.asyncio.sleep(0)
            case 6:
                this.StepIndex += 1
                this.Events.Push(["after_notify_one", this.First.done(), this.Second.done()])
                return this.Condition.acquire()
            case 7:
                this.StepIndex += 1
                this.Events.Push(["notify_all_return", this.Condition.notify_all(), this.Condition.locked()])
                this.Condition.release()
                return stdlib.asyncio.gather(this.First, this.Second)
            case 8:
                this.StepIndex += 1
                this.Events.Push(["after_notify_all", this.First.done(), this.Second.done(), this.Condition.locked()])
                return this.Condition.wait()
            case 9:
                return this.Events
        }
    }

    AhkStdlibAsyncioThrow(task, err)
    {
        if this.StepIndex = 9 {
            this.StepIndex += 1
            this.Events.Push(["wait_unlocked_error", Type(err), err.Message])
            try {
                this.Condition.notify()
            } catch Error as notifyErr {
                this.Events.Push(["notify_unlocked_error", Type(notifyErr), notifyErr.Message])
            }
            try {
                this.Condition.release()
            } catch Error as releaseErr {
                this.Events.Push(["release_unlocked_error", Type(releaseErr), releaseErr.Message])
            }
            return this.Events
        }
        throw err
    }
}

class StdlibAsyncioConditionWaiterBody
{
    __New(condition, events, label)
    {
        this.Condition := condition
        this.Events := events
        this.Label := label
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                return this.Condition.acquire()
            case 1:
                this.StepIndex += 1
                return this.Condition.wait()
            case 2:
                this.Events.Push([this.Label, value, this.Condition.locked()])
                this.Condition.release()
                return value
        }
    }
}

class StdlibAsyncioPendingWaitBody
{
    __New()
    {
        this.Events := []
        this.StepIndex := 0
        this.Loop := unset
        this.Left := unset
        this.Right := unset
        this.WaitTask := unset
        this.TimeoutTarget := unset
        this.Delayed := unset
        this.WaitForTask := unset
        this.First := unset
        this.Second := unset
        this.Completed := unset
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Loop := stdlib.asyncio.get_running_loop()
                this.Left := this.Loop.create_future()
                this.Right := this.Loop.create_future()
                this.WaitTask := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(stdlib.asyncio.wait([this.Left, this.Right])))
                return stdlib.asyncio.sleep(0)
            case 1:
                this.StepIndex += 1
                this.Events.Push(["wait_pending_initial", this.WaitTask.done()])
                this.Left.set_result("left")
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                this.Events.Push(["wait_after_one", this.WaitTask.done()])
                this.Right.set_result("right")
                return this.WaitTask
            case 3:
                this.StepIndex += 1
                values := [value[1][1].result(), value[1][2].result()]
                values := StdlibAsyncioSortStrings(values)
                this.Events.Push(["wait_after_all", value[1].Length, value[2].Length, values])
                this.TimeoutTarget := this.Loop.create_future()
                return stdlib.asyncio.wait_for(this.TimeoutTarget, { timeout: 0.01 })
            case 4:
                return this.Events
            case 5:
                this.StepIndex += 1
                this.Events.Push(["wait_for_pending_initial", this.WaitForTask.done()])
                this.Delayed.set_result("delayed-result")
                return this.WaitForTask
            case 6:
                this.StepIndex += 1
                this.Events.Push(["wait_for_result", value])
                this.First := this.Loop.create_future()
                this.Second := this.Loop.create_future()
                completedAwaitables := stdlib.asyncio.as_completed([this.First, this.Second])
                this.Completed := [
                    stdlib.asyncio.create_task(completedAwaitables[1]),
                    stdlib.asyncio.create_task(completedAwaitables[2]),
                ]
                return stdlib.asyncio.sleep(0)
            case 7:
                this.StepIndex += 1
                this.Events.Push(["as_completed_initial", [this.Completed[1].done(), this.Completed[2].done()]])
                this.Second.set_result("second")
                return stdlib.asyncio.sleep(0)
            case 8:
                this.StepIndex += 1
                this.Events.Push(["as_completed_after_second", [this.Completed[1].done(), this.Completed[2].done()]])
                this.First.set_result("first")
                return this.Completed[1]
            case 9:
                this.StepIndex += 1
                this.FirstResult := value
                return this.Completed[2]
            case 10:
                this.Events.Push(["as_completed_results", [this.FirstResult, value]])
                return this.Events
        }
    }

    AhkStdlibAsyncioThrow(task, err)
    {
        switch this.StepIndex {
            case 4:
                this.StepIndex += 1
                this.Events.Push(["wait_for_timeout", Type(err), err.Message, this.TimeoutTarget.cancelled()])
                this.Delayed := this.Loop.create_future()
                this.WaitForTask := stdlib.asyncio.create_task(StdlibAsyncioAwaitFutureBody(stdlib.asyncio.wait_for(this.Delayed, { timeout: 1 })))
                return stdlib.asyncio.sleep(0)
        }
        throw err
    }
}

StdlibAsyncioSortStrings(values)
{
    if values.Length = 2 && values[1] = "right" && values[2] = "left"
        return [values[2], values[1]]
    return values
}

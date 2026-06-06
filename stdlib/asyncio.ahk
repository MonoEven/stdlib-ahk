#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibAsyncio
{
    static FIRST_COMPLETED := "FIRST_COMPLETED"
    static FIRST_EXCEPTION := "FIRST_EXCEPTION"
    static ALL_COMPLETED := "ALL_COMPLETED"

    class CancelledError extends Error
    {
    }

    class InvalidStateError extends Error
    {
    }

    class TimeoutError extends Error
    {
    }

    class IncompleteReadError extends Error
    {
    }

    class LimitOverrunError extends Error
    {
    }

    class SendfileNotAvailableError extends RuntimeError
    {
    }

    class QueueEmpty extends Error
    {
    }

    class QueueFull extends Error
    {
    }

    static DefaultEventLoopPolicy := AhkStdlibAsyncioEventLoopPolicyClass
    static WindowsSelectorEventLoopPolicy := AhkStdlibAsyncioEventLoopPolicyClass
    static WindowsProactorEventLoopPolicy := AhkStdlibAsyncioEventLoopPolicyClass
    static AbstractEventLoopPolicy := AhkStdlibAsyncioEventLoopPolicyClass
    static AbstractEventLoop := AhkStdlibAsyncioEventLoopClass
    static BaseEventLoop := AhkStdlibAsyncioEventLoopClass
    static SelectorEventLoop := AhkStdlibAsyncioEventLoopClass
    static ProactorEventLoop := AhkStdlibAsyncioEventLoopClass
    static Queue := AhkStdlibAsyncioQueueClass
    static PriorityQueue := AhkStdlibAsyncioPriorityQueueClass
    static LifoQueue := AhkStdlibAsyncioLifoQueueClass
    static Lock := AhkStdlibAsyncioLockClass
    static Event := AhkStdlibAsyncioEventClass
    static Semaphore := AhkStdlibAsyncioSemaphoreClass
    static BoundedSemaphore := AhkStdlibAsyncioBoundedSemaphoreClass
    static Condition := AhkStdlibAsyncioConditionClass
    static BaseProtocol := AhkStdlibAsyncioBaseProtocolClass
    static Protocol := AhkStdlibAsyncioBaseProtocolClass
    static DatagramProtocol := AhkStdlibAsyncioBaseProtocolClass
    static SubprocessProtocol := AhkStdlibAsyncioBaseProtocolClass
    static BufferedProtocol := AhkStdlibAsyncioBaseProtocolClass
    static BaseTransport := AhkStdlibAsyncioBaseTransportClass
    static ReadTransport := AhkStdlibAsyncioBaseTransportClass
    static WriteTransport := AhkStdlibAsyncioBaseTransportClass
    static Transport := AhkStdlibAsyncioBaseTransportClass
    static DatagramTransport := AhkStdlibAsyncioBaseTransportClass
    static SubprocessTransport := AhkStdlibAsyncioBaseTransportClass
    static AbstractServer := AhkStdlibAsyncioAbstractServerClass
    static Server := AhkStdlibAsyncioAbstractServerClass
    static Handle := AhkStdlibAsyncioHandleClass
    static TimerHandle := AhkStdlibAsyncioTimerHandleClass
    static Task := AhkStdlibAsyncioTaskClass

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

    static get_event_loop_policy(args*)
    {
        if args.Length != 0
            throw TypeError("get_event_loop_policy() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibAsyncioGetPolicy()
    }

    static set_event_loop_policy(args*)
    {
        if args.Length != 1
            throw TypeError("set_event_loop_policy() takes exactly one argument (" args.Length " given)", -1)
        AhkStdlibAsyncioSetPolicy(args[1])
        return stdlib.None
    }

    static get_event_loop(args*)
    {
        if args.Length != 0
            throw TypeError("get_event_loop() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibAsyncioGetPolicy().get_event_loop()
    }

    static set_event_loop(args*)
    {
        if args.Length != 1
            throw TypeError("set_event_loop() takes exactly one argument (" args.Length " given)", -1)
        AhkStdlibAsyncioGetPolicy().set_event_loop(args[1])
        return stdlib.None
    }

    static get_child_watcher(args*)
    {
        if args.Length != 0
            throw TypeError("get_child_watcher() takes 0 positional arguments but " args.Length " " (args.Length = 1 ? "was" : "were") " given", -1)
        throw stdlib.NotImplementedError("", -1)
    }

    static set_child_watcher(args*)
    {
        if args.Length < 1
            throw TypeError("set_child_watcher() missing 1 required positional argument: 'watcher'", -1)
        if args.Length > 1
            throw TypeError("set_child_watcher() takes 1 positional argument but " args.Length " were given", -1)
        throw stdlib.NotImplementedError("", -1)
    }

    static _get_running_loop(args*)
    {
        if args.Length != 0
            throw TypeError("_get_running_loop() takes no arguments (" args.Length " given)", -1)
        return AhkStdlibAsyncioRunningLoop()
    }

    static _set_running_loop(args*)
    {
        if args.Length != 1
            throw TypeError("_set_running_loop() takes exactly one argument (" args.Length " given)", -1)
        AhkStdlibAsyncioSetRunningLoop(args[1])
        return stdlib.None
    }

    static get_running_loop(args*)
    {
        if args.Length != 0
            throw TypeError("get_running_loop() takes no arguments (" args.Length " given)", -1)
        runningLoop := AhkStdlibAsyncioRunningLoop()
        if AhkStdlibIsNone(runningLoop)
            throw RuntimeError("no running event loop", -1)
        return runningLoop
    }

    static sleep(delay, result := unset)
    {
        eventLoop := AhkStdlibAsyncioGetPolicy().get_event_loop()
        future := eventLoop.create_future()
        callback := IsSet(result)
            ? ((targetFuture, value) => targetFuture.set_result(value))
            : ((targetFuture) => targetFuture.set_result(stdlib.None))
        if IsSet(result)
            eventLoop.call_later(delay, callback, future, result)
        else
            eventLoop.call_later(delay, callback, future)
        return future
    }

    static gather(args*)
    {
        eventLoop := AhkStdlibAsyncioGetPolicy().get_event_loop()
        resultFuture := eventLoop.create_future()
        if args.Length = 0 {
            resultFuture.set_result([])
            return resultFuture
        }
        return AhkStdlibAsyncioGatherFuture(eventLoop, args, resultFuture)
    }

    static ensure_future(value, options?)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions(options?)
        return AhkStdlibAsyncioEnsureFuture(value, eventLoop)
    }

    static wrap_future(args*)
    {
        if args.Length < 1
            throw TypeError("wrap_future() missing 1 required positional argument: 'future'", -1)
        if args.Length > 2
            throw TypeError("wrap_future() takes 1 positional argument but " args.Length " were given", -1)
        if args.Length = 2 && !AhkStdlibAsyncioIsPlainKeywordObject(args[2])
            throw TypeError("wrap_future() takes 1 positional argument but " args.Length " were given", -1)
        if args[1] is AhkStdlibAsyncioFuture
            return args[1]
        throw Error("concurrent.futures.Future is expected, got " AhkStdlibAsyncioRepr(args[1]), -1)
    }

    static create_task(value, options?)
    {
        runningLoop := AhkStdlibAsyncioRunningLoop()
        if AhkStdlibIsNone(runningLoop)
            throw RuntimeError("no running event loop", -1)
        return runningLoop.create_task(value, options?)
    }

    static run(value, options?)
    {
        if !AhkStdlibIsNone(AhkStdlibAsyncioRunningLoop())
            throw RuntimeError("asyncio.run() cannot be called from a running event loop", -1)
        if !AhkStdlibAsyncioIsStepAwaitable(value)
            throw ValueError("a coroutine was expected, got " AhkStdlibAsyncioRepr(value), -1)

        policy := AhkStdlibAsyncioGetPolicy()
        previousLoop := policy.AhkStdlibEventLoop
        eventLoop := AhkStdlibAsyncioEventLoop()
        policy.set_event_loop(eventLoop)
        try {
            return eventLoop.run_until_complete(value)
        } finally {
            policy.set_event_loop(previousLoop)
            AhkStdlibAsyncioSetRunningLoop(stdlib.None)
        }
    }

    static run_coroutine_threadsafe(args*)
    {
        if args.Length < 2
            throw TypeError("run_coroutine_threadsafe() missing 2 required positional arguments: 'coro' and 'loop'", -1)
        if args.Length > 2
            throw TypeError("run_coroutine_threadsafe() takes 2 positional arguments but " args.Length " were given", -1)

        coro := args[1]
        eventLoop := args[2]
        if !AhkStdlibAsyncioIsStepAwaitable(coro)
            throw TypeError("A coroutine object is required", -1)
        if !HasMethod(eventLoop, "call_soon_threadsafe")
            throw stdlib.AttributeError("'" AhkStdlibPythonTypeName(eventLoop) "' object has no attribute 'call_soon_threadsafe'", -1)

        resultFuture := AhkStdlibAsyncioFuture({ loop: eventLoop })
        eventLoop.call_soon_threadsafe(AhkStdlibAsyncioRunCoroutineThreadsafeCallback(resultFuture, coro, eventLoop))
        return resultFuture
    }

    static coroutine(args*)
    {
        if args.Length < 1
            throw TypeError("coroutine() missing 1 required positional argument: 'func'", -1)
        if args.Length > 1
            throw TypeError("coroutine() takes 1 positional argument but " args.Length " were given", -1)
        if AhkStdlibAsyncioIsCoroutineFunction(args[1])
            return args[1]
        return AhkStdlibAsyncioCoroutineFunctionWrapper(args[1])
    }

    static to_thread(args*)
    {
        if args.Length < 1
            throw TypeError("to_thread() missing 1 required positional argument: 'func'", -1)
        func := args.RemoveAt(1)
        return AhkStdlibAsyncioToThreadAwaitable(func, args)
    }

    static iscoroutine(value)
    {
        return AhkStdlibAsyncioIsStepAwaitable(value)
    }

    static iscoroutinefunction(value)
    {
        return AhkStdlibAsyncioIsCoroutineFunction(value)
    }

    static shield(value)
    {
        eventLoop := AhkStdlibAsyncioGetPolicy().get_event_loop()
        source := AhkStdlibAsyncioEnsureFuture(value, eventLoop)
        if source.done()
            return source
        target := eventLoop.create_future()
        source.add_done_callback((doneFuture) => AhkStdlibAsyncioShieldDone(target, doneFuture))
        return target
    }

    static wait(awaitables, options?)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions(options?)
        resultFuture := eventLoop.create_future()
        done := []
        pending := []
        for item in awaitables {
            future := AhkStdlibAsyncioEnsureFuture(item, eventLoop)
            if future.done()
                done.Push(future)
            else
                pending.Push(future)
        }
        if pending.Length = 0 {
            resultFuture.set_result([done, pending])
            return resultFuture
        }
        remaining := { Count: pending.Length }
        for future in pending
            future.add_done_callback(AhkStdlibAsyncioWaitAllCallback(resultFuture, done, pending, remaining, future))
        return resultFuture
    }

    static wait_for(value, options?)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions(options?)
        timeout := AhkStdlibAsyncioOption(options?, "timeout", stdlib.None)
        future := AhkStdlibAsyncioEnsureFuture(value, eventLoop)
        if future.done()
            return future
        wrapper := eventLoop.create_future()
        if !AhkStdlibIsNone(timeout) && Number(timeout) <= 0 {
            future.cancel()
            wrapper.set_exception(AhkStdlibAsyncio.TimeoutError("", -1))
            return wrapper
        }
        future.add_done_callback(AhkStdlibAsyncioWaitForCallback(wrapper))
        if !AhkStdlibIsNone(timeout)
            eventLoop.call_later(timeout, AhkStdlibAsyncioWaitForTimeoutCallback(wrapper, future))
        return wrapper
    }

    static as_completed(awaitables, options?)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions(options?)
        futures := []
        for item in awaitables {
            future := AhkStdlibAsyncioEnsureFuture(item, eventLoop)
            futures.Push(future)
        }
        return AhkStdlibAsyncioAsCompleted(eventLoop, futures)
    }

    static current_task(options?)
    {
        eventLoop := AhkStdlibAsyncioTaskLoopFromOptions(options?)
        if AhkStdlibIsNone(eventLoop)
            return stdlib.None
        return eventLoop.AhkStdlibCurrentTask
    }

    static all_tasks(options?)
    {
        eventLoop := AhkStdlibAsyncioTaskLoopFromOptions(options?)
        if AhkStdlibIsNone(eventLoop)
            return []
        return eventLoop.AhkStdlibLiveTasks()
    }
}

class AhkStdlibAsyncioEventLoopPolicyClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioEventLoopPolicy()
    }
}

class AhkStdlibAsyncioEventLoopPolicy
{
    __New()
    {
        this.AhkStdlibEventLoop := stdlib.None
    }

    get_event_loop()
    {
        if AhkStdlibIsNone(this.AhkStdlibEventLoop)
            this.AhkStdlibEventLoop := AhkStdlibAsyncioEventLoop()
        return this.AhkStdlibEventLoop
    }

    set_event_loop(eventLoop)
    {
        this.AhkStdlibEventLoop := eventLoop
        return stdlib.None
    }

    new_event_loop()
    {
        return AhkStdlibAsyncioEventLoop()
    }
}

class AhkStdlibAsyncioEventLoopClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioEventLoop()
    }
}

class AhkStdlibAsyncioEventLoop
{
    __New()
    {
        this.AhkStdlibDebug := false
        this.AhkStdlibReady := []
        this.AhkStdlibTimers := []
        this.AhkStdlibStopped := false
        this.AhkStdlibRunning := false
        this.AhkStdlibClosed := false
        this.AhkStdlibTasks := []
        this.AhkStdlibCurrentTask := stdlib.None
    }

    get_debug()
    {
        return this.AhkStdlibDebug
    }

    time()
    {
        return A_TickCount / 1000.0
    }

    is_running()
    {
        return this.AhkStdlibRunning
    }

    is_closed()
    {
        return this.AhkStdlibClosed
    }

    create_future()
    {
        return AhkStdlibAsyncioFuture({ loop: this })
    }

    create_task(value, options?)
    {
        return AhkStdlibAsyncioTask(value, { loop: this })
    }

    call_soon(callback, args*)
    {
        this.AhkStdlibCheckClosed()
        handle := AhkStdlibAsyncioHandle(this, callback, args)
        this.AhkStdlibReady.Push(handle)
        return handle
    }

    call_soon_threadsafe(callback, args*)
    {
        return this.call_soon(callback, args*)
    }

    call_later(delay, callback, args*)
    {
        return this.call_at(this.time() + Max(0, Number(delay)), callback, args*)
    }

    call_at(when, callback, args*)
    {
        this.AhkStdlibCheckClosed()
        when := Number(when) * 1000
        handle := AhkStdlibAsyncioTimerHandle(this, callback, args, when)
        this.AhkStdlibTimers.Push(handle)
        return handle
    }

    run_until_complete(future)
    {
        this.AhkStdlibCheckClosed()
        future := AhkStdlibAsyncioEnsureFuture(future, this)
        this.AhkStdlibStopped := false
        previousRunning := AhkStdlibAsyncioRunningLoop()
        AhkStdlibAsyncioSetRunningLoop(this)
        this.AhkStdlibRunning := true
        try {
            while !future.done() && !this.AhkStdlibStopped
                this.AhkStdlibRunOnce()
        } finally {
            this.AhkStdlibRunning := false
            AhkStdlibAsyncioSetRunningLoop(previousRunning)
        }
        if !future.done()
            throw RuntimeError("Event loop stopped before Future completed.", -1)
        return future.result()
    }

    run_forever()
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibStopped := false
        previousRunning := AhkStdlibAsyncioRunningLoop()
        AhkStdlibAsyncioSetRunningLoop(this)
        this.AhkStdlibRunning := true
        try {
            while !this.AhkStdlibStopped
                this.AhkStdlibRunOnce()
        } finally {
            this.AhkStdlibRunning := false
            AhkStdlibAsyncioSetRunningLoop(previousRunning)
        }
    }

    stop()
    {
        this.AhkStdlibStopped := true
        return stdlib.None
    }

    close()
    {
        if this.AhkStdlibRunning
            throw RuntimeError("Cannot close a running event loop", -1)
        this.AhkStdlibClosed := true
        this.AhkStdlibReady := []
        this.AhkStdlibTimers := []
        return stdlib.None
    }

    AhkStdlibCheckClosed()
    {
        if this.AhkStdlibClosed
            throw RuntimeError("Event loop is closed", -1)
    }

    AhkStdlibRunOnce()
    {
        this.AhkStdlibMoveDueTimers()
        if this.AhkStdlibReady.Length = 0 {
            if this.AhkStdlibTimers.Length = 0
                Sleep 0
            else
                Sleep Max(0, this.AhkStdlibNextTimerDelay())
            this.AhkStdlibMoveDueTimers()
        }

        ready := this.AhkStdlibReady
        this.AhkStdlibReady := []
        for handle in ready
            handle.AhkStdlibRun()
    }

    AhkStdlibMoveDueTimers()
    {
        now := A_TickCount
        index := 1
        while index <= this.AhkStdlibTimers.Length {
            timer := this.AhkStdlibTimers[index]
            if timer.AhkStdlibCancelled {
                this.AhkStdlibTimers.RemoveAt(index)
                continue
            }
            if timer.AhkStdlibWhen <= now {
                this.AhkStdlibTimers.RemoveAt(index)
                this.AhkStdlibReady.Push(timer)
                continue
            }
            index += 1
        }
    }

    AhkStdlibNextTimerDelay()
    {
        nextWhen := 0
        for timer in this.AhkStdlibTimers {
            if timer.AhkStdlibCancelled
                continue
            if nextWhen = 0 || timer.AhkStdlibWhen < nextWhen
                nextWhen := timer.AhkStdlibWhen
        }
        if nextWhen = 0
            return 0
        return nextWhen - A_TickCount
    }

    AhkStdlibRegisterTask(task)
    {
        this.AhkStdlibTasks.Push(task)
        return stdlib.None
    }

    AhkStdlibUnregisterTask(task)
    {
        index := 1
        while index <= this.AhkStdlibTasks.Length {
            if this.AhkStdlibTasks[index] == task {
                this.AhkStdlibTasks.RemoveAt(index)
                continue
            }
            index += 1
        }
        if this.AhkStdlibCurrentTask == task
            this.AhkStdlibCurrentTask := stdlib.None
        return stdlib.None
    }

    AhkStdlibLiveTasks()
    {
        tasks := []
        for task in this.AhkStdlibTasks {
            if !task.done()
                tasks.Push(task)
        }
        return tasks
    }
}

class AhkStdlibAsyncioQueueClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioQueue(args*)
    }
}

class AhkStdlibAsyncioQueue
{
    __New(args*)
    {
        this.AhkStdlibMaxSize := 0
        this.AhkStdlibItems := []
        this.AhkStdlibGetters := []
        this.AhkStdlibPutters := []
        this.AhkStdlibUnfinishedTasks := 0
        this.AhkStdlibJoinWaiters := []
        if args.Length = 0
            return
        if args.Length > 1
            throw TypeError("Queue() takes at most 1 keyword argument (" args.Length " given)", -1)
        if !AhkStdlibAsyncioIsPlainKeywordObject(args[1]) {
            this.AhkStdlibMaxSize := args[1]
            return
        }
        for key, value in args[1].OwnProps() {
            if key != "maxsize"
                throw TypeError("'" key "' is an invalid keyword argument for Queue()", -1)
            this.AhkStdlibMaxSize := value
        }
    }

    qsize()
    {
        return this.AhkStdlibItems.Length
    }

    empty()
    {
        return this.AhkStdlibItems.Length = 0
    }

    full()
    {
        return this.AhkStdlibMaxSize > 0 && this.AhkStdlibItems.Length >= this.AhkStdlibMaxSize
    }

    put_nowait(item)
    {
        if this.full()
            throw AhkStdlibAsyncio.QueueFull("", -1)
        this.AhkStdlibEnqueue(item)
        this.AhkStdlibScheduleGetters()
        return stdlib.None
    }

    get_nowait()
    {
        if this.empty()
            throw AhkStdlibAsyncio.QueueEmpty("", -1)
        item := this.AhkStdlibPopNextItem()
        this.AhkStdlibSchedulePuttersDeferred()
        return item
    }

    put(item)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if !this.full() {
            this.put_nowait(item)
            future.set_result(stdlib.None)
            return future
        }

        this.AhkStdlibPutters.Push({ Item: item, Future: future })
        return future
    }

    get()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if !this.empty() {
            future.set_result(this.get_nowait())
            return future
        }

        this.AhkStdlibGetters.Push(future)
        return future
    }

    task_done()
    {
        if this.AhkStdlibUnfinishedTasks <= 0
            throw ValueError("task_done() called too many times", -1)
        this.AhkStdlibUnfinishedTasks -= 1
        if this.AhkStdlibUnfinishedTasks = 0
            this.AhkStdlibWakeJoiners()
        return stdlib.None
    }

    join()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if this.AhkStdlibUnfinishedTasks = 0
            future.set_result(stdlib.None)
        else
            this.AhkStdlibJoinWaiters.Push(future)
        return future
    }

    AhkStdlibEnqueue(item)
    {
        this.AhkStdlibItems.Push(item)
        this.AhkStdlibUnfinishedTasks += 1
    }

    AhkStdlibPopNextItem()
    {
        return this.AhkStdlibItems.RemoveAt(1)
    }

    AhkStdlibScheduleGetters()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        eventLoop.call_soon(ObjBindMethod(this, "AhkStdlibWakeGetters"))
    }

    AhkStdlibSchedulePuttersDeferred()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        eventLoop.call_soon((queue) => eventLoop.call_soon(ObjBindMethod(queue, "AhkStdlibWakePutters")), this)
    }

    AhkStdlibWakeGetters()
    {
        while this.AhkStdlibItems.Length > 0 && this.AhkStdlibGetters.Length > 0 {
            getter := this.AhkStdlibGetters.RemoveAt(1)
            if getter.cancelled()
                continue
            getter.set_result(this.AhkStdlibPopNextItem())
            this.AhkStdlibSchedulePuttersDeferred()
            return
        }
    }

    AhkStdlibWakePutters()
    {
        while !this.full() && this.AhkStdlibPutters.Length > 0 {
            putter := this.AhkStdlibPutters.RemoveAt(1)
            if putter.Future.cancelled()
                continue
            this.AhkStdlibEnqueue(putter.Item)
            putter.Future.set_result(stdlib.None)
            this.AhkStdlibScheduleGetters()
            return
        }
    }

    AhkStdlibWakeJoiners()
    {
        waiters := this.AhkStdlibJoinWaiters
        this.AhkStdlibJoinWaiters := []
        for waiter in waiters {
            if !waiter.cancelled()
                waiter.set_result(stdlib.None)
        }
    }
}

class AhkStdlibAsyncioLifoQueueClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioLifoQueue(args*)
    }
}

class AhkStdlibAsyncioLifoQueue extends AhkStdlibAsyncioQueue
{
    AhkStdlibPopNextItem()
    {
        return this.AhkStdlibItems.Pop()
    }
}

class AhkStdlibAsyncioPriorityQueueClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioPriorityQueue(args*)
    }
}

class AhkStdlibAsyncioPriorityQueue extends AhkStdlibAsyncioQueue
{
    AhkStdlibPopNextItem()
    {
        if this.AhkStdlibItems.Length = 1
            return this.AhkStdlibItems.Pop()
        bestIndex := 1
        bestKey := AhkStdlibAsyncioPriorityKey(this.AhkStdlibItems[1])
        loop this.AhkStdlibItems.Length - 1 {
            index := A_Index + 1
            key := AhkStdlibAsyncioPriorityKey(this.AhkStdlibItems[index])
            if key < bestKey {
                bestKey := key
                bestIndex := index
            }
        }
        return this.AhkStdlibItems.RemoveAt(bestIndex)
    }
}

class AhkStdlibAsyncioLockClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioLock()
    }
}

class AhkStdlibAsyncioLock
{
    __New()
    {
        this.AhkStdlibLocked := false
        this.AhkStdlibWaiters := []
    }

    locked()
    {
        return this.AhkStdlibLocked
    }

    acquire()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if !this.AhkStdlibLocked {
            this.AhkStdlibLocked := true
            future.set_result(true)
            return future
        }

        this.AhkStdlibWaiters.Push(future)
        return future
    }

    release()
    {
        if !this.AhkStdlibLocked
            throw RuntimeError("Lock is not acquired.", -1)
        this.AhkStdlibWakeNextWaiter()
        return stdlib.None
    }

    AhkStdlibWakeNextWaiter()
    {
        while this.AhkStdlibWaiters.Length > 0 {
            waiter := this.AhkStdlibWaiters.RemoveAt(1)
            if waiter.cancelled()
                continue
            waiter.set_result(true)
            return
        }
        this.AhkStdlibLocked := false
    }
}

class AhkStdlibAsyncioEventClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioEvent()
    }
}

class AhkStdlibAsyncioEvent
{
    __New()
    {
        this.AhkStdlibIsSet := false
        this.AhkStdlibWaiters := []
    }

    is_set()
    {
        return this.AhkStdlibIsSet
    }

    set()
    {
        this.AhkStdlibIsSet := true
        waiters := this.AhkStdlibWaiters
        this.AhkStdlibWaiters := []
        for waiter in waiters {
            if !waiter.cancelled()
                waiter.set_result(true)
        }
        return stdlib.None
    }

    clear()
    {
        this.AhkStdlibIsSet := false
        return stdlib.None
    }

    wait()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if this.AhkStdlibIsSet
            future.set_result(true)
        else
            this.AhkStdlibWaiters.Push(future)
        return future
    }
}

class AhkStdlibAsyncioSemaphoreClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioSemaphore(args*)
    }
}

class AhkStdlibAsyncioSemaphore
{
    __New(value := 1)
    {
        if Number(value) < 0
            throw ValueError("Semaphore initial value must be >= 0", -1)
        this.AhkStdlibValue := Number(value)
        this.AhkStdlibWaiters := []
    }

    locked()
    {
        return this.AhkStdlibValue = 0
    }

    acquire()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        future := eventLoop.create_future()
        if this.AhkStdlibValue > 0 {
            this.AhkStdlibValue -= 1
            future.set_result(true)
            return future
        }

        this.AhkStdlibWaiters.Push(future)
        return future
    }

    release()
    {
        this.AhkStdlibValue += 1
        this.AhkStdlibWakeNextWaiter()
        return stdlib.None
    }

    AhkStdlibWakeNextWaiter()
    {
        while this.AhkStdlibValue > 0 && this.AhkStdlibWaiters.Length > 0 {
            waiter := this.AhkStdlibWaiters.RemoveAt(1)
            if waiter.cancelled()
                continue
            this.AhkStdlibValue -= 1
            waiter.set_result(true)
            return
        }
    }
}

class AhkStdlibAsyncioBoundedSemaphoreClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioBoundedSemaphore(args*)
    }
}

class AhkStdlibAsyncioBoundedSemaphore extends AhkStdlibAsyncioSemaphore
{
    __New(value := 1)
    {
        super.__New(value)
        this.AhkStdlibBoundValue := Number(value)
    }

    release()
    {
        if this.AhkStdlibValue >= this.AhkStdlibBoundValue
            throw ValueError("BoundedSemaphore released too many times", -1)
        return super.release()
    }
}

class AhkStdlibAsyncioConditionClass
{
    static Call(thisClass, lock := unset)
    {
        if IsSet(lock)
            return AhkStdlibAsyncioCondition(lock)
        return AhkStdlibAsyncioCondition()
    }
}

class AhkStdlibAsyncioCondition
{
    __New(lock := unset)
    {
        this.AhkStdlibLock := IsSet(lock) ? lock : AhkStdlibAsyncioLock()
        this.AhkStdlibWaiters := []
    }

    locked()
    {
        return this.AhkStdlibLock.locked()
    }

    acquire()
    {
        return this.AhkStdlibLock.acquire()
    }

    release()
    {
        return this.AhkStdlibLock.release()
    }

    wait()
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        if !this.locked() {
            failed := eventLoop.create_future()
            failed.set_exception(RuntimeError("cannot wait on un-acquired lock", -1))
            return failed
        }
        waiter := eventLoop.create_future()
        this.AhkStdlibWaiters.Push(waiter)
        this.release()
        return AhkStdlibAsyncioConditionWaitFuture(this, waiter, eventLoop)
    }

    notify(n := 1)
    {
        if !this.locked()
            throw RuntimeError("cannot notify on un-acquired lock", -1)
        count := Max(0, Integer(n))
        while count > 0 && this.AhkStdlibWaiters.Length > 0 {
            waiter := this.AhkStdlibWaiters.RemoveAt(1)
            if waiter.cancelled()
                continue
            waiter.set_result(true)
            count -= 1
        }
        return stdlib.None
    }

    notify_all()
    {
        return this.notify(this.AhkStdlibWaiters.Length)
    }
}

class AhkStdlibAsyncioConditionWaitFuture extends AhkStdlibAsyncioFuture
{
    __New(condition, waiter, eventLoop)
    {
        super.__New({ loop: eventLoop })
        this.AhkStdlibCondition := condition
        this.AhkStdlibWaiter := waiter
        waiter.add_done_callback(ObjBindMethod(this, "AhkStdlibWaiterDone"))
    }

    AhkStdlibWaiterDone(waiter)
    {
        if this.done()
            return
        try {
            result := waiter.result()
        } catch Error as err {
            this.AhkStdlibReacquireThen("exception", err)
            return
        }
        this.AhkStdlibReacquireThen("result", result)
    }

    AhkStdlibReacquireThen(kind, value)
    {
        acquireFuture := this.AhkStdlibCondition.acquire()
        acquireFuture.add_done_callback(AhkStdlibAsyncioConditionReacquireCallback(this, kind, value))
    }

    AhkStdlibCompleteAfterReacquire(kind, value)
    {
        if this.done()
            return
        if kind = "exception"
            this.set_exception(value)
        else
            this.set_result(value)
    }
}

class AhkStdlibAsyncioBaseProtocolClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioBaseProtocol()
    }
}

class AhkStdlibAsyncioBaseProtocol
{
}

class AhkStdlibAsyncioBaseTransportClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioBaseTransport()
    }
}

class AhkStdlibAsyncioBaseTransport
{
}

class AhkStdlibAsyncioAbstractServerClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioAbstractServer()
    }
}

class AhkStdlibAsyncioAbstractServer
{
}

class AhkStdlibAsyncioHandleClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioHandle()
    }
}

class AhkStdlibAsyncioHandle
{
    __New(eventLoop, callback, args := unset)
    {
        this.AhkStdlibLoop := eventLoop
        this.AhkStdlibCallback := callback
        this.AhkStdlibArgs := IsSet(args) ? args : []
        this.AhkStdlibCancelled := false
    }

    cancel()
    {
        this.AhkStdlibCancelled := true
        return stdlib.None
    }

    cancelled()
    {
        return this.AhkStdlibCancelled
    }

    AhkStdlibRun()
    {
        if this.AhkStdlibCancelled
            return
        this.AhkStdlibCallback.Call(this.AhkStdlibArgs*)
    }
}

class AhkStdlibAsyncioTimerHandleClass extends AhkStdlibAsyncioHandleClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioTimerHandle()
    }
}

class AhkStdlibAsyncioTimerHandle extends AhkStdlibAsyncioHandle
{
    __New(eventLoop, callback, args, when)
    {
        super.__New(eventLoop, callback, args)
        this.AhkStdlibWhen := when
    }
}

class AhkStdlibAsyncioFuture
{
    __New(args*)
    {
        this.AhkStdlibState := "pending"
        this.AhkStdlibResult := stdlib.None
        this.AhkStdlibException := stdlib.None
        this.AhkStdlibLoop := AhkStdlibAsyncioEventLoop()
        this.AhkStdlibCancelMessage := ""
        this.AhkStdlibCallbacks := []

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

    get_loop(args*)
    {
        if args.Length != 0
            throw TypeError("Future.get_loop() takes no arguments (" args.Length " given)", -1)
        return this.AhkStdlibLoop
    }

    done(args*)
    {
        if args.Length != 0
            throw TypeError("Future.done() takes no arguments (" args.Length " given)", -1)
        return this.AhkStdlibState != "pending"
    }

    cancelled(args*)
    {
        if args.Length != 0
            throw TypeError("Future.cancelled() takes no arguments (" args.Length " given)", -1)
        return this.AhkStdlibState = "cancelled"
    }

    cancel(args*)
    {
        if args.Length > 1
            throw TypeError("cancel() takes at most 1 argument (" args.Length " given)", -1)
        if this.done()
            return false
        this.AhkStdlibState := "cancelled"
        this.AhkStdlibCancelMessage := args.Length = 0 ? "" : String(args[1])
        this.AhkStdlibScheduleCallbacks()
        return true
    }

    result(args*)
    {
        if args.Length != 0
            throw TypeError("Future.result() takes no arguments (" args.Length " given)", -1)
        if this.AhkStdlibState = "pending"
            throw AhkStdlibAsyncio.InvalidStateError("Result is not set.", -1)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibAsyncio.CancelledError(this.AhkStdlibCancelMessage, -1)
        if this.AhkStdlibState = "exception"
            throw this.AhkStdlibException
        return this.AhkStdlibResult
    }

    exception(args*)
    {
        if args.Length != 0
            throw TypeError("Future.exception() takes no arguments (" args.Length " given)", -1)
        if this.AhkStdlibState = "pending"
            throw AhkStdlibAsyncio.InvalidStateError("Exception is not set.", -1)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibAsyncio.CancelledError(this.AhkStdlibCancelMessage, -1)
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
        this.AhkStdlibScheduleCallbacks()
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
        this.AhkStdlibScheduleCallbacks()
        return stdlib.None
    }

    add_done_callback(callback)
    {
        if this.done()
            this.AhkStdlibLoop.call_soon(callback, this)
        else
            this.AhkStdlibCallbacks.Push(callback)
        return stdlib.None
    }

    remove_done_callback(callback)
    {
        removed := 0
        kept := []
        for item in this.AhkStdlibCallbacks {
            if item = callback
                removed += 1
            else
                kept.Push(item)
        }
        this.AhkStdlibCallbacks := kept
        return removed
    }

    AhkStdlibScheduleCallbacks()
    {
        callbacks := this.AhkStdlibCallbacks
        this.AhkStdlibCallbacks := []
        for callback in callbacks
            this.AhkStdlibLoop.call_soon(callback, this)
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

class AhkStdlibAsyncioTaskClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioTask(args*)
    }
}

class AhkStdlibAsyncioTask extends AhkStdlibAsyncioFuture
{
    __New(value, options?)
    {
        eventLoop := AhkStdlibAsyncioLoopFromOptions(options?)
        super.__New({ loop: eventLoop })
        if !AhkStdlibAsyncioIsStepAwaitable(value)
            throw TypeError("a coroutine was expected, got " AhkStdlibAsyncioRepr(value), -1)
        this.AhkStdlibCoro := value
        this.AhkStdlibWaitingOn := stdlib.None
        this.AhkStdlibCancelRequested := false
        this.AhkStdlibStepScheduled := false
        this.AhkStdlibLoop.AhkStdlibRegisterTask(this)
        this.AhkStdlibScheduleStep()
    }

    cancel(args*)
    {
        if args.Length > 1
            throw TypeError("cancel() takes at most 1 argument (" args.Length " given)", -1)
        if this.done()
            return false
        this.AhkStdlibCancelRequested := true
        this.AhkStdlibCancelMessage := args.Length = 0 ? "" : String(args[1])
        if !AhkStdlibIsNone(this.AhkStdlibWaitingOn) && this.AhkStdlibWaitingOn is AhkStdlibAsyncioFuture
            this.AhkStdlibWaitingOn.cancel(args*)
        this.AhkStdlibScheduleStep()
        return true
    }

    set_result(value := unset)
    {
        throw RuntimeError("Task does not support set_result operation", -1)
    }

    set_exception(value := unset)
    {
        throw RuntimeError("Task does not support set_exception operation", -1)
    }

    AhkStdlibScheduleStep(value := unset)
    {
        if this.done() || this.AhkStdlibStepScheduled
            return
        this.AhkStdlibStepScheduled := true
        if IsSet(value)
            this.AhkStdlibLoop.call_soon(ObjBindMethod(this, "AhkStdlibStep"), value)
        else
            this.AhkStdlibLoop.call_soon(ObjBindMethod(this, "AhkStdlibStep"))
    }

    AhkStdlibStep(value := unset)
    {
        this.AhkStdlibStepScheduled := false
        if this.done()
            return
        if this.AhkStdlibCancelRequested {
            this.AhkStdlibCancelNow()
            return
        }

        previousTask := this.AhkStdlibLoop.AhkStdlibCurrentTask
        this.AhkStdlibLoop.AhkStdlibCurrentTask := this
        try {
            nextValue := IsSet(value)
                ? this.AhkStdlibCoro.AhkStdlibAsyncioStep(this, value)
                : this.AhkStdlibCoro.AhkStdlibAsyncioStep(this)
        } catch StopIteration as stop {
            this.AhkStdlibSetTaskResult(stop.Message)
            return
        } catch Error as err {
            if err is AhkStdlibAsyncio.CancelledError
                this.AhkStdlibCancelNow(err.Message)
            else
                this.AhkStdlibSetTaskException(err)
            return
        } finally {
            this.AhkStdlibLoop.AhkStdlibCurrentTask := previousTask
        }

        if nextValue is AhkStdlibAsyncioFuture {
            this.AhkStdlibAwaitFuture(nextValue)
            return
        }

        this.AhkStdlibSetTaskResult(nextValue)
    }

    AhkStdlibStepThrow(err)
    {
        this.AhkStdlibStepScheduled := false
        if this.done()
            return
        if this.AhkStdlibCancelRequested {
            this.AhkStdlibCancelNow()
            return
        }

        previousTask := this.AhkStdlibLoop.AhkStdlibCurrentTask
        this.AhkStdlibLoop.AhkStdlibCurrentTask := this
        try {
            if HasMethod(this.AhkStdlibCoro, "AhkStdlibAsyncioThrow")
                nextValue := this.AhkStdlibCoro.AhkStdlibAsyncioThrow(this, err)
            else
                throw err
        } catch StopIteration as stop {
            this.AhkStdlibSetTaskResult(stop.Message)
            return
        } catch Error as thrownErr {
            if thrownErr is AhkStdlibAsyncio.CancelledError
                this.AhkStdlibCancelNow(thrownErr.Message)
            else
                this.AhkStdlibSetTaskException(thrownErr)
            return
        } finally {
            this.AhkStdlibLoop.AhkStdlibCurrentTask := previousTask
        }

        if nextValue is AhkStdlibAsyncioFuture {
            this.AhkStdlibAwaitFuture(nextValue)
            return
        }

        this.AhkStdlibSetTaskResult(nextValue)
    }

    AhkStdlibAwaitFuture(future)
    {
        if future.done() {
            this.AhkStdlibWakeFrom(future)
            return
        }
        this.AhkStdlibWaitingOn := future
        future.add_done_callback(ObjBindMethod(this, "AhkStdlibWakeFrom"))
    }

    AhkStdlibWakeFrom(future)
    {
        if this.done()
            return
        this.AhkStdlibWaitingOn := stdlib.None
        if this.AhkStdlibCancelRequested {
            this.AhkStdlibCancelNow()
            return
        }
        try {
            value := future.result()
        } catch Error as err {
            if err is AhkStdlibAsyncio.CancelledError && !HasMethod(this.AhkStdlibCoro, "AhkStdlibAsyncioThrow") {
                this.AhkStdlibCancelNow(err.Message)
                return
            }
            this.AhkStdlibStepScheduled := true
            this.AhkStdlibLoop.call_soon(ObjBindMethod(this, "AhkStdlibStepThrow"), err)
            return
        }
        this.AhkStdlibScheduleStep(value)
    }

    AhkStdlibSetTaskResult(value)
    {
        super.set_result(value)
    }

    AhkStdlibSetTaskException(err)
    {
        super.set_exception(err)
    }

    AhkStdlibCancelNow(message := unset)
    {
        if IsSet(message) && message != ""
            super.cancel(message)
        else
            super.cancel()
    }

    AhkStdlibScheduleCallbacks()
    {
        this.AhkStdlibLoop.AhkStdlibUnregisterTask(this)
        super.AhkStdlibScheduleCallbacks()
    }

    __Repr()
    {
        switch this.AhkStdlibState {
            case "pending":
                return "<Task pending>"
            case "cancelled":
                return "<Task cancelled>"
            case "result":
                return "<Task finished result=" AhkStdlibAsyncioRepr(this.AhkStdlibResult) ">"
            case "exception":
                return "<Task finished exception=" AhkStdlibAsyncioExceptionRepr(this.AhkStdlibException) ">"
            default:
                return "<Task pending>"
        }
    }
}

class AhkStdlibAsyncioCoroutineFunctionWrapper
{
    __New(func)
    {
        this.AhkStdlibFunc := func
    }

    Call(args*)
    {
        return AhkStdlibAsyncioCoroutineCallResult(this.AhkStdlibFunc, args)
    }
}

class AhkStdlibAsyncioCoroutineCallResult
{
    __New(func, args)
    {
        this.AhkStdlibFunc := func
        this.AhkStdlibArgs := args
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        result := this.AhkStdlibFunc.Call(this.AhkStdlibArgs*)
        if AhkStdlibAsyncioIsStepAwaitable(result) || result is AhkStdlibAsyncioFuture
            return result
        return result
    }
}

class AhkStdlibAsyncioToThreadAwaitable
{
    __New(func, args)
    {
        this.AhkStdlibFunc := func
        this.AhkStdlibArgs := args
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        throw stdlib.NotImplementedError("asyncio.to_thread() requires a Windows DLL worker backend for true thread offload", -1)
    }
}

stdlib.asyncio := AhkStdlibAsyncio

AhkStdlibAsyncioGetPolicy()
{
    return AhkStdlibAsyncioPolicySlot()
}

AhkStdlibAsyncioSetPolicy(policy)
{
    AhkStdlibAsyncioPolicySlot(policy)
}

AhkStdlibAsyncioPolicySlot(value := unset)
{
    static policy := AhkStdlibAsyncioEventLoopPolicy()
    if IsSet(value)
        policy := value
    return policy
}

AhkStdlibAsyncioRunningLoop()
{
    return AhkStdlibAsyncioRunningLoopSlot()
}

AhkStdlibAsyncioSetRunningLoop(eventLoop)
{
    AhkStdlibAsyncioRunningLoopSlot(eventLoop)
}

AhkStdlibAsyncioRunningLoopSlot(value := unset)
{
    static runningLoop := stdlib.None
    if IsSet(value)
        runningLoop := value
    return runningLoop
}

AhkStdlibAsyncioIsPlainKeywordObject(value)
{
    return Type(value) = "Object"
}

AhkStdlibAsyncioPriorityKey(value)
{
    if value is Array && value.Length > 0
        return value[1]
    return value
}

AhkStdlibAsyncioLoopFromOptions(options := unset)
{
    if IsSet(options) && AhkStdlibAsyncioIsPlainKeywordObject(options) && options.HasOwnProp("loop")
        return options.loop
    runningLoop := AhkStdlibAsyncioRunningLoop()
    if !AhkStdlibIsNone(runningLoop)
        return runningLoop
    return AhkStdlibAsyncioGetPolicy().get_event_loop()
}

AhkStdlibAsyncioTaskLoopFromOptions(options := unset)
{
    if IsSet(options) && AhkStdlibAsyncioIsPlainKeywordObject(options) && options.HasOwnProp("loop")
        return options.loop
    runningLoop := AhkStdlibAsyncioRunningLoop()
    if !AhkStdlibIsNone(runningLoop)
        return runningLoop
    return stdlib.None
}

AhkStdlibAsyncioOption(options, name, defaultValue)
{
    if IsSet(options) && AhkStdlibAsyncioIsPlainKeywordObject(options) && options.HasOwnProp(name)
        return options.%name%
    return defaultValue
}

AhkStdlibAsyncioShieldDone(target, source)
{
    if target.done()
        return
    try {
        target.set_result(source.result())
    } catch Error as err {
        target.set_exception(err)
    }
}

AhkStdlibAsyncioWaitForDone(target, source)
{
    if target.done()
        return
    try {
        target.set_result(source.result())
    } catch Error as err {
        target.set_exception(err)
    }
}

AhkStdlibAsyncioWaitForCallback(target)
{
    return (source) => AhkStdlibAsyncioWaitForDone(target, source)
}

AhkStdlibAsyncioWaitAllCallback(resultFuture, done, pending, remaining, expected)
{
    return (source) => AhkStdlibAsyncioWaitAllDone(resultFuture, done, pending, remaining, expected, source)
}

AhkStdlibAsyncioWaitAllDone(resultFuture, done, pending, remaining, expected, source)
{
    if resultFuture.done() || source != expected
        return
    remaining.Count -= 1
    if remaining.Count != 0
        return

    finalDone := []
    finalPending := []
    for future in done
        finalDone.Push(future)
    for future in pending {
        if future.done()
            finalDone.Push(future)
        else
            finalPending.Push(future)
    }
    resultFuture.set_result([finalDone, finalPending])
}

AhkStdlibAsyncioWaitForTimeoutCallback(target, source)
{
    return (*) => AhkStdlibAsyncioWaitForTimeout(target, source)
}

AhkStdlibAsyncioWaitForTimeout(target, source)
{
    if target.done()
        return
    source.cancel()
    target.set_exception(AhkStdlibAsyncio.TimeoutError("", -1))
}

AhkStdlibAsyncioRunCoroutineThreadsafeCallback(resultFuture, coro, eventLoop)
{
    return (*) => AhkStdlibAsyncioRunCoroutineThreadsafeStart(resultFuture, coro, eventLoop)
}

AhkStdlibAsyncioRunCoroutineThreadsafeStart(resultFuture, coro, eventLoop)
{
    if resultFuture.cancelled()
        return
    try {
        task := eventLoop.create_task(coro)
    } catch Error as err {
        if !resultFuture.done()
            resultFuture.set_exception(err)
        return
    }
    resultFuture.add_done_callback(AhkStdlibAsyncioRunCoroutineThreadsafeCancelCallback(task))
    task.add_done_callback(AhkStdlibAsyncioRunCoroutineThreadsafeDoneCallback(resultFuture))
}

AhkStdlibAsyncioRunCoroutineThreadsafeCancelCallback(task)
{
    return (source) => AhkStdlibAsyncioRunCoroutineThreadsafeCancelTask(source, task)
}

AhkStdlibAsyncioRunCoroutineThreadsafeCancelTask(source, task)
{
    if source.cancelled() && !task.done()
        task.cancel()
}

AhkStdlibAsyncioRunCoroutineThreadsafeDoneCallback(resultFuture)
{
    return (task) => AhkStdlibAsyncioRunCoroutineThreadsafeDone(resultFuture, task)
}

AhkStdlibAsyncioRunCoroutineThreadsafeDone(resultFuture, task)
{
    if resultFuture.done()
        return
    try {
        resultFuture.set_result(task.result())
    } catch Error as err {
        if err is AhkStdlibAsyncio.CancelledError
            resultFuture.cancel(err.Message)
        else
            resultFuture.set_exception(err)
    }
}

AhkStdlibAsyncioAsCompleted(eventLoop, futures)
{
    state := {
        Loop: eventLoop,
        Completed: [],
        Awaiters: [],
        DrainScheduled: false,
    }
    wrappers := []
    loop futures.Length
        wrappers.Push(AhkStdlibAsyncioAsCompletedAwaitable(state))
    for future in futures {
        if future.done()
            AhkStdlibAsyncioAsCompletedDone(state, future)
        else
            future.add_done_callback((source) => AhkStdlibAsyncioAsCompletedDone(state, source))
    }
    return wrappers
}

AhkStdlibAsyncioAsCompletedDone(state, source)
{
    state.Completed.Push(source)
    AhkStdlibAsyncioAsCompletedScheduleDrain(state)
}

AhkStdlibAsyncioAsCompletedScheduleDrain(state)
{
    if state.DrainScheduled
        return
    state.DrainScheduled := true
    state.Loop.call_soon(AhkStdlibAsyncioAsCompletedDelayDrainCallback(state))
}

AhkStdlibAsyncioAsCompletedDelayDrainCallback(state)
{
    return (*) => state.Loop.call_soon(AhkStdlibAsyncioAsCompletedDrainCallback(state))
}

AhkStdlibAsyncioAsCompletedDrainCallback(state)
{
    return (*) => AhkStdlibAsyncioAsCompletedDrain(state)
}

AhkStdlibAsyncioAsCompletedDrain(state)
{
    state.DrainScheduled := false
    while state.Completed.Length > 0 && state.Awaiters.Length > 0 {
        source := state.Completed.RemoveAt(1)
        waiter := state.Awaiters.RemoveAt(1)
        AhkStdlibAsyncioWaitForDone(waiter, source)
    }
    if state.Completed.Length > 0 && state.Awaiters.Length > 0
        AhkStdlibAsyncioAsCompletedScheduleDrain(state)
}

class AhkStdlibAsyncioAsCompletedAwaitable
{
    __New(state)
    {
        this.AhkStdlibState := state
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex = 0 {
            this.AhkStdlibStepIndex += 1
            if this.AhkStdlibState.Completed.Length > 0 {
                source := this.AhkStdlibState.Completed.RemoveAt(1)
                return source
            }
            waiter := task.get_loop().create_future()
            this.AhkStdlibState.Awaiters.Push(waiter)
            return waiter
        }
        return value
    }
}

AhkStdlibAsyncioConditionReacquireCallback(target, kind, value)
{
    return (source) => AhkStdlibAsyncioConditionCompleteAfterReacquire(target, kind, value, source)
}

AhkStdlibAsyncioConditionCompleteAfterReacquire(target, kind, value, source)
{
    try {
        source.result()
    } catch Error as err {
        target.set_exception(err)
        return
    }
    target.AhkStdlibCompleteAfterReacquire(kind, value)
}

AhkStdlibAsyncioEnsureFuture(value, eventLoop)
{
    if value is AhkStdlibAsyncioFuture
        return value
    if AhkStdlibAsyncioIsStepAwaitable(value)
        return eventLoop.create_task(value)
    if HasMethod(value, "Call") {
        future := eventLoop.create_future()
        try {
            future.set_result(value.Call())
        } catch Error as err {
            future.set_exception(err)
        }
        return future
    }
    throw TypeError("An asyncio.Future, a coroutine or an awaitable is required", -1)
}

AhkStdlibAsyncioIsStepAwaitable(value)
{
    return IsObject(value) && HasMethod(value, "AhkStdlibAsyncioStep")
}

AhkStdlibAsyncioIsCoroutineFunction(value)
{
    if !IsObject(value) || !HasMethod(value, "Call")
        return false
    try {
        result := value.Call()
    } catch {
        return false
    }
    return AhkStdlibAsyncioIsStepAwaitable(result)
}

AhkStdlibAsyncioGatherFuture(eventLoop, awaitables, resultFuture)
{
    values := []
    remaining := { Count: awaitables.Length }
    loop awaitables.Length
        values.Push(stdlib.None)

    for index, item in awaitables {
        child := AhkStdlibAsyncioEnsureFuture(item, eventLoop)
        child.add_done_callback(AhkStdlibAsyncioGatherCallback(resultFuture, values, remaining, index))
    }
    return resultFuture
}

AhkStdlibAsyncioGatherCallback(resultFuture, values, remaining, index)
{
    return (child) => AhkStdlibAsyncioGatherChildDone(resultFuture, values, remaining, index, child)
}

AhkStdlibAsyncioGatherChildDone(resultFuture, values, remaining, index, child)
{
    if resultFuture.done()
        return
    try {
        values[index] := child.result()
    } catch Error as err {
        resultFuture.set_exception(err)
        return
    }
    remaining.Count -= 1
    if remaining.Count = 0
        resultFuture.set_result(values)
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

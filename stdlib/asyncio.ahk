#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibAsyncio
{
    static FIRST_COMPLETED := "FIRST_COMPLETED"
    static FIRST_EXCEPTION := "FIRST_EXCEPTION"
    static ALL_COMPLETED := "ALL_COMPLETED"
    static base_events := AhkStdlibAsyncioPublicModule("asyncio.base_events")
    static base_futures := AhkStdlibAsyncioPublicModule("asyncio.base_futures")
    static base_subprocess := AhkStdlibAsyncioPublicModule("asyncio.base_subprocess")
    static base_tasks := AhkStdlibAsyncioPublicModule("asyncio.base_tasks")
    static constants := AhkStdlibAsyncioPublicModule("asyncio.constants")
    static coroutines := AhkStdlibAsyncioPublicModule("asyncio.coroutines")
    static events := AhkStdlibAsyncioPublicModule("asyncio.events")
    static exceptions := AhkStdlibAsyncioPublicModule("asyncio.exceptions")
    static format_helpers := AhkStdlibAsyncioPublicModule("asyncio.format_helpers")
    static futures := AhkStdlibAsyncioPublicModule("asyncio.futures")
    static locks := AhkStdlibAsyncioPublicModule("asyncio.locks")
    static log := AhkStdlibAsyncioPublicModule("asyncio.log")
    static mixins := AhkStdlibAsyncioPublicModule("asyncio.mixins")
    static proactor_events := AhkStdlibAsyncioPublicModule("asyncio.proactor_events")
    static protocols := AhkStdlibAsyncioPublicModule("asyncio.protocols")
    static queues := AhkStdlibAsyncioPublicModule("asyncio.queues")
    static runners := AhkStdlibAsyncioPublicModule("asyncio.runners")
    static selector_events := AhkStdlibAsyncioPublicModule("asyncio.selector_events")
    static sslproto := AhkStdlibAsyncioPublicModule("asyncio.sslproto")
    static staggered := AhkStdlibAsyncioPublicModule("asyncio.staggered")
    static streams := AhkStdlibAsyncioPublicModule("asyncio.streams")
    static subprocess := AhkStdlibAsyncioPublicModule("asyncio.subprocess")
    static sys := AhkStdlibAsyncioPublicModule("sys")
    static tasks := AhkStdlibAsyncioPublicModule("asyncio.tasks")
    static threads := AhkStdlibAsyncioPublicModule("asyncio.threads")
    static transports := AhkStdlibAsyncioPublicModule("asyncio.transports")
    static trsock := AhkStdlibAsyncioPublicModule("asyncio.trsock")
    static windows_events := AhkStdlibAsyncioPublicModule("asyncio.windows_events")
    static windows_utils := AhkStdlibAsyncioPublicModule("asyncio.windows_utils")

    class CancelledError extends Error
    {
    }

    class InvalidStateError extends Error
    {
    }

    class TimeoutError extends Error
    {
    }

    class IncompleteReadError extends EOFError
    {
        __New(partial, expected)
        {
            expectedText := AhkStdlibIsNone(expected) ? "undefined" : String(expected)
            message := AhkStdlibAsyncioByteLength(partial) " bytes read on a total of " expectedText " expected bytes"
            super.__New(message, -1)
            this.partial := partial
            this.expected := expected
        }
    }

    class LimitOverrunError extends Error
    {
        __New(message, consumed)
        {
            super.__New(message, -1)
            this.consumed := consumed
        }
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
    static Protocol := AhkStdlibAsyncioProtocolClass
    static DatagramProtocol := AhkStdlibAsyncioDatagramProtocolClass
    static SubprocessProtocol := AhkStdlibAsyncioSubprocessProtocolClass
    static BufferedProtocol := AhkStdlibAsyncioBufferedProtocolClass
    static BaseTransport := AhkStdlibAsyncioBaseTransportClass
    static ReadTransport := AhkStdlibAsyncioReadTransportClass
    static WriteTransport := AhkStdlibAsyncioWriteTransportClass
    static Transport := AhkStdlibAsyncioTransportClass
    static DatagramTransport := AhkStdlibAsyncioDatagramTransportClass
    static SubprocessTransport := AhkStdlibAsyncioSubprocessTransportClass
    static AbstractServer := AhkStdlibAsyncioAbstractServerClass
    static Server := AhkStdlibAsyncioServerClass
    static IocpProactor := AhkStdlibAsyncioIocpProactorClass
    static StreamReader := AhkStdlibAsyncioStreamReaderClass
    static StreamReaderProtocol := AhkStdlibAsyncioStreamReaderProtocolClass
    static StreamWriter := AhkStdlibAsyncioStreamWriterClass
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

    static open_connection(args*)
    {
        if args.Length < 2
            throw TypeError("open_connection() missing required positional arguments", -1)
        return AhkStdlibAsyncioOpenConnectionAwaitable(args)
    }

    static start_server(args*)
    {
        if args.Length < 3
            throw TypeError("start_server() missing required positional arguments", -1)
        return AhkStdlibAsyncioStartServerAwaitable(args)
    }

    static create_subprocess_exec(args*)
    {
        if args.Length < 1
            throw TypeError("create_subprocess_exec() missing 1 required positional argument: 'program'", -1)
        options := AhkStdlibAsyncioSubprocessOptionsFromArgs(&args)
        return AhkStdlibAsyncioSubprocessCreateAwaitable("exec", args, options)
    }

    static create_subprocess_shell(args*)
    {
        if args.Length < 1
            throw TypeError("create_subprocess_shell() missing 1 required positional argument: 'cmd'", -1)
        command := args[1]
        options := AhkStdlibAsyncioSubprocessOptionsFromArgs(&args)
        return AhkStdlibAsyncioSubprocessCreateAwaitable("shell", [command], options)
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
        returnExceptions := false
        if args.Length > 0 && AhkStdlibAsyncioIsPlainKeywordObject(args[args.Length]) && args[args.Length].HasOwnProp("return_exceptions") {
            options := args.RemoveAt(args.Length)
            returnExceptions := AhkStdlibTruthValue(options.return_exceptions)
        }
        if args.Length = 0 {
            resultFuture.set_result([])
            return resultFuture
        }
        return AhkStdlibAsyncioGatherFuture(eventLoop, args, resultFuture, returnExceptions)
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

class AhkStdlibAsyncioPublicModule
{
    __New(name)
    {
        this.__name := name
        if name = "asyncio.subprocess" {
            this.PIPE := -1
            this.STDOUT := -2
            this.DEVNULL := -3
        }
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
        this.AhkStdlibNetworkServers := []
        this.AhkStdlibNetworkConnections := []
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
        for server in this.AhkStdlibNetworkServers
            try server.close()
        this.AhkStdlibNetworkServers := []
        this.AhkStdlibNetworkConnections := []
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
        this.AhkStdlibPollNetwork()
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

    AhkStdlibRegisterNetworkServer(server)
    {
        this.AhkStdlibNetworkServers.Push(server)
        return stdlib.None
    }

    AhkStdlibUnregisterNetworkServer(server)
    {
        kept := []
        for item in this.AhkStdlibNetworkServers {
            if item != server
                kept.Push(item)
        }
        this.AhkStdlibNetworkServers := kept
        return stdlib.None
    }

    AhkStdlibRegisterNetworkConnection(connection)
    {
        this.AhkStdlibNetworkConnections.Push(connection)
        return stdlib.None
    }

    AhkStdlibUnregisterNetworkConnection(connection)
    {
        kept := []
        for item in this.AhkStdlibNetworkConnections {
            if item != connection
                kept.Push(item)
        }
        this.AhkStdlibNetworkConnections := kept
        return stdlib.None
    }

    AhkStdlibPollNetwork()
    {
        for server in this.AhkStdlibNetworkServers
            server.AhkStdlibPollAccept()
        for connection in this.AhkStdlibNetworkConnections
            connection.AhkStdlibPollRead()
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
    connection_made(transport)
    {
        return stdlib.None
    }

    connection_lost(exc)
    {
        return stdlib.None
    }

    pause_writing()
    {
        return stdlib.None
    }

    resume_writing()
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioProtocolClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioProtocol()
    }
}

class AhkStdlibAsyncioProtocol extends AhkStdlibAsyncioBaseProtocol
{
    data_received(data)
    {
        return stdlib.None
    }

    eof_received()
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioDatagramProtocolClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioDatagramProtocol()
    }
}

class AhkStdlibAsyncioDatagramProtocol extends AhkStdlibAsyncioBaseProtocol
{
    datagram_received(data, addr)
    {
        return stdlib.None
    }

    error_received(exc)
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioSubprocessProtocolClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioSubprocessProtocol()
    }
}

class AhkStdlibAsyncioSubprocessProtocol extends AhkStdlibAsyncioBaseProtocol
{
    pipe_data_received(fd, data)
    {
        return stdlib.None
    }

    pipe_connection_lost(fd, exc)
    {
        return stdlib.None
    }

    process_exited()
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioBufferedProtocolClass
{
    static Call(thisClass)
    {
        return AhkStdlibAsyncioBufferedProtocol()
    }
}

class AhkStdlibAsyncioBufferedProtocol extends AhkStdlibAsyncioBaseProtocol
{
    get_buffer(sizehint)
    {
        return stdlib.None
    }

    buffer_updated(nbytes)
    {
        return stdlib.None
    }

    eof_received()
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioBaseTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioBaseTransport(extra) : AhkStdlibAsyncioBaseTransport()
    }
}

class AhkStdlibAsyncioBaseTransport
{
    __New(extra := unset)
    {
        this.AhkStdlibExtra := IsSet(extra) && !AhkStdlibIsNone(extra) ? extra : stdlib.None
    }

    get_extra_info(name, defaultValue := unset)
    {
        if this.AhkStdlibExtra is Map {
            if this.AhkStdlibExtra.Has(name)
                return this.AhkStdlibExtra[name]
        } else if IsObject(this.AhkStdlibExtra) {
            if this.AhkStdlibExtra.HasOwnProp(name)
                return this.AhkStdlibExtra.%name%
        }
        return IsSet(defaultValue) ? defaultValue : stdlib.None
    }

    close()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    is_closing()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_protocol()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    set_protocol(protocol)
    {
        throw stdlib.NotImplementedError("", -1)
    }
}

class AhkStdlibAsyncioReadTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioReadTransport(extra) : AhkStdlibAsyncioReadTransport()
    }
}

class AhkStdlibAsyncioReadTransport extends AhkStdlibAsyncioBaseTransport
{
    is_reading()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    pause_reading()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    resume_reading()
    {
        throw stdlib.NotImplementedError("", -1)
    }
}

class AhkStdlibAsyncioWriteTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioWriteTransport(extra) : AhkStdlibAsyncioWriteTransport()
    }
}

class AhkStdlibAsyncioWriteTransport extends AhkStdlibAsyncioBaseTransport
{
    set_write_buffer_limits(high := unset, low := unset)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_write_buffer_size()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_write_buffer_limits()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    write(data)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    writelines(list_of_data)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    write_eof()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    can_write_eof()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    abort()
    {
        throw stdlib.NotImplementedError("", -1)
    }
}

class AhkStdlibAsyncioTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioTransport(extra) : AhkStdlibAsyncioTransport()
    }
}

class AhkStdlibAsyncioTransport extends AhkStdlibAsyncioReadTransport
{
    set_write_buffer_limits(high := unset, low := unset)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_write_buffer_size()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_write_buffer_limits()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    write(data)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    writelines(list_of_data)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    write_eof()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    can_write_eof()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    abort()
    {
        throw stdlib.NotImplementedError("", -1)
    }
}

class AhkStdlibAsyncioDatagramTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioDatagramTransport(extra) : AhkStdlibAsyncioDatagramTransport()
    }
}

class AhkStdlibAsyncioDatagramTransport extends AhkStdlibAsyncioBaseTransport
{
    sendto(data, addr := unset)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    abort()
    {
        throw stdlib.NotImplementedError("", -1)
    }
}

class AhkStdlibAsyncioSubprocessTransportClass
{
    static Call(thisClass, extra := unset)
    {
        return IsSet(extra) ? AhkStdlibAsyncioSubprocessTransport(extra) : AhkStdlibAsyncioSubprocessTransport()
    }
}

class AhkStdlibAsyncioSubprocessTransport extends AhkStdlibAsyncioBaseTransport
{
    get_pid()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_pipe_transport(fd)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_returncode()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    send_signal(signal)
    {
        throw stdlib.NotImplementedError("", -1)
    }

    terminate()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    kill()
    {
        throw stdlib.NotImplementedError("", -1)
    }
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
    close()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    get_loop()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    is_serving()
    {
        throw stdlib.NotImplementedError("", -1)
    }

    start_serving()
    {
        return AhkStdlibAsyncioFailedAwaitable(stdlib.NotImplementedError("", -1))
    }

    serve_forever()
    {
        return AhkStdlibAsyncioFailedAwaitable(stdlib.NotImplementedError("", -1))
    }

    wait_closed()
    {
        return AhkStdlibAsyncioFailedAwaitable(stdlib.NotImplementedError("", -1))
    }
}

class AhkStdlibAsyncioServerClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioServer(args*)
    }
}

class AhkStdlibAsyncioServer extends AhkStdlibAsyncioAbstractServer
{
    __New(args*)
    {
        if args.Length < 6
            throw TypeError("Server.__init__() missing required positional arguments", -1)
        if args.Length > 6
            throw TypeError("Server.__init__() takes 7 positional arguments but " (args.Length + 1) " were given", -1)
        this.AhkStdlibLoop := args[1]
        this.sockets := args[2]
        this.AhkStdlibProtocolFactory := args[3]
        this.AhkStdlibSslContext := args[4]
        this.AhkStdlibBacklog := args[5]
        this.AhkStdlibSslHandshakeTimeout := args[6]
        this.AhkStdlibServing := false
        this.AhkStdlibClosed := false
        this.AhkStdlibForeverFuture := stdlib.None
        this.AhkStdlibWaitClosedFutures := []
    }

    get_loop()
    {
        return this.AhkStdlibLoop
    }

    is_serving()
    {
        return this.AhkStdlibServing
    }

    start_serving()
    {
        future := this.AhkStdlibLoop.create_future()
        this.AhkStdlibServing := !this.AhkStdlibClosed
        future.set_result(stdlib.None)
        return future
    }

    serve_forever()
    {
        future := this.AhkStdlibLoop.create_future()
        if this.AhkStdlibClosed {
            future.cancel()
            return future
        }
        this.AhkStdlibServing := true
        this.AhkStdlibForeverFuture := future
        return future
    }

    close()
    {
        this.AhkStdlibServing := false
        this.AhkStdlibClosed := true
        if HasMethod(this.AhkStdlibLoop, "AhkStdlibUnregisterNetworkServer")
            this.AhkStdlibLoop.AhkStdlibUnregisterNetworkServer(this)
        for socketValue in this.sockets {
            if HasMethod(socketValue, "close")
                try socketValue.close()
        }
        if !AhkStdlibIsNone(this.AhkStdlibForeverFuture) && !this.AhkStdlibForeverFuture.done()
            this.AhkStdlibForeverFuture.cancel()
        this.AhkStdlibResolveWaitClosed()
        return stdlib.None
    }

    wait_closed()
    {
        future := this.AhkStdlibLoop.create_future()
        if this.AhkStdlibClosed {
            future.set_result(stdlib.None)
            return future
        }
        this.AhkStdlibWaitClosedFutures.Push(future)
        return future
    }

    AhkStdlibResolveWaitClosed()
    {
        waiters := this.AhkStdlibWaitClosedFutures
        this.AhkStdlibWaitClosedFutures := []
        for future in waiters {
            if !future.done()
                future.set_result(stdlib.None)
        }
    }

    AhkStdlibPollAccept()
    {
        return stdlib.None
    }
}

class AhkStdlibAsyncioIocpProactorClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioIocpProactor(args*)
    }
}

class AhkStdlibAsyncioIocpProactor
{
    __New(args*)
    {
        if args.Length > 1
            throw TypeError("IocpProactor.__init__() takes from 1 to 2 positional arguments but " (args.Length + 1) " were given", -1)
        this.AhkStdlibConcurrency := args.Length = 0 ? 4294967295 : Integer(args[1])
        this.AhkStdlibClosed := false
        this.AhkStdlibLoop := stdlib.None
    }

    set_loop(eventLoop)
    {
        this.AhkStdlibLoop := eventLoop
        return stdlib.None
    }

    select(timeout := unset)
    {
        if this.AhkStdlibClosed
            throw TypeError("GetQueuedCompletionStatus() argument 1 must be int, not None", -1)
        return []
    }

    accept(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.accept() is not implemented by stdlib asyncio yet", -1)
    }

    accept_pipe(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.accept_pipe() is not implemented by stdlib asyncio yet", -1)
    }

    connect(args*)
    {
        if args.Length < 2
            throw TypeError("connect() missing required positional arguments", -1)
        return AhkStdlibAsyncioIocpSocketAwaitable("connect", args)
    }

    connect_pipe(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.connect_pipe() is not implemented by stdlib asyncio yet", -1)
    }

    recv(args*)
    {
        if args.Length < 2
            throw TypeError("recv() missing required positional arguments", -1)
        return AhkStdlibAsyncioIocpSocketAwaitable("recv", args)
    }

    recv_into(args*)
    {
        if args.Length < 2
            throw TypeError("recv_into() missing required positional arguments", -1)
        return AhkStdlibAsyncioIocpSocketAwaitable("recv_into", args)
    }

    recvfrom(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.recvfrom() is not implemented by stdlib asyncio yet", -1)
    }

    send(args*)
    {
        if args.Length < 2
            throw TypeError("send() missing required positional arguments", -1)
        return AhkStdlibAsyncioIocpSocketAwaitable("send", args)
    }

    sendfile(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.sendfile() is not implemented by stdlib asyncio yet", -1)
    }

    sendto(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.sendto() is not implemented by stdlib asyncio yet", -1)
    }

    wait_for_handle(args*)
    {
        throw stdlib.NotImplementedError("asyncio.IocpProactor.wait_for_handle() is not implemented by stdlib asyncio yet", -1)
    }

    close()
    {
        this.AhkStdlibClosed := true
        return stdlib.None
    }
}

class AhkStdlibAsyncioStreamReaderClass
{
    static Call(thisClass, args*)
    {
        limit := 65536
        eventLoop := unset
        if args.Length > 2
            throw TypeError("StreamReader() takes from 0 to 2 positional arguments but " args.Length " were given", -1)
        if args.Length = 1 && AhkStdlibAsyncioIsPlainKeywordObject(args[1]) {
            options := args[1]
            for key, value in options.OwnProps() {
                switch key {
                    case "limit":
                        limit := value
                    case "loop":
                        eventLoop := value
                    default:
                        throw TypeError("'" key "' is an invalid keyword argument for StreamReader()", -1)
                }
            }
        } else {
            if args.Length >= 1
                limit := args[1]
            if args.Length >= 2
                eventLoop := args[2]
        }
        if IsSet(eventLoop)
            return AhkStdlibAsyncioStreamReader(limit, eventLoop)
        return AhkStdlibAsyncioStreamReader(limit)
    }
}

class AhkStdlibAsyncioStreamReader
{
    __New(limit := 65536, eventLoop := unset)
    {
        this.AhkStdlibLimit := Integer(limit)
        this.AhkStdlibLoop := IsSet(eventLoop) && !AhkStdlibIsNone(eventLoop)
            ? eventLoop
            : AhkStdlibAsyncioLoopFromOptions()
        this.AhkStdlibBuffer := []
        this.AhkStdlibEof := false
        this.AhkStdlibWaiter := stdlib.None
    }

    at_eof(args*)
    {
        if args.Length != 0
            throw TypeError("StreamReader.at_eof() takes no arguments (" args.Length " given)", -1)
        return this.AhkStdlibEof && this.AhkStdlibBuffer.Length = 0
    }

    feed_data(args*)
    {
        if args.Length < 1
            throw TypeError("StreamReader.feed_data() missing 1 required positional argument: 'data'", -1)
        if args.Length > 1
            throw TypeError("StreamReader.feed_data() takes 1 positional argument but " args.Length " were given", -1)
        for value in AhkStdlibAsyncioBytesToValues(args[1])
            this.AhkStdlibBuffer.Push(value)
        this.AhkStdlibWakeWaiter()
        return stdlib.None
    }

    feed_eof(args*)
    {
        if args.Length != 0
            throw TypeError("StreamReader.feed_eof() takes no arguments (" args.Length " given)", -1)
        this.AhkStdlibEof := true
        this.AhkStdlibWakeWaiter()
        return stdlib.None
    }

    read(n := -1)
    {
        n := Integer(n)
        future := this.AhkStdlibLoop.create_future()
        outcome := this.AhkStdlibReadOutcome("read", n)
        if outcome.Ready {
            this.AhkStdlibCompleteFuture(future, outcome)
            return future
        }
        return this.AhkStdlibWaitForFuture(future, { Kind: "read", N: n })
    }

    readline()
    {
        future := this.AhkStdlibLoop.create_future()
        outcome := this.AhkStdlibReadOutcome("readline")
        if outcome.Ready {
            this.AhkStdlibCompleteFuture(future, outcome)
            return future
        }
        return this.AhkStdlibWaitForFuture(future, { Kind: "readline" })
    }

    readexactly(n)
    {
        n := Integer(n)
        if n < 0
            throw ValueError("readexactly size can not be less than zero", -1)
        future := this.AhkStdlibLoop.create_future()
        outcome := this.AhkStdlibReadOutcome("readexactly", n)
        if outcome.Ready {
            this.AhkStdlibCompleteFuture(future, outcome)
            return future
        }
        return this.AhkStdlibWaitForFuture(future, { Kind: "readexactly", N: n })
    }

    readuntil(separator := unset)
    {
        separatorValues := IsSet(separator)
            ? AhkStdlibAsyncioBytesToValues(separator)
            : [10]
        if separatorValues.Length = 0
            throw ValueError("Separator should be at least one-byte string", -1)
        future := this.AhkStdlibLoop.create_future()
        outcome := this.AhkStdlibReadOutcome("readuntil", separatorValues)
        if outcome.Ready {
            this.AhkStdlibCompleteFuture(future, outcome)
            return future
        }
        return this.AhkStdlibWaitForFuture(future, { Kind: "readuntil", Separator: separatorValues })
    }

    AhkStdlibWaitForFuture(future, spec)
    {
        if !AhkStdlibIsNone(this.AhkStdlibWaiter) {
            future.set_exception(RuntimeError("read() called while another coroutine is already waiting for incoming data", -1))
            return future
        }
        spec.Future := future
        this.AhkStdlibWaiter := spec
        return future
    }

    AhkStdlibWakeWaiter()
    {
        if AhkStdlibIsNone(this.AhkStdlibWaiter)
            return
        waiter := this.AhkStdlibWaiter
        switch waiter.Kind {
            case "read":
                outcome := this.AhkStdlibReadOutcome("read", waiter.N)
            case "readline":
                outcome := this.AhkStdlibReadOutcome("readline")
            case "readexactly":
                outcome := this.AhkStdlibReadOutcome("readexactly", waiter.N)
            case "readuntil":
                outcome := this.AhkStdlibReadOutcome("readuntil", waiter.Separator)
            default:
                outcome := { Ready: false }
        }
        if !outcome.Ready
            return
        this.AhkStdlibWaiter := stdlib.None
        this.AhkStdlibCompleteFuture(waiter.Future, outcome)
    }

    AhkStdlibCompleteFuture(future, outcome)
    {
        if outcome.HasOwnProp("Exception")
            future.set_exception(outcome.Exception)
        else
            future.set_result(outcome.Result)
    }

    AhkStdlibReadOutcome(kind, value := unset)
    {
        available := this.AhkStdlibBuffer.Length
        switch kind {
            case "read":
                n := value
                if n = 0
                    return { Ready: true, Result: Buffer(0) }
                if n < 0 {
                    if this.AhkStdlibEof
                        return { Ready: true, Result: this.AhkStdlibTakeBytes(available) }
                    return { Ready: false }
                }
                if available > 0
                    return { Ready: true, Result: this.AhkStdlibTakeBytes(Min(n, available)) }
                if this.AhkStdlibEof
                    return { Ready: true, Result: Buffer(0) }
                return { Ready: false }
            case "readline":
                newlineIndex := this.AhkStdlibFindByte(10)
                if newlineIndex > 0
                    return { Ready: true, Result: this.AhkStdlibTakeBytes(newlineIndex) }
                if this.AhkStdlibEof
                    return { Ready: true, Result: this.AhkStdlibTakeBytes(available) }
                return { Ready: false }
            case "readexactly":
                n := value
                if n = 0
                    return { Ready: true, Result: Buffer(0) }
                if available >= n
                    return { Ready: true, Result: this.AhkStdlibTakeBytes(n) }
                if this.AhkStdlibEof {
                    partial := this.AhkStdlibTakeBytes(available)
                    return { Ready: true, Exception: AhkStdlibAsyncioIncompleteReadError(partial, n) }
                }
                return { Ready: false }
            case "readuntil":
                separator := value
                index := this.AhkStdlibFindSequence(separator)
                if index > 0
                    return { Ready: true, Result: this.AhkStdlibTakeBytes(index + separator.Length - 1) }
                if this.AhkStdlibEof {
                    partial := this.AhkStdlibTakeBytes(available)
                    return { Ready: true, Exception: AhkStdlibAsyncioIncompleteReadError(partial, stdlib.None) }
                }
                return { Ready: false }
        }
        return { Ready: false }
    }

    AhkStdlibFindByte(needle)
    {
        for index, value in this.AhkStdlibBuffer {
            if value = needle
                return index
        }
        return 0
    }

    AhkStdlibFindSequence(values)
    {
        if values.Length = 0
            return 0
        limit := this.AhkStdlibBuffer.Length - values.Length + 1
        if limit < 1
            return 0
        loop limit {
            start := A_Index
            matched := true
            for offset, value in values {
                if this.AhkStdlibBuffer[start + offset - 1] != value {
                    matched := false
                    break
                }
            }
            if matched
                return start
        }
        return 0
    }

    AhkStdlibTakeBytes(count)
    {
        if count <= 0
            return Buffer(0)
        values := []
        loop count
            values.Push(this.AhkStdlibBuffer.RemoveAt(1))
        return AhkStdlibAsyncioValuesToBytes(values)
    }
}

class AhkStdlibAsyncioStreamReaderProtocolClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioStreamReaderProtocol(args*)
    }
}

class AhkStdlibAsyncioStreamReaderProtocol
{
    __New(streamReader, clientConnectedCallback := unset, eventLoop := unset)
    {
        this.AhkStdlibStreamReader := streamReader
        this.AhkStdlibClientConnectedCallback := IsSet(clientConnectedCallback) ? clientConnectedCallback : stdlib.None
        this.AhkStdlibLoop := IsSet(eventLoop) && !AhkStdlibIsNone(eventLoop)
            ? eventLoop
            : AhkStdlibAsyncioLoopFromOptions()
        this.AhkStdlibTransport := stdlib.None
    }

    connection_made(transport)
    {
        this.AhkStdlibTransport := transport
        return stdlib.None
    }

    connection_lost(exc := unset)
    {
        this.AhkStdlibStreamReader.feed_eof()
        return stdlib.None
    }

    data_received(data)
    {
        return this.AhkStdlibStreamReader.feed_data(data)
    }

    eof_received()
    {
        this.AhkStdlibStreamReader.feed_eof()
        return stdlib.None
    }
}

class AhkStdlibAsyncioStreamWriterClass
{
    static Call(thisClass, args*)
    {
        return AhkStdlibAsyncioStreamWriter(args*)
    }
}

class AhkStdlibAsyncioStreamWriter
{
    __New(transport, protocol, reader, eventLoop)
    {
        this.AhkStdlibTransport := transport
        this.AhkStdlibProtocol := protocol
        this.AhkStdlibReader := reader
        this.AhkStdlibLoop := eventLoop
    }

    write(data)
    {
        return this.AhkStdlibTransport.write(data)
    }

    writelines(lines)
    {
        if HasMethod(this.AhkStdlibTransport, "writelines")
            return this.AhkStdlibTransport.writelines(lines)
        for line in lines
            this.AhkStdlibTransport.write(line)
        return stdlib.None
    }

    write_eof()
    {
        return this.AhkStdlibTransport.write_eof()
    }

    can_write_eof()
    {
        return this.AhkStdlibTransport.can_write_eof()
    }

    close()
    {
        return this.AhkStdlibTransport.close()
    }

    is_closing()
    {
        return this.AhkStdlibTransport.is_closing()
    }

    abort()
    {
        return this.AhkStdlibTransport.abort()
    }

    get_extra_info(name, defaultValue := unset)
    {
        if HasMethod(this.AhkStdlibTransport, "get_extra_info") {
            if IsSet(defaultValue)
                return this.AhkStdlibTransport.get_extra_info(name, defaultValue)
            return this.AhkStdlibTransport.get_extra_info(name)
        }
        return IsSet(defaultValue) ? defaultValue : stdlib.None
    }

    drain()
    {
        future := this.AhkStdlibLoop.create_future()
        future.set_result(stdlib.None)
        return future
    }

    wait_closed()
    {
        return this.drain()
    }
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
        if !IsObject(this.AhkStdlibFunc) || !HasMethod(this.AhkStdlibFunc, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(this.AhkStdlibFunc) "' object is not callable", -1)
        return this.AhkStdlibFunc.Call(this.AhkStdlibArgs*)
    }
}

class AhkStdlibAsyncioSubprocessCreateAwaitable
{
    __New(kind, args, options)
    {
        this.AhkStdlibKind := kind
        this.AhkStdlibArgs := args
        this.AhkStdlibOptions := options
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        if this.AhkStdlibKind = "shell"
            return AhkStdlibAsyncioCreateShellProcess(this.AhkStdlibArgs[1], this.AhkStdlibOptions)
        return AhkStdlibAsyncioCreateExecProcess(this.AhkStdlibArgs, this.AhkStdlibOptions)
    }
}

class AhkStdlibAsyncioStartServerAwaitable
{
    __New(args)
    {
        this.AhkStdlibArgs := args
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        return AhkStdlibAsyncioCreateTcpServer(eventLoop, this.AhkStdlibArgs)
    }
}

class AhkStdlibAsyncioOpenConnectionAwaitable
{
    __New(args)
    {
        this.AhkStdlibArgs := args
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        eventLoop := AhkStdlibAsyncioLoopFromOptions()
        return AhkStdlibAsyncioOpenTcpConnection(eventLoop, this.AhkStdlibArgs)
    }
}

class AhkStdlibAsyncioIocpSocketAwaitable
{
    __New(kind, args)
    {
        this.AhkStdlibKind := kind
        this.AhkStdlibArgs := args
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        socketValue := this.AhkStdlibArgs[1]
        switch this.AhkStdlibKind {
            case "connect":
                address := this.AhkStdlibArgs[2]
                AhkStdlibAsyncioSocketConnect(AhkStdlibAsyncioSocketHandleFromValue(socketValue), address[1], address[2])
                AhkStdlibAsyncioSocketSetNonBlocking(AhkStdlibAsyncioSocketHandleFromValue(socketValue))
                return socketValue
            case "send":
                data := this.AhkStdlibArgs[2]
                flags := this.AhkStdlibArgs.Length >= 3 ? Integer(this.AhkStdlibArgs[3]) : 0
                return AhkStdlibAsyncioSocketSend(AhkStdlibAsyncioSocketHandleFromValue(socketValue), data, flags)
            case "recv":
                nbytes := Integer(this.AhkStdlibArgs[2])
                flags := this.AhkStdlibArgs.Length >= 3 ? Integer(this.AhkStdlibArgs[3]) : 0
                result := AhkStdlibAsyncioSocketRecv(AhkStdlibAsyncioSocketHandleFromValue(socketValue), nbytes, flags, true)
                if AhkStdlibIsNone(result) {
                    this.AhkStdlibStepIndex -= 1
                    return AhkStdlibAsyncio.sleep(0.001)
                }
                return result
            case "recv_into":
                target := this.AhkStdlibArgs[2]
                flags := this.AhkStdlibArgs.Length >= 3 ? Integer(this.AhkStdlibArgs[3]) : 0
                result := AhkStdlibAsyncioSocketRecvInto(AhkStdlibAsyncioSocketHandleFromValue(socketValue), target, flags, true)
                if AhkStdlibIsNone(result) {
                    this.AhkStdlibStepIndex -= 1
                    return AhkStdlibAsyncio.sleep(0.001)
                }
                return result
        }
    }
}

class AhkStdlibAsyncioTcpServer extends AhkStdlibAsyncioServer
{
    __New(eventLoop, socketValue, clientConnectedCallback, backlog := 100)
    {
        super.__New(eventLoop, [socketValue], clientConnectedCallback, stdlib.None, backlog, 60.0)
        this.AhkStdlibSocketValue := socketValue
        this.AhkStdlibServing := true
        this.AhkStdlibClosed := false
        this.AhkStdlibLoop.AhkStdlibRegisterNetworkServer(this)
    }

    AhkStdlibPollAccept()
    {
        if !this.AhkStdlibServing || this.AhkStdlibClosed
            return stdlib.None
        loop 8 {
            clientHandle := AhkStdlibAsyncioSocketAccept(this.AhkStdlibSocketValue.AhkStdlibSocketHandle)
            if clientHandle = 0
                return stdlib.None
            AhkStdlibAsyncioSocketSetNonBlocking(clientHandle)
            reader := AhkStdlibAsyncioStreamReader(65536, this.AhkStdlibLoop)
            transport := AhkStdlibAsyncioSocketTransport(clientHandle, reader, this.AhkStdlibLoop)
            writer := AhkStdlibAsyncioStreamWriter(transport, stdlib.None, reader, this.AhkStdlibLoop)
            result := this.AhkStdlibProtocolFactory.Call(reader, writer)
            if AhkStdlibAsyncioIsStepAwaitable(result)
                this.AhkStdlibLoop.create_task(result)
        }
        return stdlib.None
    }
}

class AhkStdlibAsyncioSocketValue
{
    __New(handle, host, port)
    {
        this.AhkStdlibSocketHandle := handle
        this.AhkStdlibHost := host
        this.AhkStdlibPort := port
        this.AhkStdlibClosed := false
    }

    getsockname()
    {
        return [this.AhkStdlibHost, this.AhkStdlibPort]
    }

    close()
    {
        if this.AhkStdlibClosed
            return stdlib.None
        this.AhkStdlibClosed := true
        if this.AhkStdlibSocketHandle != 0 && this.AhkStdlibSocketHandle != -1
            DllCall("Ws2_32\closesocket", "Ptr", this.AhkStdlibSocketHandle, "Int")
        this.AhkStdlibSocketHandle := -1
        return stdlib.None
    }

    __Delete()
    {
        try this.close()
    }
}

class AhkStdlibAsyncioSocketTransport
{
    __New(handle, reader, eventLoop)
    {
        this.AhkStdlibSocketHandle := handle
        this.AhkStdlibReader := reader
        this.AhkStdlibLoop := eventLoop
        this.AhkStdlibClosed := false
        this.AhkStdlibLoop.AhkStdlibRegisterNetworkConnection(this)
    }

    write(data)
    {
        if this.AhkStdlibClosed
            return stdlib.None
        bytes := data is Buffer ? data : AhkStdlibAsyncioValuesToBytes(AhkStdlibAsyncioBytesToValues(data))
        if bytes.Size = 0
            return stdlib.None
        sent := DllCall("Ws2_32\send", "Ptr", this.AhkStdlibSocketHandle, "Ptr", bytes.Ptr, "Int", bytes.Size, "Int", 0, "Int")
        if sent = -1 {
            err := DllCall("Ws2_32\WSAGetLastError", "Int")
            if err != 10035
                throw OSError("[WinError " err "] socket send failed", -1)
        }
        return stdlib.None
    }

    writelines(lines)
    {
        for line in lines
            this.write(line)
        return stdlib.None
    }

    write_eof()
    {
        return stdlib.None
    }

    can_write_eof()
    {
        return true
    }

    close()
    {
        if this.AhkStdlibClosed
            return stdlib.None
        this.AhkStdlibClosed := true
        this.AhkStdlibLoop.AhkStdlibUnregisterNetworkConnection(this)
        if this.AhkStdlibSocketHandle != 0 && this.AhkStdlibSocketHandle != -1
            DllCall("Ws2_32\closesocket", "Ptr", this.AhkStdlibSocketHandle, "Int")
        this.AhkStdlibSocketHandle := -1
        this.AhkStdlibReader.feed_eof()
        return stdlib.None
    }

    is_closing()
    {
        return this.AhkStdlibClosed
    }

    abort()
    {
        return this.close()
    }

    get_extra_info(name, defaultValue := unset)
    {
        if name = "sockname"
            return AhkStdlibAsyncioSocketGetSockName(this.AhkStdlibSocketHandle)
        if name = "peername"
            return AhkStdlibAsyncioSocketGetPeerName(this.AhkStdlibSocketHandle)
        return IsSet(defaultValue) ? defaultValue : stdlib.None
    }

    AhkStdlibPollRead()
    {
        if this.AhkStdlibClosed
            return stdlib.None
        readBuffer := Buffer(4096, 0)
        received := DllCall("Ws2_32\recv", "Ptr", this.AhkStdlibSocketHandle, "Ptr", readBuffer.Ptr, "Int", readBuffer.Size, "Int", 0, "Int")
        if received > 0 {
            data := Buffer(received, 0)
            DllCall("kernel32\RtlMoveMemory", "Ptr", data.Ptr, "Ptr", readBuffer.Ptr, "Ptr", received)
            this.AhkStdlibReader.feed_data(data)
            return stdlib.None
        }
        if received = 0 {
            this.close()
            return stdlib.None
        }
        err := DllCall("Ws2_32\WSAGetLastError", "Int")
        if err != 10035
            this.close()
        return stdlib.None
    }

    __Delete()
    {
        try this.close()
    }
}

class AhkStdlibAsyncioProcess
{
    __New(processInfo)
    {
        this.AhkStdlibProcessHandle := processInfo.ProcessHandle
        this.pid := processInfo.ProcessId
        this.returncode := stdlib.None
        this.AhkStdlibStdoutPath := processInfo.HasOwnProp("StdoutPath") ? processInfo.StdoutPath : ""
        this.AhkStdlibStderrPath := processInfo.HasOwnProp("StderrPath") ? processInfo.StderrPath : ""
        this.AhkStdlibStdinWriteHandle := processInfo.HasOwnProp("StdinWriteHandle") ? processInfo.StdinWriteHandle : 0
        this.stdout := this.AhkStdlibStdoutPath != "" ? AhkStdlibAsyncioStreamReader() : stdlib.None
        this.stderr := this.AhkStdlibStderrPath != "" ? AhkStdlibAsyncioStreamReader() : stdlib.None
        this.stdin := this.AhkStdlibStdinWriteHandle ? AhkStdlibAsyncioStreamWriter(AhkStdlibAsyncioStdinPipeTransport(this), stdlib.None, stdlib.None, stdlib.None) : stdlib.None
    }

    __Delete()
    {
        if this.AhkStdlibProcessHandle
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibProcessHandle)
        if this.AhkStdlibStdinWriteHandle
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibStdinWriteHandle)
    }

    wait(args*)
    {
        if args.Length != 0
            throw TypeError("Process.wait() takes 1 positional argument but " args.Length + 1 " were given", -1)
        return AhkStdlibAsyncioProcessWaitAwaitable(this)
    }

    communicate(args*)
    {
        if args.Length > 1
            throw TypeError("Process.communicate() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        input := args.Length = 1 ? args[1] : unset
        return IsSet(input) ? AhkStdlibAsyncioProcessCommunicateAwaitable(this, input) : AhkStdlibAsyncioProcessCommunicateAwaitable(this)
    }

    send_signal(signal)
    {
        return this.AhkStdlibTerminate(1)
    }

    terminate()
    {
        return this.AhkStdlibTerminate(1)
    }

    kill()
    {
        return this.AhkStdlibTerminate(1)
    }

    AhkStdlibWait()
    {
        if !AhkStdlibIsNone(this.returncode)
            return this.returncode
        result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 0xFFFFFFFF, "UInt")
        if result != 0
            throw OSError("WaitForSingleObject failed: " A_LastError, -1)
        exitCode := 0
        if !DllCall("kernel32\GetExitCodeProcess", "Ptr", this.AhkStdlibProcessHandle, "UInt*", &exitCode, "Int")
            throw OSError("GetExitCodeProcess failed: " A_LastError, -1)
        this.returncode := exitCode
        return this.returncode
    }

    AhkStdlibTerminate(exitCode := 1)
    {
        if !AhkStdlibIsNone(this.returncode)
            throw ProcessLookupError("", -1)
        currentExitCode := 0
        if !DllCall("kernel32\GetExitCodeProcess", "Ptr", this.AhkStdlibProcessHandle, "UInt*", &currentExitCode, "Int")
            throw OSError("GetExitCodeProcess failed: " A_LastError, -1)
        if currentExitCode != 259 {
            this.returncode := currentExitCode
            throw ProcessLookupError("", -1)
        }
        if !DllCall("kernel32\TerminateProcess", "Ptr", this.AhkStdlibProcessHandle, "UInt", exitCode, "Int")
            throw OSError("TerminateProcess failed: " A_LastError, -1)
        return stdlib.None
    }

    AhkStdlibCommunicate(input := unset)
    {
        if IsSet(input)
            this.AhkStdlibWriteStdin(input)
        else
            this.AhkStdlibCloseStdin()
        this.AhkStdlibWait()
        stdoutBytes := this.AhkStdlibStdoutPath != "" ? AhkStdlibAsyncioReadFileBytes(this.AhkStdlibStdoutPath) : stdlib.None
        stderrBytes := this.AhkStdlibStderrPath != "" ? AhkStdlibAsyncioReadFileBytes(this.AhkStdlibStderrPath) : stdlib.None
        this.AhkStdlibCleanupPipeFiles()
        return [stdoutBytes, stderrBytes]
    }

    AhkStdlibWriteStdin(input)
    {
        if !this.AhkStdlibStdinWriteHandle
            throw AttributeError("'NoneType' object has no attribute 'write'", -1)
        bytes := input is Buffer ? input : AhkStdlibAsyncioValuesToBytes(AhkStdlibAsyncioBytesToValues(input))
        bytesWritten := 0
        if bytes.Size > 0 && !DllCall("kernel32\WriteFile", "Ptr", this.AhkStdlibStdinWriteHandle, "Ptr", bytes.Ptr, "UInt", bytes.Size, "UInt*", &bytesWritten, "Ptr", 0, "Int")
            throw OSError("WriteFile failed: " A_LastError, -1)
        this.AhkStdlibCloseStdin()
        return stdlib.None
    }

    AhkStdlibCloseStdin()
    {
        if this.AhkStdlibStdinWriteHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibStdinWriteHandle)
            this.AhkStdlibStdinWriteHandle := 0
        }
        return stdlib.None
    }

    AhkStdlibCleanupPipeFiles()
    {
        if this.AhkStdlibStdoutPath != "" {
            try FileDelete(this.AhkStdlibStdoutPath)
            this.AhkStdlibStdoutPath := ""
        }
        if this.AhkStdlibStderrPath != "" {
            try FileDelete(this.AhkStdlibStderrPath)
            this.AhkStdlibStderrPath := ""
        }
        return stdlib.None
    }
}

class AhkStdlibAsyncioProcessWaitAwaitable
{
    __New(process)
    {
        this.AhkStdlibProcess := process
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        return this.AhkStdlibProcess.AhkStdlibWait()
    }
}

class AhkStdlibAsyncioProcessCommunicateAwaitable
{
    __New(process, input := unset)
    {
        this.AhkStdlibProcess := process
        this.AhkStdlibHasInput := IsSet(input)
        if this.AhkStdlibHasInput
            this.AhkStdlibInput := input
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        return this.AhkStdlibHasInput
            ? this.AhkStdlibProcess.AhkStdlibCommunicate(this.AhkStdlibInput)
            : this.AhkStdlibProcess.AhkStdlibCommunicate()
    }
}

class AhkStdlibAsyncioStdinPipeTransport
{
    __New(process)
    {
        this.AhkStdlibProcess := process
        this.AhkStdlibClosing := false
    }

    write(data)
    {
        return this.AhkStdlibProcess.AhkStdlibWriteStdin(data)
    }

    writelines(lines)
    {
        for data in lines
            this.write(data)
        return stdlib.None
    }

    write_eof()
    {
        return this.AhkStdlibProcess.AhkStdlibCloseStdin()
    }

    can_write_eof()
    {
        return true
    }

    close()
    {
        this.AhkStdlibClosing := true
        return this.AhkStdlibProcess.AhkStdlibCloseStdin()
    }

    is_closing()
    {
        return this.AhkStdlibClosing
    }

    get_extra_info(name, default := stdlib.None)
    {
        return default
    }
}

class AhkStdlibAsyncioUnsupportedCoroutine
{
    __New(name)
    {
        this.AhkStdlibName := name
        this.AhkStdlibStepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.AhkStdlibStepIndex != 0
            return value
        this.AhkStdlibStepIndex += 1
        throw stdlib.NotImplementedError("asyncio." this.AhkStdlibName "() is not implemented by stdlib asyncio yet", -1)
    }
}

class AhkStdlibAsyncioFailedAwaitable
{
    __New(err)
    {
        this.AhkStdlibError := err
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        throw this.AhkStdlibError
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

AhkStdlibAsyncioSubprocessOptionsFromArgs(&args)
{
    options := { stdin: stdlib.None, stdout: stdlib.None, stderr: stdlib.None }
    if args.Length > 0 && AhkStdlibAsyncioIsPlainKeywordObject(args[args.Length]) {
        maybeOptions := args[args.Length]
        hasSubprocessOption := false
        for key in ["stdin", "stdout", "stderr"] {
            if maybeOptions.HasOwnProp(key)
                hasSubprocessOption := true
        }
        if hasSubprocessOption {
            args.RemoveAt(args.Length)
            if maybeOptions.HasOwnProp("stdin")
                options.stdin := maybeOptions.stdin
            if maybeOptions.HasOwnProp("stdout")
                options.stdout := maybeOptions.stdout
            if maybeOptions.HasOwnProp("stderr")
                options.stderr := maybeOptions.stderr
        }
    }
    return options
}

AhkStdlibAsyncioCreateShellProcess(command, options)
{
    return AhkStdlibAsyncioCreateProcess(AhkStdlibAsyncioJoinCommand([A_ComSpec, "/C", command]), options)
}

AhkStdlibAsyncioCreateExecProcess(args, options)
{
    return AhkStdlibAsyncioCreateProcess(AhkStdlibAsyncioJoinCommand(args), options)
}

AhkStdlibAsyncioCreateProcess(commandLine, options)
{
    startupSize := A_PtrSize = 8 ? 104 : 68
    processInfoSize := A_PtrSize = 8 ? 24 : 16
    startupInfo := Buffer(startupSize, 0)
    processInfo := Buffer(processInfoSize, 0)
    NumPut("UInt", startupSize, startupInfo, 0)
    stdoutFile := ""
    stderrFile := ""
    stdinDevnullFile := ""
    stdoutDevnullFile := ""
    stderrDevnullFile := ""
    stdoutPath := ""
    stderrPath := ""
    stdinReadHandle := 0
    stdinWriteHandle := 0
    inheritHandles := false

    if options.stdin = AhkStdlibAsyncio.subprocess.PIPE {
        AhkStdlibAsyncioCreatePipe(&stdinReadHandle, &stdinWriteHandle)
        inheritHandles := true
    } else if options.stdin = AhkStdlibAsyncio.subprocess.DEVNULL {
        stdinDevnullFile := FileOpen("NUL", "r", "UTF-8-RAW")
        AhkStdlibAsyncioMakeHandleInheritable(stdinDevnullFile.Handle)
        inheritHandles := true
    }

    if options.stdout = AhkStdlibAsyncio.subprocess.PIPE {
        stdoutPath := AhkStdlibAsyncioTempPath("stdout")
        stdoutFile := FileOpen(stdoutPath, "w", "UTF-8-RAW")
        AhkStdlibAsyncioMakeHandleInheritable(stdoutFile.Handle)
        inheritHandles := true
    } else if options.stdout = AhkStdlibAsyncio.subprocess.DEVNULL {
        stdoutDevnullFile := FileOpen("NUL", "w", "UTF-8-RAW")
        AhkStdlibAsyncioMakeHandleInheritable(stdoutDevnullFile.Handle)
        inheritHandles := true
    }
    if options.stderr = AhkStdlibAsyncio.subprocess.PIPE {
        stderrPath := AhkStdlibAsyncioTempPath("stderr")
        stderrFile := FileOpen(stderrPath, "w", "UTF-8-RAW")
        AhkStdlibAsyncioMakeHandleInheritable(stderrFile.Handle)
        inheritHandles := true
    } else if options.stderr = AhkStdlibAsyncio.subprocess.DEVNULL {
        stderrDevnullFile := FileOpen("NUL", "w", "UTF-8-RAW")
        AhkStdlibAsyncioMakeHandleInheritable(stderrDevnullFile.Handle)
        inheritHandles := true
    } else if options.stderr = AhkStdlibAsyncio.subprocess.STDOUT {
        inheritHandles := true
    }
    if inheritHandles {
        flagsOffset := A_PtrSize = 8 ? 60 : 44
        stdinOffset := A_PtrSize = 8 ? 80 : 56
        stdoutOffset := A_PtrSize = 8 ? 88 : 60
        stderrOffset := A_PtrSize = 8 ? 96 : 64
        stdinHandle := stdinReadHandle ? stdinReadHandle : (stdinDevnullFile != "" ? stdinDevnullFile.Handle : DllCall("kernel32\GetStdHandle", "Int", -10, "Ptr"))
        stdoutHandle := stdoutFile != "" ? stdoutFile.Handle : (stdoutDevnullFile != "" ? stdoutDevnullFile.Handle : DllCall("kernel32\GetStdHandle", "Int", -11, "Ptr"))
        stderrHandle := stderrFile != "" ? stderrFile.Handle : (stderrDevnullFile != "" ? stderrDevnullFile.Handle : (options.stderr = AhkStdlibAsyncio.subprocess.STDOUT ? stdoutHandle : DllCall("kernel32\GetStdHandle", "Int", -12, "Ptr")))
        NumPut("UInt", 0x100, startupInfo, flagsOffset)
        NumPut("Ptr", stdinHandle, startupInfo, stdinOffset)
        NumPut("Ptr", stdoutHandle, startupInfo, stdoutOffset)
        NumPut("Ptr", stderrHandle, startupInfo, stderrOffset)
    }

    ok := false
    try {
        ok := DllCall(
            "kernel32\CreateProcessW",
            "Ptr", 0,
            "Str", commandLine,
            "Ptr", 0,
            "Ptr", 0,
            "Int", inheritHandles,
            "UInt", 0x08000000,
            "Ptr", 0,
            "Str", A_WorkingDir,
            "Ptr", startupInfo,
            "Ptr", processInfo,
            "Int"
        )
    } finally {
        if stdoutFile != ""
            stdoutFile.Close()
        if stderrFile != ""
            stderrFile.Close()
        if stdinDevnullFile != ""
            stdinDevnullFile.Close()
        if stdoutDevnullFile != ""
            stdoutDevnullFile.Close()
        if stderrDevnullFile != ""
            stderrDevnullFile.Close()
        if stdinReadHandle
            DllCall("kernel32\CloseHandle", "Ptr", stdinReadHandle)
    }
    if !ok
        throw OSError("CreateProcessW failed: " A_LastError, -1)

    threadHandle := NumGet(processInfo, A_PtrSize, "Ptr")
    DllCall("kernel32\CloseHandle", "Ptr", threadHandle)
    return AhkStdlibAsyncioProcess({
        ProcessHandle: NumGet(processInfo, 0, "Ptr"),
        ProcessId: NumGet(processInfo, A_PtrSize * 2, "UInt"),
        StdoutPath: stdoutPath,
        StderrPath: stderrPath,
        StdinWriteHandle: stdinWriteHandle,
    })
}

AhkStdlibAsyncioCreatePipe(&readHandle, &writeHandle)
{
    readHandle := 0
    writeHandle := 0
    securityAttributes := Buffer(A_PtrSize = 8 ? 24 : 12, 0)
    NumPut("UInt", securityAttributes.Size, securityAttributes, 0)
    NumPut("Int", true, securityAttributes, A_PtrSize = 8 ? 16 : 8)
    if !DllCall("kernel32\CreatePipe", "Ptr*", &readHandle, "Ptr*", &writeHandle, "Ptr", securityAttributes, "UInt", 0, "Int")
        throw OSError("CreatePipe failed: " A_LastError, -1)
    if !DllCall("kernel32\SetHandleInformation", "Ptr", writeHandle, "UInt", 1, "UInt", 0, "Int")
        throw OSError("SetHandleInformation failed: " A_LastError, -1)
    return stdlib.None
}

AhkStdlibAsyncioMakeHandleInheritable(handle)
{
    if !DllCall("kernel32\SetHandleInformation", "Ptr", handle, "UInt", 1, "UInt", 1, "Int")
        throw OSError("SetHandleInformation failed: " A_LastError, -1)
    return stdlib.None
}

AhkStdlibAsyncioCreateTcpServer(eventLoop, args)
{
    callback := args[1]
    host := args[2]
    port := Integer(args[3])
    handle := AhkStdlibAsyncioSocketCreateTcp()
    try {
        AhkStdlibAsyncioSocketBind(handle, host, port)
        actual := AhkStdlibAsyncioSocketGetSockName(handle)
        AhkStdlibAsyncioSocketListen(handle, 100)
        AhkStdlibAsyncioSocketSetNonBlocking(handle)
        socketValue := AhkStdlibAsyncioSocketValue(handle, actual[1], actual[2])
        return AhkStdlibAsyncioTcpServer(eventLoop, socketValue, callback, 100)
    } catch Error as err {
        if handle != 0 && handle != -1
            DllCall("Ws2_32\closesocket", "Ptr", handle, "Int")
        throw err
    }
}

AhkStdlibAsyncioOpenTcpConnection(eventLoop, args)
{
    host := args[1]
    port := Integer(args[2])
    handle := AhkStdlibAsyncioSocketCreateTcp()
    try {
        AhkStdlibAsyncioSocketConnect(handle, host, port)
        AhkStdlibAsyncioSocketSetNonBlocking(handle)
        reader := AhkStdlibAsyncioStreamReader(65536, eventLoop)
        transport := AhkStdlibAsyncioSocketTransport(handle, reader, eventLoop)
        writer := AhkStdlibAsyncioStreamWriter(transport, stdlib.None, reader, eventLoop)
        return [reader, writer]
    } catch Error as err {
        if handle != 0 && handle != -1
            DllCall("Ws2_32\closesocket", "Ptr", handle, "Int")
        throw err
    }
}

AhkStdlibAsyncioSocketEnsureStartup()
{
    static started := false
    if started
        return stdlib.None
    started := true
    wsaData := Buffer(394 + A_PtrSize, 0)
    err := DllCall("Ws2_32\WSAStartup", "UShort", 0x0202, "Ptr", wsaData.Ptr, "Int")
    if err
        throw OSError("WSAStartup failed with error " err, -1)
    return stdlib.None
}

AhkStdlibAsyncioSocketCreateTcp()
{
    AhkStdlibAsyncioSocketEnsureStartup()
    handle := DllCall("Ws2_32\socket", "Int", 2, "Int", 1, "Int", 6, "Ptr")
    if handle = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("socket"), -1)
    return handle
}

AhkStdlibAsyncioSocketBind(handle, host, port)
{
    addr := AhkStdlibAsyncioSockaddr(host, port)
    if DllCall("Ws2_32\bind", "Ptr", handle, "Ptr", addr.Ptr, "Int", addr.Size, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("bind"), -1)
    return stdlib.None
}

AhkStdlibAsyncioSocketListen(handle, backlog)
{
    if DllCall("Ws2_32\listen", "Ptr", handle, "Int", backlog, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("listen"), -1)
    return stdlib.None
}

AhkStdlibAsyncioSocketConnect(handle, host, port)
{
    addr := AhkStdlibAsyncioSockaddr(host, port)
    if DllCall("Ws2_32\connect", "Ptr", handle, "Ptr", addr.Ptr, "Int", addr.Size, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("connect"), -1)
    return stdlib.None
}

AhkStdlibAsyncioSocketSend(handle, data, flags := 0)
{
    bytes := data is Buffer ? data : AhkStdlibAsyncioValuesToBytes(AhkStdlibAsyncioBytesToValues(data))
    if bytes.Size = 0
        return 0
    sent := DllCall("Ws2_32\send", "Ptr", handle, "Ptr", bytes.Ptr, "Int", bytes.Size, "Int", flags, "Int")
    if sent = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("send"), -1)
    return sent
}

AhkStdlibAsyncioSocketRecv(handle, nbytes, flags := 0, returnNoneOnWouldBlock := false)
{
    readBuffer := Buffer(Max(0, Integer(nbytes)), 0)
    if readBuffer.Size = 0
        return readBuffer
    received := DllCall("Ws2_32\recv", "Ptr", handle, "Ptr", readBuffer.Ptr, "Int", readBuffer.Size, "Int", flags, "Int")
    if received = -1 {
        err := DllCall("Ws2_32\WSAGetLastError", "Int")
        if returnNoneOnWouldBlock && err = 10035
            return stdlib.None
        throw OSError(AhkStdlibAsyncioSocketLastError("recv"), -1)
    }
    data := Buffer(received, 0)
    if received > 0
        DllCall("kernel32\RtlMoveMemory", "Ptr", data.Ptr, "Ptr", readBuffer.Ptr, "Ptr", received)
    return data
}

AhkStdlibAsyncioSocketRecvInto(handle, target, flags := 0, returnNoneOnWouldBlock := false)
{
    if !(target is Buffer)
        throw TypeError("recv_into() argument must be a writable bytes-like object", -1)
    if target.Size = 0
        return 0
    readBuffer := Buffer(target.Size, 0)
    received := DllCall("Ws2_32\recv", "Ptr", handle, "Ptr", readBuffer.Ptr, "Int", readBuffer.Size, "Int", flags, "Int")
    if received = -1 {
        err := DllCall("Ws2_32\WSAGetLastError", "Int")
        if returnNoneOnWouldBlock && err = 10035
            return stdlib.None
        throw OSError(AhkStdlibAsyncioSocketLastError("recv"), -1)
    }
    if received > 0
        DllCall("kernel32\RtlMoveMemory", "Ptr", target.Ptr, "Ptr", readBuffer.Ptr, "Ptr", received)
    return received
}

AhkStdlibAsyncioSocketHandleFromValue(socketValue)
{
    if HasProp(socketValue, "AhkStdlibSocketHandle")
        return socketValue.AhkStdlibSocketHandle
    if HasMethod(socketValue, "fileno")
        return socketValue.fileno()
    throw TypeError("'" AhkStdlibPythonTypeName(socketValue) "' object cannot be interpreted as a socket", -1)
}

AhkStdlibAsyncioSocketAccept(handle)
{
    client := DllCall("Ws2_32\accept", "Ptr", handle, "Ptr", 0, "Ptr", 0, "Ptr")
    if client = -1 {
        err := DllCall("Ws2_32\WSAGetLastError", "Int")
        if err = 10035
            return 0
        throw OSError("[WinError " err "] socket accept failed", -1)
    }
    return client
}

AhkStdlibAsyncioSocketSetNonBlocking(handle)
{
    mode := 1
    if DllCall("Ws2_32\ioctlsocket", "Ptr", handle, "Int", 0x8004667E, "UInt*", &mode, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("ioctlsocket"), -1)
    return stdlib.None
}

AhkStdlibAsyncioSocketGetSockName(handle)
{
    addr := Buffer(16, 0)
    addrLen := addr.Size
    if DllCall("Ws2_32\getsockname", "Ptr", handle, "Ptr", addr.Ptr, "Int*", &addrLen, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("getsockname"), -1)
    port := AhkStdlibAsyncioNtohs(NumGet(addr, 2, "UShort"))
    ip := AhkStdlibAsyncioIpFromUInt(NumGet(addr, 4, "UInt"))
    return [ip, port]
}

AhkStdlibAsyncioSocketGetPeerName(handle)
{
    addr := Buffer(16, 0)
    addrLen := addr.Size
    if DllCall("Ws2_32\getpeername", "Ptr", handle, "Ptr", addr.Ptr, "Int*", &addrLen, "Int") = -1
        throw OSError(AhkStdlibAsyncioSocketLastError("getpeername"), -1)
    port := AhkStdlibAsyncioNtohs(NumGet(addr, 2, "UShort"))
    ip := AhkStdlibAsyncioIpFromUInt(NumGet(addr, 4, "UInt"))
    return [ip, port]
}

AhkStdlibAsyncioSockaddr(host, port)
{
    addr := Buffer(16, 0)
    NumPut("UShort", 2, addr, 0)
    NumPut("UShort", AhkStdlibAsyncioHtons(port), addr, 2)
    NumPut("UInt", AhkStdlibAsyncioInetAddr(host), addr, 4)
    return addr
}

AhkStdlibAsyncioInetAddr(host)
{
    if host = "localhost"
        host := "127.0.0.1"
    value := DllCall("Ws2_32\inet_addr", "AStr", String(host), "UInt")
    if value = 0xFFFFFFFF && host != "255.255.255.255"
        throw OSError("Only IPv4 numeric hosts are implemented in this asyncio slice", -1)
    return value
}

AhkStdlibAsyncioHtons(value)
{
    return ((value & 0xff) << 8) | ((value >> 8) & 0xff)
}

AhkStdlibAsyncioNtohs(value)
{
    return AhkStdlibAsyncioHtons(value)
}

AhkStdlibAsyncioIpFromUInt(value)
{
    return (value & 0xff) "." ((value >> 8) & 0xff) "." ((value >> 16) & 0xff) "." ((value >> 24) & 0xff)
}

AhkStdlibAsyncioSocketLastError(operation)
{
    err := DllCall("Ws2_32\WSAGetLastError", "Int")
    return "[WinError " err "] socket " operation " failed"
}

AhkStdlibAsyncioTempPath(kind)
{
    return A_Temp "\stdlib-asyncio-subprocess-" kind "-" DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999) ".bin"
}

AhkStdlibAsyncioReadFileBytes(path)
{
    file := FileOpen(path, "r", "UTF-8-RAW")
    try {
        size := file.Length
        bytes := Buffer(size, 0)
        if size > 0
            file.RawRead(bytes, size)
        return bytes
    } finally {
        file.Close()
    }
}

AhkStdlibAsyncioJoinCommand(items)
{
    parts := []
    for item in items
        parts.Push(AhkStdlibAsyncioCommandArg(item))
    return AhkStdlibAsyncioJoin(parts, " ")
}

AhkStdlibAsyncioCommandArg(value)
{
    text := value ""
    if text = ""
        return "`"`""
    if !RegExMatch(text, "[\s`"]")
        return text
    return "`"" StrReplace(text, "`"", "\`"") "`""
}

AhkStdlibAsyncioJoin(values, delimiter)
{
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
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

AhkStdlibAsyncioBytesToValues(value)
{
    values := []
    if value is Buffer {
        loop value.Size
            values.Push(NumGet(value, A_Index - 1, "UChar"))
        return values
    }
    if value is Array {
        for item in value
            values.Push(Integer(item) & 0xff)
        return values
    }
    throw TypeError("a bytes-like object is required, not '" AhkStdlibPythonTypeName(value) "'", -1)
}

AhkStdlibAsyncioValuesToBytes(values)
{
    bytes := Buffer(values.Length, 0)
    for index, value in values
        NumPut("UChar", value, bytes, index - 1)
    return bytes
}

AhkStdlibAsyncioByteLength(value)
{
    if IsObject(value) {
        if HasProp(value, "Size")
            return value.Size
        if HasProp(value, "Length")
            return value.Length
    }
    if value is String
        return StrLen(value)
    return 0
}

AhkStdlibAsyncioIncompleteReadError(partial, expected)
{
    return AhkStdlibAsyncio.IncompleteReadError(partial, expected)
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

AhkStdlibAsyncioGatherFuture(eventLoop, awaitables, resultFuture, returnExceptions := false)
{
    values := []
    remaining := { Count: awaitables.Length }
    loop awaitables.Length
        values.Push(stdlib.None)

    for index, item in awaitables {
        child := AhkStdlibAsyncioEnsureFuture(item, eventLoop)
        child.add_done_callback(AhkStdlibAsyncioGatherCallback(resultFuture, values, remaining, index, returnExceptions))
    }
    return resultFuture
}

AhkStdlibAsyncioGatherCallback(resultFuture, values, remaining, index, returnExceptions)
{
    return (child) => AhkStdlibAsyncioGatherChildDone(resultFuture, values, remaining, index, returnExceptions, child)
}

AhkStdlibAsyncioGatherChildDone(resultFuture, values, remaining, index, returnExceptions, child)
{
    if resultFuture.done()
        return
    try {
        values[index] := child.result()
    } catch Error as err {
        if returnExceptions
            values[index] := err
        else {
            resultFuture.set_exception(err)
            return
        }
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

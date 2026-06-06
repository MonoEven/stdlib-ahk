#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\thread>

class StdlibThreadTest
{
    static TestThreadingPublicSurfaceAliasesAndMainThreadState()
    {
        for name in [
            "Barrier",
            "BoundedSemaphore",
            "BrokenBarrierError",
            "Channel",
            "Condition",
            "Event",
            "ExceptHookArgs",
            "Future",
            "Lock",
            "RLock",
            "Semaphore",
            "SharedMemory",
            "SharedObject",
            "TIMEOUT_MAX",
            "Thread",
            "ThreadError",
            "ThreadPool",
            "TimeoutError",
            "Timer",
            "WeakSet",
            "activeCount",
            "active_count",
            "currentThread",
            "current_channel",
            "current_shared_object",
            "current_shared_memory",
            "current_thread",
            "enumerate",
            "get_ident",
            "get_native_id",
            "getprofile",
            "gettrace",
            "local",
            "main_thread",
            "setprofile",
            "settrace",
            "stack_size"
        ]
            AhkTest.AssertTrue(HasProp(stdlib.thread, name), name)

        AhkTest.AssertSame(stdlib.thread.current_thread(), stdlib.thread.main_thread())
        AhkTest.AssertSame(stdlib.thread.current_thread(), stdlib.thread.currentThread())
        AhkTest.AssertEqual(1, stdlib.thread.active_count())
        AhkTest.AssertEqual(1, stdlib.thread.activeCount())
        AhkTest.AssertEqual(1, stdlib.thread.enumerate().Length)
        AhkTest.AssertSame(stdlib.thread.current_thread(), stdlib.thread.enumerate()[1])
        AhkTest.AssertEqual("Float", Type(stdlib.thread.TIMEOUT_MAX))
        AhkTest.AssertSame(stdlib.None, stdlib.thread.settrace(stdlib.None))
        AhkTest.AssertSame(stdlib.None, stdlib.thread.gettrace())
        AhkTest.AssertSame(stdlib.None, stdlib.thread.setprofile(stdlib.None))
        AhkTest.AssertSame(stdlib.None, stdlib.thread.getprofile())
        AhkTest.AssertEqual("Integer", Type(stdlib.thread.stack_size()))
    }

    static TestLockRLockSemaphoreAndBoundedSemaphoreCoreBehavior()
    {
        lock := stdlib.thread.Lock()
        AhkTest.AssertTrue(lock.acquire(false))
        AhkTest.AssertTrue(lock.locked())
        AhkTest.AssertFalse(lock.acquire(false))
        AhkTest.AssertSame(stdlib.None, lock.release())
        AhkTest.AssertFalse(lock.locked())
        AhkTest.RaisesMatch(RuntimeError, "^release unlocked lock$", (*) => lock.release())

        aliasLock := stdlib.thread.allocate_lock()
        AhkTest.AssertTrue(aliasLock.acquire(false))
        AhkTest.AssertTrue(aliasLock.locked())
        aliasLock.release()

        rlock := stdlib.thread.RLock()
        AhkTest.AssertTrue(rlock.acquire(false))
        AhkTest.AssertTrue(rlock.acquire(false))
        AhkTest.AssertSame(stdlib.None, rlock.release())
        AhkTest.AssertSame(stdlib.None, rlock.release())
        AhkTest.RaisesMatch(RuntimeError, "^cannot release un-acquired lock$", (*) => rlock.release())

        semaphore := stdlib.thread.Semaphore(1)
        AhkTest.AssertTrue(semaphore.acquire(false))
        AhkTest.AssertFalse(semaphore.acquire(false))
        AhkTest.AssertSame(stdlib.None, semaphore.release())
        AhkTest.AssertTrue(semaphore.acquire(false))

        bounded := stdlib.thread.BoundedSemaphore(1)
        AhkTest.AssertTrue(bounded.acquire(false))
        AhkTest.AssertSame(stdlib.None, bounded.release())
        AhkTest.RaisesMatch(ValueError, "^Semaphore released too many times$", (*) => bounded.release())
    }

    static TestConditionBarrierLocalAndTraceProfileSurface()
    {
        condition := stdlib.thread.Condition()
        AhkTest.RaisesMatch(RuntimeError, "^cannot wait on un-acquired lock$", (*) => condition.wait(0))
        AhkTest.RaisesMatch(RuntimeError, "^cannot notify on un-acquired lock$", (*) => condition.notify())
        AhkTest.AssertTrue(condition.acquire())
        AhkTest.AssertFalse(condition.wait(0))
        AhkTest.AssertSame(stdlib.None, condition.notify())
        AhkTest.AssertSame(stdlib.None, condition.notify_all())
        AhkTest.AssertSame(stdlib.None, condition.release())

        barrier := stdlib.thread.Barrier(1)
        AhkTest.AssertEqual(1, barrier.parties)
        AhkTest.AssertEqual(0, barrier.n_waiting)
        AhkTest.AssertFalse(barrier.broken)
        AhkTest.AssertEqual(0, barrier.wait(0))
        AhkTest.AssertSame(stdlib.None, barrier.reset())
        AhkTest.AssertSame(stdlib.None, barrier.abort())
        AhkTest.AssertTrue(barrier.broken)
        AhkTest.Raises(stdlib.thread.BrokenBarrierError, (*) => barrier.wait(0))

        localStore := stdlib.thread.local()
        localStore.value := 7
        AhkTest.AssertEqual(7, localStore.value)
        AhkTest.AssertEqual("AhkStdlibThreadLocal", Type(localStore))

        traceFunc := (*) => stdlib.None
        profileFunc := (*) => stdlib.None
        AhkTest.AssertSame(stdlib.None, stdlib.thread.settrace(traceFunc))
        AhkTest.AssertSame(traceFunc, stdlib.thread.gettrace())
        AhkTest.AssertSame(stdlib.None, stdlib.thread.setprofile(profileFunc))
        AhkTest.AssertSame(profileFunc, stdlib.thread.getprofile())
        AhkTest.AssertEqual(0, stdlib.thread.stack_size(0))
        AhkTest.AssertSame(stdlib.None, stdlib.thread.settrace(stdlib.None))
        AhkTest.AssertSame(stdlib.None, stdlib.thread.setprofile(stdlib.None))
    }

    static TestGetIdentCurrentThreadAndEventUseSystemThreadPrimitives()
    {
        mainTid := DllCall("kernel32\GetCurrentThreadId", "UInt")
        mainThread := stdlib.thread.current_thread()
        event := stdlib.thread.Event()

        AhkTest.AssertEqual(mainTid, stdlib.thread.get_ident())
        AhkTest.AssertEqual("MainThread", mainThread.name)
        AhkTest.AssertEqual(mainTid, mainThread.native_id)
        AhkTest.AssertFalse(event.is_set())
        AhkTest.AssertFalse(event.wait(0))
        AhkTest.AssertSame(stdlib.None, event.set())
        AhkTest.AssertTrue(event.is_set())
        AhkTest.AssertTrue(event.wait(0))
        AhkTest.AssertSame(stdlib.None, event.clear())
        AhkTest.AssertFalse(event.is_set())
    }

    static TestThreadStartsIndependentInterpreterAndMainThreadReadsResult()
    {
        mainPid := DllCall("kernel32\GetCurrentProcessId", "UInt")
        mainTid := stdlib.thread.get_ident()
        worker := stdlib.thread.Thread({
            name: "calc-worker",
            source: "thread_result := Map(`"value`", 42, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"tid`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
        })

        AhkTest.AssertFalse(worker.is_alive())
        AhkTest.AssertSame(stdlib.None, worker.start())
        AhkTest.AssertEqual("calc-worker", worker.name)
        AhkTest.AssertTrue(worker.pid > 0)
        AhkTest.AssertTrue(worker.native_id > 0)
        AhkTest.AssertNotEqual(mainPid, worker.pid)
        AhkTest.AssertNotEqual(mainTid, worker.native_id)
        AhkTest.AssertSame(stdlib.None, worker.join(2))
        AhkTest.AssertFalse(worker.is_alive())

        result := worker.result()
        AhkTest.AssertEqual(42, result["value"])
        AhkTest.AssertEqual(worker.pid, result["pid"])
        AhkTest.AssertEqual(worker.native_id, result["tid"])
        AhkTest.AssertEqual(0, worker.exitcode)
    }

    static TestResultQueuePollsCompletedWorkersOnMainThread()
    {
        queue := stdlib.thread.ResultQueue()
        worker := stdlib.thread.start({
            name: "queue-worker",
            source: "thread_result := Map(`"label`", `"queued`", `"tid`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
        })

        AhkTest.AssertSame(stdlib.None, queue.add(worker))
        AhkTest.AssertEqual(0, queue.qsize())
        AhkTest.AssertSame(stdlib.None, worker.join(2))

        completed := queue.poll()
        AhkTest.AssertEqual(1, completed.Length)
        AhkTest.AssertEqual(1, queue.qsize())
        item := queue.get_nowait()
        AhkTest.AssertSame(worker, item.thread)
        AhkTest.AssertEqual("queued", item.value["label"])
        AhkTest.AssertEqual(worker.native_id, item.native_id)
        AhkTest.Raises(stdlib.thread.Empty, (*) => queue.get_nowait())
    }

    static TestChannelPassesJsonMessagesBetweenMainAndWorker()
    {
        channel := stdlib.thread.Channel()
        worker := stdlib.thread.Thread({
            name: "channel-worker",
            channel: channel,
            source: "channel := stdlib.thread.current_channel()`n"
                . "incoming := channel.recv_worker(2)`n"
                . "channel.send_worker(Map(`"reply`", incoming[`"value`"] + 1, `"label`", incoming[`"label`"]))`n"
                . "finish := channel.recv_worker(2)`n"
                . "thread_result := Map(`"finished`", finish[`"done`"])"
        })

        worker.start()
        channel.send(Map("value", 10, "label", "safe-json"))
        reply := channel.recv(2)
        AhkTest.AssertEqual(11, reply["reply"])
        AhkTest.AssertEqual("safe-json", reply["label"])
        channel.send(Map("done", true))
        worker.join(2)
        result := worker.result()
        AhkTest.AssertTrue(result["finished"])
        channel.close()
    }

    static TestChannelRecvRetriesTransientJsonFileLocks()
    {
        channel := stdlib.thread.Channel()
        handle := 0
        release := (*) => (
            handle ? (DllCall("kernel32\CloseHandle", "Ptr", handle), handle := 0) : 0
        )
        try {
            channel.send_worker(Map("value", 42))
            path := StdlibThreadTest.FirstJsonFile(channel.AhkStdlibWorkerToMain)
            AhkTest.AssertTrue(path != "")
            handle := DllCall("kernel32\CreateFileW", "Str", path, "UInt", 0x80000000, "UInt", 0, "Ptr", 0, "UInt", 3, "UInt", 0x80, "Ptr", 0, "Ptr")
            AhkTest.AssertTrue(handle != 0 && handle != -1)
            SetTimer release, -80
            reply := channel.recv(2)
            AhkTest.AssertEqual(42, reply["value"])
        } finally {
            SetTimer release, 0
            if handle
                DllCall("kernel32\CloseHandle", "Ptr", handle)
            channel.close()
        }
    }

    static TestChannelFirstJsonFileUsesStringOrderingForHyphenatedNames()
    {
        temp := AhkTest.TempDir()
        try {
            DirCreate temp.Path "\queue"
            FileAppend "{}", temp.Path "\queue\000000000002-61404-123688343-610733.json", "UTF-8"
            FileAppend "{}", temp.Path "\queue\000000000001-61404-123688343-610733.json", "UTF-8"

            path := AhkStdlibThreadFirstJsonFile(temp.Path "\queue")
            SplitPath path, &name
            AhkTest.AssertEqual("000000000001-61404-123688343-610733.json", name)
        } finally {
            temp.Cleanup()
        }
    }

    static TestSharedMemoryProvidesBoundedByteAndJsonAccessAcrossHandles()
    {
        memory := stdlib.thread.SharedMemory({ size: 64 })
        reopened := stdlib.thread.SharedMemory({ name: memory.name, size: 64 })
        try {
            AhkTest.AssertEqual(64, memory.size)
            AhkTest.AssertTrue(StrLen(memory.name) > 0)
            AhkTest.AssertEqual("00000000", StdlibThreadTest.BufferHex(memory.read(0, 4)))

            memory.write("abcd", 0)
            AhkTest.AssertEqual("abcd", reopened.read_text(0, 4))
            reopened.write("WXYZ", 4)
            AhkTest.AssertEqual("WXYZ", memory.read_text(4, 4))

            memory.write_json(Map("value", 21, "label", "shared"), 8, 40)
            data := reopened.read_json(8, 40)
            AhkTest.AssertEqual(21, data["value"])
            AhkTest.AssertEqual("shared", data["label"])

            AhkTest.RaisesMatch(ValueError, "^shared memory access out of bounds$", (*) => memory.read(63, 2))
            AhkTest.RaisesMatch(ValueError, "^shared memory access out of bounds$", (*) => memory.write("xx", 63))
        } finally {
            reopened.close()
            memory.close()
        }
    }

    static TestSharedMemoryIsAccessibleFromWorkerWithoutSharingAhkObjects()
    {
        channel := stdlib.thread.Channel()
        memory := stdlib.thread.SharedMemory({ size: 128 })
        worker := stdlib.thread.Thread({
            name: "shared-memory-worker",
            channel: channel,
            shared_memory: memory,
            source: "memory := stdlib.thread.current_shared_memory()`n"
                . "incoming := memory.read_text(0, 4)`n"
                . "memory.write(`"WXYZ`", 4)`n"
                . "memory.write_json(Map(`"worker`", incoming, `"ok`", true), 16, 64)`n"
                . "stdlib.thread.current_channel().send_worker(Map(`"seen`", incoming, `"name`", memory.name, `"size`", memory.size))`n"
                . "thread_result := Map(`"done`", true)"
        })

        try {
            memory.write("abcd", 0)
            worker.start()
            reply := channel.recv(2)
            worker.join(2)
            result := worker.result()
            payload := memory.read_json(16, 64)

            AhkTest.AssertEqual("abcd", reply["seen"])
            AhkTest.AssertEqual(memory.name, reply["name"])
            AhkTest.AssertEqual(memory.size, reply["size"])
            AhkTest.AssertEqual("WXYZ", memory.read_text(4, 4))
            AhkTest.AssertEqual("abcd", payload["worker"])
            AhkTest.AssertTrue(payload["ok"])
            AhkTest.AssertTrue(result["done"])
        } finally {
            channel.close()
            memory.close()
        }
    }

    static TestSharedMemoryNamedMutexCoordinatesWorkerAccess()
    {
        channel := stdlib.thread.Channel()
        memory := stdlib.thread.SharedMemory({ size: 128 })
        lock := memory.lock()
        worker := stdlib.thread.Thread({
            name: "shared-memory-lock-worker",
            channel: channel,
            shared_memory: memory,
            source: "memory := stdlib.thread.current_shared_memory()`n"
                . "lock := memory.lock()`n"
                . "first := lock.acquire(false)`n"
                . "if first`n"
                . "    lock.release()`n"
                . "stdlib.thread.current_channel().send_worker(Map(`"first_acquire`", first))`n"
                . "stdlib.thread.current_channel().recv_worker(2)`n"
                . "memory.synchronized((shared) => shared.write_json(Map(`"safe`", true), 0, 64), 2)`n"
                . "stdlib.thread.current_channel().send_worker(Map(`"second_done`", true))`n"
                . "thread_result := Map(`"done`", true)"
        })

        try {
            AhkTest.AssertTrue(lock.acquire(false))
            worker.start()
            first := channel.recv(2)
            AhkTest.AssertFalse(first["first_acquire"])
            AhkTest.AssertSame(stdlib.None, lock.release())
            channel.send(Map("continue", true))
            second := channel.recv(2)
            AhkTest.AssertTrue(second["second_done"])
            worker.join(2)
            result := worker.result()
            payload := memory.read_json(0, 64)
            AhkTest.AssertTrue(result["done"])
            AhkTest.AssertTrue(payload["safe"])
        } finally {
            channel.close()
            lock.close()
            memory.close()
        }
    }

    static TestSharedMemoryExposesBoundedRawPointerAndTypedAccess()
    {
        channel := stdlib.thread.Channel()
        memory := stdlib.thread.SharedMemory({ size: 64 })
        worker := stdlib.thread.Thread({
            name: "shared-memory-raw-worker",
            channel: channel,
            shared_memory: memory,
            source: "memory := stdlib.thread.current_shared_memory()`n"
                . "workerAddress := memory.address`n"
                . "memory.synchronized((shared) => (`n"
                . "    shared.put(0x11223344, 4, `"UInt`"),`n"
                . "    shared.put(-123, 12, `"Int`"),`n"
                . "    shared.put(0x55, 20, `"UChar`")`n"
                . "), 2)`n"
                . "stdlib.thread.current_channel().send_worker(Map(`"address_type`", Type(workerAddress), `"u32`", memory.get(4, `"UInt`"), `"signed`", memory.get(12, `"Int`"), `"byte`", memory.get(20, `"UChar`")))`n"
                . "thread_result := Map(`"ptr`", workerAddress)"
        })

        try {
            AhkTest.AssertEqual("Integer", Type(memory.address))
            AhkTest.AssertEqual(memory.address, memory.ptr())
            memory.put(0xAABBCCDD, 0, "UInt")
            AhkTest.AssertEqual(0xAABBCCDD, memory.get(0, "UInt"))
            AhkTest.RaisesMatch(ValueError, "^shared memory access out of bounds$", (*) => memory.put(1, 63, "UShort"))
            AhkTest.RaisesMatch(ValueError, "^shared memory access out of bounds$", (*) => memory.get(63, "UShort"))

            worker.start()
            reply := channel.recv(2)
            worker.join(2)
            result := worker.result()

            AhkTest.AssertEqual("Integer", reply["address_type"])
            AhkTest.AssertEqual(0x11223344, reply["u32"])
            AhkTest.AssertEqual(-123, reply["signed"])
            AhkTest.AssertEqual(0x55, reply["byte"])
            AhkTest.AssertEqual(0x11223344, memory.get(4, "UInt"))
            AhkTest.AssertEqual(-123, memory.get(12, "Int"))
            AhkTest.AssertEqual(0x55, memory.get(20, "UChar"))
            AhkTest.AssertEqual("Integer", Type(result["ptr"]))
        } finally {
            channel.close()
            memory.close()
        }
    }

    static TestSharedObjectProxySerializesWorkerMutationsThroughMainBroker()
    {
        shared := stdlib.thread.SharedObject(Map("count", 0, "items", []))
        workerSource := "
        (
state := stdlib.thread.current_shared_object(`"state`")
state.acquire(true, 2)
try {
    loop 25
        state.append(`"items`", A_Args.Length ? A_Args[1] : `"worker`")
    before := state.get(`"count`")
    state.set(`"count`", before + 1)
    thread_result := Map(`"count`", state.get(`"count`"), `"items_length`", state.len(`"items`"))
} finally {
    state.release()
}
        )"
        left := stdlib.thread.Thread({
            name: "shared-object-left",
            shared_objects: Map("state", shared),
            source: StrReplace(workerSource, "A_Args.Length ? A_Args[1] : `"worker`"", "`"left`"")
        })
        right := stdlib.thread.Thread({
            name: "shared-object-right",
            shared_objects: Map("state", shared),
            source: StrReplace(workerSource, "A_Args.Length ? A_Args[1] : `"worker`"", "`"right`"")
        })

        left.start()
        right.start()
        left.join(3)
        right.join(3)

        leftResult := left.result()
        rightResult := right.result()
        snapshot := shared.snapshot()

        AhkTest.AssertEqual(2, snapshot["count"])
        AhkTest.AssertEqual(50, snapshot["items"].Length)
        AhkTest.AssertTrue(
            (leftResult["count"] = 1 && rightResult["count"] = 2)
            || (leftResult["count"] = 2 && rightResult["count"] = 1),
            "worker result counts should reflect serialized shared-object mutation"
        )
        AhkTest.AssertTrue(leftResult["items_length"] = 25 || leftResult["items_length"] = 50)
        AhkTest.AssertTrue(rightResult["items_length"] = 25 || rightResult["items_length"] = 50)
    }

    static TestSharedObjectBrokerDoesNotUsePublicThreadNameAsIdentity()
    {
        shared := stdlib.thread.SharedObject(Map("count", 0, "items", []))
        source := "
        (
state := stdlib.thread.current_shared_object(`"state`")
state.acquire(true, 2)
try {
    state.append(`"items`", `"same-name`")
    state.set(`"count`", state.get(`"count`") + 1)
    thread_result := Map(`"count`", state.get(`"count`"))
} finally {
    state.release()
}
        )"
        left := stdlib.thread.Thread({ name: "same-name", shared_objects: Map("state", shared), source: source })
        right := stdlib.thread.Thread({ name: "same-name", shared_objects: Map("state", shared), source: source })

        left.start()
        right.start()
        left.join(3)
        right.join(3)

        leftResult := left.result()
        rightResult := right.result()
        snapshot := shared.snapshot()

        AhkTest.AssertEqual("same-name", left.name)
        AhkTest.AssertEqual("same-name", right.name)
        AhkTest.AssertEqual(2, snapshot["count"])
        AhkTest.AssertEqual(2, snapshot["items"].Length)
        AhkTest.AssertTrue(leftResult["count"] >= 1)
        AhkTest.AssertTrue(rightResult["count"] >= 1)
    }

    static TestSharedObjectBrokerPumpsOtherWorkersWhileJoiningOneThread()
    {
        shared := stdlib.thread.SharedObject(Map("count", 0))
        holderChannel := stdlib.thread.Channel()
        holder := stdlib.thread.Thread({
            name: "shared-object-holder",
            channel: holderChannel,
            shared_objects: Map("state", shared),
            source: "state := stdlib.thread.current_shared_object(`"state`")`n"
                . "state.acquire(true, 2)`n"
                . "stdlib.thread.current_channel().send_worker(Map(`"holding`", true))`n"
                . "stdlib.thread.current_channel().recv_worker(2)`n"
                . "state.set(`"count`", state.get(`"count`") + 1)`n"
                . "state.release()`n"
                . "thread_result := Map(`"holder`", true)"
        })
        waiter := stdlib.thread.Thread({
            name: "shared-object-waiter",
            shared_objects: Map("state", shared),
            source: "state := stdlib.thread.current_shared_object(`"state`")`n"
                . "state.acquire(true, 2)`n"
                . "try {`n"
                . "    state.set(`"count`", state.get(`"count`") + 10)`n"
                . "    thread_result := Map(`"waiter`", true)`n"
                . "} finally {`n"
                . "    state.release()`n"
                . "}"
        })

        try {
            holder.start()
            ready := StdlibThreadTest.WaitForChannelMessage(holder, holderChannel, 2)
            AhkTest.AssertTrue(ready["holding"])

            waiter.start()
            holderChannel.send(Map("continue", true))
            waiter.join(3)
            holder.join(3)

            waiterResult := waiter.result()
            holderResult := holder.result()
            snapshot := shared.snapshot()

            AhkTest.AssertTrue(waiterResult["waiter"])
            AhkTest.AssertTrue(holderResult["holder"])
            AhkTest.AssertEqual(11, snapshot["count"])
        } finally {
            holderChannel.close()
        }
    }

    static TestThreadPoolQueuesTasksAndFutureResultTimeoutLikePython310()
    {
        pool := stdlib.thread.ThreadPool({ max_workers: 1, thread_name_prefix: "pool" })
        gate := stdlib.thread.Channel()
        try {
            first := pool.submit({
                name: "pool-first",
                channel: gate,
                source: "channel := stdlib.thread.current_channel()`n"
                    . "channel.send_worker(Map(`"started`", true))`n"
                    . "channel.recv_worker(2)`n"
                    . "thread_result := `"first`""
            })
            ready := gate.recv(2)
            AhkTest.AssertTrue(ready["started"])

            second := pool.submit({ name: "pool-second", source: "thread_result := `"second`"" })
            queuedCancel := pool.submit({ name: "pool-cancel", source: "thread_result := `"cancelled`"" })

            AhkTest.AssertFalse(second.done())
            AhkTest.Raises(stdlib.thread.TimeoutError, (*) => second.result(0.01))
            AhkTest.AssertTrue(queuedCancel.cancel())
            AhkTest.AssertTrue(queuedCancel.cancelled())
            AhkTest.AssertTrue(queuedCancel.done())

            gate.send(Map("continue", true))
            AhkTest.AssertEqual("first", first.result(2))
            AhkTest.AssertEqual("second", stdlib.await(second, { timeout: 2 }))
            AhkTest.AssertTrue(first.done())
            AhkTest.AssertTrue(second.done())

            AhkTest.AssertSame(stdlib.None, pool.shutdown())
            AhkTest.RaisesMatch(RuntimeError, "^cannot schedule new futures after shutdown$", (*) => pool.submit({ source: "thread_result := 1" }))
        } finally {
            gate.close()
            try pool.shutdown()
        }
    }

    static TestThreadPoolFutureRunningAndDoneCallbacksMatchPython310()
    {
        manualEvents := []
        manual := stdlib.thread.Future()
        AhkTest.AssertFalse(manual.done())
        AhkTest.AssertFalse(manual.running())

        manual.add_done_callback((future) => manualEvents.Push({
            label: "manual-first",
            done: future.done(),
            running: future.running(),
            result: future.result()
        }))
        manual.add_done_callback((future) => manualEvents.Push({
            label: "manual-second",
            done: future.done(),
            running: future.running(),
            result: future.result()
        }))
        manual.set_result("manual-value")
        manual.add_done_callback((future) => manualEvents.Push({
            label: "manual-late",
            done: future.done(),
            running: future.running(),
            result: future.result()
        }))

        AhkTest.AssertEqual(3, manualEvents.Length)
        AhkTest.AssertEqual("manual-first", manualEvents[1].label)
        AhkTest.AssertEqual("manual-second", manualEvents[2].label)
        AhkTest.AssertEqual("manual-late", manualEvents[3].label)
        AhkTest.AssertTrue(manualEvents[1].done)
        AhkTest.AssertFalse(manualEvents[1].running)
        AhkTest.AssertEqual("manual-value", manualEvents[1].result)

        pool := stdlib.thread.ThreadPool({ max_workers: 1, thread_name_prefix: "pool-callback" })
        gate := stdlib.thread.Channel()
        callbackEvents := []
        cancelEvents := []
        try {
            first := pool.submit({
                name: "callback-first",
                channel: gate,
                source: "channel := stdlib.thread.current_channel()`n"
                    . "channel.send_worker(Map(`"started`", true))`n"
                    . "channel.recv_worker(2)`n"
                    . "thread_result := `"first`""
            })
            gate.recv(2)
            second := pool.submit({ name: "callback-second", source: "thread_result := `"second`"" })
            queuedCancel := pool.submit({ name: "callback-cancel", source: "thread_result := `"cancelled`"" })

            AhkTest.AssertTrue(first.running())
            AhkTest.AssertFalse(second.running())
            AhkTest.AssertFalse(second.done())

            second.add_done_callback((future) => callbackEvents.Push({
                label: "second",
                done: future.done(),
                running: future.running(),
                result: future.result()
            }))
            queuedCancel.add_done_callback((future) => cancelEvents.Push({
                done: future.done(),
                running: future.running(),
                cancelled: future.cancelled()
            }))

            AhkTest.AssertTrue(queuedCancel.cancel())
            AhkTest.AssertEqual(1, cancelEvents.Length)
            AhkTest.AssertTrue(cancelEvents[1].done)
            AhkTest.AssertFalse(cancelEvents[1].running)
            AhkTest.AssertTrue(cancelEvents[1].cancelled)

            gate.send(Map("continue", true))
            AhkTest.AssertEqual("first", first.result(2))
            AhkTest.AssertEqual("second", second.result(2))
            AhkTest.AssertEqual(1, callbackEvents.Length)
            AhkTest.AssertEqual("second", callbackEvents[1].label)
            AhkTest.AssertTrue(callbackEvents[1].done)
            AhkTest.AssertFalse(callbackEvents[1].running)
            AhkTest.AssertEqual("second", callbackEvents[1].result)

            first.add_done_callback((future) => callbackEvents.Push({
                label: "first-late",
                result: future.result(),
                running: future.running()
            }))
            AhkTest.AssertEqual(2, callbackEvents.Length)
            AhkTest.AssertEqual("first-late", callbackEvents[2].label)
            AhkTest.AssertFalse(callbackEvents[2].running)
        } finally {
            gate.close()
            try pool.shutdown()
        }
    }

    static TestThreadPoolMapReturnsResultsInInputOrderLikePython310()
    {
        pool := stdlib.thread.ThreadPool({ max_workers: 2, thread_name_prefix: "pool-map" })
        try {
            results := pool.map((value) => { source: "thread_result := " (value * 10) }, [3, 1, 2])
            AhkTest.AssertEqual([30, 10, 20], results)
        } finally {
            pool.shutdown()
        }
    }

    static TestThreadPoolPersistentWorkerSourceReusesWorkerIdentityLikePython310()
    {
        pool := stdlib.thread.ThreadPool({
            max_workers: 1,
            thread_name_prefix: "pool-reuse",
            worker_source: "AhkStdlibThreadPoolHandleTask(task) {`n"
                . "    return Map(`"label`", task[`"label`"], `"value`", task[`"value`"] * 10, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))`n"
                . "}"
        })
        try {
            first := pool.submit({ task: Map("label", "first", "value", 1) }).result(2)
            second := pool.submit({ task: Map("label", "second", "value", 2) }).result(2)
            third := pool.map((value) => { task: Map("label", "map", "value", value) }, [3])[1]

            AhkTest.AssertEqual("first", first["label"])
            AhkTest.AssertEqual(10, first["value"])
            AhkTest.AssertEqual("second", second["label"])
            AhkTest.AssertEqual(20, second["value"])
            AhkTest.AssertEqual("map", third["label"])
            AhkTest.AssertEqual(30, third["value"])
            AhkTest.AssertEqual(first["pid"], second["pid"])
            AhkTest.AssertEqual(first["pid"], third["pid"])
            AhkTest.AssertEqual(first["native_id"], second["native_id"])
            AhkTest.AssertEqual(first["native_id"], third["native_id"])
        } finally {
            pool.shutdown()
        }
    }

    static TestThreadPoolShutdownWaitFalseLetsRunningPersistentTaskCompleteLikePython310()
    {
        pool := stdlib.thread.ThreadPool({
            max_workers: 1,
            thread_name_prefix: "pool-shutdown",
            worker_source: "AhkStdlibThreadPoolHandleTask(task) {`n"
                . "    Sleep 100`n"
                . "    return Map(`"label`", task[`"label`"], `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))`n"
                . "}"
        })

        future := pool.submit({ task: Map("label", "done") })
        AhkTest.AssertTrue(future.running())
        AhkTest.AssertSame(stdlib.None, pool.shutdown(false))
        AhkTest.AssertFalse(future.done())

        result := future.result(2)
        AhkTest.AssertEqual("done", result["label"])
        AhkTest.AssertTrue(future.done())
        AhkTest.AssertFalse(future.running())
    }

    static TestThreadPoolFuturePropagatesWorkerExceptions()
    {
        pool := stdlib.thread.ThreadPool({ max_workers: 1 })
        try {
            future := pool.submit({ source: "throw ValueError(`"pool boom`", -1)" })

            AhkTest.RaisesMatch(ValueError, "^pool boom$", (*) => future.result(2))
            err := future.exception()
            AhkTest.AssertEqual("ValueError", Type(err))
            AhkTest.AssertEqual("pool boom", err.Message)
            StdlibThreadTest.AssertNoWorkerWarning(future.AhkStdlibWorker, "pool exception worker")
            AhkTest.AssertTrue(future.done())
            AhkTest.AssertFalse(future.cancelled())
        } finally {
            pool.shutdown()
        }
    }

    static TestThreadPropagatesWorkerExceptionFromResultQueue()
    {
        worker := stdlib.thread.start({
            name: "failing-worker",
            source: "throw RuntimeError(`"worker boom`", -1)"
        })

        worker.join(2)

        AhkTest.RaisesMatch(RuntimeError, "^worker boom$", (*) => worker.result())
        StdlibThreadTest.AssertNoWorkerWarning(worker, "thread exception worker")
        AhkTest.AssertTrue(worker.exitcode != 0)
    }

    static TestThreadLifecycleErrorsMatchPythonStyleSurface()
    {
        worker := stdlib.thread.Thread("thread_result := 1")

        AhkTest.RaisesMatch(RuntimeError, "^cannot join thread before it is started$", (*) => worker.join())
        AhkTest.RaisesMatch(RuntimeError, "^thread result is not ready$", (*) => worker.result())
        worker.start()
        AhkTest.RaisesMatch(RuntimeError, "^threads can only be started once$", (*) => worker.start())
        worker.join(2)
        AhkTest.AssertEqual(1, worker.result())
    }

    static TestThreadObjectMethodAliasesEventAliasAndConditionWaitFor()
    {
        worker := stdlib.thread.Thread({ name: "object-worker", source: "thread_result := stdlib.json.Null" })
        AhkTest.AssertEqual("object-worker", worker.getName())
        AhkTest.AssertSame(stdlib.None, worker.setName("renamed-worker"))
        AhkTest.AssertEqual("renamed-worker", worker.name)
        AhkTest.AssertFalse(worker.isDaemon())
        AhkTest.AssertSame(stdlib.None, worker.setDaemon(true))
        AhkTest.AssertTrue(worker.daemon)
        AhkTest.AssertSame(stdlib.None, worker.run())

        event := stdlib.thread.Event()
        AhkTest.AssertFalse(event.isSet())
        event.set()
        AhkTest.AssertTrue(event.isSet())

        condition := stdlib.thread.Condition()
        condition.acquire()
        try {
            AhkTest.AssertTrue(condition.wait_for((*) => true, 0))
            AhkTest.AssertFalse(condition.wait_for((*) => false, 0))
        } finally {
            condition.release()
        }

        timerEvents := []
        timer := stdlib.thread.Timer(10, (*) => timerEvents.Push("late"))
        AhkTest.AssertSame(stdlib.None, timer.cancel())
        AhkTest.AssertFalse(timer.is_alive())
        AhkTest.AssertEqual(0, timerEvents.Length)

        runEvents := []
        runTimer := stdlib.thread.Timer(0, (value) => runEvents.Push(value), ["run-fired"])
        AhkTest.AssertSame(stdlib.None, runTimer.run())
        AhkTest.AssertEqual(["run-fired"], runEvents)
    }

    static TestThreadProcessSourceTimerExceptHookArgsAndWeakSetSurface()
    {
        worker := stdlib.thread.Thread({
            name: "source-worker",
            source: "thread_result := Map(`"sum`", 2 + 3, `"label`", `"ok`")",
            daemon: true
        })

        AhkTest.AssertEqual("source-worker", worker.name)
        AhkTest.AssertTrue(worker.daemon)
        AhkTest.AssertSame(stdlib.None, worker.start())
        AhkTest.AssertSame(stdlib.None, worker.join(2))
        sourceResult := worker.result()
        AhkTest.AssertEqual(5, sourceResult["sum"])
        AhkTest.AssertEqual("ok", sourceResult["label"])

        timerEvents := []
        timer := stdlib.thread.Timer(0, (value) => timerEvents.Push(value), ["timer-fired"])
        AhkTest.AssertFalse(timer.is_alive())
        AhkTest.AssertSame(stdlib.None, timer.start())
        AhkTest.AssertSame(stdlib.None, timer.join(1))
        AhkTest.AssertEqual(["timer-fired"], timerEvents)
        AhkTest.AssertFalse(timer.is_alive())

        hookArgs := stdlib.thread.ExceptHookArgs([RuntimeError, RuntimeError("boom", -1), stdlib.None, worker])
        AhkTest.AssertEqual(4, hookArgs.Length)
        AhkTest.AssertSame(RuntimeError, hookArgs.exc_type)
        AhkTest.AssertEqual("boom", hookArgs.exc_value.Message)
        AhkTest.AssertSame(worker, hookArgs.thread)

        weakSet := stdlib.thread.WeakSet()
        AhkTest.AssertEqual(0, weakSet.__len__())
        weakSet.add(worker)
        AhkTest.AssertEqual(1, weakSet.__len__())
        AhkTest.AssertTrue(weakSet.contains(worker))
        weakSet.discard(worker)
        AhkTest.AssertEqual(0, weakSet.__len__())
    }

    static TestThreadWorkerSuppressesTrayAndCapturesLoadErrors()
    {
        worker := stdlib.thread.Thread({
            name: "parse-failure-worker",
            source: "this is not valid AutoHotkey syntax !!!"
        })

        worker.start()
        generatedScript := FileRead(worker.AhkStdlibScriptPath, "UTF-8")
        AhkTest.AssertTrue(InStr(generatedScript, "#NoTrayIcon") = 1, "worker scripts should hide the tray icon before any other directive")
        AhkTest.AssertContains("#NoTrayIcon", generatedScript)
        AhkTest.AssertContains("#ErrorStdOut `"UTF-8`"", generatedScript)
        AhkTest.AssertContains("#Warn Unreachable, Off", generatedScript)
        AhkTest.AssertContains("this is not valid AutoHotkey syntax !!!", generatedScript)
        StdlibThreadTest.AssertNoRegexReplacementPollution(generatedScript, worker.AhkStdlibScriptPath)

        worker.join(2)
        stdoutText := FileExist(worker.AhkStdlibStdoutPath) ? FileRead(worker.AhkStdlibStdoutPath, "UTF-8") : ""
        stderrText := FileExist(worker.AhkStdlibStderrPath) ? FileRead(worker.AhkStdlibStderrPath, "UTF-8") : ""
        AhkTest.AssertTrue(StrLen(stdoutText . stderrText) > 0, "stdout/stderr should capture worker load error")
        AhkTest.AssertTrue(worker.exitcode != 0)
        AhkTest.RaisesMatch(RuntimeError, "^worker exited without a result", (*) => worker.result())
    }

    static TestThreadWorkerReportsHiddenTrayState()
    {
        worker := stdlib.thread.Thread({
            name: "hidden-tray-worker",
            source: "thread_result := Map(`"icon_hidden`", A_IconHidden, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"))"
        })

        worker.start()
        worker.join(2)
        result := worker.result()

        AhkTest.AssertTrue(result["icon_hidden"])
        AhkTest.AssertTrue(result["pid"] > 0)
    }

    static TestThreadExampleAndReadmeBlocksRunThroughCapture()
    {
        repoRoot := StdlibThreadTest.RepoRoot()
        examplePath := repoRoot "\stdlib\examples\thread.ahk"
        exampleScript := FileRead(examplePath, "UTF-8")

        StdlibThreadTest.AssertNoRegexReplacementPollution(exampleScript, "thread.ahk")
        for needle in [
            "stdlib.thread.Event",
            "stdlib.thread.Thread",
            "stdlib.thread.Channel",
            "stdlib.thread.SharedMemory",
            "stdlib.thread.SharedObject",
            "stdlib.thread.current_shared_object",
            "stdlib.thread.ThreadPool",
            "stdlib.await",
            "stdlib.thread.ResultQueue",
            "stdlib.thread.start",
            "kernel32\GetCurrentThreadId"
        ]
            AhkTest.AssertContains(needle, exampleScript, "thread.ahk")

        result := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", examplePath], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
        diagnostic := "example exit=" result.ExitCode " stdout=" result.Out " stderr=" result.Err
        AhkTest.AssertEqual(0, result.ExitCode, diagnostic)
        AhkTest.AssertEqual("", result.Err, diagnostic)

        for readmeName in ["README.en.md", "README.zh-CN.md"] {
            readmePath := repoRoot "\" readmeName
            text := FileRead(readmePath, "UTF-8")
            StdlibThreadTest.AssertNoRegexReplacementPollution(text, readmeName)
            script := StdlibThreadTest.ExtractThreadBlock(text)
            StdlibThreadTest.AssertNoRegexReplacementPollution(script, readmeName)
            for needle in [
                "stdlib.thread.Event",
                "stdlib.thread.Thread",
                "stdlib.thread.Channel",
                "stdlib.thread.SharedMemory",
                "stdlib.thread.SharedObject",
                "stdlib.thread.current_shared_object",
                "stdlib.thread.ThreadPool",
                "stdlib.await",
                "worker.start()",
                "worker.join(2)",
                "worker.result()"
            ]
                AhkTest.AssertContains(needle, script, readmeName)

            script := StrReplace(script, "#Include <stdlib\thread>", "#Include `"" repoRoot "\stdlib\thread.ahk`"")
            scriptPath := A_Temp "\stdlib-readme-thread-" StrReplace(readmeName, ".", "-") "-" A_TickCount "-" Random(100000, 999999) ".ahk"
            try {
                FileAppend script, scriptPath, "UTF-8"
                readmeResult := AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", scriptPath], { WorkingDir: repoRoot, TimeoutSeconds: 90 })
            } finally {
                try FileDelete scriptPath
            }
            readmeDiagnostic := readmeName " exit=" readmeResult.ExitCode " stdout=" readmeResult.Out " stderr=" readmeResult.Err
            AhkTest.AssertEqual(0, readmeResult.ExitCode, readmeDiagnostic)
            AhkTest.AssertEqual("", readmeResult.Err, readmeDiagnostic)
        }
    }

    static AssertNoRegexReplacementPollution(text, label)
    {
        pollutedNamespace := "System.Text." "RegularExpressions"
        pollutedEvaluator := "Match" "Evaluator"
        AhkTest.AssertFalse(InStr(text, pollutedNamespace) > 0, label)
        AhkTest.AssertFalse(InStr(text, pollutedEvaluator) > 0, label)
    }

    static AssertNoWorkerWarning(worker, label)
    {
        output := worker.AhkStdlibReadCapturedOutput()
        AhkTest.AssertFalse(InStr(output, "Warning:") > 0, label " captured a warning: " output)
        AhkTest.AssertFalse(InStr(output, "will never execute") > 0, label " captured unreachable-code warning: " output)
    }

    static ExtractThreadBlock(text)
    {
        marker := "#Include <stdlib\thread>"
        markerPos := InStr(text, marker)
        if markerPos = 0
            AhkTest.Fail("missing thread include")
        fence := Chr(96) Chr(96) Chr(96)
        blockStart := 0
        searchPos := 1
        loop {
            candidate := InStr(text, fence "ahk", false, searchPos)
            if candidate = 0 || candidate > markerPos
                break
            blockStart := candidate
            searchPos := candidate + 1
        }
        blockEnd := InStr(text, fence, false, markerPos + StrLen(marker))
        if blockStart = 0 || blockEnd = 0
            AhkTest.Fail("missing thread ahk block")
        contentStart := InStr(text, "`n", false, blockStart) + 1
        return SubStr(text, contentStart, blockEnd - contentStart)
    }

    static RepoRoot()
    {
        SplitPath A_LineFile, , &testsDir
        SplitPath testsDir, , &stdlibDir
        SplitPath stdlibDir, , &repoRoot
        return repoRoot
    }

    static BufferHex(bytes)
    {
        text := ""
        loop bytes.Size
            text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return text
    }

    static FirstJsonFile(directory)
    {
        first := ""
        Loop Files, directory "\*.json", "F" {
            first := A_LoopFileFullPath
            break
        }
        return first
    }

    static WaitForChannelMessage(worker, channel, timeout)
    {
        deadline := A_TickCount + Round(timeout * 1000)
        loop {
            worker.join(0.02)
            try return channel.recv(0)
            catch AhkStdlibThread.Empty {
                if A_TickCount >= deadline
                    throw
                Sleep 10
            }
        }
    }

}

AhkTest.Collect(StdlibThreadTest)

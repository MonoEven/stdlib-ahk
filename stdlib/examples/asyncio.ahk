#Requires AutoHotkey v2.0

#Include <stdlib\asyncio>

asyncio_example_loop := stdlib.asyncio.new_event_loop()
asyncio_example_pending := stdlib.asyncio.Future()
asyncio_example_loop_pending := stdlib.asyncio.Future({ loop: asyncio_example_loop })
asyncio_example_loop_identity := asyncio_example_loop_pending.get_loop() == asyncio_example_loop
asyncio_example_implicit_loop_debug := asyncio_example_pending.get_loop().get_debug()
asyncio_example_pending_done := asyncio_example_pending.done()
asyncio_example_pending_cancelled := asyncio_example_pending.cancelled()
asyncio_example_pending_repr := asyncio_example_pending.__Repr()
asyncio_example_isfuture_pending := stdlib.asyncio.isfuture(asyncio_example_pending)
asyncio_example_isfuture_int := stdlib.asyncio.isfuture(1)

asyncio_example_finished := stdlib.asyncio.Future()
asyncio_example_set_result_return := asyncio_example_finished.set_result(42)
asyncio_example_finished_done := asyncio_example_finished.done()
asyncio_example_finished_result := asyncio_example_finished.result()
asyncio_example_finished_exception := asyncio_example_finished.exception()
asyncio_example_finished_repr := asyncio_example_finished.__Repr()
asyncio_example_finished_await := stdlib.await(asyncio_example_finished, { loop: asyncio_example_loop })

asyncio_example_cancelled := stdlib.asyncio.Future()
asyncio_example_cancel_first := asyncio_example_cancelled.cancel("example stop")
asyncio_example_cancel_second := asyncio_example_cancelled.cancel()
asyncio_example_cancelled_done := asyncio_example_cancelled.done()
asyncio_example_cancelled_flag := asyncio_example_cancelled.cancelled()
asyncio_example_cancelled_repr := asyncio_example_cancelled.__Repr()
asyncio_example_cancelled_result_error := ""
try {
    asyncio_example_cancelled.result()
} catch Error as err {
    if err is stdlib.asyncio.CancelledError
        asyncio_example_cancelled_result_error := err.Message
}

asyncio_example_exception_future := stdlib.asyncio.Future()
asyncio_example_exception_source := RuntimeError("boom", -1)
asyncio_example_set_exception_return := asyncio_example_exception_future.set_exception(asyncio_example_exception_source)
asyncio_example_exception_done := asyncio_example_exception_future.done()
asyncio_example_exception_same := asyncio_example_exception_future.exception() == asyncio_example_exception_source
asyncio_example_exception_repr := asyncio_example_exception_future.__Repr()

asyncio_example_bad_loop_error := ""
try {
    stdlib.asyncio.Future({ loop: 1 })
} catch AttributeError as err {
    asyncio_example_bad_loop_error := err.Message
}

asyncio_example_invalid_state_error := ""
try {
    stdlib.asyncio.Future().result()
} catch Error as err {
    if err is stdlib.asyncio.InvalidStateError
        asyncio_example_invalid_state_error := err.Message
}

asyncio_example_policy := stdlib.asyncio.DefaultEventLoopPolicy()
asyncio_example_set_policy_return := stdlib.asyncio.set_event_loop_policy(asyncio_example_policy)
asyncio_example_policy_identity := stdlib.asyncio.get_event_loop_policy() == asyncio_example_policy
asyncio_example_set_loop_return := stdlib.asyncio.set_event_loop(asyncio_example_loop)
asyncio_example_get_loop_identity := stdlib.asyncio.get_event_loop() == asyncio_example_loop
asyncio_example_child_watcher_error := ""
try {
    stdlib.asyncio.get_child_watcher()
} catch Error as err {
    if err is stdlib.NotImplementedError
        asyncio_example_child_watcher_error := Type(err)
}

asyncio_example_callback_order := []
asyncio_example_handle := asyncio_example_loop.call_soon((label) => asyncio_example_callback_order.Push(label), "soon")
asyncio_example_cancelled_handle := asyncio_example_loop.call_soon((*) => asyncio_example_callback_order.Push("cancelled"))
asyncio_example_cancel_handle_return := asyncio_example_cancelled_handle.cancel()
asyncio_example_threadsafe_handle := asyncio_example_loop.call_soon_threadsafe((label) => asyncio_example_callback_order.Push(label), "threadsafe")
asyncio_example_timer := asyncio_example_loop.call_later(0, (label) => asyncio_example_callback_order.Push(label), "later0")
asyncio_example_loop_spin := asyncio_example_loop.run_until_complete(stdlib.asyncio.sleep(0))

asyncio_example_lifecycle_loop := stdlib.asyncio.new_event_loop()
asyncio_example_lifecycle_initial := [
    asyncio_example_lifecycle_loop.is_running(),
    asyncio_example_lifecycle_loop.is_closed(),
    Type(asyncio_example_lifecycle_loop.time())
]
asyncio_example_lifecycle_events := []
asyncio_example_lifecycle_loop.call_soon(
    (targetLoop, events) => events.Push(["soon", targetLoop.is_running(), targetLoop.is_closed()]),
    asyncio_example_lifecycle_loop,
    asyncio_example_lifecycle_events
)
asyncio_example_lifecycle_at := asyncio_example_lifecycle_loop.call_at(
    asyncio_example_lifecycle_loop.time(),
    (events, label) => events.Push(["at", label]),
    asyncio_example_lifecycle_events,
    "now"
)
asyncio_example_lifecycle_later := asyncio_example_lifecycle_loop.call_at(
    asyncio_example_lifecycle_loop.time() + 0.001,
    (events, label) => events.Push(["later", label]),
    asyncio_example_lifecycle_events,
    "tick"
)
asyncio_example_lifecycle_spin_future := asyncio_example_lifecycle_loop.create_future()
asyncio_example_lifecycle_loop.call_later(0.01, (future) => future.set_result("lifecycle-spin"), asyncio_example_lifecycle_spin_future)
asyncio_example_lifecycle_spin := asyncio_example_lifecycle_loop.run_until_complete(asyncio_example_lifecycle_spin_future)
asyncio_example_lifecycle_after_run := [
    asyncio_example_lifecycle_loop.is_running(),
    asyncio_example_lifecycle_loop.is_closed()
]
asyncio_example_lifecycle_close := asyncio_example_lifecycle_loop.close()
asyncio_example_lifecycle_after_close := [
    asyncio_example_lifecycle_loop.is_running(),
    asyncio_example_lifecycle_loop.is_closed()
]
asyncio_example_lifecycle_closed_error := ""
try {
    asyncio_example_lifecycle_loop.call_soon((*) => stdlib.None)
} catch RuntimeError as err {
    asyncio_example_lifecycle_closed_error := err.Message
}

asyncio_example_callback_future := asyncio_example_loop.create_future()
asyncio_example_done_callbacks := []
asyncio_example_add_done_callback := asyncio_example_callback_future.add_done_callback((future) => asyncio_example_done_callbacks.Push(future.result()))
asyncio_example_callback_future.set_result("callback-value")
asyncio_example_done_callback_before_spin := asyncio_example_done_callbacks.Clone()
asyncio_example_callback_spin := asyncio_example_loop.run_until_complete(stdlib.asyncio.sleep(0))

asyncio_example_sleep_result := asyncio_example_loop.run_until_complete(stdlib.asyncio.sleep(0, "slept"))
asyncio_example_gather_left := asyncio_example_loop.create_future()
asyncio_example_gather_right := asyncio_example_loop.create_future()
asyncio_example_gathered := stdlib.asyncio.gather(asyncio_example_gather_left, asyncio_example_gather_right)
asyncio_example_gather_left.set_result("left")
asyncio_example_gather_right.set_result("right")
asyncio_example_gather_result := asyncio_example_loop.run_until_complete(asyncio_example_gathered)

asyncio_example_ensure_future_same := stdlib.asyncio.ensure_future(asyncio_example_gather_left) == asyncio_example_gather_left
asyncio_example_wrap_future_same := stdlib.asyncio.wrap_future(asyncio_example_gather_left) == asyncio_example_gather_left
asyncio_example_shielded := stdlib.asyncio.shield(asyncio_example_gather_right)
asyncio_example_shield_result := asyncio_example_loop.run_until_complete(asyncio_example_shielded)
asyncio_example_wait_left := asyncio_example_loop.create_future()
asyncio_example_wait_right := asyncio_example_loop.create_future()
asyncio_example_wait_left.set_result("wait-left")
asyncio_example_wait_right.set_result("wait-right")
asyncio_example_wait_result := asyncio_example_loop.run_until_complete(stdlib.asyncio.wait([asyncio_example_wait_left, asyncio_example_wait_right]))
asyncio_example_wait_for_future := asyncio_example_loop.create_future()
asyncio_example_wait_for_future.set_result("wait-for")
asyncio_example_wait_for_result := asyncio_example_loop.run_until_complete(stdlib.asyncio.wait_for(asyncio_example_wait_for_future, { timeout: 1 }))
asyncio_example_timeout_future := asyncio_example_loop.create_future()
asyncio_example_wait_for_timeout_error := ""
try {
    asyncio_example_loop.run_until_complete(stdlib.asyncio.wait_for(asyncio_example_timeout_future, { timeout: 0 }))
} catch Error as err {
    if err is stdlib.asyncio.TimeoutError
        asyncio_example_wait_for_timeout_error := Type(err)
}
asyncio_example_timeout_cancelled := asyncio_example_timeout_future.cancelled()
asyncio_example_completed_left := asyncio_example_loop.create_future()
asyncio_example_completed_right := asyncio_example_loop.create_future()
asyncio_example_completed_items := stdlib.asyncio.as_completed([asyncio_example_completed_left, asyncio_example_completed_right])
asyncio_example_completed_left.set_result("completed-left")
asyncio_example_completed_right.set_result("completed-right")
asyncio_example_completed_results := [
    stdlib.await(asyncio_example_completed_items[1], { loop: asyncio_example_loop }),
    stdlib.await(asyncio_example_completed_items[2], { loop: asyncio_example_loop })
]
asyncio_example_current_task := stdlib.asyncio.current_task({ loop: asyncio_example_loop })
asyncio_example_all_tasks := stdlib.asyncio.all_tasks({ loop: asyncio_example_loop })

asyncio_example_task_events := []
asyncio_example_task_body := AsyncioExampleTaskBody(asyncio_example_task_events)
asyncio_example_task := asyncio_example_loop.create_task(asyncio_example_task_body)
asyncio_example_task_isfuture := stdlib.asyncio.isfuture(asyncio_example_task)
asyncio_example_task_in_all_tasks := AsyncioExampleContains(stdlib.asyncio.all_tasks({ loop: asyncio_example_loop }), asyncio_example_task)
asyncio_example_task_result := asyncio_example_loop.run_until_complete(asyncio_example_task)
asyncio_example_task_done := asyncio_example_task.done()
asyncio_example_task_exception := asyncio_example_task.exception()
asyncio_example_task_all_done := stdlib.asyncio.all_tasks({ loop: asyncio_example_loop })
asyncio_example_threadsafe_future := stdlib.asyncio.run_coroutine_threadsafe(AsyncioExampleTaskBody([]), asyncio_example_loop)
asyncio_example_threadsafe_done_before := asyncio_example_threadsafe_future.done()
asyncio_example_threadsafe_result := stdlib.await(asyncio_example_threadsafe_future, { loop: asyncio_example_loop })

asyncio_example_run_events := []
asyncio_example_run_result := stdlib.asyncio.run(AsyncioExampleParentTaskBody(asyncio_example_run_events))
asyncio_example_is_coroutine := stdlib.asyncio.iscoroutine(AsyncioExampleTaskBody([]))
asyncio_example_is_coroutine_function := stdlib.asyncio.iscoroutinefunction(AsyncioExampleCoroutineFunction)
asyncio_example_plain_function_is_coroutine_function := stdlib.asyncio.iscoroutinefunction(AsyncioExamplePlainFunction)
asyncio_example_decorated_plain := stdlib.asyncio.coroutine(AsyncioExamplePlainFunction)
asyncio_example_decorated_plain_is_coroutine_function := stdlib.asyncio.iscoroutinefunction(asyncio_example_decorated_plain)
asyncio_example_decorated_plain_result := stdlib.await(asyncio_example_decorated_plain.Call())
asyncio_example_to_thread_error := ""
try {
    stdlib.await(stdlib.asyncio.to_thread(AsyncioExampleJoinText, "to", "-thread"))
} catch Error as err {
    if err is stdlib.NotImplementedError
        asyncio_example_to_thread_error := err.Message
}
asyncio_example_create_task_no_loop_error := ""
try {
    stdlib.asyncio.create_task(AsyncioExampleTaskBody([]))
} catch RuntimeError as err {
    asyncio_example_create_task_no_loop_error := err.Message
}
asyncio_example_sync_events := stdlib.asyncio.run(AsyncioExampleSyncPrimitiveBody())
asyncio_example_queue_events := stdlib.asyncio.run(AsyncioExampleAsyncQueueBody())

asyncio_example_queue := stdlib.asyncio.Queue({ maxsize: 2 })
asyncio_example_queue_put_a := asyncio_example_queue.put_nowait("a")
asyncio_example_queue_put_b := asyncio_example_queue.put_nowait("b")
asyncio_example_queue_full := asyncio_example_queue.full()
asyncio_example_queue_get_a := asyncio_example_queue.get_nowait()
asyncio_example_queue_get_b := asyncio_example_queue.get_nowait()

AsyncioExampleContains(items, needle)
{
    for item in items {
        if item == needle
            return true
    }
    return false
}

AsyncioExamplePlainFunction()
{
    return "plain"
}

AsyncioExampleCoroutineFunction()
{
    return AsyncioExampleTaskBody([])
}

AsyncioExampleJoinText(left, right)
{
    return left right
}

class AsyncioExampleTaskBody
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
            this.Events.Push(["current-task", stdlib.asyncio.current_task() == task])
            return stdlib.asyncio.sleep(0, "task-slept")
        }
        this.Events.Push(["after-sleep", value])
        return "task-result"
    }
}

class AsyncioExampleParentTaskBody
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
            child := stdlib.asyncio.create_task(AsyncioExampleTaskBody(this.Events))
            this.Events.Push(["child-created", stdlib.asyncio.isfuture(child)])
            return child
        }
        this.Events.Push(["parent-result", value])
        return value
    }
}

class AsyncioExampleAwaitFutureBody
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

class AsyncioExampleSyncPrimitiveBody
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
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Lock := stdlib.asyncio.Lock()
                return this.Lock.acquire()
            case 1:
                this.StepIndex += 1
                this.Events.Push(["lock-acquired", value, this.Lock.locked()])
                this.LockWaiter := stdlib.asyncio.create_task(AsyncioExampleAwaitFutureBody(this.Lock.acquire()))
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                this.Events.Push(["lock-waiter-pending", this.LockWaiter.done()])
                this.Lock.release()
                return stdlib.asyncio.sleep(0)
            case 3:
                this.StepIndex += 1
                this.Events.Push(["lock-waiter-done", this.LockWaiter.done(), this.LockWaiter.result()])
                this.Lock.release()
                this.Event := stdlib.asyncio.Event()
                this.EventWaiter := stdlib.asyncio.create_task(AsyncioExampleAwaitFutureBody(this.Event.wait()))
                return stdlib.asyncio.sleep(0)
            case 4:
                this.StepIndex += 1
                this.Events.Push(["event-waiter-pending", this.EventWaiter.done()])
                this.Event.set()
                return stdlib.asyncio.sleep(0)
            case 5:
                this.StepIndex += 1
                this.Events.Push(["event-set", this.Event.is_set(), this.EventWaiter.result()])
                this.Semaphore := stdlib.asyncio.Semaphore(1)
                return this.Semaphore.acquire()
            case 6:
                this.StepIndex += 1
                this.Events.Push(["semaphore-acquired", value, this.Semaphore.locked()])
                this.SemaphoreWaiter := stdlib.asyncio.create_task(AsyncioExampleAwaitFutureBody(this.Semaphore.acquire()))
                return stdlib.asyncio.sleep(0)
            case 7:
                this.StepIndex += 1
                this.Events.Push(["semaphore-waiter-pending", this.SemaphoreWaiter.done()])
                this.Semaphore.release()
                return stdlib.asyncio.sleep(0)
            case 8:
                this.Events.Push(["semaphore-waiter-done", this.SemaphoreWaiter.done(), this.SemaphoreWaiter.result()])
                return this.Events
        }
    }
}

class AsyncioExampleAsyncQueueBody
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
                return this.Queue.put("a")
            case 1:
                this.StepIndex += 1
                this.Events.Push(["put-a", value, this.Queue.full()])
                this.Putter := stdlib.asyncio.create_task(AsyncioExampleAwaitFutureBody(this.Queue.put("b")))
                return stdlib.asyncio.sleep(0)
            case 2:
                this.StepIndex += 1
                this.Events.Push(["putter-pending", this.Putter.done()])
                return this.Queue.get()
            case 3:
                this.StepIndex += 1
                this.Events.Push(["got", value])
                this.Queue.task_done()
                return stdlib.asyncio.sleep(0)
            case 4:
                this.StepIndex += 1
                this.Events.Push(["putter-done", this.Putter.done(), this.Queue.get_nowait()])
                this.Queue.task_done()
                this.Getter := stdlib.asyncio.create_task(AsyncioExampleAwaitFutureBody(this.Queue.get()))
                return stdlib.asyncio.sleep(0)
            case 5:
                this.StepIndex += 1
                this.Queue.put_nowait("c")
                return stdlib.asyncio.sleep(0)
            case 6:
                this.StepIndex += 1
                this.Events.Push(["getter-done", this.Getter.done(), this.Getter.result()])
                this.Queue.task_done()
                return this.Queue.join()
            case 7:
                this.Events.Push(["join", value])
                return this.Events
        }
    }
}

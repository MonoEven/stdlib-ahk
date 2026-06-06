#Requires AutoHotkey v2.0

#Include <stdlib\thread>

thread_example_main_pid := DllCall("kernel32\GetCurrentProcessId", "UInt")
thread_example_main_tid := stdlib.thread.get_ident()
thread_example_current := stdlib.thread.current_thread()

thread_example_event := stdlib.thread.Event()
thread_example_event_before := thread_example_event.is_set()
thread_example_event_wait_before := thread_example_event.wait(0)
thread_example_event_set_return := thread_example_event.set()
thread_example_event_after := thread_example_event.wait(0)
thread_example_event_clear_return := thread_example_event.clear()
thread_example_event_after_clear := thread_example_event.is_set()

thread_example_worker := stdlib.thread.Thread({
    name: "example-worker",
    source: "thread_result := Map(`"value`", 42, `"text`", `"done`", `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
thread_example_started_return := thread_example_worker.start()
thread_example_worker_pid := thread_example_worker.pid
thread_example_worker_native_id := thread_example_worker.native_id
thread_example_worker_is_separate_process := thread_example_worker_pid != thread_example_main_pid
thread_example_worker_is_separate_thread := thread_example_worker_native_id != thread_example_main_tid
thread_example_join_return := thread_example_worker.join(2)
thread_example_result := thread_example_worker.result()
thread_example_result_value := thread_example_result["value"]
thread_example_result_text := thread_example_result["text"]

thread_example_queue := stdlib.thread.ResultQueue()
thread_example_queued_worker := stdlib.thread.start({
    name: "queued-worker",
    source: "thread_result := Map(`"label`", `"queued`", `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
thread_example_queue_add_return := thread_example_queue.add(thread_example_queued_worker)
thread_example_queued_worker.join(2)
thread_example_completed := thread_example_queue.poll()
thread_example_queue_item := thread_example_queue.get_nowait()
thread_example_queue_label := thread_example_queue_item.value["label"]
thread_example_queue_native_id := thread_example_queue_item.native_id

thread_example_channel := stdlib.thread.Channel()
thread_example_channel_worker := stdlib.thread.Thread({
    name: "channel-worker",
    channel: thread_example_channel,
    source: "channel := stdlib.thread.current_channel()`n"
        . "request := channel.recv_worker(2)`n"
        . "channel.send_worker(Map(`"answer`", request[`"value`"] * 2, `"label`", request[`"label`"]))`n"
        . "done := channel.recv_worker(2)`n"
        . "thread_result := Map(`"done`", done[`"done`"])"
})
thread_example_channel_worker.start()
thread_example_channel.send(Map("value", 21, "label", "json-message"))
thread_example_channel_reply := thread_example_channel.recv(2)
thread_example_channel_answer := thread_example_channel_reply["answer"]
thread_example_channel_label := thread_example_channel_reply["label"]
thread_example_channel.send(Map("done", true))
thread_example_channel_worker.join(2)
thread_example_channel_result := thread_example_channel_worker.result()
thread_example_channel_done := thread_example_channel_result["done"]
thread_example_channel.close()

thread_example_memory_channel := stdlib.thread.Channel()
thread_example_memory := stdlib.thread.SharedMemory({ size: 128 })
thread_example_memory.write("abcd", 0)
thread_example_memory_worker := stdlib.thread.Thread({
    name: "shared-memory-worker",
    channel: thread_example_memory_channel,
    shared_memory: thread_example_memory,
    source: "memory := stdlib.thread.current_shared_memory()`n"
        . "seen := memory.read_text(0, 4)`n"
        . "memory.write(`"WXYZ`", 4)`n"
        . "memory.synchronized((shared) => (`n"
        . "    shared.write_json(Map(`"seen`", seen, `"ok`", true), 16, 64),`n"
        . "    shared.put(0x11223344, 80, `"UInt`"),`n"
        . "    shared.put(-123, 84, `"Int`"),`n"
        . "    shared.put(0x55, 88, `"UChar`")`n"
        . "), 2)`n"
        . "stdlib.thread.current_channel().send_worker(Map(`"seen`", seen, `"address_type`", Type(memory.address), `"raw`", memory.get(80, `"UInt`")))`n"
        . "thread_result := Map(`"done`", true)"
})
thread_example_memory_worker.start()
thread_example_memory_reply := thread_example_memory_channel.recv(2)
thread_example_memory_worker.join(2)
thread_example_memory_result := thread_example_memory_worker.result()
thread_example_memory_text := thread_example_memory.read_text(4, 4)
thread_example_memory_payload := thread_example_memory.read_json(16, 64)
thread_example_memory_address_type := thread_example_memory_reply["address_type"]
thread_example_memory_raw_u32 := thread_example_memory.get(80, "UInt")
thread_example_memory_raw_i32 := thread_example_memory.get(84, "Int")
thread_example_memory_raw_u8 := thread_example_memory.get(88, "UChar")
thread_example_memory_channel.close()
thread_example_memory.close()

thread_example_shared := stdlib.thread.SharedObject(Map("count", 0, "items", []))
thread_example_shared_worker := stdlib.thread.Thread({
    name: "shared-object-worker",
    shared_objects: Map("state", thread_example_shared),
    source: "state := stdlib.thread.current_shared_object(`"state`")`n"
        . "state.acquire(true, 2)`n"
        . "try {`n"
        . "    state.append(`"items`", `"proxy-message`")`n"
        . "    state.set(`"count`", state.get(`"count`") + 1)`n"
        . "    thread_result := Map(`"count`", state.get(`"count`"), `"items_length`", state.len(`"items`"))`n"
        . "} finally {`n"
        . "    state.release()`n"
        . "}"
})
thread_example_shared_worker.start()
thread_example_shared_worker.join(2)
thread_example_shared_result := thread_example_shared_worker.result()
thread_example_shared_snapshot := thread_example_shared.snapshot()
thread_example_shared_count := thread_example_shared_snapshot["count"]
thread_example_shared_items_length := thread_example_shared_snapshot["items"].Length

thread_example_pool := stdlib.thread.ThreadPool({ max_workers: 1, thread_name_prefix: "example-pool" })
thread_example_pool_first := thread_example_pool.submit({
    source: "thread_result := Map(`"label`", `"first`", `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
thread_example_pool_second := thread_example_pool.submit({
    source: "thread_result := Map(`"label`", `"second`", `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
thread_example_pool_callbacks := []
thread_example_pool_first.add_done_callback((future) => thread_example_pool_callbacks.Push(future.result()["label"]))
thread_example_pool_second_running_before := thread_example_pool_second.running()
thread_example_pool_first_result := thread_example_pool_first.result(2)
thread_example_pool_second.add_done_callback((future) => thread_example_pool_callbacks.Push(future.result()["label"]))
thread_example_pool_second_result := stdlib.await(thread_example_pool_second, { timeout: 2 })
thread_example_pool_first_label := thread_example_pool_first_result["label"]
thread_example_pool_second_label := thread_example_pool_second_result["label"]
thread_example_pool_callback_count := thread_example_pool_callbacks.Length
thread_example_pool_map_results := thread_example_pool.map((value) => { source: "thread_result := " (value * 10) }, [3, 1, 2])
thread_example_pool.shutdown()

thread_example_persistent_pool := stdlib.thread.ThreadPool({
    max_workers: 1,
    thread_name_prefix: "example-persistent",
    worker_source: "AhkStdlibThreadPoolHandleTask(task) {`n"
        . "    return Map(`"label`", task[`"label`"], `"value`", task[`"value`"] * 10, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))`n"
        . "}"
})
thread_example_persistent_first := thread_example_persistent_pool.submit({ task: Map("label", "first", "value", 1) }).result(2)
thread_example_persistent_second := thread_example_persistent_pool.submit({ task: Map("label", "second", "value", 2) }).result(2)
thread_example_persistent_map := thread_example_persistent_pool.map((value) => { task: Map("label", "map", "value", value) }, [3])
thread_example_persistent_reused_pid := thread_example_persistent_first["pid"] = thread_example_persistent_second["pid"]
thread_example_persistent_reused_native_id := thread_example_persistent_first["native_id"] = thread_example_persistent_map[1]["native_id"]
thread_example_persistent_pool.shutdown()

thread_example_error := ""
thread_example_failing_worker := stdlib.thread.start({
    name: "failing-worker",
    source: "throw RuntimeError(`"worker boom`", -1)"
})
thread_example_failing_worker.join(2)
try {
    thread_example_failing_worker.result()
} catch RuntimeError as err {
    thread_example_error := err.Message
}

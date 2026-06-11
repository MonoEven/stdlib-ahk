#Requires AutoHotkey v2.0

#Include <stdlib\asyncio>
#Include <stdlib\socket>

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
asyncio_example_events_module_name := stdlib.asyncio.events.__name
asyncio_example_streams_module_name := stdlib.asyncio.streams.__name
asyncio_example_tasks_module_name := stdlib.asyncio.tasks.__name
asyncio_example_sys_module_name := stdlib.asyncio.sys.__name
asyncio_example_stream_reader := stdlib.asyncio.StreamReader({ loop: asyncio_example_loop })
asyncio_example_stream_reader.feed_data(AsyncioExampleBytes("first`nsecond"))
asyncio_example_stream_line := AsyncioExampleBufferText(stdlib.await(asyncio_example_stream_reader.readline(), { loop: asyncio_example_loop }))
asyncio_example_stream_reader.feed_eof()
asyncio_example_stream_rest := AsyncioExampleBufferText(stdlib.await(asyncio_example_stream_reader.read(), { loop: asyncio_example_loop }))
asyncio_example_stream_at_eof := asyncio_example_stream_reader.at_eof()
asyncio_example_stream_protocol_reader := stdlib.asyncio.StreamReader({ loop: asyncio_example_loop })
asyncio_example_stream_protocol := stdlib.asyncio.StreamReaderProtocol(asyncio_example_stream_protocol_reader, stdlib.None, asyncio_example_loop)
asyncio_example_stream_protocol.data_received(AsyncioExampleBytes("a|b|"))
asyncio_example_stream_protocol_first := AsyncioExampleBufferText(stdlib.await(asyncio_example_stream_protocol_reader.readuntil(AsyncioExampleBytes("|")), { loop: asyncio_example_loop }))
asyncio_example_stream_protocol.eof_received()
asyncio_example_stream_protocol_rest := AsyncioExampleBufferText(stdlib.await(asyncio_example_stream_protocol_reader.read(), { loop: asyncio_example_loop }))
asyncio_example_stream_transport := AsyncioExampleMemoryTransport()
asyncio_example_stream_writer := stdlib.asyncio.StreamWriter(asyncio_example_stream_transport, asyncio_example_stream_protocol, asyncio_example_stream_protocol_reader, asyncio_example_loop)
asyncio_example_stream_writer.write(AsyncioExampleBytes("hi"))
asyncio_example_stream_writer.writelines([AsyncioExampleBytes("a"), AsyncioExampleBytes("b")])
asyncio_example_stream_writer.close()
asyncio_example_stream_writer_writes := asyncio_example_stream_transport.Writes
asyncio_example_stream_writer_closed := asyncio_example_stream_writer.is_closing()
asyncio_example_iocp_proactor := stdlib.asyncio.IocpProactor(1)
asyncio_example_iocp_proactor_type := Type(asyncio_example_iocp_proactor)
asyncio_example_iocp_proactor_empty := asyncio_example_iocp_proactor.select(0)
asyncio_example_iocp_proactor_set_loop := asyncio_example_iocp_proactor.set_loop(stdlib.None)
asyncio_example_iocp_proactor_close_first := asyncio_example_iocp_proactor.close()
asyncio_example_iocp_proactor_close_second := asyncio_example_iocp_proactor.close()
asyncio_example_iocp_proactor_closed_select_error := ""
try {
    asyncio_example_iocp_proactor.select(0)
} catch TypeError as err {
    asyncio_example_iocp_proactor_closed_select_error := err.Message
}
asyncio_example_protocol := stdlib.asyncio.Protocol()
asyncio_example_protocol_connection := asyncio_example_protocol.connection_made("transport")
asyncio_example_protocol_data := asyncio_example_protocol.data_received(AsyncioExampleBytes("payload"))
asyncio_example_protocol_eof := asyncio_example_protocol.eof_received()
asyncio_example_transport := stdlib.asyncio.BaseTransport(Map("peername", "peer"))
asyncio_example_transport_peer := asyncio_example_transport.get_extra_info("peername")
asyncio_example_transport_missing := asyncio_example_transport.get_extra_info("missing", "fallback")
asyncio_example_transport_close_error := ""
try {
    asyncio_example_transport.close()
} catch Error as err {
    if err is stdlib.NotImplementedError
        asyncio_example_transport_close_error := Type(err)
}
asyncio_example_server := stdlib.asyncio.Server(asyncio_example_loop, [], (*) => stdlib.None, stdlib.None, 100, 60.0)
asyncio_example_server_initial := asyncio_example_server.is_serving()
asyncio_example_server_start := stdlib.await(asyncio_example_server.start_serving(), { loop: asyncio_example_loop })
asyncio_example_server_started := asyncio_example_server.is_serving()
asyncio_example_server_forever := asyncio_example_server.serve_forever()
asyncio_example_server_forever_pending := asyncio_example_server_forever.done()
asyncio_example_server_close := asyncio_example_server.close()
asyncio_example_server_closed := asyncio_example_server.is_serving()
asyncio_example_server_wait_closed := stdlib.await(asyncio_example_server.wait_closed(), { loop: asyncio_example_loop })
asyncio_example_server_forever_cancelled := asyncio_example_server_forever.cancelled()

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

asyncio_example_incomplete_error := stdlib.asyncio.IncompleteReadError(AsyncioExampleBytes("abc"), 5)
asyncio_example_incomplete_is_eof := asyncio_example_incomplete_error is stdlib.EOFError
asyncio_example_incomplete_message := asyncio_example_incomplete_error.Message
asyncio_example_incomplete_partial := AsyncioExampleBufferText(asyncio_example_incomplete_error.partial)
asyncio_example_incomplete_expected := asyncio_example_incomplete_error.expected
asyncio_example_limit_error := stdlib.asyncio.LimitOverrunError("separator not found", 7)
asyncio_example_limit_message := asyncio_example_limit_error.Message
asyncio_example_limit_consumed := asyncio_example_limit_error.consumed

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
asyncio_example_gather_ok := asyncio_example_loop.create_future()
asyncio_example_gather_failed := asyncio_example_loop.create_future()
asyncio_example_gather_ok.set_result("ok")
asyncio_example_gather_failed.set_exception(RuntimeError("boom", -1))
asyncio_example_gather_return_exceptions := asyncio_example_loop.run_until_complete(
    stdlib.asyncio.gather(asyncio_example_gather_ok, asyncio_example_gather_failed, { return_exceptions: true })
)
asyncio_example_gather_exception_message := asyncio_example_gather_return_exceptions[2].Message

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
asyncio_example_to_thread_result := stdlib.await(stdlib.asyncio.to_thread(AsyncioExampleJoinText, "to", "-thread"))
asyncio_example_to_thread_failure_error := ""
try {
    stdlib.await(stdlib.asyncio.to_thread(AsyncioExampleToThreadFailure))
} catch RuntimeError as err {
    asyncio_example_to_thread_failure_error := err.Message
}
asyncio_example_to_thread_bad_callable_error := ""
try {
    stdlib.await(stdlib.asyncio.to_thread(1))
} catch Error as err {
    if err is TypeError
        asyncio_example_to_thread_bad_callable_error := err.Message
}
asyncio_example_subprocess_exec := stdlib.asyncio.create_subprocess_exec(A_ComSpec, "/C", "exit", "3")
asyncio_example_subprocess_shell := stdlib.asyncio.create_subprocess_shell("exit 4")
asyncio_example_network_events := []
asyncio_example_network_server := stdlib.await(stdlib.asyncio.start_server(AsyncioExampleEchoServerHandler(asyncio_example_network_events), "127.0.0.1", 0), { loop: asyncio_example_loop })
asyncio_example_network_server_serving := asyncio_example_network_server.is_serving()
asyncio_example_network_sockname := asyncio_example_network_server.sockets[1].getsockname()
asyncio_example_network_pair := stdlib.await(stdlib.asyncio.open_connection(asyncio_example_network_sockname[1], asyncio_example_network_sockname[2]), { loop: asyncio_example_loop })
asyncio_example_network_reader := asyncio_example_network_pair[1]
asyncio_example_network_writer := asyncio_example_network_pair[2]
asyncio_example_network_writer_sockname := asyncio_example_network_writer.get_extra_info("sockname")
asyncio_example_network_writer_peername := asyncio_example_network_writer.get_extra_info("peername")
asyncio_example_network_writer_missing := asyncio_example_network_writer.get_extra_info("missing", "fallback")
asyncio_example_network_write := asyncio_example_network_writer.write(AsyncioExampleBytes("hello"))
asyncio_example_network_drain := stdlib.await(asyncio_example_network_writer.drain(), { loop: asyncio_example_loop })
asyncio_example_network_reply := AsyncioExampleBufferText(stdlib.await(asyncio_example_network_reader.read(5), { loop: asyncio_example_loop }))
asyncio_example_network_writer_close := asyncio_example_network_writer.close()
asyncio_example_network_writer_closed := stdlib.await(asyncio_example_network_writer.wait_closed(), { loop: asyncio_example_loop })
asyncio_example_network_server_close := asyncio_example_network_server.close()
asyncio_example_network_server_wait_closed := stdlib.await(asyncio_example_network_server.wait_closed(), { loop: asyncio_example_loop })
asyncio_example_iocp_socket_events := []
asyncio_example_iocp_socket_server := stdlib.await(stdlib.asyncio.start_server(AsyncioExampleProactorServerHandler(asyncio_example_iocp_socket_events), "127.0.0.1", 0), { loop: asyncio_example_loop })
asyncio_example_iocp_socket_sockname := asyncio_example_iocp_socket_server.sockets[1].getsockname()
asyncio_example_iocp_socket := stdlib.socket.socket()
asyncio_example_iocp_connect_result := stdlib.await(asyncio_example_iocp_proactor.connect(asyncio_example_iocp_socket, [asyncio_example_iocp_socket_sockname[1], asyncio_example_iocp_socket_sockname[2]]), { loop: asyncio_example_loop })
asyncio_example_iocp_send_result := stdlib.await(asyncio_example_iocp_proactor.send(asyncio_example_iocp_socket, AsyncioExampleBytes("ping")), { loop: asyncio_example_loop })
asyncio_example_iocp_recv_result := AsyncioExampleBufferText(stdlib.await(asyncio_example_iocp_proactor.recv(asyncio_example_iocp_socket, 4), { loop: asyncio_example_loop }))
asyncio_example_iocp_socket_close := asyncio_example_iocp_socket.close()
asyncio_example_iocp_socket_server_close := asyncio_example_iocp_socket_server.close()
asyncio_example_iocp_socket_server_wait_closed := stdlib.await(asyncio_example_iocp_socket_server.wait_closed(), { loop: asyncio_example_loop })
asyncio_example_subprocess_exec_is_coroutine := stdlib.asyncio.iscoroutine(asyncio_example_subprocess_exec)
asyncio_example_subprocess_shell_is_coroutine := stdlib.asyncio.iscoroutine(asyncio_example_subprocess_shell)
asyncio_example_subprocess_exec_process := stdlib.await(asyncio_example_subprocess_exec, { loop: asyncio_example_loop })
asyncio_example_subprocess_exec_pid_is_int := asyncio_example_subprocess_exec_process.pid is Integer
asyncio_example_subprocess_exec_returncode_before := asyncio_example_subprocess_exec_process.returncode
asyncio_example_subprocess_exec_wait_result := stdlib.await(asyncio_example_subprocess_exec_process.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_exec_returncode_after := asyncio_example_subprocess_exec_process.returncode
asyncio_example_subprocess_shell_process := stdlib.await(asyncio_example_subprocess_shell, { loop: asyncio_example_loop })
asyncio_example_subprocess_shell_pid_is_int := asyncio_example_subprocess_shell_process.pid is Integer
asyncio_example_subprocess_shell_returncode_before := asyncio_example_subprocess_shell_process.returncode
asyncio_example_subprocess_shell_wait_result := stdlib.await(asyncio_example_subprocess_shell_process.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_shell_returncode_after := asyncio_example_subprocess_shell_process.returncode
asyncio_example_subprocess_pipe := stdlib.await(stdlib.asyncio.create_subprocess_exec(
    A_ComSpec,
    "/C",
    "echo out&>&2 echo err&exit 5",
    { stdout: stdlib.asyncio.subprocess.PIPE, stderr: stdlib.asyncio.subprocess.PIPE }
), { loop: asyncio_example_loop })
asyncio_example_subprocess_pipe_stdout_is_reader := Type(asyncio_example_subprocess_pipe.stdout) = "AhkStdlibAsyncioStreamReader"
asyncio_example_subprocess_pipe_stderr_is_reader := Type(asyncio_example_subprocess_pipe.stderr) = "AhkStdlibAsyncioStreamReader"
asyncio_example_subprocess_pipe_result := stdlib.await(asyncio_example_subprocess_pipe.communicate(), { loop: asyncio_example_loop })
asyncio_example_subprocess_pipe_stdout := AsyncioExampleBufferText(asyncio_example_subprocess_pipe_result[1])
asyncio_example_subprocess_pipe_stderr := AsyncioExampleBufferText(asyncio_example_subprocess_pipe_result[2])
asyncio_example_subprocess_pipe_returncode := asyncio_example_subprocess_pipe.returncode
asyncio_example_subprocess_stdin_code := "import sys; data=sys.stdin.buffer.read(); sys.stdout.buffer.write(data.upper()); sys.stderr.buffer.write(b'err:' + data); sys.exit(7)"
asyncio_example_subprocess_stdin := stdlib.await(stdlib.asyncio.create_subprocess_exec(
    "py",
    "-3.10",
    "-c",
    asyncio_example_subprocess_stdin_code,
    { stdin: stdlib.asyncio.subprocess.PIPE, stdout: stdlib.asyncio.subprocess.PIPE, stderr: stdlib.asyncio.subprocess.PIPE }
), { loop: asyncio_example_loop })
asyncio_example_subprocess_stdin_is_writer := Type(asyncio_example_subprocess_stdin.stdin) = "AhkStdlibAsyncioStreamWriter"
asyncio_example_subprocess_stdin_result := stdlib.await(asyncio_example_subprocess_stdin.communicate(AsyncioExampleBytes("abc")), { loop: asyncio_example_loop })
asyncio_example_subprocess_stdin_stdout := AsyncioExampleBufferText(asyncio_example_subprocess_stdin_result[1])
asyncio_example_subprocess_stdin_stderr := AsyncioExampleBufferText(asyncio_example_subprocess_stdin_result[2])
asyncio_example_subprocess_stdin_returncode := asyncio_example_subprocess_stdin.returncode
asyncio_example_subprocess_sleep_code := "import time; time.sleep(5)"
asyncio_example_subprocess_terminate := stdlib.await(stdlib.asyncio.create_subprocess_exec("py", "-3.10", "-c", asyncio_example_subprocess_sleep_code), { loop: asyncio_example_loop })
asyncio_example_subprocess_terminate_return := asyncio_example_subprocess_terminate.terminate()
asyncio_example_subprocess_terminate_wait := stdlib.await(asyncio_example_subprocess_terminate.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_kill := stdlib.await(stdlib.asyncio.create_subprocess_exec("py", "-3.10", "-c", asyncio_example_subprocess_sleep_code), { loop: asyncio_example_loop })
asyncio_example_subprocess_kill_return := asyncio_example_subprocess_kill.kill()
asyncio_example_subprocess_kill_wait := stdlib.await(asyncio_example_subprocess_kill.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_signal := stdlib.await(stdlib.asyncio.create_subprocess_exec("py", "-3.10", "-c", asyncio_example_subprocess_sleep_code), { loop: asyncio_example_loop })
asyncio_example_subprocess_signal_return := asyncio_example_subprocess_signal.send_signal(15)
asyncio_example_subprocess_signal_wait := stdlib.await(asyncio_example_subprocess_signal.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_constants_output_code := "import sys; sys.stdout.buffer.write(b'out'); sys.stderr.buffer.write(b'err'); sys.exit(8)"
asyncio_example_subprocess_merged := stdlib.await(stdlib.asyncio.create_subprocess_exec(
    "py",
    "-3.10",
    "-c",
    asyncio_example_subprocess_constants_output_code,
    { stdout: stdlib.asyncio.subprocess.PIPE, stderr: stdlib.asyncio.subprocess.STDOUT }
), { loop: asyncio_example_loop })
asyncio_example_subprocess_merged_result := stdlib.await(asyncio_example_subprocess_merged.communicate(), { loop: asyncio_example_loop })
asyncio_example_subprocess_merged_stdout := AsyncioExampleBufferText(asyncio_example_subprocess_merged_result[1])
asyncio_example_subprocess_merged_stderr_is_none := asyncio_example_subprocess_merged_result[2] == stdlib.None
asyncio_example_subprocess_devnull := stdlib.await(stdlib.asyncio.create_subprocess_exec(
    "py",
    "-3.10",
    "-c",
    "import sys; sys.stdout.buffer.write(b'out'); sys.stderr.buffer.write(b'err'); sys.exit(9)",
    { stdout: stdlib.asyncio.subprocess.DEVNULL, stderr: stdlib.asyncio.subprocess.DEVNULL }
), { loop: asyncio_example_loop })
asyncio_example_subprocess_devnull_result := stdlib.await(asyncio_example_subprocess_devnull.communicate(), { loop: asyncio_example_loop })
asyncio_example_subprocess_devnull_stdout_is_none := asyncio_example_subprocess_devnull_result[1] == stdlib.None
asyncio_example_subprocess_devnull_stderr_is_none := asyncio_example_subprocess_devnull_result[2] == stdlib.None
asyncio_example_subprocess_done := stdlib.await(stdlib.asyncio.create_subprocess_exec("py", "-3.10", "-c", "import sys; sys.exit(0)"), { loop: asyncio_example_loop })
asyncio_example_subprocess_done_wait := stdlib.await(asyncio_example_subprocess_done.wait(), { loop: asyncio_example_loop })
asyncio_example_subprocess_process_lookup_error := ""
try {
    asyncio_example_subprocess_done.terminate()
} catch Error as err {
    if err is stdlib.ProcessLookupError
        asyncio_example_subprocess_process_lookup_error := Type(err)
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

AsyncioExampleToThreadFailure()
{
    throw RuntimeError("to-thread-boom", -1)
}

AsyncioExampleBytes(text)
{
    size := StrPut(text, "UTF-8") - 1
    bytes := Buffer(size, 0)
    if size > 0
        StrPut(text, bytes, "UTF-8")
    return bytes
}

AsyncioExampleBufferText(bytes)
{
    return bytes.Size > 0 ? StrGet(bytes, "UTF-8") : ""
}

class AsyncioExampleMemoryTransport
{
    __New()
    {
        this.Writes := []
        this.Closed := false
    }

    write(data)
    {
        this.Writes.Push(AsyncioExampleBufferText(data))
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
        this.Writes.Push("<eof>")
        return stdlib.None
    }

    can_write_eof()
    {
        return true
    }

    close()
    {
        this.Closed := true
        return stdlib.None
    }

    is_closing()
    {
        return this.Closed
    }

    get_extra_info(name, defaultValue := unset)
    {
        return IsSet(defaultValue) ? defaultValue : stdlib.None
    }
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

class AsyncioExampleEchoServerHandler
{
    __New(events)
    {
        this.Events := events
    }

    Call(reader, writer)
    {
        return AsyncioExampleEchoServerBody(this.Events, reader, writer)
    }
}

class AsyncioExampleEchoServerBody
{
    __New(events, reader, writer)
    {
        this.Events := events
        this.Reader := reader
        this.Writer := writer
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                this.Events.Push(["reader", Type(this.Reader)])
                this.Events.Push(["writer", Type(this.Writer)])
                return this.Reader.read(5)
            case 1:
                this.StepIndex += 1
                text := AsyncioExampleBufferText(value)
                this.Events.Push(["read", text])
                this.Writer.write(AsyncioExampleBytes(StrUpper(text)))
                return this.Writer.drain()
            case 2:
                this.Writer.close()
                return stdlib.None
        }
    }
}

class AsyncioExampleProactorServerHandler
{
    __New(events)
    {
        this.Events := events
    }

    Call(reader, writer)
    {
        return AsyncioExampleProactorServerBody(this.Events, reader, writer)
    }
}

class AsyncioExampleProactorServerBody
{
    __New(events, reader, writer)
    {
        this.Events := events
        this.Reader := reader
        this.Writer := writer
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        switch this.StepIndex {
            case 0:
                this.StepIndex += 1
                return this.Reader.read(4)
            case 1:
                this.StepIndex += 1
                text := AsyncioExampleBufferText(value)
                this.Events.Push(["read", text])
                this.Writer.write(AsyncioExampleBytes(StrUpper(text)))
                return this.Writer.drain()
            case 2:
                this.Writer.close()
                return stdlib.None
        }
    }
}

#Requires AutoHotkey v2.0

#Include <stdlib\asyncio>

asyncio_example_loop := stdlib.asyncio.new_event_loop()
asyncio_example_pending := stdlib.asyncio.Future()
asyncio_example_loop_pending := stdlib.asyncio.Future({ loop: asyncio_example_loop })
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

asyncio_example_cancelled := stdlib.asyncio.Future()
asyncio_example_cancel_first := asyncio_example_cancelled.cancel()
asyncio_example_cancel_second := asyncio_example_cancelled.cancel()
asyncio_example_cancelled_done := asyncio_example_cancelled.done()
asyncio_example_cancelled_flag := asyncio_example_cancelled.cancelled()
asyncio_example_cancelled_repr := asyncio_example_cancelled.__Repr()
asyncio_example_cancelled_result_error := ""
try {
    asyncio_example_cancelled.result()
} catch Error as err {
    if err is stdlib.asyncio.CancelledError
        asyncio_example_cancelled_result_error := Type(err)
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

#Requires AutoHotkey v2.0

#Include <stdlib\queue>

queue_example := stdlib.queue.Queue(1)
queue_example_empty_before := queue_example.empty()
queue_example.put_nowait("item")
queue_example_full_after_put := queue_example.full()
queue_example_size_after_put := queue_example.qsize()
queue_example_item := queue_example.get_nowait()
queue_example_empty_after_get := queue_example.empty()

queue_example_get_nowait_error := ""
try {
    stdlib.queue.Queue().get_nowait()
} catch Error as err {
    if err is stdlib.queue.Empty
        queue_example_get_nowait_error := Type(err)
}

queue_example_put_nowait_error := ""
queue_example_full_queue := stdlib.queue.Queue(1)
queue_example_full_queue.put_nowait(1)
try {
    queue_example_full_queue.put_nowait(2)
} catch Error as err {
    if err is stdlib.queue.Full
        queue_example_put_nowait_error := Type(err)
}

queue_example_float_maxsize := stdlib.queue.Queue(1.5)
queue_example_float_maxsize_value := queue_example_float_maxsize.maxsize
queue_example_string_maxsize_error := ""
try {
    stdlib.queue.Queue("1").full()
} catch TypeError as err {
    queue_example_string_maxsize_error := err.Message
}

queue_example_task_queue := stdlib.queue.Queue()
queue_example_task_queue.put_nowait(1)
queue_example_unfinished_before_done := queue_example_task_queue.unfinished_tasks
queue_example_task_queue.task_done()
queue_example_join_result := queue_example_task_queue.join()
queue_example_unfinished_after_done := queue_example_task_queue.unfinished_tasks
queue_example_timeout_none_queue := stdlib.queue.Queue()
queue_example_timeout_none_put := queue_example_timeout_none_queue.put("none-timeout", true, stdlib.None)
queue_example_timeout_none_value := queue_example_timeout_none_queue.get(true, stdlib.None)
queue_example_timeout_none_queue.task_done()
queue_example_timeout_none_join := queue_example_timeout_none_queue.join()

queue_example_simple := stdlib.queue.SimpleQueue()
queue_example_simple_empty_before := queue_example_simple.empty()
queue_example_simple.put("a")
queue_example_simple.put_nowait("b")
queue_example_simple_put_ignored_timeout := queue_example_simple.put("c", true, -1)
queue_example_simple_first := queue_example_simple.get()
queue_example_simple_second := queue_example_simple.get_nowait()
queue_example_simple_third := queue_example_simple.get(true, stdlib.None)
queue_example_simple_empty_after := queue_example_simple.empty()
queue_example_simple_timeout_error := ""
try {
    stdlib.queue.SimpleQueue().get(true, -1)
} catch ValueError as err {
    queue_example_simple_timeout_error := err.Message
}

queue_example_lifo := stdlib.queue.LifoQueue()
queue_example_lifo.put("a")
queue_example_lifo.put_nowait("b")
queue_example_lifo_first := queue_example_lifo.get_nowait()
queue_example_lifo_second := queue_example_lifo.get()
queue_example_lifo.task_done()
queue_example_lifo.task_done()
queue_example_lifo_join_result := queue_example_lifo.join()
queue_example_lifo_timeout_none_put := queue_example_lifo.put("none-timeout", true, stdlib.None)
queue_example_lifo_timeout_none_value := queue_example_lifo.get(true, stdlib.None)
queue_example_lifo.task_done()
queue_example_lifo_timeout_none_join := queue_example_lifo.join()
queue_example_lifo_empty_error := ""
try {
    stdlib.queue.LifoQueue().get_nowait()
} catch Error as err {
    if err is stdlib.queue.Empty
        queue_example_lifo_empty_error := Type(err)
}

queue_example_priority := stdlib.queue.PriorityQueue()
queue_example_priority.put([2, "b"])
queue_example_priority.put_nowait([1, "a"])
queue_example_priority.put([3, "c"])
queue_example_priority_first := queue_example_priority.get_nowait()
queue_example_priority_second := queue_example_priority.get()
queue_example_priority_third := queue_example_priority.get()
queue_example_priority.task_done()
queue_example_priority.task_done()
queue_example_priority.task_done()
queue_example_priority_join_result := queue_example_priority.join()
queue_example_priority_timeout_none_put := queue_example_priority.put([0, "none-timeout"], true, stdlib.None)
queue_example_priority_timeout_none_value := queue_example_priority.get(true, stdlib.None)
queue_example_priority.task_done()
queue_example_priority_timeout_none_join := queue_example_priority.join()
queue_example_priority_empty_error := ""
try {
    stdlib.queue.PriorityQueue().get_nowait()
} catch Error as err {
    if err is stdlib.queue.Empty
        queue_example_priority_empty_error := Type(err)
}

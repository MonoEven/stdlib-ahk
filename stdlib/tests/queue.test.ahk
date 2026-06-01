#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\queue>

class StdlibQueueTest
{
    static TestQueuePutGetQsizeAndStateMatchPython()
    {
        q := stdlib.queue.Queue(1)

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertFalse(q.full())
        AhkTest.AssertEqual(0, q.qsize())

        q.put(1)

        AhkTest.AssertFalse(q.empty())
        AhkTest.AssertTrue(q.full())
        AhkTest.AssertEqual(1, q.qsize())
        AhkTest.AssertEqual(1, q.get())
        AhkTest.AssertEqual(0, q.qsize())
        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertFalse(q.full())
    }

    static TestQueueNowaitHelpersAndBoundedErrorsFollowPython()
    {
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.Queue().get_nowait())

        fullQueue := stdlib.queue.Queue(1)
        fullQueue.put_nowait(1)
        AhkTest.Raises(stdlib.queue.Full, (*) => fullQueue.put_nowait(2))
        AhkTest.Raises(stdlib.queue.Full, (*) => fullQueue.put(2, false))
        AhkTest.Raises(stdlib.queue.Full, (*) => fullQueue.put(2, true, 0))
    }

    static TestQueueTimeoutValidationAndUnboundedNegativeMaxsizeFollowPython()
    {
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => stdlib.queue.Queue().get(true, -1))

        negativeMaxsize := stdlib.queue.Queue(-1)
        AhkTest.AssertFalse(negativeMaxsize.full())
        negativeMaxsize.put_nowait(1)
        AhkTest.AssertEqual(1, negativeMaxsize.qsize())
        AhkTest.AssertEqual(1, negativeMaxsize.get_nowait())
    }

    static TestQueueTimeoutNoneMatchesPython310ReadyAndNonBlockingPaths()
    {
        q := stdlib.queue.Queue()
        lifo := stdlib.queue.LifoQueue()
        priority := stdlib.queue.PriorityQueue()
        simple := stdlib.queue.SimpleQueue()
        fullQueue := stdlib.queue.Queue(1)
        fullLifo := stdlib.queue.LifoQueue(1)
        fullPriority := stdlib.queue.PriorityQueue(1)

        AhkTest.AssertEqual("", q.put("a", true, stdlib.None))
        AhkTest.AssertEqual("a", q.get(true, stdlib.None))
        AhkTest.AssertEqual("", lifo.put("b", true, stdlib.None))
        AhkTest.AssertEqual("b", lifo.get(true, stdlib.None))
        AhkTest.AssertEqual("", priority.put([1, "c"], true, stdlib.None))
        AhkTest.AssertEqual([1, "c"], priority.get(true, stdlib.None))
        simple.put("d")
        AhkTest.AssertEqual("d", simple.get(true, stdlib.None))

        fullQueue.put_nowait("a")
        fullLifo.put_nowait("b")
        fullPriority.put_nowait([1, "c"])
        AhkTest.Raises(stdlib.queue.Full, (*) => fullQueue.put("x", false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Full, (*) => fullLifo.put("x", false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Full, (*) => fullPriority.put([0, "x"], false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.Queue().get(false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.LifoQueue().get(false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.PriorityQueue().get(false, stdlib.None))
        AhkTest.Raises(stdlib.queue.Empty, (*) => stdlib.queue.SimpleQueue().get(false, stdlib.None))
    }

    static TestQueueMaxsizePassthroughAndTaskAccountingFollowPython()
    {
        floatQueue := stdlib.queue.Queue(1.5)
        stringQueue := stdlib.queue.Queue("1")
        noneQueue := stdlib.queue.Queue(stdlib.None)
        taskQueue := stdlib.queue.Queue()

        AhkTest.AssertEqual(1.5, floatQueue.maxsize)
        AhkTest.AssertEqual("1", stringQueue.maxsize)
        AhkTest.AssertSame(stdlib.None, noneQueue.maxsize)
        AhkTest.AssertFalse(floatQueue.full())
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'int' and 'str'", (*) => stringQueue.full())
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'int' and 'NoneType'", (*) => noneQueue.full())

        taskQueue.put_nowait(1)
        AhkTest.AssertEqual(1, taskQueue.unfinished_tasks)
        taskQueue.task_done()
        AhkTest.AssertEqual(0, taskQueue.unfinished_tasks)
        AhkTest.RaisesMatch(ValueError, "task_done\(\) called too many times", (*) => stdlib.queue.Queue().task_done())
    }

    static TestQueueJoinReturnsWhenAllTasksAreDoneLikePython310()
    {
        emptyQueue := stdlib.queue.Queue()
        taskQueue := stdlib.queue.Queue()

        AhkTest.AssertEqual("", emptyQueue.join())
        taskQueue.put_nowait("work")
        AhkTest.AssertEqual("work", taskQueue.get_nowait())
        taskQueue.task_done()

        AhkTest.AssertEqual("", taskQueue.join())
        AhkTest.RaisesMatch(ValueError, "task_done\(\) called too many times", (*) => taskQueue.task_done())
    }

    static TestSimpleQueueCoveredSurfaceMatchesPython()
    {
        q := stdlib.queue.SimpleQueue()

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertEqual(0, q.qsize())

        q.put("a")
        q.put("b", false)
        q.put("c", true, 0)

        AhkTest.AssertFalse(q.empty())
        AhkTest.AssertEqual(3, q.qsize())
        AhkTest.AssertEqual("a", q.get())
        AhkTest.AssertEqual("b", q.get(false))
        AhkTest.AssertEqual("c", q.get(true, 0))
        AhkTest.AssertTrue(q.empty())
    }

    static TestSimpleQueueEmptyAndTimeoutParityMatchesPython()
    {
        q := stdlib.queue.SimpleQueue()

        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get_nowait())
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(false))
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(false, -1))
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(true, 0))
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => q.get(true, -1))
    }

    static TestSimpleQueuePutIgnoresBlockAndTimeoutLikePython310()
    {
        q := stdlib.queue.SimpleQueue()

        negativeTimeoutResult := q.put("a", true, -1)
        stringTimeoutResult := q.put("b", true, "ignored")
        noneTimeoutResult := q.put("c", false, stdlib.None)

        AhkTest.AssertEqual("", negativeTimeoutResult)
        AhkTest.AssertEqual("", stringTimeoutResult)
        AhkTest.AssertEqual("", noneTimeoutResult)
        AhkTest.AssertEqual(3, q.qsize())
        AhkTest.AssertEqual("a", q.get())
        AhkTest.AssertEqual("b", q.get())
        AhkTest.AssertEqual("c", q.get())
    }

    static TestLifoQueueCoveredSurfaceMatchesPython()
    {
        q := stdlib.queue.LifoQueue(1)

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertFalse(q.full())
        AhkTest.AssertEqual(0, q.qsize())

        q.put("a")

        AhkTest.AssertTrue(q.full())
        AhkTest.AssertEqual("a", q.get_nowait())
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get_nowait())

        q.put("a")
        AhkTest.Raises(stdlib.queue.Full, (*) => q.put_nowait("b"))

        lifo := stdlib.queue.LifoQueue()
        lifo.put("a")
        lifo.put("b")
        lifo.put("c")

        AhkTest.AssertEqual("c", lifo.get())
        AhkTest.AssertEqual("b", lifo.get(false))
        AhkTest.AssertEqual("a", lifo.get(true, 0))
    }

    static TestLifoQueueTimeoutAndBoundedErrorsMatchPython()
    {
        q := stdlib.queue.LifoQueue()

        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(false))
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(true, 0))
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => q.get(true, -1))

        bounded := stdlib.queue.LifoQueue(1)
        bounded.put("a")
        AhkTest.Raises(stdlib.queue.Full, (*) => bounded.put("b", false))
        AhkTest.Raises(stdlib.queue.Full, (*) => bounded.put("b", true, 0))
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => bounded.put("b", true, -1))
        AhkTest.AssertEqual("a", bounded.get_nowait())
    }

    static TestLifoQueueJoinReturnsWhenAllTasksAreDoneLikePython310()
    {
        q := stdlib.queue.LifoQueue()

        AhkTest.AssertEqual("", q.join())
        q.put("a")
        AhkTest.AssertEqual("a", q.get())
        q.task_done()

        AhkTest.AssertEqual("", q.join())
    }

    static TestPriorityQueueCoveredSurfaceMatchesPython()
    {
        q := stdlib.queue.PriorityQueue(1)

        AhkTest.AssertTrue(q.empty())
        AhkTest.AssertFalse(q.full())
        AhkTest.AssertEqual(0, q.qsize())

        q.put([2, "b"])

        AhkTest.AssertTrue(q.full())
        AhkTest.AssertEqual([2, "b"], q.get_nowait())
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get_nowait())

        q.put([2, "b"])
        AhkTest.Raises(stdlib.queue.Full, (*) => q.put_nowait([1, "a"]))

        priority := stdlib.queue.PriorityQueue()
        priority.put([2, "b"])
        priority.put([1, "a"])
        priority.put([3, "c"])
        priority.put([1, "b"])

        AhkTest.AssertEqual([1, "a"], priority.get())
        AhkTest.AssertEqual([1, "b"], priority.get(false))
        AhkTest.AssertEqual([2, "b"], priority.get())
        AhkTest.AssertEqual([3, "c"], priority.get(true, 0))

        numbers := stdlib.queue.PriorityQueue()
        numbers.put(3)
        numbers.put(1)
        numbers.put(2)

        AhkTest.AssertEqual(1, numbers.get())
        AhkTest.AssertEqual(2, numbers.get())
        AhkTest.AssertEqual(3, numbers.get())

        mixed := stdlib.queue.PriorityQueue()
        mixed.put([1, "a"])
        AhkTest.RaisesMatch(TypeError, "'<' not supported between instances of 'int' and 'list'", (*) => mixed.put(2))
    }

    static TestPriorityQueueTimeoutAndBoundedErrorsMatchPython()
    {
        q := stdlib.queue.PriorityQueue()

        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(false))
        AhkTest.Raises(stdlib.queue.Empty, (*) => q.get(true, 0))
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => q.get(true, -1))

        bounded := stdlib.queue.PriorityQueue(1)
        bounded.put([2, "b"])
        AhkTest.Raises(stdlib.queue.Full, (*) => bounded.put([1, "a"], false))
        AhkTest.Raises(stdlib.queue.Full, (*) => bounded.put([1, "a"], true, 0))
        AhkTest.RaisesMatch(ValueError, "'timeout' must be a non-negative number", (*) => bounded.put([1, "a"], true, -1))
        AhkTest.AssertEqual([2, "b"], bounded.get_nowait())
    }

    static TestPriorityQueueJoinReturnsWhenAllTasksAreDoneLikePython310()
    {
        q := stdlib.queue.PriorityQueue()

        AhkTest.AssertEqual("", q.join())
        q.put([1, "a"])
        AhkTest.AssertEqual([1, "a"], q.get())
        q.task_done()

        AhkTest.AssertEqual("", q.join())
    }
}

AhkTest.Collect(StdlibQueueTest)

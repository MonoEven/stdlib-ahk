#Requires AutoHotkey v2.0

#Include <stdlib\init>

; SINGLE-THREAD DEVIATION: CPython's Queue blocks the calling thread when a
; get() on an empty queue (or put() on a full one) would otherwise fail, waiting
; until another thread makes room/data available. AutoHotkey is single-threaded
; here, so there is no other thread to unblock us — a blocking wait would
; deadlock. We therefore treat block=True like block=False: an empty get() or
; full put() raises Empty/Full immediately rather than waiting. timeout is
; validated but never actually waited on. This is an architectural limitation,
; not a bug; code that relies on cross-thread blocking semantics will not port.
class AhkStdlibQueue
{
    class Empty extends Error
    {
    }

    class Full extends Error
    {
    }

    static Queue(maxsize := 0)
    {
        return AhkStdlibQueueQueue(maxsize)
    }

    static SimpleQueue()
    {
        return AhkStdlibQueueSimpleQueue()
    }

    static LifoQueue(maxsize := 0)
    {
        return AhkStdlibQueueLifoQueue(maxsize)
    }

    static PriorityQueue(maxsize := 0)
    {
        return AhkStdlibQueuePriorityQueue(maxsize)
    }
}

class AhkStdlibQueueQueue
{
    __New(maxsize := 0)
    {
        this.maxsize := maxsize
        this.AhkStdlibItems := []
        ; FIFO get() advances AhkStdlibHead instead of shifting the whole array
        ; (RemoveAt(1) is O(n)); the consumed prefix is compacted periodically so
        ; get() is O(1) amortized. Subclasses that pop from the tail (LifoQueue)
        ; or use the heap helpers (PriorityQueue) leave head at 0.
        this.AhkStdlibHead := 0
        this.unfinished_tasks := 0
    }

    qsize()
    {
        return this.AhkStdlibItems.Length - this.AhkStdlibHead
    }

    empty()
    {
        return this.qsize() = 0
    }

    full()
    {
        if AhkStdlibQueueShouldRaiseMaxsizeCompareError(this.maxsize)
            throw TypeError(AhkStdlibQueueMaxsizeCompareError(this.maxsize), -1)
        return 0 < this.maxsize && this.qsize() >= this.maxsize
    }

    put(item, block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        else
            AhkStdlibQueueValidateTimeout(block)
        ; block is honored as immediate-raise (see module-level note): a full
        ; queue raises Full whether or not block is requested.
        if this.full()
            throw AhkStdlibQueue.Full("", -1)

        this.AhkStdlibItems.Push(item)
        this.unfinished_tasks += 1
    }

    put_nowait(item)
    {
        return this.put(item, false)
    }

    get(block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        else
            AhkStdlibQueueValidateTimeout(block)
        ; block is honored as immediate-raise (see module-level note): an empty
        ; queue raises Empty whether or not block is requested.
        if this.empty()
            throw AhkStdlibQueue.Empty("", -1)
        return this.AhkStdlibFifoTake()
    }

    ; O(1) amortized dequeue from the logical front via a head cursor; the dead
    ; prefix is dropped in one RemoveAt once it grows past half the array.
    AhkStdlibFifoTake()
    {
        value := this.AhkStdlibItems[this.AhkStdlibHead + 1]
        this.AhkStdlibHead += 1
        if this.AhkStdlibHead >= 32 && this.AhkStdlibHead * 2 >= this.AhkStdlibItems.Length {
            this.AhkStdlibItems.RemoveAt(1, this.AhkStdlibHead)
            this.AhkStdlibHead := 0
        }
        return value
    }

    get_nowait()
    {
        return this.get(false)
    }

    task_done()
    {
        if this.unfinished_tasks <= 0
            throw ValueError("task_done() called too many times", -1)
        this.unfinished_tasks -= 1
    }

    join()
    {
        while this.unfinished_tasks > 0
            Sleep 10
    }
}

class AhkStdlibQueueSimpleQueue
{
    __New()
    {
        this.AhkStdlibItems := []
        this.AhkStdlibHead := 0
    }

    qsize()
    {
        return this.AhkStdlibItems.Length - this.AhkStdlibHead
    }

    empty()
    {
        return this.qsize() = 0
    }

    put(item, block := true, timeout := unset)
    {
        this.AhkStdlibItems.Push(item)
    }

    put_nowait(item)
    {
        return this.put(item, false)
    }

    get(block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        if this.empty()
            throw AhkStdlibQueue.Empty("", -1)
        ; O(1) amortized FIFO take with periodic prefix compaction.
        value := this.AhkStdlibItems[this.AhkStdlibHead + 1]
        this.AhkStdlibHead += 1
        if this.AhkStdlibHead >= 32 && this.AhkStdlibHead * 2 >= this.AhkStdlibItems.Length {
            this.AhkStdlibItems.RemoveAt(1, this.AhkStdlibHead)
            this.AhkStdlibHead := 0
        }
        return value
    }

    get_nowait()
    {
        return this.get(false)
    }
}

class AhkStdlibQueueLifoQueue extends AhkStdlibQueueQueue
{
    get(block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        else
            AhkStdlibQueueValidateTimeout(block)
        if !block {
            if this.empty()
                throw AhkStdlibQueue.Empty("", -1)
            return this.AhkStdlibItems.Pop()
        }

        if IsSet(timeout) {
            if timeout = 0 && this.empty()
                throw AhkStdlibQueue.Empty("", -1)
        }

        if this.empty()
            throw AhkStdlibQueue.Empty("", -1)

        return this.AhkStdlibItems.Pop()
    }
}

class AhkStdlibQueuePriorityQueue extends AhkStdlibQueueQueue
{
    put(item, block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        else
            AhkStdlibQueueValidateTimeout(block)
        if !block {
            if this.full()
                throw AhkStdlibQueue.Full("", -1)
            AhkStdlibQueuePriorityPush(this.AhkStdlibItems, item)
            this.unfinished_tasks += 1
            return
        }

        if IsSet(timeout) {
            if timeout = 0 && this.full()
                throw AhkStdlibQueue.Full("", -1)
        }

        if this.full()
            throw AhkStdlibQueue.Full("", -1)

        AhkStdlibQueuePriorityPush(this.AhkStdlibItems, item)
        this.unfinished_tasks += 1
    }

    get(block := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibQueueValidateTimeout(block, timeout)
        else
            AhkStdlibQueueValidateTimeout(block)
        if !block {
            if this.empty()
                throw AhkStdlibQueue.Empty("", -1)
            return AhkStdlibQueuePriorityPop(this.AhkStdlibItems)
        }

        if IsSet(timeout) {
            if timeout = 0 && this.empty()
                throw AhkStdlibQueue.Empty("", -1)
        }

        if this.empty()
            throw AhkStdlibQueue.Empty("", -1)

        return AhkStdlibQueuePriorityPop(this.AhkStdlibItems)
    }
}

stdlib.queue := AhkStdlibQueue

AhkStdlibQueueValidateTimeout(block, timeout := unset)
{
    if !IsSet(timeout)
        return
    if AhkStdlibIsNone(timeout)
        return
    if !block
        return
    if !(timeout is Number) || timeout < 0
        throw ValueError("'timeout' must be a non-negative number", -1)
}

AhkStdlibQueuePythonTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    if value is Array
        return "list"
    if value is Map
        return "dict"
    if IsObject(value) && Type(value) != "Object" {
        dot := InStr(Type(value), ".", false, -1)
        if dot
            return SubStr(Type(value), dot + 1)
        return Type(value)
    }
    if IsObject(value)
        return "object"
    return Type(value)
}

AhkStdlibQueueShouldRaiseMaxsizeCompareError(value)
{
    if value is Integer || value is Float
        return false
    return true
}

AhkStdlibQueueMaxsizeCompareError(value)
{
    return "'<' not supported between instances of 'int' and '" AhkStdlibQueuePythonTypeName(value) "'"
}

AhkStdlibQueuePriorityPush(heap, item)
{
    heap.Push(item)
    AhkStdlibQueuePrioritySiftDown(heap, 1, heap.Length)
}

AhkStdlibQueuePriorityPop(heap)
{
    lastItem := heap.Pop()
    if heap.Length {
        returnItem := heap[1]
        heap[1] := lastItem
        AhkStdlibQueuePrioritySiftUp(heap, 1)
        return returnItem
    }
    return lastItem
}

AhkStdlibQueuePrioritySiftDown(heap, startIndex, index)
{
    ; Delegates to the shared heap core with the priority comparator.
    AhkStdlibHeapSiftDown(heap, startIndex, index, (a, b) => AhkStdlibQueuePriorityLess(a, b))
}

AhkStdlibQueuePrioritySiftUp(heap, index)
{
    AhkStdlibHeapSiftUp(heap, index, (a, b) => AhkStdlibQueuePriorityLess(a, b))
}

AhkStdlibQueuePriorityLess(left, right)
{
    return AhkStdlibQueuePriorityCompare(left, right) < 0
}

AhkStdlibQueuePriorityCompare(left, right)
{
    if !IsObject(left) && !IsObject(right) {
        if left is Number && right is Number
            return left = right ? 0 : (left < right ? -1 : 1)
        if left is String && right is String
            return StrCompare(left, right)
        throw TypeError(AhkStdlibQueuePriorityComparisonError(left, right), -1)
    }

    if left is Array && right is Array {
        sharedLength := Min(left.Length, right.Length)
        loop sharedLength {
            comparison := AhkStdlibQueuePriorityCompare(left[A_Index], right[A_Index])
            if comparison != 0
                return comparison
        }
        if left.Length = right.Length
            return 0
        return left.Length < right.Length ? -1 : 1
    }

    throw TypeError(AhkStdlibQueuePriorityComparisonError(left, right), -1)
}

AhkStdlibQueuePriorityComparisonError(left, right)
{
    return "'<' not supported between instances of '" AhkStdlibQueuePythonTypeName(left) "' and '" AhkStdlibQueuePythonTypeName(right) "'"
}

#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCollectionsHeapq
{
    static heappush(heap, item)
    {
        AhkStdlibHeapqCheckList(heap, "heappush() argument 1")
        heap.Push(item)
        AhkStdlibHeapqSiftDown(heap, 1, heap.Length)
    }

    static heappop(heap)
    {
        AhkStdlibHeapqCheckList(heap, "heappop() argument")
        if heap.Length = 0
            throw IndexError("index out of range", -1)

        lastItem := heap.Pop()
        if heap.Length {
            returnItem := heap[1]
            heap[1] := lastItem
            AhkStdlibHeapqSiftUp(heap, 1)
            return returnItem
        }
        return lastItem
    }

    static heapify(x)
    {
        AhkStdlibHeapqCheckList(x, "heapify() argument")
        index := x.Length // 2
        while index >= 1 {
            AhkStdlibHeapqSiftUp(x, index)
            index -= 1
        }
    }

    static heapreplace(heap, item)
    {
        AhkStdlibHeapqCheckList(heap, "heapreplace() argument")
        if heap.Length = 0
            throw IndexError("index out of range", -1)

        returnItem := heap[1]
        heap[1] := item
        AhkStdlibHeapqSiftUp(heap, 1)
        return returnItem
    }

    static heappushpop(heap, item)
    {
        AhkStdlibHeapqCheckList(heap, "heappushpop() argument")
        if heap.Length && heap[1] < item {
            returnItem := heap[1]
            heap[1] := item
            AhkStdlibHeapqSiftUp(heap, 1)
            return returnItem
        }
        return item
    }
}

stdlib.heapq := AhkStdlibCollectionsHeapq

AhkStdlibHeapqCheckList(value, label)
{
    if !(value is Array)
        throw TypeError(label " must be list, not " Type(value), -1)
}

AhkStdlibHeapqSiftDown(heap, startIndex, index)
{
    newItem := heap[index]
    while index > startIndex {
        parentIndex := index // 2
        parent := heap[parentIndex]
        if newItem < parent {
            heap[index] := parent
            index := parentIndex
            continue
        }
        break
    }
    heap[index] := newItem
}

AhkStdlibHeapqSiftUp(heap, index)
{
    endIndex := heap.Length
    startIndex := index
    newItem := heap[index]
    childIndex := index * 2

    while childIndex <= endIndex {
        rightIndex := childIndex + 1
        if rightIndex <= endIndex && !(heap[childIndex] < heap[rightIndex])
            childIndex := rightIndex

        heap[index] := heap[childIndex]
        index := childIndex
        childIndex := index * 2
    }

    heap[index] := newItem
    AhkStdlibHeapqSiftDown(heap, startIndex, index)
}

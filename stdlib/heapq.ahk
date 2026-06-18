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

    static nlargest(n, iterable, key := unset)
    {
        return AhkStdlibHeapqNlargest(n, iterable, key?)
    }

    static nsmallest(n, iterable, key := unset)
    {
        return AhkStdlibHeapqNsmallest(n, iterable, key?)
    }

    static merge(iterables*)
    {
        return AhkStdlibHeapqMerge(iterables)
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
    ; Delegates to the shared heap core with native '<' ordering.
    AhkStdlibHeapSiftDown(heap, startIndex, index, (a, b) => a < b)
}

AhkStdlibHeapqSiftUp(heap, index)
{
    AhkStdlibHeapSiftUp(heap, index, (a, b) => a < b)
}

AhkStdlibHeapqToArray(iterable)
{
    if iterable is Array
        return iterable.Clone()
    if iterable is String {
        values := []
        loop Parse iterable
            values.Push(A_LoopField)
        return values
    }
    if IsObject(iterable) && HasMethod(iterable, "__Enum") {
        values := []
        for value in iterable
            values.Push(value)
        return values
    }
    throw TypeError("'" Type(iterable) "' object is not iterable", -1)
}

AhkStdlibHeapqKeyOf(value, key := unset)
{
    if IsSet(key)
        return key.Call(value)
    return value
}

AhkStdlibHeapqSortByKey(values, key := unset, descending := false)
{
    AhkStdlibHeapqMergeSort(values, 1, values.Length, key?, descending)
}

AhkStdlibHeapqMergeSort(arr, lo, hi, key := unset, descending := false)
{
    if hi - lo < 1
        return
    mid := (lo + hi) // 2
    AhkStdlibHeapqMergeSort(arr, lo, mid, key?, descending)
    AhkStdlibHeapqMergeSort(arr, mid + 1, hi, key?, descending)

    merged := []
    i := lo
    j := mid + 1
    while i <= mid && j <= hi {
        leftKey := AhkStdlibHeapqKeyOf(arr[i], key?)
        rightKey := AhkStdlibHeapqKeyOf(arr[j], key?)
        takeLeft := descending ? !(leftKey < rightKey) : !(rightKey < leftKey)
        if takeLeft {
            merged.Push(arr[i])
            i += 1
        } else {
            merged.Push(arr[j])
            j += 1
        }
    }
    while i <= mid {
        merged.Push(arr[i])
        i += 1
    }
    while j <= hi {
        merged.Push(arr[j])
        j += 1
    }
    for offset, value in merged
        arr[lo + offset - 1] := value
}

AhkStdlibHeapqNlargest(n, iterable, key := unset)
{
    values := AhkStdlibHeapqToArray(iterable)
    if n <= 0
        return []
    AhkStdlibHeapqSortByKey(values, key?, true)
    result := []
    loop Min(n, values.Length)
        result.Push(values[A_Index])
    return result
}

AhkStdlibHeapqNsmallest(n, iterable, key := unset)
{
    values := AhkStdlibHeapqToArray(iterable)
    if n <= 0
        return []
    AhkStdlibHeapqSortByKey(values, key?, false)
    result := []
    loop Min(n, values.Length)
        result.Push(values[A_Index])
    return result
}

AhkStdlibHeapqMerge(iterables)
{
    key := unset
    reverse := false
    if iterables.Length > 0 {
        last := iterables[iterables.Length]
        if AhkStdlibHeapqIsOptionsObject(last) {
            if HasProp(last, "key") && !AhkStdlibIsNone(last.key)
                key := last.key
            if HasProp(last, "reverse")
                reverse := AhkStdlibTruthValue(last.reverse)
            iterables := AhkStdlibHeapqWithoutLast(iterables)
        }
    }

    merged := []
    for iterable in iterables {
        for value in AhkStdlibHeapqToArray(iterable)
            merged.Push(value)
    }
    AhkStdlibHeapqSortByKey(merged, key?, reverse)
    return merged
}

AhkStdlibHeapqIsOptionsObject(value)
{
    if !IsObject(value) || Type(value) != "Object"
        return false
    return HasProp(value, "key") || HasProp(value, "reverse")
}

AhkStdlibHeapqWithoutLast(items)
{
    result := []
    loop items.Length - 1
        result.Push(items[A_Index])
    return result
}

#Requires AutoHotkey v2.0

class stdlib
{
    static None := AhkStdlibNone()
    static NotImplemented := AhkStdlibNotImplemented()
    static True := AhkStdlibBool(true)
    static False := AhkStdlibBool(false)

    static NotImplementedError
    {
        get => NotImplementedError
    }

    static NotImplementedError(args*)
    {
        return NotImplementedError(args*)
    }

    static RuntimeError
    {
        get => RuntimeError
    }

    static RuntimeError(args*)
    {
        return RuntimeError(args*)
    }

    static StopIteration
    {
        get => StopIteration
    }

    static StopIteration(args*)
    {
        return StopIteration(args*)
    }

    static KeyError
    {
        get => KeyError
    }

    static KeyError(args*)
    {
        return KeyError(args*)
    }

    static AttributeError
    {
        get => AttributeError
    }

    static AttributeError(args*)
    {
        return AttributeError(args*)
    }

    static SystemError
    {
        get => SystemError
    }

    static SystemError(args*)
    {
        return SystemError(args*)
    }

    static SyntaxError
    {
        get => SyntaxError
    }

    static SyntaxError(args*)
    {
        return SyntaxError(args*)
    }

    static ModuleNotFoundError
    {
        get => ModuleNotFoundError
    }

    static ModuleNotFoundError(args*)
    {
        return ModuleNotFoundError(args*)
    }

    static OverflowError
    {
        get => OverflowError
    }

    static OverflowError(args*)
    {
        return OverflowError(args*)
    }

    static EOFError
    {
        get => EOFError
    }

    static EOFError(args*)
    {
        return EOFError(args*)
    }

    static ProcessLookupError
    {
        get => ProcessLookupError
    }

    static ProcessLookupError(args*)
    {
        return ProcessLookupError(args*)
    }

    static tuple(iterable := unset)
    {
        if !IsSet(iterable)
            return AhkStdlibTuple()
        return AhkStdlibTupleFrom(iterable)
    }

    static slice(args*)
    {
        return AhkStdlibSlice(args*)
    }

    static await(value, options?)
    {
        return AhkStdlibAwait(value, options?)
    }

    static decorate(target, decorators*)
    {
        return AhkStdlibDecorate(target, decorators*)
    }
}

class NotImplementedError extends Error
{
}

class RuntimeError extends Error
{
}

class StopIteration extends Error
{
}

class KeyError extends Error
{
}

class AttributeError extends Error
{
}

class SystemError extends Error
{
}

class SyntaxError extends Error
{
}

class ModuleNotFoundError extends Error
{
}

class OverflowError extends Error
{
}

class EOFError extends Error
{
}

class ProcessLookupError extends OSError
{
}

AhkStdlibNone()
{
    static value := { __AhkStdlibNone: true }
    return value
}

AhkStdlibNotImplemented()
{
    static value := { __AhkStdlibNotImplemented: true }
    return value
}

class AhkStdlibBoolean
{
    __New(value)
    {
        this.Value := value ? true : false
    }
}

AhkStdlibBool(value)
{
    static trueValue := AhkStdlibBoolean(true)
    static falseValue := AhkStdlibBoolean(false)
    return value ? trueValue : falseValue
}

AhkStdlibIsNone(value)
{
    return IsObject(value) && !(value !== AhkStdlibNone())
}

AhkStdlibIsNotImplemented(value)
{
    return IsObject(value) && !(value !== AhkStdlibNotImplemented())
}

AhkStdlibIsBool(value)
{
    return value is AhkStdlibBoolean
}

AhkStdlibTruthValue(value)
{
    if AhkStdlibIsBool(value)
        return value.Value
    if AhkStdlibIsNone(value)
        return false
    if value is Array
        return value.Length != 0
    if value is Map
        return value.Count != 0
    return value ? true : false
}

class AhkStdlibSlice
{
    __New(args*)
    {
        if args.Length = 0
            throw TypeError("slice expected at least 1 argument, got 0", -1)
        if args.Length > 3
            throw TypeError("slice expected at most 3 arguments, got " args.Length, -1)

        if args.Length = 1 {
            this.start := stdlib.None
            this.stop := args[1]
            this.step := stdlib.None
            return
        }

        this.start := args[1]
        this.stop := args[2]
        this.step := args.Length = 3 ? args[3] : stdlib.None
    }

    indices(args*)
    {
        if args.Length != 1
            throw TypeError("slice.indices() takes exactly one argument (" args.Length " given)", -1)
        length := AhkStdlibSliceIndex(args[1])
        if length < 0
            throw ValueError("length should not be negative", -1)

        step := AhkStdlibIsNone(this.step) ? 1 : AhkStdlibSliceIndex(this.step)
        if step = 0
            throw ValueError("slice step cannot be zero", -1)

        if step > 0 {
            start := AhkStdlibIsNone(this.start) ? 0 : AhkStdlibSliceIndex(this.start)
            if start < 0
                start += length
            if start < 0
                start := 0
            else if start > length
                start := length

            stop := AhkStdlibIsNone(this.stop) ? length : AhkStdlibSliceIndex(this.stop)
            if stop < 0
                stop += length
            if stop < 0
                stop := 0
            else if stop > length
                stop := length
            return stdlib.tuple([start, stop, step])
        }

        start := AhkStdlibIsNone(this.start) ? length - 1 : AhkStdlibSliceIndex(this.start)
        if start < 0
            start += length
        if start < 0
            start := -1
        else if start >= length
            start := length - 1

        if AhkStdlibIsNone(this.stop)
            stop := -1
        else {
            stop := AhkStdlibSliceIndex(this.stop)
            if stop < 0
                stop += length
            if stop < 0
                stop := -1
            else if stop >= length
                stop := length - 1
        }
        return stdlib.tuple([start, stop, step])
    }

    __Repr()
    {
        return "slice(" AhkStdlibSliceValueRepr(this.start) ", " AhkStdlibSliceValueRepr(this.stop) ", " AhkStdlibSliceValueRepr(this.step) ")"
    }
}

class AhkStdlibTuple extends Array
{
    __New(values := unset)
    {
        this.AhkStdlibInitializing := true
        if IsSet(values) {
            for value in values
                super.Push(value)
        }
        this.AhkStdlibInitializing := false
    }

    __Item[index]
    {
        get => super[index]
        set => AhkStdlibTupleMutation()
    }

    Length {
        get => super.Length
        set => AhkStdlibTupleMutation()
    }

    Push(values*)
    {
        if this.AhkStdlibInitializing
            return super.Push(values*)
        AhkStdlibTupleMutation()
    }

    Pop()
    {
        AhkStdlibTupleMutation()
    }

    InsertAt(index, values*)
    {
        AhkStdlibTupleMutation()
    }

    RemoveAt(index, length?)
    {
        AhkStdlibTupleMutation()
    }

    Delete(index)
    {
        AhkStdlibTupleMutation()
    }
}

AhkStdlibTupleFrom(iterable)
{
    if iterable is AhkStdlibTuple
        return iterable

    values := []
    if iterable is String {
        loop parse iterable
            values.Push(A_LoopField)
        return AhkStdlibTuple(values)
    }

    if IsObject(iterable) && HasMethod(iterable, "__Enum") {
        for value in iterable
            values.Push(value)
        return AhkStdlibTuple(values)
    }

    throw TypeError("'" AhkStdlibPythonTypeName(iterable) "' object is not iterable", -1)
}

AhkStdlibTupleMutation()
{
    throw TypeError("'tuple' object does not support item assignment", -1)
}

AhkStdlibSliceIndex(value)
{
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    if value is Integer
        return value
    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibSliceValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return "'" StrReplace(StrReplace(value, "\", "\\"), "'", "\'") "'"
    return String(value)
}

AhkStdlibAwait(value, options := unset)
{
    if IsObject(value) && Type(value) = "AhkStdlibThreadFuture" {
        if IsSet(options) && Type(options) = "Object" && options.HasOwnProp("timeout")
            return value.result(options.timeout)
        return value.result()
    }

    if !HasProp(stdlib, "asyncio")
        throw RuntimeError("stdlib.await() requires stdlib.asyncio to be loaded", -1)

    runningLoop := stdlib.asyncio._get_running_loop()
    if !AhkStdlibIsNone(runningLoop)
        throw RuntimeError("stdlib.await() cannot block while an asyncio loop is already running", -1)

    if IsSet(options) && Type(options) = "Object" && options.HasOwnProp("loop")
        return options.loop.run_until_complete(value)

    return stdlib.asyncio.run(value)
}

AhkStdlibDecorate(target, decorators*)
{
    decorated := target
    index := decorators.Length
    while index >= 1 {
        decorator := decorators[index]
        if !IsObject(decorator) || !HasMethod(decorator, "Call")
            throw TypeError("'" AhkStdlibPythonTypeName(decorator) "' object is not callable", -1)
        decorated := decorator.Call(decorated)
        index -= 1
    }
    return decorated
}

AhkStdlibPythonTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsNotImplemented(value)
        return "NotImplementedType"
    if AhkStdlibIsBool(value)
        return "bool"
    if value is Map
        return "dict"
    if value is Array
        return "list"
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    typeName := Type(value)
    if typeName = "Func" || typeName = "BoundFunc"
        return "function"
    if IsObject(value) && typeName != "Object"
        return AhkStdlibLeafTypeName(typeName)
    if IsObject(value)
        return "object"
    return typeName
}

AhkStdlibLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}

; Shared binary-heap core (min-heap). heapq and queue.PriorityQueue both need
; the identical sift logic; they differ only in how two items compare, so the
; comparator is injected as `less(a, b) -> bool`. Operating on a 1-based AHK
; Array, matching CPython's list-backed heap.
AhkStdlibHeapSiftDown(heap, startIndex, index, less)
{
    newItem := heap[index]
    while index > startIndex {
        parentIndex := index // 2
        parent := heap[parentIndex]
        if less(newItem, parent) {
            heap[index] := parent
            index := parentIndex
            continue
        }
        break
    }
    heap[index] := newItem
}

AhkStdlibHeapSiftUp(heap, index, less)
{
    endIndex := heap.Length
    startIndex := index
    newItem := heap[index]
    childIndex := index * 2

    while childIndex <= endIndex {
        rightIndex := childIndex + 1
        if rightIndex <= endIndex && !less(heap[childIndex], heap[rightIndex])
            childIndex := rightIndex

        heap[index] := heap[childIndex]
        index := childIndex
        childIndex := index * 2
    }

    heap[index] := newItem
    AhkStdlibHeapSiftDown(heap, startIndex, index, less)
}

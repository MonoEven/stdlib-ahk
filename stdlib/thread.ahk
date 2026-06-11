#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\json>

class AhkStdlibThread
{
    class Empty extends Error
    {
    }

    class BrokenBarrierError extends RuntimeError
    {
    }

    class CancelledError extends Error
    {
    }

    class TimeoutError extends Error
    {
    }

    static ExceptHookArgs := AhkStdlibThreadExceptHookArgsClass
    static TIMEOUT_MAX := 4294967.0
    static ThreadError := RuntimeError

    static Lock()
    {
        return AhkStdlibThreadLock()
    }

    static allocate_lock()
    {
        return AhkStdlibThreadLock()
    }

    static RLock()
    {
        return AhkStdlibThreadRLock()
    }

    static Semaphore(value := 1)
    {
        return AhkStdlibThreadSemaphore(value)
    }

    static BoundedSemaphore(value := 1)
    {
        return AhkStdlibThreadBoundedSemaphore(value)
    }

    static Channel()
    {
        return AhkStdlibThreadChannel()
    }

    static SharedMemory(options := unset)
    {
        return IsSet(options) ? AhkStdlibThreadSharedMemory(options) : AhkStdlibThreadSharedMemory()
    }

    static SharedObject(value)
    {
        return AhkStdlibThreadSharedObject(value)
    }

    static Condition(lock := unset)
    {
        return IsSet(lock) ? AhkStdlibThreadCondition(lock) : AhkStdlibThreadCondition()
    }

    static Event()
    {
        return AhkStdlibThreadEvent()
    }

    static Future()
    {
        return AhkStdlibThreadFuture()
    }

    static Barrier(parties, action := unset, timeout := unset)
    {
        if IsSet(action) && IsSet(timeout)
            return AhkStdlibThreadBarrier(parties, action, timeout)
        if IsSet(action)
            return AhkStdlibThreadBarrier(parties, action)
        if IsSet(timeout)
            return AhkStdlibThreadBarrier(parties, unset, timeout)
        return AhkStdlibThreadBarrier(parties)
    }

    static Thread(options := unset)
    {
        return IsSet(options) ? AhkStdlibThreadWorker(options) : AhkStdlibThreadWorker()
    }

    static ThreadPool(options := unset)
    {
        return IsSet(options) ? AhkStdlibThreadPool(options) : AhkStdlibThreadPool()
    }

    static Timer(interval, function, args := unset, kwargs := unset)
    {
        options := { name: "Timer", source: "thread_result := stdlib.json.Null" }
        if IsSet(function) && HasMethod(function, "Call")
            options.source := "thread_result := stdlib.json.Null"
        return AhkStdlibThreadTimer(interval, function, args?, kwargs?)
    }

    static WeakSet(data := unset)
    {
        return IsSet(data) ? AhkStdlibThreadWeakSet(data) : AhkStdlibThreadWeakSet()
    }

    static ResultQueue()
    {
        return AhkStdlibThreadResultQueue()
    }

    static start(options)
    {
        worker := AhkStdlibThreadWorker(options)
        worker.start()
        return worker
    }

    static current_thread()
    {
        return AhkStdlibThreadMainThreadSingleton()
    }

    static currentThread()
    {
        return this.current_thread()
    }

    static current_channel()
    {
        return AhkStdlibThreadCurrentChannelSlot()
    }

    static current_shared_memory()
    {
        return AhkStdlibThreadCurrentSharedMemorySlot()
    }

    static current_shared_object(name := unset)
    {
        objects := AhkStdlibThreadCurrentSharedObjectSlot()
        if !IsSet(name)
            return objects
        if objects is Map && objects.Has(name)
            return objects[name]
        throw RuntimeError("shared object is not available: " name, -1)
    }

    static main_thread()
    {
        return AhkStdlibThreadMainThreadSingleton()
    }

    static active_count()
    {
        return this.enumerate().Length
    }

    static activeCount()
    {
        return this.active_count()
    }

    static enumerate()
    {
        return [AhkStdlibThreadMainThreadSingleton()]
    }

    static get_ident()
    {
        return DllCall("kernel32\GetCurrentThreadId", "UInt")
    }

    static get_native_id()
    {
        return DllCall("kernel32\GetCurrentThreadId", "UInt")
    }

    static local()
    {
        return AhkStdlibThreadLocal()
    }

    static settrace(func)
    {
        AhkStdlibThreadTraceSlot(func)
        return stdlib.None
    }

    static gettrace()
    {
        return AhkStdlibThreadTraceSlot()
    }

    static setprofile(func)
    {
        AhkStdlibThreadProfileSlot(func)
        return stdlib.None
    }

    static getprofile()
    {
        return AhkStdlibThreadProfileSlot()
    }

    static stack_size(size := unset)
    {
        if !IsSet(size)
            return AhkStdlibThreadStackSizeSlot()
        previous := AhkStdlibThreadStackSizeSlot()
        if size != 0 && size < 32768
            throw ValueError("size not valid: " size, -1)
        AhkStdlibThreadStackSizeSlot(size)
        return previous
    }

    static excepthook(args)
    {
        return stdlib.None
    }
}

stdlib.thread := AhkStdlibThread

AhkStdlibThreadMainThreadSingleton()
{
    static value := AhkStdlibThreadMainThread()
    return value
}

AhkStdlibThreadTraceSlot(value := unset)
{
    static trace := stdlib.None
    if IsSet(value)
        trace := value
    return trace
}

AhkStdlibThreadProfileSlot(value := unset)
{
    static profile := stdlib.None
    if IsSet(value)
        profile := value
    return profile
}

AhkStdlibThreadStackSizeSlot(value := unset)
{
    static stackSize := 0
    if IsSet(value)
        stackSize := value
    return stackSize
}

AhkStdlibThreadCurrentChannelSlot(value := unset)
{
    static channel := stdlib.None
    if IsSet(value)
        channel := value
    return channel
}

AhkStdlibThreadSetCurrentChannel(channel)
{
    AhkStdlibThreadCurrentChannelSlot(channel)
    return stdlib.None
}

AhkStdlibThreadCurrentSharedMemorySlot(value := unset)
{
    static memory := stdlib.None
    if IsSet(value)
        memory := value
    return memory
}

AhkStdlibThreadSetCurrentSharedMemory(memory)
{
    AhkStdlibThreadCurrentSharedMemorySlot(memory)
    return stdlib.None
}

AhkStdlibThreadCurrentSharedObjectSlot(value := unset)
{
    static objects := Map()
    if IsSet(value)
        objects := value
    return objects
}

AhkStdlibThreadSetCurrentSharedObjects(objects)
{
    AhkStdlibThreadCurrentSharedObjectSlot(objects)
    return stdlib.None
}

class AhkStdlibThreadMainThread
{
    __New()
    {
        this.name := "MainThread"
        this.ident := DllCall("kernel32\GetCurrentThreadId", "UInt")
        this.native_id := this.ident
        this.pid := DllCall("kernel32\GetCurrentProcessId", "UInt")
        this.daemon := false
    }

    is_alive()
    {
        return true
    }

    join(timeout := unset)
    {
        throw RuntimeError("cannot join current thread", -1)
    }
}

class AhkStdlibThreadExceptHookArgsClass
{
    static Call(thisClass, iterable := unset)
    {
        return IsSet(iterable) ? AhkStdlibThreadExceptHookArgs(iterable) : AhkStdlibThreadExceptHookArgs()
    }
}

class AhkStdlibThreadExceptHookArgs extends Array
{
    __New(iterable := unset)
    {
        if IsSet(iterable) {
            for value in iterable
                super.Push(value)
        }
        while this.Length < 4
            super.Push(stdlib.None)
        this.exc_type := this[1]
        this.exc_value := this[2]
        this.exc_traceback := this[3]
        this.thread := this[4]
    }
}

class AhkStdlibThreadLock
{
    __New()
    {
        this.AhkStdlibLocked := false
    }

    acquire(blocking := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibThreadTimeoutToMilliseconds(timeout)
        if !this.AhkStdlibLocked {
            this.AhkStdlibLocked := true
            return true
        }
        return false
    }

    release()
    {
        if !this.AhkStdlibLocked
            throw RuntimeError("release unlocked lock", -1)
        this.AhkStdlibLocked := false
        return stdlib.None
    }

    locked()
    {
        return this.AhkStdlibLocked
    }
}

class AhkStdlibThreadRLock
{
    __New()
    {
        this.AhkStdlibOwner := 0
        this.AhkStdlibCount := 0
    }

    acquire(blocking := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibThreadTimeoutToMilliseconds(timeout)
        current := DllCall("kernel32\GetCurrentThreadId", "UInt")
        if this.AhkStdlibCount = 0 || this.AhkStdlibOwner = current {
            this.AhkStdlibOwner := current
            this.AhkStdlibCount += 1
            return true
        }
        return false
    }

    release()
    {
        current := DllCall("kernel32\GetCurrentThreadId", "UInt")
        if this.AhkStdlibCount = 0 || this.AhkStdlibOwner != current
            throw RuntimeError("cannot release un-acquired lock", -1)
        this.AhkStdlibCount -= 1
        if this.AhkStdlibCount = 0
            this.AhkStdlibOwner := 0
        return stdlib.None
    }

    AhkStdlibIsOwned()
    {
        return this.AhkStdlibCount > 0 && this.AhkStdlibOwner = DllCall("kernel32\GetCurrentThreadId", "UInt")
    }
}

class AhkStdlibThreadSemaphore
{
    __New(value := 1)
    {
        if value < 0
            throw ValueError("semaphore initial value must be >= 0", -1)
        this.AhkStdlibValue := value
    }

    acquire(blocking := true, timeout := unset)
    {
        if IsSet(timeout)
            AhkStdlibThreadTimeoutToMilliseconds(timeout)
        if this.AhkStdlibValue > 0 {
            this.AhkStdlibValue -= 1
            return true
        }
        return false
    }

    release(n := 1)
    {
        if n < 1
            throw ValueError("n must be one or more", -1)
        this.AhkStdlibValue += n
        return stdlib.None
    }
}

class AhkStdlibThreadBoundedSemaphore extends AhkStdlibThreadSemaphore
{
    __New(value := 1)
    {
        super.__New(value)
        this.AhkStdlibInitialValue := value
    }

    release(n := 1)
    {
        if this.AhkStdlibValue + n > this.AhkStdlibInitialValue
            throw ValueError("Semaphore released too many times", -1)
        return super.release(n)
    }
}

class AhkStdlibThreadCondition
{
    __New(lock := unset)
    {
        this.AhkStdlibLock := IsSet(lock) ? lock : AhkStdlibThreadRLock()
    }

    acquire(args*)
    {
        return this.AhkStdlibLock.acquire(args*)
    }

    release()
    {
        return this.AhkStdlibLock.release()
    }

    wait(timeout := unset)
    {
        if !this.AhkStdlibOwnsLock()
            throw RuntimeError("cannot wait on un-acquired lock", -1)
        if IsSet(timeout)
            AhkStdlibThreadTimeoutToMilliseconds(timeout)
        return false
    }

    wait_for(predicate, timeout := unset)
    {
        if !this.AhkStdlibOwnsLock()
            throw RuntimeError("cannot wait on un-acquired lock", -1)
        if IsSet(timeout)
            AhkStdlibThreadTimeoutToMilliseconds(timeout)
        return AhkStdlibTruthValue(predicate.Call())
    }

    notify(n := 1)
    {
        if !this.AhkStdlibOwnsLock()
            throw RuntimeError("cannot notify on un-acquired lock", -1)
        return stdlib.None
    }

    notify_all()
    {
        return this.notify()
    }

    notifyAll()
    {
        return this.notify_all()
    }

    AhkStdlibOwnsLock()
    {
        if HasMethod(this.AhkStdlibLock, "AhkStdlibIsOwned")
            return this.AhkStdlibLock.AhkStdlibIsOwned()
        if HasMethod(this.AhkStdlibLock, "locked")
            return this.AhkStdlibLock.locked()
        return false
    }
}

class AhkStdlibThreadBarrier
{
    __New(parties, action := unset, timeout := unset)
    {
        if parties <= 0
            throw ValueError("parties must be greater than 0", -1)
        this.parties := parties
        this.action := IsSet(action) ? action : stdlib.None
        this.timeout := IsSet(timeout) ? timeout : stdlib.None
        this.n_waiting := 0
        this.broken := false
    }

    wait(timeout := unset)
    {
        if this.broken
            throw AhkStdlibThread.BrokenBarrierError("", -1)
        if this.parties = 1 {
            if HasMethod(this.action, "Call")
                this.action.Call()
            return 0
        }
        if IsSet(timeout) && timeout = 0 {
            this.broken := true
            throw AhkStdlibThread.BrokenBarrierError("", -1)
        }
        this.n_waiting += 1
        return 0
    }

    reset()
    {
        this.n_waiting := 0
        this.broken := false
        return stdlib.None
    }

    abort()
    {
        this.broken := true
        this.n_waiting := 0
        return stdlib.None
    }
}

class AhkStdlibThreadLocal
{
}

class AhkStdlibThreadChannel
{
    __New(root := unset)
    {
        if IsSet(root)
            this.AhkStdlibRoot := root
        else
            this.AhkStdlibRoot := A_Temp "\stdlib-thread-channel-" DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999)
        this.AhkStdlibMainToWorker := this.AhkStdlibRoot "\main-to-worker"
        this.AhkStdlibWorkerToMain := this.AhkStdlibRoot "\worker-to-main"
        this.AhkStdlibMainSeq := 0
        this.AhkStdlibWorkerSeq := 0
        this.AhkStdlibClosed := false
        DirCreate this.AhkStdlibMainToWorker
        DirCreate this.AhkStdlibWorkerToMain
    }

    send(value)
    {
        return this.AhkStdlibSendTo(this.AhkStdlibMainToWorker, "main", value)
    }

    recv(timeout := unset)
    {
        return this.AhkStdlibRecvFrom(this.AhkStdlibWorkerToMain, timeout?)
    }

    send_worker(value)
    {
        return this.AhkStdlibSendTo(this.AhkStdlibWorkerToMain, "worker", value)
    }

    recv_worker(timeout := unset)
    {
        return this.AhkStdlibRecvFrom(this.AhkStdlibMainToWorker, timeout?)
    }

    close()
    {
        this.AhkStdlibClosed := true
        try DirDelete this.AhkStdlibRoot, true
        return stdlib.None
    }

    AhkStdlibSendTo(directory, prefix, value)
    {
        if this.AhkStdlibClosed
            throw RuntimeError("channel is closed", -1)
        seq := prefix = "main" ? (this.AhkStdlibMainSeq += 1) : (this.AhkStdlibWorkerSeq += 1)
        stamp := Format("{:012}", seq) "-" DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999)
        tempPath := directory "\" stamp ".tmp"
        finalPath := directory "\" stamp ".json"
        FileAppend stdlib.json.dumps(value), tempPath, "UTF-8"
        FileMove tempPath, finalPath, 1
        return stdlib.None
    }

    AhkStdlibRecvFrom(directory, timeout := unset)
    {
        deadline := IsSet(timeout) ? A_TickCount + AhkStdlibThreadTimeoutToMilliseconds(timeout) : ""
        loop {
            path := AhkStdlibThreadFirstJsonFile(directory)
            if path != "" {
                try {
                    value := stdlib.json.load(path)
                    FileDelete path
                    return value
                } catch OSError as err {
                    if !AhkStdlibThreadIsTransientFileAccessError(err)
                        throw err
                }
            }
            if IsSet(timeout) && A_TickCount >= deadline
                throw AhkStdlibThread.Empty("", -1)
            Sleep 10
        }
    }
}

class AhkStdlibThreadSharedMemory
{
    __New(options := unset)
    {
        this.name := ""
        this.size := 0
        this.AhkStdlibHandle := 0
        this.AhkStdlibView := 0
        this.AhkStdlibClosed := false

        if !IsSet(options)
            options := { size: 4096 }
        if options is Integer
            options := { size: options }
        if options is String
            options := { name: options, size: 4096 }
        if Type(options) != "Object"
            throw TypeError("SharedMemory() expected an options object", -1)

        if options.HasOwnProp("name")
            this.name := options.name
        if options.HasOwnProp("size")
            this.size := Integer(options.size)
        if this.size <= 0
            throw ValueError("shared memory size must be greater than 0", -1)
        if this.name = ""
            this.name := AhkStdlibThreadSharedMemoryName()
        this.mutex_name := AhkStdlibThreadSharedMemoryMutexName(this.name)

        if options.HasOwnProp("create") && !AhkStdlibTruthValue(options.create)
            this.AhkStdlibOpenExisting()
        else if options.HasOwnProp("name") && !options.HasOwnProp("create")
            this.AhkStdlibOpenExisting()
        else
            this.AhkStdlibCreate()
    }

    __Delete()
    {
        this.close()
    }

    read(offset := 0, length := unset)
    {
        this.AhkStdlibRequireOpen()
        offset := Integer(offset)
        length := IsSet(length) ? Integer(length) : this.size - offset
        this.AhkStdlibCheckBounds(offset, length)
        bytesBuffer := Buffer(length, 0)
        DllCall("kernel32\RtlMoveMemory", "Ptr", bytesBuffer.Ptr, "Ptr", this.AhkStdlibView + offset, "UPtr", length)
        return bytesBuffer
    }

    write(value, offset := 0)
    {
        this.AhkStdlibRequireOpen()
        offset := Integer(offset)
        sourceBuffer := AhkStdlibThreadSharedMemoryToBuffer(value)
        this.AhkStdlibCheckBounds(offset, sourceBuffer.Size)
        DllCall("kernel32\RtlMoveMemory", "Ptr", this.AhkStdlibView + offset, "Ptr", sourceBuffer.Ptr, "UPtr", sourceBuffer.Size)
        return stdlib.None
    }

    read_text(offset := 0, length := unset, encoding := "UTF-8")
    {
        bytesBuffer := this.read(offset, length?)
        return StrGet(bytesBuffer, encoding)
    }

    write_text(text, offset := 0, encoding := "UTF-8")
    {
        return this.write(AhkStdlibThreadTextToBuffer(text, encoding), offset)
    }

    write_json(value, offset := 0, length := unset)
    {
        text := stdlib.json.dumps(value)
        sourceBuffer := AhkStdlibThreadTextToBuffer(text, "UTF-8")
        areaLength := IsSet(length) ? Integer(length) : sourceBuffer.Size
        this.AhkStdlibCheckBounds(offset, areaLength)
        if sourceBuffer.Size > areaLength
            throw ValueError("JSON payload does not fit shared memory region", -1)
        clearBuffer := Buffer(areaLength, 0)
        DllCall("kernel32\RtlMoveMemory", "Ptr", clearBuffer.Ptr, "Ptr", sourceBuffer.Ptr, "UPtr", sourceBuffer.Size)
        return this.write(clearBuffer, offset)
    }

    read_json(offset := 0, length := unset)
    {
        bytesBuffer := this.read(offset, length?)
        text := AhkStdlibThreadBufferToNullTerminatedText(bytesBuffer, "UTF-8")
        return stdlib.json.loads(text)
    }

    ptr()
    {
        this.AhkStdlibRequireOpen()
        return this.AhkStdlibView
    }

    get(offset := 0, typeName := "UChar")
    {
        this.AhkStdlibRequireOpen()
        offset := Integer(offset)
        typeName := AhkStdlibThreadSharedMemoryNormalizeType(typeName)
        this.AhkStdlibCheckBounds(offset, AhkStdlibThreadSharedMemoryTypeSize(typeName))
        return NumGet(this.AhkStdlibView, offset, typeName)
    }

    put(value, offset := 0, typeName := "UChar")
    {
        this.AhkStdlibRequireOpen()
        offset := Integer(offset)
        typeName := AhkStdlibThreadSharedMemoryNormalizeType(typeName)
        this.AhkStdlibCheckBounds(offset, AhkStdlibThreadSharedMemoryTypeSize(typeName))
        NumPut(typeName, value, this.AhkStdlibView, offset)
        return stdlib.None
    }

    address {
        get => this.ptr()
    }

    lock()
    {
        return AhkStdlibThreadNamedMutex(this.mutex_name)
    }

    synchronized(callback, timeout := unset)
    {
        lock := this.lock()
        acquired := false
        try {
            acquired := lock.acquire(true, timeout?)
            if !acquired
                throw RuntimeError("could not acquire shared memory lock", -1)
            return callback.Call(this)
        } finally {
            if acquired
                lock.release()
            lock.close()
        }
    }

    close()
    {
        if this.AhkStdlibView {
            DllCall("kernel32\UnmapViewOfFile", "Ptr", this.AhkStdlibView)
            this.AhkStdlibView := 0
        }
        if this.AhkStdlibHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibHandle)
            this.AhkStdlibHandle := 0
        }
        this.AhkStdlibClosed := true
        return stdlib.None
    }

    unlink()
    {
        return this.close()
    }

    AhkStdlibCreate()
    {
        this.AhkStdlibHandle := DllCall(
            "kernel32\CreateFileMappingW",
            "Ptr", -1,
            "Ptr", 0,
            "UInt", 0x04,
            "UInt", 0,
            "UInt", this.size,
            "Str", this.name,
            "Ptr"
        )
        if !this.AhkStdlibHandle
            throw OSError("CreateFileMappingW failed: " A_LastError, -1)
        this.AhkStdlibMapView()
    }

    AhkStdlibOpenExisting()
    {
        this.AhkStdlibHandle := DllCall("kernel32\OpenFileMappingW", "UInt", 0x000F001F, "Int", false, "Str", this.name, "Ptr")
        if !this.AhkStdlibHandle
            throw OSError("OpenFileMappingW failed: " A_LastError, -1)
        this.AhkStdlibMapView()
    }

    AhkStdlibMapView()
    {
        this.AhkStdlibView := DllCall("kernel32\MapViewOfFile", "Ptr", this.AhkStdlibHandle, "UInt", 0x000F001F, "UInt", 0, "UInt", 0, "UPtr", this.size, "Ptr")
        if !this.AhkStdlibView
            throw OSError("MapViewOfFile failed: " A_LastError, -1)
    }

    AhkStdlibRequireOpen()
    {
        if this.AhkStdlibClosed || !this.AhkStdlibView
            throw RuntimeError("shared memory is closed", -1)
    }

    AhkStdlibCheckBounds(offset, length)
    {
        if offset < 0 || length < 0 || offset + length > this.size
            throw ValueError("shared memory access out of bounds", -1)
    }
}

class AhkStdlibThreadSharedObject
{
    __New(value)
    {
        this.AhkStdlibValue := value
        this.AhkStdlibLock := AhkStdlibThreadLock()
    }

    acquire(blocking := true, timeout := unset)
    {
        if !AhkStdlibTruthValue(blocking)
            return this.AhkStdlibLock.acquire(false)
        deadline := IsSet(timeout) ? A_TickCount + AhkStdlibThreadTimeoutToMilliseconds(timeout) : ""
        loop {
            if this.AhkStdlibLock.acquire(false)
                return true
            if IsSet(timeout) && A_TickCount >= deadline
                return false
            Sleep 10
        }
    }

    release()
    {
        return this.AhkStdlibLock.release()
    }

    get(key)
    {
        if this.AhkStdlibValue is Map
            return this.AhkStdlibValue[key]
        return this.AhkStdlibValue.%key%
    }

    set(key, value)
    {
        if this.AhkStdlibValue is Map
            this.AhkStdlibValue[key] := value
        else
            this.AhkStdlibValue.%key% := value
        return stdlib.None
    }

    append(key, value)
    {
        target := this.get(key)
        if !(target is Array)
            throw TypeError("SharedObject.append() target must be an Array", -1)
        target.Push(value)
        return stdlib.None
    }

    len(key := unset)
    {
        value := IsSet(key) ? this.get(key) : this.AhkStdlibValue
        if value is Array
            return value.Length
        if value is Map
            return value.Count
        if value is String
            return StrLen(value)
        throw TypeError("SharedObject.len() target has no length", -1)
    }

    snapshot()
    {
        return AhkStdlibThreadSharedObjectClone(this.AhkStdlibValue)
    }

    AhkStdlibHandleRequest(request)
    {
        op := request.Has("op") ? request["op"] : ""
        switch op {
            case "acquire":
                return this.acquire(false)
            case "release":
                return this.release()
            case "get":
                return AhkStdlibThreadSharedObjectClone(this.get(request["key"]))
            case "set":
                return this.set(request["key"], request["value"])
            case "append":
                return this.append(request["key"], request["value"])
            case "len":
                if request.Has("key")
                    return this.len(request["key"])
                return this.len()
            case "snapshot":
                return this.snapshot()
            default:
                throw ValueError("unsupported shared object operation", -1)
        }
    }
}

class AhkStdlibThreadSharedObjectProxy
{
    __New(name, channel)
    {
        this.name := name
        this.AhkStdlibChannel := channel
    }

    acquire(blocking := true, timeout := unset)
    {
        if !AhkStdlibTruthValue(blocking)
            return this.AhkStdlibRequest("acquire")
        deadline := IsSet(timeout) ? A_TickCount + AhkStdlibThreadTimeoutToMilliseconds(timeout) : ""
        loop {
            if this.AhkStdlibRequest("acquire")
                return true
            if IsSet(timeout) && A_TickCount >= deadline
                return false
            Sleep 10
        }
    }

    release()
    {
        return this.AhkStdlibRequest("release")
    }

    get(key)
    {
        return this.AhkStdlibRequest("get", Map("key", key))
    }

    set(key, value)
    {
        return this.AhkStdlibRequest("set", Map("key", key, "value", value))
    }

    append(key, value)
    {
        return this.AhkStdlibRequest("append", Map("key", key, "value", value))
    }

    len(key := unset)
    {
        if IsSet(key)
            return this.AhkStdlibRequest("len", Map("key", key))
        return this.AhkStdlibRequest("len")
    }

    snapshot()
    {
        return this.AhkStdlibRequest("snapshot")
    }

    AhkStdlibRequest(op, fields := unset)
    {
        request := Map("shared_object", this.name, "op", op)
        if IsSet(fields) {
            for key, value in fields
                request[key] := value
        }
        this.AhkStdlibChannel.send_worker(request)
        response := this.AhkStdlibChannel.recv_worker(5)
        if response["status"] = "error"
            throw RuntimeError(response["message"], -1)
        return response["value"]
    }
}

AhkStdlibThreadSharedObjectClone(value)
{
    if AhkStdlibIsNone(value) || AhkStdlibJsonIsNull(value)
        return stdlib.json.Null
    if AhkStdlibIsBool(value)
        return value

    valueType := Type(value)
    switch valueType {
        case "String", "Integer", "Float":
            return value
        case "Array":
            clonedArray := []
            for item in value
                clonedArray.Push(AhkStdlibThreadSharedObjectClone(item))
            return clonedArray
        case "Map":
            clonedMap := Map()
            for key, item in value
                clonedMap[key] := AhkStdlibThreadSharedObjectClone(item)
            return clonedMap
        case "Object":
            clonedObject := {}
            for key, item in value.OwnProps()
                clonedObject.%key% := AhkStdlibThreadSharedObjectClone(item)
            return clonedObject
        default:
            throw TypeError("SharedObject values must be JSON-safe", -1)
    }
}

class AhkStdlibThreadNamedMutex
{
    __New(name)
    {
        this.name := name
        this.AhkStdlibHandle := DllCall("kernel32\CreateMutexW", "Ptr", 0, "Int", false, "Str", this.name, "Ptr")
        if !this.AhkStdlibHandle
            throw OSError("CreateMutexW failed: " A_LastError, -1)
        this.AhkStdlibClosed := false
        this.AhkStdlibOwned := false
    }

    __Delete()
    {
        this.close()
    }

    acquire(blocking := true, timeout := unset)
    {
        this.AhkStdlibRequireOpen()
        milliseconds := 0
        if IsSet(timeout)
            milliseconds := AhkStdlibThreadTimeoutToMilliseconds(timeout)
        else
            milliseconds := AhkStdlibTruthValue(blocking) ? 0xFFFFFFFF : 0
        result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibHandle, "UInt", milliseconds, "UInt")
        if result = 0 || result = 0x80 {
            this.AhkStdlibOwned := true
            return true
        }
        if result = 0x102
            return false
        throw OSError("WaitForSingleObject failed: " A_LastError, -1)
    }

    release()
    {
        this.AhkStdlibRequireOpen()
        if !DllCall("kernel32\ReleaseMutex", "Ptr", this.AhkStdlibHandle, "Int")
            throw RuntimeError("cannot release un-acquired shared memory lock", -1)
        this.AhkStdlibOwned := false
        return stdlib.None
    }

    close()
    {
        if this.AhkStdlibHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibHandle)
            this.AhkStdlibHandle := 0
        }
        this.AhkStdlibClosed := true
        return stdlib.None
    }

    AhkStdlibRequireOpen()
    {
        if this.AhkStdlibClosed || !this.AhkStdlibHandle
            throw RuntimeError("shared memory lock is closed", -1)
    }
}

class AhkStdlibThreadWeakSet
{
    __New(data := unset)
    {
        this.AhkStdlibItems := Map()
        if IsSet(data) {
            for item in data
                this.add(item)
        }
    }

    add(item)
    {
        this.AhkStdlibItems[item] := true
        return stdlib.None
    }

    discard(item)
    {
        if this.AhkStdlibItems.Has(item)
            this.AhkStdlibItems.Delete(item)
        return stdlib.None
    }

    contains(item)
    {
        return this.AhkStdlibItems.Has(item)
    }

    __len()
    {
        return this.AhkStdlibItems.Count
    }

    __Enum(numberOfVars := 1)
    {
        if numberOfVars != 1
            return this.AhkStdlibItems.__Enum(numberOfVars)
        items := []
        for item, _ in this.AhkStdlibItems
            items.Push(item)
        return items.__Enum(1)
    }
}

class AhkStdlibThreadTimer extends AhkStdlibThreadWorker
{
    __New(interval, function, args := unset, kwargs := unset)
    {
        this.interval := interval
        this.function := function
        this.args := IsSet(args) && args is Array ? args : []
        this.kwargs := IsSet(kwargs) ? kwargs : stdlib.None
        super.__New({ name: "Timer", source: "thread_result := stdlib.json.Null" })
    }

    start()
    {
        if HasMethod(this.function, "Call") {
            if this.AhkStdlibStarted
                throw RuntimeError("threads can only be started once", -1)
            if this.AhkStdlibCancelled {
                this.AhkStdlibStarted := true
                this.AhkStdlibFinished := true
                this.exitcode := 0
                return stdlib.None
            }
            this.AhkStdlibStarted := true
            Sleep Round(Number(this.interval) * 1000)
            this.function.Call(this.args*)
            this.AhkStdlibFinished := true
            this.exitcode := 0
            return stdlib.None
        }
        return super.start()
    }

    join(timeout := unset)
    {
        if HasMethod(this.function, "Call") {
            if !this.AhkStdlibStarted
                throw RuntimeError("cannot join thread before it is started", -1)
            return stdlib.None
        }
        return super.join(timeout?)
    }

    is_alive()
    {
        if HasMethod(this.function, "Call")
            return this.AhkStdlibStarted && !this.AhkStdlibFinished
        return super.is_alive()
    }

    result(timeout := unset)
    {
        if HasMethod(this.function, "Call") {
            if !this.AhkStdlibStarted || !this.AhkStdlibFinished
                throw RuntimeError("thread result is not ready", -1)
            return stdlib.None
        }
        return super.result(timeout?)
    }

    run()
    {
        if !this.AhkStdlibCancelled && HasMethod(this.function, "Call")
            this.function.Call(this.args*)
        return stdlib.None
    }

    cancel()
    {
        this.AhkStdlibCancelled := true
        return stdlib.None
    }
}

class AhkStdlibThreadEvent
{
    __New()
    {
        this.AhkStdlibHandle := DllCall("kernel32\CreateEventW", "Ptr", 0, "Int", true, "Int", false, "Ptr", 0, "Ptr")
        if !this.AhkStdlibHandle
            throw OSError("CreateEventW failed: " A_LastError, -1)
    }

    __Delete()
    {
        this.close()
    }

    set()
    {
        if !DllCall("kernel32\SetEvent", "Ptr", this.AhkStdlibHandle, "Int")
            throw OSError("SetEvent failed: " A_LastError, -1)
        return stdlib.None
    }

    clear()
    {
        if !DllCall("kernel32\ResetEvent", "Ptr", this.AhkStdlibHandle, "Int")
            throw OSError("ResetEvent failed: " A_LastError, -1)
        return stdlib.None
    }

    wait(timeout := unset)
    {
        milliseconds := IsSet(timeout) ? AhkStdlibThreadTimeoutToMilliseconds(timeout) : 0xFFFFFFFF
        result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibHandle, "UInt", milliseconds, "UInt")
        if result = 0
            return true
        if result = 0x102
            return false
        throw OSError("WaitForSingleObject failed: " A_LastError, -1)
    }

    is_set()
    {
        return this.wait(0)
    }

    isSet()
    {
        return this.is_set()
    }

    close()
    {
        if HasProp(this, "AhkStdlibHandle") && this.AhkStdlibHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibHandle)
            this.AhkStdlibHandle := 0
        }
        return stdlib.None
    }
}

class AhkStdlibThreadWorker
{
    static AhkStdlibNextNumber := 1

    __New(options := unset)
    {
        this.name := ""
        this.daemon := false
        this.ident := stdlib.None
        this.native_id := stdlib.None
        this.pid := stdlib.None
        this.exitcode := stdlib.None
        this.AhkStdlibSource := "thread_result := stdlib.json.Null"
        this.AhkStdlibChannel := stdlib.None
        this.AhkStdlibSharedMemory := stdlib.None
        this.AhkStdlibSharedObjects := Map()
        this.AhkStdlibTarget := stdlib.None
        this.AhkStdlibStarted := false
        this.AhkStdlibFinished := false
        this.AhkStdlibCancelled := false
        this.AhkStdlibProcessHandle := 0
        this.AhkStdlibResultConsumed := false

        number := AhkStdlibThreadWorker.AhkStdlibNextNumber
        AhkStdlibThreadWorker.AhkStdlibNextNumber += 1
        this.name := "Thread-" number
        this.AhkStdlibWorkerKey := "worker-" number

        if IsSet(options)
            this.AhkStdlibConfigure(options)
    }

    __Delete()
    {
        this.close()
    }

    AhkStdlibConfigure(options)
    {
        if options is String {
            this.AhkStdlibSource := options
            return
        }
        if Type(options) = "Object" {
            if options.HasOwnProp("name")
                this.name := options.name
            if options.HasOwnProp("source")
                this.AhkStdlibSource := options.source
            if options.HasOwnProp("target")
                this.AhkStdlibTarget := options.target
            if options.HasOwnProp("channel")
                this.AhkStdlibChannel := options.channel
            if options.HasOwnProp("shared_memory")
                this.AhkStdlibSharedMemory := options.shared_memory
            if options.HasOwnProp("shared_objects")
                this.AhkStdlibSharedObjects := options.shared_objects
            if options.HasOwnProp("daemon")
                this.daemon := AhkStdlibTruthValue(options.daemon)
            return
        }
        throw TypeError("Thread() source must be a string or keyword object", -1)
    }

    getName()
    {
        return this.name
    }

    setName(name)
    {
        this.name := name
        return stdlib.None
    }

    isDaemon()
    {
        return this.daemon
    }

    setDaemon(daemon)
    {
        this.daemon := AhkStdlibTruthValue(daemon)
        return stdlib.None
    }

    run()
    {
        if HasMethod(this.AhkStdlibTarget, "Call")
            this.AhkStdlibTarget.Call()
        return stdlib.None
    }

    start()
    {
        if this.AhkStdlibStarted
            throw RuntimeError("threads can only be started once", -1)

        stamp := DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999)
        this.AhkStdlibScriptPath := A_Temp "\stdlib-thread-worker-" stamp ".ahk"
        this.AhkStdlibResultPath := A_Temp "\stdlib-thread-worker-" stamp ".json"
        this.AhkStdlibStdoutPath := A_Temp "\stdlib-thread-worker-" stamp ".out.txt"
        this.AhkStdlibStderrPath := A_Temp "\stdlib-thread-worker-" stamp ".err.txt"
        this.AhkStdlibPrepareSharedObjectChannels()
        this.AhkStdlibWriteWorkerScript()

        processInfo := AhkStdlibThreadCreateProcess(A_AhkPath, ["/ErrorStdOut=UTF-8", this.AhkStdlibScriptPath], A_WorkingDir, this.AhkStdlibStdoutPath, this.AhkStdlibStderrPath)
        this.AhkStdlibProcessHandle := processInfo.ProcessHandle
        this.pid := processInfo.ProcessId
        this.ident := processInfo.ThreadId
        this.native_id := processInfo.ThreadId
        this.AhkStdlibStarted := true
        AhkStdlibThreadWorkerRegistry("add", this)
        return stdlib.None
    }

    join(timeout := unset)
    {
        if !this.AhkStdlibStarted
            throw RuntimeError("cannot join thread before it is started", -1)
        milliseconds := IsSet(timeout) ? AhkStdlibThreadTimeoutToMilliseconds(timeout) : 0xFFFFFFFF
        deadline := milliseconds = 0xFFFFFFFF ? "" : A_TickCount + milliseconds
        loop {
            AhkStdlibThreadPumpSharedObjectRequests()
            result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 10, "UInt")
            if result = 0 {
                this.AhkStdlibMarkFinished()
                AhkStdlibThreadPumpSharedObjectRequests()
                return stdlib.None
            }
            if result != 0x102
                throw OSError("WaitForSingleObject failed: " A_LastError, -1)
            if IsSet(timeout) && A_TickCount >= deadline
                return stdlib.None
        }
    }

    is_alive()
    {
        if !this.AhkStdlibStarted || this.AhkStdlibFinished
            return false
        AhkStdlibThreadPumpSharedObjectRequests()
        result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 0, "UInt")
        if result = 0 {
            this.AhkStdlibMarkFinished()
            return false
        }
        if result = 0x102
            return true
        throw OSError("WaitForSingleObject failed: " A_LastError, -1)
    }

    result(timeout := unset)
    {
        if !this.AhkStdlibStarted
            throw RuntimeError("thread result is not ready", -1)
        if IsSet(timeout)
            this.join(timeout)
        else if this.is_alive()
            throw RuntimeError("thread result is not ready", -1)

        if !this.AhkStdlibFinished
            throw RuntimeError("thread result is not ready", -1)

        if !this.HasOwnProp("AhkStdlibResultCache")
            this.AhkStdlibResultCache := this.AhkStdlibReadResult()

        this.AhkStdlibResultConsumed := true
        if this.AhkStdlibResultCache["status"] = "error" {
            typeName := this.AhkStdlibResultCache.Has("type") ? this.AhkStdlibResultCache["type"] : "Error"
            message := this.AhkStdlibResultCache.Has("message") ? this.AhkStdlibResultCache["message"] : ""
            throw AhkStdlibThreadErrorFromPayload(typeName, message)
        }

        return this.AhkStdlibResultCache["value"]
    }

    close()
    {
        if this.AhkStdlibProcessHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibProcessHandle)
            this.AhkStdlibProcessHandle := 0
        }
        this.AhkStdlibCleanupFiles()
        return stdlib.None
    }

    AhkStdlibResultItem()
    {
        value := this.result()
        return { thread: this, value: value, pid: this.pid, native_id: this.native_id, name: this.name }
    }

    AhkStdlibMarkFinished()
    {
        if this.AhkStdlibFinished
            return
        exitCode := 0
        if !DllCall("kernel32\GetExitCodeProcess", "Ptr", this.AhkStdlibProcessHandle, "UInt*", &exitCode, "Int")
            throw OSError("GetExitCodeProcess failed: " A_LastError, -1)
        this.exitcode := exitCode
        this.AhkStdlibFinished := true
        AhkStdlibThreadWorkerRegistry("remove", this)
    }

    AhkStdlibReadResult()
    {
        if !FileExist(this.AhkStdlibResultPath) {
            if this.exitcode != 0 {
                output := this.AhkStdlibReadCapturedOutput()
                suffix := output = "" ? "" : ": " AhkStdlibThreadCompactText(output)
                throw RuntimeError("worker exited without a result" suffix, -1)
            }
            throw RuntimeError("thread result is not ready", -1)
        }
        return stdlib.json.load(this.AhkStdlibResultPath)
    }

    AhkStdlibWriteWorkerScript()
    {
        script := "#NoTrayIcon`n"
            . "#Requires AutoHotkey v2.0`n"
            . "#ErrorStdOut `"UTF-8`"`n"
            . "#Warn Unreachable, Off`n"
            . "#Include <stdlib\thread>`n"
            . "AhkStdlibThreadWorkerResultPath := " AhkStdlibThreadAhkQuote(this.AhkStdlibResultPath) "`n"
            . this.AhkStdlibWorkerChannelScript()
            . this.AhkStdlibWorkerSharedMemoryScript()
            . this.AhkStdlibWorkerSharedObjectScript()
            . "try {`n"
            . "    thread_result := stdlib.json.Null`n"
            . AhkStdlibThreadIndentSource(this.AhkStdlibSource)
            . "    AhkStdlibThreadWorkerWriteResult(AhkStdlibThreadWorkerResultPath, `"ok`", thread_result)`n"
            . "    ExitApp 0`n"
            . "} catch Error as err {`n"
            . "    AhkStdlibThreadWorkerWriteResult(AhkStdlibThreadWorkerResultPath, `"error`", stdlib.json.Null, Type(err), err.Message)`n"
            . "    ExitApp 1`n"
            . "}`n"
            . "AhkStdlibThreadWorkerWriteResult(path, status, value, typeName := `"`", message := `"`") {`n"
            . "    payload := Map(`"status`", status, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"), `"value`", value, `"type`", typeName, `"message`", message)`n"
            . "    if FileExist(path)`n"
            . "        FileDelete path`n"
            . "    FileAppend stdlib.json.dumps(payload), path, `"UTF-8`"`n"
            . "}`n"

        if FileExist(this.AhkStdlibScriptPath)
            FileDelete this.AhkStdlibScriptPath
        if FileExist(this.AhkStdlibResultPath)
            FileDelete this.AhkStdlibResultPath
        FileAppend script, this.AhkStdlibScriptPath, "UTF-8"
    }

    AhkStdlibWorkerChannelScript()
    {
        if !(this.AhkStdlibChannel is AhkStdlibThreadChannel)
            return ""
        root := this.AhkStdlibChannel.AhkStdlibRoot
        return "AhkStdlibThreadSetCurrentChannel(AhkStdlibThreadChannel(" AhkStdlibThreadAhkQuote(root) "))`n"
    }

    AhkStdlibWorkerSharedMemoryScript()
    {
        if !(this.AhkStdlibSharedMemory is AhkStdlibThreadSharedMemory)
            return ""
        name := this.AhkStdlibSharedMemory.name
        size := this.AhkStdlibSharedMemory.size
        return "AhkStdlibThreadSetCurrentSharedMemory(AhkStdlibThreadSharedMemory({ name: " AhkStdlibThreadAhkQuote(name) ", size: " size " }))`n"
    }

    AhkStdlibPrepareSharedObjectChannels()
    {
        if !(this.AhkStdlibSharedObjects is Map)
            return
        for name, shared in this.AhkStdlibSharedObjects {
            if !(shared is AhkStdlibThreadSharedObject)
                throw TypeError("Thread shared_objects values must be stdlib.thread.SharedObject", -1)
            if !HasProp(shared, "AhkStdlibWorkerChannels")
                shared.AhkStdlibWorkerChannels := Map()
            channel := AhkStdlibThreadChannel()
            shared.AhkStdlibWorkerChannels[this.AhkStdlibWorkerKey] := channel
        }
    }

    AhkStdlibWorkerSharedObjectScript()
    {
        if !(this.AhkStdlibSharedObjects is Map) || this.AhkStdlibSharedObjects.Count = 0
            return ""
        script := "AhkStdlibThreadWorkerSharedObjects := Map()`n"
        for name, shared in this.AhkStdlibSharedObjects {
            channel := shared.AhkStdlibWorkerChannels[this.AhkStdlibWorkerKey]
            script .= "AhkStdlibThreadWorkerSharedObjects[" AhkStdlibThreadAhkQuote(name) "] := AhkStdlibThreadSharedObjectProxy(" AhkStdlibThreadAhkQuote(name) ", AhkStdlibThreadChannel(" AhkStdlibThreadAhkQuote(channel.AhkStdlibRoot) "))`n"
        }
        script .= "AhkStdlibThreadSetCurrentSharedObjects(AhkStdlibThreadWorkerSharedObjects)`n"
        return script
    }

    AhkStdlibProcessSharedObjectRequests()
    {
        if !(this.AhkStdlibSharedObjects is Map)
            return stdlib.None
        for name, shared in this.AhkStdlibSharedObjects {
            if !(shared is AhkStdlibThreadSharedObject)
                continue
            if !HasProp(shared, "AhkStdlibWorkerChannels") || !shared.AhkStdlibWorkerChannels.Has(this.AhkStdlibWorkerKey)
                continue
            channel := shared.AhkStdlibWorkerChannels[this.AhkStdlibWorkerKey]
            loop {
                try request := channel.recv(0)
                catch AhkStdlibThread.Empty
                    break
                this.AhkStdlibHandleSharedObjectRequest(shared, channel, request)
            }
        }
        return stdlib.None
    }

    AhkStdlibHandleSharedObjectRequest(shared, channel, request)
    {
        try {
            value := shared.AhkStdlibHandleRequest(request)
            channel.send(Map("status", "ok", "value", AhkStdlibThreadSharedObjectClone(value)))
        } catch Error as err {
            channel.send(Map("status", "error", "value", stdlib.json.Null, "message", err.Message, "type", Type(err)))
        }
        return stdlib.None
    }

    AhkStdlibReadCapturedOutput()
    {
        output := ""
        if HasProp(this, "AhkStdlibStdoutPath") && FileExist(this.AhkStdlibStdoutPath)
            output .= FileRead(this.AhkStdlibStdoutPath, "UTF-8")
        if HasProp(this, "AhkStdlibStderrPath") && FileExist(this.AhkStdlibStderrPath)
            output .= FileRead(this.AhkStdlibStderrPath, "UTF-8")
        return output
    }

    AhkStdlibCleanupFiles()
    {
        if HasProp(this, "AhkStdlibScriptPath") && FileExist(this.AhkStdlibScriptPath)
            FileDelete this.AhkStdlibScriptPath
        if this.AhkStdlibResultConsumed && HasProp(this, "AhkStdlibResultPath") && FileExist(this.AhkStdlibResultPath)
            FileDelete this.AhkStdlibResultPath
        if this.AhkStdlibResultConsumed && HasProp(this, "AhkStdlibStdoutPath") && FileExist(this.AhkStdlibStdoutPath)
            FileDelete this.AhkStdlibStdoutPath
        if this.AhkStdlibResultConsumed && HasProp(this, "AhkStdlibStderrPath") && FileExist(this.AhkStdlibStderrPath)
            FileDelete this.AhkStdlibStderrPath
    }
}

class AhkStdlibThreadFuture
{
    __New(pool := unset, options := unset)
    {
        this.AhkStdlibPool := IsSet(pool) ? pool : stdlib.None
        this.AhkStdlibOptions := IsSet(options) ? options : unset
        this.AhkStdlibState := "pending"
        this.AhkStdlibWorker := stdlib.None
        this.AhkStdlibResult := stdlib.None
        this.AhkStdlibException := stdlib.None
        this.AhkStdlibCallbacks := []
    }

    cancel()
    {
        this.AhkStdlibPumpOwner()
        if this.AhkStdlibState != "pending"
            return false
        this.AhkStdlibState := "cancelled"
        this.AhkStdlibScheduleCallbacks()
        return true
    }

    cancelled()
    {
        return this.AhkStdlibState = "cancelled"
    }

    done()
    {
        this.AhkStdlibPumpOwner()
        return this.AhkStdlibIsDone()
    }

    running()
    {
        this.AhkStdlibPumpOwner()
        return this.AhkStdlibState = "running"
    }

    result(timeout := unset)
    {
        this.AhkStdlibWait(timeout?)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibThread.CancelledError("", -1)
        if this.AhkStdlibState = "exception"
            throw this.AhkStdlibException
        if this.AhkStdlibState = "finished"
            return this.AhkStdlibResult
        throw AhkStdlibThread.TimeoutError("", -1)
    }

    exception(timeout := unset)
    {
        this.AhkStdlibWait(timeout?)
        if this.AhkStdlibState = "cancelled"
            throw AhkStdlibThread.CancelledError("", -1)
        if this.AhkStdlibState = "exception"
            return this.AhkStdlibException
        if this.AhkStdlibState = "finished"
            return stdlib.None
        throw AhkStdlibThread.TimeoutError("", -1)
    }

    set_result(value)
    {
        if this.AhkStdlibIsDone()
            throw RuntimeError("Future is already done", -1)
        this.AhkStdlibResult := value
        this.AhkStdlibState := "finished"
        this.AhkStdlibScheduleCallbacks()
        return stdlib.None
    }

    set_exception(err)
    {
        if this.AhkStdlibIsDone()
            throw RuntimeError("Future is already done", -1)
        this.AhkStdlibException := err
        this.AhkStdlibState := "exception"
        this.AhkStdlibScheduleCallbacks()
        return stdlib.None
    }

    add_done_callback(callback)
    {
        if !HasMethod(callback, "Call")
            throw TypeError("Future.add_done_callback() expected a callable", -1)
        if this.AhkStdlibIsDone()
            callback.Call(this)
        else
            this.AhkStdlibCallbacks.Push(callback)
        return stdlib.None
    }

    AhkStdlibStart()
    {
        if this.AhkStdlibState != "pending"
            return stdlib.None
        this.AhkStdlibWorker := AhkStdlibThreadWorker(this.AhkStdlibOptions)
        this.AhkStdlibWorker.start()
        this.AhkStdlibState := "running"
        return stdlib.None
    }

    AhkStdlibPoll()
    {
        if this.AhkStdlibState != "running"
            return stdlib.None
        if this.AhkStdlibWorker.is_alive()
            return stdlib.None
        try {
            this.set_result(this.AhkStdlibWorker.result())
        } catch Error as err {
            this.set_exception(err)
        }
        return stdlib.None
    }

    AhkStdlibWait(timeout := unset)
    {
        deadline := IsSet(timeout) ? A_TickCount + AhkStdlibThreadTimeoutToMilliseconds(timeout) : ""
        loop {
            if this.AhkStdlibIsDone()
                return stdlib.None
            this.AhkStdlibPumpOwner()
            if this.AhkStdlibIsDone()
                return stdlib.None
            if IsSet(timeout) && A_TickCount >= deadline
                throw AhkStdlibThread.TimeoutError("", -1)
            Sleep 10
        }
    }

    AhkStdlibPumpOwner()
    {
        if this.AhkStdlibPool is AhkStdlibThreadPool
            this.AhkStdlibPool.AhkStdlibPump()
        else
            AhkStdlibThreadPumpSharedObjectRequests()
        return stdlib.None
    }

    AhkStdlibIsDone()
    {
        return this.AhkStdlibState = "finished"
            || this.AhkStdlibState = "exception"
            || this.AhkStdlibState = "cancelled"
    }

    AhkStdlibScheduleCallbacks()
    {
        callbacks := this.AhkStdlibCallbacks
        this.AhkStdlibCallbacks := []
        for callback in callbacks
            callback.Call(this)
        return stdlib.None
    }
}

class AhkStdlibThreadPool
{
    __New(options := unset)
    {
        this.AhkStdlibMaxWorkers := 1
        this.AhkStdlibThreadNamePrefix := "ThreadPool"
        this.AhkStdlibShutdown := false
        this.AhkStdlibPending := []
        this.AhkStdlibRunning := []
        this.AhkStdlibSubmitted := 0
        this.AhkStdlibPumping := false
        this.AhkStdlibWorkerSource := ""
        this.AhkStdlibPersistentWorkers := []

        if IsSet(options) {
            if options is Integer
                this.AhkStdlibMaxWorkers := Integer(options)
            else if Type(options) = "Object" {
                if options.HasOwnProp("max_workers")
                    this.AhkStdlibMaxWorkers := Integer(options.max_workers)
                if options.HasOwnProp("thread_name_prefix")
                    this.AhkStdlibThreadNamePrefix := options.thread_name_prefix
                if options.HasOwnProp("worker_source")
                    this.AhkStdlibWorkerSource := options.worker_source
            } else {
                throw TypeError("ThreadPool() expected an options object", -1)
            }
        }
        if this.AhkStdlibMaxWorkers <= 0
            throw ValueError("max_workers must be greater than 0", -1)
    }

    submit(options)
    {
        if this.AhkStdlibShutdown
            throw RuntimeError("cannot schedule new futures after shutdown", -1)
        this.AhkStdlibSubmitted += 1
        future := AhkStdlibThreadFuture(this, this.AhkStdlibTaskOptions(options))
        this.AhkStdlibPending.Push(future)
        this.AhkStdlibPump()
        return future
    }

    map(function, iterable, timeout := unset)
    {
        if !HasMethod(function, "Call")
            throw TypeError("ThreadPool.map() expected a callable", -1)
        futures := []
        for _, value in iterable
            futures.Push(this.submit(function.Call(value)))

        results := []
        deadline := IsSet(timeout) ? A_TickCount + AhkStdlibThreadTimeoutToMilliseconds(timeout) : ""
        for future in futures {
            if IsSet(timeout) {
                remaining := (deadline - A_TickCount) / 1000
                if remaining < 0
                    remaining := 0
                results.Push(future.result(remaining))
            } else {
                results.Push(future.result())
            }
        }
        return results
    }

    shutdown(wait := true)
    {
        this.AhkStdlibShutdown := true
        if AhkStdlibTruthValue(wait) {
            loop {
                this.AhkStdlibPump()
                if this.AhkStdlibPending.Length = 0
                    && this.AhkStdlibRunning.Length = 0
                    && (!this.AhkStdlibHasPersistentWorkers() || this.AhkStdlibPersistentWorkersIdle())
                    break
                Sleep 10
            }
        }
        for worker in this.AhkStdlibPersistentWorkers
            worker.shutdown(wait)
        return stdlib.None
    }

    AhkStdlibPump()
    {
        if this.AhkStdlibPumping
            return stdlib.None
        this.AhkStdlibPumping := true
        try {
        AhkStdlibThreadPumpSharedObjectRequests()
        if this.AhkStdlibHasPersistentWorkers()
            this.AhkStdlibPumpPersistent()
        else
            this.AhkStdlibPumpProcessTasks()
        } finally {
            this.AhkStdlibPumping := false
        }
        return stdlib.None
    }

    AhkStdlibPumpProcessTasks()
    {
        index := this.AhkStdlibRunning.Length
        while index >= 1 {
            future := this.AhkStdlibRunning[index]
            future.AhkStdlibPoll()
            if future.AhkStdlibIsDone()
                this.AhkStdlibRunning.RemoveAt(index)
            index -= 1
        }

        while this.AhkStdlibRunning.Length < this.AhkStdlibMaxWorkers && this.AhkStdlibPending.Length > 0 {
            future := this.AhkStdlibPending.RemoveAt(1)
            if future.cancelled()
                continue
            future.AhkStdlibStart()
            this.AhkStdlibRunning.Push(future)
        }
        return stdlib.None
    }

    AhkStdlibPumpPersistent()
    {
        this.AhkStdlibEnsurePersistentWorkers()
        for worker in this.AhkStdlibPersistentWorkers
            worker.poll()

        for worker in this.AhkStdlibPersistentWorkers {
            while worker.is_idle() && this.AhkStdlibPending.Length > 0 {
                future := this.AhkStdlibPending.RemoveAt(1)
                if future.cancelled()
                    continue
                worker.assign(future)
            }
        }
        return stdlib.None
    }

    AhkStdlibHasPersistentWorkers()
    {
        return this.AhkStdlibWorkerSource != ""
    }

    AhkStdlibEnsurePersistentWorkers()
    {
        while this.AhkStdlibPersistentWorkers.Length < this.AhkStdlibMaxWorkers {
            worker := AhkStdlibThreadPoolWorkerProcess(this, this.AhkStdlibPersistentWorkers.Length + 1)
            worker.start()
            this.AhkStdlibPersistentWorkers.Push(worker)
        }
        return stdlib.None
    }

    AhkStdlibPersistentWorkersIdle()
    {
        for worker in this.AhkStdlibPersistentWorkers {
            if !worker.is_idle()
                return false
        }
        return true
    }

    AhkStdlibTaskOptions(options)
    {
        if options is String
            return options
        if Type(options) != "Object"
            throw TypeError("ThreadPool.submit() expected a Thread options object", -1)
        if this.AhkStdlibHasPersistentWorkers() {
            if !options.HasOwnProp("task")
                throw TypeError("ThreadPool.submit() with worker_source expected a task object", -1)
            return options.task
        }
        if options.HasOwnProp("name")
            return options

        task := {}
        for key, value in options.OwnProps()
            task.%key% := value
        task.name := this.AhkStdlibThreadNamePrefix "-" this.AhkStdlibSubmitted
        return task
    }
}

class AhkStdlibThreadPoolWorkerProcess
{
    __New(pool, number)
    {
        this.AhkStdlibPool := pool
        this.AhkStdlibNumber := number
        this.AhkStdlibChannel := AhkStdlibThreadChannel()
        this.AhkStdlibFuture := stdlib.None
        this.AhkStdlibProcessHandle := 0
        this.AhkStdlibPid := stdlib.None
        this.AhkStdlibNativeId := stdlib.None
        this.AhkStdlibScriptPath := ""
        this.AhkStdlibStdoutPath := ""
        this.AhkStdlibStderrPath := ""
        this.AhkStdlibStarted := false
        this.AhkStdlibStopped := false
        this.AhkStdlibShutdownRequested := false
    }

    __Delete()
    {
        this.shutdown(false)
    }

    start()
    {
        if this.AhkStdlibStarted
            return stdlib.None
        stamp := DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999)
        this.AhkStdlibScriptPath := A_Temp "\stdlib-thread-pool-worker-" stamp ".ahk"
        this.AhkStdlibStdoutPath := A_Temp "\stdlib-thread-pool-worker-" stamp ".out.txt"
        this.AhkStdlibStderrPath := A_Temp "\stdlib-thread-pool-worker-" stamp ".err.txt"
        this.AhkStdlibWriteScript()
        processInfo := AhkStdlibThreadCreateProcess(A_AhkPath, ["/ErrorStdOut=UTF-8", this.AhkStdlibScriptPath], A_WorkingDir, this.AhkStdlibStdoutPath, this.AhkStdlibStderrPath)
        this.AhkStdlibProcessHandle := processInfo.ProcessHandle
        this.AhkStdlibPid := processInfo.ProcessId
        this.AhkStdlibNativeId := processInfo.ThreadId
        this.AhkStdlibStarted := true
        return stdlib.None
    }

    assign(future)
    {
        if !(future is AhkStdlibThreadFuture)
            throw TypeError("ThreadPool worker expected a Future", -1)
        this.start()
        this.AhkStdlibFuture := future
        future.AhkStdlibState := "running"
        this.AhkStdlibChannel.send(Map("kind", "task", "task", future.AhkStdlibOptions))
        return stdlib.None
    }

    poll()
    {
        if this.AhkStdlibFuture is AhkStdlibThreadFuture {
            if this.AhkStdlibPollResult()
                return stdlib.None
        } else if this.AhkStdlibProcessExited() {
            this.close()
            return stdlib.None
        }

        if this.AhkStdlibProcessExited() {
            this.AhkStdlibStopped := true
            if this.AhkStdlibFuture is AhkStdlibThreadFuture && !this.AhkStdlibFuture.AhkStdlibIsDone()
                this.AhkStdlibFuture.set_exception(RuntimeError("pool worker exited without a task result" this.AhkStdlibCapturedOutputSuffix(), -1))
            this.AhkStdlibFuture := stdlib.None
        }
        return stdlib.None
    }

    AhkStdlibPollResult()
    {
        loop {
            try response := this.AhkStdlibChannel.recv(0)
            catch AhkStdlibThread.Empty
                return false
            if !response.Has("kind") || response["kind"] != "result"
                continue
            future := this.AhkStdlibFuture
            this.AhkStdlibFuture := stdlib.None
            if response.Has("status") && response["status"] = "ok"
                future.set_result(response.Has("value") ? response["value"] : stdlib.json.Null)
            else
                future.set_exception(AhkStdlibThreadErrorFromPayload(response.Has("type") ? response["type"] : "Error", response.Has("message") ? response["message"] : ""))
            if this.AhkStdlibShutdownRequested
                this.AhkStdlibCloseAfterCompletedShutdown()
            return true
        }
    }

    AhkStdlibProcessExited()
    {
        if !this.AhkStdlibProcessHandle || this.AhkStdlibStopped
            return this.AhkStdlibStopped
        result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 0, "UInt")
        if result = 0 {
            this.AhkStdlibStopped := true
            return true
        }
        return false
    }

    is_idle()
    {
        return this.AhkStdlibStarted
            && !this.AhkStdlibStopped
            && !(this.AhkStdlibFuture is AhkStdlibThreadFuture)
    }

    shutdown(wait := true)
    {
        if this.AhkStdlibStarted && !this.AhkStdlibStopped {
            if !this.AhkStdlibShutdownRequested {
                try this.AhkStdlibChannel.send(Map("kind", "shutdown"))
                this.AhkStdlibShutdownRequested := true
            }
            if !AhkStdlibTruthValue(wait) && this.AhkStdlibFuture is AhkStdlibThreadFuture
                return stdlib.None
            timeoutMilliseconds := AhkStdlibTruthValue(wait) ? 2000 : 200
            if !this.AhkStdlibWaitForExit(timeoutMilliseconds)
                this.AhkStdlibTerminate()
        }
        this.close()
        return stdlib.None
    }

    AhkStdlibCloseAfterCompletedShutdown()
    {
        if !this.AhkStdlibWaitForExit(2000)
            this.AhkStdlibTerminate()
        this.close()
        return stdlib.None
    }

    AhkStdlibWaitForExit(timeoutMilliseconds)
    {
        if !this.AhkStdlibProcessHandle
            return true
        deadline := A_TickCount + timeoutMilliseconds
        loop {
            result := DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 10, "UInt")
            if result = 0 {
                this.AhkStdlibStopped := true
                return true
            }
            if result != 0x102
                return false
            if A_TickCount >= deadline
                return false
        }
    }

    AhkStdlibTerminate()
    {
        if this.AhkStdlibProcessHandle {
            DllCall("kernel32\TerminateProcess", "Ptr", this.AhkStdlibProcessHandle, "UInt", 1, "Int")
            DllCall("kernel32\WaitForSingleObject", "Ptr", this.AhkStdlibProcessHandle, "UInt", 100, "UInt")
        }
        this.AhkStdlibStopped := true
        return stdlib.None
    }

    close()
    {
        if this.AhkStdlibProcessHandle {
            DllCall("kernel32\CloseHandle", "Ptr", this.AhkStdlibProcessHandle)
            this.AhkStdlibProcessHandle := 0
        }
        try this.AhkStdlibChannel.close()
        if this.AhkStdlibScriptPath != "" && FileExist(this.AhkStdlibScriptPath)
            FileDelete this.AhkStdlibScriptPath
        if this.AhkStdlibStdoutPath != "" && FileExist(this.AhkStdlibStdoutPath)
            FileDelete this.AhkStdlibStdoutPath
        if this.AhkStdlibStderrPath != "" && FileExist(this.AhkStdlibStderrPath)
            FileDelete this.AhkStdlibStderrPath
        return stdlib.None
    }

    AhkStdlibWriteScript()
    {
        script := "#NoTrayIcon`n"
            . "#Requires AutoHotkey v2.0`n"
            . "#ErrorStdOut `"UTF-8`"`n"
            . "#Warn Unreachable, Off`n"
            . "#Include <stdlib\thread>`n"
            . "AhkStdlibThreadPoolWorkerChannel := AhkStdlibThreadChannel(" AhkStdlibThreadAhkQuote(this.AhkStdlibChannel.AhkStdlibRoot) ")`n"
            . this.AhkStdlibPool.AhkStdlibWorkerSource "`n"
            . "loop {`n"
            . "    message := AhkStdlibThreadPoolWorkerChannel.recv_worker()`n"
            . "    if message.Has(`"kind`") && message[`"kind`"] = `"shutdown`" {`n"
            . "        ExitApp 0`n"
            . "    }`n"
            . "    try {`n"
            . "        value := AhkStdlibThreadPoolHandleTask(message[`"task`"])`n"
            . "        AhkStdlibThreadPoolWorkerChannel.send_worker(Map(`"kind`", `"result`", `"status`", `"ok`", `"value`", value, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`")))`n"
            . "    } catch Error as err {`n"
            . "        AhkStdlibThreadPoolWorkerChannel.send_worker(Map(`"kind`", `"result`", `"status`", `"error`", `"value`", stdlib.json.Null, `"type`", Type(err), `"message`", err.Message, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`")))`n"
            . "    }`n"
            . "}`n"

        if FileExist(this.AhkStdlibScriptPath)
            FileDelete this.AhkStdlibScriptPath
        FileAppend script, this.AhkStdlibScriptPath, "UTF-8"
        return stdlib.None
    }

    AhkStdlibCapturedOutputSuffix()
    {
        output := ""
        if this.AhkStdlibStdoutPath != "" && FileExist(this.AhkStdlibStdoutPath)
            output .= FileRead(this.AhkStdlibStdoutPath, "UTF-8")
        if this.AhkStdlibStderrPath != "" && FileExist(this.AhkStdlibStderrPath)
            output .= FileRead(this.AhkStdlibStderrPath, "UTF-8")
        output := AhkStdlibThreadCompactText(output)
        return output = "" ? "" : ": " output
    }
}

class AhkStdlibThreadResultQueue
{
    __New()
    {
        this.AhkStdlibThreads := []
        this.AhkStdlibItems := []
        this.AhkStdlibQueued := Map()
    }

    add(worker)
    {
        if !(worker is AhkStdlibThreadWorker)
            throw TypeError("ResultQueue.add() expected stdlib.thread.Thread", -1)
        this.AhkStdlibThreads.Push(worker)
        return stdlib.None
    }

    poll()
    {
        completed := []
        for worker in this.AhkStdlibThreads {
            key := worker.pid ""
            if this.AhkStdlibQueued.Has(key)
                continue
            if worker.AhkStdlibStarted && !worker.is_alive() {
                item := worker.AhkStdlibResultItem()
                this.AhkStdlibQueued[key] := true
                this.AhkStdlibItems.Push(item)
                completed.Push(item)
            }
        }
        return completed
    }

    qsize()
    {
        return this.AhkStdlibItems.Length
    }

    empty()
    {
        return this.qsize() = 0
    }

    get_nowait()
    {
        if this.empty()
            throw AhkStdlibThread.Empty("", -1)
        return this.AhkStdlibItems.RemoveAt(1)
    }
}

AhkStdlibThreadWorkerRegistry(action := "list", worker := unset)
{
    static workers := Map()
    if action = "add" {
        workers[worker.AhkStdlibWorkerKey] := worker
        return stdlib.None
    }
    if action = "remove" {
        if workers.Has(worker.AhkStdlibWorkerKey)
            workers.Delete(worker.AhkStdlibWorkerKey)
        return stdlib.None
    }
    return workers
}

AhkStdlibThreadPumpSharedObjectRequests()
{
    workers := AhkStdlibThreadWorkerRegistry()
    for _, worker in workers {
        if worker.AhkStdlibStarted && !worker.AhkStdlibFinished
            worker.AhkStdlibProcessSharedObjectRequests()
    }
    return stdlib.None
}

AhkStdlibThreadErrorFromPayload(typeName, message)
{
    switch typeName {
        case "RuntimeError":
            return RuntimeError(message, -1)
        case "ValueError":
            return ValueError(message, -1)
        case "TypeError":
            return TypeError(message, -1)
        case "OSError":
            return OSError(message, -1)
        default:
            return Error(message, -1)
    }
}

AhkStdlibThreadTimeoutToMilliseconds(timeout)
{
    if AhkStdlibIsNone(timeout)
        return 0xFFFFFFFF
    value := Number(timeout)
    if value < 0
        throw ValueError("timeout value must be non-negative", -1)
    return Round(value * 1000)
}

AhkStdlibThreadFirstJsonFile(directory)
{
    first := ""
    firstName := ""
    Loop Files, directory "\*.json", "F" {
        if first = "" || StrCompare(A_LoopFileName, firstName) < 0 {
            first := A_LoopFileFullPath
            firstName := A_LoopFileName
        }
    }
    return first
}

AhkStdlibThreadIsTransientFileAccessError(err)
{
    return InStr(err.Message, "being used by another process")
        || InStr(err.Message, "cannot access the file")
}

AhkStdlibThreadCompactText(text)
{
    compact := Trim(StrReplace(StrReplace(text, "`r", " "), "`n", " "))
    while InStr(compact, "  ")
        compact := StrReplace(compact, "  ", " ")
    if StrLen(compact) > 240
        return SubStr(compact, 1, 240)
    return compact
}

AhkStdlibThreadSharedMemoryName()
{
    return "Local\stdlib-thread-shm-" DllCall("kernel32\GetCurrentProcessId", "UInt") "-" A_TickCount "-" Random(100000, 999999)
}

AhkStdlibThreadSharedMemoryMutexName(sharedName)
{
    return "Local\stdlib-thread-mutex-" RegExReplace(sharedName, "[^A-Za-z0-9_-]", "_")
}

AhkStdlibThreadSharedMemoryNormalizeType(typeName)
{
    normalized := String(typeName)
    sizes := AhkStdlibThreadSharedMemoryTypeSizes()
    if sizes.Has(normalized)
        return normalized
    for candidate, _ in sizes {
        if StrLower(candidate) = StrLower(normalized)
            return candidate
    }
    throw ValueError("unsupported shared memory value type", -1)
}

AhkStdlibThreadSharedMemoryTypeSize(typeName)
{
    sizes := AhkStdlibThreadSharedMemoryTypeSizes()
    if !sizes.Has(typeName)
        throw ValueError("unsupported shared memory value type", -1)
    return sizes[typeName]
}

AhkStdlibThreadSharedMemoryTypeSizes()
{
    return Map(
        "Char", 1,
        "UChar", 1,
        "Short", 2,
        "UShort", 2,
        "Int", 4,
        "UInt", 4,
        "Int64", 8,
        "UInt64", 8,
        "Ptr", A_PtrSize,
        "UPtr", A_PtrSize,
        "Float", 4,
        "Double", 8
    )
}

AhkStdlibThreadSharedMemoryToBuffer(value)
{
    if value is Buffer
        return value
    if value is String
        return AhkStdlibThreadTextToBuffer(value, "UTF-8")
    if value is Array {
        bytesBuffer := Buffer(value.Length, 0)
        for index, item in value
            NumPut("UChar", Integer(item), bytesBuffer, index - 1)
        return bytesBuffer
    }
    throw TypeError("shared memory write value must be Buffer, String, or Array", -1)
}

AhkStdlibThreadTextToBuffer(text, encoding := "UTF-8")
{
    length := StrPut(text, encoding) - 1
    bytesBuffer := Buffer(length, 0)
    if length > 0
        StrPut(text, bytesBuffer, encoding)
    return bytesBuffer
}

AhkStdlibThreadBufferToNullTerminatedText(bytesBuffer, encoding := "UTF-8")
{
    length := bytesBuffer.Size
    loop bytesBuffer.Size {
        if NumGet(bytesBuffer, A_Index - 1, "UChar") = 0 {
            length := A_Index - 1
            break
        }
    }
    if length = 0
        return ""
    textBuffer := Buffer(length, 0)
    DllCall("kernel32\RtlMoveMemory", "Ptr", textBuffer.Ptr, "Ptr", bytesBuffer.Ptr, "UPtr", length)
    return StrGet(textBuffer, encoding)
}

AhkStdlibThreadCreateProcess(executable, args, workingDir, stdoutPath := unset, stderrPath := unset)
{
    commandLine := AhkStdlibThreadJoinCommand([executable, args*])
    startupSize := A_PtrSize = 8 ? 104 : 68
    processInfoSize := A_PtrSize = 8 ? 24 : 16
    startupInfo := Buffer(startupSize, 0)
    processInfo := Buffer(processInfoSize, 0)
    NumPut("UInt", startupSize, startupInfo, 0)
    stdoutFile := ""
    stderrFile := ""
    inheritHandles := false

    if IsSet(stdoutPath) && IsSet(stderrPath) {
        stdoutFile := FileOpen(stdoutPath, "w", "UTF-8-RAW")
        stderrFile := FileOpen(stderrPath, "w", "UTF-8-RAW")
        AhkStdlibThreadMakeHandleInheritable(stdoutFile.Handle)
        AhkStdlibThreadMakeHandleInheritable(stderrFile.Handle)
        stdinHandle := DllCall("kernel32\GetStdHandle", "Int", -10, "Ptr")
        flagsOffset := A_PtrSize = 8 ? 60 : 44
        stdinOffset := A_PtrSize = 8 ? 80 : 56
        stdoutOffset := A_PtrSize = 8 ? 88 : 60
        stderrOffset := A_PtrSize = 8 ? 96 : 64
        NumPut("UInt", 0x100, startupInfo, flagsOffset)
        NumPut("Ptr", stdinHandle, startupInfo, stdinOffset)
        NumPut("Ptr", stdoutFile.Handle, startupInfo, stdoutOffset)
        NumPut("Ptr", stderrFile.Handle, startupInfo, stderrOffset)
        inheritHandles := true
    }

    ok := false
    try {
        ok := DllCall(
            "kernel32\CreateProcessW",
            "Ptr", 0,
            "Str", commandLine,
            "Ptr", 0,
            "Ptr", 0,
            "Int", inheritHandles,
            "UInt", 0x08000000,
            "Ptr", 0,
            "Str", workingDir,
            "Ptr", startupInfo,
            "Ptr", processInfo,
            "Int"
        )
    } finally {
        if stdoutFile != ""
            stdoutFile.Close()
        if stderrFile != ""
            stderrFile.Close()
    }
    if !ok
        throw OSError("CreateProcessW failed: " A_LastError, -1)

    threadHandle := NumGet(processInfo, A_PtrSize, "Ptr")
    DllCall("kernel32\CloseHandle", "Ptr", threadHandle)
    return {
        ProcessHandle: NumGet(processInfo, 0, "Ptr"),
        ProcessId: NumGet(processInfo, A_PtrSize * 2, "UInt"),
        ThreadId: NumGet(processInfo, A_PtrSize * 2 + 4, "UInt"),
    }
}

AhkStdlibThreadMakeHandleInheritable(handle)
{
    if !DllCall("kernel32\SetHandleInformation", "Ptr", handle, "UInt", 1, "UInt", 1, "Int")
        throw OSError("SetHandleInformation failed: " A_LastError, -1)
    return stdlib.None
}

AhkStdlibThreadJoinCommand(items)
{
    parts := []
    for item in items
        parts.Push(AhkStdlibThreadCommandArg(item))
    return AhkStdlibThreadJoin(parts, " ")
}

AhkStdlibThreadCommandArg(value)
{
    text := value ""
    if text = ""
        return "`"`""
    if !RegExMatch(text, "[\s`"]")
        return text
    return "`"" StrReplace(text, "`"", "\`"") "`""
}

AhkStdlibThreadJoin(values, delimiter)
{
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

AhkStdlibThreadAhkQuote(value)
{
    text := value ""
    text := StrReplace(text, "``", "````")
    text := StrReplace(text, "`"", "```"")
    text := StrReplace(text, "`r", "``r")
    text := StrReplace(text, "`n", "``n")
    text := StrReplace(text, "`t", "``t")
    return "`"" text "`""
}

AhkStdlibThreadIndentSource(source)
{
    result := ""
    loop parse source, "`n", "`r"
        result .= "    " A_LoopField "`n"
    return result
}

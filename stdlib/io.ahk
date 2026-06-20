#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibIo
{
    static SEEK_SET := 0
    static SEEK_CUR := 1
    static SEEK_END := 2

    static DEFAULT_BUFFER_SIZE := 8192

    static UnsupportedOperation
    {
        get => AhkStdlibIoUnsupportedOperation
    }

    static UnsupportedOperation(args*)
    {
        return AhkStdlibIoUnsupportedOperation(args*)
    }

    static StringIO(initial_value := unset)
    {
        if !IsSet(initial_value) || AhkStdlibIsNone(initial_value)
            return AhkStdlibIoStringIO("")
        if !(initial_value is String)
            throw TypeError("initial_value must be str or None, not " AhkStdlibIoPythonTypeName(initial_value), -1)
        return AhkStdlibIoStringIO(initial_value)
    }

    static BytesIO(initial_bytes := unset)
    {
        if !IsSet(initial_bytes) || AhkStdlibIsNone(initial_bytes)
            return AhkStdlibIoBytesIO([])
        return AhkStdlibIoBytesIO(AhkStdlibIoBytesFromValue(initial_bytes))
    }

    static open(file, mode := "r", buffering := -1, encoding := unset, errors := unset, newline := unset, closefd := true, opener := unset)
    {
        if !(file is String)
            throw TypeError("expected str, bytes or os.PathLike object, not " AhkStdlibIoPythonTypeName(file), -1)
        if !(mode is String)
            throw TypeError("open() argument 2 must be str, not " AhkStdlibIoPythonTypeName(mode), -1)
        return AhkStdlibIoFileWrapper(file, mode)
    }

    static TextIOWrapper(buffer, encoding := unset, errors := unset, newline := unset, line_buffering := false, write_through := false)
    {
        return AhkStdlibIoTextIOWrapper(buffer, encoding?, newline?)
    }

    static IOBase := AhkStdlibIoIOBase
    static RawIOBase := AhkStdlibIoRawIOBase
    static BufferedIOBase := AhkStdlibIoBufferedIOBase
    static TextIOBase := AhkStdlibIoTextIOBase

    static FileIO(name, mode := "r")
    {
        return AhkStdlibIoFileIO(name, mode)
    }

    static BufferedReader(raw, buffer_size := unset)
    {
        return AhkStdlibIoBufferedReader(raw, buffer_size?)
    }

    static BufferedWriter(raw, buffer_size := unset)
    {
        return AhkStdlibIoBufferedWriter(raw, buffer_size?)
    }

    static BufferedRandom(raw, buffer_size := unset)
    {
        return AhkStdlibIoBufferedRandom(raw, buffer_size?)
    }

    static BufferedRWPair(reader, writer, buffer_size := unset)
    {
        return AhkStdlibIoBufferedRWPair(reader, writer, buffer_size?)
    }
}

class AhkStdlibIoUnsupportedOperation extends OSError
{
}

class AhkStdlibIoStringIO
{
    __New(text := "")
    {
        ; Content is stored as a list of chunks whose concatenation is the full
        ; value. Sequential writes (the common case) push a chunk in O(1); the
        ; string is only materialized lazily on read/seek/getvalue. This avoids
        ; the O(n^2) full-buffer copy the previous "before . text . after" did
        ; on every write.
        this.AhkStdlibChunks := text = "" ? [] : [text]
        this.AhkStdlibLength := StrLen(text)
        this.AhkStdlibPosition := 0
        this.closed := false
    }

    AhkStdlibMaterialize()
    {
        chunks := this.AhkStdlibChunks
        if chunks.Length = 0
            return ""
        if chunks.Length = 1
            return chunks[1]
        result := ""
        VarSetStrCapacity(&result, this.AhkStdlibLength)
        for chunk in chunks
            result .= chunk
        this.AhkStdlibChunks := [result]
        return result
    }

    getvalue()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibMaterialize()
    }

    read(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if !(size is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(size), -1)

        buffer := this.AhkStdlibMaterialize()
        length := this.AhkStdlibLength
        if size < 0
            size := length - this.AhkStdlibPosition
        if size <= 0
            return ""

        start := this.AhkStdlibPosition + 1
        text := SubStr(buffer, start, size)
        this.AhkStdlibPosition += StrLen(text)
        return text
    }

    readline(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if !(size is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(size), -1)
        if size = 0
            return ""

        buffer := this.AhkStdlibMaterialize()
        remaining := SubStr(buffer, this.AhkStdlibPosition + 1)
        if remaining = ""
            return ""

        newline := InStr(remaining, "`n")
        if newline {
            line := SubStr(remaining, 1, newline)
        } else {
            line := remaining
        }

        if size > 0 && StrLen(line) > size
            line := SubStr(line, 1, size)

        this.AhkStdlibPosition += StrLen(line)
        return line
    }

    readlines(hint := -1)
    {
        this.AhkStdlibEnsureOpen()
        if AhkStdlibIsNone(hint)
            hint := -1
        if !(hint is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(hint), -1)
        lines := []
        total := 0
        loop {
            line := this.readline()
            if line = ""
                break
            lines.Push(line)
            total += StrLen(line)
            if hint > 0 && total > hint
                break
        }
        return lines
    }

    writelines(lines)
    {
        this.AhkStdlibEnsureOpen()
        if !(IsObject(lines) && HasMethod(lines, "__Enum"))
            throw TypeError("'" AhkStdlibIoPythonTypeName(lines) "' object is not iterable", -1)
        for line in lines
            this.write(line)
        return stdlib.None
    }

    write(text)
    {
        this.AhkStdlibEnsureOpen()
        if !(text is String)
            throw TypeError("string argument expected, got '" Type(text) "'", -1)

        pos := this.AhkStdlibPosition
        length := this.AhkStdlibLength

        ; Fast path: appending at end-of-stream is an O(1) chunk push.
        if pos = length {
            if text != "" {
                this.AhkStdlibChunks.Push(text)
                this.AhkStdlibLength += StrLen(text)
            }
            this.AhkStdlibPosition += StrLen(text)
            return StrLen(text)
        }

        ; Slow path: overwrite/seek-back requires materializing and splicing.
        buffer := this.AhkStdlibMaterialize()
        padCount := pos - length
        if padCount > 0 {
            buffer .= AhkStdlibIoRepeatChar(Chr(0), padCount)
            length := pos
        }

        before := SubStr(buffer, 1, pos)
        afterStart := pos + StrLen(text) + 1
        after := SubStr(buffer, afterStart)
        newBuffer := before text after
        this.AhkStdlibChunks := [newBuffer]
        this.AhkStdlibLength := StrLen(newBuffer)
        this.AhkStdlibPosition := pos + StrLen(text)
        return StrLen(text)
    }

    tell()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibPosition
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibEnsureOpen()
        if !(pos is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(pos), -1)
        if !(whence is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(whence), -1)

        switch whence {
            case 0:
                if pos < 0
                    throw ValueError("Negative seek position " pos, -1)
                this.AhkStdlibPosition := pos
            case 1:
                if pos != 0
                    throw OSError("Can't do nonzero cur-relative seeks", -1)
            case 2:
                if pos != 0
                    throw OSError("Can't do nonzero cur-relative seeks", -1)
                this.AhkStdlibPosition := this.AhkStdlibLength
            default:
                throw ValueError("Invalid whence (" whence ", should be 0, 1 or 2)", -1)
        }
        return this.AhkStdlibPosition
    }

    truncate(size := unset)
    {
        this.AhkStdlibEnsureOpen()
        if IsSet(size) {
            if !(size is Integer)
                throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(size), -1)
            target := size
        } else {
            target := this.AhkStdlibPosition
        }

        if target < 0
            throw ValueError("Negative size value " target, -1)

        if target < this.AhkStdlibLength {
            buffer := this.AhkStdlibMaterialize()
            truncated := SubStr(buffer, 1, target)
            this.AhkStdlibChunks := [truncated]
            this.AhkStdlibLength := StrLen(truncated)
        }
        return target
    }

    close()
    {
        this.closed := true
    }

    AhkStdlibEnsureOpen()
    {
        if this.closed
            throw ValueError("I/O operation on closed file", -1)
    }
}

class AhkStdlibIoBytesIO
{
    __New(bytes := unset)
    {
        this.AhkStdlibBuffer := IsSet(bytes) ? AhkStdlibIoBytesFromValue(bytes) : []
        this.AhkStdlibPosition := 0
        this.closed := false
    }

    getvalue()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibBuffer.Clone()
    }

    read(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        size := this.AhkStdlibNormalizeSize(size, "argument should be integer or None, not")

        remaining := this.AhkStdlibBuffer.Length - this.AhkStdlibPosition
        if size < 0
            size := remaining
        if size <= 0 || remaining <= 0
            return []

        count := Min(size, remaining)
        out := []
        loop count {
            out.Push(this.AhkStdlibBuffer[this.AhkStdlibPosition + 1])
            this.AhkStdlibPosition += 1
        }
        return out
    }

    read1(size := -1)
    {
        return this.read(size)
    }

    readinto(target)
    {
        this.AhkStdlibEnsureOpen()
        if target is Buffer
            return this.AhkStdlibReadIntoBuffer(target)
        if target is Array
            return this.AhkStdlibReadIntoArray(target)
        throw TypeError("readinto() argument must be read-write bytes-like object, not " AhkStdlibIoPythonTypeName(target), -1)
    }

    readinto1(target)
    {
        return this.readinto(target)
    }

    readline(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        size := this.AhkStdlibNormalizeSize(size, "argument should be integer or None, not")
        if size = 0 || this.AhkStdlibPosition >= this.AhkStdlibBuffer.Length
            return []

        out := []
        while this.AhkStdlibPosition < this.AhkStdlibBuffer.Length {
            if size > 0 && out.Length >= size
                break
            byte := this.AhkStdlibBuffer[this.AhkStdlibPosition + 1]
            out.Push(byte)
            this.AhkStdlibPosition += 1
            if byte = 10
                break
        }
        return out
    }

    readlines(hint := -1)
    {
        this.AhkStdlibEnsureOpen()
        hint := this.AhkStdlibNormalizeSize(hint, "integer argument expected, got")
        lines := []
        total := 0
        while this.AhkStdlibPosition < this.AhkStdlibBuffer.Length {
            line := this.readline()
            if line.Length = 0
                break
            lines.Push(line)
            total += line.Length
            if hint > 0 && total >= hint
                break
        }
        return lines
    }

    write(bytes)
    {
        this.AhkStdlibEnsureOpen()
        values := AhkStdlibIoBytesFromValue(bytes)
        padCount := this.AhkStdlibPosition - this.AhkStdlibBuffer.Length
        loop Max(padCount, 0)
            this.AhkStdlibBuffer.Push(0)

        for index, byte in values {
            targetIndex := this.AhkStdlibPosition + index
            if targetIndex <= this.AhkStdlibBuffer.Length
                this.AhkStdlibBuffer[targetIndex] := byte
            else
                this.AhkStdlibBuffer.Push(byte)
        }
        this.AhkStdlibPosition += values.Length
        return values.Length
    }

    writelines(lines)
    {
        this.AhkStdlibEnsureOpen()
        if !(IsObject(lines) && HasMethod(lines, "__Enum"))
            throw TypeError("'" AhkStdlibIoPythonTypeName(lines) "' object is not iterable", -1)
        for line in lines
            this.write(line)
        return stdlib.None
    }

    readable()
    {
        this.AhkStdlibEnsureOpen()
        return true
    }

    writable()
    {
        this.AhkStdlibEnsureOpen()
        return true
    }

    seekable()
    {
        this.AhkStdlibEnsureOpen()
        return true
    }

    isatty()
    {
        this.AhkStdlibEnsureOpen()
        return false
    }

    flush()
    {
        this.AhkStdlibEnsureOpen()
        return stdlib.None
    }

    fileno()
    {
        throw AhkStdlibIoUnsupportedOperation("fileno", -1)
    }

    detach()
    {
        throw AhkStdlibIoUnsupportedOperation("detach", -1)
    }

    tell()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibPosition
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibEnsureOpen()
        if !(pos is Integer)
            throw TypeError("an integer is required", -1)
        if !(whence is Integer)
            throw TypeError("an integer is required", -1)

        switch whence {
            case 0:
                target := pos
            case 1:
                target := this.AhkStdlibPosition + pos
            case 2:
                target := this.AhkStdlibBuffer.Length + pos
            default:
                throw ValueError("invalid whence (" whence ", should be 0, 1 or 2)", -1)
        }

        if target < 0
            throw ValueError("negative seek value " target, -1)
        this.AhkStdlibPosition := target
        return this.AhkStdlibPosition
    }

    truncate(size := unset)
    {
        this.AhkStdlibEnsureOpen()
        if IsSet(size) && !AhkStdlibIsNone(size) {
            if !(size is Integer)
                throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(size), -1)
            target := size
        } else {
            target := this.AhkStdlibPosition
        }

        if target < 0
            throw ValueError("negative size value " target, -1)
        while this.AhkStdlibBuffer.Length > target
            this.AhkStdlibBuffer.RemoveAt(this.AhkStdlibBuffer.Length)
        return target
    }

    close()
    {
        this.closed := true
        return stdlib.None
    }

    AhkStdlibEnsureOpen()
    {
        if this.closed
            throw ValueError("I/O operation on closed file.", -1)
    }

    AhkStdlibNormalizeSize(size, messagePrefix)
    {
        if AhkStdlibIsNone(size)
            return -1
        if !(size is Integer)
            throw TypeError(messagePrefix " '" AhkStdlibIoPythonTypeName(size) "'", -1)
        return size
    }

    AhkStdlibReadIntoBuffer(target)
    {
        remaining := Max(this.AhkStdlibBuffer.Length - this.AhkStdlibPosition, 0)
        count := Min(target.Size, remaining)
        loop count
            NumPut("UChar", this.AhkStdlibBuffer[this.AhkStdlibPosition + A_Index], target, A_Index - 1)
        this.AhkStdlibPosition += count
        return count
    }

    AhkStdlibReadIntoArray(target)
    {
        remaining := Max(this.AhkStdlibBuffer.Length - this.AhkStdlibPosition, 0)
        count := Min(target.Length, remaining)
        loop count
            target[A_Index] := this.AhkStdlibBuffer[this.AhkStdlibPosition + A_Index]
        this.AhkStdlibPosition += count
        return count
    }
}

class AhkStdlibIoFileWrapper
{
    __New(path, mode)
    {
        this.AhkStdlibPath := path
        this.AhkStdlibMode := mode
        this.AhkStdlibParseMode(mode)

        if this.AhkStdlibReadInitial {
            if !FileExist(path) {
                if this.AhkStdlibMustExist
                    throw OSError("[Errno 2] No such file or directory: '" path "'", -1)
                content := ""
            } else {
                content := FileRead(path, "UTF-8")
            }
        } else {
            content := ""
        }

        this.AhkStdlibContent := content
        this.AhkStdlibLength := StrLen(content)
        this.AhkStdlibPosition := this.AhkStdlibAtEnd ? this.AhkStdlibLength : 0
        this.AhkStdlibDirty := !this.AhkStdlibReadInitial || this.AhkStdlibTruncate
        this.closed := false

        if this.AhkStdlibTruncate || !this.AhkStdlibReadInitial
            this.AhkStdlibFlushToDisk()
    }

    AhkStdlibParseMode(mode)
    {
        normalized := StrReplace(StrReplace(mode, "b"), "t")
        switch normalized {
            case "r":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := false
                this.AhkStdlibReadInitial := true, this.AhkStdlibMustExist := true
                this.AhkStdlibTruncate := false, this.AhkStdlibAtEnd := false
            case "w":
                this.AhkStdlibCanRead := false, this.AhkStdlibCanWrite := true
                this.AhkStdlibReadInitial := false, this.AhkStdlibMustExist := false
                this.AhkStdlibTruncate := true, this.AhkStdlibAtEnd := false
            case "a":
                this.AhkStdlibCanRead := false, this.AhkStdlibCanWrite := true
                this.AhkStdlibReadInitial := true, this.AhkStdlibMustExist := false
                this.AhkStdlibTruncate := false, this.AhkStdlibAtEnd := true
            case "r+", "+r":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true
                this.AhkStdlibReadInitial := true, this.AhkStdlibMustExist := true
                this.AhkStdlibTruncate := false, this.AhkStdlibAtEnd := false
            case "w+", "+w":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true
                this.AhkStdlibReadInitial := false, this.AhkStdlibMustExist := false
                this.AhkStdlibTruncate := true, this.AhkStdlibAtEnd := false
            case "a+", "+a":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true
                this.AhkStdlibReadInitial := true, this.AhkStdlibMustExist := false
                this.AhkStdlibTruncate := false, this.AhkStdlibAtEnd := true
            default:
                throw ValueError("invalid mode: '" mode "'", -1)
        }
    }

    read(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if !this.AhkStdlibCanRead
            throw AhkStdlibIoUnsupportedOperation("not readable", -1)
        if AhkStdlibIsNone(size)
            size := -1
        if !(size is Integer)
            throw TypeError("argument should be integer or None, not " AhkStdlibIoPythonTypeName(size), -1)
        if size < 0
            size := this.AhkStdlibLength - this.AhkStdlibPosition
        if size <= 0
            return ""
        text := SubStr(this.AhkStdlibContent, this.AhkStdlibPosition + 1, size)
        this.AhkStdlibPosition += StrLen(text)
        return text
    }

    readline(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if !this.AhkStdlibCanRead
            throw AhkStdlibIoUnsupportedOperation("not readable", -1)
        remaining := SubStr(this.AhkStdlibContent, this.AhkStdlibPosition + 1)
        if remaining = ""
            return ""
        newline := InStr(remaining, "`n")
        line := newline ? SubStr(remaining, 1, newline) : remaining
        if size > 0 && StrLen(line) > size
            line := SubStr(line, 1, size)
        this.AhkStdlibPosition += StrLen(line)
        return line
    }

    readlines(hint := -1)
    {
        this.AhkStdlibEnsureOpen()
        lines := []
        loop {
            line := this.readline()
            if line = ""
                break
            lines.Push(line)
        }
        return lines
    }

    write(text)
    {
        this.AhkStdlibEnsureOpen()
        if !this.AhkStdlibCanWrite
            throw AhkStdlibIoUnsupportedOperation("not writable", -1)
        if !(text is String)
            throw TypeError("write() argument must be str, not " AhkStdlibIoPythonTypeName(text), -1)

        pos := this.AhkStdlibPosition
        if pos > this.AhkStdlibLength {
            this.AhkStdlibContent .= AhkStdlibIoRepeatChar(Chr(0), pos - this.AhkStdlibLength)
            this.AhkStdlibLength := pos
        }
        before := SubStr(this.AhkStdlibContent, 1, pos)
        after := SubStr(this.AhkStdlibContent, pos + StrLen(text) + 1)
        this.AhkStdlibContent := before text after
        this.AhkStdlibLength := StrLen(this.AhkStdlibContent)
        this.AhkStdlibPosition := pos + StrLen(text)
        this.AhkStdlibDirty := true
        return StrLen(text)
    }

    writelines(lines)
    {
        this.AhkStdlibEnsureOpen()
        if !(IsObject(lines) && HasMethod(lines, "__Enum"))
            throw TypeError("'" AhkStdlibIoPythonTypeName(lines) "' object is not iterable", -1)
        for line in lines
            this.write(line)
        return stdlib.None
    }

    tell()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibPosition
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibEnsureOpen()
        if !(pos is Integer)
            throw TypeError("an integer is required", -1)
        switch whence {
            case 0:
                target := pos
            case 1:
                target := this.AhkStdlibPosition + pos
            case 2:
                target := this.AhkStdlibLength + pos
            default:
                throw ValueError("invalid whence (" whence ", should be 0, 1 or 2)", -1)
        }
        if target < 0
            throw ValueError("negative seek value " target, -1)
        this.AhkStdlibPosition := target
        return this.AhkStdlibPosition
    }

    readable()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibCanRead
    }

    writable()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibCanWrite
    }

    seekable()
    {
        this.AhkStdlibEnsureOpen()
        return true
    }

    flush()
    {
        this.AhkStdlibEnsureOpen()
        this.AhkStdlibFlushToDisk()
        return stdlib.None
    }

    close()
    {
        if this.closed
            return stdlib.None
        if this.AhkStdlibDirty
            this.AhkStdlibFlushToDisk()
        this.closed := true
        return stdlib.None
    }

    AhkStdlibFlushToDisk()
    {
        if !this.AhkStdlibCanWrite
            return
        handle := FileOpen(this.AhkStdlibPath, "w", "UTF-8")
        if !handle
            throw OSError("could not open '" this.AhkStdlibPath "' for writing", -1)
        handle.Write(this.AhkStdlibContent)
        handle.Close()
        this.AhkStdlibDirty := false
    }

    AhkStdlibEnsureOpen()
    {
        if this.closed
            throw ValueError("I/O operation on closed file.", -1)
    }
}

class AhkStdlibIoTextIOWrapper
{
    __New(buffer, encoding := unset, newline := unset)
    {
        this.AhkStdlibBuffer := buffer
        this.AhkStdlibPosition := 0
        this.closed := false
        this.encoding := (IsSet(encoding) && !AhkStdlibIsNone(encoding)) ? encoding : "UTF-8"
        ; newline: unset/None -> universal newlines (translate \r\n and \r to \n
        ; on read). "" -> no translation. Any other string -> that terminator.
        this.AhkStdlibNewline := IsSet(newline) ? newline : stdlib.None
        this.AhkStdlibLoad()
    }

    AhkStdlibLoad()
    {
        ; Decode the buffer's raw bytes through the configured encoding, then
        ; apply universal-newline translation for reads.
        raw := this.AhkStdlibBuffer.getvalue()
        text := AhkStdlibIoDecodeBytes(raw, this.encoding)
        this.AhkStdlibContent := AhkStdlibIoTranslateReadNewlines(text, this.AhkStdlibNewline)
        this.AhkStdlibLength := StrLen(this.AhkStdlibContent)
    }

    read(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if AhkStdlibIsNone(size)
            size := -1
        if size < 0
            size := this.AhkStdlibLength - this.AhkStdlibPosition
        if size <= 0
            return ""
        text := SubStr(this.AhkStdlibContent, this.AhkStdlibPosition + 1, size)
        this.AhkStdlibPosition += StrLen(text)
        return text
    }

    readline(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        remaining := SubStr(this.AhkStdlibContent, this.AhkStdlibPosition + 1)
        if remaining = ""
            return ""
        newline := InStr(remaining, "`n")
        line := newline ? SubStr(remaining, 1, newline) : remaining
        this.AhkStdlibPosition += StrLen(line)
        return line
    }

    readlines(hint := -1)
    {
        this.AhkStdlibEnsureOpen()
        lines := []
        loop {
            line := this.readline()
            if line = ""
                break
            lines.Push(line)
        }
        return lines
    }

    write(text)
    {
        this.AhkStdlibEnsureOpen()
        if !(text is String)
            throw TypeError("write() argument must be str, not " AhkStdlibIoPythonTypeName(text), -1)
        ; Encode through the configured encoding into a byte-value array the
        ; underlying BytesIO understands.
        bytes := AhkStdlibIoEncodeBytes(text, this.encoding)
        this.AhkStdlibBuffer.write(bytes)
        this.AhkStdlibContent .= AhkStdlibIoTranslateReadNewlines(text, this.AhkStdlibNewline)
        this.AhkStdlibLength := StrLen(this.AhkStdlibContent)
        this.AhkStdlibPosition := this.AhkStdlibLength
        return StrLen(text)
    }

    tell()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibPosition
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibEnsureOpen()
        switch whence {
            case 0:
                this.AhkStdlibPosition := pos
            case 2:
                this.AhkStdlibPosition := this.AhkStdlibLength
            default:
                this.AhkStdlibPosition += pos
        }
        return this.AhkStdlibPosition
    }

    close()
    {
        this.closed := true
        return stdlib.None
    }

    AhkStdlibEnsureOpen()
    {
        if this.closed
            throw ValueError("I/O operation on closed file.", -1)
    }
}

stdlib.io := AhkStdlibIo

; Decode an int-array (or Buffer) of raw bytes into a string via `encoding`.
AhkStdlibIoDecodeBytes(raw, encoding)
{
    if raw is Buffer {
        if raw.Size = 0
            return ""
        return StrGet(raw, raw.Size, encoding)
    }
    ; Otherwise an array of byte values (BytesIO). Pack into a Buffer and decode.
    if !(raw is Array) || raw.Length = 0
        return ""
    buf := Buffer(raw.Length)
    for index, byte in raw
        NumPut("UChar", byte & 0xFF, buf, index - 1)
    return StrGet(buf, raw.Length, encoding)
}

; Encode a string into an array of byte values via `encoding` (no NUL term).
AhkStdlibIoEncodeBytes(text, encoding)
{
    if text = ""
        return []
    size := StrPut(text, encoding) ; includes space for terminator
    buf := Buffer(size)
    written := StrPut(text, buf, encoding)
    ; Drop the encoding's NUL terminator(s): StrPut returns chars for some
    ; encodings, so recompute the true byte length from the buffer content.
    byteLen := AhkStdlibIoEncodedByteLength(text, encoding, buf)
    bytes := []
    i := 0
    while i < byteLen {
        bytes.Push(NumGet(buf, i, "UChar"))
        i += 1
    }
    return bytes
}

AhkStdlibIoEncodedByteLength(text, encoding, buf)
{
    ; StrPut's return value is in characters for UTF-16 and bytes for others,
    ; minus reliability quirks; derive the byte length by re-encoding to a sized
    ; buffer and trimming the single/double NUL terminator.
    normalized := StrLower(StrReplace(encoding, "-"))
    full := buf.Size
    if (normalized = "utf16" || normalized = "utf16le" || normalized = "unicode" || normalized = "cp1200") {
        ; 2-byte terminator.
        return full - 2
    }
    return full - 1
}

; Universal-newline translation for reads: with None newline, \r\n and lone \r
; collapse to \n. With "" or a specific terminator, leave text unchanged.
AhkStdlibIoTranslateReadNewlines(text, newline)
{
    if !AhkStdlibIsNone(newline)
        return text
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    return text
}


AhkStdlibIoPythonTypeName(value)
{
    if AhkStdlibIsNone(value)
        return "NoneType"
    if value is Integer
        return "int"
    if value is Float
        return "float"
    if value is String
        return "str"
    if IsObject(value)
        return "object"
    return Type(value)
}

AhkStdlibIoRepeatChar(char, count)
{
    text := ""
    loop count
        text .= char
    return text
}

AhkStdlibIoBytesFromValue(value)
{
    if value is String
        throw TypeError("a bytes-like object is required, not 'str'", -1)
    if value is Integer
        throw TypeError("a bytes-like object is required, not 'int'", -1)
    if value is Buffer
        return AhkStdlibIoBytesFromBuffer(value)
    if value is Array {
        bytes := []
        for item in value
            bytes.Push(AhkStdlibIoRequireByte(item))
        return bytes
    }
    throw TypeError("a bytes-like object is required, not '" AhkStdlibIoPythonTypeName(value) "'", -1)
}

AhkStdlibIoBytesFromBuffer(buffer)
{
    bytes := []
    loop buffer.Size
        bytes.Push(NumGet(buffer, A_Index - 1, "UChar"))
    return bytes
}

AhkStdlibIoRequireByte(value)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibIoPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
    if value < 0 || value > 255
        throw ValueError("byte must be in range(0, 256)", -1)
    return value
}

; ============================================================================
; io class hierarchy (IOBase / RawIOBase / BufferedIOBase / TextIOBase) plus the
; concrete FileIO and Buffered* wrappers. These mirror CPython's layered stream
; model: a raw byte stream (FileIO) wrapped by a buffering layer (BufferedReader
; /Writer/Random) and optionally decoded by TextIOWrapper. Single-threaded, so
; no locking is needed.
; ============================================================================

class AhkStdlibIoIOBase
{
    __New()
    {
        this.closed := false
    }

    readable() => false
    writable() => false
    seekable() => false

    AhkStdlibCheckClosed()
    {
        if this.closed
            throw ValueError("I/O operation on closed file.", -1)
    }

    AhkStdlibCheckReadable()
    {
        if !this.readable()
            throw AhkStdlibIoUnsupportedOperation("File or stream is not readable.", -1)
    }

    AhkStdlibCheckWritable()
    {
        if !this.writable()
            throw AhkStdlibIoUnsupportedOperation("File or stream is not writable.", -1)
    }

    AhkStdlibCheckSeekable()
    {
        if !this.seekable()
            throw AhkStdlibIoUnsupportedOperation("File or stream is not seekable.", -1)
    }

    flush()
    {
        this.AhkStdlibCheckClosed()
        return ""
    }

    close()
    {
        if !this.closed {
            try this.flush()
            this.closed := true
        }
        return ""
    }

    tell()
    {
        return this.seek(0, 1)
    }
}

class AhkStdlibIoRawIOBase extends AhkStdlibIoIOBase
{
}

class AhkStdlibIoBufferedIOBase extends AhkStdlibIoIOBase
{
}

class AhkStdlibIoTextIOBase extends AhkStdlibIoIOBase
{
}

; FileIO: unbuffered raw bytes over a real file handle. read/readall return a
; Buffer; write accepts a Buffer or a (latin-1) string. Mirrors io.FileIO.
class AhkStdlibIoFileIO extends AhkStdlibIoRawIOBase
{
    __New(name, mode := "r")
    {
        this.name := name
        this.AhkStdlibMode := mode
        this.AhkStdlibParseMode(mode)
        if this.AhkStdlibMustExist && !FileExist(name)
            throw OSError("[Errno 2] No such file or directory: '" name "'", -1)
        ; Open binary (no encoding) so bytes pass through verbatim.
        flags := this.AhkStdlibCanWrite ? (this.AhkStdlibCanRead ? "rw" : "w") : "r"
        if this.AhkStdlibAppend
            flags := "a"
        this.AhkStdlibFile := FileOpen(name, flags)
        if this.AhkStdlibTruncate
            this.AhkStdlibFile.Length := 0
        if this.AhkStdlibAppend
            this.AhkStdlibFile.Seek(0, 2)
        this.closed := false
    }

    AhkStdlibParseMode(mode)
    {
        normalized := StrReplace(StrReplace(mode, "b"), "t")
        this.AhkStdlibAppend := false
        this.AhkStdlibTruncate := false
        switch normalized {
            case "r":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := false, this.AhkStdlibMustExist := true
            case "w":
                this.AhkStdlibCanRead := false, this.AhkStdlibCanWrite := true, this.AhkStdlibMustExist := false, this.AhkStdlibTruncate := true
            case "a":
                this.AhkStdlibCanRead := false, this.AhkStdlibCanWrite := true, this.AhkStdlibMustExist := false, this.AhkStdlibAppend := true
            case "r+", "+r":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true, this.AhkStdlibMustExist := true
            case "w+", "+w":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true, this.AhkStdlibMustExist := false, this.AhkStdlibTruncate := true
            case "a+", "+a":
                this.AhkStdlibCanRead := true, this.AhkStdlibCanWrite := true, this.AhkStdlibMustExist := false, this.AhkStdlibAppend := true
            default:
                throw ValueError("invalid mode: '" mode "'", -1)
        }
    }

    readable() => this.AhkStdlibCanRead
    writable() => this.AhkStdlibCanWrite
    seekable() => true

    read(size := -1)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibCheckReadable()
        if AhkStdlibIsNone(size) || size < 0
            return this.readall()
        if size = 0
            return Buffer(0)
        remaining := this.AhkStdlibFile.Length - this.AhkStdlibFile.Pos
        if remaining <= 0
            return Buffer(0)
        count := Min(size, remaining)
        buf := Buffer(count)
        got := this.AhkStdlibFile.RawRead(buf, count)
        return got = count ? buf : AhkStdlibIoTrimBuffer(buf, got)
    }

    readall()
    {
        remaining := this.AhkStdlibFile.Length - this.AhkStdlibFile.Pos
        if remaining <= 0
            return Buffer(0)
        buf := Buffer(remaining)
        got := this.AhkStdlibFile.RawRead(buf, remaining)
        return got = remaining ? buf : AhkStdlibIoTrimBuffer(buf, got)
    }

    readinto(target)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibCheckReadable()
        return this.AhkStdlibFile.RawRead(target, target.Size)
    }

    write(data)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibCheckWritable()
        if data is Buffer
            return this.AhkStdlibFile.RawWrite(data, data.Size)
        ; A string is written as raw bytes (latin-1 style: low byte per char).
        buf := AhkStdlibIoStringToByteBuffer(data)
        return this.AhkStdlibFile.RawWrite(buf, buf.Size)
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibFile.Seek(pos, whence)
        return this.AhkStdlibFile.Pos
    }

    tell()
    {
        this.AhkStdlibCheckClosed()
        return this.AhkStdlibFile.Pos
    }

    truncate(size := unset)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibCheckWritable()
        target := IsSet(size) ? size : this.AhkStdlibFile.Pos
        this.AhkStdlibFile.Length := target
        return target
    }

    flush()
    {
        this.AhkStdlibCheckClosed()
        return ""
    }

    close()
    {
        if !this.closed {
            try this.AhkStdlibFile.Close()
            this.closed := true
        }
        return ""
    }
}

; Convert a Buffer to a fresh Buffer of exactly `count` bytes.
AhkStdlibIoTrimBuffer(buf, count)
{
    trimmed := Buffer(count)
    if count > 0
        DllCall("RtlMoveMemory", "Ptr", trimmed.Ptr, "Ptr", buf.Ptr, "UPtr", count)
    return trimmed
}

; Pack a string's low byte per character into a Buffer (latin-1 semantics).
AhkStdlibIoStringToByteBuffer(text)
{
    n := StrLen(text)
    buf := Buffer(n)
    i := 1
    while i <= n {
        NumPut("UChar", Ord(SubStr(text, i, 1)) & 0xFF, buf, i - 1)
        i += 1
    }
    return buf
}

; BufferedReader: read-ahead buffering over a raw readable stream. read(size)
; pulls from an internal byte buffer, refilling from the raw stream in
; DEFAULT_BUFFER_SIZE chunks. peek/read1 mirror CPython.
class AhkStdlibIoBufferedReader extends AhkStdlibIoBufferedIOBase
{
    __New(raw, buffer_size := unset)
    {
        this.raw := raw
        this.AhkStdlibBufSize := IsSet(buffer_size) ? buffer_size : AhkStdlibIo.DEFAULT_BUFFER_SIZE
        this.AhkStdlibPending := Buffer(0)   ; bytes read-ahead but not yet consumed
        this.AhkStdlibPendingPos := 0
        this.closed := false
    }

    readable() => true
    writable() => false
    seekable() => this.raw.seekable()

    AhkStdlibPendingCount()
    {
        return this.AhkStdlibPending.Size - this.AhkStdlibPendingPos
    }

    AhkStdlibFill()
    {
        chunk := this.raw.read(this.AhkStdlibBufSize)
        this.AhkStdlibPending := chunk
        this.AhkStdlibPendingPos := 0
        return chunk.Size
    }

    read(size := -1)
    {
        this.AhkStdlibCheckClosed()
        if AhkStdlibIsNone(size) || size < 0 {
            ; Read everything: drain pending then the raw tail.
            parts := []
            if this.AhkStdlibPendingCount() > 0
                parts.Push(AhkStdlibIoSliceBuffer(this.AhkStdlibPending, this.AhkStdlibPendingPos, this.AhkStdlibPendingCount()))
            this.AhkStdlibPendingPos := this.AhkStdlibPending.Size
            rest := this.raw.read(-1)
            if rest.Size > 0
                parts.Push(rest)
            return AhkStdlibIoConcatBuffers(parts)
        }
        if size = 0
            return Buffer(0)
        parts := []
        need := size
        while need > 0 {
            avail := this.AhkStdlibPendingCount()
            if avail = 0 {
                if this.AhkStdlibFill() = 0
                    break
                avail := this.AhkStdlibPendingCount()
                if avail = 0
                    break
            }
            take := Min(need, avail)
            parts.Push(AhkStdlibIoSliceBuffer(this.AhkStdlibPending, this.AhkStdlibPendingPos, take))
            this.AhkStdlibPendingPos += take
            need -= take
        }
        return AhkStdlibIoConcatBuffers(parts)
    }

    read1(size := -1)
    {
        this.AhkStdlibCheckClosed()
        if this.AhkStdlibPendingCount() = 0
            this.AhkStdlibFill()
        avail := this.AhkStdlibPendingCount()
        take := (size < 0) ? avail : Min(size, avail)
        result := AhkStdlibIoSliceBuffer(this.AhkStdlibPending, this.AhkStdlibPendingPos, take)
        this.AhkStdlibPendingPos += take
        return result
    }

    peek(size := 0)
    {
        this.AhkStdlibCheckClosed()
        if this.AhkStdlibPendingCount() = 0
            this.AhkStdlibFill()
        return AhkStdlibIoSliceBuffer(this.AhkStdlibPending, this.AhkStdlibPendingPos, this.AhkStdlibPendingCount())
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibCheckClosed()
        this.AhkStdlibCheckSeekable()
        ; Discard the read-ahead buffer and seek the raw stream.
        this.AhkStdlibPending := Buffer(0)
        this.AhkStdlibPendingPos := 0
        return this.raw.seek(pos, whence)
    }

    tell()
    {
        this.AhkStdlibCheckClosed()
        return this.raw.tell() - this.AhkStdlibPendingCount()
    }

    flush()
    {
        this.AhkStdlibCheckClosed()
        return ""
    }

    close()
    {
        if !this.closed {
            try this.raw.close()
            this.closed := true
        }
        return ""
    }
}

; BufferedWriter: accumulate writes and flush to the raw stream in bulk.
class AhkStdlibIoBufferedWriter extends AhkStdlibIoBufferedIOBase
{
    __New(raw, buffer_size := unset)
    {
        this.raw := raw
        this.AhkStdlibBufSize := IsSet(buffer_size) ? buffer_size : AhkStdlibIo.DEFAULT_BUFFER_SIZE
        this.AhkStdlibParts := []
        this.AhkStdlibPendingBytes := 0
        this.closed := false
    }

    readable() => false
    writable() => true
    seekable() => this.raw.seekable()

    write(data)
    {
        this.AhkStdlibCheckClosed()
        buf := (data is Buffer) ? data : AhkStdlibIoStringToByteBuffer(data)
        this.AhkStdlibParts.Push(buf)
        this.AhkStdlibPendingBytes += buf.Size
        if this.AhkStdlibPendingBytes >= this.AhkStdlibBufSize
            this.flush()
        return buf.Size
    }

    flush()
    {
        this.AhkStdlibCheckClosed()
        if this.AhkStdlibParts.Length = 0
            return ""
        merged := AhkStdlibIoConcatBuffers(this.AhkStdlibParts)
        this.raw.write(merged)
        if HasMethod(this.raw, "flush")
            this.raw.flush()
        this.AhkStdlibParts := []
        this.AhkStdlibPendingBytes := 0
        return ""
    }

    seek(pos, whence := 0)
    {
        this.flush()
        return this.raw.seek(pos, whence)
    }

    tell()
    {
        return this.raw.tell() + this.AhkStdlibPendingBytes
    }

    close()
    {
        if !this.closed {
            try this.flush()
            try this.raw.close()
            this.closed := true
        }
        return ""
    }
}

; BufferedRandom: a seekable read+write buffered stream. Keeps it simple by
; flushing writes before reads/seeks so the raw position is authoritative.
class AhkStdlibIoBufferedRandom extends AhkStdlibIoBufferedIOBase
{
    __New(raw, buffer_size := unset)
    {
        this.raw := raw
        this.AhkStdlibBufSize := IsSet(buffer_size) ? buffer_size : AhkStdlibIo.DEFAULT_BUFFER_SIZE
        this.closed := false
    }

    readable() => true
    writable() => true
    seekable() => true

    read(size := -1)
    {
        this.AhkStdlibCheckClosed()
        return this.raw.read(size)
    }

    write(data)
    {
        this.AhkStdlibCheckClosed()
        return this.raw.write(data)
    }

    seek(pos, whence := 0)
    {
        this.AhkStdlibCheckClosed()
        return this.raw.seek(pos, whence)
    }

    tell()
    {
        this.AhkStdlibCheckClosed()
        return this.raw.tell()
    }

    flush()
    {
        this.AhkStdlibCheckClosed()
        if HasMethod(this.raw, "flush")
            this.raw.flush()
        return ""
    }

    close()
    {
        if !this.closed {
            try this.flush()
            try this.raw.close()
            this.closed := true
        }
        return ""
    }
}

; BufferedRWPair: pairs an independent reader and writer (e.g. a socket).
class AhkStdlibIoBufferedRWPair extends AhkStdlibIoBufferedIOBase
{
    __New(reader, writer, buffer_size := unset)
    {
        size := IsSet(buffer_size) ? buffer_size : AhkStdlibIo.DEFAULT_BUFFER_SIZE
        this.AhkStdlibReader := AhkStdlibIoBufferedReader(reader, size)
        this.AhkStdlibWriter := AhkStdlibIoBufferedWriter(writer, size)
        this.closed := false
    }

    readable() => true
    writable() => true
    seekable() => false

    read(size := -1) => this.AhkStdlibReader.read(size)
    read1(size := -1) => this.AhkStdlibReader.read1(size)
    peek(size := 0) => this.AhkStdlibReader.peek(size)
    write(data) => this.AhkStdlibWriter.write(data)
    flush() => this.AhkStdlibWriter.flush()

    close()
    {
        if !this.closed {
            try this.AhkStdlibWriter.close()
            try this.AhkStdlibReader.close()
            this.closed := true
        }
        return ""
    }
}

; Return a fresh Buffer holding `count` bytes of `buf` starting at offset.
AhkStdlibIoSliceBuffer(buf, offset, count)
{
    out := Buffer(count)
    if count > 0
        DllCall("RtlMoveMemory", "Ptr", out.Ptr, "Ptr", buf.Ptr + offset, "UPtr", count)
    return out
}

; Concatenate an array of Buffers into one.
AhkStdlibIoConcatBuffers(parts)
{
    total := 0
    for part in parts
        total += part.Size
    out := Buffer(total)
    pos := 0
    for part in parts {
        if part.Size > 0 {
            DllCall("RtlMoveMemory", "Ptr", out.Ptr + pos, "Ptr", part.Ptr, "UPtr", part.Size)
            pos += part.Size
        }
    }
    return out
}

#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibIo
{
    static SEEK_SET := 0
    static SEEK_CUR := 1
    static SEEK_END := 2

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

stdlib.io := AhkStdlibIo

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

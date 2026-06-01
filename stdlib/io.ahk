#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibIo
{
    static SEEK_SET := 0
    static SEEK_CUR := 1
    static SEEK_END := 2

    static StringIO(initial_value := unset)
    {
        if !IsSet(initial_value) || AhkStdlibIsNone(initial_value)
            return AhkStdlibIoStringIO("")
        if !(initial_value is String)
            throw TypeError("initial_value must be str or None, not " AhkStdlibIoPythonTypeName(initial_value), -1)
        return AhkStdlibIoStringIO(initial_value)
    }
}

class AhkStdlibIoStringIO
{
    __New(text := "")
    {
        this.AhkStdlibBuffer := text
        this.AhkStdlibPosition := 0
        this.closed := false
    }

    getvalue()
    {
        this.AhkStdlibEnsureOpen()
        return this.AhkStdlibBuffer
    }

    read(size := -1)
    {
        this.AhkStdlibEnsureOpen()
        if !(size is Integer)
            throw TypeError("integer argument expected, got " AhkStdlibIoPythonTypeName(size), -1)

        length := StrLen(this.AhkStdlibBuffer)
        if size < 0
            size := length - this.AhkStdlibPosition
        if size <= 0
            return ""

        start := this.AhkStdlibPosition + 1
        text := SubStr(this.AhkStdlibBuffer, start, size)
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

        remaining := SubStr(this.AhkStdlibBuffer, this.AhkStdlibPosition + 1)
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

        padCount := this.AhkStdlibPosition - StrLen(this.AhkStdlibBuffer)
        if padCount > 0
            this.AhkStdlibBuffer .= AhkStdlibIoRepeatChar(Chr(0), padCount)

        before := SubStr(this.AhkStdlibBuffer, 1, this.AhkStdlibPosition)
        afterStart := this.AhkStdlibPosition + StrLen(text) + 1
        after := SubStr(this.AhkStdlibBuffer, afterStart)
        this.AhkStdlibBuffer := before text after
        this.AhkStdlibPosition += StrLen(text)
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
                this.AhkStdlibPosition := StrLen(this.AhkStdlibBuffer)
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

        current := StrLen(this.AhkStdlibBuffer)
        if target < current
            this.AhkStdlibBuffer := SubStr(this.AhkStdlibBuffer, 1, target)
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

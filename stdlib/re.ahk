#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibRe
{
    static ASCII := 256
    static A := 256
    static IGNORECASE := 2
    static I := 2
    static MULTILINE := 8
    static M := 8
    static DOTALL := 16
    static S := 16
    static VERBOSE := 64
    static X := 64

    static compile(pattern, flags := 0)
    {
        return AhkStdlibRePattern(pattern, flags)
    }

    static search(pattern, string, flags := 0)
    {
        return this.compile(pattern, flags).search(string)
    }

    static match(pattern, string, flags := 0)
    {
        return this.compile(pattern, flags).match(string)
    }

    static fullmatch(pattern, string, flags := 0)
    {
        return this.compile(pattern, flags).fullmatch(string)
    }

    static findall(pattern, string, flags := 0)
    {
        return this.compile(pattern, flags).findall(string)
    }

    static sub(pattern, repl, string, count := 0, flags := 0)
    {
        return this.compile(pattern, flags).sub(repl, string, count)
    }
}

class AhkStdlibRePattern
{
    __New(pattern, flags := 0)
    {
        this.pattern := pattern
        this.flags := flags
        this.Needle := AhkStdlibReBuildNeedle(pattern, flags)
    }

    search(string)
    {
        return AhkStdlibReSearch(this, string, 1)
    }

    match(string)
    {
        found := RegExMatch(string, this.Needle, &raw, 1)
        if !found || found != 1
            return ""
        return AhkStdlibReMatch(this, string, raw)
    }

    fullmatch(string)
    {
        found := RegExMatch(string, this.Needle, &raw, 1)
        if !found || found != 1
            return ""
        if raw.Len[0] != StrLen(string)
            return ""
        return AhkStdlibReMatch(this, string, raw)
    }

    findall(string)
    {
        result := []
        startPos := 1
        textLength := StrLen(string)

        loop {
            found := RegExMatch(string, this.Needle, &raw, startPos)
            if !found
                break

            if raw.Count = 0 {
                result.Push(raw[0])
            } else if raw.Count = 1 {
                result.Push(raw[1])
            } else {
                groups := []
                Loop raw.Count
                    groups.Push(raw[A_Index])
                result.Push(groups)
            }

            nextPos := raw.Pos[0] + raw.Len[0]
            if raw.Len[0] = 0
                nextPos += 1
            startPos := nextPos
            if startPos > textLength + 1
                break
        }

        return result
    }

    sub(repl, string, count := 0)
    {
        limit := count = 0 ? -1 : count
        return RegExReplace(string, this.Needle, AhkStdlibReTranslateReplacement(repl), , limit)
    }
}

class AhkStdlibReMatch
{
    __New(pattern, string, raw)
    {
        this.re := pattern
        this.string := string
        this.Raw := raw
        this.lastindex := raw.Count > 0 ? raw.Count : ""
        this.lastgroup := AhkStdlibReLastGroupName(raw)
    }

    group(group := 0, groups*)
    {
        if groups.Length = 0
            return this.Raw[group]

        result := [this.Raw[group]]
        for nextGroup in groups
            result.Push(this.Raw[nextGroup])
        return result
    }

    groups(default := unset)
    {
        result := []
        Loop this.Raw.Count {
            value := this.Raw[A_Index]
            if value = "" && this.Raw.Pos[A_Index] = 0 && IsSet(default)
                value := default
            result.Push(value)
        }
        return result
    }

    groupdict(default := unset)
    {
        result := Map()
        Loop this.Raw.Count {
            name := this.Raw.Name[A_Index]
            if name = ""
                continue
            value := this.Raw[A_Index]
            if value = "" && this.Raw.Pos[A_Index] = 0 && IsSet(default)
                value := default
            result[name] := value
        }
        return result
    }

    start(group := 0)
    {
        position := this.Raw.Pos[group]
        if position = 0
            return -1
        return position - 1
    }

    end(group := 0)
    {
        start := this.start(group)
        if start = -1
            return -1
        return start + this.Raw.Len[group]
    }

    span(group := 0)
    {
        return [this.start(group), this.end(group)]
    }
}

stdlib.re := AhkStdlibRe

AhkStdlibReSearch(pattern, string, startPos := 1)
{
    found := RegExMatch(string, pattern.Needle, &raw, startPos)
    if !found
        return ""
    return AhkStdlibReMatch(pattern, string, raw)
}

AhkStdlibReBuildNeedle(pattern, flags := 0)
{
    options := ""
    if flags & AhkStdlibRe.IGNORECASE
        options .= "i"
    if flags & AhkStdlibRe.MULTILINE
        options .= "m"
    if flags & AhkStdlibRe.DOTALL
        options .= "s"
    if flags & AhkStdlibRe.VERBOSE
        options .= "x"

    prefix := options = "" ? ")" : options ")"
    if !(flags & AhkStdlibRe.ASCII)
        prefix .= "(*UCP)"
    return prefix pattern
}

AhkStdlibReTranslateReplacement(repl)
{
    output := ""
    index := 1
    length := StrLen(repl)

    while index <= length {
        char := SubStr(repl, index, 1)
        if char != "\" {
            output .= char
            index += 1
            continue
        }

        if index = length {
            output .= "\"
            index += 1
            continue
        }

        nextChar := SubStr(repl, index + 1, 1)
        if AhkStdlibReIsDigit(nextChar) {
            digits := nextChar
            index += 2
            while index <= length {
                maybeDigit := SubStr(repl, index, 1)
                if !AhkStdlibReIsDigit(maybeDigit)
                    break
                digits .= maybeDigit
                index += 1
            }
            output .= "$" digits
            continue
        }

        if nextChar = "g" && SubStr(repl, index + 2, 1) = "<" {
            closePos := InStr(repl, ">", , index + 3)
            if closePos {
                name := SubStr(repl, index + 3, closePos - index - 3)
                output .= "${" name "}"
                index := closePos + 1
                continue
            }
        }

        if nextChar = "\" {
            output .= "\"
            index += 2
            continue
        }

        output .= "\" nextChar
        index += 2
    }

    return output
}

AhkStdlibReIsDigit(value)
{
    return value != "" && InStr("0123456789", value) != 0
}

AhkStdlibReLastGroupName(raw)
{
    Loop raw.Count {
        index := raw.Count - A_Index + 1
        if raw.Pos[index] != 0 {
            name := raw.Name[index]
            if name != ""
                return name
            return ""
        }
    }
    return ""
}

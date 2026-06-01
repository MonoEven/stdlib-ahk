#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTextComParser
{
    static load(path, encoding := "UTF-8", itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return this.loads(FileRead(path, encoding), itemDelimiter, keyValueDelimiter)
    }

    static loads(text, itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return com_parse(text, itemDelimiter, keyValueDelimiter)
    }

    static dump(values, path, encoding := "UTF-8", itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        text := this.dumps(values, itemDelimiter, keyValueDelimiter)
        if FileExist(path)
            FileDelete path
        FileAppend text, path, encoding
        return text
    }

    static dumps(values, itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return com_dumps(values, itemDelimiter, keyValueDelimiter)
    }
}

com_parse(text, itemDelimiter := "`n", keyValueDelimiter := "=")
{
    com_validate_delimiters(itemDelimiter, keyValueDelimiter)

    if itemDelimiter = "`n"
        text := StrReplace(StrReplace(text, "`r`n", "`n"), "`r", "`n")

    values := Map()
    for item in StrSplit(text, itemDelimiter) {
        line := Trim(item)
        if line = "" || SubStr(line, 1, 1) = "#"
            continue

        delimiterPos := InStr(line, keyValueDelimiter)
        if !delimiterPos
            throw ValueError("key-value item is missing delimiter", -1, line)

        key := Trim(SubStr(line, 1, delimiterPos - 1))
        value := Trim(SubStr(line, delimiterPos + StrLen(keyValueDelimiter)))
        if key = ""
            throw ValueError("key must not be empty", -1, line)

        values[key] := value
    }
    return values
}

com_dumps(values, itemDelimiter := "`n", keyValueDelimiter := "=")
{
    com_validate_delimiters(itemDelimiter, keyValueDelimiter)

    if !(values is Map)
        throw TypeError("values must be a Map", -1, values)

    pairs := []
    for key, value in values {
        keyText := "" key
        if keyText = ""
            throw ValueError("key must not be empty", -1, keyText)
        if InStr(keyText, itemDelimiter) || InStr(keyText, keyValueDelimiter)
            throw ValueError("key must not contain delimiters", -1, keyText)
        pairs.Push({ Key: keyText, Value: "" value })
    }

    com_sort_pairs_by_key(pairs)

    lines := []
    for pair in pairs
        lines.Push(pair.Key keyValueDelimiter pair.Value)
    return com_join(lines, itemDelimiter)
}

com_validate_delimiters(itemDelimiter, keyValueDelimiter)
{
    if itemDelimiter = ""
        throw ValueError("itemDelimiter must not be empty", -1)
    if keyValueDelimiter = ""
        throw ValueError("keyValueDelimiter must not be empty", -1)
}

com_sort_pairs_by_key(pairs)
{
    index := 2
    while index <= pairs.Length {
        current := pairs[index]
        scan := index - 1
        while scan >= 1 && StrCompare(pairs[scan].Key, current.Key, true) > 0 {
            pairs[scan + 1] := pairs[scan]
            scan -= 1
        }
        pairs[scan + 1] := current
        index += 1
    }
}

com_join(values, delimiter)
{
    text := ""
    first := true
    for value in values {
        if first
            first := false
        else
            text .= delimiter
        text .= value
    }
    return text
}

class comParser
{
    static Parse(text, itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return com_parse(text, itemDelimiter, keyValueDelimiter)
    }

    static Loads(text, itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return com_parse(text, itemDelimiter, keyValueDelimiter)
    }

    static Dumps(values, itemDelimiter := "`n", keyValueDelimiter := "=")
    {
        return com_dumps(values, itemDelimiter, keyValueDelimiter)
    }
}

stdlib.comparser := AhkStdlibTextComParser

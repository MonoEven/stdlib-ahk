#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTextToml
{
    static load(path, encoding := "UTF-8")
    {
        return toml_load(path, encoding)
    }

    static loads(text)
    {
        return toml_loads(text)
    }

    static dump(value, path, encoding := "UTF-8")
    {
        return toml_dump(value, path, encoding)
    }

    static dumps(value)
    {
        return toml_dumps(value)
    }

    static Toml(defaults?)
    {
        return IsSet(defaults) ? Toml(defaults) : Toml()
    }

    static document(defaults?)
    {
        return this.Toml(defaults?)
    }
}

stdlib.toml := AhkStdlibTextToml

toml_load(path, encoding := "UTF-8")
{
    return toml_loads(FileRead(path, encoding))
}

toml_loads(text)
{
    return _TomlParser(text).Parse()
}

toml_dump(value, path, encoding := "UTF-8")
{
    text := toml_dumps(value)
    if FileExist(path)
        FileDelete path
    FileAppend text, path, encoding
    return text
}

toml_dumps(value)
{
    return _TomlWriter(value).Write()
}

class Toml
{
    __New(defaults?)
    {
        this.values := Map()
        if IsSet(defaults)
            this.values := _Toml_ToMap(defaults)
    }

    read(source := "", type := "text", encoding := "UTF-8")
    {
        if source is Toml {
            parsed := _Toml_Clone(source.values)
        } else if type = "file" {
            parsed := toml_load(source, encoding)
        } else if source is Object && HasMethod(source, "Read") {
            parsed := toml_loads(source.Read())
        } else {
            parsed := toml_loads(source)
        }

        this.values := _Toml_Merge(this.values, parsed)
        return this
    }

    toMap()
    {
        return _Toml_Clone(this.values)
    }

    isEmpty()
    {
        return this.values.Count = 0
    }

    contains(path)
    {
        return this._HasPath(path)
    }

    containsPrimitive(path)
    {
        if !this._HasPath(path)
            return false
        value := this._GetPath(path)
        return !(value is Map) && !(value is Array)
    }

    containsTable(path)
    {
        if !this._HasPath(path)
            return false
        return this._GetPath(path) is Map
    }

    containsTableArray(path)
    {
        if !this._HasPath(path)
            return false
        value := this._GetPath(path)
        if !(value is Array) || value.Length = 0
            return false
        return value[1] is Map
    }

    get(path, default?)
    {
        if this._HasPath(path)
            return this._GetPath(path)
        if IsSet(default)
            return default
        return ""
    }

    getString(path, default?)
    {
        value := IsSet(default) ? this.get(path, default) : this.get(path)
        if value = ""
            return value
        return value ""
    }

    getLong(path, default?)
    {
        value := IsSet(default) ? this.get(path, default) : this.get(path)
        if value = ""
            return value
        return Integer(value)
    }

    getDouble(path, default?)
    {
        value := IsSet(default) ? this.get(path, default) : this.get(path)
        if value = ""
            return value
        return Float(value)
    }

    getBoolean(path, default?)
    {
        value := IsSet(default) ? this.get(path, default) : this.get(path)
        if value = ""
            return value
        return value ? true : false
    }

    getList(path, default?)
    {
        return IsSet(default) ? this.get(path, default) : this.get(path)
    }

    getTable(path)
    {
        value := this.get(path)
        if value is Toml
            return value
        if value is Map
            return Toml(value)
        return Toml()
    }

    getTables(path)
    {
        values := this.get(path, [])
        tables := []
        if values is Array {
            for value in values {
                if value is Map
                    tables.Push(Toml(value))
            }
        }
        return tables
    }

    _HasPath(path)
    {
        current := this.values
        for token in _Toml_PathTokens(path) {
            if current is Map {
                if !current.Has(token)
                    return false
                current := current[token]
            } else if current is Array {
                index := Integer(token) + 1
                if index < 1 || index > current.Length
                    return false
                current := current[index]
            } else {
                return false
            }
        }
        return true
    }

    _GetPath(path)
    {
        current := this.values
        for token in _Toml_PathTokens(path) {
            if current is Map {
                current := current[token]
            } else if current is Array {
                current := current[Integer(token) + 1]
            } else {
                throw ValueError("TOML path not found: " path, -1)
            }
        }
        return current
    }
}

class _TomlParser
{
    __New(text)
    {
        this.Text := text
        this.Root := Map()
        this.Current := this.Root
    }

    Parse()
    {
        lines := StrSplit(this.Text, "`n", "`r")
        i := 1
        while i <= lines.Length {
            rawLine := lines[i]
            lineNumber := i

            ; A key/value whose value opens a multiline string (""" or ''')
            ; may span several physical lines; buffer until it closes.
            joined := _Toml_MaybeJoinMultiline(lines, &i)
            if joined != "" {
                this.ParseKeyValue(joined, lineNumber)
                i += 1
                continue
            }

            line := Trim(_Toml_StripComment(rawLine))
            if line = "" {
                i += 1
                continue
            }

            if SubStr(line, 1, 2) = "[[" {
                this.ParseTableArray(line, lineNumber)
            } else if SubStr(line, 1, 1) = "[" {
                this.ParseTable(line, lineNumber)
            } else {
                this.ParseKeyValue(line, lineNumber)
            }
            i += 1
        }
        return this.Root
    }

    ParseTable(line, lineNumber)
    {
        if SubStr(line, -1) != "]"
            this.Fail(lineNumber, "unterminated table header")
        name := Trim(SubStr(line, 2, StrLen(line) - 2))
        if name = ""
            this.Fail(lineNumber, "empty table name")
        this.Current := this.EnsurePath(_Toml_KeyParts(name), lineNumber)
    }

    ParseTableArray(line, lineNumber)
    {
        if SubStr(line, -2) != "]]"
            this.Fail(lineNumber, "unterminated table array header")
        name := Trim(SubStr(line, 3, StrLen(line) - 4))
        if name = ""
            this.Fail(lineNumber, "empty table array name")

        parentParts := _Toml_KeyParts(name)
        key := parentParts.Pop()
        parent := this.EnsurePath(parentParts, lineNumber)
        if parent.Has(key) {
            if !(parent[key] is Array)
                this.Fail(lineNumber, "key already exists as non-array: " key)
        } else {
            parent[key] := []
        }

        table := Map()
        parent[key].Push(table)
        this.Current := table
    }

    ParseKeyValue(line, lineNumber)
    {
        equalsPos := _Toml_FindUnquoted(line, "=")
        if equalsPos = 0
            this.Fail(lineNumber, "expected '='")

        keyText := Trim(SubStr(line, 1, equalsPos - 1))
        valueText := Trim(SubStr(line, equalsPos + 1))
        if keyText = ""
            this.Fail(lineNumber, "empty key")
        if valueText = ""
            this.Fail(lineNumber, "missing value for key " keyText)

        parts := _Toml_KeyParts(keyText)
        key := parts.Pop()
        target := parts.Length ? this.EnsurePath(parts, lineNumber, this.Current) : this.Current
        if target.Has(key)
            this.Fail(lineNumber, "duplicate key: " keyText)
        target[key] := _Toml_ParseValue(valueText, lineNumber)
    }

    EnsurePath(parts, lineNumber, start?)
    {
        current := IsSet(start) ? start : this.Root
        for part in parts {
            if part = ""
                this.Fail(lineNumber, "empty dotted key segment")
            if current.Has(part) {
                if !(current[part] is Map)
                    this.Fail(lineNumber, "key already exists as non-table: " part)
            } else {
                current[part] := Map()
            }
            current := current[part]
        }
        return current
    }

    Fail(lineNumber, message)
    {
        throw ValueError("TOML parse error on line " lineNumber ": " message, -1)
    }
}

class _TomlWriter
{
    __New(value)
    {
        this.Value := _Toml_ToMap(value)
    }

    Write()
    {
        lines := []
        this.WriteMap(this.Value, lines)
        return _Toml_Join(lines, "`n")
    }

    WriteMap(values, lines, prefix := "")
    {
        nested := []
        for key, value in values {
            if value is Map {
                nested.Push([key, value])
            } else {
                lines.Push(key " = " _Toml_FormatValue(value))
            }
        }

        for item in nested {
            if lines.Length
                lines.Push("")
            section := prefix = "" ? item[1] : prefix "." item[1]
            lines.Push("[" section "]")
            this.WriteMap(item[2], lines, section)
        }
    }
}

_Toml_ParseValue(text, lineNumber := 0)
{
    text := Trim(text)
    if text = ""
        _Toml_FailValue(lineNumber, "empty value")

    ; Multiline strings: """...""" (basic) and '''...''' (literal). A leading
    ; newline immediately after the opening delimiter is trimmed (TOML spec).
    if SubStr(text, 1, 3) = "`"`"`"" {
        if SubStr(text, -3) != "`"`"`"" || StrLen(text) < 6
            _Toml_FailValue(lineNumber, "unterminated multiline string")
        body := SubStr(text, 4, StrLen(text) - 6)
        body := _Toml_TrimLeadingNewline(body)
        return _Toml_UnquoteBasic(body, lineNumber)
    }
    if SubStr(text, 1, 3) = "'''" {
        if SubStr(text, -3) != "'''" || StrLen(text) < 6
            _Toml_FailValue(lineNumber, "unterminated multiline literal string")
        body := SubStr(text, 4, StrLen(text) - 6)
        return _Toml_TrimLeadingNewline(body)
    }

    first := SubStr(text, 1, 1)
    last := SubStr(text, -1)

    if first = "`"" {
        if last != "`"" || StrLen(text) = 1
            _Toml_FailValue(lineNumber, "unterminated string")
        return _Toml_UnquoteBasic(SubStr(text, 2, StrLen(text) - 2), lineNumber)
    }

    if first = "'" {
        if last != "'" || StrLen(text) = 1
            _Toml_FailValue(lineNumber, "unterminated literal string")
        return SubStr(text, 2, StrLen(text) - 2)
    }

    if first = "[" {
        if last != "]"
            _Toml_FailValue(lineNumber, "unterminated array")
        return _Toml_ParseArray(SubStr(text, 2, StrLen(text) - 2), lineNumber)
    }

    if first = "{" {
        if last != "}"
            _Toml_FailValue(lineNumber, "unterminated inline table")
        return _Toml_ParseInlineTable(SubStr(text, 2, StrLen(text) - 2), lineNumber)
    }

    lowered := StrLower(text)
    if lowered = "true"
        return true
    if lowered = "false"
        return false

    ; inf / nan floats (TOML spec + the reference `toml` package). AHK has no
    ; inf/nan literal, but a Double materialised from the IEEE-754 bit pattern
    ; behaves and stringifies ("inf"/"-inf"/"nan") exactly as CPython's toml.
    if lowered = "inf" || lowered = "+inf"
        return _Toml_Inf(false)
    if lowered = "-inf"
        return _Toml_Inf(true)
    if lowered = "nan" || lowered = "+nan" || lowered = "-nan"
        return _Toml_Nan()

    numberText := StrReplace(text, "_", "")
    if RegExMatch(numberText, "^[+-]?\d+$")
        return Integer(numberText)
    if RegExMatch(numberText, "^[+-]?(\d+\.\d*|\d*\.\d+)([eE][+-]?\d+)?$") || RegExMatch(numberText, "^[+-]?\d+[eE][+-]?\d+$")
        return Float(numberText)
    if RegExMatch(text, "^\d{4}-\d{2}-\d{2}")
        return text

    _Toml_FailValue(lineNumber, "unsupported value: " text)
}

; Materialise +/-infinity from its IEEE-754 double bit pattern.
_Toml_Inf(negative)
{
    bits := negative ? 0xFFF0000000000000 : 0x7FF0000000000000
    b := Buffer(8, 0)
    NumPut("Int64", bits, b, 0)
    return NumGet(b, 0, "Double")
}

; Materialise a quiet NaN double.
_Toml_Nan()
{
    b := Buffer(8, 0)
    NumPut("Int64", 0x7FF8000000000000, b, 0)
    return NumGet(b, 0, "Double")
}

_Toml_ParseArray(text, lineNumber)
{
    values := []
    for item in _Toml_SplitTopLevel(text, ",") {
        item := Trim(item)
        if item = ""
            continue
        values.Push(_Toml_ParseValue(item, lineNumber))
    }
    return values
}

; Inline table: { key = value, key2 = value2 }  ->  Map. Dotted keys allowed.
_Toml_ParseInlineTable(text, lineNumber)
{
    table := Map()
    for entry in _Toml_SplitTopLevel(text, ",") {
        entry := Trim(entry)
        if entry = ""
            continue
        equalsPos := _Toml_FindUnquoted(entry, "=")
        if equalsPos = 0
            _Toml_FailValue(lineNumber, "expected '=' in inline table")
        keyText := Trim(SubStr(entry, 1, equalsPos - 1))
        valueText := Trim(SubStr(entry, equalsPos + 1))
        if keyText = ""
            _Toml_FailValue(lineNumber, "empty key in inline table")
        if valueText = ""
            _Toml_FailValue(lineNumber, "missing value in inline table for key " keyText)

        parts := _Toml_KeyParts(keyText)
        leaf := parts.Pop()
        target := table
        for part in parts {
            if !target.Has(part)
                target[part] := Map()
            else if !(target[part] is Map)
                _Toml_FailValue(lineNumber, "inline table key conflict: " part)
            target := target[part]
        }
        if target.Has(leaf)
            _Toml_FailValue(lineNumber, "duplicate key in inline table: " keyText)
        target[leaf] := _Toml_ParseValue(valueText, lineNumber)
    }
    return table
}

; If lines[i] is a `key = """` / `key = '''` whose multiline string does not
; close on the same physical line, consume continuation lines (joined with
; "`n") through the closing delimiter and return the joined statement. Advances
; &i to the last consumed line. Returns "" when no multiline join applies.
_Toml_MaybeJoinMultiline(lines, &i)
{
    raw := lines[i]
    eqPos := _Toml_FindUnquoted(raw, "=")
    if eqPos = 0
        return ""
    valuePart := Trim(SubStr(raw, eqPos + 1))
    opener := ""
    if SubStr(valuePart, 1, 3) = "`"`"`""
        opener := "`"`"`""
    else if SubStr(valuePart, 1, 3) = "'''"
        opener := "'''"
    else
        return ""

    ; Already closed on the same line (and longer than just the opener)?
    rest := SubStr(valuePart, 4)
    if StrLen(valuePart) >= 6 && InStr(rest, opener)
        return ""

    buffer := raw
    j := i + 1
    while j <= lines.Length {
        buffer .= "`n" lines[j]
        if InStr(lines[j], opener) {
            i := j
            return buffer
        }
        j += 1
    }
    ; Unterminated; let ParseKeyValue surface the error on the original line.
    i := lines.Length
    return buffer
}

; Trim a single leading newline (CR/LF or LF) right after an opening """/'''.
_Toml_TrimLeadingNewline(text)
{
    if SubStr(text, 1, 2) = "`r`n"
        return SubStr(text, 3)
    if SubStr(text, 1, 1) = "`n"
        return SubStr(text, 2)
    return text
}

_Toml_FormatValue(value)
{
    if value is Array {
        parts := []
        for item in value
            parts.Push(_Toml_FormatValue(item))
        return "[" _Toml_Join(parts, ", ") "]"
    }

    valueType := Type(value)
    switch valueType {
        case "String":
            return _Toml_Quote(value)
        case "Integer":
            return (value = true ? "true" : value = false ? "false" : value "")
        case "Float":
            return value ""
        default:
            throw TypeError("cannot TOML serialize value of type " valueType, -1)
    }
}

_Toml_Quote(text)
{
    result := "`""
    Loop Parse, text {
        ch := A_LoopField
        switch ch {
            case "`"":
                result .= "\`""
            case "\":
                result .= "\\"
            case "`n":
                result .= "\n"
            case "`r":
                result .= "\r"
            case "`t":
                result .= "\t"
            default:
                result .= ch
        }
    }
    return result "`""
}

_Toml_UnquoteBasic(text, lineNumber)
{
    result := ""
    pos := 1
    length := StrLen(text)
    while pos <= length {
        ch := SubStr(text, pos, 1)
        pos += 1
        if ch != "\" {
            result .= ch
            continue
        }

        if pos > length
            _Toml_FailValue(lineNumber, "unterminated escape sequence")
        esc := SubStr(text, pos, 1)
        pos += 1
        switch esc {
            case "`"":
                result .= "`""
            case "\":
                result .= "\"
            case "b":
                result .= Chr(8)
            case "f":
                result .= Chr(12)
            case "n":
                result .= "`n"
            case "r":
                result .= "`r"
            case "t":
                result .= "`t"
            case "u":
                if pos + 3 > length
                    _Toml_FailValue(lineNumber, "short unicode escape")
                hex := SubStr(text, pos, 4)
                if !RegExMatch(hex, "i)^[0-9a-f]{4}$")
                    _Toml_FailValue(lineNumber, "invalid unicode escape")
                result .= Chr(Integer("0x" hex))
                pos += 4
            default:
                _Toml_FailValue(lineNumber, "invalid escape sequence")
        }
    }
    return result
}

_Toml_StripComment(line)
{
    inString := false
    quote := ""
    escaped := false
    Loop Parse, line {
        ch := A_LoopField
        if inString {
            if quote = "`"" && ch = "\" && !escaped {
                escaped := true
                continue
            }
            if ch = quote && !escaped {
                inString := false
                quote := ""
            }
            escaped := false
            continue
        }

        if ch = "`"" || ch = "'" {
            inString := true
            quote := ch
            escaped := false
            continue
        }

        if ch = "#"
            return SubStr(line, 1, A_Index - 1)
    }
    return line
}

_Toml_FindUnquoted(text, needle)
{
    inString := false
    quote := ""
    escaped := false
    Loop Parse, text {
        ch := A_LoopField
        if inString {
            if quote = "`"" && ch = "\" && !escaped {
                escaped := true
                continue
            }
            if ch = quote && !escaped {
                inString := false
                quote := ""
            }
            escaped := false
            continue
        }

        if ch = "`"" || ch = "'" {
            inString := true
            quote := ch
            escaped := false
            continue
        }

        if ch = needle
            return A_Index
    }
    return 0
}

_Toml_SplitTopLevel(text, delimiter)
{
    values := []
    start := 1
    depth := 0
    inString := false
    quote := ""
    escaped := false

    Loop Parse, text {
        ch := A_LoopField
        if inString {
            if quote = "`"" && ch = "\" && !escaped {
                escaped := true
                continue
            }
            if ch = quote && !escaped {
                inString := false
                quote := ""
            }
            escaped := false
            continue
        }

        if ch = "`"" || ch = "'" {
            inString := true
            quote := ch
            escaped := false
            continue
        }

        if ch = "[" || ch = "{"
            depth += 1
        else if ch = "]" || ch = "}"
            depth -= 1
        else if ch = delimiter && depth = 0 {
            values.Push(SubStr(text, start, A_Index - start))
            start := A_Index + 1
        }
    }

    values.Push(SubStr(text, start))
    return values
}

_Toml_KeyParts(text)
{
    parts := []
    for part in _Toml_SplitTopLevel(text, ".") {
        part := Trim(part)
        if part = ""
            throw ValueError("TOML key contains an empty segment", -1)
        if SubStr(part, 1, 1) = "`"" && SubStr(part, -1) = "`""
            part := _Toml_UnquoteBasic(SubStr(part, 2, StrLen(part) - 2), 0)
        else if SubStr(part, 1, 1) = "'" && SubStr(part, -1) = "'"
            part := SubStr(part, 2, StrLen(part) - 2)
        else if !RegExMatch(part, "^[A-Za-z0-9_-]+$")
            throw ValueError("invalid TOML key segment: " part, -1)
        parts.Push(part)
    }
    return parts
}

_Toml_PathTokens(path)
{
    tokens := []
    for part in StrSplit(path, ".") {
        remaining := part
        while RegExMatch(remaining, "^(.*?)\[(\d+)\](.*)$", &match) {
            if match[1] != ""
                tokens.Push(match[1])
            tokens.Push(match[2])
            remaining := match[3]
        }
        if remaining != ""
            tokens.Push(remaining)
    }
    return tokens
}

_Toml_ToMap(value)
{
    if value is Toml
        return _Toml_Clone(value.values)
    if value is Map
        return _Toml_Clone(value)
    if value is Object {
        result := Map()
        for key, item in value.OwnProps()
            result[key] := item is Map || item is Array ? _Toml_Clone(item) : item
        return result
    }
    throw TypeError("TOML value must be a Map, Object, or Toml", -1)
}

_Toml_Clone(value)
{
    if value is Map {
        result := Map()
        for key, item in value
            result[key] := _Toml_Clone(item)
        return result
    }
    if value is Array {
        result := []
        for item in value
            result.Push(_Toml_Clone(item))
        return result
    }
    return value
}

_Toml_Merge(base, override)
{
    result := _Toml_Clone(base)
    for key, value in override {
        if result.Has(key) && result[key] is Map && value is Map
            result[key] := _Toml_Merge(result[key], value)
        else
            result[key] := _Toml_Clone(value)
    }
    return result
}

_Toml_Join(values, delimiter := "")
{
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

_Toml_FailValue(lineNumber, message)
{
    if lineNumber
        throw ValueError("TOML parse error on line " lineNumber ": " message, -1)
    throw ValueError("TOML parse error: " message, -1)
}

#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTextJson
{
    static Null := AhkStdlibJsonNull()
    static True := stdlib.True
    static False := stdlib.False

    static JSONDecodeError
    {
        get => AhkStdlibJsonDecodeError
    }

    static JSONDecodeError(args*)
    {
        return AhkStdlibJsonDecodeError(args*)
    }

    static JSONEncoder
    {
        get => AhkStdlibJsonEncoder
    }

    static JSONEncoder(options := unset)
    {
        return AhkStdlibJsonEncoder(options?)
    }

    static JSONDecoder
    {
        get => AhkStdlibJsonDecoder
    }

    static JSONDecoder(options := unset)
    {
        return AhkStdlibJsonDecoder(options?)
    }

    static Bool(value)
    {
        return AhkStdlibTruthValue(value) ? this.True : this.False
    }

    static load(path, options := unset, encoding := "UTF-8")
    {
        return AhkStdlibJsonLoads(FileRead(path, encoding), options?)
    }

    static loads(text, options := unset)
    {
        return AhkStdlibJsonLoads(text, options?)
    }

    static dump(value, path, encoding := "UTF-8", options := unset)
    {
        text := AhkStdlibJsonDumps(value, options?)
        if FileExist(path)
            FileDelete path
        FileAppend text, path, encoding
        return text
    }

    static dumps(value, options := unset)
    {
        return AhkStdlibJsonDumps(value, options?)
    }
}

stdlib.json := AhkStdlibTextJson

AhkStdlibJsonNull()
{
    static value := { __AhkStdlibJsonNull: true }
    return value
}

AhkStdlibJsonLoads(text, options := unset)
{
    parseConfig := {
        object_hook: stdlib.None,
        parse_float: stdlib.None,
        parse_int: stdlib.None
    }
    if IsSet(options) && IsObject(options) {
        if HasProp(options, "object_hook") && !AhkStdlibIsNone(options.object_hook)
            parseConfig.object_hook := options.object_hook
        if HasProp(options, "parse_float") && !AhkStdlibIsNone(options.parse_float)
            parseConfig.parse_float := options.parse_float
        if HasProp(options, "parse_int") && !AhkStdlibIsNone(options.parse_int)
            parseConfig.parse_int := options.parse_int
    }
    return AhkStdlibJsonParser(text, parseConfig).Parse()
}

AhkStdlibJsonDumps(value, options := unset)
{
    config := AhkStdlibJsonOptions(options?)
    return AhkStdlibJsonStringify(value, config, 0)
}

AhkStdlibJsonOptions(options := unset)
{
    config := {
        indent: stdlib.None,
        sort_keys: false,
        itemSep: ", ",
        keySep: ": ",
        default: stdlib.None,
        ensure_ascii: true,
        hasSeparators: false
    }
    if !IsSet(options)
        return config
    if !IsObject(options)
        throw TypeError("dumps options must be an object", -1)

    if HasProp(options, "indent") && !AhkStdlibIsNone(options.indent)
        config.indent := options.indent
    if HasProp(options, "sort_keys")
        config.sort_keys := AhkStdlibTruthValue(options.sort_keys)
    if HasProp(options, "default")
        config.default := options.default
    if HasProp(options, "ensure_ascii")
        config.ensure_ascii := AhkStdlibTruthValue(options.ensure_ascii)
    if HasProp(options, "separators") && !AhkStdlibIsNone(options.separators) {
        seps := options.separators
        config.itemSep := seps[1]
        config.keySep := seps[2]
        config.hasSeparators := true
    }
    if !config.hasSeparators && !AhkStdlibIsNone(config.indent)
        config.itemSep := ","
    return config
}

AhkStdlibJsonIndentUnit(indent)
{
    if indent is Integer
        return AhkStdlibJsonRepeat(" ", indent)
    if indent is String
        return indent
    return ""
}

AhkStdlibJsonRepeat(text, count)
{
    result := ""
    loop count
        result .= text
    return result
}

AhkStdlibJsonIsNull(value)
{
    return IsObject(value) && !(value !== AhkStdlibJsonNull())
}

AhkStdlibJsonIsBool(value)
{
    return AhkStdlibIsBool(value)
}

AhkStdlibJsonStringify(value, config, depth)
{
    if AhkStdlibJsonIsNull(value)
        return "null"
    if AhkStdlibJsonIsBool(value)
        return value.Value ? "true" : "false"

    valueType := Type(value)
    switch valueType {
        case "String":
            return AhkStdlibJsonQuote(value, config)
        case "Integer":
            return value ""
        case "Float":
            return value ""
        case "Array":
            return AhkStdlibJsonArrayToString(value, config, depth)
        case "Map":
            return AhkStdlibJsonMapToString(value, config, depth)
        case "Object":
            return AhkStdlibJsonObjectToString(value, config, depth)
        default:
            if !AhkStdlibIsNone(config.default) {
                converted := config.default.Call(value)
                return AhkStdlibJsonStringify(converted, config, depth)
            }
            throw TypeError("cannot JSON serialize value of type " valueType, -1)
    }
}

AhkStdlibJsonArrayToString(values, config, depth)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibJsonStringify(value, config, depth + 1))
    return AhkStdlibJsonWrap(parts, "[", "]", config, depth)
}

AhkStdlibJsonMapToString(values, config, depth)
{
    pairs := []
    for key, value in values
        pairs.Push([key "", value])
    if config.sort_keys
        AhkStdlibJsonSortPairs(pairs)
    parts := []
    for pair in pairs
        parts.Push(AhkStdlibJsonQuote(pair[1], config) config.keySep AhkStdlibJsonStringify(pair[2], config, depth + 1))
    return AhkStdlibJsonWrap(parts, "{", "}", config, depth)
}

AhkStdlibJsonWrap(parts, openChar, closeChar, config, depth)
{
    if parts.Length = 0
        return openChar closeChar
    if AhkStdlibIsNone(config.indent)
        return openChar AhkStdlibJsonJoin(parts, config.itemSep) closeChar

    unit := AhkStdlibJsonIndentUnit(config.indent)
    inner := AhkStdlibJsonRepeat(unit, depth + 1)
    outer := AhkStdlibJsonRepeat(unit, depth)
    separator := RTrim(config.itemSep, " ") "`n" inner
    return openChar "`n" inner AhkStdlibJsonJoin(parts, separator) "`n" outer closeChar
}

AhkStdlibJsonSortPairs(pairs)
{
    loop pairs.Length - 1 {
        outer := A_Index
        loop pairs.Length - outer {
            i := A_Index
            if StrCompare(pairs[i][1], pairs[i + 1][1]) > 0 {
                temp := pairs[i]
                pairs[i] := pairs[i + 1]
                pairs[i + 1] := temp
            }
        }
    }
}

AhkStdlibJsonObjectToString(value, config, depth)
{
    pairs := []
    for key, item in value.OwnProps()
        pairs.Push([key "", item])
    if config.sort_keys
        AhkStdlibJsonSortPairs(pairs)
    parts := []
    for pair in pairs
        parts.Push(AhkStdlibJsonQuote(pair[1]) config.keySep AhkStdlibJsonStringify(pair[2], config, depth + 1))
    return AhkStdlibJsonWrap(parts, "{", "}", config, depth)
}

AhkStdlibJsonQuote(text, config := unset)
{
    ; ensure_ascii defaults to true (Python's default): escape all non-ASCII.
    ensureAscii := true
    if IsSet(config) && IsObject(config) && HasProp(config, "ensure_ascii")
        ensureAscii := config.ensure_ascii
    result := "`""
    Loop Parse, text {
        ch := A_LoopField
        code := Ord(ch)
        switch ch {
            case "`"":
                result .= "\" . "`""
            case "\":
                result .= "\\"
            case "`b":
                result .= "\b"
            case "`f":
                result .= "\f"
            case "`n":
                result .= "\n"
            case "`r":
                result .= "\r"
            case "`t":
                result .= "\t"
            default:
                if code < 32
                    result .= AhkStdlibJsonUnicodeEscape(code)
                else if code > 127 && ensureAscii
                    result .= AhkStdlibJsonUnicodeEscape(code)
                else
                    result .= ch
        }
    }
    return result . "`""
}

AhkStdlibJsonUnicodeEscape(code)
{
    if code <= 0xFFFF
        return Format("\u{:04x}", code)

    code -= 0x10000
    high := 0xD800 + (code // 0x400)
    low := 0xDC00 + Mod(code, 0x400)
    return Format("\u{:04x}\u{:04x}", high, low)
}

AhkStdlibJsonJoin(values, delimiter := "")
{
    return AhkStdlibJoinWith(values, delimiter)
}

class AhkStdlibJsonParser
{
    __New(text, config := unset)
    {
        this.Text := text
        this.Pos := 1
        this.Length := StrLen(text)
        this.ObjectHook := IsSet(config) ? config.object_hook : stdlib.None
        this.ParseFloat := IsSet(config) ? config.parse_float : stdlib.None
        this.ParseInt := IsSet(config) ? config.parse_int : stdlib.None
    }

    Parse()
    {
        value := this.ParseValue()
        this.SkipWhitespace()
        if this.Pos <= this.Length
            this.Fail("extra data")
        return value
    }

    ParseValue()
    {
        this.SkipWhitespace()
        ch := this.Peek()
        if ch = ""
            this.Fail("unexpected end of input")

        if ch = "{"
            return this.ParseObject()
        if ch = "["
            return this.ParseArray()
        if ch = "`""
            return this.ParseString()
        if ch = "t" {
            this.ExpectLiteral("true")
            return stdlib.True
        }
        if ch = "f" {
            this.ExpectLiteral("false")
            return stdlib.False
        }
        if ch = "n" {
            this.ExpectLiteral("null")
            return AhkStdlibJsonNull()
        }
        if ch = "-" || this.IsDigit(ch)
            return this.ParseNumber()

        this.Fail("unexpected character '" ch "'")
    }

    ParseObject()
    {
        result := Map()
        this.ExpectChar("{")
        this.SkipWhitespace()
        if this.MatchChar("}")
            return this.ApplyObjectHook(result)

        loop {
            this.SkipWhitespace()
            if this.Peek() != "`""
                this.Fail("object keys must be strings")
            key := this.ParseString()

            this.SkipWhitespace()
            this.ExpectChar(":")
            result[key] := this.ParseValue()

            this.SkipWhitespace()
            if this.MatchChar("}")
                return this.ApplyObjectHook(result)
            this.ExpectChar(",")
        }
    }

    ApplyObjectHook(result)
    {
        if AhkStdlibIsNone(this.ObjectHook)
            return result
        return this.ObjectHook.Call(result)
    }

    ParseArray()
    {
        result := []
        this.ExpectChar("[")
        this.SkipWhitespace()
        if this.MatchChar("]")
            return result

        loop {
            result.Push(this.ParseValue())
            this.SkipWhitespace()
            if this.MatchChar("]")
                return result
            this.ExpectChar(",")
        }
    }

    ParseString()
    {
        this.ExpectChar("`"")
        result := ""

        while this.Pos <= this.Length {
            ch := this.ReadChar()
            if ch = "`""
                return result

            if ch = "\" {
                if this.Pos > this.Length
                    this.Fail("unterminated escape sequence")
                esc := this.ReadChar()
                switch esc {
                    case "`"":
                        result .= "`""
                    case "\":
                        result .= "\"
                    case "/":
                        result .= "/"
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
                        result .= this.ParseUnicodeEscape()
                    default:
                        this.Fail("invalid escape sequence")
                }
            } else {
                if Ord(ch) < 32
                    this.Fail("control character in string")
                result .= ch
            }
        }

        this.Fail("unterminated string")
    }

    ParseUnicodeEscape()
    {
        if this.Pos + 3 > this.Length
            this.Fail("short unicode escape")

        hex := SubStr(this.Text, this.Pos, 4)
        if !RegExMatch(hex, "i)^[0-9a-f]{4}$")
            this.Fail("invalid unicode escape")
        this.Pos += 4
        return Chr(Integer("0x" hex))
    }

    ParseNumber()
    {
        start := this.Pos
        if this.Peek() = "-"
            this.Pos += 1

        if !this.IsDigit(this.Peek())
            this.Fail("invalid number")

        if this.Peek() = "0" {
            this.Pos += 1
        } else {
            while this.IsDigit(this.Peek())
                this.Pos += 1
        }

        isFloat := false
        if this.Peek() = "." {
            isFloat := true
            this.Pos += 1
            if !this.IsDigit(this.Peek())
                this.Fail("invalid number")
            while this.IsDigit(this.Peek())
                this.Pos += 1
        }

        ch := this.Peek()
        if ch = "e" || ch = "E" {
            isFloat := true
            this.Pos += 1
            ch := this.Peek()
            if ch = "+" || ch = "-"
                this.Pos += 1
            if !this.IsDigit(this.Peek())
                this.Fail("invalid number")
            while this.IsDigit(this.Peek())
                this.Pos += 1
        }

        token := SubStr(this.Text, start, this.Pos - start)
        if isFloat {
            if !AhkStdlibIsNone(this.ParseFloat)
                return this.ParseFloat.Call(token)
            return Float(token)
        }
        if !AhkStdlibIsNone(this.ParseInt)
            return this.ParseInt.Call(token)
        return Integer(token)
    }

    ExpectLiteral(literal)
    {
        if SubStr(this.Text, this.Pos, StrLen(literal)) != literal
            this.Fail("expected '" literal "'")
        this.Pos += StrLen(literal)
    }

    ExpectChar(expected)
    {
        actual := this.ReadChar()
        if actual != expected
            this.Fail("expected '" expected "'")
    }

    MatchChar(expected)
    {
        if this.Peek() != expected
            return false
        this.Pos += 1
        return true
    }

    ReadChar()
    {
        if this.Pos > this.Length
            this.Fail("unexpected end of input")
        ch := SubStr(this.Text, this.Pos, 1)
        this.Pos += 1
        return ch
    }

    Peek()
    {
        if this.Pos > this.Length
            return ""
        return SubStr(this.Text, this.Pos, 1)
    }

    SkipWhitespace()
    {
        while this.Pos <= this.Length {
            ch := this.Peek()
            if ch != " " && ch != "`t" && ch != "`r" && ch != "`n"
                return
            this.Pos += 1
        }
    }

    IsDigit(ch)
    {
        if ch = ""
            return false
        code := Ord(ch)
        return code >= 48 && code <= 57
    }

    Fail(message)
    {
        lineno := 1
        colno := 1
        i := 1
        charIndex := this.Pos - 1
        while i <= charIndex && i <= this.Length {
            if SubStr(this.Text, i, 1) = "`n" {
                lineno += 1
                colno := 1
            } else {
                colno += 1
            }
            i += 1
        }
        detail := message ": line " lineno " column " colno " (char " charIndex ")"
        err := AhkStdlibJsonDecodeError(detail)
        err.msg := message
        err.pos := charIndex
        err.lineno := lineno
        err.colno := colno
        throw err
    }
}

class AhkStdlibJsonDecodeError extends ValueError
{
}

; CPython JSONEncoder: holds dump options (indent/sort_keys/ensure_ascii/...)
; and exposes encode(value) / iterencode(value) / default(obj). Subclassing for
; custom serialization works by overriding default; here AHK lets the caller
; pass options.default = a Func, which AhkStdlibJsonStringify already honors.
class AhkStdlibJsonEncoder
{
    __New(options := unset)
    {
        this._config := AhkStdlibJsonOptions(options?)
        this.indent := IsSet(options) && IsObject(options) && HasProp(options, "indent") && !AhkStdlibIsNone(options.indent) ? options.indent : stdlib.None
        this.sort_keys := this._config.sort_keys
        this.ensure_ascii := this._config.ensure_ascii
        this.item_separator := this._config.itemSep
        this.key_separator := this._config.keySep
    }

    encode(value)
    {
        return AhkStdlibJsonStringify(value, this._config, 0)
    }

    iterencode(value)
    {
        ; Python's iterencode yields chunks; AHK has no generators, so emit the
        ; whole encoded string as a single-element array. Callers iterating over
        ; this still see correct concatenated output.
        return [this.encode(value)]
    }

    default(obj)
    {
        ; Mirrors CPython: by default, raises TypeError; subclasses override to
        ; produce a serializable substitute. Callers using options.default get
        ; their hook routed through AhkStdlibJsonStringify before this fires.
        throw TypeError("Object of type " Type(obj) " is not JSON serializable", -1)
    }
}

; CPython JSONDecoder: configurable parser holding object_hook/parse_float/etc.
; Exposes decode(text) / raw_decode(text) -> [value, end_index] for streaming
; parsers that need to know how many characters were consumed.
class AhkStdlibJsonDecoder
{
    __New(options := unset)
    {
        config := {
            object_hook: stdlib.None,
            parse_float: stdlib.None,
            parse_int: stdlib.None
        }
        if IsSet(options) && IsObject(options) {
            if HasProp(options, "object_hook") && !AhkStdlibIsNone(options.object_hook)
                config.object_hook := options.object_hook
            if HasProp(options, "parse_float") && !AhkStdlibIsNone(options.parse_float)
                config.parse_float := options.parse_float
            if HasProp(options, "parse_int") && !AhkStdlibIsNone(options.parse_int)
                config.parse_int := options.parse_int
        }
        this._config := config
        this.object_hook := config.object_hook
        this.parse_float := config.parse_float
        this.parse_int := config.parse_int
    }

    decode(text)
    {
        return AhkStdlibJsonParser(text, this._config).Parse()
    }

    raw_decode(text)
    {
        ; Skip leading whitespace per CPython, then parse one value and return
        ; (value, end_index_after_value) without complaining about trailing
        ; data — this is the streaming-friendly entry point.
        parser := AhkStdlibJsonParser(text, this._config)
        parser.SkipWhitespace()
        value := parser.ParseValue()
        return AhkStdlibTuple([value, parser.Pos - 1])
    }
}

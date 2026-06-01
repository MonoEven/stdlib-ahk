#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTextJson
{
    static Null := AhkStdlibJsonNull()
    static True := stdlib.True
    static False := stdlib.False

    static Bool(value)
    {
        return AhkStdlibTruthValue(value) ? this.True : this.False
    }

    static load(path, encoding := "UTF-8")
    {
        return AhkStdlibJsonLoads(FileRead(path, encoding))
    }

    static loads(text)
    {
        return AhkStdlibJsonLoads(text)
    }

    static dump(value, path, encoding := "UTF-8")
    {
        text := AhkStdlibJsonDumps(value)
        if FileExist(path)
            FileDelete path
        FileAppend text, path, encoding
        return text
    }

    static dumps(value)
    {
        return AhkStdlibJsonDumps(value)
    }
}

stdlib.json := AhkStdlibTextJson

AhkStdlibJsonNull()
{
    static value := { __AhkStdlibJsonNull: true }
    return value
}

AhkStdlibJsonLoads(text)
{
    return AhkStdlibJsonParser(text).Parse()
}

AhkStdlibJsonDumps(value)
{
    return AhkStdlibJsonStringify(value)
}

AhkStdlibJsonIsNull(value)
{
    return IsObject(value) && !(value !== AhkStdlibJsonNull())
}

AhkStdlibJsonIsBool(value)
{
    return AhkStdlibIsBool(value)
}

AhkStdlibJsonStringify(value)
{
    if AhkStdlibJsonIsNull(value)
        return "null"
    if AhkStdlibJsonIsBool(value)
        return value.Value ? "true" : "false"

    valueType := Type(value)
    switch valueType {
        case "String":
            return AhkStdlibJsonQuote(value)
        case "Integer":
            return value ""
        case "Float":
            return value ""
        case "Array":
            return AhkStdlibJsonArrayToString(value)
        case "Map":
            return AhkStdlibJsonMapToString(value)
        case "Object":
            return AhkStdlibJsonObjectToString(value)
        default:
            throw TypeError("cannot JSON serialize value of type " valueType, -1)
    }
}

AhkStdlibJsonArrayToString(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibJsonStringify(value))
    return "[" AhkStdlibJsonJoin(parts, ", ") "]"
}

AhkStdlibJsonMapToString(values)
{
    parts := []
    for key, value in values
        parts.Push(AhkStdlibJsonQuote(key "") ": " AhkStdlibJsonStringify(value))
    return "{" AhkStdlibJsonJoin(parts, ", ") "}"
}

AhkStdlibJsonObjectToString(value)
{
    parts := []
    for key, item in value.OwnProps()
        parts.Push(AhkStdlibJsonQuote(key) ": " AhkStdlibJsonStringify(item))
    return "{" AhkStdlibJsonJoin(parts, ", ") "}"
}

AhkStdlibJsonQuote(text)
{
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
                if code < 32 || code > 127
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
    result := ""
    for index, value in values {
        if index > 1
            result .= delimiter
        result .= value
    }
    return result
}

class AhkStdlibJsonParser
{
    __New(text)
    {
        this.Text := text
        this.Pos := 1
        this.Length := StrLen(text)
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
            return result

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
                return result
            this.ExpectChar(",")
        }
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
        return isFloat ? Float(token) : Integer(token)
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
        throw ValueError("JSON parse error at position " this.Pos ": " message, -1)
    }
}

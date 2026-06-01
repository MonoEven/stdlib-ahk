#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibHtml
{
    static escape(args*)
    {
        if args.Length = 0
            throw TypeError("escape() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("escape() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        s := args[1]
        if !(s is String)
            throw AttributeError("'" AhkStdlibPythonTypeName(s) "' object has no attribute 'replace'", -1)

        quote := true
        if args.Length >= 2
            quote := AhkStdlibTruthValue(args[2])

        escaped := StrReplace(s, "&", "&amp;")
        escaped := StrReplace(escaped, "<", "&lt;")
        escaped := StrReplace(escaped, ">", "&gt;")

        if quote {
            escaped := StrReplace(escaped, Chr(34), "&quot;")
            escaped := StrReplace(escaped, "'", "&#x27;")
        }

        return escaped
    }

    static unescape(args*)
    {
        if args.Length = 0
            throw TypeError("unescape() missing 1 required positional argument: 's'", -1)
        if args.Length > 1
            throw TypeError("unescape() takes 1 positional argument but " args.Length " were given", -1)

        s := args[1]
        if !(s is String)
            throw TypeError("argument of type '" AhkStdlibPythonTypeName(s) "' is not iterable", -1)

        if !InStr(s, "&")
            return s
        return AhkStdlibHtmlUnescapeText(s)
    }
}

stdlib.html := AhkStdlibHtml

AhkStdlibHtmlUnescapeText(text)
{
    result := ""
    index := 1
    while index <= StrLen(text) {
        char := SubStr(text, index, 1)
        if char != "&" {
            result .= char
            index += 1
            continue
        }

        consumed := 0
        decoded := AhkStdlibHtmlDecodeEntity(text, index, &consumed)
        if consumed > 0 {
            result .= decoded
            index += consumed
            continue
        }

        result .= char
        index += 1
    }
    return result
}

AhkStdlibHtmlDecodeEntity(text, start, &consumed)
{
    consumed := 0
    if start >= StrLen(text)
        return ""

    next := SubStr(text, start + 1, 1)
    if next = "#"
        return AhkStdlibHtmlDecodeNumericEntity(text, start, &consumed)
    return AhkStdlibHtmlDecodeNamedEntity(text, start, &consumed)
}

AhkStdlibHtmlDecodeNumericEntity(text, start, &consumed)
{
    consumed := 0
    index := start + 2
    if index > StrLen(text)
        return ""

    base := 10
    if index <= StrLen(text) {
        prefix := SubStr(text, index, 1)
        if prefix = "x" || prefix = "X" {
            base := 16
            index += 1
        }
    }

    digitStart := index
    while index <= StrLen(text) {
        char := SubStr(text, index, 1)
        if !AhkStdlibHtmlIsDigitForBase(char, base)
            break
        index += 1
    }

    if index = digitStart
        return ""

    hasSemicolon := index <= StrLen(text) && SubStr(text, index, 1) = ";"
    digits := SubStr(text, digitStart, index - digitStart)
    codepoint := AhkStdlibHtmlParseInteger(digits, base)
    consumed := (index - start) + (hasSemicolon ? 1 : 0)
    return Chr(codepoint)
}

AhkStdlibHtmlDecodeNamedEntity(text, start, &consumed)
{
    consumed := 0
    static entities := Map(
        "nbsp", Chr(160),
        "quot", Chr(34),
        "apos", "'",
        "amp", "&",
        "lt", "<",
        "gt", ">"
    )
    static names := ["nbsp", "quot", "apos", "amp", "lt", "gt"]

    for _, name in names {
        withSemicolon := "&" name ";"
        if AhkStdlibHtmlStartsWith(text, start, withSemicolon) {
            consumed := StrLen(withSemicolon)
            return entities[name]
        }

        bare := "&" name
        if !AhkStdlibHtmlStartsWith(text, start, bare)
            continue

        nextPos := start + StrLen(bare)
        if nextPos <= StrLen(text) && AhkStdlibHtmlIsNameChar(SubStr(text, nextPos, 1))
            continue

        consumed := StrLen(bare)
        return entities[name]
    }

    return ""
}

AhkStdlibHtmlStartsWith(text, start, needle)
{
    return SubStr(text, start, StrLen(needle)) = needle
}

AhkStdlibHtmlIsNameChar(char)
{
    return RegExMatch(char, "^[0-9A-Za-z]$")
}

AhkStdlibHtmlIsDigitForBase(char, base)
{
    if base = 10
        return RegExMatch(char, "^\d$")
    return RegExMatch(char, "^[0-9A-Fa-f]$")
}

AhkStdlibHtmlParseInteger(text, base)
{
    value := 0
    loop parse text {
        digit := AhkStdlibHtmlDigitValue(A_LoopField)
        value := (value * base) + digit
    }
    return value
}

AhkStdlibHtmlDigitValue(char)
{
    code := Ord(char)
    if code >= Ord("0") && code <= Ord("9")
        return code - Ord("0")
    if code >= Ord("A") && code <= Ord("F")
        return 10 + (code - Ord("A"))
    return 10 + (code - Ord("a"))
}

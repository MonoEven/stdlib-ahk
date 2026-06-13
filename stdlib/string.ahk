#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibString
{
    static ascii_lowercase := "abcdefghijklmnopqrstuvwxyz"
    static ascii_uppercase := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    static ascii_letters := AhkStdlibString.ascii_lowercase AhkStdlibString.ascii_uppercase
    static digits := "0123456789"
    static hexdigits := "0123456789abcdefABCDEF"
    static octdigits := "01234567"
    static punctuation := "!" Chr(34) "#$%&'()*+,-./:;<=>?@[" Chr(92) "]^_" Chr(96) "{|}~"
    static whitespace := " `t`n`r" Chr(11) Chr(12)
    static printable := AhkStdlibString.digits AhkStdlibString.ascii_letters AhkStdlibString.punctuation AhkStdlibString.whitespace

    static Template := AhkStdlibStringTemplate

    static Formatter
    {
        get => AhkStdlibStringFormatter
    }

    static Formatter(args*)
    {
        return AhkStdlibStringFormatter(args*)
    }

    static capwords(args*)
    {
        if args.Length = 0
            throw TypeError("capwords() missing 1 required positional argument: 's'", -1)
        if args.Length > 2
            throw TypeError("capwords() takes from 1 to 2 positional arguments but " args.Length " were given", -1)

        s := args[1]
        if !(s is String)
            throw AttributeError("'" AhkStdlibPythonTypeName(s) "' object has no attribute 'split'", -1)

        if args.Length = 1
            return AhkStdlibStringCapwordsDefault(s)

        sep := args[2]
        if AhkStdlibIsNone(sep)
            return AhkStdlibStringCapwordsDefault(s)
        if AhkStdlibIsBool(sep) {
            if sep.Value
                throw AttributeError("'bool' object has no attribute 'join'", -1)
            throw TypeError("must be str or None, not bool", -1)
        }
        if !(sep is String)
            throw AttributeError("'" AhkStdlibPythonTypeName(sep) "' object has no attribute 'join'", -1)
        if sep = ""
            throw ValueError("empty separator", -1)

        parts := StrSplit(s, sep)
        loop parts.Length
            parts[A_Index] := AhkStdlibStringCapitalize(parts[A_Index])
        return AhkStdlibStringJoin(parts, sep)
    }
}

stdlib.string := AhkStdlibString

AhkStdlibStringCapwordsDefault(text)
{
    normalized := Trim(RegExReplace(text, "\s+", A_Space), AhkStdlibString.whitespace)
    if normalized = ""
        return ""

    parts := StrSplit(normalized, A_Space)
    loop parts.Length
        parts[A_Index] := AhkStdlibStringCapitalize(parts[A_Index])
    return AhkStdlibStringJoin(parts, A_Space)
}

AhkStdlibStringCapitalize(text)
{
    if text = ""
        return ""
    return StrUpper(SubStr(text, 1, 1)) StrLower(SubStr(text, 2))
}

AhkStdlibStringJoin(parts, separator)
{
    result := ""
    for index, part in parts {
        if index > 1
            result .= separator
        result .= part
    }
    return result
}

class AhkStdlibStringTemplate
{
    static Call(thisClass, template)
    {
        return AhkStdlibStringTemplateValue(template)
    }
}

class AhkStdlibStringTemplateValue
{
    __New(template)
    {
        if !(template is String)
            throw TypeError("Template argument must be str, not " AhkStdlibPythonTypeName(template), -1)
        this.template := template
    }

    substitute(mapping := unset)
    {
        return AhkStdlibStringTemplateRender(this.template, AhkStdlibStringTemplateMapping(mapping?), false)
    }

    safe_substitute(mapping := unset)
    {
        return AhkStdlibStringTemplateRender(this.template, AhkStdlibStringTemplateMapping(mapping?), true)
    }
}

AhkStdlibStringTemplateMapping(mapping := unset)
{
    result := Map()
    if !IsSet(mapping)
        return result
    if mapping is Map {
        for key, value in mapping
            result[String(key)] := value
        return result
    }
    if IsObject(mapping) {
        for key, value in mapping.OwnProps()
            result[key] := value
        return result
    }
    throw TypeError("substitute() mapping must be a Map or Object", -1)
}

AhkStdlibStringTemplateRender(template, mapping, safe)
{
    output := ""
    index := 1
    length := StrLen(template)

    while index <= length {
        char := SubStr(template, index, 1)
        if char != "$" {
            output .= char
            index += 1
            continue
        }

        if index = length {
            if safe {
                output .= "$"
                index += 1
                continue
            }
            throw ValueError("Invalid placeholder in string: line 1, col " index, -1)
        }

        nextChar := SubStr(template, index + 1, 1)
        if nextChar = "$" {
            output .= "$"
            index += 2
            continue
        }

        if nextChar = "{" {
            closePos := InStr(template, "}", , index + 2)
            if !closePos {
                if safe {
                    output .= "$"
                    index += 1
                    continue
                }
                throw ValueError("Invalid placeholder in string: line 1, col " index, -1)
            }
            name := SubStr(template, index + 2, closePos - index - 2)
            if !AhkStdlibStringTemplateIsIdentifier(name) {
                if safe {
                    output .= SubStr(template, index, closePos - index + 1)
                    index := closePos + 1
                    continue
                }
                throw ValueError("Invalid placeholder in string: line 1, col " index, -1)
            }
            output .= AhkStdlibStringTemplateValueFor(mapping, name, safe, "${" name "}")
            index := closePos + 1
            continue
        }

        name := AhkStdlibStringTemplateReadIdentifier(template, index + 1)
        if name = "" {
            if safe {
                output .= "$"
                index += 1
                continue
            }
            throw ValueError("Invalid placeholder in string: line 1, col " index, -1)
        }
        output .= AhkStdlibStringTemplateValueFor(mapping, name, safe, "$" name)
        index += 1 + StrLen(name)
    }
    return output
}

AhkStdlibStringTemplateValueFor(mapping, name, safe, original)
{
    if mapping.Has(name)
        return String(mapping[name])
    if safe
        return original
    throw stdlib.KeyError("'" name "'", -1)
}

AhkStdlibStringTemplateReadIdentifier(template, start)
{
    firstChar := SubStr(template, start, 1)
    if !AhkStdlibStringTemplateIsIdentifierStart(firstChar)
        return ""

    name := firstChar
    pos := start + 1
    length := StrLen(template)
    while pos <= length {
        char := SubStr(template, pos, 1)
        if !AhkStdlibStringTemplateIsIdentifierChar(char)
            break
        name .= char
        pos += 1
    }
    return name
}

AhkStdlibStringTemplateIsIdentifier(name)
{
    if name = ""
        return false
    if !AhkStdlibStringTemplateIsIdentifierStart(SubStr(name, 1, 1))
        return false
    loop StrLen(name) {
        if !AhkStdlibStringTemplateIsIdentifierChar(SubStr(name, A_Index, 1))
            return false
    }
    return true
}

AhkStdlibStringTemplateIsIdentifierStart(char)
{
    return char = "_" || RegExMatch(char, "^[A-Za-z]$")
}

AhkStdlibStringTemplateIsIdentifierChar(char)
{
    return char = "_" || RegExMatch(char, "^[A-Za-z0-9]$")
}

; ---------------------------------------------------------------------------
; Formatter — Python's string.Formatter class.
; Supports {}, {0}, {name}, {0.attr}, {0[key]}, format specs (delegated to
; AHK's Format() where they map cleanly), and !r/!s/!a conversions.
; ---------------------------------------------------------------------------

class AhkStdlibStringFormatter
{
    format(formatString, args*)
    {
        return this.vformat(formatString, args, Map())
    }

    vformat(formatString, args, kwargs)
    {
        result := ""
        autoIndex := 0
        explicitMode := ""  ; "" until first field decides; then "auto" or "manual"
        for entry in this.parse(formatString) {
            literalText := entry[1]
            fieldName := entry[2]
            formatSpec := entry[3]
            conversion := entry[4]
            result .= literalText
            if AhkStdlibIsNone(fieldName)
                continue
            ; Auto-numbering
            effectiveField := fieldName
            if fieldName = "" {
                if explicitMode = "manual"
                    throw ValueError("cannot switch from manual field specification to automatic field numbering", -1)
                explicitMode := "auto"
                effectiveField := String(autoIndex)
                autoIndex += 1
            } else if RegExMatch(SubStr(fieldName, 1, 1), "^[0-9]$") {
                if explicitMode = "auto"
                    throw ValueError("cannot switch from automatic field numbering to manual field specification", -1)
                explicitMode := "manual"
            }
            value := this.get_field(effectiveField, args, kwargs)
            value := this.convert_field(value, conversion)
            result .= this.format_field(value, formatSpec)
        }
        return result
    }

    parse(formatString)
    {
        ; Yields (literal_text, field_name, format_spec, conversion) tuples
        ; matching CPython's Formatter.parse output.
        return AhkStdlibStringFormatterParse(formatString)
    }

    get_field(fieldName, args, kwargs)
    {
        ; Split first into the "first" key + a list of (is_attr, key) pairs,
        ; then drill down. Compatible with Python's _vformat helper.
        first := ""
        rest := []
        AhkStdlibStringFormatterSplitFieldName(fieldName, &first, &rest)
        value := this.get_value(first, args, kwargs)
        for piece in rest {
            isAttr := piece[1]
            key := piece[2]
            if isAttr {
                if !IsObject(value) || !HasProp(value, key)
                    throw stdlib.AttributeError("'" AhkStdlibPythonTypeName(value) "' object has no attribute '" key "'", -1)
                value := value.%key%
            } else {
                ; Try integer index first if key looks numeric
                if RegExMatch(key, "^-?\d+$") {
                    idx := Integer(key)
                    if value is Array {
                        if idx < 0
                            idx += value.Length
                        value := value[idx + 1]
                        continue
                    }
                }
                if value is Map
                    value := value[key]
                else if IsObject(value) && HasProp(value, "__Item")
                    value := value[key]
                else
                    throw TypeError("'" AhkStdlibPythonTypeName(value) "' object is not subscriptable", -1)
            }
        }
        return value
    }

    get_value(key, args, kwargs)
    {
        ; Numeric key -> positional arg (1-based to AHK args array)
        if RegExMatch(key, "^\d+$") {
            idx := Integer(key)
            if !(args is Array)
                throw TypeError("Formatter args must be a list", -1)
            if idx >= args.Length
                throw stdlib.KeyError("Replacement index " idx " out of range for positional args", -1)
            return args[idx + 1]
        }
        ; Named key -> kwargs lookup
        if kwargs is Map {
            if kwargs.Has(key)
                return kwargs[key]
        } else if IsObject(kwargs) && HasProp(kwargs, key) {
            return kwargs.%key%
        }
        throw stdlib.KeyError("'" key "'", -1)
    }

    format_field(value, formatSpec)
    {
        if formatSpec = ""
            return AhkStdlibStringFormatterToString(value)
        ; Delegate to AHK Format() with a translated spec.
        return AhkStdlibStringFormatterApplySpec(value, formatSpec)
    }

    convert_field(value, conversion)
    {
        if AhkStdlibIsNone(conversion) || conversion = ""
            return value
        switch conversion {
            case "r":
                ; Python repr(): strings get quoted with single quotes.
                if value is String
                    return "'" StrReplace(value, "'", "\'") "'"
                return AhkStdlibStringFormatterToString(value)
            case "s":
                return AhkStdlibStringFormatterToString(value)
            case "a":
                ; ASCII repr: like 'r' but escape non-ASCII.
                if value is String {
                    out := "'"
                    Loop Parse value {
                        ch := A_LoopField
                        code := Ord(ch)
                        if code > 127
                            out .= Format("\u{:04x}", code)
                        else if ch = "'"
                            out .= "\'"
                        else
                            out .= ch
                    }
                    return out "'"
                }
                return AhkStdlibStringFormatterToString(value)
            default:
                throw ValueError("Unknown conversion specifier: '" conversion "'", -1)
        }
    }
}

AhkStdlibStringFormatterToString(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return value
    return String(value)
}

AhkStdlibStringFormatterApplySpec(value, spec)
{
    ; Parse Python format spec: [[fill]align][sign][#][0][width][,][.precision][type]
    ; AHK Format() does not support align/fill/group separators, so build the
    ; result manually for the common cases used by Python tests.
    parsed := AhkStdlibStringFormatterParseSpec(spec)
    typeChar := parsed.type
    ; Numeric formatting
    if typeChar = "d" || typeChar = "x" || typeChar = "X" || typeChar = "o" || typeChar = "b" {
        n := Integer(value)
        switch typeChar {
            case "d":
                core := Format("{:d}", n)
            case "x":
                core := Format("{:x}", n)
            case "X":
                core := Format("{:X}", n)
            case "o":
                core := Format("{:o}", n)
            case "b":
                ; AHK Format has no binary; build manually
                if n = 0
                    core := "0"
                else {
                    core := ""
                    abs := n < 0 ? -n : n
                    while abs > 0 {
                        core := Mod(abs, 2) core
                        abs := abs // 2
                    }
                    if n < 0
                        core := "-" core
                }
        }
    } else if typeChar = "f" || typeChar = "F" {
        prec := parsed.precision = "" ? 6 : Integer(parsed.precision)
        core := Format("{:." prec "f}", value)
    } else if typeChar = "e" || typeChar = "E" {
        prec := parsed.precision = "" ? 6 : Integer(parsed.precision)
        core := Format("{:." prec typeChar "}", value)
    } else if typeChar = "g" || typeChar = "G" {
        prec := parsed.precision = "" ? 6 : Integer(parsed.precision)
        core := Format("{:." prec typeChar "}", value)
    } else if typeChar = "s" || typeChar = "" {
        core := AhkStdlibStringFormatterToString(value)
        if parsed.precision != "" {
            limit := Integer(parsed.precision)
            if StrLen(core) > limit
                core := SubStr(core, 1, limit)
        }
    } else {
        ; Fallback: pass-through to AHK Format()
        return Format("{:" spec "}", value)
    }

    ; Apply zero-pad before alignment if requested.
    if parsed.zeroPad && parsed.width != "" && (typeChar != "s" && typeChar != "") {
        targetW := Integer(parsed.width)
        signChar := ""
        rest := core
        if SubStr(core, 1, 1) = "-" {
            signChar := "-"
            rest := SubStr(core, 2)
        }
        while StrLen(signChar rest) < targetW
            rest := "0" rest
        core := signChar rest
    }

    ; Apply alignment + fill.
    if parsed.width != "" {
        w := Integer(parsed.width)
        n := StrLen(core)
        if n < w {
            fill := parsed.fill = "" ? " " : parsed.fill
            gap := w - n
            align := parsed.align
            if align = "" {
                ; Default align: numbers right, strings left.
                align := (typeChar = "s" || typeChar = "") ? "<" : ">"
            }
            switch align {
                case ">":
                    core := AhkStdlibStringFormatterRepeat(fill, gap) core
                case "<":
                    core := core AhkStdlibStringFormatterRepeat(fill, gap)
                case "^":
                    leftPad := gap // 2
                    rightPad := gap - leftPad
                    core := AhkStdlibStringFormatterRepeat(fill, leftPad) core AhkStdlibStringFormatterRepeat(fill, rightPad)
                case "=":
                    ; Zero-pad after sign (already applied if zeroPad set)
                    if SubStr(core, 1, 1) = "-"
                        core := "-" AhkStdlibStringFormatterRepeat(fill, gap) SubStr(core, 2)
                    else
                        core := AhkStdlibStringFormatterRepeat(fill, gap) core
            }
        }
    }
    return core
}

AhkStdlibStringFormatterParseSpec(spec)
{
    ; Returns object: {fill, align, sign, alt, zeroPad, width, precision, type}
    parsed := { fill: "", align: "", sign: "", alt: false, zeroPad: false, width: "", precision: "", type: "" }
    n := StrLen(spec)
    i := 1
    if n = 0
        return parsed
    ; [[fill]align]: align is one of '<>=^' optionally preceded by any one fill char
    if n >= 2 {
        c2 := SubStr(spec, 2, 1)
        if c2 = "<" || c2 = ">" || c2 = "=" || c2 = "^" {
            parsed.fill := SubStr(spec, 1, 1)
            parsed.align := c2
            i := 3
        }
    }
    if i = 1 {
        c1 := SubStr(spec, 1, 1)
        if c1 = "<" || c1 = ">" || c1 = "=" || c1 = "^" {
            parsed.align := c1
            i := 2
        }
    }
    if i <= n {
        c := SubStr(spec, i, 1)
        if c = "+" || c = "-" || c = " " {
            parsed.sign := c
            i += 1
        }
    }
    if i <= n && SubStr(spec, i, 1) = "#" {
        parsed.alt := true
        i += 1
    }
    if i <= n && SubStr(spec, i, 1) = "0" {
        parsed.zeroPad := true
        i += 1
    }
    ; Width: digits
    while i <= n && RegExMatch(SubStr(spec, i, 1), "^\d$") {
        parsed.width .= SubStr(spec, i, 1)
        i += 1
    }
    ; Precision: .digits
    if i <= n && SubStr(spec, i, 1) = "." {
        i += 1
        while i <= n && RegExMatch(SubStr(spec, i, 1), "^\d$") {
            parsed.precision .= SubStr(spec, i, 1)
            i += 1
        }
    }
    ; Type: last remaining char
    if i <= n
        parsed.type := SubStr(spec, i, 1)
    return parsed
}

AhkStdlibStringFormatterRepeat(text, count)
{
    out := ""
    loop count
        out .= text
    return out
}

; Iterator-like array of (literal, field_name, format_spec, conversion) tuples
; matching CPython's Formatter.parse return shape.
AhkStdlibStringFormatterParse(formatString)
{
    out := []
    n := StrLen(formatString)
    i := 1
    literal := ""
    while i <= n {
        ch := SubStr(formatString, i, 1)
        if ch = "{" {
            if SubStr(formatString, i + 1, 1) = "{" {
                literal .= "{"
                i += 2
                continue
            }
            ; Find matching closing brace, accounting for nested braces inside spec
            depth := 1
            j := i + 1
            while j <= n {
                c2 := SubStr(formatString, j, 1)
                if c2 = "{"
                    depth += 1
                else if c2 = "}" {
                    depth -= 1
                    if depth = 0
                        break
                }
                j += 1
            }
            if depth != 0
                throw ValueError("Single '{' encountered in format string", -1)
            inner := SubStr(formatString, i + 1, j - i - 1)
            ; Split inner into field_name [! conversion] [: spec]
            fieldName := inner
            conversion := stdlib.None
            formatSpec := ""
            colonPos := AhkStdlibStringFormatterFindTopColon(inner)
            if colonPos > 0 {
                formatSpec := SubStr(inner, colonPos + 1)
                fieldName := SubStr(inner, 1, colonPos - 1)
            }
            bangPos := InStr(fieldName, "!")
            if bangPos {
                conversion := SubStr(fieldName, bangPos + 1, 1)
                fieldName := SubStr(fieldName, 1, bangPos - 1)
            }
            out.Push(stdlib.tuple([literal, fieldName, formatSpec, conversion]))
            literal := ""
            i := j + 1
            continue
        }
        if ch = "}" {
            if SubStr(formatString, i + 1, 1) = "}" {
                literal .= "}"
                i += 2
                continue
            }
            throw ValueError("Single '}' encountered in format string", -1)
        }
        literal .= ch
        i += 1
    }
    if literal != ""
        out.Push(stdlib.tuple([literal, stdlib.None, stdlib.None, stdlib.None]))
    return out
}

AhkStdlibStringFormatterFindTopColon(text)
{
    depth := 0
    Loop StrLen(text) {
        ch := SubStr(text, A_Index, 1)
        if ch = "["
            depth += 1
        else if ch = "]"
            depth -= 1
        else if ch = ":" && depth = 0
            return A_Index
    }
    return 0
}

AhkStdlibStringFormatterSplitFieldName(fieldName, &first, &rest)
{
    rest := []
    ; Find first '.' or '[' that splits the name
    n := StrLen(fieldName)
    i := 1
    while i <= n {
        ch := SubStr(fieldName, i, 1)
        if ch = "." || ch = "["
            break
        i += 1
    }
    first := SubStr(fieldName, 1, i - 1)
    while i <= n {
        ch := SubStr(fieldName, i, 1)
        if ch = "." {
            ; Attribute access: read until next . or [
            i += 1
            start := i
            while i <= n {
                c2 := SubStr(fieldName, i, 1)
                if c2 = "." || c2 = "["
                    break
                i += 1
            }
            rest.Push([true, SubStr(fieldName, start, i - start)])
        } else if ch = "[" {
            i += 1
            start := i
            while i <= n && SubStr(fieldName, i, 1) != "]"
                i += 1
            rest.Push([false, SubStr(fieldName, start, i - start)])
            i += 1  ; skip ]
        }
    }
}

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

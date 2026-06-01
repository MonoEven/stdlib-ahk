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

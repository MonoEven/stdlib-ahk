#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibFnmatch
{
    static fnmatch(args*)
    {
        if args.Length = 0
            throw TypeError("fnmatch() missing 2 required positional arguments: 'name' and 'pat'", -1)
        if args.Length = 1
            throw TypeError("fnmatch() missing 1 required positional argument: 'pat'", -1)
        if args.Length > 2
            throw TypeError("fnmatch() takes 2 positional arguments but " args.Length " were given", -1)

        nameInfo := AhkStdlibFnmatchCoerceInput(args[1])
        patInfo := AhkStdlibFnmatchCoerceInput(args[2])
        AhkStdlibFnmatchEnsureCompatibleKinds(nameInfo, patInfo)
        return AhkStdlibFnmatchMatch(AhkStdlibFnmatchNormcase(nameInfo.Text), AhkStdlibFnmatchNormcase(patInfo.Text))
    }

    static fnmatchcase(args*)
    {
        if args.Length = 0
            throw TypeError("fnmatchcase() missing 2 required positional arguments: 'name' and 'pat'", -1)
        if args.Length = 1
            throw TypeError("fnmatchcase() missing 1 required positional argument: 'pat'", -1)
        if args.Length > 2
            throw TypeError("fnmatchcase() takes 2 positional arguments but " args.Length " were given", -1)

        nameInfo := AhkStdlibFnmatchCoerceInput(args[1])
        patInfo := AhkStdlibFnmatchCoerceInput(args[2])
        AhkStdlibFnmatchEnsureCompatibleKinds(nameInfo, patInfo)
        return AhkStdlibFnmatchMatch(nameInfo.Text, patInfo.Text)
    }

    static filter(args*)
    {
        if args.Length = 0
            throw TypeError("filter() missing 2 required positional arguments: 'names' and 'pat'", -1)
        if args.Length = 1
            throw TypeError("filter() missing 1 required positional argument: 'pat'", -1)
        if args.Length > 2
            throw TypeError("filter() takes 2 positional arguments but " args.Length " were given", -1)

        names := args[1]
        patInfo := AhkStdlibFnmatchCoerceInput(args[2])
        matcherPattern := patInfo.Kind = "str" ? AhkStdlibFnmatchNormcase(patInfo.Text) : AhkStdlibFnmatchNormcase(patInfo.Text)
        result := []

        if names is String {
            loop parse names
                if AhkStdlibFnmatchMatch(AhkStdlibFnmatchNormcase(A_LoopField), matcherPattern)
                    result.Push(A_LoopField)
            return result
        }

        if !(IsObject(names) && HasMethod(names, "__Enum"))
            throw TypeError("'" AhkStdlibPythonTypeName(names) "' object is not iterable", -1)

        for name in names {
            nameInfo := AhkStdlibFnmatchCoerceInput(name)
            AhkStdlibFnmatchEnsureCompatibleKinds(nameInfo, patInfo)
            if AhkStdlibFnmatchMatch(AhkStdlibFnmatchNormcase(nameInfo.Text), matcherPattern)
                result.Push(name)
        }
        return result
    }

    static translate(args*)
    {
        if args.Length = 0
            throw TypeError("translate() missing 1 required positional argument: 'pat'", -1)
        if args.Length > 1
            throw TypeError("translate() takes 1 positional argument but " args.Length " were given", -1)

        pat := args[1]
        if pat is Buffer
            throw TypeError("decoding to str: need a bytes-like object, int found", -1)
        if !(pat is String)
            throw TypeError("expected str, bytes or os.PathLike object, not " AhkStdlibPythonTypeName(pat), -1)
        return AhkStdlibFnmatchTranslatePattern(pat)
    }
}

stdlib.fnmatch := AhkStdlibFnmatch

AhkStdlibFnmatchCoerceInput(value)
{
    if value is String
        return { Kind: "str", Text: value, Original: value }
    if value is Buffer
        return { Kind: "bytes", Text: AhkStdlibFnmatchBufferToLatin1(value), Original: value }
    throw TypeError("expected str, bytes or os.PathLike object, not " AhkStdlibPythonTypeName(value), -1)
}

AhkStdlibFnmatchEnsureCompatibleKinds(nameInfo, patInfo)
{
    if nameInfo.Kind = patInfo.Kind
        return
    if nameInfo.Kind = "str"
        throw TypeError("cannot use a bytes pattern on a string-like object", -1)
    throw TypeError("cannot use a string pattern on a bytes-like object", -1)
}

AhkStdlibFnmatchNormcase(text)
{
    return StrLower(StrReplace(text, "/", "\"))
}

AhkStdlibFnmatchMatch(name, pat)
{
    regex := AhkStdlibFnmatchTranslatePattern(pat)
    found := RegExMatch(name, regex, &match, 1)
    return found = 1 && match.Len[0] = StrLen(name)
}

AhkStdlibFnmatchTranslatePattern(pat)
{
    star := AhkStdlibFnmatchStarSentinel()
    parts := []
    i := 1
    n := StrLen(pat)

    while i <= n {
        c := SubStr(pat, i, 1)
        i += 1

        if c = "*" {
            if parts.Length = 0 || (parts[parts.Length] !== star)
                parts.Push(star)
            continue
        }

        if c = "?" {
            parts.Push(".")
            continue
        }

        if c = "[" {
            j := i
            if j <= n && SubStr(pat, j, 1) = "!"
                j += 1
            if j <= n && SubStr(pat, j, 1) = "]"
                j += 1
            while j <= n && SubStr(pat, j, 1) != "]"
                j += 1

            if j > n {
                parts.Push("\[")
                continue
            }

            stuff := SubStr(pat, i, j - i)
            stuff := StrReplace(stuff, "\", "\\")
            stuff := AhkStdlibFnmatchEscapeSetOperators(stuff)
            i := j + 1

            if stuff = "" {
                parts.Push("(?!)")
            } else if stuff = "!" {
                parts.Push(".")
            } else {
                first := SubStr(stuff, 1, 1)
                if first = "!" {
                    stuff := "^" SubStr(stuff, 2)
                } else if first = "^" || first = "[" {
                    stuff := "\" stuff
                }
                parts.Push("[" stuff "]")
            }
            continue
        }

        parts.Push(AhkStdlibFnmatchEscapeRegexChar(c))
    }

    result := ""
    index := 1
    total := parts.Length
    while index <= total && (parts[index] !== star) {
        result .= parts[index]
        index += 1
    }

    while index <= total {
        index += 1
        if index > total {
            result .= ".*"
            break
        }

        fixed := ""
        while index <= total && (parts[index] !== star) {
            fixed .= parts[index]
            index += 1
        }

        if index > total {
            result .= ".*" fixed
        } else {
            groupNum := AhkStdlibFnmatchNextGroupNumber()
            result .= "(?=(?P<g" groupNum ">.*?" fixed "))(?P=g" groupNum ")"
        }
    }

    return "(?s:" result ")\Z"
}

AhkStdlibFnmatchEscapeRegexChar(char)
{
    if InStr(".^$+(){}|[]\", char)
        return "\" char
    return char
}

AhkStdlibFnmatchEscapeSetOperators(text)
{
    escaped := ""
    loop parse text
        escaped .= InStr("&~|", A_LoopField) ? "\" A_LoopField : A_LoopField
    return escaped
}

AhkStdlibFnmatchBufferToLatin1(buffer)
{
    text := ""
    loop buffer.Size
        text .= Chr(NumGet(buffer, A_Index - 1, "UChar"))
    return text
}

AhkStdlibFnmatchStarSentinel()
{
    static value := { __AhkStdlibFnmatchStar: true }
    return value
}

AhkStdlibFnmatchNextGroupNumber()
{
    static value := 0
    current := value
    value += 1
    return current
}

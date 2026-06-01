#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibTextwrap
{
    static dedent(args*)
    {
        if args.Length = 0
            throw TypeError("dedent() missing 1 required positional argument: 'text'", -1)
        if args.Length > 1
            throw TypeError("dedent() takes 1 positional argument but " args.Length " were given", -1)

        text := args[1]
        if !(text is String)
            throw TypeError("expected string or bytes-like object", -1)

        return AhkStdlibTextwrapDedent(text)
    }

    static indent(args*)
    {
        if args.Length = 0
            throw TypeError("indent() missing 2 required positional arguments: 'text' and 'prefix'", -1)
        if args.Length = 1
            throw TypeError("indent() missing 1 required positional argument: 'prefix'", -1)
        if args.Length > 3
            throw TypeError("indent() takes from 2 to 3 positional arguments but " args.Length " were given", -1)

        text := args[1]
        if !(text is String)
            throw AttributeError("'" AhkStdlibPythonTypeName(text) "' object has no attribute 'splitlines'", -1)

        prefix := args[2]
        if !(prefix is String)
            throw TypeError("unsupported operand type(s) for +: '" AhkStdlibPythonTypeName(prefix) "' and 'str'", -1)

        predicate := unset
        if args.Length >= 3
            predicate := args[3]

        return AhkStdlibTextwrapIndent(text, prefix, predicate?)
    }
}

stdlib.textwrap := AhkStdlibTextwrap

AhkStdlibTextwrapDedent(text)
{
    lines := StrSplit(text, "`n")
    if lines.Length = 0
        return text

    margin := unset
    for _, line in lines {
        trimmedLine := RTrim(line, "`r")
        if RegExMatch(trimmedLine, "^[ `t]*$", &blankMatch)
            continue
        if RegExMatch(trimmedLine, "^[ `t]*", &indentMatch) {
            indent := indentMatch[0]
            if !IsSet(margin)
                margin := indent
            else
                margin := AhkStdlibTextwrapCommonMargin(margin, indent)
        }
    }

    if !IsSet(margin)
        return RegExReplace(text, "[ `t]+(?=(\r?\n|$))", "")
    if margin = ""
        return RegExReplace(text, "[ `t]+(?=(\r?\n|$))", "")

    dedentedLines := []
    for _, line in lines {
        if RegExMatch(line, "^[ `t]*$", &blankMatch) {
            dedentedLines.Push(RegExReplace(line, "[ `t]+(?=(\r?$))", ""))
            continue
        }
        if InStr(line, margin) = 1
            dedentedLines.Push(SubStr(line, StrLen(margin) + 1))
        else
            dedentedLines.Push(line)
    }
    return AhkStdlibTextwrapJoinLines(dedentedLines)
}

AhkStdlibTextwrapIndent(text, prefix, predicate := unset)
{
    lines := StrSplit(text, "`n")
    result := ""
    for index, line in lines {
        applyPrefix := false
        if IsSet(predicate) {
            if !IsObject(predicate) || !HasMethod(predicate)
                throw TypeError("'" AhkStdlibPythonTypeName(predicate) "' object is not callable", -1)
            applyPrefix := AhkStdlibTruthValue(predicate(line))
        } else {
            applyPrefix := !RegExMatch(line, "^[ `t]*\r?$")
        }

        if applyPrefix
            result .= prefix
        result .= line
        if index < lines.Length
            result .= "`n"
    }
    return result
}

AhkStdlibTextwrapCommonMargin(left, right)
{
    if left = ""
        return ""
    if right = ""
        return ""

    if InStr(left, right) = 1
        return right
    if InStr(right, left) = 1
        return left

    common := ""
    maxLength := Min(StrLen(left), StrLen(right))
    loop maxLength {
        char := SubStr(left, A_Index, 1)
        if char != SubStr(right, A_Index, 1)
            break
        common .= char
    }
    return common
}

AhkStdlibTextwrapJoinLines(lines)
{
    result := ""
    for index, line in lines {
        if index > 1
            result .= "`n"
        result .= line
    }
    return result
}

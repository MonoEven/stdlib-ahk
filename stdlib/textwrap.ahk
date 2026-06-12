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

    static wrap(text, options := unset)
    {
        if !(text is String)
            throw TypeError("expected string", -1)
        return AhkStdlibTextwrapWrap(text, AhkStdlibTextwrapOptions(options?))
    }

    static fill(text, options := unset)
    {
        lines := this.wrap(text, options?)
        return AhkStdlibTextwrapJoinLines(lines)
    }

    static shorten(text, options := unset)
    {
        if !(text is String)
            throw TypeError("expected string", -1)
        return AhkStdlibTextwrapShorten(text, AhkStdlibTextwrapOptions(options?))
    }
}

stdlib.textwrap := AhkStdlibTextwrap

AhkStdlibTextwrapOptions(options := unset)
{
    config := {
        width: 70,
        placeholder: " [...]",
        break_long_words: true,
        drop_whitespace: true,
        initial_indent: "",
        subsequent_indent: "",
        max_lines: stdlib.None
    }
    if !IsSet(options)
        return config
    if !IsObject(options)
        throw TypeError("options must be an object", -1)
    for name in ["width", "placeholder", "break_long_words", "drop_whitespace", "initial_indent", "subsequent_indent", "max_lines"] {
        if HasProp(options, name)
            config.%name% := options.%name%
    }
    return config
}

AhkStdlibTextwrapNormalizeWhitespace(text)
{
    collapsed := RegExReplace(text, "\s+", " ")
    return Trim(collapsed, " ")
}

AhkStdlibTextwrapSplitWords(text)
{
    words := []
    for word in StrSplit(text, " ") {
        if word != ""
            words.Push(word)
    }
    return words
}

AhkStdlibTextwrapWrap(text, config)
{
    normalized := AhkStdlibTextwrapNormalizeWhitespace(text)
    words := AhkStdlibTextwrapSplitWords(normalized)
    lines := []
    width := config.width

    index := 1
    while index <= words.Length {
        indent := lines.Length = 0 ? config.initial_indent : config.subsequent_indent
        current := ""
        available := width - StrLen(indent)

        while index <= words.Length {
            word := words[index]
            candidate := current = "" ? word : current " " word
            if StrLen(candidate) <= available {
                current := candidate
                index += 1
                continue
            }
            if current = "" {
                if config.break_long_words && available > 0 {
                    current := SubStr(word, 1, available)
                    words[index] := SubStr(word, available + 1)
                } else {
                    current := word
                    index += 1
                }
            }
            break
        }

        lines.Push(indent current)
    }

    if !AhkStdlibIsNone(config.max_lines)
        return AhkStdlibTextwrapApplyMaxLines(words, config, lines)
    return lines
}

AhkStdlibTextwrapApplyMaxLines(words, config, lines)
{
    maxLines := config.max_lines
    if lines.Length <= maxLines
        return lines

    truncated := []
    loop maxLines
        truncated.Push(lines[A_Index])

    placeholder := config.placeholder
    lastIndent := maxLines = 1 ? config.initial_indent : config.subsequent_indent
    available := config.width - StrLen(lastIndent)
    lastLine := SubStr(truncated[maxLines], StrLen(lastIndent) + 1)

    if StrLen(lastLine) + StrLen(placeholder) <= available {
        truncated[maxLines] := lastIndent lastLine placeholder
        return truncated
    }

    words := AhkStdlibTextwrapSplitWords(lastLine)
    rebuilt := ""
    for word in words {
        candidate := rebuilt = "" ? word : rebuilt " " word
        if StrLen(candidate) + StrLen(placeholder) <= available
            rebuilt := candidate
        else
            break
    }
    placeholderTrimmed := LTrim(placeholder, " ")
    if rebuilt = ""
        truncated[maxLines] := lastIndent placeholderTrimmed
    else
        truncated[maxLines] := lastIndent rebuilt placeholder
    return truncated
}

AhkStdlibTextwrapShorten(text, config)
{
    normalized := AhkStdlibTextwrapNormalizeWhitespace(text)
    if StrLen(normalized) <= config.width
        return normalized

    placeholder := config.placeholder
    words := AhkStdlibTextwrapSplitWords(normalized)
    rebuilt := ""
    for word in words {
        candidate := rebuilt = "" ? word : rebuilt " " word
        if StrLen(candidate) + StrLen(placeholder) <= config.width
            rebuilt := candidate
        else
            break
    }
    if rebuilt = ""
        return LTrim(placeholder, " ")
    return rebuilt placeholder
}

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

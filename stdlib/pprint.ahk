#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibPPrint
{
    static pformat(object, indent := 1, width := 80, depth := unset, compact := false, sort_dicts := true)
    {
        printer := AhkStdlibPPrintPrettyPrinter(indent, width, depth?, stdlib.None, compact, sort_dicts)
        return printer.pformat(object)
    }

    static pprint(object, stream := unset, indent := 1, width := 80, depth := unset, compact := false, sort_dicts := true)
    {
        printer := AhkStdlibPPrintPrettyPrinter(indent, width, depth?, IsSet(stream) ? stream : stdlib.None, compact, sort_dicts)
        return printer.pprint(object)
    }

    static pp(object, stream := unset, sort_dicts := false, indent := 1, width := 80, depth := unset, compact := false)
    {
        printer := AhkStdlibPPrintPrettyPrinter(indent, width, depth?, IsSet(stream) ? stream : stdlib.None, compact, sort_dicts)
        return printer.pprint(object)
    }

    static saferepr(object)
    {
        return AhkStdlibPPrintSafeRepr(object, Map(), stdlib.None, 0, true).repr
    }

    static isreadable(object)
    {
        return AhkStdlibBool(AhkStdlibPPrintSafeRepr(object, Map(), stdlib.None, 0, true).readable)
    }

    static isrecursive(object)
    {
        return AhkStdlibBool(AhkStdlibPPrintSafeRepr(object, Map(), stdlib.None, 0, true).recursive)
    }

    static PrettyPrinter := AhkStdlibPPrintPrettyPrinterClass
}

class AhkStdlibPPrintPrettyPrinterClass
{
    static Call(thisClass, indent := 1, width := 80, depth := unset, stream := unset, compact := false, sort_dicts := true)
    {
        return AhkStdlibPPrintPrettyPrinter(indent, width, depth?, stream?, compact, sort_dicts)
    }
}

class AhkStdlibPPrintPrettyPrinter
{
    __New(indent := 1, width := 80, depth := unset, stream := unset, compact := false, sort_dicts := true)
    {
        this.indent := AhkStdlibPPrintParseInt(indent)
        this.width := AhkStdlibPPrintParseInt(width)
        this.depth := IsSet(depth) && !AhkStdlibIsNone(depth) ? AhkStdlibPPrintParseInt(depth) : stdlib.None
        this.stream := IsSet(stream) ? stream : stdlib.None
        this.compact := AhkStdlibTruthValue(compact)
        this.sort_dicts := AhkStdlibTruthValue(sort_dicts)
    }

    pformat(object)
    {
        return AhkStdlibPPrintFormatValue(object, this, 0, 0)
    }

    pprint(object)
    {
        stream := this.stream
        if AhkStdlibIsNone(stream)
            FileAppend(this.pformat(object) "`n", "**", "UTF-8")
        else {
            if !HasMethod(stream, "write")
                throw stdlib.AttributeError("'" AhkStdlibPythonTypeName(stream) "' object has no attribute 'write'", -1)
            stream.write(this.pformat(object) "`n")
        }
        return stdlib.None
    }
}

stdlib.pprint := AhkStdlibPPrint

AhkStdlibPPrintParseInt(value)
{
    if value is Integer
        return value
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    if value is String && value != "" {
        if value ~= "^-?\d+$"
            return Integer(value)
    }
    throw ValueError("invalid literal for int() with base 10: '" value "'", -1)
}

AhkStdlibPPrintFormatValue(value, printer, depthLevel, inlineIndent)
{
    if !(AhkStdlibIsNone(printer.depth)) && depthLevel >= printer.depth {
        if value is Array || value is Map
            return "[...]"
    }

    if value is Map
        return AhkStdlibPPrintFormatMap(value, printer, depthLevel, inlineIndent)
    if value is Array
        return AhkStdlibPPrintFormatArray(value, printer, depthLevel, inlineIndent)
    return AhkStdlibPPrintScalarRepr(value)
}

AhkStdlibPPrintFormatArray(values, printer, depthLevel, inlineIndent)
{
    if values.Length = 0
        return "[]"

    parts := []
    for value in values
        parts.Push(AhkStdlibPPrintFormatValue(value, printer, depthLevel + 1, inlineIndent + 1))

    single := "[" AhkStdlibPPrintJoin(parts, ", ") "]"
    multilineThreshold := printer.width - inlineIndent
    if printer.compact
        return AhkStdlibPPrintCompactArray(parts, multilineThreshold)
    if StrLen(single) <= multilineThreshold
        return single

    indentText := AhkStdlibPPrintRepeat(" ", printer.indent)
    leadingSpace := AhkStdlibPPrintNeedsCompoundLeadingSpace(parts) ? " " : ""
    return "[" leadingSpace AhkStdlibPPrintJoin(parts, ",`n" indentText) "]"
}

AhkStdlibPPrintCompactArray(parts, multilineThreshold)
{
    single := "[" AhkStdlibPPrintJoin(parts, ", ") "]"
    if StrLen(single) <= multilineThreshold
        return single

    rows := []
    current := ""
    for part in parts {
        candidate := current = "" ? part : current ", " part
        if current != "" && StrLen(candidate) > multilineThreshold {
            rows.Push(current)
            current := part
        } else {
            current := candidate
        }
    }
    if current != ""
        rows.Push(current)
    return "[" AhkStdlibPPrintJoin(rows, ",`n ") "]"
}

AhkStdlibPPrintFormatMap(mapping, printer, depthLevel, inlineIndent)
{
    if mapping.Count = 0
        return "{}"

    pairs := []
    for key, value in mapping
        pairs.Push([key, value])

        if printer.sort_dicts
            AhkStdlibPPrintSortPairsByKey(&pairs)

    items := []
    for pair in pairs
        items.Push(AhkStdlibPPrintScalarRepr(pair[1]) ": " AhkStdlibPPrintFormatValue(pair[2], printer, depthLevel + 1, inlineIndent + 2))

    single := "{" AhkStdlibPPrintJoin(items, ", ") "}"
    multilineThreshold := printer.width - inlineIndent
    if StrLen(single) <= multilineThreshold
        return single

    indentText := AhkStdlibPPrintRepeat(" ", printer.indent)
    firstIndent := printer.indent > 1 ? " " : ""
    return "{" firstIndent AhkStdlibPPrintJoin(items, ",`n" indentText) "}"
}

AhkStdlibPPrintSortPairsByKey(&pairs)
{
    count := pairs.Length
    loop count - 1 {
        outer := A_Index
        loop count - outer {
            index := A_Index
            left := AhkStdlibPPrintScalarRepr(pairs[index][1])
            right := AhkStdlibPPrintScalarRepr(pairs[index + 1][1])
            if StrCompare(left, right) > 0 {
                temp := pairs[index]
                pairs[index] := pairs[index + 1]
                pairs[index + 1] := temp
            }
        }
    }
}

AhkStdlibPPrintScalarRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if HasMethod(value, "__Repr")
        return value.__Repr()
    if value is String
        return AhkStdlibPPrintStringRepr(value)
    if value is Float {
        text := String(value)
        if !InStr(text, ".") && !InStr(text, "e") && !InStr(text, "E")
            text .= ".0"
        return text
    }
    if value is Integer
        return String(value)
    if value is Map
        return AhkStdlibPPrintFormatMap(value, AhkStdlibPPrintPrettyPrinter(), 0, 0)
    if value is Array
        return AhkStdlibPPrintFormatArray(value, AhkStdlibPPrintPrettyPrinter(), 0, 0)
    return "<" Type(value) " object>"
}

AhkStdlibPPrintStringRepr(value)
{
    escaped := StrReplace(value, "\", "\\")
    escaped := StrReplace(escaped, "'", "\'")
    escaped := StrReplace(escaped, "`r", "\r")
    escaped := StrReplace(escaped, "`n", "\n")
    escaped := StrReplace(escaped, "`t", "\t")
    return "'" escaped "'"
}

AhkStdlibPPrintJoin(values, delimiter)
{
    text := ""
    for index, value in values {
        if index > 1
            text .= delimiter
        text .= value
    }
    return text
}

AhkStdlibPPrintRepeat(text, count)
{
    result := ""
    loop count
        result .= text
    return result
}

AhkStdlibPPrintNeedsCompoundLeadingSpace(parts)
{
    if parts.Length = 0
        return false
    first := parts[1]
    return RegExMatch(first, "^[\[\{\(]")
}

; Faithful port of CPython 3.10 pprint._safe_repr. Returns an object with
; .repr (string), .readable (bool), .recursive (bool). maxlevels is None
; (no truncation) for the public saferepr/isreadable/isrecursive helpers.
; Recursion is detected by tracking container identity (ObjPtr) in context.
AhkStdlibPPrintSafeRepr(object, context, maxlevels, level, sort_dicts)
{
    if object is Map {
        if object.Count = 0
            return {repr: "{}", readable: true, recursive: false}
        objid := ObjPtr(object)
        if !AhkStdlibIsNone(maxlevels) && level >= maxlevels
            return {repr: "{...}", readable: false, recursive: context.Has(objid)}
        if context.Has(objid)
            return {repr: AhkStdlibPPrintRecursion(object), readable: false, recursive: true}
        context[objid] := 1
        readable := true
        recursive := false
        components := []
        pairs := []
        for key, value in object
            pairs.Push([key, value])
        if AhkStdlibTruthValue(sort_dicts)
            AhkStdlibPPrintSortPairsByKey(&pairs)
        for pair in pairs {
            kres := AhkStdlibPPrintSafeRepr(pair[1], context, maxlevels, level + 1, sort_dicts)
            vres := AhkStdlibPPrintSafeRepr(pair[2], context, maxlevels, level + 1, sort_dicts)
            components.Push(kres.repr ": " vres.repr)
            readable := readable && kres.readable && vres.readable
            if kres.recursive || vres.recursive
                recursive := true
        }
        context.Delete(objid)
        return {repr: "{" AhkStdlibPPrintJoin(components, ", ") "}", readable: readable, recursive: recursive}
    }

    if object is Array {
        if object.Length = 0
            return {repr: "[]", readable: true, recursive: false}
        objid := ObjPtr(object)
        if !AhkStdlibIsNone(maxlevels) && level >= maxlevels
            return {repr: "[...]", readable: false, recursive: context.Has(objid)}
        if context.Has(objid)
            return {repr: AhkStdlibPPrintRecursion(object), readable: false, recursive: true}
        context[objid] := 1
        readable := true
        recursive := false
        components := []
        for value in object {
            res := AhkStdlibPPrintSafeRepr(value, context, maxlevels, level + 1, sort_dicts)
            components.Push(res.repr)
            if !res.readable
                readable := false
            if res.recursive
                recursive := true
        }
        context.Delete(objid)
        return {repr: "[" AhkStdlibPPrintJoin(components, ", ") "]", readable: readable, recursive: recursive}
    }

    rep := AhkStdlibPPrintScalarRepr(object)
    return {repr: rep, readable: (rep != "" && SubStr(rep, 1, 1) != "<"), recursive: false}
}

AhkStdlibPPrintRecursion(object)
{
    return "<Recursion on " AhkStdlibPythonTypeName(object) " with id=" ObjPtr(object) ">"
}

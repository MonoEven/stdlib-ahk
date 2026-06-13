#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibWarningsWarning extends Error
{
}

class AhkStdlibWarningsUserWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsDeprecationWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsPendingDeprecationWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsFutureWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsRuntimeWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsSyntaxWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsImportWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsUnicodeWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsBytesWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsResourceWarning extends AhkStdlibWarningsWarning
{
}

class AhkStdlibWarningsWarningMessage
{
    __New(message, category, location := unset, source := unset)
    {
        this.message := message
        this.category := category
        if IsSet(location) {
            this.filename := location.File
            this.lineno := location.Line
        } else {
            this.filename := A_LineFile
            this.lineno := A_LineNumber
        }
        this.module := this.filename
        if IsSet(source)
            this.source := source
    }
}

class AhkStdlibWarningsCatchWarnings
{
    __New(record := false)
    {
        this.Record := record
    }

    Call(callback)
    {
        if !HasMethod(callback, "Call")
            throw TypeError("catch_warnings callback must be callable", -1)

        records := []
        savedFilters := AhkStdlibWarnings._Filters.Clone()
        AhkStdlibWarningsPushContext({ Record: this.Record, Records: records, Seen: Map() })
        try {
            callback.Call(records)
        } finally {
            AhkStdlibWarningsPopContext()
            AhkStdlibWarnings._Filters := savedFilters
        }
        return this.Record ? records : ""
    }
}

class AhkStdlibWarnings
{
    static Warning := AhkStdlibWarningsWarning
    static UserWarning := AhkStdlibWarningsUserWarning
    static DeprecationWarning := AhkStdlibWarningsDeprecationWarning
    static PendingDeprecationWarning := AhkStdlibWarningsPendingDeprecationWarning
    static FutureWarning := AhkStdlibWarningsFutureWarning
    static RuntimeWarning := AhkStdlibWarningsRuntimeWarning
    static SyntaxWarning := AhkStdlibWarningsSyntaxWarning
    static ImportWarning := AhkStdlibWarningsImportWarning
    static UnicodeWarning := AhkStdlibWarningsUnicodeWarning
    static BytesWarning := AhkStdlibWarningsBytesWarning
    static ResourceWarning := AhkStdlibWarningsResourceWarning
    static _Contexts := []
    static _Registry := []
    static _Seen := Map()
    static _Filters := []

    static warn(message, category := unset, stacklevel := 1, source := unset)
    {
        if !IsSet(category)
            category := this.UserWarning
        AhkStdlibWarningsCheckCategory(category)

        location := AhkStdlibWarningsLocation(stacklevel)
        record := AhkStdlibWarningsWarningMessage(message, category, location, source?)
        AhkStdlibWarningsEmit(record)
    }

    static warn_explicit(message, category := unset, filename := "", lineno := 0, module := unset, source := unset)
    {
        if !IsSet(category)
            category := this.UserWarning
        AhkStdlibWarningsCheckCategory(category)

        record := AhkStdlibWarningsWarningMessage(message, category)
        record.filename := filename
        record.lineno := lineno
        record.module := IsSet(module) ? module : AhkStdlibWarningsModuleFromFilename(filename)
        if IsSet(source)
            record.source := source
        AhkStdlibWarningsEmit(record)
    }

    static filterwarnings(action, message := "", category := unset, module := "", lineno := 0, append := false)
    {
        if !IsSet(category)
            category := this.Warning
        AhkStdlibWarningsCheckAction(action)
        AhkStdlibWarningsCheckCategory(category)
        if !(message is String)
            throw TypeError("message must be a string", -1)
        if !(module is String)
            throw TypeError("module must be a string", -1)
        if !(lineno is Integer) || lineno < 0
            throw TypeError("lineno must be an int >= 0", -1)

        filter := { Action: action, Category: category, Lineno: lineno
            , Message: message, Module: module }
        if append
            this._Filters.Push(filter)
        else
            this._Filters.InsertAt(1, filter)
    }

    static formatwarning(message, category, filename, lineno, line := unset)
    {
        return AhkStdlibWarningsFormat(message, category, filename, lineno, line?)
    }

    static showwarning(message, category, filename, lineno, file := unset, line := unset)
    {
        text := AhkStdlibWarningsFormat(message, category, filename, lineno, line?)
        if IsSet(file) && IsObject(file) && HasMethod(file, "Write") {
            file.Write(text)
        } else {
            FileAppend(text, "**", "UTF-8")
        }
    }

    static simplefilter(action, category := unset, lineno := 0, append := false)
    {
        if !IsSet(category)
            category := this.Warning
        AhkStdlibWarningsCheckAction(action)
        filter := { Action: action, Category: category, Lineno: lineno
            , Message: "", Module: "" }
        if append
            this._Filters.Push(filter)
        else
            this._Filters.InsertAt(1, filter)
    }

    static resetwarnings()
    {
        this._Filters := []
    }

    static catch_warnings(record := false)
    {
        return AhkStdlibWarningsCatchWarnings(record)
    }
}

stdlib.warnings := AhkStdlibWarnings

AhkStdlibWarningsPushContext(context)
{
    AhkStdlibWarnings._Contexts.Push(context)
}

AhkStdlibWarningsPopContext()
{
    AhkStdlibWarnings._Contexts.Pop()
}

AhkStdlibWarningsCheckAction(action)
{
    if action = "default" || action = "always" || action = "error" || action = "ignore" || action = "module" || action = "once"
        return
    throw ValueError("invalid action: " action, -1)
}

AhkStdlibWarningsCheckCategory(category)
{
    if category == AhkStdlibWarnings.Warning
        return
    if IsObject(category) && HasProp(category, "Prototype") && HasBase(category.Prototype, AhkStdlibWarnings.Warning.Prototype)
        return
    throw TypeError("category must be a Warning subclass, not 'type'", -1)
}

AhkStdlibWarningsFilterAction(record)
{
    for filter in AhkStdlibWarnings._Filters {
        if AhkStdlibWarningsFilterMatches(record, filter)
            return filter.Action
    }
    return "default"
}

AhkStdlibWarningsFilterMatches(record, filter)
{
    if !AhkStdlibWarningsCategoryMatches(record.category, filter.Category)
        return false
    if HasProp(filter, "Message") && filter.Message != "" {
        ; Python: re.compile(message, re.I).match(text) -> case-insensitive, anchored at start
        if !RegExMatch(record.message "", "i)^(?:" filter.Message ")")
            return false
    }
    if HasProp(filter, "Module") && filter.Module != "" {
        ; Python: re.compile(module).match(name) -> case-sensitive, anchored at start
        if !RegExMatch(record.module "", "^(?:" filter.Module ")")
            return false
    }
    return filter.Lineno = 0 || filter.Lineno = record.lineno
}

AhkStdlibWarningsCategoryMatches(category, expected)
{
    if category == expected
        return true
    if IsObject(category) && HasProp(category, "Prototype") && IsObject(expected) && HasProp(expected, "Prototype")
        return HasBase(category.Prototype, expected.Prototype)
    return false
}

AhkStdlibWarningsLocation(stacklevel)
{
    if !(stacklevel is Integer) || stacklevel < 1
        stacklevel := 1
    return Error("", -(stacklevel + 1))
}

AhkStdlibWarningsShouldEmit(record, action)
{
    if action != "default" && action != "module" && action != "once"
        return true

    registry := AhkStdlibWarningsSeenRegistry()
    key := AhkStdlibWarningsRegistryKey(record, action)
    if registry.Has(key)
        return false
    registry[key] := true
    return true
}

AhkStdlibWarningsSeenRegistry()
{
    if AhkStdlibWarnings._Contexts.Length > 0 {
        context := AhkStdlibWarnings._Contexts[AhkStdlibWarnings._Contexts.Length]
        return context.Seen
    }
    return AhkStdlibWarnings._Seen
}

AhkStdlibWarningsRegistryKey(record, action)
{
    categoryName := record.category.Prototype.__Class
    if action = "once"
        return record.message "`n" categoryName
    if action = "module"
        return record.message "`n" categoryName "`n" record.filename
    return record.message "`n" categoryName "`n" record.filename "`n" record.lineno
}

AhkStdlibWarningsEmit(record)
{
    action := AhkStdlibWarningsFilterAction(record)
    if action = "error" {
        ; Assign class to a local first: record.category(...) is parsed as a
        ; method call and injects record as a hidden first arg, shifting message.
        errCategory := record.category
        errMessage := record.message
        throw errCategory(errMessage, -1)
    }
    if action = "ignore"
        return
    if !AhkStdlibWarningsShouldEmit(record, action)
        return

    if AhkStdlibWarnings._Contexts.Length > 0 {
        context := AhkStdlibWarnings._Contexts[AhkStdlibWarnings._Contexts.Length]
        if context.Record
            context.Records.Push(record)
    } else {
        AhkStdlibWarnings._Registry.Push(record)
    }
}

AhkStdlibWarningsModuleFromFilename(filename)
{
    name := filename ""
    ; strip directory
    SplitPath(name, &base)
    name := base
    ; strip extension
    if RegExMatch(name, "^(.*)\.[^.]*$", &m)
        name := m[1]
    return name
}

AhkStdlibWarningsCategoryName(category)
{
    fullName := category.Prototype.__Class
    ; AhkStdlibWarningsUserWarning -> UserWarning; custom subclasses keep their own name
    if RegExMatch(fullName, "^AhkStdlibWarnings(.+)$", &m)
        return m[1]
    return fullName
}

AhkStdlibWarningsFormat(message, category, filename, lineno, line := unset)
{
    name := AhkStdlibWarningsCategoryName(category)
    text := filename ":" lineno ": " name ": " message "`n"
    if IsSet(line) {
        stripped := Trim(line "", " `t`r`n")
        if stripped != ""
            text .= "  " stripped "`n"
    }
    return text
}

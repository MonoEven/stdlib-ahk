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
        action := AhkStdlibWarningsFilterAction(record)
        if action = "error"
            throw category(message, -1)
        if action = "ignore"
            return
        if !AhkStdlibWarningsShouldEmit(record, action)
            return

        if this._Contexts.Length > 0 {
            context := this._Contexts[this._Contexts.Length]
            if context.Record
                context.Records.Push(record)
        } else {
            this._Registry.Push(record)
        }
    }

    static simplefilter(action, category := unset, lineno := 0, append := false)
    {
        if !IsSet(category)
            category := this.Warning
        AhkStdlibWarningsCheckAction(action)
        filter := { Action: action, Category: category, Lineno: lineno }
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

#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibEnumModule
{
    static Enum(args*)
    {
        return AhkStdlibEnumBuildType("Enum", args*)
    }

    static auto(args*)
    {
        if args.Length != 0
            throw TypeError("auto() takes no arguments", -1)
        return AhkStdlibEnumAutoValue()
    }

    static IntEnum(args*)
    {
        return AhkStdlibEnumBuildType("IntEnum", args*)
    }

    static Flag(args*)
    {
        return AhkStdlibEnumBuildType("Flag", args*)
    }

    static IntFlag(args*)
    {
        return AhkStdlibEnumBuildType("IntFlag", args*)
    }

    static unique(enumType)
    {
        ; Decorator: raise if any two member names share a value (aliases).
        ; Use the alias-tracking list captured at construction.
        aliases := enumType.AhkStdlibEnumAliases
        if aliases.Length > 0 {
            joined := ""
            for pair in aliases {
                entry := pair[1] " -> " pair[2]
                joined := joined = "" ? entry : joined ", " entry
            }
            throw ValueError("duplicate values found in <enum '" enumType.__name "'>: " joined, -1)
        }
        return enumType
    }

    ; Class-syntax base classes. AHK's `extends` requires a literal class name,
    ; so these are exposed as top-level globals (like every AHK class) AND echoed
    ; here for discovery. Use as: `class Color extends AhkStdlibEnum { ... }`.
    static EnumBase := AhkStdlibEnum
    static IntEnumBase := AhkStdlibIntEnum
    static FlagBase := AhkStdlibFlag
    static IntFlagBase := AhkStdlibIntFlag
}

; ---------------------------------------------------------------------------
; Class-syntax enums (Python's `class Color(Enum)`).
;
; AHK has no metaclass, but `static __New` is a genuine class-creation hook:
; it fires once per subclass at load time with `this` bound to the new class.
; Static field initializers run top-to-bottom *before* __New, so a member
; factory that stamps a global creation counter lets __New recover definition
; order (OwnProps() alone returns names case-insensitively sorted, losing it).
;
; Members are declared with the factory helpers, NOT bare literals, because a
; bare `static RED := 1` is indistinguishable from any other static and carries
; no order stamp:
;     class Color extends AhkStdlibEnum {
;         static RED   := AhkStdlibEnum.member(1)
;         static GREEN := AhkStdlibEnum.auto()
;     }
; After __New, Color.RED is a real enum member, `Color(1)`, `Color["RED"]`,
; and `for m in Color` all work, exactly like the functional API's enum type.
; ---------------------------------------------------------------------------

class AhkStdlibEnum
{
    static AhkStdlibEnumKind := "Enum"

    static __New()
    {
        AhkStdlibEnumClassInit(this)
    }

    ; Member factories. `this` is NOT injected for Class.Method() calls, so the
    ; first parameter is the real argument.
    static member(value)
    {
        return AhkStdlibEnumMemberSpec(value, false)
    }

    static auto()
    {
        return AhkStdlibEnumMemberSpec(unset, true)
    }
}

class AhkStdlibIntEnum extends AhkStdlibEnum
{
    static AhkStdlibEnumKind := "IntEnum"
    static __New()
    {
        AhkStdlibEnumClassInit(this)
    }
}

class AhkStdlibFlag extends AhkStdlibEnum
{
    static AhkStdlibEnumKind := "Flag"
    static __New()
    {
        AhkStdlibEnumClassInit(this)
    }
}

class AhkStdlibIntFlag extends AhkStdlibEnum
{
    static AhkStdlibEnumKind := "IntFlag"
    static __New()
    {
        AhkStdlibEnumClassInit(this)
    }
}

; A member declaration captured in the class body. Stamps a monotonically
; increasing creation counter so definition order survives OwnProps() sorting.
global AhkStdlibEnumSpecCounter := 0

class AhkStdlibEnumMemberSpec
{
    __New(value := unset, isAuto := false)
    {
        global AhkStdlibEnumSpecCounter
        AhkStdlibEnumSpecCounter += 1
        this.AhkStdlibSpecOrder := AhkStdlibEnumSpecCounter
        this.AhkStdlibSpecIsAuto := isAuto
        if !isAuto && IsSet(value)
            this.AhkStdlibSpecValue := value
    }
}

; Build the enum onto the class itself (the class IS the enum type, like Python).
AhkStdlibEnumClassInit(cls)
{
    ; The four framework base classes themselves define no members — skip them.
    ; A real user enum has at least one member spec among its own static props.
    specs := AhkStdlibEnumCollectSpecs(cls)
    if specs.Length = 0
        return

    kind := cls.AhkStdlibEnumKind
    name := cls.Prototype.__Class

    ; Resolve auto() values in definition order, honoring _generate_next_value_.
    rows := AhkStdlibEnumResolveClassRows(cls, specs, kind, name)

    AhkStdlibEnumInstallOnClass(cls, kind, name, rows)
}

AhkStdlibEnumCollectSpecs(cls)
{
    specs := []
    for propName in cls.OwnProps() {
        value := cls.%propName%
        if value is AhkStdlibEnumMemberSpec
            specs.Push({ name: propName, spec: value })
    }
    ; Sort by creation order (insertion sort; member counts are small).
    loop specs.Length {
        i := A_Index
        loop specs.Length - i {
            j := A_Index
            if specs[j].spec.AhkStdlibSpecOrder > specs[j + 1].spec.AhkStdlibSpecOrder {
                tmp := specs[j]
                specs[j] := specs[j + 1]
                specs[j + 1] := tmp
            }
        }
    }
    return specs
}

AhkStdlibEnumResolveClassRows(cls, specs, kind, name)
{
    rows := []
    lastValues := []
    count := 0
    for entry in specs {
        spec := entry.spec
        if spec.AhkStdlibSpecIsAuto {
            value := AhkStdlibEnumGenerateNextValue(cls, kind, entry.name, count, lastValues)
            factory := AhkStdlibEnumAutoValue()
        } else {
            value := spec.AhkStdlibSpecValue
            factory := stdlib.None
        }
        lastValues.Push(value)
        count += 1
        rows.Push({ Name: entry.name, Value: value, Factory: factory })
    }
    return rows
}

; Mirrors Enum._generate_next_value_(name, start, count, last_values). A user
; class may override it (static method, no `this` injection). Default: Enum/
; IntEnum increment the last value (start at 1); Flag/IntFlag use the next
; power of two above the highest seen.
AhkStdlibEnumGenerateNextValue(cls, kind, memberName, count, lastValues)
{
    if HasMethod(cls, "_generate_next_value_")
        return cls._generate_next_value_(memberName, 1, count, AhkStdlibEnumCopyArray(lastValues))

    if kind = "Flag" || kind = "IntFlag"
        return AhkStdlibEnumNextFlagValue(lastValues)

    if lastValues.Length = 0
        return 1
    return lastValues[lastValues.Length] + 1
}

AhkStdlibEnumNextFlagValue(lastValues)
{
    if lastValues.Length = 0
        return 1
    ; next power of two strictly above the max value seen
    maxSeen := 0
    for value in lastValues {
        if value is Integer && value > maxSeen
            maxSeen := value
    }
    next := 1
    while next <= maxSeen
        next *= 2
    return next
}

AhkStdlibEnumCopyArray(source)
{
    copy := []
    for value in source
        copy.Push(value)
    return copy
}

; Turn `cls` into a working enum type: build member objects (with `cls` as their
; class so reprs read Color.RED), wire aliases, rewrite each static prop to its
; member, and install Call (value lookup), __Item (name lookup) and __Enum.
AhkStdlibEnumInstallOnClass(cls, kind, name, rows)
{
    memberMap := Map()
    canonical := []        ; iteration order, no aliases
    aliases := []          ; [aliasName, canonicalName] pairs

    for row in rows {
        existing := AhkStdlibEnumFindMemberByValue(canonical, row.Value)
        if existing != "" {
            memberMap[row.Name] := existing
            cls.DefineProp(row.Name, { Value: existing })
            aliases.Push([row.Name, existing.name])
            continue
        }
        member := AhkStdlibEnumMember(cls, row.Name, row.Value, row.Factory)
        memberMap[row.Name] := member
        canonical.Push(member)
        cls.DefineProp(row.Name, { Value: member })
    }

    cls.DefineProp("__name", { Value: name })
    cls.DefineProp("__kind", { Value: kind })
    cls.DefineProp("AhkStdlibEnumMemberMap", { Value: memberMap })
    cls.DefineProp("AhkStdlibEnumMembers", { Value: canonical })
    cls.DefineProp("AhkStdlibEnumAliases", { Value: aliases })
    cls.DefineProp("__members", { Value: AhkStdlibEnumClassMembersView(cls) })

    cls.DefineProp("Call", { Call: AhkStdlibEnumClassLookupByValue })
    cls.DefineProp("__Item", { Get: AhkStdlibEnumClassLookupByName })
    cls.DefineProp("__Enum", { Call: AhkStdlibEnumClassEnumerate })
}

AhkStdlibEnumClassLookupByValue(cls, value)
{
    for member in cls.AhkStdlibEnumMembers {
        if AhkStdlibEnumValuesEqual(member.value, value)
            return member
    }
    if HasMethod(cls, "_missing_") {
        try {
            result := cls._missing_(value)
            if IsObject(result) && (result is AhkStdlibEnumMember)
                return result
        } catch {
        }
    }
    throw ValueError(AhkStdlibEnumReprValue(value) " is not a valid " cls.__name, -1)
}

AhkStdlibEnumClassLookupByName(cls, propName)
{
    if cls.AhkStdlibEnumMemberMap.Has(propName)
        return cls.AhkStdlibEnumMemberMap[propName]
    throw KeyError("'" propName "'", -1)
}

AhkStdlibEnumClassEnumerate(cls, numberOfVars)
{
    members := cls.AhkStdlibEnumMembers
    index := 0
    if numberOfVars = 1 {
        return (&value) => (
            index += 1,
            index <= members.Length ? (value := members[index], true) : false
        )
    }
    return (&name, &value) => (
        index += 1,
        index <= members.Length ? (name := members[index].name, value := members[index], true) : false
    )
}

class AhkStdlibEnumClassMembersView
{
    __New(cls)
    {
        this.AhkStdlibEnumClass := cls
    }

    Has(name)
    {
        return this.AhkStdlibEnumClass.AhkStdlibEnumMemberMap.Has(name)
    }

    __Item[name]
    {
        get => this.AhkStdlibEnumClass.AhkStdlibEnumMemberMap[name]
    }

    __Enum(numberOfVars)
    {
        members := this.AhkStdlibEnumClass.AhkStdlibEnumMembers
        index := 0
        if numberOfVars = 1 {
            return (&value) => (
                index += 1,
                index <= members.Length ? (value := members[index].name, true) : false
            )
        }
        return (&name, &value) => (
            index += 1,
            index <= members.Length ? (name := members[index].name, value := members[index], true) : false
        )
    }
}

class AhkStdlibEnumAutoValue
{
    __Repr()
    {
        return "<auto>"
    }

    ToString()
    {
        return this.__Repr()
    }
}

class AhkStdlibEnumType
{
    __New(kind, name, memberRows)
    {
        this.__kind := kind
        this.__name := name
        this.AhkStdlibEnumMemberMap := Map()
        this.AhkStdlibEnumMembers := []         ; canonical members only (iteration order)
        this.AhkStdlibEnumAllMembers := []      ; canonical + aliases (definition order)
        this.AhkStdlibEnumAliases := []         ; names of alias entries -> canonical name pairs

        for row in memberRows {
            ; Alias detection: if a previous canonical member already has this
            ; value, reuse that member object so the new name is an alias.
            existing := AhkStdlibEnumFindMemberByValue(this.AhkStdlibEnumMembers, row.Value)
            if existing != "" {
                this.AhkStdlibEnumMemberMap[row.Name] := existing
                this.DefineProp(row.Name, { Value: existing })
                this.AhkStdlibEnumAliases.Push([row.Name, existing.name])
                continue
            }
            member := AhkStdlibEnumMember(this, row.Name, row.Value, row.Factory)
            this.AhkStdlibEnumMemberMap[row.Name] := member
            this.AhkStdlibEnumMembers.Push(member)
            this.AhkStdlibEnumAllMembers.Push(member)
            this.DefineProp(row.Name, { Value: member })
        }
        this.__members := AhkStdlibEnumMembersView(this)
    }

    Call(value)
    {
        for member in this.AhkStdlibEnumMembers {
            if AhkStdlibEnumValuesEqual(member.value, value)
                return member
        }
        ; Python: enum class can override _missing_ to handle unknown values.
        if HasMethod(this, "_missing_") {
            try {
                result := this._missing_(value)
                if IsObject(result) && (result is AhkStdlibEnumMember)
                    return result
            } catch {
            }
        }
        throw ValueError(AhkStdlibEnumReprValue(value) " is not a valid " this.__name, -1)
    }

    __Item[name]
    {
        get {
            if this.AhkStdlibEnumMemberMap.Has(name)
                return this.AhkStdlibEnumMemberMap[name]
            throw KeyError("'" name "'", -1)
        }
    }

    __Enum(numberOfVars)
    {
        return this.AhkStdlibEnumMembers.__Enum(numberOfVars)
    }

    ToString()
    {
        return "<enum '" this.__name "'>"
    }

    __Repr()
    {
        return this.ToString()
    }
}

class AhkStdlibEnumMember
{
    __New(enumType, name, value, factory)
    {
        this.__class := enumType
        this.name := name
        this.value := value
        this._value_factory := factory
    }

    ToString()
    {
        return this.__class.__name "." this.name
    }

    __Repr()
    {
        return "<" this.__class.__name "." this.name ": " AhkStdlibEnumReprValue(this.value) ">"
    }
}

class AhkStdlibEnumMembersView
{
    __New(enumType)
    {
        this.AhkStdlibEnumType := enumType
    }

    Has(name)
    {
        return this.AhkStdlibEnumType.AhkStdlibEnumMemberMap.Has(name)
    }

    __Item[name]
    {
        get => this.AhkStdlibEnumType.AhkStdlibEnumMemberMap[name]
    }

    __Enum(numberOfVars)
    {
        members := this.AhkStdlibEnumType.AhkStdlibEnumMembers
        index := 0
        if numberOfVars = 1 {
            return (&value) => (
                index += 1,
                index <= members.Length ? (value := members[index].name, true) : false
            )
        }
        return (&name, &value) => (
            index += 1,
            index <= members.Length ? (name := members[index].name, value := members[index], true) : false
        )
    }
}

stdlib.enum := AhkStdlibEnumModule

AhkStdlibEnumBuildType(kind, args*)
{
    if args.Length = 0
        throw TypeError("EnumMeta.__call__() missing 1 required positional argument: 'value'", -1)
    if args.Length = 1
        throw ValueError("'" args[1] "' is not a valid " kind, -1)
    if args.Length > 3
        throw TypeError(kind "() takes from 2 to 3 positional arguments but " args.Length " were given", -1)

    name := args[1]
    members := args[2]
    options := args.Length >= 3 ? args[3] : unset

    if !(name is String)
        throw TypeError("name must be a string", -1)

    start := 1
    if IsSet(options) {
        if Type(options) != "Object"
            throw TypeError("'" AhkStdlibPythonTypeName(options) "' object is not iterable", -1)
        for optionName, optionValue in options.OwnProps() {
            switch optionName {
                case "start":
                    start := optionValue
                default:
                    throw TypeError(kind "() got an unexpected keyword argument '" optionName "'", -1)
            }
        }
    }

    rows := AhkStdlibEnumNormalizeMembers(members, start)
    return AhkStdlibEnumType(kind, name, rows)
}

AhkStdlibEnumNormalizeMembers(members, start)
{
    if members is String
        return AhkStdlibEnumNormalizeNameList(AhkStdlibEnumParseMemberText(members), start)

    if members is Map
        return AhkStdlibEnumNormalizeNameValueMap(AhkStdlibEnumPairsFromMap(members), start)

    if members is Array
        return AhkStdlibEnumNormalizeArrayMembers(members, start)

    if Type(members) = "Object"
        return AhkStdlibEnumNormalizeNameValueMap(AhkStdlibEnumPairsFromObject(members), start)

    if IsObject(members) && HasMethod(members, "__Enum")
        return AhkStdlibEnumNormalizeArrayMembers(AhkStdlibEnumMaterializeEnumerable(members), start)

    throw TypeError("'" AhkStdlibPythonTypeName(members) "' object is not iterable", -1)
}

AhkStdlibEnumParseMemberText(text)
{
    names := []
    normalized := StrReplace(text, ",", " ")
    for token in StrSplit(normalized, " ") {
        token := Trim(token)
        if token != ""
            names.Push(token)
    }
    return names
}

AhkStdlibEnumNormalizeNameList(names, start)
{
    rows := []
    nextValue := start
    for name in names {
        rows.Push({ Name: name, Value: nextValue, Factory: stdlib.None })
        nextValue := AhkStdlibEnumNextValue(nextValue)
    }
    return rows
}

AhkStdlibEnumNormalizeNameValueMap(pairs, start)
{
    rows := []
    nextValue := start
    for pair in pairs {
        name := pair[1]
        value := pair[2]
        factory := stdlib.None
        if value is AhkStdlibEnumAutoValue {
            factory := value
            value := nextValue
            nextValue := AhkStdlibEnumNextValue(nextValue)
        } else {
            nextValue := AhkStdlibEnumNextValue(value)
        }
        rows.Push({ Name: name, Value: value, Factory: factory })
    }
    return rows
}

AhkStdlibEnumNormalizeArrayMembers(values, start)
{
    if AhkStdlibEnumArrayIsPairList(values)
        return AhkStdlibEnumNormalizeNameValueMap(values, start)
    return AhkStdlibEnumNormalizeNameList(values, start)
}

AhkStdlibEnumArrayIsPairList(values)
{
    if values.Length = 0
        return false
    for item in values {
        if !(item is Array) || item.Length != 2
            return false
    }
    return true
}

AhkStdlibEnumMaterializeEnumerable(iterable)
{
    values := []
    for value in iterable
        values.Push(value)
    return values
}

AhkStdlibEnumPairsFromMap(members)
{
    pairs := []
    for name, value in members
        pairs.InsertAt(1, [name, value])
    return pairs
}

AhkStdlibEnumPairsFromObject(members)
{
    pairs := []
    for name, value in members.OwnProps()
        pairs.InsertAt(1, [name, value])
    return pairs
}

AhkStdlibEnumValuesEqual(left, right)
{
    if IsObject(left) || IsObject(right)
        return !(left !== right)
    return left == right
}

AhkStdlibEnumFindMemberByValue(members, value)
{
    for member in members {
        if AhkStdlibEnumValuesEqual(member.value, value)
            return member
    }
    return ""
}

AhkStdlibEnumNextValue(value)
{
    return value + 1
}

AhkStdlibEnumReprValue(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if value is String
        return value
    return String(value)
}

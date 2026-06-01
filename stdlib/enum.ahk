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
        this.__kind__ := kind
        this.__name__ := name
        this.AhkStdlibEnumMemberMap := Map()
        this.AhkStdlibEnumMembers := []

        for row in memberRows {
            member := AhkStdlibEnumMember(this, row.Name, row.Value, row.Factory)
            this.AhkStdlibEnumMemberMap[row.Name] := member
            this.AhkStdlibEnumMembers.Push(member)
            this.DefineProp(row.Name, { Value: member })
        }
        this.__members__ := AhkStdlibEnumMembersView(this)
    }

    Call(value)
    {
        for member in this.AhkStdlibEnumMembers {
            if AhkStdlibEnumValuesEqual(member.value, value)
                return member
        }
        throw ValueError(AhkStdlibEnumReprValue(value) " is not a valid " this.__name__, -1)
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
        return "<enum '" this.__name__ "'>"
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
        this.__class__ := enumType
        this.name := name
        this.value := value
        this._value_factory := factory
    }

    ToString()
    {
        return this.__class__.__name__ "." this.name
    }

    __Repr()
    {
        return "<" this.__class__.__name__ "." this.name ": " AhkStdlibEnumReprValue(this.value) ">"
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

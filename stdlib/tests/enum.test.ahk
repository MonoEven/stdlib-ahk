#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\enum>

class StdlibEnumTest
{
    static TestFunctionalEnumApiMatchesObservedLocal310Surface()
    {
        Color := stdlib.enum.Enum("Color", "RED GREEN BLUE")
        Listed := stdlib.enum.Enum("Listed", ["RED", "GREEN", "BLUE"], { start: 5 })
        Ordered := stdlib.enum.Enum("Ordered", [["LOW", 10], ["HIGH", 20]])
        AutoColor := stdlib.enum.Enum("AutoColor", [["RED", stdlib.enum.auto()], ["GREEN", stdlib.enum.auto()]])

        AhkTest.AssertEqual("Color", Color.__name)
        AhkTest.AssertEqual("Color", Color.RED.__class.__name)
        AhkTest.AssertFalse(HasProp(Color, "__name__"))
        AhkTest.AssertFalse(HasProp(Color, "__members__"))
        AhkTest.AssertFalse(HasProp(Color.RED, "__class__"))
        AhkTest.AssertEqual("RED", Color.RED.name)
        AhkTest.AssertEqual(1, Color.RED.value)
        AhkTest.AssertEqual("Color.RED", String(Color.RED))
        AhkTest.AssertEqual("<Color.RED: 1>", Color.RED.__Repr())
        AhkTest.AssertSame(Color.GREEN, Color["GREEN"])
        AhkTest.AssertSame(Color.GREEN, Color(2))
        AhkTest.AssertEqual(["RED", "GREEN", "BLUE"], StdlibEnumTest.MemberNames(Color))
        AhkTest.AssertEqual([1, 2, 3], StdlibEnumTest.MemberValues(Color))
        AhkTest.AssertEqual([5, 6, 7], StdlibEnumTest.MemberValues(Listed))
        AhkTest.AssertEqual(["LOW", "HIGH"], StdlibEnumTest.MemberNames(Ordered))
        AhkTest.AssertEqual([10, 20], StdlibEnumTest.MemberValues(Ordered))
        AhkTest.AssertEqual([1, 2], StdlibEnumTest.MemberValues(AutoColor))
        AhkTest.AssertEqual("<auto>", AutoColor.RED._value_factory.__Repr())
    }

    static TestObservedEnumErrorsMatchLocal310()
    {
        Color := stdlib.enum.Enum("Color", "RED GREEN BLUE")

        AhkTest.RaisesMatch(TypeError, "^EnumMeta\.__call__\(\) missing 1 required positional argument: 'value'$", (*) => stdlib.enum.Enum())
        AhkTest.RaisesMatch(TypeError, "^auto\(\) takes no arguments$", (*) => stdlib.enum.auto(1))
        AhkTest.RaisesMatch(ValueError, "^4 is not a valid Color$", (*) => Color(4))
        AhkTest.RaisesMatch(KeyError, "^'MISSING'$", (*) => Color["MISSING"])
        AhkTest.RaisesMatch(TypeError, "^Enum\(\) got an unexpected keyword argument 'bad'$", (*) => stdlib.enum.Enum("Color", "RED GREEN BLUE", { bad: 1 }))
        AhkTest.RaisesMatch(TypeError, "^'int' object is not iterable$", (*) => stdlib.enum.Enum("Color", 1))
        AhkTest.RaisesMatch(ValueError, "^'Color' is not a valid Enum$", (*) => stdlib.enum.Enum("Color"))
    }

    static TestIntEnumBuildsWithIntegerValues()
    {
        Priority := stdlib.enum.IntEnum("Priority", [["LOW", 1], ["HIGH", 10]])
        AhkTest.AssertEqual("IntEnum", Priority.__kind)
        AhkTest.AssertEqual(1, Priority.LOW.value)
        AhkTest.AssertEqual(10, Priority.HIGH.value)
        AhkTest.AssertSame(Priority.HIGH, Priority(10))
        ; IntEnum repr still names the member like Python.
        AhkTest.AssertEqual("Priority.LOW", String(Priority.LOW))
    }

    static TestFlagAndIntFlagBuild()
    {
        Perm := stdlib.enum.Flag("Perm", [["R", 1], ["W", 2], ["X", 4]])
        AhkTest.AssertEqual("Flag", Perm.__kind)
        AhkTest.AssertEqual(1, Perm.R.value)
        AhkTest.AssertEqual(4, Perm.X.value)

        Mode := stdlib.enum.IntFlag("Mode", [["A", 1], ["B", 2]])
        AhkTest.AssertEqual("IntFlag", Mode.__kind)
        AhkTest.AssertEqual(2, Mode.B.value)
    }

    static TestUniqueDecoratorRaisesOnAliases()
    {
        ; No duplicates: returns the same enum unchanged.
        Clean := stdlib.enum.Enum("Clean", [["A", 1], ["B", 2]])
        AhkTest.AssertSame(Clean, stdlib.enum.unique(Clean))

        ; Duplicate values are aliases and must raise under @unique.
        Dup := stdlib.enum.Enum("Dup", [["A", 1], ["B", 1]])
        AhkTest.RaisesMatch(ValueError, "duplicate values found", (*) => stdlib.enum.unique(Dup))
    }

    static TestEnumAliasesShareMemberObject()
    {
        ; Defining two names with the same value creates an alias: the second
        ; name maps to the same member as the first (Python enum behavior).
        Aliased := stdlib.enum.Enum("Aliased", [["A", 1], ["B", 1], ["C", 2]])
        AhkTest.AssertSame(Aliased.A, Aliased.B)
        ; Iteration excludes aliases.
        canonical := []
        for member in Aliased
            canonical.Push(member.name)
        AhkTest.AssertEqual(["A", "C"], canonical)
        ; Lookup-by-value finds the canonical member.
        AhkTest.AssertSame(Aliased.A, Aliased(1))
    }

    static MemberNames(enumType)
    {
        names := []
        for name, value in enumType.__members
            names.Push(name)
        return names
    }

    static MemberValues(enumType)
    {
        values := []
        for item in enumType
            values.Push(item.value)
        return values
    }
}

; --- Class-syntax enums (Python's `class Color(Enum)`) ---
; Members declared via the member()/auto() factories so static __New can recover
; definition order. The class itself becomes the enum type.

class ClassColor extends AhkStdlibEnum
{
    static RED := AhkStdlibEnum.member(1)
    static GREEN := AhkStdlibEnum.member(2)
    static BLUE := AhkStdlibEnum.member(3)
}

class ClassAuto extends AhkStdlibEnum
{
    static ALPHA := AhkStdlibEnum.auto()
    static BETA := AhkStdlibEnum.auto()
    static GAMMA := AhkStdlibEnum.auto()
}

class ClassMixed extends AhkStdlibEnum
{
    static A := AhkStdlibEnum.member(10)
    static B := AhkStdlibEnum.auto()
    static C := AhkStdlibEnum.auto()
}

class ClassPriority extends AhkStdlibIntEnum
{
    static LOW := AhkStdlibIntEnum.member(1)
    static HIGH := AhkStdlibIntEnum.member(10)
}

class ClassPerm extends AhkStdlibFlag
{
    static R := AhkStdlibFlag.auto()
    static W := AhkStdlibFlag.auto()
    static X := AhkStdlibFlag.auto()
    static D := AhkStdlibFlag.auto()
}

class ClassAliased extends AhkStdlibEnum
{
    static A := AhkStdlibEnum.member(1)
    static B := AhkStdlibEnum.member(1)
    static C := AhkStdlibEnum.member(2)
}

class ClassCustomGen extends AhkStdlibEnum
{
    static _generate_next_value_(name, start, count, last_values)
    {
        return StrLower(name)
    }
    static RED := AhkStdlibEnum.auto()
    static GREEN := AhkStdlibEnum.auto()
}

class StdlibEnumClassSyntaxTest
{
    static TestClassSyntaxPreservesDefinitionOrderAndValues()
    {
        ; Iteration follows definition order (not alphabetical), values explicit.
        names := []
        values := []
        for m in ClassColor {
            names.Push(m.name)
            values.Push(m.value)
        }
        AhkTest.AssertEqual(["RED", "GREEN", "BLUE"], names)
        AhkTest.AssertEqual([1, 2, 3], values)
        ; Member objects carry name/value and a class-qualified repr.
        AhkTest.AssertEqual("RED", ClassColor.RED.name)
        AhkTest.AssertEqual(1, ClassColor.RED.value)
        AhkTest.AssertEqual("ClassColor.RED", String(ClassColor.RED))
        AhkTest.AssertEqual("<ClassColor.RED: 1>", ClassColor.RED.__Repr())
        AhkTest.AssertEqual("ClassColor", ClassColor.__name)
    }

    static TestClassSyntaxValueAndNameLookup()
    {
        AhkTest.AssertSame(ClassColor.GREEN, ClassColor(2))
        AhkTest.AssertSame(ClassColor.BLUE, ClassColor["BLUE"])
        AhkTest.RaisesMatch(ValueError, "^99 is not a valid ClassColor$", (*) => ClassColor(99))
        AhkTest.RaisesMatch(KeyError, "^'NOPE'$", (*) => ClassColor["NOPE"])
    }

    static TestClassSyntaxAutoNumbersFromOne()
    {
        AhkTest.AssertEqual([1, 2, 3], StdlibEnumClassSyntaxTest.Values(ClassAuto))
        AhkTest.AssertEqual("<auto>", ClassAuto.ALPHA._value_factory.__Repr())
    }

    static TestClassSyntaxMixedExplicitThenAuto()
    {
        ; auto() continues from the last explicit value (10 -> 11 -> 12).
        AhkTest.AssertEqual([10, 11, 12], StdlibEnumClassSyntaxTest.Values(ClassMixed))
    }

    static TestClassSyntaxIntEnumKind()
    {
        AhkTest.AssertEqual("IntEnum", ClassPriority.__kind)
        AhkTest.AssertEqual(10, ClassPriority.HIGH.value)
        AhkTest.AssertSame(ClassPriority.HIGH, ClassPriority(10))
    }

    static TestClassSyntaxFlagAutoUsesPowersOfTwo()
    {
        AhkTest.AssertEqual("Flag", ClassPerm.__kind)
        AhkTest.AssertEqual([1, 2, 4, 8], StdlibEnumClassSyntaxTest.Values(ClassPerm))
    }

    static TestClassSyntaxAliasesShareMemberAndExcludeFromIteration()
    {
        AhkTest.AssertSame(ClassAliased.A, ClassAliased.B)
        names := []
        for m in ClassAliased
            names.Push(m.name)
        AhkTest.AssertEqual(["A", "C"], names)
        AhkTest.AssertSame(ClassAliased.A, ClassAliased(1))
    }

    static TestClassSyntaxGenerateNextValueOverride()
    {
        ; A user-defined _generate_next_value_ controls auto() values.
        AhkTest.AssertEqual("red", ClassCustomGen.RED.value)
        AhkTest.AssertEqual("green", ClassCustomGen.GREEN.value)
    }

    static Values(enumType)
    {
        out := []
        for m in enumType
            out.Push(m.value)
        return out
    }
}

AhkTest.Collect(StdlibEnumClassSyntaxTest)

AhkTest.Collect(StdlibEnumTest)

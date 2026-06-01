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

        AhkTest.AssertEqual("Color", Color.__name__)
        AhkTest.AssertEqual("Color", Color.RED.__class__.__name__)
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

    static MemberNames(enumType)
    {
        names := []
        for name, value in enumType.__members__
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

AhkTest.Collect(StdlibEnumTest)

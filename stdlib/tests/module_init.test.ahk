#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\assert>
#Include <stdlib\base>
#Include <stdlib\types>
#Include <stdlib\os>
#Include <stdlib\comparser>
#Include <stdlib\json>
#Include <stdlib\toml>

class StdlibModuleInitTest
{
    static TestExplicitModuleIncludeLoadsRootNamespace()
    {
        data := stdlib.toml.loads("name = `"stdlib`"`n[features]`nmodule_init = true")

        AhkTest.AssertEqual("stdlib", data["name"])
        AhkTest.AssertTrue(data["features"]["module_init"])
    }

    static TestModuleIncludesDoNotClearExistingNamespaceMounts()
    {
        AhkTest.AssertTrue(HasProp(stdlib, "assert"))
        AhkTest.AssertTrue(HasProp(stdlib, "base"))
        AhkTest.AssertTrue(HasProp(stdlib, "types"))
        AhkTest.AssertTrue(HasProp(stdlib, "comparser"))
        AhkTest.AssertTrue(HasProp(stdlib, "json"))
        AhkTest.AssertTrue(HasProp(stdlib, "toml"))
        AhkTest.AssertTrue(HasMethod(stdlib.os, "system"))

        AhkTest.AssertSame(stdlib.json.Null, stdlib.json.loads("null"))
        AhkTest.AssertEqual("stdlib", stdlib.toml.loads("name = `"stdlib`"")["name"])
        AhkTest.AssertEqual("stdlib", stdlib.comparser.loads("name = stdlib")["name"])
    }
}

AhkTest.Collect(StdlibModuleInitTest)

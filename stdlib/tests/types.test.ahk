#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\types>

class StdlibTypesTest
{
    static TestFunctionTypeAliasesMatchAhkCallableTypes()
    {
        AhkTest.AssertSame(stdlib.types.FunctionType, stdlib.types.LambdaType)
        AhkTest.AssertEqual("Class", Type(stdlib.types.FunctionType))
        AhkTest.AssertTrue((() => 1) is stdlib.types.FunctionType)
        AhkTest.AssertTrue(StrLen is stdlib.types.BuiltinFunctionType)
    }

    static TestSimpleNamespaceStoresProperties()
    {
        namespace := stdlib.types.SimpleNamespace(Map("x", 1, "name", "Ada"))

        AhkTest.AssertEqual(1, namespace.x)
        AhkTest.AssertEqual("Ada", namespace.name)
        namespace.name := "Grace"
        AhkTest.AssertEqual("Grace", namespace.name)
    }

    static TestSimpleNamespaceEqualityComparesOwnedProperties()
    {
        left := stdlib.types.SimpleNamespace(Map("x", 1, "name", "Ada"))
        same := stdlib.types.SimpleNamespace(Map("name", "Ada", "x", 1))
        different := stdlib.types.SimpleNamespace(Map("x", 2, "name", "Ada"))

        AhkTest.AssertTrue(left.Equals(same))
        AhkTest.AssertFalse(left.Equals(different))
        AhkTest.AssertFalse(left.Equals({ x: 1, name: "Ada" }))
    }

    static TestModuleTypeStoresNameAndDoc()
    {
        module := stdlib.types.ModuleType("demo", "module docs")

        AhkTest.AssertEqual("demo", module.__name)
        AhkTest.AssertEqual("module docs", module.__doc)
        AhkTest.AssertFalse(HasProp(module, "__name__"))
        AhkTest.AssertFalse(HasProp(module, "__doc__"))
    }
}

AhkTest.Collect(StdlibTypesTest)

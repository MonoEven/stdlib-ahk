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

    static TestMappingProxyReadsThroughToMapping()
    {
        backing := Map("x", 1, "y", 2)
        proxy := stdlib.types.MappingProxyType(backing)

        AhkTest.AssertEqual(1, proxy["x"])
        AhkTest.AssertEqual(2, proxy.Count)
        AhkTest.AssertTrue(proxy.Has("y"))
        AhkTest.AssertFalse(proxy.Has("z"))
        AhkTest.AssertEqual(99, proxy.get("z", 99))

        ; Reflects later mutations of the backing mapping.
        backing["z"] := 3
        AhkTest.AssertEqual(3, proxy["z"])
        AhkTest.AssertEqual(3, proxy.Count)
    }

    static TestMappingProxyRejectsWritesAndNonMapping()
    {
        proxy := stdlib.types.MappingProxyType(Map("a", 1))
        AhkTest.RaisesMatch(TypeError, "'mappingproxy' object does not support item assignment", (*) => proxy["a"] := 2)
        AhkTest.RaisesMatch(KeyError, "'missing'", (*) => proxy["missing"])
        AhkTest.RaisesMatch(TypeError, "mappingproxy\(\) argument must be a mapping", (*) => stdlib.types.MappingProxyType([1, 2]))
    }

    static TestMappingProxyCopyReturnsPlainMap()
    {
        proxy := stdlib.types.MappingProxyType(Map("a", 1, "b", 2))
        copied := proxy.copy()
        AhkTest.AssertEqual("Map", Type(copied))
        copied["c"] := 3
        AhkTest.AssertFalse(proxy.Has("c"))
    }

    static TestCoroutineAndGeneratorTypeProtocols()
    {
        ; CoroutineType matches asyncio-style coroutines (asyncio step hook).
        coroutine := StdlibTypesCoroutineProbe()
        AhkTest.AssertTrue(stdlib.types.CoroutineType.isinstance(coroutine))
        AhkTest.AssertFalse(stdlib.types.CoroutineType.isinstance((*) => 1))
        AhkTest.AssertFalse(stdlib.types.CoroutineType.isinstance(5))
        ; GeneratorType matches nothing (AHK has no generators).
        AhkTest.AssertFalse(stdlib.types.GeneratorType.isinstance(coroutine))
        AhkTest.AssertFalse(stdlib.types.GeneratorType.isinstance([1, 2]))
        AhkTest.AssertFalse(stdlib.types.GeneratorType.isinstance(5))
    }
}

class StdlibTypesCoroutineProbe
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        return "done"
    }
}

AhkTest.Collect(StdlibTypesTest)

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

    static TestGenericAliasReprAndIntrospection()
    {
        ; types.GenericAlias(Array, [Integer, String]) mirrors list[int, str].
        alias := stdlib.types.GenericAlias(Array, [Integer, String])
        AhkTest.AssertEqual("Array[Integer, String]", alias.__Repr())
        AhkTest.AssertSame(Array, alias.__origin__)
        AhkTest.AssertEqual(2, alias.__args__.Length)
        AhkTest.AssertSame(Integer, alias.__args__[1])
        AhkTest.AssertSame(String, alias.__args__[2])
        AhkTest.AssertEqual(0, alias.__parameters__.Length)

        ; Single (non-array) arg is normalized to a one-element tuple.
        single := stdlib.types.GenericAlias(Array, Integer)
        AhkTest.AssertEqual("Array[Integer]", single.__Repr())
        AhkTest.AssertEqual(1, single.__args__.Length)

        ; Nested alias reprs recursively, like list[dict[str, int]].
        nested := stdlib.types.GenericAlias(Array, stdlib.types.GenericAlias(Map, [String, Integer]))
        AhkTest.AssertEqual("Array[Map[String, Integer]]", nested.__Repr())

        ; isinstance checks the origin only (parameters not enforced at runtime).
        AhkTest.AssertTrue(alias.isinstance([1, 2]))
        AhkTest.AssertFalse(alias.isinstance("not a list"))
    }

    static TestUnionTypeBuilderAndMembership()
    {
        ; Stand-in for `Integer | String` (AHK can't overload `|` on classes).
        union := stdlib.types.Union(Integer, String)
        AhkTest.AssertEqual("Integer | String", union.__Repr())
        AhkTest.AssertEqual(2, union.__args__.Length)

        ; isinstance matches any member.
        AhkTest.AssertTrue(union.isinstance(5))
        AhkTest.AssertTrue(union.isinstance("text"))
        AhkTest.AssertFalse(union.isinstance([1, 2]))

        ; UnionType marker recognizes union values and rejects construction.
        AhkTest.AssertTrue(stdlib.types.UnionType.isinstance(union))
        AhkTest.AssertFalse(stdlib.types.UnionType.isinstance(Integer))
        AhkTest.RaisesMatch(TypeError, "cannot create 'types.UnionType' instances", (*) => stdlib.types.UnionType(Integer, String))
    }

    static TestUnionFlattensDedupesAndIncludesNone()
    {
        ; Nested unions flatten and duplicates collapse, like CPython's `|`.
        base := stdlib.types.Union(Integer, String)
        merged := stdlib.types.Union(base, Float)
        AhkTest.AssertEqual("Integer | String | Float", merged.__Repr())
        AhkTest.AssertEqual(3, merged.__args__.Length)

        deduped := stdlib.types.Union(Integer, Integer, String)
        AhkTest.AssertEqual("Integer | String", deduped.__Repr())

        ; None member shows as None and matches the None singleton (int | None).
        optional := stdlib.types.Union(Integer, stdlib.None)
        AhkTest.AssertEqual("Integer | None", optional.__Repr())
        AhkTest.AssertTrue(optional.isinstance(5))
        AhkTest.AssertTrue(optional.isinstance(stdlib.None))
        AhkTest.AssertFalse(optional.isinstance("text"))

        AhkTest.RaisesMatch(TypeError, "a union requires at least two members", (*) => stdlib.types.Union(Integer))
    }

    static TestNewClassSynthesizesClassWithMembers()
    {
        ; Body callback populates a namespace; callables become methods, other
        ; values become class attributes (mirrors CPython exec_body(ns)).
        body := (ns) => (
            ns["CONST"] := 42,
            ns["greet"] := (self) => "hi",
            ns["__New"] := (self, label) => (self.label := label)
        )
        Widget := stdlib.types.new_class("Widget", , , body)

        ; Class attribute.
        AhkTest.AssertEqual(42, Widget.CONST)
        ; Instantiation runs the custom __New.
        w := Widget("ok")
        AhkTest.AssertEqual("ok", w.label)
        AhkTest.AssertEqual("hi", w.greet())
        AhkTest.AssertTrue(w is Widget)
    }

    static TestNewClassInheritsFromBase()
    {
        D := stdlib.types.new_class("Derived", [StdlibTypesNewClassBase], , (ns) => (ns["d"] := 1))
        inst := D()
        AhkTest.AssertEqual("base", inst.base_method())
        AhkTest.AssertEqual(1, D.d)
        AhkTest.AssertTrue(inst is D)
        AhkTest.AssertTrue(inst is StdlibTypesNewClassBase)
    }

    static TestNewClassRejectsBadArgs()
    {
        AhkTest.RaisesMatch(TypeError, "new_class\(\) bases must be classes", (*) => stdlib.types.new_class("X", [5]))
        AhkTest.RaisesMatch(TypeError, "exec_body must be callable", (*) => stdlib.types.new_class("X", , , 7))
    }

    static TestPrepareClassReturnsMetaclassNamespaceKwds()
    {
        result := stdlib.types.prepare_class("E")
        AhkTest.AssertEqual(3, result.Length)
        AhkTest.AssertSame(Class, result[1])      ; metaclass (AHK's `type` analog)
        AhkTest.AssertEqual("Map", Type(result[2]))  ; empty namespace
        AhkTest.AssertEqual(0, result[2].Count)
        AhkTest.AssertEqual("Map", Type(result[3]))  ; kwds
    }
}

class StdlibTypesCoroutineProbe
{
    AhkStdlibAsyncioStep(task, value := unset)
    {
        return "done"
    }
}

class StdlibTypesNewClassBase
{
    base_method() => "base"
}

AhkTest.Collect(StdlibTypesTest)

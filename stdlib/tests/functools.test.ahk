#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\base>
#Include <stdlib\functools>

class StdlibFunctoolsTest
{
    static callCount := 0

    class DemoCallableSource
    {
    }

    class DemoIterableSource
    {
    }

    class DemoBoundValue
    {
    }

    static TestReduceCombinesValuesFromTheLeft()
    {
        result := stdlib.functools.reduce(stdlib_functools_test_add, [1, 2, 3, 4])

        AhkTest.AssertEqual(10, result)
    }

    static TestReduceUsesInitializerAndRejectsEmptyWithoutIt()
    {
        AhkTest.AssertEqual(16, stdlib.functools.reduce(stdlib_functools_test_add, [1, 2, 3], 10))
        AhkTest.AssertEqual(10, stdlib.functools.reduce(stdlib_functools_test_add, [], 10))
        AhkTest.RaisesMatch(TypeError, "reduce\(\) of empty iterable with no initial value", (*) => stdlib.functools.reduce(stdlib_functools_test_add, []))
    }

    static TestReduceRejectsNonCallableArgumentWithPythonTypeNames()
    {
        AhkTest.RaisesMatch(TypeError, "'int' object is not callable", (*) => stdlib.functools.reduce(42, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'object' object is not callable", (*) => stdlib.functools.reduce({}, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not callable", (*) => stdlib.functools.reduce(stdlib.True, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'bool' object is not callable", (*) => stdlib.functools.reduce(stdlib.False, [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'tuple' object is not callable", (*) => stdlib.functools.reduce(stdlib.tuple(), [1, 2]))
        AhkTest.RaisesMatch(TypeError, "'DemoCallableSource' object is not callable", (*) => stdlib.functools.reduce(StdlibFunctoolsTest.DemoCallableSource(), [1, 2]))
    }

    static TestReduceRejectsNonIterableSecondArgumentWithDedicatedPythonMessage()
    {
        AhkTest.RaisesMatch(TypeError, "reduce\(\) arg 2 must support iteration", (*) => stdlib.functools.reduce(stdlib_functools_test_add, 42))
        AhkTest.RaisesMatch(TypeError, "reduce\(\) arg 2 must support iteration", (*) => stdlib.functools.reduce(stdlib_functools_test_add, {}))
        AhkTest.RaisesMatch(TypeError, "reduce\(\) arg 2 must support iteration", (*) => stdlib.functools.reduce(stdlib_functools_test_add, StdlibFunctoolsTest.DemoIterableSource()))
    }

    static TestPartialPrependsBoundArguments()
    {
        addTwo := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.AssertEqual(5, addTwo.Call(3))
    }

    static TestPartialExposesPython310Metadata()
    {
        addTwo := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.AssertSame(stdlib_functools_test_add, addTwo.func)
        AhkTest.AssertEqual([2], addTwo.args)
        AhkTest.AssertTrue(addTwo.keywords is Map)
        AhkTest.AssertEqual(0, addTwo.keywords.Count)

        addThree := stdlib.functools.partial(addTwo, 3)

        AhkTest.AssertSame(stdlib_functools_test_add, addThree.func)
        AhkTest.AssertEqual([2, 3], addThree.args)
        AhkTest.AssertEqual(5, addThree.Call())
    }

    static TestPartialExposesDefaultModuleAndDocLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.AssertEqual("functools", partial.__module)
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc)
        AhkTest.AssertFalse(HasProp(partial, "__module__"))
        AhkTest.AssertFalse(HasProp(partial, "__doc__"))
    }

    static TestPartialExposesStableEmptyDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)
        dict := partial.__dict

        AhkTest.AssertTrue(dict is Map)
        AhkTest.AssertEqual(0, dict.Count)
        AhkTest.AssertSame(dict, partial.__dict)
        AhkTest.AssertFalse(HasProp(partial, "__dict__"))
    }

    static TestPartialDynamicAttributesUpdateDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.custom := 42

        AhkTest.AssertEqual(42, partial.custom)
        AhkTest.AssertTrue(partial.__dict.Has("custom"))
        AhkTest.AssertEqual(42, partial.__dict["custom"])
        AhkTest.AssertSame(partial.__dict, partial.__dict)
    }

    static TestPartialDynamicAttributesDeleteFromDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.custom := 42
        removed := stdlib.base.delattr(partial, "custom")

        AhkTest.AssertEqual(42, removed)
        AhkTest.AssertFalse(partial.__dict.Has("custom"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^'functools\.partial' object has no attribute 'custom'$", (*) => partial.custom)
        AhkTest.RaisesMatch(stdlib.AttributeError, "^custom$", (*) => stdlib.base.delattr(partial, "custom"))
    }

    static TestPartialModuleDocAndDictSupportObservedAssignmentSemanticsLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)
        replacementDict := Map("x", 1)

        partial.__module := "custom_module"
        partial.__doc := "custom doc"
        AhkTest.AssertEqual("custom_module", partial.__module)
        AhkTest.AssertEqual("custom doc", partial.__doc)
        AhkTest.AssertEqual("custom_module", partial.__dict["__module"])
        AhkTest.AssertEqual("custom doc", partial.__dict["__doc"])

        partial.__dict := replacementDict

        AhkTest.AssertEqual("functools", partial.__module)
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc)
        AhkTest.AssertSame(replacementDict, partial.__dict)
        AhkTest.AssertEqual(1, partial.__dict["x"])
    }

    static TestPartialDictAssignmentRejectsNonDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'int'", (*) => partial.__dict := 5)
        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'list'", (*) => partial.__dict := [])
        AhkTest.RaisesMatch(TypeError, "__dict must be set to a dictionary, not a 'NoneType'", (*) => partial.__dict := stdlib.None)
    }

    static TestPartialModuleDocAndDictDeletionMatchPython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.__module := "custom_module"
        partial.__doc := "custom doc"

        AhkTest.AssertEqual("custom_module", stdlib.base.delattr(partial, "__module"))
        AhkTest.AssertEqual("functools", partial.__module)
        AhkTest.AssertEqual("custom doc", stdlib.base.delattr(partial, "__doc"))
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc)
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__module$", (*) => stdlib.base.delattr(partial, "__module"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__doc$", (*) => stdlib.base.delattr(partial, "__doc"))
        AhkTest.RaisesMatch(TypeError, "cannot delete __dict", (*) => stdlib.base.delattr(partial, "__dict"))
    }

    static TestPartialDefaultModuleAndDocDeletionRaiseAttributeErrorLikeLocal310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(stdlib.AttributeError, "^__module$", (*) => stdlib.base.delattr(partial, "__module"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__doc$", (*) => stdlib.base.delattr(partial, "__doc"))
    }

    static TestPartialPreservesArgumentOrderAndRejectsNonCallable()
    {
        prefixHello := stdlib.functools.partial(stdlib_functools_test_join, "hello")

        AhkTest.AssertEqual("hello world", prefixHello.Call("world"))
        AhkTest.RaisesMatch(TypeError, "the first argument must be callable", (*) => stdlib.functools.partial(42))
        AhkTest.RaisesMatch(TypeError, "the first argument must be callable", (*) => stdlib.functools.partial({}))
        AhkTest.RaisesMatch(TypeError, "the first argument must be callable", (*) => stdlib.functools.partial(StdlibFunctoolsTest.DemoCallableSource()))
    }

    static TestPartialRejectsMissingCallableLikePython310()
    {
        AhkTest.RaisesMatch(TypeError, "type 'partial' takes at least one argument", (*) => stdlib.functools.partial())
    }

    static TestPartialFlattensNestedPartialsLikePython()
    {
        addOne := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        addOneTwo := stdlib.functools.partial(addOne, 2)
        wrapped := stdlib.functools.partial(addOne)

        AhkTest.AssertSame(stdlib_functools_test_add_three, addOne.func)
        AhkTest.AssertEqual([1], addOne.args)
        AhkTest.AssertEqual(0, addOne.keywords.Count)
        AhkTest.AssertSame(stdlib_functools_test_add_three, addOneTwo.func)
        AhkTest.AssertEqual([1, 2], addOneTwo.args)
        AhkTest.AssertEqual(0, addOneTwo.keywords.Count)
        AhkTest.AssertEqual(6, addOneTwo.Call(3))
        AhkTest.AssertSame(stdlib_functools_test_add_three, wrapped.func)
        AhkTest.AssertEqual([1], wrapped.args)
        AhkTest.AssertSame(addOne.args, wrapped.args)
        AhkTest.AssertEqual(0, wrapped.keywords.Count)
        AhkTest.AssertEqual(6, wrapped.Call(2, 3))
    }

    static TestPartialMetadataIsReadOnlyLikePython()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => partial.func := stdlib_functools_test_join)
        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => partial.args := [1])
        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => partial.keywords := Map())
    }

    static TestPartialMetadataDeletionIsReadOnlyLikePython()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => stdlib.base.delattr(partial, "func"))
        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => stdlib.base.delattr(partial, "args"))
        AhkTest.RaisesMatch(PropertyError, "readonly attribute", (*) => stdlib.base.delattr(partial, "keywords"))
    }

    static TestPartialArgsDoNotExposeMutableInternalStateLikePython()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        observedArgs := partial.args

        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => observedArgs[1] := 9)
        AhkTest.AssertEqual([1], partial.args)
        AhkTest.AssertEqual(6, partial.Call(2, 3))
    }

    static TestPartialArgsReturnsStableReadonlyTupleLikeMetadata()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        firstArgs := partial.args
        secondArgs := partial.args

        AhkTest.AssertSame(firstArgs, secondArgs)
        AhkTest.AssertEqual([1], firstArgs)
        AhkTest.RaisesMatch(TypeError, "does not support item assignment|readonly", (*) => firstArgs[1] := 9)
        AhkTest.AssertEqual([1], partial.args)
    }

    static TestPartialReprExposesPythonStyleObservableShape()
    {
        addTwo := stdlib.functools.partial(stdlib_functools_test_add, 2)
        addTwoThree := stdlib.functools.partial(addTwo, 3)

        AhkTest.AssertRegex(addTwo.__Repr(), "^functools\.partial\(<function stdlib_functools_test_add at 0x[0-9A-F]+>, 2\)$")
        AhkTest.AssertRegex(addTwoThree.__Repr(), "^functools\.partial\(<function stdlib_functools_test_add at 0x[0-9A-F]+>, 2, 3\)$")
    }

    static TestPartialReprEscapesStringArgumentsLikePython()
    {
        withBackslash := stdlib.functools.partial(stdlib_functools_test_identity, "a\b")
        withSingleQuote := stdlib.functools.partial(stdlib_functools_test_identity, "a'b")
        withDoubleQuote := stdlib.functools.partial(stdlib_functools_test_identity, 'a"b')
        withNewline := stdlib.functools.partial(stdlib_functools_test_identity, "a`nb")
        dq := Chr(34)
        base := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, "
        backslashPattern := base "'a\\\\b'\)$"
        singleQuotePattern := base dq "a'b" dq "\)$"
        doubleQuotePattern := base "'a" dq "b'\)$"
        newlinePattern := base "'a\\nb'\)$"

        AhkTest.AssertRegex(withBackslash.__Repr(), backslashPattern)
        AhkTest.AssertRegex(withSingleQuote.__Repr(), singleQuotePattern)
        AhkTest.AssertRegex(withDoubleQuote.__Repr(), doubleQuotePattern)
        AhkTest.AssertRegex(withNewline.__Repr(), newlinePattern)
    }

    static TestPartialReprUsesPythonLiteralShapeForListDictAndNone()
    {
        withNestedValues := stdlib.functools.partial(stdlib_functools_test_identity, [1, "x"], Map("alpha", 1, "beta", stdlib.None), stdlib.None)
        pattern := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, \[1, 'x'\], \{'alpha': 1, 'beta': None\}, None\)$"

        AhkTest.AssertRegex(withNestedValues.__Repr(), pattern)
    }

    static TestPartialReprUsesPythonBoolLiteralsForRootBoolValues()
    {
        withBools := stdlib.functools.partial(stdlib_functools_test_identity, stdlib.True, stdlib.False)
        withKeyword := stdlib.functools.partial(stdlib_functools_test_identity)
        withKeyword.keywords["flag"] := stdlib.True

        base := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>"
        AhkTest.AssertRegex(withBools.__Repr(), base ", True, False\)$")
        AhkTest.AssertRegex(withKeyword.__Repr(), base ", flag=True\)$")
    }

    static TestPartialReprUsesPythonObjectShapeForCustomBoundValues()
    {
        withObject := stdlib.functools.partial(stdlib_functools_test_identity, StdlibFunctoolsTest.DemoBoundValue())
        pattern := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, <StdlibFunctoolsTest\.DemoBoundValue object at 0x[0-9A-F]+>\)$"

        AhkTest.AssertRegex(withObject.__Repr(), pattern)
    }

    static TestPartialReprUsesTupleShapeForReadonlyArgsMetadata()
    {
        addOne := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        wrappedArgs := stdlib.functools.partial(stdlib_functools_test_identity, addOne.args)
        pattern := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, \(1,\)\)$"

        AhkTest.AssertRegex(wrappedArgs.__Repr(), pattern)
    }

    static TestPartialReprUsesPythonFunctionShapeForBoundFunctionValues()
    {
        withFunction := stdlib.functools.partial(stdlib_functools_test_identity, stdlib_functools_test_identity)
        pattern := "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, <function stdlib_functools_test_identity at 0x[0-9A-F]+>\)$"

        AhkTest.AssertRegex(withFunction.__Repr(), pattern)
    }

    static TestPartialReprShowsObservedKeywordMetadataLikePython()
    {
        withKeywords := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        withKeywords.keywords["c"] := 5
        withNestedKeyword := stdlib.functools.partial(stdlib_functools_test_identity)
        withNestedKeyword.keywords["alpha"] := Map("x", 1)

        AhkTest.AssertRegex(withKeywords.__Repr(), "^functools\.partial\(<function stdlib_functools_test_add_three at 0x[0-9A-F]+>, 1, c=5\)$")
        AhkTest.AssertRegex(withNestedKeyword.__Repr(), "^functools\.partial\(<function stdlib_functools_test_identity at 0x[0-9A-F]+>, alpha=\{'x': 1\}\)$")
    }

    static TestPartialCallUsesMutableKeywordMetadataForTrailingParameters()
    {
        addOne := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        addOne.keywords["c"] := 5
        addOneTwo := stdlib.functools.partial(addOne, 2)

        AhkTest.AssertEqual(8, addOne.Call(2))
        AhkTest.AssertEqual(8, addOneTwo.Call())

        addOne.keywords["c"] := 7

        AhkTest.AssertEqual(10, addOne.Call(2))
        AhkTest.AssertEqual(8, addOneTwo.Call())
    }

    static TestPartialExposesReduceAndSetstateSurfaceLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        reduced := partial.__reduce()
        state := reduced[3]

        AhkTest.AssertTrue(HasMethod(partial, "__reduce"))
        AhkTest.AssertTrue(HasMethod(partial, "__setstate"))
        AhkTest.AssertTrue(reduced is AhkStdlibTuple)
        AhkTest.AssertEqual(3, reduced.Length)
        AhkTest.AssertSame(AhkStdlibFunctoolsPartial, reduced[1])
        AhkTest.AssertEqual([stdlib_functools_test_add_three], reduced[2])
        AhkTest.AssertTrue(state is AhkStdlibTuple)
        AhkTest.AssertEqual(4, state.Length)
        AhkTest.AssertSame(stdlib_functools_test_add_three, state[1])
        AhkTest.AssertEqual([1], state[2])
        AhkTest.AssertTrue(state[3] is Map)
        AhkTest.AssertEqual(0, state[3].Count)
        AhkTest.AssertSame(stdlib.None, state[4])

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), stdlib.None]))
        AhkTest.AssertSame(stdlib_functools_test_add_three, partial.func)
        AhkTest.AssertEqual([1], partial.args)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertTrue(partial.__dict is Map)
        AhkTest.AssertEqual(0, partial.__dict.Count)
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), []]))
        AhkTest.AssertEqual(0, partial.__dict.Length)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), stdlib.tuple()]))
        AhkTest.AssertEqual(0, partial.__dict.Length)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, stdlib.None]))
        AhkTest.AssertTrue(partial.keywords is Map)
        AhkTest.AssertEqual(0, partial.keywords.Count)
        AhkTest.AssertTrue(partial.__dict is Map)
        AhkTest.AssertEqual(0, partial.__dict.Count)
        AhkTest.AssertEqual(8, partial.Call(2, 5))

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, 5]))
        AhkTest.AssertTrue(partial.keywords is Map)
        AhkTest.AssertEqual(0, partial.keywords.Count)
        AhkTest.AssertEqual(5, partial.__dict)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.custom := 42)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.custom)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.DeleteProp("custom"))
        AhkTest.AssertEqual(8, partial.Call(2, 5))
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__reduce())

        AhkTest.RaisesMatch(TypeError, "partial\.__setstate\(\) takes exactly one argument \(0 given\)", (*) => partial.__setstate())
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate(42))
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate(stdlib.tuple([1, 2, 3])))
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, [1], Map(), stdlib.None])))
    }

    static TestPartialMetadataRoundtripsThroughDictStateLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        reduced := ""
        state := ""

        partial.__module := 5
        partial.__doc := 6

        AhkTest.AssertEqual(5, partial.__module)
        AhkTest.AssertEqual(6, partial.__doc)
        AhkTest.AssertTrue(partial.__dict is Map)
        AhkTest.AssertEqual(5, partial.__dict["__module"])
        AhkTest.AssertEqual(6, partial.__dict["__doc"])

        reduced := partial.__reduce()
        state := reduced[3]
        AhkTest.AssertTrue(state[4] is Map)
        AhkTest.AssertEqual(5, state[4]["__module"])
        AhkTest.AssertEqual(6, state[4]["__doc"])

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), Map("__module", 7, "__doc", 8, "x", 9)]))
        AhkTest.AssertEqual(7, partial.__module)
        AhkTest.AssertEqual(8, partial.__doc)
        AhkTest.AssertEqual(9, partial.x)
        AhkTest.AssertEqual(7, partial.__dict["__module"])
        AhkTest.AssertEqual(8, partial.__dict["__doc"])
        AhkTest.AssertEqual(9, partial.__dict["x"])

        partial.__setstate(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, 5]))
        AhkTest.AssertEqual(5, partial.__dict)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__module)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__doc)
    }

    static TestCacheMemoizesUnboundedLikePython310()
    {
        StdlibFunctoolsTest.callCount := 0
        cached := stdlib.functools.cache(stdlib_functools_test_counting_square)

        AhkTest.AssertEqual(9, cached.Call(3))
        AhkTest.AssertEqual(9, cached.Call(3))
        AhkTest.AssertEqual(16, cached.Call(4))

        info := cached.cache_info()
        AhkTest.AssertEqual(1, info.hits)
        AhkTest.AssertEqual(2, info.misses)
        AhkTest.AssertSame(stdlib.None, info.maxsize)
        AhkTest.AssertEqual(2, info.currsize)
        AhkTest.AssertEqual(2, StdlibFunctoolsTest.callCount)
    }

    static TestLruCacheEvictsLeastRecentlyUsedLikePython310()
    {
        StdlibFunctoolsTest.callCount := 0
        cached := stdlib.functools.lru_cache(2).Call(stdlib_functools_test_counting_square)

        AhkTest.AssertEqual(1, cached.Call(1))
        AhkTest.AssertEqual(4, cached.Call(2))
        AhkTest.AssertEqual(1, cached.Call(1))
        AhkTest.AssertEqual(9, cached.Call(3))

        info := cached.cache_info()
        AhkTest.AssertEqual(1, info.hits)
        AhkTest.AssertEqual(3, info.misses)
        AhkTest.AssertEqual(2, info.maxsize)
        AhkTest.AssertEqual(2, info.currsize)

        AhkTest.AssertEqual(4, cached.Call(2))
        AhkTest.AssertEqual(4, cached.cache_info().misses)
    }

    static TestLruCacheBareDecoratorUsesDefaultMaxsize()
    {
        cached := stdlib.functools.lru_cache(stdlib_functools_test_counting_square)
        AhkTest.AssertEqual(25, cached.Call(5))
        AhkTest.AssertEqual(25, cached.Call(5))

        info := cached.cache_info()
        AhkTest.AssertEqual(1, info.hits)
        AhkTest.AssertEqual(1, info.misses)
        AhkTest.AssertEqual(128, info.maxsize)
    }

    static TestLruCacheClearAndParametersMatchPython310()
    {
        cached := stdlib.functools.lru_cache(8, true).Call(stdlib_functools_test_counting_square)
        cached.Call(2)
        cached.Call(2)

        params := cached.cache_parameters()
        AhkTest.AssertEqual(8, params["maxsize"])
        AhkTest.AssertSame(stdlib.True, params["typed"])

        cached.cache_clear()
        info := cached.cache_info()
        AhkTest.AssertEqual(0, info.hits)
        AhkTest.AssertEqual(0, info.misses)
        AhkTest.AssertEqual(0, info.currsize)
    }

    static TestLruCacheTypedSeparatesIntAndFloatKeys()
    {
        ; Two args force the general key path (the single-arg fast path only
        ; applies to ints, so f(3) and f(3.0) would never collide there).
        untyped := stdlib.functools.lru_cache(stdlib.None, false).Call(stdlib_functools_test_add)
        untyped.Call(3, 0)
        untyped.Call(3.0, 0)
        AhkTest.AssertEqual(1, untyped.cache_info().misses)
        AhkTest.AssertEqual(1, untyped.cache_info().hits)

        typed := stdlib.functools.lru_cache(stdlib.None, true).Call(stdlib_functools_test_add)
        typed.Call(3, 0)
        typed.Call(3.0, 0)
        AhkTest.AssertEqual(2, typed.cache_info().misses)
        AhkTest.AssertEqual(0, typed.cache_info().hits)
    }

    static TestCacheInfoReprMatchesPython310()
    {
        cached := stdlib.functools.lru_cache(2).Call(stdlib_functools_test_counting_square)
        cached.Call(1)
        cached.Call(1)

        AhkTest.AssertEqual("CacheInfo(hits=1, misses=1, maxsize=2, currsize=1)", cached.cache_info().__Repr())
        unbounded := stdlib.functools.cache(stdlib_functools_test_counting_square)
        unbounded.Call(1)
        AhkTest.AssertEqual("CacheInfo(hits=0, misses=1, maxsize=None, currsize=1)", unbounded.cache_info().__Repr())
    }

    static TestCmpToKeyProducesOrderingWrappers()
    {
        low := stdlib.functools.cmp_to_key(stdlib_functools_test_reverse_cmp).Call(1)
        high := stdlib.functools.cmp_to_key(stdlib_functools_test_reverse_cmp).Call(2)

        AhkTest.AssertTrue(low.gt(high))
        AhkTest.AssertFalse(low.lt(high))
        AhkTest.AssertTrue(low.ne(high))
        AhkTest.AssertEqual(1, low.obj)
    }

    static TestCmpToKeyRejectsNonCallable()
    {
        AhkTest.RaisesMatch(TypeError, "the first argument must be callable", (*) => stdlib.functools.cmp_to_key(42))
    }

    static TestUpdateWrapperCopiesMetadata()
    {
        wrapped := stdlib_functools_test_add
        wrapper := (a, b) => wrapped(a, b)
        stdlib.functools.update_wrapper(wrapper, wrapped)
        AhkTest.AssertSame(wrapped, wrapper.__wrapped__)
    }

    static TestWrapsReturnsDecoratorCopyingMetadata()
    {
        wrapped := stdlib_functools_test_add
        deco := stdlib.functools.wraps(wrapped)
        wrapper := deco((a, b) => wrapped(a, b))
        AhkTest.AssertSame(wrapped, wrapper.__wrapped__)
    }

    static TestTotalOrderingFillsComparisons()
    {
        stdlib.functools.total_ordering(StdlibFunctoolsOrderingDemo)
        a := StdlibFunctoolsOrderingDemo(1)
        b := StdlibFunctoolsOrderingDemo(2)
        AhkTest.AssertTrue(a.lt(b))
        AhkTest.AssertTrue(a.le(b))
        AhkTest.AssertFalse(a.gt(b))
        AhkTest.AssertFalse(a.ge(b))
        AhkTest.AssertTrue(b.gt(a))
        AhkTest.AssertTrue(b.ge(a))
    }

    static TestCachedPropertyComputesOnce()
    {
        StdlibFunctoolsCachedDemo.computeCount := 0
        StdlibFunctoolsCachedDemo.Bind()
        obj := StdlibFunctoolsCachedDemo(21)
        AhkTest.AssertEqual(210, obj.expensive)
        AhkTest.AssertEqual(210, obj.expensive)
        AhkTest.AssertEqual(1, StdlibFunctoolsCachedDemo.computeCount)
    }

    static TestPartialmethodBindsInstance()
    {
        pm := stdlib.functools.partialmethod(stdlib_functools_test_pm_add, 10)
        pm.Bind(StdlibFunctoolsPartialDemo, "addTen")
        obj := StdlibFunctoolsPartialDemo(5)
        AhkTest.AssertEqual(15, obj.addTen(5))
    }

}

class StdlibFunctoolsOrderingDemo
{
    __New(value)
    {
        this.value := value
    }

    eq(other) => this.value = other.value
    lt(other) => this.value < other.value
}

class StdlibFunctoolsCachedDemo
{
    static computeCount := 0

    __New(base)
    {
        this.baseValue := base
    }

    static Bind()
    {
        prop := stdlib.functools.cached_property(StdlibFunctoolsCachedComputeExpensive)
        prop.Bind(StdlibFunctoolsCachedDemo, "expensive")
    }
}

StdlibFunctoolsCachedComputeExpensive(instance)
{
    StdlibFunctoolsCachedDemo.computeCount += 1
    return instance.baseValue * 10
}

class StdlibFunctoolsPartialDemo
{
    __New(base)
    {
        this.baseValue := base
    }
}

stdlib_functools_test_add(a, b)
{
    return a + b
}

stdlib_functools_test_counting_square(value)
{
    StdlibFunctoolsTest.callCount += 1
    return value * value
}

stdlib_functools_test_reverse_cmp(a, b)
{
    return b - a
}

stdlib_functools_test_join(a, b)
{
    return a " " b
}

stdlib_functools_test_add_three(a, b, c)
{
    return a + b + c
}

stdlib_functools_test_identity(value)
{
    return value
}

stdlib_functools_test_pm_add(instance, addend, extra)
{
    return instance.base + addend - extra + extra
}

AhkTest.Collect(StdlibFunctoolsTest)

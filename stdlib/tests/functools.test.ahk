#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\base>
#Include <stdlib\functools>

class StdlibFunctoolsTest
{
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

        AhkTest.AssertEqual("functools", partial.__module__)
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc__)
    }

    static TestPartialExposesStableEmptyDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)
        dict := partial.__dict__

        AhkTest.AssertTrue(dict is Map)
        AhkTest.AssertEqual(0, dict.Count)
        AhkTest.AssertSame(dict, partial.__dict__)
    }

    static TestPartialDynamicAttributesUpdateDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.custom := 42

        AhkTest.AssertEqual(42, partial.custom)
        AhkTest.AssertTrue(partial.__dict__.Has("custom"))
        AhkTest.AssertEqual(42, partial.__dict__["custom"])
        AhkTest.AssertSame(partial.__dict__, partial.__dict__)
    }

    static TestPartialDynamicAttributesDeleteFromDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.custom := 42
        removed := stdlib.base.delattr(partial, "custom")

        AhkTest.AssertEqual(42, removed)
        AhkTest.AssertFalse(partial.__dict__.Has("custom"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^'functools\.partial' object has no attribute 'custom'$", (*) => partial.custom)
        AhkTest.RaisesMatch(stdlib.AttributeError, "^custom$", (*) => stdlib.base.delattr(partial, "custom"))
    }

    static TestPartialModuleDocAndDictSupportObservedAssignmentSemanticsLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)
        replacementDict := Map("x", 1)

        partial.__module__ := "custom_module"
        partial.__doc__ := "custom doc"
        AhkTest.AssertEqual("custom_module", partial.__module__)
        AhkTest.AssertEqual("custom doc", partial.__doc__)
        AhkTest.AssertEqual("custom_module", partial.__dict__["__module__"])
        AhkTest.AssertEqual("custom doc", partial.__dict__["__doc__"])

        partial.__dict__ := replacementDict

        AhkTest.AssertEqual("functools", partial.__module__)
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc__)
        AhkTest.AssertSame(replacementDict, partial.__dict__)
        AhkTest.AssertEqual(1, partial.__dict__["x"])
    }

    static TestPartialDictAssignmentRejectsNonDictLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(TypeError, "__dict__ must be set to a dictionary, not a 'int'", (*) => partial.__dict__ := 5)
        AhkTest.RaisesMatch(TypeError, "__dict__ must be set to a dictionary, not a 'list'", (*) => partial.__dict__ := [])
        AhkTest.RaisesMatch(TypeError, "__dict__ must be set to a dictionary, not a 'NoneType'", (*) => partial.__dict__ := stdlib.None)
    }

    static TestPartialModuleDocAndDictDeletionMatchPython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        partial.__module__ := "custom_module"
        partial.__doc__ := "custom doc"

        AhkTest.AssertEqual("custom_module", stdlib.base.delattr(partial, "__module__"))
        AhkTest.AssertEqual("functools", partial.__module__)
        AhkTest.AssertEqual("custom doc", stdlib.base.delattr(partial, "__doc__"))
        AhkTest.AssertEqual("partial(func, *args, **keywords) - new function with partial application`n    of the given arguments and keywords.`n", partial.__doc__)
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__module__$", (*) => stdlib.base.delattr(partial, "__module__"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__doc__$", (*) => stdlib.base.delattr(partial, "__doc__"))
        AhkTest.RaisesMatch(TypeError, "cannot delete __dict__", (*) => stdlib.base.delattr(partial, "__dict__"))
    }

    static TestPartialDefaultModuleAndDocDeletionRaiseAttributeErrorLikeLocal310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add, 2)

        AhkTest.RaisesMatch(stdlib.AttributeError, "^__module__$", (*) => stdlib.base.delattr(partial, "__module__"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^__doc__$", (*) => stdlib.base.delattr(partial, "__doc__"))
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
        reduced := partial.__reduce__()
        state := reduced[3]

        AhkTest.AssertTrue(HasMethod(partial, "__reduce__"))
        AhkTest.AssertTrue(HasMethod(partial, "__setstate__"))
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

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), stdlib.None]))
        AhkTest.AssertSame(stdlib_functools_test_add_three, partial.func)
        AhkTest.AssertEqual([1], partial.args)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertTrue(partial.__dict__ is Map)
        AhkTest.AssertEqual(0, partial.__dict__.Count)
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), []]))
        AhkTest.AssertEqual(0, partial.__dict__.Length)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), stdlib.tuple()]))
        AhkTest.AssertEqual(0, partial.__dict__.Length)
        AhkTest.AssertEqual(5, partial.keywords["c"])
        AhkTest.AssertEqual(8, partial.Call(2))

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, stdlib.None]))
        AhkTest.AssertTrue(partial.keywords is Map)
        AhkTest.AssertEqual(0, partial.keywords.Count)
        AhkTest.AssertTrue(partial.__dict__ is Map)
        AhkTest.AssertEqual(0, partial.__dict__.Count)
        AhkTest.AssertEqual(8, partial.Call(2, 5))

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, 5]))
        AhkTest.AssertTrue(partial.keywords is Map)
        AhkTest.AssertEqual(0, partial.keywords.Count)
        AhkTest.AssertEqual(5, partial.__dict__)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.custom := 42)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.custom)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.DeleteProp("custom"))
        AhkTest.AssertEqual(8, partial.Call(2, 5))
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__reduce__())

        AhkTest.RaisesMatch(TypeError, "partial\.__setstate__\(\) takes exactly one argument \(0 given\)", (*) => partial.__setstate__())
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate__(42))
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate__(stdlib.tuple([1, 2, 3])))
        AhkTest.RaisesMatch(TypeError, "invalid partial state", (*) => partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, [1], Map(), stdlib.None])))
    }

    static TestPartialMetadataRoundtripsThroughDictStateLikePython310()
    {
        partial := stdlib.functools.partial(stdlib_functools_test_add_three, 1)
        reduced := ""
        state := ""

        partial.__module__ := 5
        partial.__doc__ := 6

        AhkTest.AssertEqual(5, partial.__module__)
        AhkTest.AssertEqual(6, partial.__doc__)
        AhkTest.AssertTrue(partial.__dict__ is Map)
        AhkTest.AssertEqual(5, partial.__dict__["__module__"])
        AhkTest.AssertEqual(6, partial.__dict__["__doc__"])

        reduced := partial.__reduce__()
        state := reduced[3]
        AhkTest.AssertTrue(state[4] is Map)
        AhkTest.AssertEqual(5, state[4]["__module__"])
        AhkTest.AssertEqual(6, state[4]["__doc__"])

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), Map("c", 5), Map("__module__", 7, "__doc__", 8, "x", 9)]))
        AhkTest.AssertEqual(7, partial.__module__)
        AhkTest.AssertEqual(8, partial.__doc__)
        AhkTest.AssertEqual(9, partial.x)
        AhkTest.AssertEqual(7, partial.__dict__["__module__"])
        AhkTest.AssertEqual(8, partial.__dict__["__doc__"])
        AhkTest.AssertEqual(9, partial.__dict__["x"])

        partial.__setstate__(stdlib.tuple([stdlib_functools_test_add_three, stdlib.tuple([1]), stdlib.None, 5]))
        AhkTest.AssertEqual(5, partial.__dict__)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__module__)
        AhkTest.RaisesMatch(stdlib.SystemError, "bad argument to internal function", (*) => partial.__doc__)
    }

}

stdlib_functools_test_add(a, b)
{
    return a + b
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

AhkTest.Collect(StdlibFunctoolsTest)

#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\operator>

class AhkStdlibItertoolsChainCallable
{
    Call(args*)
    {
        if args.Length > 0 && args[1] == AhkStdlibItertools
            args.RemoveAt(1)
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.chain() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        for , arg in args {
            if AhkStdlibItertoolsIsKeywordArgumentObject(arg)
                throw TypeError("chain() takes no keyword arguments", -1)
        }
        return AhkStdlibItertoolsChain(args)
    }

    from_iterable(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("chain.from_iterable() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("chain.from_iterable() takes no keyword arguments", -1)
        if args.Length != 1
            throw TypeError("chain.from_iterable() takes exactly one argument (" args.Length " given)", -1)
        return AhkStdlibItertoolsChainFromIterable(args[1])
    }
}

class AhkStdlibItertools
{
    static chain := AhkStdlibItertoolsChainCallable()

    static count(args*)
    {
        if args.Length > 2
            throw TypeError("count() takes at most 2 arguments (" args.Length " given)", -1)

        start := args.Length >= 1 ? args[1] : 0
        step := args.Length >= 2 ? args[2] : 1
        startIsKeywordObject := Type(start) = "Object" && ObjOwnPropCount(start) > 0
            && !HasMethod(start, "__Enum") && !HasMethod(start, "Call")
        stepIsKeywordObject := Type(step) = "Object" && ObjOwnPropCount(step) > 0
            && !HasMethod(step, "__Enum") && !HasMethod(step, "Call")

        if startIsKeywordObject && stepIsKeywordObject {
            keywordCount := ObjOwnPropCount(start) + ObjOwnPropCount(step)
            if keywordCount > 2
                throw TypeError("count() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            for key in start.OwnProps() {
                if key != "start" && key != "step"
                    throw TypeError("'" key "' is an invalid keyword argument for count()", -1)
            }
            for key in step.OwnProps() {
                if key != "start" && key != "step"
                    throw TypeError("'" key "' is an invalid keyword argument for count()", -1)
            }
            optionsStart := start
            optionsStep := step
            start := HasProp(optionsStart, "start") ? optionsStart.start : 0
            if HasProp(optionsStart, "step")
                step := optionsStart.step
            else
                step := 1
            if HasProp(optionsStep, "start")
                start := optionsStep.start
            if HasProp(optionsStep, "step")
                step := optionsStep.step
        } else if stepIsKeywordObject && (HasProp(step, "start") || HasProp(step, "step")) {
            if HasProp(step, "start")
                throw TypeError("argument for count() given by name ('start') and position (1)", -1)
            for key in step.OwnProps() {
                if key != "step"
                    throw TypeError("'" key "' is an invalid keyword argument for count()", -1)
            }
            step := step.step
        } else if startIsKeywordObject {
            keywordCount := ObjOwnPropCount(start)
            if keywordCount > 2
                throw TypeError("count() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            for key in start.OwnProps() {
                if key != "start" && key != "step"
                    throw TypeError("'" key "' is an invalid keyword argument for count()", -1)
            }
            options := start
            start := HasProp(options, "start") ? options.start : 0
            if HasProp(options, "step")
                step := options.step
            else if args.Length < 2
                step := 1
        }
        return AhkStdlibItertoolsCount(start, step)
    }

    static accumulate(args*)
    {
        if args.Length = 0
            throw TypeError("accumulate() missing required argument 'iterable' (pos 1)", -1)
        if args.Length > 3
            throw TypeError("accumulate() takes at most 3 arguments (" args.Length " given)", -1)
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.accumulate() got multiple values for keyword argument '" duplicateKeyword "'", -1)

        iterable := args[1]
        func := args.Length >= 2 && args.Has(2) ? args[2] : unset
        initial := args.Length >= 3 && args.Has(3) ? args[3] : unset

        iterableIsKeywordObject := Type(iterable) = "Object" && !AhkStdlibIsNone(iterable) && !AhkStdlibIsNotImplemented(iterable)
            && !HasMethod(iterable, "__Enum") && !HasMethod(iterable, "Call")
            && ObjOwnPropCount(iterable) > 0
        funcIsKeywordObject := IsSet(func) && Type(func) = "Object" && !AhkStdlibIsNone(func) && !AhkStdlibIsNotImplemented(func)
            && !HasMethod(func, "__Enum") && !HasMethod(func, "Call")
            && ObjOwnPropCount(func) > 0
        initialIsKeywordObject := IsSet(initial) && Type(initial) = "Object" && !AhkStdlibIsNone(initial) && !AhkStdlibIsNotImplemented(initial)
            && !HasMethod(initial, "__Enum") && !HasMethod(initial, "Call")
            && ObjOwnPropCount(initial) > 0

        if iterableIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable)
            if keywordCount > 3
                throw TypeError("accumulate() takes at most 3 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable")
                throw TypeError("accumulate() missing required argument 'iterable' (pos 1)", -1)
            for prop in iterable.OwnProps() {
                if prop != "iterable" && prop != "func" && prop != "initial"
                    throw TypeError("'" prop "' is an invalid keyword argument for accumulate()", -1)
            }
            if IsSet(func)
                throw TypeError("argument for accumulate() given by name ('iterable') and position (1)", -1)
            if HasProp(iterable, "func")
                func := iterable.func
            if HasProp(iterable, "initial")
                initial := iterable.initial
            iterable := iterable.iterable
        } else if funcIsKeywordObject {
            keywordCount := ObjOwnPropCount(func)
            if keywordCount > 2
                throw TypeError("accumulate() takes at most 3 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(func, "iterable")
                throw TypeError("argument for accumulate() given by name ('iterable') and position (1)", -1)
            for prop in func.OwnProps() {
                if prop != "func" && prop != "initial"
                    throw TypeError("'" prop "' is an invalid keyword argument for accumulate()", -1)
            }
            funcOptions := func
            if HasProp(funcOptions, "initial")
                initial := funcOptions.initial
            if HasProp(funcOptions, "func")
                func := funcOptions.func
            else
                func := unset
        }
        if initialIsKeywordObject {
            keywordCount := ObjOwnPropCount(initial)
            if keywordCount > 1
                throw TypeError("accumulate() takes at most 3 arguments (" (2 + keywordCount) " given)", -1)
            if HasProp(initial, "iterable")
                throw TypeError("argument for accumulate() given by name ('iterable') and position (1)", -1)
            if HasProp(initial, "func")
                throw TypeError("argument for accumulate() given by name ('func') and position (2)", -1)
            if HasProp(initial, "initial")
                initial := initial.initial
            else {
                for prop in initial.OwnProps()
                    throw TypeError("'" prop "' is an invalid keyword argument for accumulate()", -1)
            }
        }
        if IsSet(func) && AhkStdlibIsNone(func)
            func := unset
        if IsSet(initial) {
            if IsSet(func)
                return AhkStdlibItertoolsAccumulate(iterable, func, initial)
            return AhkStdlibItertoolsAccumulate(iterable, unset, initial)
        }
        if IsSet(func)
            return AhkStdlibItertoolsAccumulate(iterable, func)
        return AhkStdlibItertoolsAccumulate(iterable)
    }

    static repeat(args*)
    {
        if args.Length = 0
            throw TypeError("repeat() missing required argument 'object' (pos 1)", -1)
        if args.Length > 2 {
            duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
            if duplicateKeyword != ""
                throw TypeError("itertools.repeat() got multiple values for keyword argument '" duplicateKeyword "'", -1)

            keywordArgumentCount := 0
            keywordObjectCount := 0
            for , arg in args {
                if !AhkStdlibItertoolsIsKeywordArgumentObject(arg)
                    continue
                keywordObjectCount += 1
                keywordArgumentCount += ObjOwnPropCount(arg)
            }

            if keywordObjectCount = args.Length
                throw TypeError("repeat() takes at most 2 keyword arguments (" keywordArgumentCount " given)", -1)
            if !AhkStdlibItertoolsIsKeywordArgumentObject(args[1]) && keywordObjectCount = args.Length - 1
                throw TypeError("repeat() takes at most 2 arguments (" (1 + keywordArgumentCount) " given)", -1)
            throw TypeError("repeat() takes at most 2 arguments (" args.Length " given)", -1)
        }

        value := args[1]
        times := args.Length >= 2 && args.Has(2) ? args[2] : unset
        valueIsKeywordObject := Type(value) = "Object" && !AhkStdlibIsNone(value) && !AhkStdlibIsNotImplemented(value)
            && !HasMethod(value, "__Enum") && !HasMethod(value, "Call") && ObjOwnPropCount(value) > 0
        timesIsKeywordObject := IsSet(times) && Type(times) = "Object" && !AhkStdlibIsNone(times) && !AhkStdlibIsNotImplemented(times)
            && !HasMethod(times, "__Enum") && !HasMethod(times, "Call") && ObjOwnPropCount(times) > 0

        if valueIsKeywordObject && timesIsKeywordObject {
            options1 := value
            options2 := times
            keywordCount := ObjOwnPropCount(options1) + ObjOwnPropCount(options2)

            for prop in options2.OwnProps() {
                if HasProp(options1, prop)
                    throw TypeError("itertools.repeat() got multiple values for keyword argument '" prop "'", -1)
            }

            hasObject := HasProp(options1, "object") || HasProp(options2, "object")

            if keywordCount > 2
                throw TypeError("repeat() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !hasObject
                throw TypeError("repeat() missing required argument 'object' (pos 1)", -1)

            for prop in options1.OwnProps() {
                if prop != "object" && prop != "times"
                    throw TypeError("'" prop "' is an invalid keyword argument for repeat()", -1)
            }
            for prop in options2.OwnProps() {
                if prop != "object" && prop != "times"
                    throw TypeError("'" prop "' is an invalid keyword argument for repeat()", -1)
            }

            value := HasProp(options1, "object") ? options1.object : options2.object
            if HasProp(options1, "times")
                times := options1.times
            else if HasProp(options2, "times")
                times := options2.times
            else
                times := unset
            valueIsKeywordObject := false
            timesIsKeywordObject := false
        }

        if !valueIsKeywordObject
            valueIsKeywordObject := Type(value) = "Object" && !HasMethod(value, "__Enum") && !HasMethod(value, "Call")
                && !AhkStdlibIsNone(value) && !AhkStdlibIsNotImplemented(value) && ObjOwnPropCount(value) > 0
        if !timesIsKeywordObject
            timesIsKeywordObject := IsSet(times) && Type(times) = "Object" && ObjOwnPropCount(times) > 0
                && !AhkStdlibIsNone(times) && !AhkStdlibIsNotImplemented(times)
                && !HasMethod(times, "__Enum") && !HasMethod(times, "Call")

        if valueIsKeywordObject
            && !HasProp(value, "object") && !HasProp(value, "times") && ObjOwnPropCount(value) > 0 {
            if ObjOwnPropCount(value) > 2
                throw TypeError("repeat() takes at most 2 keyword arguments (" ObjOwnPropCount(value) " given)", -1)
            throw TypeError("repeat() missing required argument 'object' (pos 1)", -1)
        }
        if valueIsKeywordObject
            && !HasProp(value, "object") && HasProp(value, "times") {
            if ObjOwnPropCount(value) > 2
                throw TypeError("repeat() takes at most 2 keyword arguments (" ObjOwnPropCount(value) " given)", -1)
            throw TypeError("repeat() missing required argument 'object' (pos 1)", -1)
        }
        if valueIsKeywordObject
            && (HasProp(value, "object") || HasProp(value, "times")) {
            if ObjOwnPropCount(value) > 2
                throw TypeError("repeat() takes at most 2 keyword arguments (" ObjOwnPropCount(value) " given)", -1)
            for prop in value.OwnProps() {
                if prop != "object" && prop != "times"
                    throw TypeError("'" prop "' is an invalid keyword argument for repeat()", -1)
            }
            if !HasProp(value, "object")
                throw TypeError("repeat() missing required argument 'object' (pos 1)", -1)
            if HasProp(value, "times")
                times := value.times
            value := value.object
        } else if timesIsKeywordObject {
            givenCount := 1 + ObjOwnPropCount(times)
            if HasProp(times, "object") {
                if ObjOwnPropCount(times) > 1
                    throw TypeError("repeat() takes at most 2 arguments (" givenCount " given)", -1)
                throw TypeError("argument for repeat() given by name ('object') and position (1)", -1)
            }
            if HasProp(times, "times") {
                if ObjOwnPropCount(times) > 1
                    throw TypeError("repeat() takes at most 2 arguments (" givenCount " given)", -1)
                times := times.times
            } else {
                if ObjOwnPropCount(times) > 1
                    throw TypeError("repeat() takes at most 2 arguments (" givenCount " given)", -1)
                for prop in times.OwnProps()
                    throw TypeError("'" prop "' is an invalid keyword argument for repeat()", -1)
            }
        }

        if IsSet(times)
            return AhkStdlibItertoolsRepeat(value, times)
        return AhkStdlibItertoolsRepeat(value)
    }

    static product(iterables*)
    {
        return AhkStdlibItertoolsProduct(iterables)
    }

    static zip_longest(iterables*)
    {
        return AhkStdlibItertoolsZipLongest(iterables)
    }

    static groupby(args*)
    {
        if args.Length = 0
            throw TypeError("groupby() missing required argument 'iterable' (pos 1)", -1)
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.groupby() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if args.Length > 2 {
            keywordArgumentCount := 0
            keywordObjectCount := 0
            for , arg in args {
                if !AhkStdlibItertoolsIsKeywordArgumentObject(arg)
                    continue
                keywordObjectCount += 1
                keywordArgumentCount += ObjOwnPropCount(arg)
            }

            if keywordObjectCount = args.Length
                throw TypeError("groupby() takes at most 2 keyword arguments (" keywordArgumentCount " given)", -1)
            if !AhkStdlibItertoolsIsKeywordArgumentObject(args[1]) && keywordObjectCount = args.Length - 1
                throw TypeError("groupby() takes at most 2 arguments (" (1 + keywordArgumentCount) " given)", -1)
            throw TypeError("groupby() takes at most 2 arguments (" args.Length " given)", -1)
        }

        iterable := args[1]
        key := args.Length >= 2 && args.Has(2) ? args[2] : unset
        iterableIsKeywordObject := Type(iterable) = "Object" && !AhkStdlibIsNone(iterable) && !AhkStdlibIsNotImplemented(iterable)
            && !HasMethod(iterable, "Call")
            && ((HasProp(iterable, "iterable") || HasProp(iterable, "key"))
                || (ObjOwnPropCount(iterable) > 0 && !HasMethod(iterable, "__Enum")))
        keyIsKeywordObject := IsSet(key) && Type(key) = "Object" && !AhkStdlibIsNone(key) && !AhkStdlibIsNotImplemented(key)
            && !HasMethod(key, "__Enum")
            && !HasMethod(key, "Call")
            && ((HasProp(key, "iterable") || HasProp(key, "key"))
                || ObjOwnPropCount(key) > 0)

        if iterableIsKeywordObject && keyIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable) + ObjOwnPropCount(key)
            if keywordCount > 2
                throw TypeError("groupby() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable") && !HasProp(key, "iterable")
                throw TypeError("groupby() missing required argument 'iterable' (pos 1)", -1)
            for prop in iterable.OwnProps() {
                if prop != "iterable" && prop != "key"
                    throw TypeError("'" prop "' is an invalid keyword argument for groupby()", -1)
            }
            for prop in key.OwnProps() {
                if prop != "iterable" && prop != "key"
                    throw TypeError("'" prop "' is an invalid keyword argument for groupby()", -1)
            }
            options1 := iterable
            options2 := key
            iterable := HasProp(options1, "iterable") ? options1.iterable : options2.iterable
            if HasProp(options1, "key")
                key := options1.key
            else if HasProp(options2, "key")
                key := options2.key
            else
                key := unset
        } else if iterableIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable)
            if keywordCount > 2
                throw TypeError("groupby() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable")
                throw TypeError("groupby() missing required argument 'iterable' (pos 1)", -1)
            for prop in iterable.OwnProps() {
                if prop != "iterable" && prop != "key"
                    throw TypeError("'" prop "' is an invalid keyword argument for groupby()", -1)
            }
            options := iterable
            iterable := options.iterable
            if !IsSet(key) && HasProp(options, "key")
                key := options.key
        } else if keyIsKeywordObject {
            keywordCount := ObjOwnPropCount(key)
            if keywordCount > 1
                throw TypeError("groupby() takes at most 2 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(key, "iterable")
                throw TypeError("argument for groupby() given by name ('iterable') and position (1)", -1)
            if HasProp(key, "key")
                key := key.key
            else {
                for prop in key.OwnProps()
                    throw TypeError("'" prop "' is an invalid keyword argument for groupby()", -1)
            }
        }
        if IsSet(key)
            return AhkStdlibItertoolsGroupby(iterable, key)
        return AhkStdlibItertoolsGroupby(iterable)
    }

    static cycle(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.cycle() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if args.Length < 1
            throw TypeError("cycle expected 1 argument, got " args.Length, -1)
        if args.Length > 1 {
            loop args.Length - 1 {
                if AhkStdlibItertoolsIsKeywordArgumentObject(args[A_Index + 1]) {
                    throw TypeError("cycle() takes no keyword arguments", -1)
                }
            }
            throw TypeError("cycle expected 1 argument, got " args.Length, -1)
        }
        iterable := args[1]
        if AhkStdlibItertoolsIsKeywordArgumentObject(iterable)
            throw TypeError("cycle() takes no keyword arguments", -1)
        return AhkStdlibItertoolsCycle(iterable)
    }

    static pairwise(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.pairwise() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if args.Length < 1
            throw TypeError("pairwise expected 1 argument, got " args.Length, -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("pairwise() takes no keyword arguments", -1)
        iterable := args[1]
        if args.Length > 1
            throw TypeError("pairwise expected 1 argument, got " args.Length, -1)
        return AhkStdlibItertoolsPairwise(iterable)
    }

    static combinations(args*)
    {
        if args.Length = 0
            throw TypeError("combinations() missing required argument 'iterable' (pos 1)", -1)
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.combinations() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if args.Length > 2 {
            keywordArgumentCount := 0
            keywordObjectCount := 0
            for , arg in args {
                if !AhkStdlibItertoolsIsKeywordArgumentObject(arg)
                    continue
                keywordObjectCount += 1
                keywordArgumentCount += ObjOwnPropCount(arg)
            }

            if keywordObjectCount = args.Length
                throw TypeError("combinations() takes at most 2 keyword arguments (" keywordArgumentCount " given)", -1)
            if !AhkStdlibItertoolsIsKeywordArgumentObject(args[1]) && keywordObjectCount = args.Length - 1
                throw TypeError("combinations() takes at most 2 arguments (" (1 + keywordArgumentCount) " given)", -1)
            throw TypeError("combinations() takes at most 2 arguments (" args.Length " given)", -1)
        }

        iterable := args[1]
        r := args.Length >= 2 && args.Has(2) ? args[2] : unset
        iterableIsKeywordObject := Type(iterable) = "Object" && !AhkStdlibIsNone(iterable) && !AhkStdlibIsNotImplemented(iterable)
            && !HasMethod(iterable, "__Enum")
            && !HasMethod(iterable, "Call")
            && ObjOwnPropCount(iterable) > 0
        rIsKeywordObject := IsSet(r) && Type(r) = "Object" && !AhkStdlibIsNone(r) && !AhkStdlibIsNotImplemented(r)
            && !HasMethod(r, "__Enum")
            && !HasMethod(r, "Call")
            && ObjOwnPropCount(r) > 0

        if iterableIsKeywordObject && rIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable) + ObjOwnPropCount(r)
            if keywordCount > 2
                throw TypeError("combinations() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable") && !HasProp(r, "iterable")
                throw TypeError("combinations() missing required argument 'iterable' (pos 1)", -1)
            if !HasProp(iterable, "r") && !HasProp(r, "r")
                throw TypeError("combinations() missing required argument 'r' (pos 2)", -1)
            options1 := iterable
            options2 := r
            iterable := HasProp(options1, "iterable") ? options1.iterable : options2.iterable
            r := HasProp(options1, "r") ? options1.r : options2.r
        } else if iterableIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable)
            if keywordCount > 2
                throw TypeError("combinations() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable")
                throw TypeError("combinations() missing required argument 'iterable' (pos 1)", -1)
            if !HasProp(iterable, "r")
                throw TypeError("combinations() missing required argument 'r' (pos 2)", -1)
            options := iterable
            iterable := options.iterable
            r := options.r
        } else if rIsKeywordObject {
            keywordCount := ObjOwnPropCount(r)
            if keywordCount > 1
                throw TypeError("combinations() takes at most 2 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(r, "r")
                r := r.r
            else
                throw TypeError("combinations() missing required argument 'r' (pos 2)", -1)
        }
        return AhkStdlibItertoolsCombinations(iterable, r)
    }

    static combinations_with_replacement(args*)
    {
        if args.Length = 0
            throw TypeError("combinations_with_replacement() missing required argument 'iterable' (pos 1)", -1)
        if args.Length > 2
            throw TypeError("combinations_with_replacement() takes at most 2 arguments (" args.Length " given)", -1)

        iterable := args[1]
        r := args.Length >= 2 && args.Has(2) ? args[2] : unset
        iterableIsKeywordObject := Type(iterable) = "Object" && !AhkStdlibIsNone(iterable) && !AhkStdlibIsNotImplemented(iterable)
            && !HasMethod(iterable, "__Enum")
            && !HasMethod(iterable, "Call")
            && ObjOwnPropCount(iterable) > 0
        rIsKeywordObject := IsSet(r) && Type(r) = "Object" && !AhkStdlibIsNone(r) && !AhkStdlibIsNotImplemented(r)
            && !HasMethod(r, "__Enum")
            && !HasMethod(r, "Call")
            && ObjOwnPropCount(r) > 0

        if iterableIsKeywordObject && rIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable) + ObjOwnPropCount(r)
            if keywordCount > 2
                throw TypeError("combinations_with_replacement() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable") && !HasProp(r, "iterable")
                throw TypeError("combinations_with_replacement() missing required argument 'iterable' (pos 1)", -1)
            if !HasProp(iterable, "r") && !HasProp(r, "r")
                throw TypeError("combinations_with_replacement() missing required argument 'r' (pos 2)", -1)
            options1 := iterable
            options2 := r
            iterable := HasProp(options1, "iterable") ? options1.iterable : options2.iterable
            r := HasProp(options1, "r") ? options1.r : options2.r
        } else if iterableIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable)
            if keywordCount > 2
                throw TypeError("combinations_with_replacement() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable")
                throw TypeError("combinations_with_replacement() missing required argument 'iterable' (pos 1)", -1)
            if !HasProp(iterable, "r")
                throw TypeError("combinations_with_replacement() missing required argument 'r' (pos 2)", -1)
            options := iterable
            iterable := options.iterable
            r := options.r
        } else if rIsKeywordObject {
            keywordCount := ObjOwnPropCount(r)
            if keywordCount > 1
                throw TypeError("combinations_with_replacement() takes at most 2 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(r, "r")
                r := r.r
            else
                throw TypeError("combinations_with_replacement() missing required argument 'r' (pos 2)", -1)
        }
        if IsSet(r)
            return AhkStdlibItertoolsCombinationsWithReplacement(iterable, r)
        return AhkStdlibItertoolsCombinationsWithReplacement(iterable)
    }

    static permutations(args*)
    {
        if args.Length = 0
            throw TypeError("permutations() missing required argument 'iterable' (pos 1)", -1)
        if args.Length > 2
            throw TypeError("permutations() takes at most 2 arguments (" args.Length " given)", -1)

        iterable := args[1]
        r := args.Length >= 2 && args.Has(2) ? args[2] : unset
        iterableIsKeywordObject := Type(iterable) = "Object" && !AhkStdlibIsNone(iterable) && !AhkStdlibIsNotImplemented(iterable)
            && !HasMethod(iterable, "__Enum")
            && !HasMethod(iterable, "Call")
            && ObjOwnPropCount(iterable) > 0
        rIsKeywordObject := IsSet(r) && Type(r) = "Object" && !AhkStdlibIsNone(r) && !AhkStdlibIsNotImplemented(r)
            && !HasMethod(r, "__Enum")
            && !HasMethod(r, "Call")
            && ObjOwnPropCount(r) > 0

        if iterableIsKeywordObject && rIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable) + ObjOwnPropCount(r)
            if keywordCount > 2
                throw TypeError("permutations() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable") && !HasProp(r, "iterable")
                throw TypeError("permutations() missing required argument 'iterable' (pos 1)", -1)
            for prop in iterable.OwnProps() {
                if prop != "iterable" && prop != "r"
                    throw TypeError("'" prop "' is an invalid keyword argument for permutations()", -1)
            }
            for prop in r.OwnProps() {
                if prop != "iterable" && prop != "r"
                    throw TypeError("'" prop "' is an invalid keyword argument for permutations()", -1)
            }
            options1 := iterable
            options2 := r
            iterable := HasProp(options1, "iterable") ? options1.iterable : options2.iterable
            if HasProp(options1, "r")
                r := options1.r
            else if HasProp(options2, "r")
                r := options2.r
            else
                r := unset
        } else if iterableIsKeywordObject {
            keywordCount := ObjOwnPropCount(iterable)
            if keywordCount > 2
                throw TypeError("permutations() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(iterable, "iterable")
                throw TypeError("permutations() missing required argument 'iterable' (pos 1)", -1)
            for prop in iterable.OwnProps() {
                if prop != "iterable" && prop != "r"
                    throw TypeError("'" prop "' is an invalid keyword argument for permutations()", -1)
            }
            if HasProp(iterable, "r")
                r := iterable.r
            iterable := iterable.iterable
        } else if rIsKeywordObject {
            keywordCount := ObjOwnPropCount(r)
            if keywordCount > 1
                throw TypeError("permutations() takes at most 2 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(r, "iterable")
                throw TypeError("argument for permutations() given by name ('iterable') and position (1)", -1)
            if HasProp(r, "r")
                r := r.r
            else {
                for prop in r.OwnProps()
                    throw TypeError("'" prop "' is an invalid keyword argument for permutations()", -1)
            }
        }
        if IsSet(r)
            return AhkStdlibItertoolsPermutations(iterable, r)
        return AhkStdlibItertoolsPermutations(iterable)
    }

    static starmap(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.starmap() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("starmap() takes no keyword arguments", -1)
        if args.Length != 2
            throw TypeError("starmap expected 2 arguments, got " args.Length, -1)
        return AhkStdlibItertoolsStarmap(args[1], args[2])
    }

    static takewhile(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.takewhile() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("takewhile() takes no keyword arguments", -1)
        if args.Length != 2
            throw TypeError("takewhile expected 2 arguments, got " args.Length, -1)
        return AhkStdlibItertoolsTakewhile(args[1], args[2])
    }

    static dropwhile(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.dropwhile() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("dropwhile() takes no keyword arguments", -1)
        if args.Length != 2
            throw TypeError("dropwhile expected 2 arguments, got " args.Length, -1)
        return AhkStdlibItertoolsDropwhile(args[1], args[2])
    }

    static filterfalse(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.filterfalse() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("filterfalse() takes no keyword arguments", -1)
        if args.Length != 2
            throw TypeError("filterfalse expected 2 arguments, got " args.Length, -1)
        return AhkStdlibItertoolsFilterfalse(args[1], args[2])
    }

    static tee(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.tee() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if args.Length < 1
            throw TypeError("tee expected at least 1 argument, got " args.Length, -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("itertools.tee() takes no keyword arguments", -1)
        if args.Length > 2
            throw TypeError("tee expected at most 2 arguments, got " args.Length, -1)
        if args.Length = 1
            return AhkStdlibItertoolsTee(args[1])
        return AhkStdlibItertoolsTee(args[1], args[2])
    }

    static compress(args*)
    {
        if args.Length = 0
            throw TypeError("compress() missing required argument 'data' (pos 1)", -1)
        if args.Length > 2
            throw TypeError("compress() takes at most 2 arguments (" args.Length " given)", -1)
        data := args[1]
        selectors := args.Length >= 2 ? args[2] : unset
        if Type(data) = "Object" && !AhkStdlibIsNone(data) && !AhkStdlibIsNotImplemented(data)
            && ObjOwnPropCount(data) > 0 && !HasMethod(data, "__Enum") && !HasMethod(data, "Call") {
            keywordCount := ObjOwnPropCount(data)
            if keywordCount > 2
                throw TypeError("compress() takes at most 2 keyword arguments (" keywordCount " given)", -1)
            if !HasProp(data, "data")
                throw TypeError("compress() missing required argument 'data' (pos 1)", -1)
            if !HasProp(data, "selectors")
                throw TypeError("compress() missing required argument 'selectors' (pos 2)", -1)
            options := data
            data := options.data
            selectors := options.selectors
        } else if IsSet(selectors) && Type(selectors) = "Object"
            && !AhkStdlibIsNone(selectors) && !AhkStdlibIsNotImplemented(selectors)
            && ObjOwnPropCount(selectors) > 0 && !HasMethod(selectors, "__Enum") && !HasMethod(selectors, "Call") {
            keywordCount := ObjOwnPropCount(selectors)
            if keywordCount > 1
                throw TypeError("compress() takes at most 2 arguments (" (1 + keywordCount) " given)", -1)
            if HasProp(selectors, "selectors")
                selectors := selectors.selectors
            else
                throw TypeError("compress() missing required argument 'selectors' (pos 2)", -1)
        }
        if !IsSet(selectors)
            throw TypeError("compress() missing required argument 'selectors' (pos 2)", -1)
        return AhkStdlibItertoolsCompress(data, selectors)
    }

    static islice(args*)
    {
        duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(args*)
        if duplicateKeyword != ""
            throw TypeError("itertools.islice() got multiple values for keyword argument '" duplicateKeyword "'", -1)
        if AhkStdlibItertoolsContainsKeywordArgumentObject(args*)
            throw TypeError("islice() takes no keyword arguments", -1)
        if args.Length < 2
            throw TypeError("islice expected at least 2 arguments, got " args.Length, -1)
        if args.Length > 4
            throw TypeError("islice expected at most 4 arguments, got " args.Length, -1)

        iterable := args[1]
        start := args[2]
        stop := args.Length >= 3 && args.Has(3) ? args[3] : unset
        step := args.Length >= 4 && args.Has(4) ? args[4] : 1
        stopWasOmitted := !IsSet(stop)
        if !IsSet(stop) {
            stop := start
            start := 0
        }

        return AhkStdlibItertoolsIslice(iterable, start, stop, step, stopWasOmitted)
    }
}

class AhkStdlibItertoolsOperatorCallable
{
    __New(func, methodName)
    {
        this.Bound := ObjBindMethod(stdlib.operator, methodName)
        this.MethodName := methodName
        this.MinArgs := func.MinParams - 1
        this.MaxArgs := func.MaxParams - 1
    }

    Name {
        get => this.MethodName
    }

    Call(args*)
    {
        actual := args.Length
        if actual < this.MinArgs || actual > this.MaxArgs
            throw TypeError(AhkStdlibItertoolsOperatorArityMessage(this.MethodName, actual, this.MinArgs, this.MaxArgs), -1)
        return this.Bound.Call(args*)
    }
}

class AhkStdlibItertoolsChain
{
    __New(iterables)
    {
        this.Iterables := iterables
        this.OuterIndex := 1
        this.HasCurrentIterator := false
        this.CurrentIterator := ""
    }

    __Repr()
    {
        return "<itertools.chain object at 0x" Format("{:X}", ObjPtr(this)) ">"
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            loop {
                if !self.HasCurrentIterator {
                    if self.OuterIndex > self.Iterables.Length
                        return false
                    self.CurrentIterator := AhkStdlibItertoolsEnum(self.Iterables[self.OuterIndex])
                    self.OuterIndex += 1
                    self.HasCurrentIterator := true
                }

                currentIterator := self.CurrentIterator
                if currentIterator(&value)
                    return true

                self.CurrentIterator := ""
                self.HasCurrentIterator := false
            }
        }
    }
}

class AhkStdlibItertoolsChainFromIterable
{
    __New(iterable)
    {
        this.OuterIterator := AhkStdlibItertoolsEnum(iterable)
        this.HasCurrentIterator := false
        this.CurrentIterator := ""
    }

    __Repr()
    {
        return "<itertools.chain object at 0x" Format("{:X}", ObjPtr(this)) ">"
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            loop {
                if !self.HasCurrentIterator {
                    outerIterator := self.OuterIterator
                    nextIterable := unset
                    if !outerIterator(&nextIterable)
                        return false
                    self.CurrentIterator := AhkStdlibItertoolsEnum(nextIterable)
                    self.HasCurrentIterator := true
                }

                currentIterator := self.CurrentIterator
                if currentIterator(&value)
                    return true

                self.CurrentIterator := ""
                self.HasCurrentIterator := false
            }
        }
    }
}

class AhkStdlibItertoolsAccumulate
{
    __New(iterable, func := unset, initial := unset)
    {
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.Func := IsSet(func) ? AhkStdlibItertoolsNormalizeCallable(func) : AhkStdlibItertoolsAccumulateAdd
        this.HasInitial := IsSet(initial)
        this.Initial := IsSet(initial) ? initial : unset
        this.HasTotal := false
        this.Total := unset
        this.InitialEmitted := false
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("accumulate", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.HasInitial && !self.InitialEmitted {
                self.InitialEmitted := true
                self.HasTotal := true
                self.Total := self.Initial
                value := self.Total
                return true
            }

            iterator := self.Iterator
            nextItem := unset
            if !iterator(&nextItem)
                return false

            if !self.HasTotal {
                self.Total := nextItem
                self.HasTotal := true
                value := self.Total
                return true
            }

            if !IsObject(self.Func) || !HasMethod(self.Func, "Call")
                throw TypeError("'" AhkStdlibItertoolsPythonTypeName(self.Func) "' object is not callable", -1)
            self.Total := self.Func.Call(self.Total, nextItem)
            value := self.Total
            return true
        }
    }
}

AhkStdlibItertoolsAccumulateAdd(a, b)
{
    return stdlib.operator.add(a, b)
}

class AhkStdlibItertoolsCycle
{
    __New(iterable)
    {
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.Saved := []
        this.ReplayIndex := 1
        this.IterationComplete := false
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("cycle", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if !self.IterationComplete {
                iterator := self.Iterator
                if iterator(&value) {
                    self.Saved.Push(value)
                    return true
                }
                self.IterationComplete := true
                self.ReplayIndex := 1
                if self.Saved.Length = 0
                    return false
            }

            value := self.Saved[self.ReplayIndex]
            self.ReplayIndex += 1
            if self.ReplayIndex > self.Saved.Length
                self.ReplayIndex := 1
            return true
        }
    }
}

class AhkStdlibItertoolsPairwiseIterator
{
    __New(iterable)
    {
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.HasPrevious := false
        this.Previous := unset
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("pairwise", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            iterator := self.Iterator
            if !self.HasPrevious {
                previous := unset
                if !iterator(&previous)
                    return false
                self.Previous := previous
                self.HasPrevious := true
            }

            nextItem := unset
            if !iterator(&nextItem)
                return false

            value := AhkStdlibTuple([self.Previous, nextItem])
            self.Previous := nextItem
            return true
        }
    }
}

class AhkStdlibItertoolsCombinationsIterator
{
    __New(pool, r)
    {
        this.Pool := pool
        this.R := r
        this.N := pool.Length
        this.Started := false
        this.Done := r > this.N
        this.Indices := []
        loop r
            this.Indices.Push(A_Index)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("combinations", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            if !self.Started {
                self.Started := true
            } else {
                if self.R = 0 {
                    self.Done := true
                    return false
                }

                index := self.R
                while index >= 1 && self.Indices[index] = index + self.N - self.R
                    index -= 1

                if index < 1 {
                    self.Done := true
                    return false
                }

                self.Indices[index] += 1
                nextIndex := index + 1
                while nextIndex <= self.R {
                    self.Indices[nextIndex] := self.Indices[nextIndex - 1] + 1
                    nextIndex += 1
                }
            }

            value := self.CurrentTuple()
            return true
        }
    }

    CurrentTuple()
    {
        values := []
        loop this.R
            values.Push(this.Pool[this.Indices[A_Index]])
        return AhkStdlibTuple(values)
    }
}

class AhkStdlibItertoolsProductIterator
{
    __New(pools)
    {
        this.Pools := pools
        this.PoolCount := pools.Length
        this.Started := false
        this.Done := false
        this.Indices := []
        for , pool in pools {
            if pool.Length = 0
                this.Done := true
            this.Indices.Push(1)
        }
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("product", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            if !self.Started {
                self.Started := true
                value := self.CurrentTuple()
                return true
            }

            if self.PoolCount = 0 {
                self.Done := true
                return false
            }

            index := self.PoolCount
            while index >= 1 {
                self.Indices[index] += 1
                if self.Indices[index] <= self.Pools[index].Length {
                    value := self.CurrentTuple()
                    return true
                }
                self.Indices[index] := 1
                index -= 1
            }

            self.Done := true
            return false
        }
    }

    CurrentTuple()
    {
        values := []
        loop this.PoolCount
            values.Push(this.Pools[A_Index][this.Indices[A_Index]])
        return AhkStdlibTuple(values)
    }
}

class AhkStdlibItertoolsZipLongestIterator
{
    __New(iterables, fillValue := unset)
    {
        this.Iterators := []
        this.Active := []
        this.ActiveCount := 0
        this.FillValue := IsSet(fillValue) ? fillValue : stdlib.None
        for , iterable in iterables {
            this.Iterators.Push(AhkStdlibItertoolsEnum(iterable))
            this.Active.Push(true)
            this.ActiveCount += 1
        }
        this.Done := this.Iterators.Length = 0
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("zip_longest", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            row := []
            hasLiveValue := false
            loop self.Iterators.Length {
                if self.Active[A_Index] {
                    iterator := self.Iterators[A_Index]
                    item := unset
                    if iterator(&item) {
                        row.Push(item)
                        hasLiveValue := true
                    } else {
                        self.Active[A_Index] := false
                        self.ActiveCount -= 1
                        row.Push(self.FillValue)
                    }
                } else {
                    row.Push(self.FillValue)
                }
            }

            if !hasLiveValue {
                self.Done := true
                return false
            }

            value := AhkStdlibTuple(row)
            return true
        }
    }
}

class AhkStdlibItertoolsGroupbyIterator
{
    __New(iterable, key := unset)
    {
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.HasKeyFunc := IsSet(key) && !AhkStdlibIsNone(key)
        this.KeyFunc := IsSet(key) ? AhkStdlibItertoolsNormalizeCallable(key) : unset
        this.HasCurrent := false
        this.CurrentValue := unset
        this.CurrentKey := unset
        this.HasTargetKey := false
        this.TargetKey := unset
        this.ActiveGroupId := 0
        this.Done := false
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("groupby", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            self.ActiveGroupId += 1

            if !self.HasCurrent {
                if !self.FetchNext() {
                    self.Done := true
                    return false
                }
            } else if self.HasTargetKey {
                while self.HasCurrent && AhkStdlibItertoolsGroupbyKeysEqual(self.CurrentKey, self.TargetKey) {
                    if !self.FetchNext() {
                        self.Done := true
                        return false
                    }
                }
            }

            self.TargetKey := self.CurrentKey
            self.HasTargetKey := true
            value := AhkStdlibTuple([self.CurrentKey, AhkStdlibItertoolsGroupbyGroupIterator(self, self.ActiveGroupId, self.CurrentKey)])
            return true
        }
    }

    FetchNext()
    {
        iterator := this.Iterator
        nextItem := unset
        if !iterator(&nextItem) {
            this.HasCurrent := false
            return false
        }

        this.CurrentValue := nextItem
        this.CurrentKey := this.ApplyKey(nextItem)
        this.HasCurrent := true
        return true
    }

    ApplyKey(value)
    {
        if !this.HasKeyFunc
            return value
        if !IsObject(this.KeyFunc) || !HasMethod(this.KeyFunc, "Call")
            throw TypeError("'" AhkStdlibItertoolsPythonTypeName(this.KeyFunc) "' object is not callable", -1)
        return this.KeyFunc.Call(value)
    }
}

class AhkStdlibItertoolsGroupbyGroupIterator
{
    __New(parent, groupId, targetKey)
    {
        this.Parent := parent
        this.GroupId := groupId
        this.TargetKey := targetKey
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("_grouper", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            parent := self.Parent
            if parent.ActiveGroupId != self.GroupId
                return false
            if !parent.HasCurrent
                return false
            if !AhkStdlibItertoolsGroupbyKeysEqual(parent.CurrentKey, self.TargetKey)
                return false

            value := parent.CurrentValue
            parent.FetchNext()
            return true
        }
    }
}

class AhkStdlibItertoolsCombinationsWithReplacementIterator
{
    __New(pool, r)
    {
        this.Pool := pool
        this.R := r
        this.N := pool.Length
        this.Started := false
        this.Done := this.N = 0 && r > 0
        this.Indices := []
        loop r
            this.Indices.Push(1)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("combinations_with_replacement", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            if !self.Started {
                self.Started := true
            } else {
                if self.R = 0 {
                    self.Done := true
                    return false
                }

                index := self.R
                while index >= 1 && self.Indices[index] = self.N
                    index -= 1

                if index < 1 {
                    self.Done := true
                    return false
                }

                replacementIndex := self.Indices[index] + 1
                while index <= self.R {
                    self.Indices[index] := replacementIndex
                    index += 1
                }
            }

            value := self.CurrentTuple()
            return true
        }
    }

    CurrentTuple()
    {
        values := []
        loop this.R
            values.Push(this.Pool[this.Indices[A_Index]])
        return AhkStdlibTuple(values)
    }
}

class AhkStdlibItertoolsPermutationsIterator
{
    __New(pool, r)
    {
        this.Pool := pool
        this.R := r
        this.N := pool.Length
        this.Started := false
        this.Done := r > this.N
        this.Indices := []
        loop this.N
            this.Indices.Push(A_Index)
        this.Cycles := []
        loop r
            this.Cycles.Push(this.N - A_Index + 1)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("permutations", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            if !self.Started {
                self.Started := true
                value := self.CurrentTuple()
                return true
            }

            if self.R = 0 {
                self.Done := true
                return false
            }

            index := self.R
            while index >= 1 {
                self.Cycles[index] -= 1
                if self.Cycles[index] = 0 {
                    saved := self.Indices[index]
                    shiftIndex := index
                    while shiftIndex < self.N {
                        self.Indices[shiftIndex] := self.Indices[shiftIndex + 1]
                        shiftIndex += 1
                    }
                    self.Indices[self.N] := saved
                    self.Cycles[index] := self.N - index + 1
                    index -= 1
                    continue
                }

                swapIndex := self.N - self.Cycles[index] + 1
                saved := self.Indices[index]
                self.Indices[index] := self.Indices[swapIndex]
                self.Indices[swapIndex] := saved
                value := self.CurrentTuple()
                return true
            }

            self.Done := true
            return false
        }
    }

    CurrentTuple()
    {
        values := []
        loop this.R
            values.Push(this.Pool[this.Indices[A_Index]])
        return AhkStdlibTuple(values)
    }
}

class AhkStdlibItertoolsStarmapIterator
{
    __New(func, iterable)
    {
        this.Func := AhkStdlibItertoolsNormalizeCallable(func)
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("starmap", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            iterator := self.Iterator
            row := unset
            if !iterator(&row)
                return false

            args := AhkStdlibItertoolsMaterializeArgs(row)
            if !IsObject(self.Func) || !HasMethod(self.Func, "Call")
                throw TypeError("'" AhkStdlibItertoolsPythonTypeName(self.Func) "' object is not callable", -1)
            value := self.Func.Call(args*)
            return true
        }
    }
}

class AhkStdlibItertoolsTakewhileIterator
{
    __New(predicate, iterable)
    {
        this.Predicate := AhkStdlibItertoolsNormalizeCallable(predicate)
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.Done := false
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("takewhile", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            iterator := self.Iterator
            nextItem := unset
            if !iterator(&nextItem)
                return false

            if !IsObject(self.Predicate) || !HasMethod(self.Predicate, "Call")
                throw TypeError("'" AhkStdlibItertoolsPythonTypeName(self.Predicate) "' object is not callable", -1)
            if !AhkStdlibTruthValue(self.Predicate.Call(nextItem)) {
                self.Done := true
                return false
            }

            value := nextItem
            return true
        }
    }
}

class AhkStdlibItertoolsDropwhileIterator
{
    __New(predicate, iterable)
    {
        this.Predicate := AhkStdlibItertoolsNormalizeCallable(predicate)
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.Dropping := true
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("dropwhile", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            iterator := self.Iterator
            loop {
                nextItem := unset
                if !iterator(&nextItem)
                    return false

                if self.Dropping {
                    if !IsObject(self.Predicate) || !HasMethod(self.Predicate, "Call")
                        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(self.Predicate) "' object is not callable", -1)
                    if AhkStdlibTruthValue(self.Predicate.Call(nextItem))
                        continue
                    self.Dropping := false
                }

                value := nextItem
                return true
            }
        }
    }
}

class AhkStdlibItertoolsFilterfalseIterator
{
    __New(predicate, iterable)
    {
        this.Predicate := AhkStdlibItertoolsNormalizeCallable(predicate)
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("filterfalse", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            iterator := self.Iterator
            loop {
                nextItem := unset
                if !iterator(&nextItem)
                    return false

                if AhkStdlibIsNone(self.Predicate) {
                    keepItem := !AhkStdlibTruthValue(nextItem)
                } else {
                    if !IsObject(self.Predicate) || !HasMethod(self.Predicate, "Call")
                        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(self.Predicate) "' object is not callable", -1)
                    keepItem := !AhkStdlibTruthValue(self.Predicate.Call(nextItem))
                }

                if keepItem {
                    value := nextItem
                    return true
                }
            }
        }
    }
}

class AhkStdlibItertoolsCompress
{
    __New(data, selectors)
    {
        this.DataIterator := AhkStdlibItertoolsEnum(data)
        this.SelectorIterator := AhkStdlibItertoolsEnum(selectors)
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("compress", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            loop {
                dataIterator := self.DataIterator
                selectorIterator := self.SelectorIterator
                item := unset
                selector := unset
                if !dataIterator(&item)
                    return false
                if !selectorIterator(&selector)
                    return false
                if AhkStdlibTruthValue(selector) {
                    value := item
                    return true
                }
            }
        }
    }
}

class AhkStdlibItertoolsCount
{
    __New(start := 0, step := 1)
    {
        this.ReprStep := step
        this.ReprStepIsDefault := AhkStdlibItertoolsCountStepIsDefault(step)
        startIsRootBool := AhkStdlibIsBool(start)
        if AhkStdlibIsBool(step)
            step := step.Value ? 1 : 0
        numericStart := startIsRootBool ? (start.Value ? 1 : 0) : start
        AhkStdlibItertoolsValidateNumber(numericStart)
        AhkStdlibItertoolsValidateNumber(step)
        if startIsRootBool && !(step is Integer && step = 1) {
            this.Current := start
            this.ProgressionCurrent := numericStart
        } else {
            this.Current := numericStart
            this.ProgressionCurrent := numericStart
        }
        this.Step := step
        this.ValidatedProgression := false
    }

    __Repr()
    {
        if this.ReprStepIsDefault
            return "count(" AhkStdlibItertoolsValueRepr(this.Current) ")"
        return "count(" AhkStdlibItertoolsValueRepr(this.Current) ", " AhkStdlibItertoolsValueRepr(this.ReprStep) ")"
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if !self.ValidatedProgression {
                stdlib.operator.add(self.ProgressionCurrent, self.Step)
                self.ValidatedProgression := true
            }
            value := self.Current
            self.ProgressionCurrent := stdlib.operator.add(self.ProgressionCurrent, self.Step)
            self.Current := self.ProgressionCurrent
            return true
        }
    }
}

class AhkStdlibItertoolsRepeat
{
    __New(value, times := unset)
    {
        this.Value := value
        this.HasLimit := IsSet(times)
        if this.HasLimit {
            if AhkStdlibIsBool(times)
                times := times.Value ? 1 : 0
            AhkStdlibItertoolsValidateRepeatTimes(times)
            this.Remaining := Max(0, times)
        }
    }

    __Repr()
    {
        valueRepr := AhkStdlibItertoolsValueRepr(this.Value)
        if !this.HasLimit
            return "repeat(" valueRepr ")"
        return "repeat(" valueRepr ", " this.Remaining ")"
    }

    __LengthHint()
    {
        if !this.HasLimit
            throw TypeError("len() of unsized object", -1)
        return this.Remaining
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&out)
        {
            if self.HasLimit {
                if self.Remaining <= 0
                    return false
                self.Remaining -= 1
            }

            out := self.Value
            return true
        }
    }
}

class AhkStdlibItertoolsTeeState
{
    __New(iterator)
    {
        this.Iterator := iterator
        this.Cache := []
        this.BaseIndex := 0
        this.NextIndex := 0
        this.Exhausted := false
        this.InEnsureItem := false
        this.ClonePositions := Map()
        this.NextCloneId := 1
    }

    RegisterClone(position)
    {
        cloneId := this.NextCloneId
        this.NextCloneId += 1
        this.ClonePositions[cloneId] := position
        return cloneId
    }

    UnregisterClone(cloneId)
    {
        if this.ClonePositions.Has(cloneId)
            this.ClonePositions.Delete(cloneId)
        this.TrimCache()
    }

    SetClonePosition(cloneId, position)
    {
        if this.ClonePositions.Has(cloneId)
            this.ClonePositions[cloneId] := position
        this.TrimCache()
    }

    EnsureItem(position)
    {
        while !this.Exhausted && position >= this.NextIndex {
            if this.InEnsureItem
                throw RuntimeError("cannot re-enter the tee iterator", -1)
            this.InEnsureItem := true
            iterator := this.Iterator
            nextItem := unset
            try {
                if !iterator(&nextItem) {
                    this.Exhausted := true
                    break
                }
            } finally {
                this.InEnsureItem := false
            }
            this.Cache.Push(nextItem)
            this.NextIndex += 1
        }
        return position < this.NextIndex
    }

    GetItem(position)
    {
        return this.Cache[position - this.BaseIndex + 1]
    }

    TrimCache()
    {
        if this.ClonePositions.Count = 0 {
            this.Cache := []
            this.BaseIndex := this.NextIndex
            return
        }

        hasMinPosition := false
        minPosition := 0
        for , position in this.ClonePositions {
            if !hasMinPosition || position < minPosition {
                minPosition := position
                hasMinPosition := true
            }
        }

        discardCount := minPosition - this.BaseIndex
        if discardCount <= 0
            return
        this.Cache.RemoveAt(1, discardCount)
        this.BaseIndex := minPosition
    }
}

class AhkStdlibItertoolsTeeIterator
{
    __class__
    {
        get => AhkStdlibItertoolsTeeIterator
    }

    __New(args*)
    {
        if args.Length >= 1 && args[1] is AhkStdlibItertoolsTeeState {
            state := args[1]
            position := args.Length >= 2 ? args[2] : 0
        } else {
            if args.Length >= 2 && Type(args[2]) = "Object" && HasProp(args[2], "iterable")
                throw TypeError("_tee() takes no keyword arguments", -1)
            if args.Length != 1
                throw TypeError("_tee expected 1 argument, got " args.Length, -1)
            if Type(args[1]) = "Object" && HasProp(args[1], "iterable")
                throw TypeError("_tee() takes no keyword arguments", -1)

            iterable := args[1]
            if iterable is AhkStdlibItertoolsTeeIterator {
                state := iterable.AhkStdlibTeeState
                position := iterable.AhkStdlibTeePosition
            } else {
                iterator := AhkStdlibItertoolsEnum(iterable)
                state := AhkStdlibItertoolsTeeState(iterator)
                position := 0
            }
        }

        this.AhkStdlibTeeState := state
        this.AhkStdlibTeePosition := position
        this.AhkStdlibTeeCloneId := state.RegisterClone(position)
    }

    __Delete()
    {
        try this.AhkStdlibTeeState.UnregisterClone(this.AhkStdlibTeeCloneId)
    }

    __Repr()
    {
        return "<itertools._tee object at 0x" Format("{:X}", ObjPtr(this)) ">"
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            position := self.AhkStdlibTeePosition
            if !self.AhkStdlibTeeState.EnsureItem(position)
                return false

            value := self.AhkStdlibTeeState.GetItem(position)
            self.AhkStdlibTeePosition := position + 1
            self.AhkStdlibTeeState.SetClonePosition(self.AhkStdlibTeeCloneId, self.AhkStdlibTeePosition)
            return true
        }
    }
}

class AhkStdlibItertoolsIslice
{
    __New(iterable, start, stop, step := 1, stopWasOmitted := false)
    {
        if AhkStdlibIsNone(start)
            start := 0
        if AhkStdlibIsBool(start)
            start := start.Value ? 1 : 0
        hasUnboundedStop := AhkStdlibIsNone(stop)
        if AhkStdlibIsBool(stop)
            stop := stop.Value ? 1 : 0
        if AhkStdlibIsNone(step)
            step := 1
        if AhkStdlibIsBool(step)
            step := step.Value ? 1 : 0
        AhkStdlibItertoolsValidateIslice(start, stop, step, stopWasOmitted)
        this.Iterator := AhkStdlibItertoolsEnum(iterable)
        this.Start := start
        this.Stop := stop
        this.Step := step
        this.HasUnboundedStop := hasUnboundedStop
        this.SourceIndex := 0
        this.NextWanted := start
        this.Done := false
    }

    __Repr()
    {
        return AhkStdlibItertoolsObjectRepr("islice", this)
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            if self.Done
                return false

            if !self.HasUnboundedStop && self.NextWanted >= self.Stop {
                stopIndex := Max(self.Start, self.Stop)
                while self.SourceIndex < stopIndex {
                    iterator := self.Iterator
                    discarded := unset
                    if !iterator(&discarded)
                        break
                    self.SourceIndex += 1
                }
                self.Done := true
                return false
            }

            candidate := unset
            while self.SourceIndex <= self.NextWanted {
                iterator := self.Iterator
                if !iterator(&candidate)
                    return false
                self.SourceIndex += 1
            }

            value := candidate
            self.NextWanted += self.Step
            return true
        }
    }
}

stdlib.itertools := AhkStdlibItertools

AhkStdlibItertoolsPairwise(iterable)
{
    return AhkStdlibItertoolsPairwiseIterator(iterable)
}

AhkStdlibItertoolsCombinations(iterable, r)
{
    if AhkStdlibIsBool(r)
        r := r.Value ? 1 : 0
    AhkStdlibItertoolsValidateCombinationsRType(r)
    pool := AhkStdlibItertoolsMaterializeIterable(iterable)
    if r < 0
        throw ValueError("r must be non-negative", -1)
    return AhkStdlibItertoolsCombinationsIterator(pool, r)
}

AhkStdlibItertoolsProduct(iterables)
{
    repeat := 1
    if iterables.Length > 0 {
        trailingKeywordObjects := []
        keywordIndex := iterables.Length
        while keywordIndex >= 1 {
            candidate := iterables[keywordIndex]
            if Type(candidate) != "Object" || ObjOwnPropCount(candidate) = 0 || HasMethod(candidate, "__Enum") || HasMethod(candidate, "Call")
                break
            trailingKeywordObjects.InsertAt(1, candidate)
            keywordIndex -= 1
        }
        if trailingKeywordObjects.Length > 0 {
            duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(trailingKeywordObjects*)
            if duplicateKeyword != ""
                throw TypeError("itertools.product() got multiple values for keyword argument '" duplicateKeyword "'", -1)

            keywordCount := 0
            for , keywordObject in trailingKeywordObjects
                keywordCount += ObjOwnPropCount(keywordObject)
            if keywordCount > 1
                throw TypeError("product() takes at most 1 keyword argument (" keywordCount " given)", -1)

            for , keywordObject in trailingKeywordObjects {
                if HasProp(keywordObject, "iterables")
                    throw TypeError("'iterables' is an invalid keyword argument for product()", -1)
                if !HasProp(keywordObject, "repeat") {
                    for prop in keywordObject.OwnProps()
                        throw TypeError("'" prop "' is an invalid keyword argument for product()", -1)
                }
                repeat := keywordObject.repeat
            }
            if AhkStdlibIsBool(repeat)
                repeat := repeat.Value ? 1 : 0
            AhkStdlibItertoolsValidateProductRepeat(repeat)
            iterables := iterables.Clone()
            while iterables.Length > keywordIndex
                iterables.RemoveAt(iterables.Length)
        }
    }

    pools := []
    if repeat > 0 {
        sourcePools := []
        for , iterable in iterables
            sourcePools.Push(AhkStdlibItertoolsMaterializeIterable(iterable))
        loop repeat {
            for , pool in sourcePools
                pools.Push(pool)
        }
    }
    return AhkStdlibItertoolsProductIterator(pools)
}

AhkStdlibItertoolsZipLongest(iterables)
{
    fillValue := unset
    if iterables.Length > 0 {
        trailingKeywordObjects := []
        keywordIndex := iterables.Length
        while keywordIndex >= 1 {
            candidate := iterables[keywordIndex]
            if Type(candidate) != "Object" || ObjOwnPropCount(candidate) = 0 || HasMethod(candidate, "__Enum") || HasMethod(candidate, "Call")
                break
            trailingKeywordObjects.InsertAt(1, candidate)
            keywordIndex -= 1
        }
        if trailingKeywordObjects.Length > 0 {
            duplicateKeyword := AhkStdlibItertoolsFindDuplicateKeywordName(trailingKeywordObjects*)
            if duplicateKeyword != ""
                throw TypeError("itertools.zip_longest() got multiple values for keyword argument '" duplicateKeyword "'", -1)

            keywordCount := 0
            for , keywordObject in trailingKeywordObjects
                keywordCount += ObjOwnPropCount(keywordObject)
            if keywordCount > 1
                throw TypeError("zip_longest() got an unexpected keyword argument", -1)

            for , keywordObject in trailingKeywordObjects {
                if !HasProp(keywordObject, "fillvalue")
                    throw TypeError("zip_longest() got an unexpected keyword argument", -1)
                fillValue := keywordObject.fillvalue
            }
            iterables := iterables.Clone()
            while iterables.Length > keywordIndex
                iterables.RemoveAt(iterables.Length)
        }
    }

    if IsSet(fillValue)
        return AhkStdlibItertoolsZipLongestIterator(iterables, fillValue)
    return AhkStdlibItertoolsZipLongestIterator(iterables)
}

AhkStdlibItertoolsGroupby(iterable, key := unset)
{
    if IsSet(key)
        return AhkStdlibItertoolsGroupbyIterator(iterable, key)
    return AhkStdlibItertoolsGroupbyIterator(iterable)
}

AhkStdlibItertoolsCombinationsWithReplacement(iterable, r := unset)
{
    if !IsSet(r)
        throw TypeError("combinations_with_replacement() missing required argument 'r' (pos 2)", -1)
    if AhkStdlibIsBool(r)
        r := r.Value ? 1 : 0
    AhkStdlibItertoolsValidateCombinationsRType(r)
    pool := AhkStdlibItertoolsMaterializeIterable(iterable)
    if r < 0
        throw ValueError("r must be non-negative", -1)
    return AhkStdlibItertoolsCombinationsWithReplacementIterator(pool, r)
}

AhkStdlibItertoolsPermutations(iterable, r := unset)
{
    pool := AhkStdlibItertoolsMaterializeIterable(iterable)
    if !IsSet(r) || AhkStdlibIsNone(r)
        r := pool.Length
    else {
        if AhkStdlibIsBool(r)
            r := r.Value ? 1 : 0
        AhkStdlibItertoolsValidatePermutationsR(r)
    }
    if r < 0
        throw ValueError("r must be non-negative", -1)
    return AhkStdlibItertoolsPermutationsIterator(pool, r)
}

AhkStdlibItertoolsStarmap(func, iterable)
{
    return AhkStdlibItertoolsStarmapIterator(func, iterable)
}

AhkStdlibItertoolsTakewhile(predicate, iterable)
{
    return AhkStdlibItertoolsTakewhileIterator(predicate, iterable)
}

AhkStdlibItertoolsDropwhile(predicate, iterable)
{
    return AhkStdlibItertoolsDropwhileIterator(predicate, iterable)
}

AhkStdlibItertoolsFilterfalse(predicate, iterable)
{
    return AhkStdlibItertoolsFilterfalseIterator(predicate, iterable)
}

AhkStdlibItertoolsTee(iterable, n := 2)
{
    if Type(n) = "Object" && !HasMethod(n, "Call") && HasProp(n, "n")
        throw TypeError("itertools.tee() takes no keyword arguments", -1)
    if AhkStdlibIsBool(n)
        n := n.Value ? 1 : 0
    AhkStdlibItertoolsValidateTeeCount(n)
    if n = 0
        return AhkStdlibTuple()

    if iterable is AhkStdlibItertoolsTeeIterator
        return AhkStdlibItertoolsCloneExistingTee(iterable, n)

    iterator := AhkStdlibItertoolsEnum(iterable)
    state := AhkStdlibItertoolsTeeState(iterator)
    return AhkStdlibItertoolsBuildTeeClones(state, 0, n)
}

AhkStdlibItertoolsCloneExistingTee(iteratorClone, count)
{
    clones := []
    clones.Push(iteratorClone)
    loop count - 1
        clones.Push(AhkStdlibItertoolsTeeIterator(iteratorClone.AhkStdlibTeeState, iteratorClone.AhkStdlibTeePosition))
    return AhkStdlibTuple(clones)
}

AhkStdlibItertoolsBuildTeeClones(state, startPosition, count)
{
    clones := []
    loop count
        clones.Push(AhkStdlibItertoolsTeeIterator(state, startPosition))
    return AhkStdlibTuple(clones)
}

AhkStdlibItertoolsIsKeywordArgumentObject(value)
{
    return Type(value) = "Object"
        && ObjOwnPropCount(value) > 0
        && !AhkStdlibIsNone(value)
        && !AhkStdlibIsNotImplemented(value)
        && !HasMethod(value, "__Enum")
        && !HasMethod(value, "Call")
}

AhkStdlibItertoolsFindDuplicateKeywordName(values*)
{
    seen := Map()
    loop values.Length {
        if !values.Has(A_Index)
            continue
        value := values[A_Index]
        if !AhkStdlibItertoolsIsKeywordArgumentObject(value)
            continue
        for prop in value.OwnProps() {
            if seen.Has(prop)
                return prop
            seen[prop] := true
        }
    }
    return ""
}

AhkStdlibItertoolsContainsKeywordArgumentObject(values*)
{
    loop values.Length {
        if !values.Has(A_Index)
            continue
        value := values[A_Index]
        if AhkStdlibItertoolsIsKeywordArgumentObject(value)
            return true
    }
    return false
}

AhkStdlibItertoolsLooksLikeIsliceKeywordOptions(value)
{
    return Type(value) = "Object"
        && (HasProp(value, "start") || HasProp(value, "stop") || HasProp(value, "step"))
}

AhkStdlibItertoolsValidateIslice(start, stop, step, stopWasOmitted := false)
{
    if !(start is Integer) || start < 0
        throw ValueError("Indices for islice() must be None or an integer: 0 <= x <= sys.maxsize.", -1)
    if !AhkStdlibIsNone(stop) && (!(stop is Integer) || stop < 0) {
        if stopWasOmitted || !(stop is Integer)
            throw ValueError("Stop argument for islice() must be None or an integer: 0 <= x <= sys.maxsize.", -1)
        throw ValueError("Indices for islice() must be None or an integer: 0 <= x <= sys.maxsize.", -1)
    }
    if !(step is Integer) || step <= 0
        throw ValueError("Step for islice() must be a positive integer or None.", -1)
}

AhkStdlibItertoolsValidateNumber(value)
{
    if !(value is Number) && !AhkStdlibItertoolsIsNumericObject(value)
        throw TypeError("a number is required", -1)
}

AhkStdlibItertoolsIsNumericObject(value)
{
    return Type(value) = "AhkStdlibDecimalValue" || Type(value) = "AhkStdlibFractionsFractionValue"
}

AhkStdlibItertoolsValidateRepeatTimes(value)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibItertoolsValidateProductRepeat(value)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
    if value < 0
        throw ValueError("repeat argument cannot be negative", -1)
}

AhkStdlibItertoolsValidateTeeCount(value)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
    if value < 0
        throw ValueError("n must be >= 0", -1)
}

AhkStdlibItertoolsValidateCombinationsRType(value)
{
    if !(value is Integer)
        throw TypeError("'" AhkStdlibItertoolsPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibItertoolsValidatePermutationsR(value)
{
    if !(value is Integer)
        throw TypeError("Expected int as r", -1)
}

AhkStdlibItertoolsGroupbyKeysEqual(left, right)
{
    return stdlib.operator.eq(left, right)
}

AhkStdlibItertoolsObjectRepr(name, value)
{
    return "<itertools." name " object at 0x" Format("{:X}", ObjPtr(value)) ">"
}

AhkStdlibItertoolsCountStepIsDefault(value)
{
    if AhkStdlibIsBool(value)
        return value.Value
    return value is Integer && value = 1
}

AhkStdlibItertoolsValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if HasMethod(value, "__Repr")
        return value.__Repr()
    if HasMethod(value, "Call")
        return "<function " AhkStdlibItertoolsCallableDisplayName(value) " at 0x" Format("{:X}", ObjPtr(value)) ">"
    if value is String
        return AhkStdlibItertoolsStringRepr(value)
    if value is AhkStdlibTuple
        return AhkStdlibItertoolsTupleRepr(value)
    if value is Array
        return AhkStdlibItertoolsArrayRepr(value)
    if value is Map
        return AhkStdlibItertoolsMapRepr(value)
    if IsObject(value)
        return "<" Type(value) " object at 0x" Format("{:X}", ObjPtr(value)) ">"
    return String(value)
}

AhkStdlibItertoolsCallableDisplayName(callback)
{
    if HasProp(callback, "Name")
        return callback.Name
    return Type(callback)
}

AhkStdlibItertoolsNormalizeCallable(callback)
{
    if Type(callback) = "Func" && HasProp(callback, "Name") {
        name := callback.Name
        if RegExMatch(name, "^AhkStdlibOperator\.(.+)$", &match)
            return AhkStdlibItertoolsOperatorCallable(callback, match[1])
    }
    return callback
}

AhkStdlibItertoolsOperatorArityMessage(methodName, actual, minArgs, maxArgs)
{
    if methodName = "truth" && minArgs = 1 && maxArgs = 1
        return "_operator.truth() takes exactly one argument (" actual " given)"
    if minArgs = maxArgs
        return methodName " expected " minArgs " arguments, got " actual
    if actual < minArgs
        return methodName " expected at least " minArgs " arguments, got " actual
    return methodName " expected at most " maxArgs " arguments, got " actual
}

AhkStdlibItertoolsStringRepr(value)
{
    escaped := StrReplace(value, "\", "\\")
    escaped := StrReplace(escaped, "`n", "\n")
    escaped := StrReplace(escaped, "`r", "\r")
    escaped := StrReplace(escaped, "`t", "\t")
    escaped := StrReplace(escaped, "'", "\'")
    if InStr(escaped, "\'") && !InStr(escaped, '"')
        return '"' StrReplace(escaped, "\'", "'") '"'
    return "'" escaped "'"
}

AhkStdlibItertoolsArrayRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibItertoolsValueRepr(value))
    return "[" AhkStdlibItertoolsJoin(parts, ", ") "]"
}

AhkStdlibItertoolsTupleRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibItertoolsValueRepr(value))
    if parts.Length = 1
        return "(" parts[1] ",)"
    return "(" AhkStdlibItertoolsJoin(parts, ", ") ")"
}

AhkStdlibItertoolsMapRepr(mapping)
{
    parts := []
    for key, value in mapping
        parts.Push(AhkStdlibItertoolsValueRepr(key) ": " AhkStdlibItertoolsValueRepr(value))
    return "{" AhkStdlibItertoolsJoin(parts, ", ") "}"
}

AhkStdlibItertoolsJoin(values, separator)
{
    text := ""
    for index, value in values {
        if index > 1
            text .= separator
        text .= value
    }
    return text
}

AhkStdlibItertoolsPythonTypeName(value)
{
    typeName := Type(value)
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsBool(value)
        return "bool"
    if typeName = "AhkStdlibFractionsFractionValue"
        return "Fraction"
    if typeName = "AhkStdlibDecimalValue"
        return "decimal.Decimal"
    if typeName = "AhkStdlibTuple"
        return "tuple"
    if AhkStdlibIsNotImplemented(value)
        return "NotImplementedType"
    if value is Map
        return "dict"
    if value is Array
        return "list"
    if value is String
        return "str"
    if value is Float
        return "float"
    if value is Integer
        return "int"
    if typeName = "Func" || typeName = "BoundFunc"
        return "function"
    if IsObject(value) && typeName != "Object"
        return AhkStdlibItertoolsLeafTypeName(typeName)
    if IsObject(value)
        return "object"
    return typeName
}

AhkStdlibItertoolsLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}

AhkStdlibItertoolsEnum(iterable)
{
    if iterable is String
        return AhkStdlibItertoolsStringEnum(iterable)
    if IsObject(iterable) && HasMethod(iterable, "__Enum")
        return iterable.__Enum(1)
    throw TypeError("'" AhkStdlibItertoolsPythonTypeName(iterable) "' object is not iterable", -1)
}

AhkStdlibItertoolsStringEnum(text)
{
    index := 1
    length := StrLen(text)

    return NextChar

    NextChar(&value)
    {
        if index > length
            return false
        value := SubStr(text, index, 1)
        index += 1
        return true
    }
}

AhkStdlibItertoolsMaterializeArgs(row)
{
    return AhkStdlibItertoolsMaterializeIterable(row)
}

AhkStdlibItertoolsMaterializeIterable(iterable)
{
    values := []
    iterator := AhkStdlibItertoolsEnum(iterable)
    item := unset
    while iterator(&item)
        values.Push(item)
    return values
}

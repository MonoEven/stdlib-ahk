#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\init>

class StdlibInitTest
{
    static TestDecorateAppliesDecoratorsInAtOrder()
    {
        events := []
        value := (*) => StdlibInitDecorateValue(events)
        outer := StdlibInitDecoratorFactory("outer", events)
        inner := StdlibInitDecoratorFactory("inner", events)

        decorated := stdlib.decorate(value, outer, inner)

        AhkTest.AssertEqual("outer(inner(value))", decorated.Call())
        AhkTest.AssertEqual([
            "apply:inner",
            "apply:outer",
            "call:outer",
            "call:inner",
            "call:value"
        ], events)
    }

    static TestDecorateCanReturnClassLikeDecoratorResults()
    {
        decorated := stdlib.decorate(StdlibInitDecorateTarget, (target) => {
            target: target,
            label: "decorated"
        })

        AhkTest.AssertEqual("decorated", decorated.label)
        AhkTest.AssertSame(StdlibInitDecorateTarget, decorated.target)
    }
}

class StdlibInitDecorateTarget
{
}

StdlibInitDecoratorFactory(label, events)
{
    return (target) => StdlibInitDecoratorApply(label, events, target)
}

StdlibInitDecoratorApply(label, events, target)
{
    events.Push("apply:" label)
    return (*) => StdlibInitDecoratorCall(label, events, target)
}

StdlibInitDecoratorCall(label, events, target)
{
    events.Push("call:" label)
    return label "(" target.Call() ")"
}

StdlibInitDecorateValue(events)
{
    events.Push("call:value")
    return "value"
}

AhkTest.Collect(StdlibInitTest)

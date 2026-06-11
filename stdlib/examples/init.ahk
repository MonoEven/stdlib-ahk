#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\asyncio>
#Include <stdlib\toml>

init_example_data := stdlib.toml.loads("name = `"stdlib`"`n[features]`nnamespace = true")
init_example_name := init_example_data["name"]
init_example_text := stdlib.toml.dumps(Map("name", init_example_name, "items", ["init", "toml"]))
init_example_none := stdlib.None
init_example_notimplemented := stdlib.NotImplemented
init_example_notimplemented_error := stdlib.NotImplementedError("todo")
init_example_runtime_error := stdlib.RuntimeError("boom")
init_example_stop_iteration := stdlib.StopIteration("done")
init_example_system_error := stdlib.SystemError("internal")
init_example_key_error := stdlib.KeyError("missing")
init_example_overflow_error := stdlib.OverflowError("too large")
init_example_eof_error := stdlib.EOFError("read() didn't return enough bytes")
init_example_process_lookup_error := stdlib.ProcessLookupError("")
init_example_true := stdlib.True
init_example_false := stdlib.False
init_example_tuple := stdlib.tuple("ab")
init_example_empty_tuple := stdlib.tuple()
init_example_slice := stdlib.slice(1, 5, 2)
init_example_slice_indices := init_example_slice.indices(6)
init_example_slice_repr := init_example_slice.__Repr()
init_example_await_result := stdlib.await(InitExampleAwaitBody())
init_example_decorator_events := []
init_example_decorated := stdlib.decorate(
    (*) => InitExampleDecoratedValue(init_example_decorator_events),
    InitExampleDecorator("outer", init_example_decorator_events),
    InitExampleDecorator("inner", init_example_decorator_events)
)
init_example_decorated_result := init_example_decorated.Call()
init_example_decorated_class := stdlib.decorate(InitExampleDecoratedTarget, (target) => {
    target: target,
    label: "decorated"
})

class InitExampleAwaitBody
{
    __New()
    {
        this.StepIndex := 0
    }

    AhkStdlibAsyncioStep(task, value := unset)
    {
        if this.StepIndex = 0 {
            this.StepIndex += 1
            return stdlib.asyncio.sleep(0, "slept")
        }
        return "await-result"
    }
}

class InitExampleDecoratedTarget
{
}

InitExampleDecorator(label, events)
{
    return (target) => InitExampleDecoratorApply(label, events, target)
}

InitExampleDecoratorApply(label, events, target)
{
    events.Push("apply:" label)
    return (*) => InitExampleDecoratorCall(label, events, target)
}

InitExampleDecoratorCall(label, events, target)
{
    events.Push("call:" label)
    return label "(" target.Call() ")"
}

InitExampleDecoratedValue(events)
{
    events.Push("call:value")
    return "value"
}

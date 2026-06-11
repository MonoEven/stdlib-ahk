#Requires AutoHotkey v2.0

#Include <stdlib\contextlib>
#Include <stdlib\io>

nullctx := stdlib.contextlib.nullcontext("seed")
closer := StdlibContextlibExampleCloser()
suppressCtx := stdlib.contextlib.suppress(ValueError)

closingCtx := stdlib.contextlib.closing(closer)
value := nullctx.__enter()
closedBefore := closer.closed
sameObject := closingCtx.__enter()
sawSuppressed := suppressCtx.__exit(ValueError, ValueError("x", -1), stdlib.None)
closingCtx.__exit(stdlib.None, stdlib.None, stdlib.None)

contextlib_example_events := []
contextlib_example_stream := stdlib.io.StringIO()
contextlib_example_redirect := stdlib.contextlib.redirect_stdout(contextlib_example_stream)
contextlib_example_redirect_target := contextlib_example_redirect.__enter()
contextlib_example_redirect.write("captured")
contextlib_example_redirect_exit := contextlib_example_redirect.__exit(stdlib.None, stdlib.None, stdlib.None)

contextlib_example_stack := stdlib.contextlib.ExitStack()
contextlib_example_stack.callback(ContextlibExampleCallback, contextlib_example_events, "one")
contextlib_example_stack.callback(ContextlibExampleCallback, contextlib_example_events, "two")
contextlib_example_stack_entered := contextlib_example_stack.enter_context(ContextlibExampleStackContext(contextlib_example_events))
contextlib_example_stack_exit := contextlib_example_stack.__exit(stdlib.None, stdlib.None, stdlib.None)

contextlib_example_decorator := stdlib.contextlib.ContextDecorator(ContextlibExampleDecoratorCore(contextlib_example_events))
contextlib_example_decorated := contextlib_example_decorator.Call((value) => ContextlibExampleDecoratedCall(contextlib_example_events, value))
contextlib_example_decorated_result := contextlib_example_decorated.Call(21)

if !IsSet(AhkTest) {
    contextlib_example_output := "nullcontext=" value
        . "`nclosing same=" (sameObject == closer ? "yes" : "no")
        . "`nclosed before=" (closedBefore ? "yes" : "no")
        . "`nclosed after=" (closer.closed ? "yes" : "no")
        . "`nsuppressed=" (sawSuppressed ? "yes" : "no")
        . "`nredirected=" contextlib_example_stream.getvalue()
        . "`nstack entered=" contextlib_example_stack_entered
        . "`ndecorated=" contextlib_example_decorated_result
    FileAppend contextlib_example_output "`n", "*", "UTF-8"
}

class StdlibContextlibExampleCloser
{
    __New()
    {
        this.closed := false
    }

    close()
    {
        this.closed := true
    }
}

class ContextlibExampleStackContext
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("enter")
        return "entered"
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

class ContextlibExampleDecoratorCore
{
    __New(events)
    {
        this.events := events
    }

    __enter()
    {
        this.events.Push("decorator-enter")
        return this
    }

    __exit(excType, exc, tb)
    {
        this.events.Push(["decorator-exit", AhkStdlibIsNone(excType) ? stdlib.None : excType])
        return false
    }
}

ContextlibExampleCallback(events, label)
{
    events.Push(["callback", label])
}

ContextlibExampleDecoratedCall(events, value)
{
    events.Push(["decorated-call", value])
    return value * 2
}

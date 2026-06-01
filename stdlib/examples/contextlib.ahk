#Requires AutoHotkey v2.0

#Include <stdlib\contextlib>

nullctx := stdlib.contextlib.nullcontext("seed")
closer := StdlibContextlibExampleCloser()
suppressCtx := stdlib.contextlib.suppress(ValueError)

closingCtx := stdlib.contextlib.closing(closer)
value := nullctx.__enter__()
closedBefore := closer.closed
sameObject := closingCtx.__enter__()
sawSuppressed := suppressCtx.__exit__(ValueError, ValueError("x", -1), stdlib.None)
closingCtx.__exit__(stdlib.None, stdlib.None, stdlib.None)

MsgBox "nullcontext=" value
    . "`nclosing same=" (sameObject == closer ? "yes" : "no")
    . "`nclosed before=" (closedBefore ? "yes" : "no")
    . "`nclosed after=" (closer.closed ? "yes" : "no")
    . "`nsuppressed=" (sawSuppressed ? "yes" : "no")

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

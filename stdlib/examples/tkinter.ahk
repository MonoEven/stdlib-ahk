#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

tkinter_example_tcl_version := stdlib.tkinter.TclVersion
tkinter_example_tk_version := stdlib.tkinter.TkVersion
tkinter_example_readable := stdlib.tkinter.READABLE
tkinter_example_writable := stdlib.tkinter.WRITABLE
tkinter_example_exception := stdlib.tkinter.EXCEPTION

tkinter_example_interp := stdlib.tkinter.Tcl()
tkinter_example_interp_type := Type(tkinter_example_interp)
tkinter_example_eval := tkinter_example_interp.eval("expr 1 + 2")
tkinter_example_setvar_return := tkinter_example_interp.setvar("x", "hello")
tkinter_example_getvar := tkinter_example_interp.getvar("x")
tkinter_example_root_string := String(tkinter_example_interp._root())

tkinter_example_tk_interp := stdlib.tkinter.Tcl({ useTk: stdlib.True })
tkinter_example_winfo_command := tkinter_example_tk_interp.eval("info commands winfo")
tkinter_example_tk_package := tkinter_example_tk_interp.eval("package require Tk")

tkinter_example_named := stdlib.tkinter.StringVar(tkinter_example_interp, "seed", "custom_name")
tkinter_example_named_name := tkinter_example_named._name
tkinter_example_named_get := tkinter_example_named.get()
tkinter_example_named_set_return := tkinter_example_named.set("grown")
tkinter_example_named_after_set := tkinter_example_named.get()

tkinter_example_generated := stdlib.tkinter.StringVar(tkinter_example_interp, "fresh")
tkinter_example_generated_name := tkinter_example_generated._name
tkinter_example_generated_get := tkinter_example_generated.get()

tkinter_example_missing_error := ""
try {
    tkinter_example_interp.getvar("missing")
} catch Error as err {
    if err is stdlib.tkinter.TclError
        tkinter_example_missing_error := err.Message
}

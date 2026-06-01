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
tkinter_example_setvar_none_return := tkinter_example_interp.setvar("none_value", stdlib.None)
tkinter_example_getvar_none := tkinter_example_interp.getvar("none_value")
tkinter_example_root_string := String(tkinter_example_interp._root())

tkinter_example_tk_interp := stdlib.tkinter.Tcl({ useTk: stdlib.True })
tkinter_example_winfo_command := tkinter_example_tk_interp.eval("info commands winfo")
tkinter_example_tk_package := tkinter_example_tk_interp.eval("package require Tk")

tkinter_example_root := stdlib.tkinter.Tk()
try {
    tkinter_example_root.eval("wm withdraw .")
    tkinter_example_root_title_before := tkinter_example_root.title()
    tkinter_example_root_title_return := tkinter_example_root.title("Stdlib Example")
    tkinter_example_root_title_after := tkinter_example_root.title()
    tkinter_example_root_type := Type(tkinter_example_root)
    tkinter_example_root_string := String(tkinter_example_root)
    tkinter_example_root_exists := tkinter_example_root.eval("winfo exists .")

    tkinter_example_frame := stdlib.tkinter.Frame(tkinter_example_root, { name: "host" })
    tkinter_example_label := stdlib.tkinter.Label(tkinter_example_root, { text: "Hello" })
    tkinter_example_button := stdlib.tkinter.Button(tkinter_example_frame, { text: "Press" })
    tkinter_example_label_text := tkinter_example_label.cget("text")
    tkinter_example_label_configure_return := tkinter_example_label.configure({ text: "Changed" })
    tkinter_example_label_after_configure := tkinter_example_label.cget("text")
    tkinter_example_frame_pack_return := tkinter_example_frame.pack()
    tkinter_example_label_pack_return := tkinter_example_label.pack()
    tkinter_example_button_pack_return := tkinter_example_button.pack()
    tkinter_example_label_manager := tkinter_example_label.winfo_manager()
    tkinter_example_button_exists := tkinter_example_button.winfo_exists()

    tkinter_example_root_destroy_return := tkinter_example_root.destroy()
} finally {
    try tkinter_example_root.destroy()
}

tkinter_example_named := stdlib.tkinter.StringVar(tkinter_example_interp, "seed", "custom_name")
tkinter_example_named_name := tkinter_example_named._name
tkinter_example_named_string := String(tkinter_example_named)
tkinter_example_named_get := tkinter_example_named.get()
tkinter_example_named_set_return := tkinter_example_named.set("grown")
tkinter_example_named_after_set := tkinter_example_named.get()
tkinter_example_named_set_none_return := tkinter_example_named.set(stdlib.None)
tkinter_example_named_after_none := tkinter_example_named.get()

tkinter_example_variable := stdlib.tkinter.Variable(tkinter_example_interp, "seed", "custom_var")
tkinter_example_variable_name := tkinter_example_variable._name
tkinter_example_variable_string := String(tkinter_example_variable)
tkinter_example_variable_get := tkinter_example_variable.get()
tkinter_example_variable_initialize_return := tkinter_example_variable.initialize("fresh")
tkinter_example_variable_after_initialize := tkinter_example_variable.get()

tkinter_example_generated := stdlib.tkinter.StringVar(tkinter_example_interp, "fresh")
tkinter_example_generated_name := tkinter_example_generated._name
tkinter_example_generated_get := tkinter_example_generated.get()

tkinter_example_int := stdlib.tkinter.IntVar(tkinter_example_interp, 7, "custom_int")
tkinter_example_int_name := tkinter_example_int._name
tkinter_example_int_get := tkinter_example_int.get()
tkinter_example_int_set_return := tkinter_example_int.set("3.5")
tkinter_example_int_after_set := tkinter_example_int.get()

tkinter_example_double := stdlib.tkinter.DoubleVar(tkinter_example_interp, 1.25, "custom_double")
tkinter_example_double_name := tkinter_example_double._name
tkinter_example_double_get := tkinter_example_double.get()
tkinter_example_double_set_return := tkinter_example_double.set(2)
tkinter_example_double_after_set := tkinter_example_double.get()

tkinter_example_bool := stdlib.tkinter.BooleanVar(tkinter_example_interp, stdlib.True, "custom_bool")
tkinter_example_bool_name := tkinter_example_bool._name
tkinter_example_bool_get := tkinter_example_bool.get()
tkinter_example_bool_set_return := tkinter_example_bool.set("off")
tkinter_example_bool_after_set := tkinter_example_bool.get()

tkinter_example_missing_error := ""
try {
    tkinter_example_interp.getvar("missing")
} catch Error as err {
    if err is stdlib.tkinter.TclError
        tkinter_example_missing_error := err.Message
}

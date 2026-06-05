# stdlib for AutoHotkey v2

A Python 3.10-inspired standard library for AutoHotkey v2.

`stdlib` rebuilds common standard-library modules behind a predictable
`#Include <stdlib\...>` surface, with focused behavior tests and examples for
each promoted module.

## Requirements

`stdlib` requires AutoHotkey v2.0.5 or later because several modules depend on
`unset`-related language features. It is currently developed and tested with
AutoHotkey v2.0.26 and v2.1-alpha.30.

The `stdlib.tkinter` slice includes bundled Tcl/Tk runtime DLLs
(`tcl86t.dll` and `tk86t.dll`) for `useTk` support. Their CPython 3.10.11
source and SHA256 verification report are tracked in
`stdlib\tkinter\lib\README.md` and `stdlib\tkinter\lib\SHA256SUMS`.

For a standalone live GUI demo, run `stdlib\examples\tkinter_gui.ahk`.

## Quick Start

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

root := stdlib.tkinter.Tk()
root.title("stdlib tkinter demo")

count := 0
name := stdlib.tkinter.StringVar(root, "AutoHotkey")
status := stdlib.tkinter.StringVar(root, "Ready")
progressValue := stdlib.tkinter.DoubleVar(root, 0)
stepValue := stdlib.tkinter.StringVar(root, "20")

frame := stdlib.tkinter.ttk.LabelFrame(root, { text: "Python-style tkinter" })
frame.grid({ row: 0, column: 0, padx: 16, pady: 16, sticky: "nsew" })

stdlib.tkinter.ttk.Label(frame, { text: "Name" })
    .grid({ row: 0, column: 0, padx: 6, pady: 6, sticky: "w" })
entry := stdlib.tkinter.ttk.Entry(frame, { textvariable: name, width: 24 })
entry.validate()
entry.xview_moveto(["0.5"])
entry.grid({ row: 0, column: 1, padx: 6, pady: 6, sticky: "ew" })
spin := stdlib.tkinter.ttk.Spinbox(frame, {
    from_: 10,
    to: 50,
    increment: 10,
    textvariable: stepValue,
    width: 6
})
spin.xview_scroll(["1"], "units")
spin.grid({ row: 0, column: 2, padx: 6, pady: 6, sticky: "ew" })

progress := stdlib.tkinter.ttk.Progressbar(frame, {
    orient: "horizontal",
    length: 180,
    mode: "determinate",
    maximum: 100,
    variable: progressValue
})
progress.grid({ row: 1, column: 0, columnspan: 2, padx: 6, pady: 6, sticky: "ew" })

canvas := stdlib.tkinter.Canvas(frame, { width: 240, height: 90, bg: "white" })
canvas.grid({ row: 2, column: 0, columnspan: 2, padx: 6, pady: 6 })
bar := canvas.create_rectangle(10, 55, 10, 75, { fill: "steelblue", outline: "steelblue" })
caption := canvas.create_text(12, 20, { text: "Click Update", anchor: "nw", fill: "gray20" })
canvas.xview_moveto(["0.0"])
canvas.yview("moveto", stdlib.tuple(["0.0"]))
canvas.scan_mark(stdlib.tuple(["20"]), 20)
canvas.scan_dragto(["10"], stdlib.tuple(["10"]), stdlib.None)

paned := stdlib.tkinter.ttk.Panedwindow(frame, { orient: "horizontal", height: 72 })
paned.grid({ row: 3, column: 0, columnspan: 2, padx: 6, pady: 6, sticky: "ew" })
leftPane := stdlib.tkinter.ttk.Frame(paned)
rightPane := stdlib.tkinter.ttk.Frame(paned)
paned.add(leftPane, { weight: 1 })
paned.add(rightPane, { weight: 2 })
scratchPane := stdlib.tkinter.ttk.Frame(paned)
paned.add(scratchPane, { weight: 0 })
paned.remove(scratchPane)
rawHost := stdlib.tkinter.ttk.Widget(leftPane, "ttk::frame", {
    padding: [4, 2],
    style: "Demo.TFrame"
})
rawHost.grid({ row: 0, column: 0, padx: 8, pady: 4, sticky: "ew" })
stdlib.tkinter.ttk.Label(rawHost, { text: "ttk widgets" })
    .grid({ row: 0, column: 0, padx: 8, pady: 8 })
rawHost.state(["disabled"])
rawHost.instate(["disabled"], stdlib.None, "ignored")
rawHost.state(["!disabled"])
rawHost.identify(["5"], 5)
style := stdlib.tkinter.ttk.Style(root)
style.configure("Demo.TFrame", { padding: 4 })
style.configure("Demo.Treeview", { rowheight: 24, foreground: "navy" })
style.configure("Demo.Treeview", stdlib.None)
style.configure("Demo.Treeview", "")
style.lookup("Demo.Treeview", "foreground", 0, "navy")
style.map("Demo.Treeview", { foreground: [["selected", "white"]] })
style.map("Demo.Treeview", stdlib.None)
style.map("Demo.Treeview", [])
style.layout("Treeview", stdlib.None)
style.layout("Demo.Empty.Treeview", [])
style.element_create("DemoClone.field_" A_TickCount "_" Random(100000, 999999), "from", style.theme_use(), "Treeview.field")
style.theme_settings(style.theme_use(), Map(
    "DemoSettingsClone.field_" A_TickCount "_" Random(100000, 999999),
    Map("element create", ["from", style.theme_use(), "Treeview.field"])
))
demoTheme := "demo_theme_" A_TickCount "_" Random(100000, 999999)
style.theme_create(demoTheme "_scratch", "")
style.theme_create([demoTheme "_sequence"], [style.theme_use()])
style.theme_create(demoTheme, style.theme_use(), Map(
    "Demo.TFrame", { configure: { padding: 4 } },
    "Demo.Treeview", { configure: { rowheight: 24, foreground: "navy" } }
))
style.theme_settings([style.theme_use()], Map(
    "Demo.Sequence.Treeview", { configure: { rowheight: 28 } }
))
style.theme_use(demoTheme)
style.theme_use([demoTheme])
tree := stdlib.tkinter.ttk.Treeview(leftPane, {
    columns: ["value"],
    show: ["tree", "headings"],
    height: 2,
    style: "Demo.Treeview"
})
tree.heading("#0", { text: "Item" })
tree.heading("value", { text: "Value" })
tree.column("value", { width: 80, anchor: "center" })
tree.insert("", "end", "updates", { text: "Updates", values: [0], tags: ["dynamic"] })
tree.insert("", "end", "last", { text: "Last value", values: ["Ready"] })
tree.insert("", "end", "scratch_a", { text: "Scratch", values: ["A"] })
tree.insert("", "end", "scratch_b", { text: "Scratch", values: ["B"] })
tree.delete("scratch_a", "scratch_b")
tree.tag_configure("dynamic", { foreground: "navy" })
tree.tag_configure("alert", { foreground: "firebrick" })
tree.tag_bind("dynamic", "<Button-1>", tree_row_clicked)
tree.detach("last")
tree.reattach("last", "", "end")
tree.set_children("", "updates", "last")
tree.heading("value", stdlib.None)
tree.column("value", stdlib.None)
tree.item("updates", stdlib.None)
tree.selection_set(["updates"])
tree.selection_toggle(["last"])
tree.xview("scroll", ["1"], "units")
tree.yview_moveto(["0.0"])
tree.grid({ row: 1, column: 0, padx: 8, pady: 4, sticky: "nsew" })
treeScroll := stdlib.tkinter.ttk.Scrollbar(leftPane, {
    orient: "vertical",
    command: (args*) => tree.yview(args*)
})
tree.configure({ yscrollcommand: (args*) => treeScroll.set(args*) })
treeScroll.grid({ row: 1, column: 1, pady: 4, sticky: "ns" })
stdlib.tkinter.ttk.Label(rightPane, { text: "Canvas + variables + callbacks" })
    .grid({ row: 0, column: 0, padx: 8, pady: 8 })
actionMenu := stdlib.tkinter.Menu(root, { tearoff: false })
actionMenu.add_command({ label: "Mark ready", command: mark_ready })
menuButton := stdlib.tkinter.ttk.Menubutton(rightPane, {
    text: "Actions",
    menu: actionMenu,
    direction: "below"
})
menuButton.grid({ row: 1, column: 0, padx: 8, pady: 4, sticky: "e" })
choice := stdlib.tkinter.StringVar(root, "one")
choiceMenu := stdlib.tkinter.ttk.OptionMenu(
    rightPane,
    choice,
    "one",
    "two",
    "three",
    { command: choose_mode }
)
choiceMenu.set_menu("", "draft", "review")
choiceMenu.set_menu("one", "two", "three")
choiceMenu.grid({ row: 2, column: 0, padx: 8, pady: 4, sticky: "e" })
labeledValue := stdlib.tkinter.IntVar(root, 3)
labeledScale := stdlib.tkinter.ttk.LabeledScale(rightPane, {
    variable: labeledValue,
    from_: 1,
    to: 5,
    compound: "bottom"
})
labeledScale.grid({ row: 3, column: 0, padx: 8, pady: 4, sticky: "ew" })
notebook := stdlib.tkinter.ttk.Notebook(rightPane, { height: 54 })
firstPage := stdlib.tkinter.ttk.Frame(notebook)
secondPage := stdlib.tkinter.ttk.Frame(notebook)
notebook.add(firstPage, { text: "One", padding: 4 })
notebook.add(secondPage, { text: "Two" })
notebook.tab(firstPage, stdlib.None)
notebook.grid({ row: 4, column: 0, padx: 8, pady: 4, sticky: "ew" })
stdlib.tkinter.ttk.Sizegrip(rightPane)
    .grid({ row: 5, column: 0, padx: 8, pady: 4, sticky: "e" })

mark_ready(*) {
    global status
    status.set("Menu ready")
}

choose_mode(value) {
    global status
    status.set("Selected " value)
}

tree_row_clicked(event) {
    global status
    status.set("Tree row clicked at " event.x ", " event.y)
    return stdlib.None
}

update_demo(*) {
    global count, name, status, progressValue, stepValue, canvas, bar, caption, tree
    count += 1
    percent := Mod(count * Integer(stepValue.get()), 120)
    if (percent = 0)
        percent := 100
    progressValue.set(percent)
    dynamicRows := tree.tag_has("dynamic")
    status.set("Hello " name.get() " - " percent "%, tagged " dynamicRows.Length)
    canvas.coords(bar, 10, 55, 10 + percent * 2, 75)
    canvas.itemconfigure(caption, { text: status.get() })
    tree.set("updates", "value", count)
    tree.set("last", "value", percent "%")
    tree.item("updates", { tags: percent >= 80 ? ["dynamic", "alert"] : ["dynamic"] })
    if Mod(count, 2)
        tree.set_children("", "last", "updates")
    else
        tree.set_children("", "updates", "last")
    tree.xview("scroll", ["1"], "units")
    tree.yview_moveto(0.0)
    tree.identify_region(["5"], 5)
    tree.identify_element(5, 5)
    tree.see("last")
}

button := stdlib.tkinter.ttk.Button(frame, { text: "Update", command: update_demo })
button.grid({ row: 4, column: 0, padx: 6, pady: 6, sticky: "ew" })
stdlib.tkinter.ttk.Label(frame, { textvariable: status })
    .grid({ row: 4, column: 1, padx: 6, pady: 6, sticky: "w" })

frame.columnconfigure(1, { weight: 1 })
root.columnconfigure(0, { weight: 1 })
root.mainloop()
```

## Design Rules

- Public includes use `#Include <stdlib\module>`.
- Public calls use `stdlib.module.func(...)` or `stdlib.module.Class(...)`.
- Module paths mirror Python 3.10 `Lib` module paths where practical.
- `stdlib\init.ahk` is a lightweight namespace root, not a dynamic import loader.
- Promoted modules must have behavior coverage under `stdlib\tests`.
- Keep README stable and user-facing; module promotion and gate-history notes
  live in `docs\stdlib-architecture.md`.

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

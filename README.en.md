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

frame := stdlib.tkinter.ttk.LabelFrame(root, { text: "Python-style tkinter" })
frame.grid({ row: 0, column: 0, padx: 16, pady: 16, sticky: "nsew" })

stdlib.tkinter.ttk.Label(frame, { text: "Name" })
    .grid({ row: 0, column: 0, padx: 6, pady: 6, sticky: "w" })
entry := stdlib.tkinter.ttk.Entry(frame, { textvariable: name, width: 24 })
entry.grid({ row: 0, column: 1, padx: 6, pady: 6, sticky: "ew" })

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

paned := stdlib.tkinter.ttk.Panedwindow(frame, { orient: "horizontal", height: 72 })
paned.grid({ row: 3, column: 0, columnspan: 2, padx: 6, pady: 6, sticky: "ew" })
leftPane := stdlib.tkinter.ttk.Frame(paned)
rightPane := stdlib.tkinter.ttk.Frame(paned)
paned.add(leftPane, { weight: 1 })
paned.add(rightPane, { weight: 2 })
stdlib.tkinter.ttk.Label(leftPane, { text: "ttk widgets" })
    .grid({ row: 0, column: 0, padx: 8, pady: 8 })
stdlib.tkinter.ttk.Label(rightPane, { text: "Canvas + variables + callbacks" })
    .grid({ row: 0, column: 0, padx: 8, pady: 8 })
stdlib.tkinter.ttk.Sizegrip(rightPane)
    .grid({ row: 1, column: 0, padx: 8, pady: 4, sticky: "e" })

update_demo(*) {
    global count, name, status, progressValue, canvas, bar, caption
    count += 1
    percent := Mod(count * 20, 120)
    if (percent = 0)
        percent := 100
    progressValue.set(percent)
    status.set("Hello " name.get() " - " percent "%")
    canvas.coords(bar, 10, 55, 10 + percent * 2, 75)
    canvas.itemconfigure(caption, { text: status.get() })
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

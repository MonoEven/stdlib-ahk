# stdlib for AutoHotkey v2

A Python 3.10-inspired standard library for AutoHotkey v2.

`stdlib` rebuilds common standard-library modules behind a predictable
`#Include <stdlib\...>` surface, with focused behavior tests and examples for
each promoted module.

## Requirements

`stdlib` requires AutoHotkey v2.0.5 or later because several modules depend on
`unset`-related language features.
The `stdlib.tkinter` slice includes bundled Tcl/Tk runtime DLLs
(`tcl86t.dll` and `tk86t.dll`) for `useTk` support. Their CPython 3.10.11
source and SHA256 verification report are tracked in
`stdlib\tkinter\lib\README.md` and `stdlib\tkinter\lib\SHA256SUMS`.
The covered GUI surface currently includes `Tk` roots with option configuration, visibility, state, transient relationships, overrideredirect, iconify/deiconify,
geometry, and window sizing APIs, `Toplevel` windows with state, transient relationships, overrideredirect, iconify/deiconify, geometry, and sizing APIs,
`Frame`, `Label`, `Button`, `Checkbutton`, `Radiobutton`, `Scale`, `Scrollbar`, `Menu`, `Entry`, `Listbox`, `Text`, and `Canvas` widgets,
`PhotoImage` image objects, widget visibility, coordinate/size, and identity-tree queries, plus focused `pack`, `grid`, and `place` layout/info/forget/child-query/geometry
behavior, window-manager protocol callbacks, `Button` / `Checkbutton` / `Radiobutton` command callbacks through `invoke()`,
`Scale` numeric state, `Scrollbar` range state, `Menu` command entries,
`Entry` cursor and selection state, focus management, event binding and synthetic event generation,
window/widget stacking with `lift()` / `tkraise()` / `lower()`, local grab state with
`grab_set()` / `grab_release()` / `grab_current()` / `grab_status()`,
command argument bridging, Canvas drawing/image/window item creation, discovery, and movement, image-backed widget
options, and a focused `after` / `mainloop` / `quit` event-loop slice.

It is currently developed and tested with AutoHotkey v2.0.26 and v2.1-alpha.30.

## Status

This project is under active rebuild.

Current direct modules under testing:

- `collections`, `itertools`, `functools`
- `datetime`, `calendar`, `time`
- `math`, `random`, `statistics`, `decimal`, `fractions`
- `json`, `csv`, `configparser`, `re`, `toml`
- `os`, `pathlib`, `shutil`, `tempfile`, `io`
- `logging`, `queue`, `tkinter`
- `ahktest`, `assert`, `base`, `types`, `warnings`, `operator`

## Quick Start

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

## Design Rules

- Public includes use `#Include <stdlib\module>`.
- Public calls use `stdlib.module.func(...)` or `stdlib.module.Class(...)`.
- Module paths mirror Python 3.10 `Lib` module paths where practical.
- `stdlib\init.ahk` is a lightweight namespace root, not a dynamic import loader.
- Promoted modules must have behavior coverage under `stdlib\tests`.

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

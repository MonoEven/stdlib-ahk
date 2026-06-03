# AHK V2 Standard Library Architecture

This library is being rebuilt into a Python-standard-library-compatible
AutoHotkey v2 library. The behavior baseline is the local CPython runtime:
Python 3.10.11. Test infrastructure should target pytest 7.4.3 capability
parity, with AHK naming (`ahktest`, `AhkTest`, `ahk*`) instead of `pytest` or
`py*` public identifiers.

The target public include surface is `#Include <stdlib\...>`. Public module
paths must mirror Python 3.10's `Lib` module paths, with only the leading
`stdlib.` / `stdlib\` prefix added. For example, Python `Lib\bisect.py` maps to
`<stdlib\bisect>` and `stdlib.bisect`, not `stdlib.collections.bisect`.
Project-owned support modules such as `ahktest` may use root-level
`<stdlib\ahktest>` paths, but they must be marked as support surface in the
manifest instead of pretending to be Python stdlib modules.

The `stdlib` directory was reset on 2026-05-25. The restart policy is
framework-first:

1. Define Python-standard-library-like planning groups in
   `stdlib\STDLIB_FRAMEWORK.json`.
2. Mark legacy implementations as `candidate` source material.
3. Mark modules with no local implementation as `missing`.
4. Keep low-level FFI, generated bindings, and DLL-heavy code in
   `native-quarantine` until isolated.
5. Promote a module to `direct` only after adding a failing stdlib gate or
   behavior test, then migrating implementation to its Python-path-aligned
   `stdlib\...` include.

Old paths are source material during the rebuild. They are not the final
dependency shape.
Once a module has been promoted to `direct` and has behavior coverage under
`<stdlib\...>`, its old AHK entrypoint should be removed so it no longer
pollutes the shared global namespace. Unmigrated candidate sources remain as
reference material until they are promoted.

## Current Direct Surface

After the 2026-05-25 reset, the direct stdlib surface is being rebuilt in
small TDD slices. Current direct modules:

- `stdlib\init.ahk`
- `stdlib\ahktest.ahk`
- `stdlib\assert.ahk`
- `stdlib\base64.ahk`
- `stdlib\getpass.ahk`
- `stdlib\binascii.ahk`
- `stdlib\quopri.ahk`
- `stdlib\abc.ahk`
- `stdlib\base.ahk`
- `stdlib\types.ahk`
- `stdlib\operator.ahk`
- `stdlib\warnings.ahk`
- `stdlib\bisect.ahk`
- `stdlib\heapq.ahk`
- `stdlib\collections.ahk`
- `stdlib\itertools.ahk`
- `stdlib\functools.ahk`
- `stdlib\calendar.ahk`
- `stdlib\datetime.ahk`
- `stdlib\time.ahk`
- `stdlib\math.ahk`
- `stdlib\random.ahk`
- `stdlib\array.ahk`
- `stdlib\hashlib.ahk`
- `stdlib\pprint.ahk`
- `stdlib\statistics.ahk`
- `stdlib\decimal.ahk`
- `stdlib\fractions.ahk`
- `stdlib\comparser.ahk`
- `stdlib\json.ahk`
- `stdlib\keyword.ahk`
- `stdlib\string.ahk`
- `stdlib\html.ahk`
- `stdlib\textwrap.ahk`
- `stdlib\fnmatch.ahk`
- `stdlib\csv.ahk`
- `stdlib\configparser.ahk`
- `stdlib\io.ahk`
- `stdlib\re.ahk`
- `stdlib\toml.ahk`
- `stdlib\os.ahk`
- `stdlib\glob.ahk`
- `stdlib\platform.ahk`
- `stdlib\socket.ahk`
- `stdlib\pathlib.ahk`
- `stdlib\shutil.ahk`
- `stdlib\tempfile.ahk`
- `stdlib\logging.ahk`
- `stdlib\queue.ahk`
- `stdlib\asyncio.ahk`
- `stdlib\enum.ahk`
- `stdlib\copy.ahk`
- `stdlib\contextlib.ahk`
- `stdlib\secrets.ahk`
- `stdlib\uuid.ahk`
- `stdlib\inspect.ahk`
- `stdlib\tkinter.ahk`

The framework manifest currently tracks `57` total module slots: `57` direct,
`0` candidate, and `0` native-quarantine.

Current verified wrapper baseline is `stdlib/tests: 1025 passed, 0 failed, 0 errors`,
with the existing `plain fallback` stderr line from the logging bootstrap smoke
still treated as expected output rather than a failure. The latest aggregate
gate completed with `run-ahktest stdlib/tests -TimeoutSeconds 70`, reporting
1025 passed, 0 failed, and 0 errors with the known `plain fallback` stderr
line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Sizegrip`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Sizegrip` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::sizegrip"`,
reports `winfo_class() == "TSizegrip"`, and exposes `class`, `cursor`,
`style`, and `takefocus` configure keys. The covered behavior includes
`cget(...)` and `configure(...)` readback for those keys, `identify(x, y)`,
the inherited `state(statespec=None)` and
`instate(statespec, callback=None, *args)` paths, Python-observed arity
messages, non-iterable state-spec `TypeError("can only join an iterable")`,
bare-string state Tcl errors, and Tcl bad-option errors passing through
unchanged. The AHK surface implements this as a prefixed internal
`AhkStdlibTkinterSizegrip` class bound to public
`stdlib.tkinter.ttk.Sizegrip` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a `ttk.Sizegrip` inside
the `ttk.Panedwindow` demo area; root `README.md` remains an English-first,
Chinese-second entry page with no code examples. Fresh promotion evidence
includes the focused red test failing because `stdlib.tkinter.ttk` had no
`Sizegrip` property, focused green passing 1/1, `Ttk` filter passing 94/94,
full `stdlib/tests/tkinter.test.ahk` passing 157/157,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1025/1025 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Panedwindow`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Panedwindow` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::panedwindow"`,
reports `winfo_class() == "TPanedwindow"`, exposes `orient`, `width`,
`height`, `takefocus`, `cursor`, `style`, and `class` configure keys, and
returns pane paths as tuples. The covered pane behavior includes
`add(child, **kw)`, `forget(child)`, `insert(pos, child, **kw)`,
`pane(pane, option=None, **kw)`, `panes()`, `sashpos(index, newpos=None)`,
and `identify(x, y)` with Python-observed arity messages, integer `weight`
readback, `pane(..., {weight: ...})` returning `{}`, empty-pane
`sashpos(0)` raising `TclError("sash index 0 out of range")`, and Tcl bad
option errors passing through unchanged. The AHK surface implements this as a
prefixed internal `AhkStdlibTkinterPanedwindow` class bound to public
`stdlib.tkinter.ttk.Panedwindow` through `DefineProp(Get, Call)`, preserving
the fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a `ttk.Panedwindow`
container alongside ttk labels, entry, progressbar, variables, callbacks,
`grid`, and Canvas drawing; root `README.md` remains an English-first,
Chinese-second entry page with no code examples. Fresh promotion evidence
includes the focused red test failing because `stdlib.tkinter.ttk` had no
`Panedwindow` property, focused green passing 1/1, `Ttk` filter passing
93/93, full `stdlib/tests/tkinter.test.ahk` passing 156/156,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probe passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1024/1024 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The latest tkinter safety slice keeps the public `stdlib.tkinter.X` and
`stdlib.tkinter.ttk.X` class surface stable while moving classic tkinter
implementation classes off AHK's global class names. A fresh AHK parser probe
confirmed that same-name host classes such as `Menu`, `Button`, `Event`,
`Image`, and `Text` can be declared before including `stdlib\tkinter.ahk`
when the stdlib implementation classes are prefixed; a focused subprocess
regression now covers that include path and confirms
`stdlib.tkinter.Tcl() is stdlib.tkinter.Tk`,
`stdlib.tkinter.Event() is stdlib.tkinter.Event`, and
`stdlib.tkinter.EventType("4") is stdlib.tkinter.EventType` while
`stdlib.tkinter.Menu` is not the host `Menu` class. The implementation now
binds public class properties with `DefineProp(Get, Call)` shims for classic
tkinter and the renamed ttk nested classes, preserving
`stdlib.tkinter.Menu(...)` and `obj is stdlib.tkinter.Menu` while avoiding raw
top-level `class Menu extends ...` declarations. The language-specific
README tkinter demo snippets now keep the window visible with `root.mainloop()`
and exercise the covered `ttk` widgets, Tk variables, command callbacks,
`grid` layout, and Canvas drawing path instead of immediately withdrawing and
destroying a root; the root `README.md` remains a bilingual entry point that
links to the English and Chinese quick starts rather than duplicating code
examples.
A fresh Python 3.10.11 probe also confirmed that `Tk.mainloop()` returns
`None` after `root.destroy()` and that the default root is cleared, while a
direct Tcl-side `destroy .` still lets `mainloop()` return `None`; the AHK
surface now sets the default `WM_DELETE_WINDOW` protocol through a registered
callback that calls `root.destroy()` and treats the Tk `application has been
destroyed` state as normal `mainloop()` exit. Fresh gates: the focused
host-class collision regression passed 1/1, focused default-window-close
mainloop regression passed 1/1, README tkinter demo probe passed with
`/ErrorStdOut=UTF-8`, `Ttk` filter passed 91/91, full
`stdlib/tests/tkinter.test.ahk` passed 155/155,
`run-ahk-validate stdlib/examples/tkinter.ahk` passed, and aggregate
`stdlib/tests` passed 1023/1023 with `-TimeoutSeconds 70` and the known
`plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.LabelFrame`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.LabelFrame` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::labelframe"`, reports default `winfo_class()` from
the explicit class override, starts in the default empty state `()`, and
exposes `text`, `width`, `height`, `padding`, `labelanchor`, `takefocus`,
`cursor`, `style`, and `class` keys. The covered option behavior includes
string/integer/tuple-shaped cget and configure readback for those options,
`labelanchor` defaulting from `nw` to the supplied `ne`, `identify(5, 5) == ""`,
the observed bad constructor option path, plus inherited
`state(statespec := unset)` and `instate(statespec, callback := unset, args*)`
behavior for iterable state specs, current-state tuple queries, true/false
match results, callback-on-match-only behavior, `TypeError("can only join an
iterable")` for non-iterable statespec values, and raw Tcl invalid-state-name
errors for bare string statespec values. The AHK surface now covers
`stdlib.tkinter.ttk.LabelFrame(...)` for that observed
constructor/configure/query/state slice while leaving other themed widgets such
as `Treeview` and `Style` intentionally unclaimed. Fresh promotion gates include
the focused red test failing because `stdlib.tkinter.ttk` had no `LabelFrame`
property, focused green passing after exposing
`AhkStdlibTkinterTtk.LabelFrame`,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate passing, and the aggregate `stdlib/tests`
gate returning to 1021 passed, 0 failed, and 0 errors with
`-TimeoutSeconds 60` plus the known `plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Button.invoke()`, `ttk.Button.state(...)`, and
`ttk.Button.instate(...)`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Button` exposes `invoke(self)`, `state(self, statespec=None)`,
and `instate(self, statespec, callback=None, *args, **kw)` from
`tkinter.ttk.Widget`; that `invoke()` returns the command callback result with
`""` when no command is configured; that `state()` returns the current widget
state tuple when `statespec` is omitted or `None`, applies iterable state
specs such as `["disabled"]` and `["!disabled"]`, and returns the delta tuple
of changed flags; that `instate()` returns booleans for matching and
non-matching state specs and invokes the callback only on a true match; and
that non-iterable statespec values raise `TypeError("can only join an iterable")`
while bare string statespec values surface the raw Tcl state-name error such as
`TclError("Invalid state name d")`. The AHK surface now covers
`stdlib.tkinter.ttk.Button(...).invoke()`, `.state(statespec := unset)`, and
`.instate(statespec, callback := unset, args*)` for that observed slice while
keeping other themed widgets' state/instate parity intentionally unclaimed.
Fresh promotion gates include the focused red test erroring because
`AhkStdlibTkinterTtk.Button` had no `invoke` method, focused green passing 1/1
in 375ms after the themed-widget state helper and stdlib-boolean callback gate
fix, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, adjacent `Ttk`
coverage and the full `stdlib/tests/tkinter.test.ahk` gate passing, and the
aggregate `stdlib/tests` gate returning to 1016 passed, 0 failed, and 0 errors
with `-TimeoutSeconds 40` plus the known `plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Notebook`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Notebook` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::notebook"`, reports
`winfo_class() == "TNotebook"`, and exposes `width`, `height`, `padding`,
`takefocus`, `cursor`, `style`, and `class` keys. The covered widget-option
behavior includes tuple readback for `padding`, integer readback for
`takefocus`, `cursor`, `style`, and `class` cget/configure shapes, and the
observed bad constructor option path. The covered tab behavior includes empty
`tabs()`, `index("end")`, and `select()` results, `add(...)`, `insert(...)`,
`forget(...)`, `hide(...)`, `tabs()`, `index(tab_id)`, `select(None)`,
`select(tab_id)` including the disabled-tab no-op, `tab(tab_id)`,
`tab(tab_id, option)`, `tab(tab_id, **kw)`, and `enable_traversal()` return
shapes. The `tab(...)` dict/list/tuple conversion is scoped to Notebook tab
metadata so generic widget option conversion remains unchanged. Fresh probes
also captured unmanaged-tab, invalid-slave, bad-option, and representative
arity messages. `Notebook.identify(...)` plus other ttk widgets such as
`Treeview`, `Style`, `Checkbutton`, `Radiobutton`, `Scale`, `Scrollbar`,
`Spinbox`, `LabelFrame`, `Menubutton`, `Panedwindow`, and `Sizegrip` remained
unclaimed at that point. Fresh promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Notebook` property, focused green passing 1/1 in
297ms after fresh probes corrected the disabled-tab selection expectation and
confirmed `identify(1, 1) == ""` while `identify(5, 5) == "tab"` in the
withdrawn-root coverage scenario,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, adjacent `Ttk` filter
coverage passing 84/84 in 17906ms, the full `stdlib/tests/tkinter.test.ahk`
gate at 147 passed, 0 failed, and 0 errors in 19532ms, and the aggregate
`stdlib/tests` gate at 1015 passed, 0 failed, and 0 errors in 42703ms with
`-TimeoutSeconds 120` and the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Progressbar`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Progressbar` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::progressbar"`, and reports
`winfo_class() == "TProgressbar"`. The covered option behavior includes default
`orient == "horizontal"`, `mode == "determinate"`, `maximum == 100`, and
`value == 0.0`, explicit horizontal `orient`, `length`, `mode`, `maximum`,
`value`, `variable`, `style`, `takefocus`, and `cursor`, Python integer-or-float
readback for `maximum`, float readback for `value`, and `keys()` membership for
`orient`, `length`, `mode`, `maximum`, `variable`, `value`, `phase`,
`takefocus`, `cursor`, `style`, and `class`. The covered command behavior
includes `step()`, `step(amount)`, `start()`, `start(interval)`, and `stop()`
returning Python `None`, with `step(...)` updating the linked `DoubleVar` and
observed `start/stop` stepping behavior. Fresh probes also captured bad
`start`, `step`, and `stop` arity text, bad-option, bad-orient, bad-mode, and
the vertical custom-style layout TclError path. A first implementation attempt
converted generic `value` options globally; the full tkinter gate caught that
as Menu/Radiobutton regressions, and the final implementation scopes
`maximum`/`value` conversion to `ttk.Progressbar`. Fresh promotion gates
include the focused red test failing because `stdlib.tkinter.ttk` had no
`Progressbar` property, focused green passing 1/1 in 328ms and 1/1 in 282ms
after the scoped-conversion repair, adjacent `Ttk` filter coverage passing
83/83 in 12921ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 146 passed, 0 failed, and
0 errors in 19391ms, and the aggregate `stdlib/tests` gate at 1014 passed,
0 failed, and 0 errors in 31109ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Separator`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Separator` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::separator"`, and reports
`winfo_class() == "TSeparator"`. The covered option behavior includes default
`orient == "horizontal"`, explicit `orient`, `style`, `cursor`, and
`takefocus`, Python integer readback for `takefocus`, `keys()` membership for
`orient`, `takefocus`, `cursor`, `style`, and `class`, representative
`configure(...)` tuple queries including `configure("class")`, orientation
and style setters returning Python `None`, and the observed bad-option and
bad-orient TclError messages. Fresh promotion gates include the focused red
test failing because `stdlib.tkinter.ttk` had no `Separator` property, focused
green passing 1/1 in 312ms and then 1/1 in 281ms after tightening the
default-root identity assertion, adjacent `Ttk` filter coverage passing
82/82 in 25719ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 145 passed, 0 failed, and
0 errors in 27656ms, and the aggregate `stdlib/tests` gate at 1013 passed,
0 failed, and 0 errors in 47625ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Combobox`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Combobox` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::combobox"`, and reports
`winfo_class() == "TCombobox"`. The covered option behavior now includes
AHK iterable `values` serialization through a Tcl list, Python-style tuple
readback from `cget("values")` and `configure("values")`, empty `values`
readback as `""`, representative `textvariable`, `width`, `state`, and
`style` option reads, and `keys()` membership for `postcommand`, `values`,
`exportselection`, `state`, `textvariable`, `width`, `style`, and `class`.
The covered command behavior includes `current()` returning `-1` initially,
`current(index)` returning Python `None` while updating the current value and
linked `StringVar`, `get()`, and `set(value)` returning Python `None`, including
the observed `current() == -1` state after setting a value outside the values
list. Fresh probes also captured the covered bad `current(...)` TclError
messages, `Combobox.set(...)`, `Combobox.current(...)`, and inherited
`Entry.get(...)` arity text, plus bad-option construction. Full classic Entry
MRO parity for every inherited method remains intentionally unclaimed beyond
the methods exercised by this slice. Fresh promotion gates include the focused
red test failing because `stdlib.tkinter.ttk` had no `Combobox` property,
focused green passing 1/1 in 281ms, adjacent `Ttk` filter coverage passing
81/81 in 26438ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 144 passed, 0 failed, and
0 errors in 29985ms, and the aggregate `stdlib/tests` gate at 1012 passed,
0 failed, and 0 errors in 59968ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
`ttk.Entry` slice with XView and scan-command behavior. Fresh Python 3.10.11
probes confirmed that `ttk.Entry.xview()` returns the two-float view tuple,
`xview_moveto(...)` and `xview_scroll(...)` return Python `None`, raw
`xview("moveto")` without a fraction raises `TclError("bad entry index \"moveto\"")`,
and the XView helper arity errors match local Python messages. The same probe
confirmed `ttk.Entry` exposes `scan_mark(...)` and `scan_dragto(...)` Python
methods with classic `Entry` arity errors, but the underlying `ttk::entry` Tcl
command has no `scan` subcommand, so real calls raise `TclError` with
`bad command "scan": must be ... or xview`. The AHK surface now covers that
XView behavior and the themed-entry scan error path. Fresh promotion gates
include the focused red test erroring because `AhkStdlibTkinterTtk.Entry` had
no `xview` method, focused green passing 1/1 in 266ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk`
gate at 143 passed, 0 failed, and 0 errors in 37359ms, and the aggregate
`stdlib/tests` gate at 1011 passed, 0 failed, and 0 errors in 58609ms with
`-TimeoutSeconds 120` and the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
`ttk.Entry` slice with cursor and selection behavior. Fresh Python 3.10.11
probes confirmed that `ttk.Entry` preserves classic `Entry` cursor APIs for
`icursor(...)` and `index("insert")`, supports `select_present()` /
`selection_present()`, `select_range(...)` / `selection_range(...)`, and
`select_clear()` / `selection_clear()` through the `ttk::entry` Tcl command,
sets the PRIMARY selection owner so widget/root `selection_get()` returns the
selected text and `selection_own_get()` resolves to the widget, and clears
ownership through root `selection_clear()`. The same probe confirmed the
themed command only accepts `clear`, `present`, and `range`, so
`select_from(...)`, `selection_from(...)`, `select_to(...)`,
`selection_to(...)`, `select_adjust(...)`, and `selection_adjust(...)` raise
`TclError` messages such as `bad command "from": must be clear, present, or range`.
The AHK surface now covers that cursor/selection behavior while XView and
scan behavior remained intentionally unclaimed at that point. Fresh promotion
gates include the focused red test erroring because
`AhkStdlibTkinterTtk.Entry` had no `icursor` method, focused green passing
1/1 in 281ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 142 passed, 0 failed, and
0 errors in 35172ms, and the aggregate `stdlib/tests` gate at 1010 passed,
0 failed, and 0 errors in 58859ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Entry`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Entry` has signature `(master=None, widget=None, **kw)`, MRO
`Entry -> Widget -> Entry -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> XView -> object`,
`widgetName == "ttk::entry"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TEntry"`, `cget("width")`,
`cget("textvariable")`, `cget("style")`, `StringVar`-backed initial value
retention, `delete(...)` and `insert(...)` returning Python `None`,
`get()` and the linked variable reflecting inserted text, `index("end")`,
`keys()` containing `class`, `width`, `textvariable`, and `style`,
`configure("width")` and `configure("style")` tuple queries, combined
`configure(...)` width/style setters returning Python `None`,
`nametowidget(...)` identity, and the observed bad master / bad option error
text. The AHK surface now exposes `stdlib.tkinter.ttk.Entry(master=None, **kw)`
for the covered explicit-root constructor, basic input, and representative
option/configure behavior. The Python `widget` constructor parameter, full
classic-Entry MRO equivalence, selection aliases, and XView behavior remained
intentionally unclaimed at that point. Other `ttk` widgets
such as `Notebook`, `Treeview`, `Style`, `Progressbar`, and
`Separator` also remain unclaimed. Fresh promotion gates include the focused
red test failing because `stdlib.tkinter.ttk` had no `Entry` property, focused
green passing 1/1 in 281ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 141 passed,
0 failed, and 0 errors in 28235ms, and the aggregate `stdlib/tests` gate at
1009 passed, 0 failed, and 0 errors in 48828ms with `-TimeoutSeconds 120` and
the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Label`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Label` has
signature `(master=None, **kw)`, MRO
`Label -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::label"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TLabel"`, `cget("text")`,
`cget("style")`, `keys()` containing `class`, `text`, and `style`,
`configure("text")` returning the 5-tuple
`("text", "text", "Text", "", current)`, `configure("style")` returning the
5-tuple `("style", "style", "Style", "", current)`, combined
`configure(...)` text/style setters returning Python `None`,
`nametowidget(...)` identity, and the
observed bad master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Label(master=None, **kw)` for the covered explicit-root
constructor/configure behavior while keeping other `ttk` widgets such as
`Entry`, `Combobox`, `Notebook`, `Treeview`, `Style`, `Progressbar`, and
`Separator` intentionally unclaimed at that point. Fresh
promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Label` property, focused green passing 1/1 in
281ms, adjacent `ttk.Frame` and `ttk.Button` passing,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 140 passed, 0 failed, and 0 errors in
37735ms, and the aggregate `stdlib/tests` gate at 1008 passed, 0 failed, and
0 errors in 57360ms with `-TimeoutSeconds 120` and the known stderr line
`plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Frame`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Frame` has
signature `(master=None, **kw)`, MRO
`Frame -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::frame"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TFrame"`, `cget("style")`,
`keys()` containing `class` and `style`, `configure("style")` returning the
5-tuple `("style", "style", "Style", "", current)`, `configure(style=...)`
returning Python `None`, `nametowidget(...)` identity, and the observed bad
master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Frame(master=None, **kw)` for the covered default-root and
explicit-root constructor/configure behavior while keeping other `ttk` widgets
such as `Label`, `Entry`, `Combobox`, `Notebook`, `Treeview`, `Style`,
`Progressbar`, and `Separator` intentionally unclaimed at that point. Fresh
promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Frame` property, focused green passing 1/1,
adjacent `ttk.Button` passing, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 139 passed,
0 failed, and 0 errors in 29484ms, and the aggregate `stdlib/tests` gate at
1007 passed, 0 failed, and 0 errors in 62484ms with `-TimeoutSeconds 120` and
the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion opened the covered themed-widget submodule
slice with `ttk.Button`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Button` has
signature `(master=None, **kw)`, MRO
`Button -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::button"`, string path naming with explicit `name`,
`winfo_class() == "TButton"`, `cget("text")`, empty default `style`,
`keys()` containing `class` and `text`, `configure("text")` returning the
5-tuple `("text", "text", "Text", "", current)`, `configure(text=...)`
returning Python `None`, `nametowidget(...)` identity, and the observed bad
master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Button(master=None, **kw)` for the covered explicit-root
constructor and representative option/configure behavior while keeping other
then-uncovered `ttk` widgets intentionally unclaimed until focused slices cover
them. Fresh promotion gates include the focused red
test failing because `stdlib.tkinter` had no `ttk` property, focused green
passing 1/1 in 297ms, adjacent root `configure`, `Widget`, and `BaseWidget`
filters passing, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 138 passed, 0 failed, and 0
errors in 36078ms, and the aggregate `stdlib/tests` gate at 1006 passed,
0 failed, and 0 errors in 64156ms with `-TimeoutSeconds 90` and the known
stderr line `plain fallback`.

The latest tkinter public TclError promotion closes the covered public
exception-constructor slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.TclError` has no inspectable signature, has MRO
`TclError -> Exception -> BaseException -> object`, is an `Exception` but not
a `RuntimeError`, and preserves Python `Exception` argument semantics:
`TclError()` has empty string text and `args == ()`, `TclError("bad")` has
text `bad` and one argument, and multi-argument construction such as
`TclError("bad", 3)` and `TclError("bad", -1)` formats the message as the
Python tuple string while preserving all values in `.args`. The AHK surface
now exposes `stdlib.tkinter.TclError(args*)` for that covered constructor
behavior and real Tcl/Tk failures still raise `TclError` with `.args`
containing the Tcl message. Full Python `repr` parity for arbitrary object
arguments remains intentionally unclaimed until a focused slice covers it.
Fresh promotion gates include the focused red test failing with
`TclError().Message` reporting `AhkStdlibTkinter.TclError`, focused green
passing 1/1 in 47ms after the final `-1` public-argument assertion, adjacent
`IntVar`, `Widget`, and `BaseWidget` error-path filters passing,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 137 passed, 0 failed, and 0 errors in
38328ms, and the aggregate `stdlib/tests` gate at 1005 passed, 0 failed, and
0 errors in 56563ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The latest tkinter public BaseWidget promotion closes the covered base widget
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.BaseWidget(master, widgetName, cnf={}, kw={}, extra=())` signature
behavior; `BaseWidget` MRO through `Misc` without `Pack` / `Place` / `Grid`;
the missing and extra positional `BaseWidget.__init__()` TypeError text; bad
`master`, bad `cnf`, bad `kw`, bad option, bad `widgetName`, and bad
string-`extra` error text; named `label` creation under an explicit `Tk()`
root; stored `widgetName`, `master`, and `tk` attributes; `cnf` / `kw`
merging with `kw` override; `nametowidget(...)` registry lookup; and
representative `Misc` methods including `cget(...)`, `configure(...)`,
`winfo_class()`, and `destroy()`. The AHK surface now exposes
`stdlib.tkinter.BaseWidget(master, widgetName, cnf={}, kw={}, extra=())` for
that covered public constructor and representative-Misc behavior while keeping
layout methods absent from `BaseWidget`. Full `Misc` method parity and full
constructor `extra` tuple behavior remain intentionally unclaimed until their
own focused slices cover them. Fresh promotion gates include the focused red
test failing at missing `BaseWidget`, focused green passing 1/1 in 375ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, an initial full
`stdlib/tests/tkinter.test.ahk` attempt observing a transient focus identity
failure followed by focused `TestTkFocusLastforMatchesLocal310` passing, the
authoritative full tkinter rerun at 136 passed, 0 failed, and 0 errors in
26891ms, and the aggregate `stdlib/tests` gate at 1004 passed, 0 failed, and
0 errors in 52438ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The preceding tkinter public Widget promotion closes the covered generic widget
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.Widget(master, widgetName, cnf={}, kw={}, extra=())` signature
behavior; the inherited `BaseWidget.__init__()` missing and extra positional
TypeError text; bad `master`, bad `cnf`, bad `kw`, bad option, and bad
`widgetName` error text; named `label` creation under an explicit `Tk()` root;
stored `widgetName`, `master`, and `tk` attributes; `cnf` / `kw` merging with
`kw` override; `nametowidget(...)` registry lookup; and representative `pack`
layout behavior inherited by `Widget`. The AHK surface now exposes
`stdlib.tkinter.Widget(master, widgetName, cnf={}, kw={}, extra=())` for that
covered public constructor behavior. Full constructor `extra` tuple behavior
remains intentionally unclaimed until its own focused slice covers it. Fresh
promotion gates include the focused red
test failing at missing `Widget`, focused green passing 1/1 in 375ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 135 passed, 0 failed, and 0 errors in
29687ms, and the aggregate `stdlib/tests` gate at 1003 passed, 0 failed, and
0 errors in 51859ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The preceding tkinter public Image promotion closes the covered base image
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.Image(imgtype, name=None, cnf={}, master=None, **kw)` signature
behavior; missing `imgtype`, extra positional argument, no-default-root,
bad image type, bad option, bad `cnf`, and bad `master` error text; named and
generated `photo` image creation under an explicit `Tk()` root; registry
membership through `image_names()`; and base `bitmap` image creation. The AHK
surface now exposes `stdlib.tkinter.Image(imgtype, name=None, cnf={}, master=None)`
for that covered public constructor behavior, sharing the existing image
query methods `width()`, `height()`, `type()`, `configure()`, `config()`, and
string conversion. `PhotoImage(...)` and `BitmapImage(...)` remain the covered
specialized image classes for their subclass-specific methods. Fresh promotion
gates include the focused red test failing at missing `Image`, focused green
passing 1/1 in 250ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
the full `stdlib/tests/tkinter.test.ahk` gate at 134 passed, 0 failed, and
0 errors in 38828ms, the aggregate `stdlib/tests` gate timing out under
`-TimeoutSeconds 60`, and the aggregate `stdlib/tests` gate passing at
1002 passed, 0 failed, and 0 errors in 58438ms with `-TimeoutSeconds 90` and
the known stderr line `plain fallback`.

The preceding tkinter public-mixin promotion closes the covered zero-argument
constructor slice for `Pack`, `Place`, `Grid`, `XView`, `YView`, `Misc`, and
`Wm`. Fresh Python 3.10.11 probes confirmed that these public mixin classes
construct with no arguments, produce empty instances without initial `tk` or
`_w` attributes, reject extra positional arguments with
`Class() takes no arguments`, expose representative inherited methods, raise
`AttributeError("'Class' object has no attribute 'tk'")` for representative
bare `tk`-dependent methods, and return Python `None` for bare
`Misc.destroy()`. The AHK surface now exposes
`stdlib.tkinter.Pack()`, `stdlib.tkinter.Place()`, `stdlib.tkinter.Grid()`,
`stdlib.tkinter.XView()`, `stdlib.tkinter.YView()`,
`stdlib.tkinter.Misc()`, and `stdlib.tkinter.Wm()` for that covered public
constructor behavior. Full mixin method parity on bare instances remains
unclaimed beyond the representative probed methods; widget-backed inherited
method behavior remains covered by the existing widget tests. Fresh promotion
gates include the focused red test failing at missing `Pack`, focused green
passing 1/1 in 0ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
the full `stdlib/tests/tkinter.test.ahk` gate at 133 passed, 0 failed, and
0 errors in 24047ms, and the aggregate `stdlib/tests` gate at 1001 passed,
0 failed, and 0 errors in 41281ms with `-TimeoutSeconds 60` and the known
stderr line `plain fallback`.

The preceding tkinter CallWrapper promotion closes the covered public callback
adapter slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.CallWrapper(func, subst, widget)` stores `func`, `subst`, and
`widget` on the instance; calls `func(*args)` directly when `subst` is `None`;
calls `func(*subst(*args))` when `subst` is provided; expands a string returned
by `subst` into individual characters; calls `widget._report_exception()` and
returns Python `None` when either `subst` or `func` raises; and raises the
observed constructor arity `TypeError` text for missing or extra positional
arguments. The AHK surface now exposes
`stdlib.tkinter.CallWrapper(func, subst, widget)` for that covered callback
adapter behavior while preserving existing widget command callback behavior.
Fresh promotion gates include the focused red test failing at missing
`CallWrapper`, the focused green test passing 1/1 in 0ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 132 passed, 0 failed, and 0 errors in
22516ms, and the aggregate `stdlib/tests` gate at 1000 passed, 0 failed, and
0 errors in 33188ms with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter EventType promotion closes the covered public event-type
constructor slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.EventType` is a `str` / `Enum` class with 39 observed member names,
including aliases `Key` -> `KeyPress` and `Button` -> `ButtonPress`; that
calling `EventType(value)` accepts string event codes such as `"2"`, `"4"`,
`"35"`, and `"38"`; that the returned object exposes canonical `.name` and
string `.value`; that `str(member)` returns the value string; and that invalid
strings, integers, `None`, missing value, and extra positional arguments raise
the observed Python 3.10.11 `ValueError` / `TypeError` text. The AHK surface
now exposes `stdlib.tkinter.EventType(value)` for the covered value-code
constructor behavior and also preserves existing callback event objects by
giving them `.type.name`, `.type.value`, and value-string conversion. Full
enum metaclass behavior, `__members__`, member attribute access such as
`EventType.ButtonPress`, `repr(...)`, and str-subclass equality remain
intentionally unclaimed until focused slices cover them. Fresh promotion gates
include the focused red test failing at missing `EventType` in 16ms, the
focused green test passing 1/1 in 16ms and follow-up focused green passing 1/1
in 0ms after example edits, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 131 passed, 0
failed, and 0 errors in 22656ms, and the aggregate `stdlib/tests` gate at 999
passed, 0 failed, and 0 errors in 32625ms with `-TimeoutSeconds 40` and the
known stderr line `plain fallback`.

The preceding tkinter Event promotion closes the public empty event-object
constructor slice. Fresh Python 3.10.11 probes confirmed that `tkinter.Event`
has signature `()`, creates an object with an empty `__dict__`, does not
predefine `widget`, `x`, `y`, `type`, or `char`, accepts normal dynamic
attribute assignment, and raises `TypeError("Event() takes no arguments")` for
extra positional arguments. The AHK surface now exposes
`stdlib.tkinter.Event()` for that covered constructor behavior while preserving
the existing internal event-binding `Event` objects used by callbacks. The
observed CPython `Event.__repr__` path, which reads unset fields and can raise
`AttributeError`, remains intentionally unclaimed until a focused slice covers
it. Fresh promotion gates include the focused red test failing at missing
`Event` in 0ms, the focused green test passing 1/1 in 15ms and follow-up
focused green passing 1/1 in 0ms after example edits,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 130 passed, 0 failed, and 0 errors in
22766ms, and the aggregate `stdlib/tests` gate at 998 passed, 0 failed, and 0
errors in 32734ms with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter NoDefaultRoot promotion closes the covered default-root
support disabling slice. Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed
that `NoDefaultRoot()` has signature `()`, returns `None`, rejects extra
positional arguments with `NoDefaultRoot()` TypeError wording, clears an
existing `_default_root`, flips `_support_default_root` false, and then routes
covered implicit-default helpers to
`RuntimeError("No master specified and tkinter is configured to not support default root")`
while still allowing explicit `Tk()` construction. The focused AHK test runs
this behavior in a child process because the Python API intentionally changes
process-global default-root state. Fresh promotion gates include the focused
child-process red test failing at missing `NoDefaultRoot` in 219ms, the focused
green test passing 1/1 in 359ms and follow-up focused green passing 1/1 in
313ms after example edits, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 129 passed, 0
failed, and 0 errors in 22734ms, and the aggregate `stdlib/tests` gate at 997
passed, 0 failed, and 0 errors in 32375ms with `-TimeoutSeconds 40` and the
known stderr line `plain fallback`.

The preceding tkinter module-constants promotion closes the covered
non-conflicting public constant slice. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed exact values for the observed constants, including geometry (`N`,
`NE`, `NSEW`, `W`, `X`, `Y`), state (`ACTIVE`, `DISABLED`, `NORMAL`, `HIDDEN`),
selection (`SEL`, `SEL_FIRST`, `SEL_LAST`), relief/orientation/scrolling
strings, boolean-style integer aliases (`TRUE`, `FALSE`, `YES`, `NO`, `ON`,
`OFF`), and `wantobjects == 1`. The AHK surface now exposes the covered names
as module attributes while preserving the existing public constructor API.
`CHECKBUTTON` and `RADIOBUTTON` remain intentionally unclaimed because AHK
class/property lookup is case-insensitive and those uppercase Python constants
collide with the already-public `Checkbutton(...)` and `Radiobutton(...)`
constructors. Fresh promotion gates included the focused constants red test
failing at missing `ACTIVE` in 0ms, an intermediate collection failure that
proved the `CHECKBUTTON` name collision, the narrowed focused constants green
test passing 1/1 in 0ms and follow-up focused green passing 1/1 in 16ms after
example edits, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 128 passed, 0 failed, and 0
errors in 22125ms, and the aggregate `stdlib/tests` gate at 996 passed, 0
failed, and 0 errors in 31953ms with `-TimeoutSeconds 40` and the known stderr
line `plain fallback`.

The preceding tkinter module numeric-alias promotion closes the covered
module-level `getint()` / `getdouble()` slice. Fresh Python 3.10.11 probes on
Tk 8.6.12 confirmed that `tkinter.getint` is `int`, `tkinter.getdouble` is
`float`, and `tkinter.getboolean` remains a separate `(s)` function. The
covered AHK surface now matches the no-default-root Python alias behavior for
no-arg defaults, whitespace/sign handling, decimal `"09"` parsing, bool and
float inputs, and Python 3.10.11 `ValueError` / `TypeError` text for the
covered invalid inputs. Existing Tcl-backed `Tcl()` / `Tk` / widget
`getint()` and `getdouble()` conversions remain intentionally unchanged: for
example, the instance path still accepts Tcl hexadecimal integer strings and
preserves Tcl's `"09"` invalid-octal diagnostics. The two-argument
`int(x, base)` form, bytes-like inputs, and custom coercion protocols remain
unclaimed for a later focused slice. Fresh promotion gates include
the focused module-alias red test failing at missing `HasMethod` in 0ms, the
focused green test passing 1/1 in 0ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, the adjacent Tcl-backed numeric
conversion guard passing 1/1 in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 127 passed, 0 failed, and 0 errors in
22281ms, and the aggregate `stdlib/tests` gate at 995 passed, 0 failed, and 0
errors in 32437ms with `-TimeoutSeconds 40` and the known stderr line `plain
fallback`.

The preceding tkinter menu-tk-popup promotion closes the safe non-posting slice
of `Menu.tk_popup(x, y, entry='')`. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed that `tk_popup` is owned by `Menu` only, has signature
`(self, x, y, entry='')`, delegates to `self.tk.call('tk_popup', self._w, x, y,
entry)`, and produces Python 3.10.11 TypeError text for missing and extra
positional arguments plus TclError text for bad coordinate and bad-entry
values. The probe also showed that posting a real popup can block unattended
automation on this host, so this promotion intentionally claims only owner,
arity, and immediate Tcl validation behavior, not live popup posting. Fresh
promotion gates included the focused Menu command-entry red test failing at
missing `HasMethod` in 188ms, the focused green test at 1 passed in 469ms with
a follow-up focused confirmation at 1 passed in 422ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 126 passed, 0 failed, and 0
errors in 22157ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 994 passed, 0 failed, and 0 errors in
31797ms with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The earlier tkinter report-callback-exception promotion closes the root-level
custom callback exception reporter slice for `Tk.report_callback_exception()`.
Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed that
`report_callback_exception(self, exc, val, tb)` is owned by `Tk`, not `Misc`,
`BaseWidget`, or `Widget`; that missing and extra positional TypeError text
matches `Tk.report_callback_exception()`; and that CPython `CallWrapper`
routes widget command exceptions to `root.report_callback_exception(exc, val,
tb)` while the widget command returns the Python-observed `"None"` Tcl result.
The AHK promotion covers the same root override routing shape for registered
widget command callbacks by forwarding the AHK error type, value, and traceback
to the root override. CPython's default `sys.stderr` print and `sys.last_*`
side effects were observed in the probe but remain intentionally unpromoted
until they receive their own probe, failing test, fix, gate, and documentation
evidence. Fresh promotion gates include the focused report-callback red test
failing at missing `HasMethod` in 156ms, the focused green test at 1 passed in
172ms, serial callback-adjacent confirmations for `ButtonCommand` at 1 passed
in 406ms, `RegisterAndDeletecommand` at 1 passed in 141ms, `VariableTrace` at
1 passed in 15ms, and `WidgetBind` at 1 passed in 250ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 126 passed, 0 failed, and 0 errors in
21984ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 994 passed, 0 failed, and 0 errors in 32234ms
with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter readprofile promotion closes the Tcl profile-file sourcing
slice of `Tk.readprofile(baseName, className)` for `Tk()` roots. Fresh Python
3.10.11 probes on Tk 8.6.12 confirmed the `Tk.readprofile(self, baseName,
className)` signature, the CPython source lookup order of
`$HOME/.{className}.tcl`, `$HOME/.{className}.py`, `$HOME/.{baseName}.tcl`,
and `$HOME/.{baseName}.py`, Python `None` returns, no-op behavior when files
are missing, missing/extra positional TypeError text, and TclError propagation
when a sourced Tcl profile contains an invalid command. This promotion
intentionally claims only `.tcl` profile sourcing; the observed `.py` execution
path remains unpromoted until it receives its own probe, failing test, fix,
gate, and documentation evidence. Fresh promotion gates include the focused
readprofile red test failing at missing `HasMethod` in 641ms, the focused
green test at 1 passed in 844ms with a follow-up focused confirmation at 1
passed in 922ms after example edits, the full `stdlib/tests/tkinter.test.ahk`
gate at 125 passed, 0 failed, and 0 errors in 23438ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the aggregate
`stdlib/tests` gate at 993 passed, 0 failed, and 0 errors in 32469ms with
`-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter loadtk promotion closes the Tk-specific `loadtk()` method
gap on both already loaded `Tk()` roots and `Tcl()` interpreters created with
`useTk=False`. Fresh Python 3.10.11 probes confirmed `Tk.loadtk(self)`, the
CPython source guard that calls `self.tk.loadtk()` and `_loadtk()` only when
`_tkloaded` is false, no-op Python `None` returns for already loaded roots,
`Tcl()` interpreter `info commands winfo` changing from `''` before `loadtk()`
to `'winfo'` after loading, `package require Tk` returning `8.6.12`, repeated
`loadtk()` calls returning Python `None`, and extra-positional TypeError text.
Fresh promotion gates include the focused loadtk red test failing at missing
`HasMethod` in 78ms, the focused green test at 1 passed in 140ms with a
follow-up focused confirmation at 1 passed in 172ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 124 passed, 0 failed, and 0
errors in 21344ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 992 passed, 0 failed, and 0 errors in
31.407 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-iconphoto promotion closes the `Tk` / `Toplevel`
`iconphoto(default=False, *args)` / `wm_iconphoto(default=False, *args)` alias
gap in the window-manager surface. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed the `Wm.wm_iconphoto(self, default=False, *args)` signature,
`iconphoto` / `wm_iconphoto` alias identity, root and toplevel method
ownership, and the CPython source branch that forwards `-default` only when
`default` is truthy and otherwise directly forwards the image arguments.
Observed local behavior includes success returning Python `None` for root and
toplevel calls, multiple `PhotoImage` arguments, truthy non-bool defaults using
the `-default` branch, falsey `None` defaults not using that branch, first
`None` truncation in the photo argument list, TclError text for missing photo
arguments, and TclError text for non-photo image names/integers. Fresh
promotion gates include the focused wm-iconphoto red test failing at missing
`HasMethod` in 172ms, the focused green test at 1 passed in 1703ms with a
follow-up focused confirmation at 1 passed in 218ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 123 passed, 0 failed, and 0
errors in 21453ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 991 passed, 0 failed, and 0 errors in
32.391 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-attributes promotion closes the `Tk` / `Toplevel`
`attributes(*args)` / `wm_attributes(*args)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed the
`Wm.wm_attributes(self, *args)` signature, `attributes` / `wm_attributes`
alias identity, root and toplevel method ownership, and the CPython source
shape that forwards `('wm', 'attributes', self._w) + args` directly to
`tk.call`. Observed local behavior includes the Windows platform attribute
tuple `('-alpha', 1.0, '-transparentcolor', '', '-disabled', 0, '-fullscreen',
0, '-toolwindow', 0, '-topmost', 0)`, single-option getters returning typed
values such as `-alpha` as `1.0` / `0.75` floats and `-topmost` /
`-disabled` as integer flags, setter calls returning an empty string, and
TclError parity for unknown attributes, bad alpha values, missing dash option
names, and odd setter argument counts. Fresh promotion gates include the
focused wm-attributes red test failing at missing `HasMethod` in 172ms, the
focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 122 passed, 0 failed, and 0 errors in
21000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 990 passed, 0 failed, and 0 errors in 31.000
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-manage-forget promotion closes the `Tk` / `Toplevel`
`manage(widget)` / `wm_manage(widget)` and `forget(window)` /
`wm_forget(window)` alias gaps in the window-manager surface. Fresh Python
3.10.11 probes confirmed the `Wm.wm_manage(self, widget)` and
`Wm.wm_forget(self, window)` signatures, `manage` / `wm_manage` and `forget` /
`wm_forget` alias identities, root and toplevel method ownership, Python `None`
returns from both source methods, Frame-to-standalone top-level management with
`winfo manager` becoming `wm` and `wm state` becoming `normal`, forget returning
the frame to unmanaged state without destroying it, object and string-path
argument conversion, missing-window-path TclError text, missing-argument
TypeError text, extra-positional TypeError text, and the Python MRO detail that
`Toplevel.forget` resolves to `Wm.wm_forget` rather than the widget layout
`forget()` alias. Fresh promotion gates include the focused wm-manage-forget red
test failing at missing `HasMethod` in 187ms, the focused green test at 1 passed
in 172ms, the full `stdlib/tests/tkinter.test.ahk` gate at 121 passed, 0 failed,
and 0 errors in 20625ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 989 passed, 0 failed, and
0 errors in 31.907 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-iconbitmap promotion closes the `Tk` / `Toplevel`
`iconbitmap(bitmap=None, default=None)` /
`wm_iconbitmap(bitmap=None, default=None)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconbitmap(self, bitmap=None, default=None)` signature, `iconbitmap` /
`wm_iconbitmap` alias identity, root and toplevel method ownership, empty
initial getter strings, `None` preserving read semantics, built-in bitmap setter
empty-string returns, getter bitmap names after assignment, truthy `default`
branch `-default` behavior, falsey-default getter fallback, two-positional
default-wins behavior, empty-string clearing, undefined-bitmap TclError text,
and extra-positional TypeError text. Fresh promotion gates include the focused
wm-iconbitmap red test failing at missing `HasMethod` in 172ms, the focused
green test at 1 passed in 172ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 120 passed, 0 failed, and 0 errors in 20859ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
988 passed, 0 failed, and 0 errors in 31.141 seconds with `-TimeoutSeconds 40`
and the known stderr line `plain fallback`.

The preceding tkinter wm-iconmask promotion closes the `Tk` / `Toplevel`
`iconmask(bitmap=None)` / `wm_iconmask(bitmap=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconmask(self, bitmap=None)` signature, `iconmask` / `wm_iconmask`
alias identity, root and toplevel method ownership, empty initial getter
strings, `None` preserving read semantics, built-in bitmap setter empty-string
returns, getter bitmap names after assignment, empty-string clearing,
undefined-bitmap TclError text, and extra-positional TypeError text. Fresh
promotion gates include the focused wm-iconmask red test failing at missing
`HasMethod` in 188ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 119 passed, 0 failed, and 0 errors in
20828ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 987 passed, 0 failed, and 0 errors in 30.609
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconwindow promotion closes the `Tk` / `Toplevel`
`iconwindow(pathName=None)` / `wm_iconwindow(pathName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconwindow(self, pathName=None)` signature, `iconwindow` /
`wm_iconwindow` alias identity, root and toplevel method ownership, empty
initial getter strings, `None` preserving read semantics, object and string
path setter empty-string returns, getter path strings after iconwindow
assignment, empty-string clearing, non-top-level widget TclError text,
missing-window-path TclError text, and extra-positional TypeError text. Fresh
promotion gates include the focused wm-iconwindow red test failing at missing
`HasMethod` in 172ms, the focused green test at 1 passed in 157ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 118 passed, 0 failed, and 0 errors in
20750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 986 passed, 0 failed, and 0 errors in 31.187
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconposition promotion closes the `Tk` / `Toplevel`
`iconposition(x=None, y=None)` / `wm_iconposition(x=None, y=None)` alias gap in
the window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconposition(self, x=None, y=None)` signature, `iconposition` /
`wm_iconposition` alias identity, root and toplevel method ownership, initial
getter `None`, explicit `iconposition(None, None)` read semantics, two-integer
tuple getter state after setter calls, first-`None` argument truncation
preserving read semantics, empty-string clearing back to `None`, one-argument
TclError text, bad-integer TclError text, and extra-positional TypeError text.
Fresh promotion gates include the focused wm-iconposition red test failing at
missing `HasMethod` in 172ms, the focused green test at 1 passed in 156ms, the
full `stdlib/tests/tkinter.test.ahk` gate at 117 passed, 0 failed, and 0 errors
in 20516ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 985 passed, 0 failed, and 0 errors in 31.235
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-colormapwindows promotion closes the `Tk` / `Toplevel`
`colormapwindows(*wlist)` / `wm_colormapwindows(*wlist)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_colormapwindows(self, *wlist)` source shape, `colormapwindows` /
`wm_colormapwindows` alias identity, root and toplevel method presence, empty
getter list semantics, getter conversion from Tcl paths into widget objects,
single widget-object setter `None` returns, multi-window setter `None`
returns, AHK-array/list-style setter behavior matching Python list argument
conversion, `None` and empty-string clearing, string path setter handling,
literal `"None"` and missing-path TclError text. Fresh promotion gates include
the focused wm-colormapwindows red test failing at missing `HasMethod` in
172ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 116 passed, 0 failed, and 0 errors in
12468ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 984 passed, 0 failed, and 0 errors in 22.671
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-command promotion closes the `Tk` / `Toplevel`
`command(value=None)` / `wm_command(value=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_command(self, value=None)` signature, `command` / `wm_command` alias
identity, root and toplevel method presence, empty-string initial reads,
`None` preserving read semantics, string setter empty-string returns,
AHK array setter Tcl-list quoting such as `cmd {arg one}`, empty-string
clearing, and extra-positional TypeError text. Fresh promotion gates include
the focused wm-command red test failing at missing `HasMethod` in 157ms, the
focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 115 passed, 0 failed, and 0 errors in
11688ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 983 passed, 0 failed, and 0 errors in 22.578
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-group promotion closes the `Tk` / `Toplevel`
`group(pathName=None)` / `wm_group(pathName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_group(self, pathName=None)` signature, `group` / `wm_group` alias
identity, root and toplevel method presence, empty-string initial reads,
`None` preserving read semantics, widget-object and string-path setter
empty-string returns, getter path strings after group assignment, empty-string
clearing, invalid-window-path TclError text, and extra-positional TypeError
text. Fresh promotion gates include the focused wm-group red test failing at
missing `HasMethod` in 188ms, the focused green test at 1 passed in 156ms, the
full `stdlib/tests/tkinter.test.ahk` gate at 114 passed, 0 failed, and 0
errors in 11750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 982 passed, 0 failed, and 0 errors in
22.266 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-grid promotion closes the `Tk` / `Toplevel`
`grid(baseWidth=None, baseHeight=None, widthInc=None, heightInc=None)` /
`wm_grid(...)` alias gap in the window-manager surface, including the Python
MRO detail that `Tk.grid` and `Toplevel.grid` resolve to `Wm.wm_grid` rather
than the ordinary widget geometry-manager `grid()` method. Fresh Python 3.10.11
probes confirmed the `Wm.wm_grid(self, baseWidth=None, baseHeight=None,
widthInc=None, heightInc=None)` signature, `grid` / `wm_grid` alias identity,
root and toplevel method presence, unset getter `None`, 4-integer tuple getter
state after setter calls, `_tkinter.tk.call` first-`None` argument truncation,
empty-string clearing, partial-argument TclError text, invalid integer TclError
text, and extra-positional TypeError text. Fresh promotion gates include the
focused wm-grid red test failing at missing `HasMethod` in 156ms, the focused
green test at 1 passed in 172ms, the full `stdlib/tests/tkinter.test.ahk`
gate at 113 passed, 0 failed, and 0 errors in 12203ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
981 passed, 0 failed, and 0 errors in 22.312 seconds with `-TimeoutSeconds 40`
and the known stderr line `plain fallback`.

The preceding tkinter wm-aspect promotion closes the `Tk` / `Toplevel`
`aspect(minNumer=None, minDenom=None, maxNumer=None, maxDenom=None)` /
`wm_aspect(...)` alias gap in the window-manager surface. Fresh Python 3.10.11
probes confirmed the `Wm.wm_aspect(self, minNumer=None, minDenom=None,
maxNumer=None, maxDenom=None)` signature, `aspect` / `wm_aspect` alias
identity, root and toplevel method presence, unset getter `None`, 4-integer
tuple getter state after setter calls, `_tkinter.tk.call` first-`None` argument
truncation, empty-string clearing, partial-argument TclError text, invalid
integer TclError text, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-aspect red test failing at missing `HasMethod` in
156ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 112 passed, 0 failed, and 0 errors in
12000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 980 passed, 0 failed, and 0 errors in 22.297
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-client promotion closes the `Tk` / `Toplevel`
`client(name=None)` / `wm_client(name=None)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_client(self, name=None)` signature, `client` / `wm_client` alias
identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, string setter empty-string returns,
empty-string clearing, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-client red test failing at missing `HasMethod` in
313ms, the focused green test at 1 passed in 281ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 111 passed, 0 failed, and 0 errors in
11859ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 979 passed, 0 failed, and 0 errors in 22.219
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconname promotion closes the `Tk` / `Toplevel`
`iconname(newName=None)` / `wm_iconname(newName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconname(self, newName=None)` signature, `iconname` / `wm_iconname`
alias identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, string setter empty-string returns,
empty-string clearing, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-iconname red test failing at missing `HasMethod`
in 282ms, the focused green test at 1 passed in 235ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 110 passed, 0 failed, and 0 errors in
11375ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 978 passed, 0 failed, and 0 errors in 21.860
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-sizefrom promotion closes the `Tk` / `Toplevel`
`sizefrom(who=None)` / `wm_sizefrom(who=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_sizefrom(self, who=None)` signature, `sizefrom` / `wm_sizefrom` alias
identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, user/program setter empty-string returns,
empty-string clearing, and invalid-value TclError plus extra-positional
TypeError text. Fresh promotion gates include the focused wm-sizefrom red test
failing at missing `HasMethod` in 235ms, the focused green test at 1 passed in
219ms, the full `stdlib/tests/tkinter.test.ahk` gate at 109 passed, 0 failed,
and 0 errors in 11391ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 977 passed, 0 failed, and 0
errors in 21.516 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-positionfrom promotion closes the `Tk` / `Toplevel`
`positionfrom(who=None)` / `wm_positionfrom(who=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_positionfrom(self, who=None)` signature, `positionfrom` /
`wm_positionfrom` alias identity, root and toplevel method presence, initial
empty-string reads, `None` preserving read semantics, user/program setter
empty-string returns, empty-string clearing, and invalid-value TclError plus
extra-positional TypeError text. Fresh promotion gates include the focused
wm-positionfrom red test failing at missing `HasMethod` in 234ms, the focused
green test at 1 passed in 234ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 108 passed, 0 failed, and 0 errors in 11125ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
976 passed, 0 failed, and 0 errors in 21.563 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter wm-focusmodel promotion closes the `Tk` / `Toplevel`
`focusmodel(model=None)` / `wm_focusmodel(model=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_focusmodel(self, model=None)` signature, `focusmodel` /
`wm_focusmodel` alias identity, root and toplevel method presence, default
`passive` reads, `None` preserving read semantics, active/passive setter empty
string returns, and invalid-value TclError plus extra-positional TypeError
text. Fresh promotion gates include the focused wm-focusmodel red test failing
at missing `HasMethod` in 266ms, the focused green test at 1 passed in 250ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 107 passed, 0 failed, and 0
errors in 11235ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 975 passed, 0 failed, and 0 errors in
21.688 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter wm-frame promotion closes the `Tk` / `Toplevel`
`frame()` / `wm_frame()` native-frame query gap in the window-manager surface.
Fresh Python 3.10.11 probes confirmed the `Wm.wm_frame(self)` signature,
`frame` / `wm_frame` alias identity, root and toplevel method presence,
platform-specific non-empty string handle returns, alias-equivalent return
values, distinct root/toplevel frame handles on the local runtime, and
extra-positional TypeError text. Fresh promotion gates include the focused
wm-frame red test failing at missing `HasMethod` in 297ms, the focused green
test at 1 passed in 266ms with a 250ms PASS entry, the full
`stdlib/tests/tkinter.test.ahk` gate at 106 passed, 0 failed, and 0 errors in
10954ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 974 passed, 0 failed, and 0 errors in 21.203
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-iconify promotion closes the `Tk` / `Toplevel`
`wm_iconify()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_iconify(self)` signature,
`iconify` / `wm_iconify` alias identity, root and toplevel method presence,
empty-string return values, `normal` to `iconic` state transitions,
`withdrawn` to `iconic` state restoration, viewable/mapped state after
iconification, and extra-positional TypeError text. Fresh promotion gates
include the focused wm-iconify red test failing at missing `HasMethod` in
203ms, the focused green test at 1 passed in 468ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 105 passed, 0 failed, and 0 errors in
10844ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 973 passed, 0 failed, and 0 errors in 21.515
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-deiconify promotion closes the `Tk` / `Toplevel`
`wm_deiconify()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_deiconify(self)` signature,
`deiconify` / `wm_deiconify` alias identity, root and toplevel method presence,
empty-string return values, `withdrawn` to `normal` state restoration, and
extra-positional TypeError text. Fresh promotion gates include the focused
wm-deiconify red test failing at missing `HasMethod` in 250ms, the focused
green test at 1 passed in 219ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 104 passed, 0 failed, and 0 errors in 10594ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
972 passed, 0 failed, and 0 errors in 21.234 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter wm-withdraw promotion closes the `Tk` / `Toplevel`
`wm_withdraw()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_withdraw(self)` signature,
`withdraw` / `wm_withdraw` alias identity, root and toplevel method presence,
empty-string return values, `normal` to `withdrawn` state transitions, clean
`deiconify()` restoration to `normal`, and extra-positional TypeError text.

The preceding tkinter wm-state promotion closes the `Tk` / `Toplevel`
`wm_state(newstate=None)` alias gap in the window-manager lifecycle surface.
Fresh Python 3.10.11 probes confirmed the `Wm.wm_state(self, newstate=None)`
signature, `state` / `wm_state` alias identity, root and toplevel method
presence, no-arg and `None` reads returning the current state string, setters
returning an empty string while transitioning between `normal` and
`withdrawn`, extra-positional TypeError text, and bad state TclError text.
Fresh promotion gates include the focused wm-state red test failing at missing
`HasMethod` in 422ms, the focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 102 passed, 0 failed, and 0 errors in
10344ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 970 passed, 0 failed, and 0 errors in 21.578
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-maxsize promotion closes the `Tk` / `Toplevel`
`wm_maxsize(width=None, height=None)` alias gap in the window-manager
maximum-size surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_maxsize(self, width=None, height=None)` signature, `maxsize` /
`wm_maxsize` alias identity, root and toplevel method presence, no-arg reads
returning the current platform maximum-size tuple, setters returning `None`,
bool arguments coercing through Tcl to integer/platform maximum-size state,
leading `None` behaving as a read for `wm_maxsize(None)`,
`wm_maxsize(None, None)`, and `wm_maxsize(None, 1)`, one-argument and
trailing-`None` calls preserving the Tcl wrong-args path, extra-positional
TypeError text, and bad integer TclError text. Fresh promotion gates include
the focused wm-maxsize red test failing at missing `HasMethod` in 156ms, the
focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 101 passed, 0 failed, and 0 errors in
10391ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 969 passed, 0 failed, and 0 errors in 20.625
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-minsize promotion closes the `Tk` / `Toplevel`
`wm_minsize(width=None, height=None)` alias gap in the window-manager
minimum-size surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_minsize(self, width=None, height=None)` signature, root and toplevel
method presence, no-arg reads returning a two-integer tuple, setters returning
`None`, bool arguments coercing to integers, leading `None` behaving as a read
for `wm_minsize(None)`, `wm_minsize(None, None)`, and `wm_minsize(None, 1)`,
one-argument and trailing-`None` calls preserving the Tcl wrong-args path,
extra-positional TypeError text, and bad integer TclError text. Fresh
promotion gates include the focused wm-minsize red test failing at missing
`HasMethod`, the focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 100 passed, 0 failed, and 0 errors in
10468ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 968 passed, 0 failed, and 0 errors in 20.328
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-resizable promotion closes the `Tk` / `Toplevel`
`wm_resizable(width=None, height=None)` alias gap in the window-manager
resizable surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_resizable(self, width=None, height=None)` signature, root and toplevel
method presence, no-arg reads returning a two-integer tuple, two-argument
setters returning an empty string, leading `None` behaving as a read for
`wm_resizable(None)`, `wm_resizable(None, None)`, and
`wm_resizable(None, True)`, trailing `None` preserving the Tcl wrong-args path,
extra-positional TypeError text, and bad boolean TclError text. Fresh promotion
gates include the focused wm-resizable red test failing at missing `HasMethod`,
the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 99 passed, 0 failed, and 0 errors in
10375ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 967 passed, 0 failed, and 0 errors in 21.094
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-geometry promotion closes the `Tk` / `Toplevel`
`wm_geometry(newGeometry=None)` alias gap in the window-manager geometry
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_geometry(self, newGeometry=None)` signature, root and toplevel method
presence, no-arg geometry reads, geometry setters returning an empty string,
`None` behaving as an omitted argument for both `geometry(None)` and
`wm_geometry(None)`, stable visible-window geometry readback after
`update_idletasks()` / `update()`, extra-positional TypeError text, and bad
geometry TclError text of `bad geometry specifier "bad"`. Fresh promotion
gates include the focused wm-geometry red test failing at missing `HasMethod`,
the focused green test at 1 passed in 281ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 98 passed, 0 failed, and 0 errors in
9734ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 966 passed, 0 failed, and 0 errors in 20.391
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-title promotion closes the `Tk` / `Toplevel`
`wm_title(string=None)` alias gap in the window-manager title surface. A fresh
Python 3.10.11 probe under withdrawn roots confirmed the
`Wm.wm_title(self, string=None)` signature, root and toplevel method presence,
no-arg title reads, string setters returning an empty string, `None` behaving
as an omitted argument for both `title(None)` and `wm_title(None)`, already
created toplevel windows retaining their own title after a root title change,
and the extra-positional TypeError text
`Wm.wm_title() takes from 1 to 2 positional arguments but 3 were given`.
Fresh promotion gates include the focused wm-title red test failing at missing
`HasMethod`, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 97 passed, 0 failed, and 0 errors in
10343ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 965 passed, 0 failed, and 0 errors in 21.219
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter selection-handle promotion closes the root/widget inherited
`selection_handle(command, **kw)` gap in the Misc selection callback surface. A
fresh Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.selection_handle(self, command, **kw)` signature, root and widget method
presence, calls returning `None`, callbacks being invoked by `selection_get()`
with string offset/length arguments of `"0"` and `"4000"`, `type='STRING'`
option forwarding, non-callable command names being accepted at registration
time, missing-command and extra-positional TypeError text, and bad option
TclError text of `bad option "-bad": must be -format, -selection, or -type`.
Fresh promotion gates include the focused selection-handle red test failing at
missing `HasMethod`, the focused green test at 1 passed in 140ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 96 passed, 0 failed, and 0 errors in
9875ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 964 passed, 0 failed, and 0 errors in 22.344
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter send promotion closes the root/widget inherited `send()`
gap in the Misc Tcl command-forwarding surface. A fresh Python 3.10.11 probe
under a withdrawn root confirmed the `Misc.send(self, interp, cmd, *args)`
signature, root and widget method presence, missing-interp/cmd TypeError text,
the local Tk absence of an intrinsic Tcl `send` command raising
`invalid command name "send"`, and successful argument forwarding/return values
when a Tcl `send` proc is installed, including Tcl list quoting for arguments
with spaces. Fresh promotion gates include the focused send red test failing at
missing `HasMethod`, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 95 passed, 0 failed, and 0 errors in
12063ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 963 passed, 0 failed, and 0 errors in 20.406
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter set-palette promotion closes the root/widget inherited
`tk_setPalette()` gap in the palette-management surface. A fresh Python 3.10.11
probe under a withdrawn root confirmed the `Misc.tk_setPalette(self, *args,
**kw)` signature, root and widget method presence, valid calls returning
`None`, positional background colors updating existing root/widget backgrounds,
keyword option/value pairs updating background and foreground defaults, the
Python source flattening kwargs as dashless Tcl `option value` pairs, no-arg and
two-positional TclError text of `must specify a background color`, and bad color
TclError text of `unknown color name "notacolor"`. Fresh promotion gates include
the focused set-palette red test failing at missing `HasMethod`, the focused
green test at 1 passed in 234ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 94 passed, 0 failed, and 0 errors in 11109ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the aggregate
`stdlib/tests` gate at 962 passed, 0 failed, and 0 errors in 20.594 seconds with
`-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter global-grab promotion closes the root/widget inherited
`grab_set_global()` gap in the grab modal-state surface. A fresh Python 3.10.11
probe under a withdrawn root confirmed the `Misc.grab_set_global(self)`
signature, root and widget method presence, calls returning `None`,
`grab_current()` pointing to the caller, the caller `grab_status()` becoming
`global`, non-caller `grab_status()` returning `None`, and the observed
`Misc.grab_set_global() takes 1 positional argument but 2 were given`
TypeError text. Fresh promotion gates include the focused global-grab red test
failing at missing `HasMethod`, the focused green test at 1 passed in 235ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 93 passed, 0 failed, and
0 errors in 11766ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
and the aggregate `stdlib/tests` gate at 961 passed, 0 failed, and 0 errors in
20.860 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter bell promotion closes the root/widget inherited
`bell(displayof=0)` gap in the Misc display routing surface. A fresh Python
3.10.11 probe under a withdrawn root confirmed the `Misc.bell(self,
displayof=0)` signature, root and widget method presence, default, `None`,
`0`, root, and widget display targets returning `None`, bad string display
targets raising `bad window path name "bad"`, and the observed
`Misc.bell() takes from 1 to 2 positional arguments but 3 were given`
TypeError text. Fresh promotion gates include the focused bell red test
failing at missing `HasMethod`, the focused green test at 1 passed in 188ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 92 passed, 0 failed, and
0 errors in 18000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
and the aggregate `stdlib/tests` gate at 960 passed, 0 failed, and 0 errors in
28.656 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter focus-follows-mouse promotion closes the root/widget
inherited `tk_focusFollowsMouse()` gap in the focus-management surface. A fresh
Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.tk_focusFollowsMouse(self)` signature, root and widget calls returning
`None`, and the observed
`Misc.tk_focusFollowsMouse() takes 1 positional argument but 2 were given`
TypeError text. Fresh promotion gates include the focused focus-follows-mouse
red test failing at missing `HasMethod`, the focused green test at 1 passed in
218ms, the full `stdlib/tests/tkinter.test.ahk` gate at 91 passed, 0 failed,
and 0 errors in 18375ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 959 passed, 0 failed, and
0 errors in 28.922 seconds with `-TimeoutSeconds 40` and the known
`plain fallback` stderr line.

The preceding tkinter command-registration promotion closes the root/widget
inherited callable `register()` and `deletecommand()` gap for Tcl command
callbacks. A fresh Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.register(func, subst=None, needcleanup=1)` and `Misc.deletecommand(name)`
signatures, string command-name returns, Tcl argument delivery into the Python
callback, root and widget registration, `deletecommand()` returning `None`,
registered command removal from `info commands`, invalid-command behavior after
delete, second-delete `can't delete Tcl command` errors, and the observed
missing/extra positional TypeError text. Fresh promotion gates include the
focused register/delete red test failing at missing `HasMethod`, the focused
green test at 1 passed in 188ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 89 passed, 0 failed, and 0 errors in 9625ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
957 passed, 0 failed, and 0 errors in 20.781 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter strict-Motif promotion closes the root/widget inherited
`tk_strictMotif(boolean=None)` gap in the Misc Tcl-boolean surface. A fresh
Python 3.10.11 probe under a withdrawn root confirmed the signature, initial
`False` root and widget queries, `True` / `False` returns when setting from
root or child widgets, shared `tk_strictMotif` Tcl variable state, `None` as a
query rather than a set operation, accepted integer/string boolean spellings,
the bad-boolean TclError text, and the extra-positional TypeError text. Fresh
promotion gates include the focused strict-Motif red test failing at missing
`HasMethod`, the focused green test at 1 passed in 344ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 88 passed, 0 failed, and 0 errors in
10031ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 956 passed, 0 failed, and 0 errors in 22.703
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter focus-lastfor promotion closes the root/widget inherited
`focus_lastfor()` gap in the focus-management surface. Fresh Python 3.10.11
probes confirmed the `Misc.focus_lastfor(self)` signature, initial Tk-root
return for root and child widgets, last-for migration to the focused Entry and
Button after `focus_force()` plus update, retention of the last focused Button
after `withdraw()` makes `focus_get()` return `None`, and the observed
`Misc.focus_lastfor() takes 1 positional argument but 2 were given` TypeError
text for root and widget extra arguments. Fresh promotion gates include the
focused `focus_lastfor` red test failing at missing `HasMethod`, the focused
green test at 1 passed in 484ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 87 passed, 0 failed, and 0 errors in 13641ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
955 passed, 0 failed, and 0 errors in 36.062 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter variable-access promotion closes the Tk-backed widget
inherited `getvar()` / `setvar()` gap beside the already covered root variable
surface. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed
that widget `getvar()` reads root-created Tcl variables, widget `setvar()`
creates variables visible from the root, `None` stores as the string `"None"`,
the default single-argument `setvar()` value is `"1"`, a missing widget variable
raises the observed TclError text, and missing/extra positional arguments keep
the observed `Misc.setvar()` / `Misc.getvar()` TypeError text. Fresh promotion
gates include the focused widget-variable red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 86 passed, 0 failed, and 0 errors in
14094ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 954 passed, 0 failed, and 0 errors in 28.438
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The same tkinter gate stabilization also moved the clipboard save/restore test
path to bounded best-effort retry helpers so transient Windows clipboard locks
do not mask tkinter parity failures.

The preceding tkinter menu-position promotion closes the `Menu.xposition(index)`
gap beside the already covered `Menu.yposition(index)` surface. A fresh Python
3.10.11 probe, run under a withdrawn root, confirmed the `Menu.xposition(self,
index)` signature, integer x-position returns for numeric and `"end"` indices,
`0` for the initially inactive `"active"` index, active-entry x-position after
`activate(0)`, the missing/extra positional `TypeError` text, and the bad-index
`TclError` text. Fresh promotion gates include the focused Menu xposition
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed,
0 failed, and 0 errors in 12781ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
953 passed, 0 failed, and 0 errors in 36.078 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line. The preceding tkinter selection
promotion expands the inherited-Misc selection
surface from root `selection_get()` into root/widget `selection_clear()`,
`selection_own()`, and `selection_own_get()`. A fresh Python 3.10.11 probe,
run under a withdrawn root, confirmed that a selected Entry range makes both
`root.selection_own_get()` and `entry.selection_own_get()` return the Entry,
that `root.selection_clear()` returns `None` and clears the PRIMARY owner while
leaving `entry.selection_present()` true, that `root.selection_own()` and
`entry.selection_own()` move ownership to the corresponding Tk object, and that
extra positional arguments raise the observed `Misc.selection_clear()`,
`Misc.selection_own()`, and `Misc.selection_own_get()` `TypeError` text. Fresh
promotion gates include the focused selection-ownership red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 9610ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors in 19.250
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The preceding tkinter selection promotion closed the `Tk.selection_get()`
inherited-Misc root gap. The preceding tkinter widget
event-loop promotion closes the Tk-backed widget
`mainloop()` / `quit()` inherited-Misc gap. A fresh Python 3.10.11 probe, run
under a withdrawn root, confirmed that `Label.quit()` and `Button.quit()`
return `None`, that `label.after(0, label.quit)` exits `Label.mainloop()` with
a `None` return, and that extra positional arguments raise the observed
`Misc.mainloop() takes from 1 to 2 positional arguments but 3 were given` and
`Misc.quit() takes 1 positional argument but 2 were given` `TypeError` text.
Fresh promotion gates include the focused widget-mainloop red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 15953ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
immediate aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 36.766
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The first aggregate attempt timed out at 40 seconds while running the tkinter
tail, so the passing rerun is the authoritative fresh aggregate evidence for
this slice. The preceding tkinter widget event-loop promotion closes the Tk-backed widget
`update()` / `update_idletasks()` inherited-Misc gap. A fresh Python 3.10.11
probe, run under a withdrawn root, confirmed that `Label.update()`,
`Label.update_idletasks()`, `Button.update()`, and root `update()` return
`None`, and that extra positional arguments raise the observed
`Misc.update() takes 1 positional argument but 2 were given` and
`Misc.update_idletasks() takes 1 positional argument but 2 were given`
`TypeError` text. Fresh promotion gates include the focused widget-update
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed,
0 failed, and 0 errors in 20828ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
953 passed, 0 failed, and 0 errors in 38.906 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line. The preceding tkinter focus-alias
promotion closes the `Misc.focus` /
`Misc.focus_set` alias gap on Tk roots and Tk-backed child widgets. A fresh
Python 3.10.11 probe, run under a withdrawn root, confirmed that
`tk.Misc.focus is tk.Misc.focus_set`, that `root.focus()`, `entry.focus()`,
and `button.focus()` return `None`, and that extra positional arguments raise
the observed `Misc.focus_set() takes 1 positional argument but 2 were given`
`TypeError`. Fresh promotion gates include the focused focus-alias red/green
test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed,
and 0 errors in 13468ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the immediate aggregate rerun gate at 953 passed, 0 failed, and
0 errors in 35.719 seconds with `-TimeoutSeconds 40` and the known
`plain fallback` stderr line. The first aggregate attempt timed out at 40
seconds while running the tkinter tail, so the passing rerun is the
authoritative fresh aggregate evidence for this slice. The preceding tkinter
widget event-loop promotion closes the first Tk-backed
widget `after(...)` and `after_cancel(...)` inherited-Misc gap. A fresh Python
3.10.11 probe, run under a withdrawn root, confirmed that `Label.after(0)`
returns `None`, callback-based `Label.after(0, func, *args)` returns an
`after#N` id, passes callback arguments on `update()`, cancellation through
`Label.after_cancel(id)` prevents the callback, `Label.after_cancel("missing")`
returns `None`, and the observed missing-ms, bad-ms, missing-id, and
extra-positional error text matches `Misc.after...` / `Misc.after_cancel...`.
Fresh promotion gates include the focused widget-after red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 15750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
immediate aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 34.781
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The first aggregate attempt timed out at 40 seconds while entering the tkinter
tail, so the passing rerun is the authoritative fresh aggregate evidence for
this slice. The preceding tkinter menu promotion closes the first
`Menu.entryconfigure(index)` / `Menu.entryconfigure(index, option)` and
`Menu.entryconfig(...)` query gap while preserving dictionary-set behavior. A
fresh Python 3.10.11 probe, run under a withdrawn root, confirmed full-query
`dict` returns, Python-style single-option tuples for command, cascade,
checkbutton, and radiobutton entries, `entryconfig(...)` alias keys, `None` returns for set
calls, label/state mutation, `underline` integer tuple values, and the observed
missing-index, extra-positional, non-dict-cnf, bad-index, bad-option, and
leading-dash-option error text. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 15625ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the immediate
aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 37.734 seconds
with `-TimeoutSeconds 40` and the known `plain fallback` stderr line. The first
aggregate attempt timed out at 40 seconds while entering the tkinter tail, so
the passing rerun is the authoritative fresh aggregate evidence for this slice.
The preceding tkinter menu promotion closes the first stable `Menu.yposition(index)`
and `Menu.unpost()` gaps, plus Python-matched `Menu.post(x, y)` arity and
coordinate validation. A fresh Python 3.10.11 probe, run under a withdrawn root,
confirmed the `post(x, y)`, `unpost()`, and `yposition(index)` signatures,
`None` returns for `post(...)` / `unpost()`, integer y-position returns, withdrawn
root mapping state staying false around post/unpost, and the observed
post-missing, post-extra, invalid-coordinate, unpost-extra,
yposition-missing, yposition-extra, and bad-index errors. The AHK promotion
test covers positive `yposition(...)`, no-op `unpost()`, and the probed
`post(...)` error paths; direct positive popup posting remains deferred because
it was unstable under the 40-second aggregate gate when exercised through the
real Tk popup tracker. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 16563ms, the aggregate `stdlib/tests` gate
at 953 passed, 0 failed, and 0 errors in 38.281 seconds with `-TimeoutSeconds
40` and the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add(itemType, ...)`
gap. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed the
`(itemType, cnf={}, **kw)` signature, `None` returns for generic
command/cascade/checkbutton/radiobutton/separator additions, empty-dictionary
command creation, appended entry metadata through `entrycget(...)`, and
command/radio/checkbutton `invoke(...)` effects. The same probe preserves the
observed missing-itemType, bad-type, bad-cnf, bad-option, and extra-positional
error text. Fresh promotion gates include the focused Menu command-entry
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors in 13891ms, the aggregate `stdlib/tests` gate at 953
passed, 0 failed, and 0 errors in 22.921 seconds with `-TimeoutSeconds 40` and
the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.insert(...)` and
`Menu.insert_cascade(...)` / `Menu.insert_checkbutton(...)` /
`Menu.insert_command(...)` / `Menu.insert_radiobutton(...)` /
`Menu.insert_separator(...)` gaps. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed the `(index, itemType, cnf={}, **kw)` generic insert
signature and the `(index, cnf={}, **kw)` helper signatures, `None` returns,
generic command insertion, inserted command/cascade/radiobutton/tail/separator/
checkbutton order, empty-dictionary command and separator insertion, inserted
entry metadata through `entrycget(...)`, and command/radio/checkbutton
`invoke(...)` effects. The same probe preserves generic bad-type and missing
itemType errors, plus insert-command and insert-separator bad-cnf, bad-option,
bad-index, and extra-positional error text. Fresh promotion gates include the
focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
16547ms, the aggregate `stdlib/tests` rerun gate at 953 passed, 0 failed, and 0
errors in 36.828 seconds with `-TimeoutSeconds 40` and the known `plain
fallback` stderr line after one preceding timeout, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_checkbutton(...)`
and `Menu.add_radiobutton(...)` gaps. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed that both methods expose `(cnf={}, **kw)` signatures,
return `None`, append `checkbutton` and `radiobutton` entries, preserve label,
variable, on/off, and value options through `entrycget(...)`, and mutate their
bound variables through `invoke(...)` with the observed empty-string Tcl return.
The same probe preserves no-argument checkbutton creation, empty-dictionary
radiobutton creation, and the observed bad-cnf, bad-option, and
extra-positional error text. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 18578ms, the aggregate `stdlib/tests` gate
at 953 passed, 0 failed, and 0 errors in 22.656 seconds with `-TimeoutSeconds
40` and the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_cascade(...)`
gap. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed that
`Menu.add_cascade(cnf={}, **kw)` returns `None` for submenu-backed cascades,
no-argument calls, and empty dictionaries, appends `cascade` entries, preserves
submenu path strings through `entrycget(index, "menu")`, and preserves the
observed bad-cnf, bad-option, and extra-positional error text. Fresh promotion
gates include the focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
17234ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 33.719 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.activate(index)` gap.
A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed that
`Menu.activate(index)` has a required single-index signature, returns `None`,
marks command entries as the active entry, clears active state for separator
entries and `"none"`, and preserves the observed missing-index,
extra-positional, and bad-index error text. Fresh promotion gates include the
focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
17265ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 35.813 seconds with `-TimeoutSeconds 40` after one observed
aggregate timeout during the tkinter tail, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_separator(...)`
and `Menu.type(index)` gap. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed that `Menu.add_separator(cnf={}, **kw)` returns
`None` for omitted config and empty dictionaries, appends separator entries,
and preserves the observed bad-cnf, bad-option, and extra-positional error
text. The same probe confirmed that `Menu.type(index)` has a required
single-index signature, returns `""` for an empty menu's `"end"` entry, returns
`"command"` / `"separator"` strings for populated entries, and preserves the
observed missing-index, extra-positional, and bad-index errors. Fresh
promotion gates include the focused Menu command-entry red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0
errors in 15875ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed,
and 0 errors in 37.750 seconds with `-TimeoutSeconds 40`, and
`run-ahk-validate stdlib/examples/tkinter.ahk` passing. The preceding tkinter
listbox promotion closes the first `Listbox.bbox(index)`
gap. A fresh Python 3.10.11 probe, run under the same withdrawn-root
condition used by the AHK gate, confirmed that `bbox(index)` has a required
single-index signature, returns a four-integer tuple for a visible row,
returns `None` for non-visible, `end`, and off-visible rows, maps `"active"`
to the active row geometry, and preserves the observed missing-index,
extra-positional, and bad-index error text. Fresh promotion gates include the
focused Listbox selection/item red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
9297ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 39.188 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first
`Text.yview_pickplace` gap. A fresh Python 3.10.11 probe, run under the same
withdrawn-root condition used by the AHK gate, confirmed that
`Text.yview_pickplace(*what)` has a varargs signature, returns `None` for a
single line/index argument, moves the visible top index to `20.0` for
`"20.0"` and to `31.0` for `"end"` in the probed 30-line text, and preserves
the observed Tcl missing-argument, bad-index, and extra-argument errors.
Fresh promotion gates include the focused Text yview-pickplace red/green test,
the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0
errors, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 20.046 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first `Text` peer gap.
A fresh Python 3.10.11 probe confirmed that
`Text.peer_create(newPathName, cnf={}, **kw)` returns `None`, creates a Tk text
peer at the requested widget path, applies peer-local options such as width,
height, and wrap, and shares text-buffer edits in both directions between the
source widget and peer widget. The same probe confirmed that
`Text.peer_names()` returns an empty tuple before peers and then returns peer
path tuples in Tk order, with newer peers observed before older peers. It also
captured the probed missing-path, extra-positional, bad-option, duplicate-path,
and peer-names arity errors now covered by `stdlib/tests/tkinter.test.ahk`.
Fresh promotion gates include the focused Text peer red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, the
aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors in 38.344
seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first `Text.replace`
gap. A fresh Python 3.10.11 probe confirmed that
`Text.replace(index1, index2, chars, *tags)` returns `None`, replaces a text
range, inserts at an empty range, deletes when `chars` is empty, applies
provided tag names to inserted characters, and preserves the observed
missing-argument TypeError messages plus bad-index and reverse-range
`TclError` paths. Fresh promotion gates include the focused Text replace
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors, the aggregate `stdlib/tests` gate at 953 passed, 0
failed, and 0 errors in 34.719 seconds with `-TimeoutSeconds 40`, and
`run-ahk-validate stdlib/examples/tkinter.ahk` passing. The preceding tkinter
multiline-text promotion closes the first `Text`
embedded-window gap. A fresh Python 3.10.11 probe confirmed that
`Text.window_create(index, cnf={}, **kw)` returns `None`, embeds supplied Tk
child widgets by path, and rejects the observed missing-index,
extra-positional, bad-index, and bad-option paths. The same probe confirmed
that `Text.window_names()` returns an empty tuple before embedded windows and
then returns child path tuples in Tk order; `Text.window_cget` and
`Text.window_configure` preserve window/align string values while converting
`padx` / `pady` / `stretch` current values to integers;
`Text.window_configure(...)` returns Python-shaped option dictionaries and
five-field option tuples; `Text.window_config(...)` aliases
`window_configure(...)`; and `Text.dump(..., window=True)` reports embedded
window triples. Fresh promotion gates include the focused Text window
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors, and the aggregate `stdlib/tests` gate at 953 passed, 0
failed, and 0 errors. The preceding tkinter multiline-text promotion closes
the first `Text`
embedded-image gap. A fresh Python 3.10.11 probe confirmed that
`Text.image_create(index, cnf={}, **kw)` returns the embedded image name,
reuses a supplied `PhotoImage` name for the first embedding, generates
`name#1` for a second embedding of the same image object, and rejects the
observed missing-index, extra-positional, bad-index, and bad-option paths.
The same probe confirmed that `Text.image_names()` returns `""` when no
embedded images exist and a tuple when images are present; `Text.image_cget`
and `Text.image_configure` preserve image/align string values while converting
`padx` / `pady` current values to integers; `Text.image_configure(...)`
returns Python-shaped option dictionaries and five-field option tuples; and
`Text.dump(..., image=True)` reports embedded image triples. Fresh promotion
gates include the focused Text image red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, and
the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors. The
preceding tkinter multiline-text promotion closes the first `Text` tag
configuration and tag binding gap. A fresh Python 3.10.11 probe confirmed that
`Text.tag_cget(tagName, option)` accepts both dashed and non-dashed option
names, strips trailing Python underscore aliases, and returns string option
values; `Text.tag_configure(tagName, cnf=None, **kw)` returns a Python-shaped
option dictionary for omitted config, a five-field tuple for a string option,
and `None` for mutation; `Text.tag_config(...)` aliases `tag_configure(...)`;
`Text.tag_bind(tagName, sequence, func, add=None)` requires the explicit
`func` argument, returns a tuple for all bound sequences when `sequence` is
falsey and `func` is falsey, returns the bound Tcl script for sequence queries,
and returns a command id for callable bindings; and `Text.tag_unbind(...)`
returns `None` while clearing the binding and deleting a truthy command id. The
probe also captured matching missing/extra positional TypeErrors, bad tag
option `TclError` paths, and missing-command deletion errors now covered by
`stdlib/tests/tkinter.test.ahk`. Fresh promotion gates include the isolated
HEAD red check for the new focused Text assertions, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, and
the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors. The
preceding tkinter multiline-text
promotion closes the first `Text.dump`
serialization gap. A fresh Python 3.10.11 probe confirmed that
`Text.dump(index1, index2=None, command=None, **kw)` returns a list of
`(key, value, index)` tuples when no truthy command is provided, internally
uses the Tk `-command` callback path to collect triples, treats falsey `index2`
as omitted, emits default all-content triples when no true filter keyword is
present, honors true `text`, `tag`, `mark`, `all`, `image`, and `window`
filters, and returns `None` while invoking the supplied callback once for each
triple. The probe also captured matching missing-index, too-many-positional,
duplicate `index2`, duplicate `command`, unknown-option, and bad-index errors
now covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter
multiline-text promotion closes the first `Text` edit/debug
undo-stack gap. A fresh Python 3.10.11 probe confirmed that `Text.debug()`
queries the internal debug flag as a boolean, `Text.debug(boolean)` returns
`None`, `Text.edit_modified(arg=None)` queries or sets the modified flag,
`Text.edit("canundo")` / `Text.edit("canredo")` return integer flags, and
`Text.edit_separator()`, `Text.edit_undo()`, `Text.edit_redo()`, and
`Text.edit_reset()` preserve the probed Tk undo/redo stack mutation returns and
errors. The probe also captured matching `Text.debug`, `Text.edit_modified`,
`Text.edit_undo`, `Text.edit_redo`, `Text.edit_reset`, and
`Text.edit_separator` TypeError text plus Tcl bad-boolean, bad-edit-option,
wrong-arity, and empty-undo-stack errors now covered by
`stdlib/tests/tkinter.test.ahk`. The preceding tkinter multiline-text
promotion closes the first `Text` search
query gap. A fresh Python 3.10.11 probe confirmed that
`Text.search(pattern, index, stopindex=None, forwards=None, backwards=None,
exact=None, regexp=None, nocase=None, count=None, elide=None)` appends only
truthy flags, inserts `--` before patterns beginning with `-`, updates a truthy
`count` variable with the match length, returns `""` for missing matches, and
preserves the probed missing-argument, too-many-argument, unexpected-keyword,
duplicate-keyword, bad-index, and bad-regexp errors. The focused Text gate now
covers forward, stop-indexed, backward, nocase, regexp, exact, count-variable,
falsey-count, and leading-dash-pattern search behavior. The preceding tkinter
multiline-text promotion closes the first `Text` count
query gap. A fresh Python 3.10.11 probe confirmed that
`Text.count(index1, index2, *args)` auto-prefixes count options with `-`,
returns one-integer tuples for the default and single count-option forms,
returns multi-integer tuples for multiple count options, returns a bare integer
for the covered `update` plus single count-option form, preserves negative
counts for reverse index ranges, and keeps the probed missing-argument,
bad-index, and bad-option errors. The preceding tkinter multiline-text
promotion closes the first `Text` index
comparison gap. A fresh Python 3.10.11 probe confirmed that
`Text.compare(index1, op, index2)` returns Python booleans for `<`, `<=`, `==`,
`>=`, `>`, and `!=`, accepts canonical Tk text indexes such as `end`, and
preserves the probed missing-argument, extra-argument, bad-index, and
bad-operator errors. The preceding tkinter multiline-text promotion closes the
first `Text` tag-range
management gap. A fresh Python 3.10.11 probe confirmed that `Text.tag_add(...)`,
`Text.tag_remove(...)`, `Text.tag_raise(...)`, `Text.tag_lower(...)`, and
`Text.tag_delete(...)` return `None`, while `Text.tag_ranges(...)`,
`Text.tag_names(...)`, `Text.tag_nextrange(...)`, and `Text.tag_prevrange(...)`
return Python-shaped tuples including empty tuples for missing ranges. The
probe also captured matching `Text.tag_*` TypeError text plus Tcl bad-index
errors now covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter
multiline-text promotion closes the first `Text` mark
management gap. A fresh Python 3.10.11 probe confirmed that
`Text.mark_set(markName, index)`, `Text.mark_unset(*markNames)`, and missing
mark unsets return `None`, `Text.mark_gravity(markName)` returns `"left"` or
`"right"`, `Text.mark_gravity(markName, direction)` returns `""`,
`Text.mark_names()` returns a tuple of mark names, and `Text.mark_next(index)` /
`Text.mark_previous(index)` return a mark name or `None`. The probe also
captured matching `Text.mark_*` TypeError text plus Tcl bad-index, missing-mark,
and bad-gravity errors now covered by `stdlib/tests/tkinter.test.ahk`. The
preceding tkinter multiline-text promotion closed the first `Text` visual view
gap. A fresh Python 3.10.11 probe confirmed that `Text.bbox(index)` returns a
four-integer tuple for visible characters and `None` for non-visible indexes,
`Text.dlineinfo(index)` returns a five-integer tuple for visible display lines
and `None` for non-visible indexes, `Text.see(index)`,
`Text.scan_mark(x, y)`, `Text.scan_dragto(x, y)`, and mutating `xview(...)` /
`yview(...)` calls return `None`, and `Text.xview()` / `Text.yview()` return
two-float tuples. The probe also captured matching `Text.*`, `XView.*`, and
`YView.*` TypeError text plus Tcl bad-index and bad-integer errors now covered
by `stdlib/tests/tkinter.test.ahk`. The earlier tkinter list-selection
promotion closes the `Listbox` view and item configuration gap. A fresh Python
3.10.11 probe confirmed that
`Listbox.activate(index)`, `see(index)`, `scan_mark(x, y)`, `scan_dragto(x, y)`,
`selection_anchor(index)`, and the `select_*` aliases return `None`,
`nearest(y)` returns an integer index, `xview()` and `yview()` return two-float
tuples, mutating view calls return `None`, and `itemconfigure(index)` /
`itemconfigure(index, option)` return Python-shaped dict / tuple option
metadata while `itemconfigure(index, cnf)` and `itemconfig(...)` return `None`.
The probe also captured the matching `Listbox.*`, `XView.*`, `YView.*`
TypeError text and the Tcl bad-index, bad-integer, and bad-option errors now
covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter entry-widget
promotion closes the `Entry` XView method gap. A fresh Python 3.10.11 probe
confirmed that `Entry.xview()` returns a two-float tuple, raw `xview(...)`
movement calls return `None`, `xview_moveto(fraction)` and
`xview_scroll(number, what)` preserve `XView.*` TypeError wording, and Tk still
owns bad index, bad fraction, bad number, bad unit, and wrong-arity `TclError`
messages. The earlier tkinter entry-widget promotion closed the scan method gap
for `Entry` and `Spinbox`: `Entry.scan_mark(x)` and
`Entry.scan_dragto(x)` return `None`, while `Spinbox.scan(...)`,
`Spinbox.scan_mark(x)`, and `Spinbox.scan_dragto(x)` return an empty tuple for
covered `mark` / `dragto` calls and preserve Tcl wrong-arity and invalid-x
errors.

The recent tkinter control-widget promotion closes the direct `flash()` method
gap for `Button` and `Checkbutton`. A fresh Python 3.10.11 probe confirmed that
`Button.flash()` and `Checkbutton.flash()` return `None` with no arguments and
raise `TypeError("<Class>.flash() takes 1 positional argument but 2 were given")`
for an extra positional argument, matching the already covered `Radiobutton`
shape.

The latest tkinter module-level numeric-alias promotion adds
`stdlib.tkinter.getint()` and `stdlib.tkinter.getdouble()` behavior. A fresh
Python 3.10.11 probe confirmed these are aliases for Python `int` and `float`,
not default-root Tcl conversion helpers, so the covered AHK surface now accepts
no default root, returns `0` / `0.0` with no arguments, parses signed and padded
decimal strings such as `"09"` through Python rules, truncates float input for
`getint`, maps bool input to numeric `1` / `0`, and preserves the observed
`ValueError` / `TypeError` text for the covered invalid inputs. The
two-argument `int(x, base)` form, bytes-like inputs, and custom coercion
protocols remain unclaimed.

The preceding tkinter module-level promotion adds default-root-backed
`stdlib.tkinter.getboolean(s)` behavior. A fresh Python 3.10.11 probe confirmed
that the module function validates arity before default-root lookup, raises
`RuntimeError` before a default root exists, returns bools for Tcl boolean
strings plus integer and bool inputs once a `Tk()` root exists, maps invalid
boolean literals to `ValueError("invalid literal for getboolean()")`, preserves
the observed `None` and float `TypeError` messages, and returns to the
too-early state after root destruction.

The recent tkinter module-level promotion adds default-root-backed
`stdlib.tkinter.image_names()`, `stdlib.tkinter.image_types()`, and
`stdlib.tkinter.mainloop(...)` behavior. A fresh Python 3.10.11 probe confirmed
that these functions raise `RuntimeError` before a default root exists, reject
extra positional arguments with module-function wording, use the first `Tk()`
root as `_default_root`, match root-level image registry tuples, run the
default root mainloop until a scheduled `quit()`, and return to the too-early
state after root destruction. The same slice moves no-master variable, widget,
and image construction toward Python's default-root behavior for covered
`StringVar()`, `Label(...)`, and `PhotoImage(...)` cases.

The latest tkinter pane-widget promotion adds `PanedWindow(...)` to the public
`stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the constructor
signature `(master=None, cnf={}, **kw)`, Python-style named paths, `Panedwindow`
Tk class naming, `panes()` path-tuple returns, `add(...)` / `remove(...)` /
`forget(...)` `None` returns, `panecget(...)`, `paneconfigure(...)` /
`paneconfig(...)` query and set behavior, `sticky` normalization to `nesw`,
`identify(...)`, `proxy_coord()` / `proxy_place(...)` / `proxy_forget()`, and
`sash_coord(...)` / `sash_mark(...)` / `sash_place(...)` return shapes plus
representative constructor, pane, proxy, and sash error paths. The aggregate
gate was also tightened by reducing pointer-query assertions to the independent
integer-return behavior that local Python/Tk actually guarantees across
separate `winfo_pointerxy()`, `winfo_pointerx()`, and `winfo_pointery()` calls.

The latest tkinter selection-widget promotion adds `OptionMenu(...)` to the
public `stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature `(master, variable, value, *values, **kwargs)`,
`OptionMenu` MRO over `Menubutton`, default `Menubutton` widget class with
Python-style `.!optionmenu` path, default `textvariable`, `menu`,
`borderwidth`, `indicatoron`, `relief`, `anchor`, and
`highlightthickness` options, internal `.menu` construction, menu labels,
menu `invoke(...)` setting the bound variable before calling the optional
command, Python's `"None"` command result, single-value menu behavior, and
observed missing-argument / master / unsupported-option errors. The AHK
surface maps Python keyword options to a trailing options object and currently
accepts only `{ command: callback }`, matching Python's supported
`OptionMenu` keyword.

The recent tkinter classic-widget promotion adds `Message(...)`,
`Menubutton(...)`, and `LabelFrame(...)` to the public `stdlib.tkinter`
surface. A fresh Python 3.10.11 probe confirmed their constructor signature,
Python-style widget paths, `_root()` identity, `winfo_class()` names,
representative `cget(...)` conversions and option keys, `Menubutton`
`Menu` attachment / command invocation, `LabelFrame` `labelwidget` and child
parent-path behavior, `destroy()` returns, and observed constructor plus
option-error paths. The implementation reuses the shared Tk-backed `Widget`
base and extends `cget("aspect")` conversion to match Python's integer
`Message` option value.

The recent tkinter widget promotion adds `Spinbox(...)` to the public
`stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature, value editing, `StringVar` `textvariable` binding,
`icursor(...)`, `index(...)`, selection query / range / clear behavior,
`invoke("buttonup")` / `invoke("buttondown")` command callbacks,
`selection_element(...)`, `bbox(index)`, `identify(x, y)`, `xview()`,
`xview_moveto(...)`, `xview_scroll(...)`, and observed constructor / method
arity plus Tcl validation errors.

The recent tkinter image-object promotion adds `BitmapImage(...)` to the
public `stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature, `data` and `file` XBM initialization, `width()`,
`height()`, `type()`, `config()` / `configure()` `None` returns, image-backed
`Label` options, image-registry membership, and observed constructor / image
method arity plus Tcl validation errors. The implementation reuses the shared
`Image` base and preserves raw bitmap `data` by quoting `-data` / `-maskdata`
options instead of brace-escaping their XBM braces.

The recent tkinter image-object promotion expands `PhotoImage` toward the
Python 3.10.11 public surface with `copy()`, `zoom(x, y="")`,
`subsample(x, y="")`, `write(filename, format=None, from_coords=None)`,
`transparency_get(x, y)`, and `transparency_set(x, y, boolean)`. A fresh
Python 3.10.11 probe confirmed the wrapper signatures, generated
`PhotoImage` return objects, copied pixel values, zoom/subsample dimensions,
boolean transparency returns, PNG write side effects, and observed arity / Tcl
validation errors.

The latest tkinter layout-alias promotion adds Python-compatible aliases for
the already covered layout-manager APIs on `Tk` roots and Tk-backed widgets:
`pack_configure()`, `grid_configure()`, `place_configure()`, `info()`,
`forget()`, `slaves()`, `propagate()`, `anchor()`, `size()`, `bbox()`, and
widget `location()`. A fresh Python 3.10.11 probe confirmed the `Pack`,
`Grid`, and `Place` alias resolution through `Label` MRO, selected arity
errors, string-valued `place_info()` coordinates, and the absence of
`Tk.location()`, so the AHK surface intentionally does not add a root
`location()` alias.

The latest tkinter promotion adds atom/path/containing/interpreter `winfo`
queries on `Tk` roots and Tk-backed widgets: `winfo_atom(name, displayof=0)`,
`winfo_atomname(id, displayof=0)`, `winfo_containing(rootX, rootY,
displayof=0)`, `winfo_interps(displayof=0)`, and `winfo_pathname(id,
displayof=0)`. A fresh Python 3.10.11 probe confirmed the `Misc` signatures,
atom round-trips, empty interpreter tuple returns on this host, raw hex window
id pathname lookup behavior, widget/`None` containing returns, `_displayof`
truthiness and `None` semantics, and observed arity / Tcl validation errors.

The recent tkinter visual-query promotion adds visual/colormap/pointer/geometry/id `winfo`
queries on `Tk` roots and Tk-backed widgets: `winfo_cells()`,
`winfo_colormapfull()`, `winfo_depth()`, `winfo_geometry()`, `winfo_id()`,
`winfo_pointerx()`, `winfo_pointerxy()`, `winfo_pointery()`,
`winfo_visual()`, `winfo_visualid()`, and `winfo_visualsavailable()`. A fresh
Python 3.10.11 probe confirmed the `Misc` signatures, local `256` color-cell
and `32` depth values, `truecolor` / `0x0` visual values, list-of-tuple
`visualsavailable` returns with integer includeids, pointer tuple behavior,
destroyed-widget `TclError` behavior, and observed arity errors.

The latest tkinter promotion tightens `winfo_screenwidth()` and
`winfo_screenheight()` to match CPython 3.10.11's DPI-unaware logical-pixel
screen dimensions on this Windows host, and adds `winfo_vrootwidth()`,
`winfo_vrootheight()`, `winfo_vrootx()`, and `winfo_vrooty()` on `Tk` roots
and Tk-backed widgets. A fresh Python 3.10.11 probe confirmed the `Misc`
signatures, `1707x1067` logical screen/virtual-root dimensions, zero virtual
root offsets, destroyed-widget `TclError` behavior, and observed arity errors.

The recent winfo screen-metadata promotion adds `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, and `winfo_server()` on `Tk`
roots and Tk-backed widgets. A fresh Python 3.10.11 probe confirmed the `Misc`
signatures, local screen name, millimeter dimensions, screen depth/cell counts,
visual model, Windows server string, destroyed-widget `TclError` behavior, and
observed arity errors.

The recent winfo distance/color promotion adds `winfo_pixels(number)`,
`winfo_fpixels(number)`, and `winfo_rgb(color)` on `Tk` roots and Tk-backed
widgets. A fresh Python 3.10.11 probe confirmed the `Misc` signatures,
integer/float pixel-distance returns, 16-bit RGB tuple returns, destroyed-widget
`TclError` behavior, and observed missing/extra-argument errors. The AHK
implementation keeps Tcl validation for screen distances and color names while
normalizing unit-based distance conversion back to CPython's DPI-unaware
logical-pixel behavior on this Windows host.

The recent tkinter root-window promotion moved GUI work back to the root-window surface:
`stdlib.tkinter.Tk()` now exposes Python 3.10.11-matched visibility, state, and
geometry APIs through `geometry()`, `state()`, `withdraw()`, `iconify()`, `deiconify()`,
`protocol()`, `wm_protocol()`,
`winfo_exists()`, `winfo_manager()`, `winfo_viewable()`, `winfo_ismapped()`,
`winfo_x()`, `winfo_y()`, `winfo_rootx()`, `winfo_rooty()`,
`winfo_screenwidth()`, `winfo_screenheight()`, `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, `winfo_server()`,
`winfo_reqwidth()`,
`winfo_reqheight()`, `winfo_vrootwidth()`, `winfo_vrootheight()`,
`winfo_vrootx()`, `winfo_vrooty()`, `winfo_pixels()`, `winfo_fpixels()`,
`winfo_rgb()`, `winfo_cells()`, `winfo_colormapfull()`, `winfo_depth()`,
`winfo_geometry()`, `winfo_id()`, `winfo_pointerx()`, `winfo_pointerxy()`,
`winfo_pointery()`, `winfo_visual()`, `winfo_visualid()`,
`winfo_visualsavailable()`, `winfo_atom()`, `winfo_atomname()`,
`winfo_containing()`, `winfo_interps()`, `winfo_pathname()`,
`winfo_width()`, `winfo_height()`, and
`winfo_toplevel()`.
The follow-up GUI promotion extends the visible-widget surface: Tk-backed
widgets and `Toplevel` windows now expose `winfo_viewable()`,
`winfo_ismapped()`, coordinate/root-coordinate/screen/request-size
`winfo_*()` queries, logical screen and virtual-root `winfo_*()` queries,
screen metadata `winfo_*()` queries, pixel-distance and RGB color `winfo_*()`
queries, visual/colormap/pointer/geometry/id `winfo_*()` queries,
atom/path/containing/interpreter `winfo_*()` queries,
`winfo_width()`, `winfo_height()`, and
`winfo_toplevel()`, while `Toplevel.geometry()` covers the observed get/set and
bad-geometry behavior. Tk roots and `Toplevel` windows also expose
`protocol()` / `wm_protocol()` for the covered window-manager callback paths.
The focus-management promotion adds `focus_set()`, `focus_force()`,
`focus_get()`, and `focus_displayof()` on Tk roots and child widgets.
The latest root-window option promotion adds `cget()`, `configure()`, and
`config()` on `Tk` roots for Python 3.10.11-matched root background option
set/read behavior, alias return values, and observed arity / option errors.
The latest option-key promotion adds `keys()` on `Tk` roots and Tk-backed
widgets, including Python 3.10.11-matched list returns, Tk `configure` option
ordering for representative root/window/widget classes, observed arity
errors, and destroyed-widget `TclError` behavior.
The latest window-decoration promotion adds `overrideredirect()` and
`wm_overrideredirect()` on `Tk` roots and `Toplevel` windows, including
Python 3.10.11-matched true-query values, false-query `None`, set-return
`None`, alias behavior, and observed arity / Tcl boolean validation errors.
The latest transient-window promotion adds `transient()` and `wm_transient()`
on `Tk` roots and `Toplevel` windows, including Python 3.10.11-matched master
path query/set/clear behavior, explicit `None` query behavior, alias behavior,
cycle errors, and bad-window-path validation.
The latest stacking promotion adds `lift()`, `tkraise()`, and `lower()` on
`Tk` roots and Tk-backed widgets, including Python 3.10.11-matched `None`
returns, explicit `None` target handling, widget/path targets, alias behavior,
and observed arity / bad-window-path errors.
The latest local-grab promotion adds `grab_set()`, `grab_release()`,
`grab_current()`, and `grab_status()` on `Tk` roots and Tk-backed widgets,
including Python 3.10.11-matched current-widget object mapping, local status
strings, no-grab `None` normalization, release idempotence, and observed arity
errors.
The latest wait promotion adds `wait_window()` and `wait_visibility()` on `Tk`
roots and Tk-backed widgets, including Python 3.10.11-matched default/self
targets, explicit `None` target behavior, widget targets, `None` returns,
event-loop-driven destroy/visibility completion, and observed arity /
AttributeError validation.
The latest variable-wait promotion adds `wait_variable(name='PY_VAR')` and its
`waitvar(...)` alias on `Tk` roots and Tk-backed widgets, including
Python 3.10.11-matched variable-object, string-name, default-name, and alias
behavior, `None` returns after scheduled variable updates, and observed arity
errors.
The latest idle-callback promotion adds `after_idle(func, *args)` on `Tk` roots
and Tk-backed widgets, including Python 3.10.11-matched required-`func`
validation, `after#N` id returns, callback argument delivery, idle execution on
`update()`, and cancellation through the existing `after_cancel(id)` path.
The widget identity-tree promotion adds `winfo_children()`, `winfo_class()`,
`winfo_name()`, and `winfo_parent()` for Tk roots, `Toplevel` windows, and
Tk-backed child widgets, including object identity for returned children,
root/child parent path strings, and destroyed-widget `TclError` behavior.
The latest path-lookup promotion adds `nametowidget(name)` on `Tk` roots and
Tk-backed widgets, including Python 3.10.11-matched absolute path, relative
child name, cross-widget root lookup, object identity returns, missing-name
`KeyError` messages, destroyed-widget `KeyError` behavior, and arity errors.
The latest image-registry promotion adds `image_names()` and `image_types()`
on `Tk` roots and Tk-backed widgets, including Python 3.10.11-matched tuple
returns for built-in Tk icons, named `PhotoImage` registry membership,
post-delete registry updates, widget/root parity, and arity errors.
The latest layout-manager promotion adds `pack_info()`, `pack_forget()`,
`grid_forget()`, `grid_remove()`, and `place_forget()` for Tk-backed widgets,
including probed manager state changes, `pack_info()` integer/string fields,
default bare-`pack()` restore behavior, `grid_forget()` default reset,
`grid_remove()` remembered-option restore behavior, `place_forget()` empty
info behavior, and observed arity / Tcl errors.
The layout child-query promotion adds `pack_slaves()`, `grid_slaves(...)`,
and `place_slaves()` on Tk roots and Tk-backed widgets, returning the same
wrapper objects that were laid out by the corresponding manager, preserving
the probed pack/grid/place ordering, row/column grid filters, forgotten-widget
removal, and observed arity / keyword / Tcl validation paths.
The latest grid geometry promotion adds `grid_size()`, `grid_bbox(...)`, and
`grid_location(x, y)` on Tk roots and Tk-backed widgets, including integer
tuple returns, full-grid and cell bbox reads, coordinate-to-cell reads,
object-form keyword analogues, Python's ignored-incomplete-argument behavior
for `grid_bbox(...)`, and observed arity / keyword / Tcl validation paths.
The grid row/column configuration promotion adds `grid_columnconfigure(...)`,
`columnconfigure(...)`, `grid_rowconfigure(...)`, and `rowconfigure(...)` on
Tk roots and Tk-backed widgets, including full-dict queries, single-option
queries, set returns, aliases, and observed arity / Tcl validation errors.
The latest layout propagation promotion adds `pack_propagate(...)`,
`grid_propagate(...)`, and `grid_anchor(...)` on Tk roots and Tk-backed
widgets, including Python 3.10.11's `None` argument handling, boolean-query
returns, set-return values, and observed arity / Tcl validation errors.
The latest clipboard promotion adds `clipboard_clear(...)`,
`clipboard_append(...)`, and `clipboard_get(...)` on Tk roots and Tk-backed
widgets, including concatenating append behavior, object-form keyword
analogues for `type` / `displayof`, empty-clipboard TclError behavior, and
observed arity / Tcl option validation errors.
The latest option-database promotion adds `option_add(...)`, `option_clear()`,
`option_get(...)`, and `option_readfile(...)` on Tk roots and Tk-backed
widgets, including new-widget option propagation, resource-file reads,
explicit `None` priority handling, and observed arity / Tcl validation errors.
The latest variable-trace promotion adds `trace_add(...)`,
`trace_remove(...)`, `trace_info()`, `trace_variable(...)`,
`trace_vdelete(...)`, and `trace_vinfo()` on `Variable`, `StringVar`,
`IntVar`, `DoubleVar`, and `BooleanVar`, including Python 3.10.11-matched
read/write/unset callback arguments, mode-list registration, legacy
`r`/`w`/`u` trace APIs, callback command cleanup, and observed arity /
bad-mode errors.
The latest window-management promotion adds Python 3.10.11-matched
`resizable()`, `minsize()`, and `maxsize()` behavior to `Tk` roots and
`Toplevel` windows, including tuple reads, set-return values, Tcl validation,
and arity errors.
The latest event promotion adds the first interaction slice: Tk-backed widgets
now expose `bind()` and `event_generate()` for the covered `<Button-1>` surface,
including synthetic event delivery, append binding, query behavior, minimal
`Event` / `EventType` fields, and observed TypeError/TclError paths.
The virtual-event promotion adds `event_add(...)`, `event_delete(...)`, and
`event_info(...)` on `Tk` roots and Tk-backed widgets, including global virtual
event table queries, physical sequence normalization, duplicate add behavior,
delete updates, explicit `None` query behavior, and observed arity / Tcl
validation errors.
The bind-tag routing promotion adds `bindtags(tagList := None)` on `Tk` roots,
`Toplevel` windows, and Tk-backed widgets, including default tag tuples,
tuple/list/string set behavior, empty tag-list no-op behavior, explicit
`None` query behavior, and observed arity / destroyed-widget errors.
The class/all binding promotion adds `bind_all(...)`, `bind_class(...)`,
`unbind(...)`, `unbind_all(...)`, and `unbind_class(...)` on `Tk` roots and
Tk-backed widgets, matching Python 3.10.11 query returns, callback ids,
widget/class/all event delivery, full-sequence unbind behavior, and observed
arity errors.
The Tcl-backed Misc conversion promotion adds `getint(s)`, `getdouble(s)`, and
`getboolean(s)` on `Tcl()` interpreters, `Tk` roots, and Tk-backed widgets,
matching Python 3.10.11 integer, float, bool, string, invalid literal, and
arity behavior.
The latest Entry promotion adds XView movement/query behavior:
`Entry(...)` now covers `xview(...)`, `xview_moveto(fraction)`, and
`xview_scroll(number, what)`, including tuple view queries, raw `moveto` /
`scroll` calls, index-form `xview(index)`, `XView.*` arity errors, and Tk-backed
bad index/fraction/number/unit errors. The previous Entry promotion added the
first cursor/selection interaction slice:
`Entry(...)` now covers `index(index)`, `icursor(index)`,
`select_range(...)` / `selection_range(...)`, `select_clear()` /
`selection_clear()`, `select_present()` / `selection_present()`,
`select_from(...)` / `selection_from(...)`, `select_to(...)` /
`selection_to(...)`, `select_adjust(...)` / `selection_adjust(...)`, and
`selection_get()` for the probed PRIMARY selection behavior.
The Canvas promotion adds item discovery and movement behavior:
`Canvas(...)` now covers `find_all()`, `find_withtag(tagOrId)`,
`bbox(*tagOrId)`, `move(tagOrId, xAmount, yAmount)`, and `type(tagOrId)` for
the probed item-id, tag, missing-item, and Tcl validation paths.
The Canvas drawing promotion adds `create_oval(...)`,
`create_polygon(...)`, and `create_text(...)`, including probed item types,
coordinate lists, item option reads, tag lookup, and coordinate/Tcl validation
errors.
The latest Canvas media promotion adds `create_image(...)` and
`create_window(...)`, covering PhotoImage-backed canvas images and embedded
widget windows with probed item ids, item types, coordinate lists, option
reads, bounding boxes, tag lookup, and coordinate/Tcl validation errors.
The latest Canvas view promotion adds `canvasx(...)`, `canvasy(...)`,
`xview(...)`, `xview_moveto(...)`, `xview_scroll(...)`, `yview(...)`,
`yview_moveto(...)`, and `yview_scroll(...)`, including coordinate
conversion, gridspacing rounding, explicit `None` gridspacing behavior,
view fraction tuples, direct `moveto` / `scroll` calls, wrapper aliases,
and observed arity / Tcl validation errors.
The Canvas tag promotion adds `addtag(...)`, `addtag_above(...)`,
`addtag_all(...)`, `addtag_below(...)`, `addtag_closest(...)`,
`addtag_enclosed(...)`, `addtag_overlapping(...)`, `addtag_withtag(...)`,
`dtag(...)`, and `gettags(...)`, including tag tuple ordering, raw Tcl-backed
search commands, convenience wrappers, tag deletion, missing-tag empty tuples,
and observed arity / Tcl validation errors.
The latest Canvas find-query promotion adds `find(...)`, `find_above(...)`,
`find_below(...)`, `find_closest(...)`, `find_enclosed(...)`, and
`find_overlapping(...)`, including raw Tcl-backed search commands, z-order
queries, closest-item optional `None` handling, enclosed / overlapping search
results, empty tuple missing-tag results, and observed TypeError / TclError
paths.
The latest Canvas arc/bitmap promotion adds `create_arc(...)` and
`create_bitmap(...)`, including probed item ids, item types, coordinate lists,
arc start / extent / style / outline / width options, bitmap name / color /
anchor options, bounding boxes, tag lookup, and observed IndexError / TclError
paths.
The latest Canvas text-item promotion adds `dchars(...)`, `focus(...)`,
`icursor(...)`, `index(...)`, `insert(...)`, `select_adjust(...)`,
`select_clear()`, `select_from(...)`, `select_item()`, and `select_to(...)`,
including text item cursor/index mutation, text insertion/deletion, focus item
queries, selection state, raw Tcl arity errors, and Python wrapper TypeError
paths.
The latest Canvas scan/scale promotion adds `scale(...)`, `scan_mark(x, y)`,
and `scan_dragto(x, y, gain=10)`, including coordinate scaling for item ids
and tags, missing-tag no-op behavior, scan-mark no-op view state, default and
explicit-gain drag scrolling, raw Tcl arity / coordinate validation errors,
and Python wrapper TypeError paths.
The latest Canvas z-order/moveto promotion adds `itemconfig(...)` as the
Python 3.10.11 alias for `itemconfigure(...)`, `moveto(tagOrId, x='', y='')`,
`tag_raise(...)`, and `tag_lower(...)`, including absolute item movement,
empty-string default coordinate forwarding, tag batch movement, item z-order
changes, missing-tag no-op movement, and observed TypeError / TclError paths.
The latest Canvas tag-event promotion adds `tag_bind(tagOrId, sequence=None,
func=None, add=None)` and `tag_unbind(tagOrId, sequence, funcid=None)`,
including tag sequence queries, event callback delivery through the existing
AHK event bridge, additive bindings, whole-sequence unbind behavior, missing
tag registration, and observed arity / command deletion errors.
The latest Canvas PostScript promotion adds `postscript(cnf={})`, including
EPS string export, option dictionaries for color mode, area and page settings,
file output with empty-string return, Tk's returned file-open error string,
and observed arity / option validation errors.

`stdlib\init.ahk` is a lightweight namespace root, not a Python-style dynamic
import loader. AutoHotkey includes are full file loads into a shared global
namespace, so `<stdlib\init>` must not include concrete modules such as
`<stdlib\toml>`. Module files include the root and explicitly mount their
namespace providers when that module is requested. For example,
`<stdlib\toml>` installs `stdlib.toml.*` because that module file
explicitly includes `<stdlib\init>` itself. AHK does not auto-load
`stdlib\init.ahk` from the directory layout. Callers should include the module
they use instead of expecting `<stdlib\init>` to load the whole stdlib.
Plain `#Include <stdlib\init>` is included only once by AutoHotkey, so repeated
module includes do not rerun the namespace root or clear earlier mounts.
`#IncludeAgain <stdlib\init>` and alternate-path includes are not allowed for
the stdlib surface because they can bypass that guarantee or cause duplicate
global class definitions.
The root namespace currently exposes `stdlib.None`, `stdlib.NotImplemented`,
`stdlib.NotImplementedError`, `stdlib.RuntimeError`, `stdlib.StopIteration`,
`stdlib.KeyError`, `stdlib.AttributeError`, `stdlib.SystemError`,
`stdlib.True`, `stdlib.False`, and `stdlib.tuple(...)`.

The root namespace currently exposes builtins-style helpers:
`stdlib.None` as the shared AHK sentinel for Python `None` semantics where
omitted AHK parameters are not expressive enough, `stdlib.NotImplemented` as
the shared Python `NotImplemented` sentinel for covered provider-protocol and
type-name parity paths, `stdlib.NotImplementedError` /
`stdlib.RuntimeError` / `stdlib.StopIteration` / `stdlib.KeyError` /
`stdlib.AttributeError` / `stdlib.SystemError` as root-level builtin-style
error classes for covered parity paths, `stdlib.True` / `stdlib.False` as
root-level shared boolean singleton values, and `stdlib.tuple(...)` as a first
root-level tuple constructor for cases where
the direct module surface needs stable Python-like readonly tuple materialization.
For example, `stdlib.itertools.islice(values, 1, stdlib.None, 2)` maps to
Python `itertools.islice(values, 1, None, 2)`, `stdlib.True` maps to Python
`True`, including covered bool-as-int argument paths such as
`itertools.combinations(values, True)`,
`itertools.combinations_with_replacement(values, True)`,
`itertools.permutations(values, True)`, `itertools.islice(values, True)`,
`itertools.repeat(value, True)`, and `itertools.tee(iterable, True)`, and
`stdlib.tuple("ab")` maps to Python `tuple("ab")`, including covered
type-name parity for integer-interpretation errors such as
`itertools.tee(iterable, tuple())`. Shared stdlib truthiness
treats `None`, `False`, empty arrays/maps, and empty stdlib tuples as false
for covered direct-module behavior such as `itertools.compress` selectors,
`itertools.takewhile` predicate results, and `itertools.filterfalse` with a
`None` predicate.

`stdlib.itertools` now follows Python 3.10.11 type-name parity for covered
non-iterable and integer-interpretation error paths across `repeat(...)`,
`chain(...)`, and `islice(...)`, including direct `Fraction` and
`decimal.Decimal` payloads. Covered error text now uses Python names such as
`Fraction`, `decimal.Decimal`, `function`, `list`, `dict`, and `NoneType`
instead of raw AHK implementation class names.
Its current `count(...)` slice also accepts root `stdlib.True` /
`stdlib.False` start and step values as Python bool-as-int numeric inputs,
including the Python 3.10.11 first-yield bool preservation for explicit root
bool starts outside the integer-step-`1` fast path. It accepts covered
same-family direct numeric progressions such as `Decimal + Decimal` and
`Fraction + Fraction`, while still rejecting mixed `decimal.Decimal` /
`Fraction` arithmetic at first iteration like local Python 3.10.11.
The covered keyword-capable `count` wrapper now also distinguishes Python's
single-invalid-key and too-many-keyword branches: `stdlib.itertools.count({
step: 2, extra: 3 })` still raises `'extra' is an invalid keyword argument for
count()`, while `stdlib.itertools.count({ start: 1, step: 2, extra: 3 })` now
raises `count() takes at most 2 keyword arguments (3 given)` instead of
stopping at the first unexpected field.

`stdlib.collections.Counter` now also follows Python 3.10.11 for covered
mapping-update and mapping-subtract arithmetic on direct numeric payloads:
same-family `Fraction` and same-family `decimal.Decimal` counts mutate through
their existing direct stdlib `__Add` / `__Sub` paths, while mixed
`Fraction` / `decimal.Decimal` mapping arithmetic remains unsupported with
Python-style binary-operator TypeErrors.

`stdlib.array` is now direct as a first slice of Python 3.10.11's `array`
module, migrated from the old `bufferarray` source material but exposed on the
public Python-path root as `stdlib.array.array(...)`. The current slice covers
module-level `typecodes`, constructor-style `stdlib.array.array(typecode,
initializer?)`, observable `.typecode` and `.itemsize` properties, zero-based
index get/set semantics, `.append(...)`, `.extend(...)`, `.tolist()`,
`.buffer_info()`, iteration, and Python-style `__Repr()` output for covered
numeric arrays. Covered invalid branches now also match the local Python 3.10.11
baseline for bad typecodes, non-iterable initializers and `extend(...)`
payloads, non-integer-compatible `append(...)` payloads, and out-of-range
indexes.

`stdlib.pprint` is now direct as a first slice of Python 3.10.11's `pprint`
module, migrated from the old `print` source material but exposed on the
public Python-path root as `stdlib.pprint.*`. The current slice covers
module-level `pformat(...)`, `pprint(...)`, and `pp(...)`, plus
`stdlib.pprint.PrettyPrinter(...).pformat(...)` / `.pprint(...)` for the
covered constructor parameters `indent`, `width`, `depth`, `stream`,
`compact`, and `sort_dicts`. The covered pretty-printing surface currently
matches the local Python baseline for nested list/dict formatting, compact
multi-line list layout, depth truncation to `[...]`, stream writes through
`stdlib.io.StringIO`, default sorted-dict formatting, and the observed
`ValueError("invalid literal for int() with base 10: 'x'")` and
`AttributeError("'int' object has no attribute 'write'")` branches. AHK
`Map(...)` enumeration on this host is already key-sorted for the covered
inputs, so `sort_dicts=False` does not yet create an independently observable
order difference on plain maps in this slice.

`stdlib.hashlib` is now direct as a first runtime slice centered on local
Python 3.10.11 hashing behavior for covered named algorithms. The current
public shape covers `stdlib.hashlib.algorithms_guaranteed`, constructor-style
`stdlib.hashlib.new(name, data?)`, convenience constructors
`stdlib.hashlib.md5(...)`, `stdlib.hashlib.sha1(...)`, and
`stdlib.hashlib.sha256(...)`, plus hash-object `.name`, `.digest_size`,
`.block_size`, `.update(...)`, `.digest()`, `.hexdigest()`, and `.copy()`
behavior for the covered algorithms. The current slice accepts Buffer-like
byte payloads, preserves incremental update state, returns lowercase hex
digests matching local Python's covered vectors, clones state through
`.copy()` without mutating the original object, raises
`ValueError("unsupported hash type ...")` for covered unsupported algorithms
such as `crc32`, and raises Python-style
`TypeError("Strings must be encoded before hashing")` when passed text
payloads directly instead of bytes.

`stdlib.string` is now direct as a first slice of Python 3.10.11 `string`,
promoted onto the public Python-path root as `stdlib.string.*`. The current
slice covers the observed module constants `ascii_lowercase`,
`ascii_uppercase`, `ascii_letters`, `digits`, `hexdigits`, `octdigits`,
`punctuation`, `whitespace`, and `printable`, plus `capwords(s, sep?)` for the
observable local baseline. Covered behavior currently matches local Python
3.10.11 for default whitespace-collapsing title-casing, explicit `None`
separator parity, explicit string separators including repeated delimiters,
and the observed local error wording for missing source arguments, excess
positional arguments, non-string source payloads, non-string separators, empty
separators, and the covered `bool` separator split where `True` raises a
Python-style missing-`join` `AttributeError` while `False` raises the observed
`TypeError("must be str or None, not bool")`. `Formatter`, `Template`, named
constant helpers such as `digits`-driven classes, and the wider formatting
surface remain deferred. To keep the public root budget stable at 57 slots,
the old `kazmath` placeholder has been removed from the root-slot manifest
count in favor of this concrete Python stdlib root.

`stdlib.keyword` is now direct as a first slice of Python 3.10.11 `keyword`,
promoted onto the public Python-path root as `stdlib.keyword.*`. The current
slice covers the observed local 3.10.11 `kwlist` and `softkwlist` contents,
plus `iskeyword(value)` and `issoftkeyword(value)` for the covered predicate
behavior. Covered behavior currently matches the local runtime for classic
keywords such as `for`, soft keywords such as `match`, false results for
covered non-string payloads such as `1`, and the observed local
`frozenset.__contains__()` arity wording for zero-argument and two-argument
misuse. To keep the public root budget stable at 57 slots, the old
`algorithm` placeholder has been removed from the root-slot manifest count in
favor of this concrete Python stdlib root.

`stdlib.fnmatch` is now direct as a first slice of Python 3.10.11 `fnmatch`,
promoted onto the public Python-path root as `stdlib.fnmatch.*`. The current
slice covers `fnmatch(name, pat)`, `fnmatchcase(name, pat)`, `filter(names,
pat)`, and `translate(pat)` for the observed local baseline: Windows-style
case-normalized matching in `fnmatch`, case-sensitive matching in
`fnmatchcase`, iterable filtering, the covered `translate()` regex outputs for
`*.txt` and `[!a]*.txt`, direct wildcard/question/negated-bracket behavior,
and the observed local arity/type-error wording for missing arguments, too
many arguments, non-string inputs, and covered mixed string/bytes-like misuse.
To keep the public root budget stable at 57 slots, the old `vector`
placeholder has been removed from the root-slot manifest count in favor of
this concrete Python stdlib root.

`stdlib.glob` is now direct as a first slice of Python 3.10.11 `glob`,
promoted onto the public Python-path root as `stdlib.glob.*`. The current
slice covers `glob(pathname, { recursive: true|false }?)`, `escape(pathname)`,
and `has_magic(s)` for the observed local baseline: plain wildcard collection,
covered `**` recursive collection through the keyword-only `recursive`
analogue, direct `escape()` output for covered bracket/meta characters, direct
`has_magic()` behavior for covered plain and wildcard strings, and the
observed local arity/type-error wording for missing arguments, too many
positional arguments, and invalid non-string payloads. To keep the public
root budget stable at 57 slots, the old `keyboard` placeholder has been
removed from the root-slot manifest count in favor of this concrete Python
stdlib root.

`stdlib.textwrap` is now direct as a first slice of Python 3.10.11
`textwrap`, promoted onto the public Python-path root as `stdlib.textwrap.*`.
The current slice covers `dedent(text)` and
`indent(text, prefix, predicate := unset)` for the observed local baseline:
common-margin removal across covered mixed-indent multiline strings, blank-line
dedent normalization for covered whitespace-only lines, default indentation of
non-blank lines only, predicate-driven all-line and no-line indentation for
covered callable returns, and the observed local arity/type-error wording for
missing arguments, too many positional arguments, non-string text values,
non-string prefixes, and non-callable predicates. To keep the public root
budget stable at 57 slots, the last root-slot placeholder `linq` has been
removed from the manifest count in favor of this concrete Python stdlib root.

`stdlib.base64` is now direct as a first slice of Python 3.10.11 `base64`,
promoted onto the public Python-path root as `stdlib.base64.*`. The current
slice covers `b64encode(s, altchars := None)` and
`b64decode(s, altchars := None, validate := False)` for the observed local
baseline: bytes-to-bytes Base64 encoding, bytes and ASCII-string decode input,
covered two-byte `altchars` handling, covered bool-like `validate` acceptance,
and the observed local arity/type-error wording for missing arguments, too
many positional arguments, text passed where bytes are required, non-bytes or
non-ASCII decode payloads, and invalid `altchars` length. To keep the public
root budget stable at 57 slots, one native-quarantine slot has been reclaimed
in favor of this concrete Python stdlib root.

`stdlib.getpass` is now direct as a first slice of Python 3.10.11 `getpass`,
promoted onto the public Python-path root as `stdlib.getpass.*`. The current
slice covers `getuser()` for the observed local Windows baseline: environment
variable priority `LOGNAME`, then `USER`, then `LNAME`, then `USERNAME`,
empty-string skipping for earlier variables, Python-style zero-argument arity
enforcement, and the observed local Windows fallback when every environment
variable is missing, which raises `ModuleNotFoundError("No module named
'pwd'")`. This promotion also adds root builtin-style
`stdlib.ModuleNotFoundError(...)` parity for covered direct-module behavior.
To keep the public root budget stable at 57 slots, the last remaining
native-quarantine slot has been reclaimed in favor of this concrete Python
stdlib root.

`stdlib.binascii` is now direct as a first slice of Python 3.10.11
`binascii`, promoted onto the public Python-path root as `stdlib.binascii.*`.
The current slice covers `hexlify(data, sep?, bytes_per_sep?)`,
`b2a_hex(...)`, `unhexlify(hexstr)`, and `a2b_hex(...)`, plus module-level
`Error` and `Incomplete` error aliases, for the observed local baseline:
lowercase bytes-to-bytes hex encoding, bytes and ASCII-string hex decode
input, covered one-byte separator handling, covered bool-like and integer
`bytes_per_sep` grouping including zero and negative values, and the observed
local arity/type/value-error wording for missing arguments, too many
positional arguments, text passed where bytes are required, bad separator
length, non-length-like separators, non-integer `bytes_per_sep`, odd-length
decode strings, invalid hex digits, and non-bytes/non-ASCII decode payloads.
To keep the public root budget stable at 57 slots, another native-quarantine
slot has been reclaimed in favor of this concrete Python stdlib root.

`stdlib.quopri` is now direct as a first slice of Python 3.10.11 `quopri`,
promoted onto the public Python-path root as `stdlib.quopri.*`. The current
slice covers `encodestring(s, quotetabs := False, header := False)` and
`decodestring(s, header := False)` for the observed local baseline:
bytes-to-bytes quoted-printable encoding and decoding, covered header-mode
space and underscore handling, covered tab and trailing-whitespace quoting,
covered hex escape and soft line-break decoding, ASCII-string decode input,
and the observed local arity/type/value-error wording for missing arguments,
too many positional arguments, text passed where bytes are required on
encode, non-bytes/non-ASCII decode payloads, and non-integer-like flag
arguments. To keep the public root budget stable at 57 slots, another
native-quarantine slot has been reclaimed in favor of this concrete Python
stdlib root.

`stdlib.html` is now direct as a first slice of Python 3.10.11 `html`,
promoted onto the public Python-path root as `stdlib.html.*`. The current
slice covers `escape(s, quote := True)` and `unescape(s)` for the observed
local baseline that is practical in AHK v2: `&`, `<`, `>`, double-quote, and
single-quote escaping with covered bool-like `quote` handling, plus named and
numeric entity unescaping for the probe-covered local cases such as `&amp`,
`&nbsp;`, `&#62;`, and `&#x27;`. Covered error wording also follows the local
Python 3.10.11 baseline for missing arguments, too many positional arguments,
non-string `escape(...)` payloads raising `'... object has no attribute
'replace'`, and non-string `unescape(...)` payloads raising
`TypeError("argument of type '...' is not iterable")`. To keep the public root
budget stable at 57 slots, another native-quarantine slot has been reclaimed
in favor of this concrete Python stdlib root.

`stdlib.secrets` is now direct as a first slice of Python 3.10.11 `secrets`,
promoted onto the public Python-path root as `stdlib.secrets.*`. The current
slice covers `choice(sequence)`, `randbelow(exclusiveUpperBound)`,
`token_bytes(nbytes := 32)`, `token_hex(nbytes := 32)`, and
`compare_digest(left, right)` for the observable local baseline that is
practical in AHK v2. Covered behavior currently matches local Python 3.10.11
for list and string `choice(...)`, Python-style `IndexError` wording for empty
list and empty string input, Python-style no-`len()` `TypeError` wording for a
covered non-sequence integer input, `randbelow(1) == 0`, bool-as-int acceptance
for `randbelow(True)`, zero-bound `ValueError("Upper bound must be positive.")`,
the observed local `AttributeError` wording for float input, the observed local
`NoneType` comparison wording for `stdlib.None`, default 32-byte token
generation, explicit-length token generation including zero-length outputs,
Python-style `ValueError("negative argument not allowed")` for negative token
lengths, lowercase hexadecimal encoding for `token_hex(...)`, and covered
string-vs-string / bytes-vs-bytes `compare_digest(...)` equality plus mixed
text/bytes and bad-arity `TypeError` wording. Wider helpers such as
`token_urlsafe(...)`, direct `SystemRandom`, and deeper bytes-like protocol
coverage remain deferred. To keep the public root budget stable at 57 slots,
the old `stateflow` placeholder has been removed from the root-slot manifest
count until there is a concrete `concurrent.futures`-style Python root plan
worth promoting back into the public budget.

`stdlib.os` is treated as a top-level module object so that the Python-like
call shape is `stdlib.os.system(command)`. Future path APIs should mount as
`stdlib.pathlib` or another explicit top-level namespace, not as an
include-order-sensitive child such as `stdlib.os.pathlib`.

`stdlib.platform` is now direct as a first Windows-focused slice of Python
3.10.11 `platform`, promoted from the old `wmi` candidate slot but exposed on
the public Python-path root as `stdlib.platform.*`. The current slice covers
`system()`, `node()`, `release()`, `version()`, `machine()`, `processor()`,
`python_version()`, `python_implementation()`, `platform(aliased?, terse?)`,
`uname()`, `architecture(executable?, bits?, linkage?)`, and
`system_alias(system, release, version)` for the observed local Windows 3.10.11
baseline. Covered behavior currently matches the local probe for Windows root
strings such as `Windows`, host node name, `10` release, raw `A_OSVersion`
version text, `AMD64` machine, `PROCESSOR_IDENTIFIER` processor text,
`Windows-10-...-SP0` default `platform()` formatting, `Windows-10` terse
formatting, the six-field iterable `uname_result` shape with processor stored
but omitted from repr, and the observed architecture tuple slice
`("64bit", "WindowsPE")` plus `("", "")` linkage override behavior when both
string arguments are explicitly blank. Covered arity errors now also follow the
local Python 3.10.11 wording for zero-argument accessors, `platform(...)`, and
`system_alias(...)`.

`stdlib.socket` is now direct as a first runtime slice of Python 3.10.11
`socket`, promoted from the old `online` candidate slot but exposed on the
public Python-path root as `stdlib.socket.*`. The current slice covers module
constants `AF_INET`, `SOCK_STREAM`, `IPPROTO_TCP`, and `has_ipv6`,
`gethostname()`, and a minimal `socket.socket(...)` object with covered default
construction, covered keyword-object construction, `.family`, `.type`, `.proto`,
`.closed`, `.fileno()`, `.close()`, and `__Repr()` behavior. Covered behavior
currently matches the local Windows 3.10.11 probe for host name, default
`AF_INET`/`SOCK_STREAM`/`proto=0` sockets, explicit `proto=IPPROTO_TCP`
keyword construction, `fileno() == -1` after close, and the observed
`_socket.gethostname()` arity wording plus unexpected-keyword wording for the
covered AHK keyword-object adapter.

`stdlib.abc` is now direct as a first abstract-base-class slice of Python
3.10.11 `abc`, promoted from the old `std` candidate slot but exposed on the
public Python-path root as `stdlib.abc.*`. The current slice covers
`ABC.register(subclass)`, `abstractmethod(funcobj)`, and covered helper
predicates `isabstract(value)` and `isinstance(instance, cls)` for the minimal
AHK expression of the observed Python semantics. Covered behavior currently
matches the local Python 3.10.11 probe for `abstractmethod()` arity wording,
callable decoration via `__isabstractmethod__`, `ABC.register(...)` returning
the same subclass object, virtual subclass `isinstance` truth after
registration, and the observed fact that a registered subclass without
abstract members remains non-abstract.

`ahktest` is the first-class stdlib test framework. It must grow toward
pytest 7.4.3 capability parity under AHK v2 constraints before broad module
migration, because every future Python-compatible stdlib module should be
specified through ahktest tests first. Current direct `ahktest` capabilities
include isolated suites, static test collection, parametrized cases with ids
and merged option/row marks,
runtime skips, conditional skips, expected-failure tracking, exception message
matching, deep equality for arrays/maps, approximate comparisons, regex/contains
assertions, explicit function-scope and suite-scoped fixtures, autouse fixtures,
structured results, max-fail run control, fixture cleanup, filter/list runs,
temporary directory fixtures, reversible environment monkeypatching, marker
metadata/filtering, source-location helpers, warning capture helpers,
child-process stdout/stderr capture helpers, summary selectors,
config-backed and JSON-manifest-backed run defaults, lifecycle hooks with priority/id controls,
request-like fixture parameter access, and temporary directory helpers.
This is progress toward parity, not a declaration that pytest equivalence is
complete.

Current practical estimate: ahktest is strong enough to start foundational
stdlib modules in parallel with further test-framework work. It covers the
core behaviors needed for pure modules and file/process smoke tests
(collection, parametrization, fixtures, temp paths, monkeypatch, capture,
marks, skip/xfail, approximate comparisons, warnings, filtering, reporting,
and hooks), but it is still not close to full pytest equivalence. Remaining
high-value gaps are filesystem discovery/config policy, richer assertion diffs,
warning-module integration, fixture/request edge cases, and plugin metadata.

`stdlib.base` remains a support-surface module rather than a Python-path
module, but it now carries one concrete Python-adjacent helper:
`stdlib.base.delattr(obj, name)`. The current direct slice removes own AHK
object properties through a stable public `stdlib.module.func(...)` shape,
raises Python-style `attribute name must be string, not 'int'` messages for
non-string attribute names, preserves readonly-property failures from
underlying AHK objects such as `functools.partial(...).func`, and raises
Python-style `'<type>' object has no attribute '<name>'` messages for missing
or non-object targets. This gives the stdlib surface a public deletion helper
without introducing a root-level `stdlib.del(...)` entrypoint that would break
the current module-oriented API policy.

`stdlib.datetime` is now direct as a first slice centered on
`stdlib.datetime.timedelta(...)`, `stdlib.datetime.date(...)`, and a first
`stdlib.datetime.datetime(...)` slice. The current public shape covers
normalized `timedelta` construction from an AHK object or `Map` with
Python-named duration components, readonly `.days` / `.seconds` /
`.microseconds` observations, `total_seconds()`, string formatting that
matches the local Python 3.10.11 baseline for covered cases, Python-style
component type errors and overflow checks, and arithmetic/comparison/unary
behavior through `stdlib.operator` dispatch (`add`, `sub`, `mul`, `neg`,
`pos`, `gt`, and related helpers). The `date` slice currently covers direct
construction, `today`, `min`, `max`, `resolution`, `fromordinal`,
`fromtimestamp`, `fromisoformat`, `toordinal`, `isoformat`, `ctime`, `weekday`,
`isoweekday`, `isocalendar`, `replace`, and `date +/- timedelta` plus
`date - date` behavior through the same operator dispatch path. The current
`datetime` slice covers direct construction, `now`, `utcnow`,
`fromtimestamp`, `utcfromtimestamp`, `fromisoformat`, `today`, `ctime()`,
`strftime()` (including `%f`), `isoformat(timespec?)`, `date()`, `time()`
returning a direct `time` object, `datetime.time(...)`,
`datetime.combine(date, time)`,
`time.fromisoformat(...)`, `time.isoformat(timespec?)`,
`time.min/max/resolution`, `time.replace(...)`, `time` rich comparison,
`replace(...)`, `datetime +/- timedelta`, `datetime - datetime`, rich
comparison, and Python-style cross-type equality/inequality behavior
through `stdlib.operator`.

Other modules remain `candidate`, `missing`, or `native-quarantine` until
promoted through the same red-green flow.

`stdlib.fractions` is now direct as a first slice of Python 3.10.11
`fractions`. The current slice covers `Fraction(...)` construction and
normalization, numerator/denominator observability, Python-style `str`/`repr`,
basic arithmetic and comparison through `stdlib.operator`, integer interop for
the covered arithmetic/comparison paths, covered native-float arithmetic and
comparison parity where local Python returns `float`, float conversion including
`Fraction.from_float(...)`, `as_integer_ratio()`, `limit_denominator(...)`,
unary/truth behavior, and Python 3.10 style constructor errors.

`stdlib.decimal` is now direct as a first slice of Python 3.10.11 `decimal`.
The current slice covers `Decimal(...)` construction from strings and integers,
preserved decimal/trailing-zero formatting, Python-style `repr`, basic
addition/subtraction/multiplication/division/floor-division/modulo/comparison through `stdlib.operator`,
integer interop for the covered arithmetic paths, unary/truth behavior,
`normalize()` including scientific-notation cases such as `500.000 -> 5E+2`,
finite-result decimal division such as `1.25 / 2 -> 0.625` and
`2 / Decimal("0.5") -> 4`, default-precision repeating-result division parity
for cases such as `1 / 3`, `2 / 3`, and `1 / 6` using Python's 28-digit
context behavior, preserved trailing-zero significance such as
`Decimal("1.00") / Decimal("2") -> 0.50`, covered comparison parity against
`Fraction` values for Python-valid `eq/ne/lt/le/gt/ge` paths, plus covered `//`
and `%` parity including integer interop, sign behavior, DivisionByZero on
`// 0`, and InvalidOperation on `% 0`, and Python 3.10 style invalid string
and dict-construction errors. Cross-type `Decimal`/`Fraction` arithmetic
remains unsupported, matching local Python 3.10.11.

`stdlib.logging` is now direct as a first slice of Python 3.10.11 `logging`.
The current slice exposes numeric level constants, `getLogger()`,
`basicConfig(...)`, module-level `debug(...)` / `info(...)` / `warning(...)` /
`error(...)` / `critical(...)` / `fatal(...)`, root/named logger objects with `name`, `level`,
`handlers`, `setLevel(...)`, `getEffectiveLevel()`, `isEnabledFor(...)`,
`debug(...)`, `info(...)`, `warning(...)`, `error(...)`, `critical(...)`, and `fatal(...)`, plus formatted
`%(levelname)s:%(name)s:%(message)s` stream output through a minimal
`StreamHandler`/`Formatter` path. The public direct surface now also exposes
`stdlib.logging.Formatter(...)`, `stdlib.logging.StreamHandler(...)`, and a
first direct `stdlib.logging.FileHandler(path, mode := "a", encoding := "UTF-8")`
slice. `basicConfig(...)` accepts a Python-style `format` string for the
initial root handler formatter and now also covers the observed Python 3.10.11
file-backed root setup slice through `filename`, `filemode`, and `encoding`,
including truncating behavior for `filemode := "w"` and the
`ValueError("'stream' and 'filename' should not be specified together")`
conflict path when both root-target options are provided on a fresh
configuration run. Fresh-root `basicConfig({ handlers: [handler, ...] })` now
also follows the observed Python 3.10.11 handler-list slice by installing the
same passed-in handler objects onto the root logger, supplying the default
`%(levelname)s:%(name)s:%(message)s` formatter only when a passed handler does
not already have one, preserving preconfigured handler formatters, and raising
`ValueError("'stream' or 'filename' should not be specified together with 'handlers'")`
when the handler-list path is mixed with `stream` or `filename`. The current direct handler slice also supports
`handler.setLevel(...)` filtering, `handler.close()`, formatter substitution of
`%(levelno)s` alongside `%(levelname)s`, `%(name)s`, and `%(message)s`, and
basic file-backed append/write logging behavior through `FileHandler`.
Covered handler lists now also accept broader iterable inputs beyond plain
arrays, matching the observed Python 3.10.11 behavior where `handlers=` can be
supplied as other iterables such as tuples or generator-backed iterables; the
current AHK direct slice accepts stdlib tuple-like arrays and custom
`__Enum`-backed iterables, materializes their handler objects, and then applies
the same default-formatter/preserved-formatter rules as the array path.
The direct behavior currently matches Python's
root-name normalization (`None`, `""`, and `"root"` all resolve to the root
logger), effective-level inheritance for named loggers, and `basicConfig(...)`
being a no-op after handlers already exist on the root logger unless
`force := true` is supplied. Covered `basicConfig({ ..., force: true })` now
follows the observed Python 3.10.11 root-reconfiguration slice by replacing
existing root handlers with the newly requested stream/file-backed handler,
closing prior file-backed root handlers so the old log target is released, and
letting removed stream-backed handlers leave caller-owned in-memory streams
readable after reconfiguration. The current
level-handling slice also accepts Python level-name strings such as `"INFO"`
and `"DEBUG"` for `basicConfig(level := ...)` and `logger.setLevel(...)`,
accepts the Python alias names `"WARN"` and `"FATAL"` alongside the
corresponding `stdlib.logging.WARN` and `stdlib.logging.FATAL` constants, and
raises Python-style `ValueError("Unknown level: 'NOPE'")` for unknown names on
fresh configuration paths. It also now
matches Python's named-logger no-handler fallback behavior: a named logger can
emit a bare message to stderr without auto-installing root handlers, but only
for `WARNING` and above, while the module-level logging helpers still
auto-configure the root logger and emit formatted output. Richer handler
classes and file-based configuration remain deferred. The current logger slice
now also exposes Python-style `logger.propagate` behavior: named loggers
default to propagation through ancestor handlers, so a child logger with its
own handler can duplicate emission into both the child and root streams, while
setting `logger.propagate := false` stops delivery to ancestor handlers without
falling back to the root logger.

`stdlib.queue` is now direct as a first slice of Python 3.10.11 `queue`.
The current slice exposes `stdlib.queue.Queue(maxsize := 0)`, `stdlib.queue.SimpleQueue()`,
`stdlib.queue.LifoQueue(maxsize := 0)`, `stdlib.queue.PriorityQueue(maxsize := 0)`, plus public
`stdlib.queue.Empty` and `stdlib.queue.Full` exception classes. Covered behavior includes `qsize()`,
`empty()`, `full()`, `put(...)`, `get(...)`, `put_nowait()`, and `get_nowait()`,
bounded-queue `Full` / empty-queue `Empty` parity for `block := false` and
`timeout := 0`, Python-style `ValueError("'timeout' must be a non-negative number")`
for negative timeout values on blocking calls, Python-style `timeout=None`
handling through `stdlib.None` for covered ready and non-blocking queue paths,
Python's unbounded behavior for
`maxsize <= 0`, Python-style passthrough `maxsize` observability for non-integer
constructor values such as `1.5`, `"1"`, and `None`, Python-style `full()`
comparison failures for unsupported `maxsize` values like `'<' not supported
between instances of 'int' and 'str'`, and covered task accounting through
`unfinished_tasks` plus `task_done()` including
`ValueError("task_done() called too many times")`, plus `join()` returning once
all unfinished tasks are complete for `Queue`, `LifoQueue`, and `PriorityQueue`,
while `SimpleQueue` currently
covers FIFO `put/get/put_nowait/get_nowait`, `qsize()/empty()`, empty-queue
`Empty` parity, Python 3.10.11 `put(...)` compatibility parameters that ignore
`block` and `timeout` including negative or non-numeric timeout values, and
Python-style negative-timeout `ValueError` on blocking `get(...)`,
and `LifoQueue` currently covers stack-order `put/get/put_nowait/get_nowait`,
`qsize()/empty()/full()`, bounded `Full` / empty `Empty` parity, and the same
covered timeout validation shape as `Queue`, and `PriorityQueue` currently covers
min-priority `put/get/put_nowait/get_nowait`, numeric and covered list-priority
ordering, `qsize()/empty()/full()`, bounded `Full` / empty `Empty` parity, and the
same covered timeout validation shape as `Queue`.

`stdlib.asyncio` is now direct as a first slice of Python 3.10.11 `asyncio`.
The current slice exposes `stdlib.asyncio.Future(...)`,
`stdlib.asyncio.isfuture(obj)`, `stdlib.asyncio.new_event_loop()`, plus public
`stdlib.asyncio.CancelledError` and `stdlib.asyncio.InvalidStateError`
exception classes. Covered behavior includes `Future()` and `Future({ loop:
loop_obj })` construction, Python-style keyword-only constructor failures for
positional arguments, invalid keyword names, too-many-keyword wrappers, and
bad `loop` objects, `done()` / `cancelled()` / `cancel()` state transitions,
`result()` / `exception()` invalid-state and cancelled branches, finished
result and finished exception storage, `set_result(...)` /
`set_exception(...)` single-argument and invalid-state errors, accepting either
an exception instance or exception class for `set_exception(...)`, Python-style
`<Future pending>`, `<Future finished result=...>`, `<Future finished
exception=RuntimeError('boom')>`, and `<Future cancelled>` repr shapes for the
covered paths, plus `asyncio.isfuture(...)` arity validation and predicate
results. Event-loop integration beyond the covered `get_debug()` acceptance
shape remains deferred.

`stdlib.tkinter` is now direct as a first Tcl/Tk-oriented slice of Python 3.10.11
`tkinter`, promoted onto the public Python-path root as `stdlib.tkinter.*`.
The current slice exposes covered module constants `TclVersion`, `TkVersion`,
`READABLE`, `WRITABLE`, `EXCEPTION`, the non-conflicting Python 3.10.11
geometry/state/selection/relief/orientation/scrolling constants, boolean-style
integer constants, and `wantobjects` (with `CHECKBUTTON` / `RADIOBUTTON`
unclaimed because they collide with constructor names in AHK), module functions
`stdlib.tkinter.NoDefaultRoot()`, `stdlib.tkinter.getint()`, `stdlib.tkinter.getdouble()`,
`stdlib.tkinter.getboolean(s)`, `stdlib.tkinter.image_names()`,
`stdlib.tkinter.image_types()`, and
`stdlib.tkinter.mainloop(...)`, plus `stdlib.tkinter.Event()`,
`stdlib.tkinter.EventType(value)`,
`stdlib.tkinter.CallWrapper(func, subst, widget)`,
`stdlib.tkinter.Pack()`, `stdlib.tkinter.Place()`,
`stdlib.tkinter.Grid()`, `stdlib.tkinter.XView()`,
`stdlib.tkinter.YView()`, `stdlib.tkinter.Misc()`,
`stdlib.tkinter.Wm()`,
`stdlib.tkinter.Tcl(...)`,
`stdlib.tkinter.Tk(...)`, `stdlib.tkinter.Variable(...)`,
`stdlib.tkinter.StringVar(...)`,
`stdlib.tkinter.IntVar(...)`, `stdlib.tkinter.DoubleVar(...)`,
`stdlib.tkinter.BooleanVar(...)`, `stdlib.tkinter.Frame(...)`,
`stdlib.tkinter.BaseWidget(...)`,
`stdlib.tkinter.Widget(...)`,
`stdlib.tkinter.Label(...)`, `stdlib.tkinter.LabelFrame(...)`,
`stdlib.tkinter.Toplevel(...)`, `stdlib.tkinter.Message(...)`,
`stdlib.tkinter.Button(...)`, `stdlib.tkinter.Menubutton(...)`,
`stdlib.tkinter.OptionMenu(...)`, `stdlib.tkinter.PanedWindow(...)`,
`stdlib.tkinter.Checkbutton(...)`,
`stdlib.tkinter.Radiobutton(...)`, `stdlib.tkinter.Scale(...)`,
`stdlib.tkinter.Scrollbar(...)`, `stdlib.tkinter.Menu(...)`,
`stdlib.tkinter.Entry(...)`, `stdlib.tkinter.Spinbox(...)`,
`stdlib.tkinter.Listbox(...)`,
`stdlib.tkinter.Text(...)`,
`stdlib.tkinter.Image(...)`, `stdlib.tkinter.BitmapImage(...)`,
`stdlib.tkinter.PhotoImage(...)`,
`stdlib.tkinter.Canvas(...)`, and public
`stdlib.tkinter.TclError`, plus the first covered themed-widget submodule
surfaces `stdlib.tkinter.ttk.Frame(...)`, `stdlib.tkinter.ttk.Label(...)`,
`stdlib.tkinter.ttk.Entry(...)`, `stdlib.tkinter.ttk.Combobox(...)`,
`stdlib.tkinter.ttk.Button(...)`, `stdlib.tkinter.ttk.Checkbutton(...)`,
`stdlib.tkinter.ttk.Radiobutton(...)`, `stdlib.tkinter.ttk.Scale(...)`, and
`stdlib.tkinter.ttk.Scrollbar(...)`,
plus `stdlib.tkinter.ttk.Separator(...)`,
`stdlib.tkinter.ttk.Progressbar(...)`, `stdlib.tkinter.ttk.Notebook(...)`,
`stdlib.tkinter.ttk.LabelFrame(...)`, `stdlib.tkinter.ttk.Panedwindow(...)`,
and `stdlib.tkinter.ttk.Sizegrip(...)`. The
covered behavior matches local Python 3.10.11 probing for `Tcl()` argument-count
and keyword/type-error wording, Tcl interpreter creation with explicit local
Tcl library discovery, `eval(...)`, `setvar(...)`, `getvar(...)`, `_root()`
string shape, Tcl missing variable errors, and the observed `StringVar(...)`
constructor, generated-name, named-variable, `get()`, and `set()` behaviors for
the covered master-backed cases. The covered variable constructor path now also
matches local probing for `str(variable)` returning the Tcl variable name,
retaining an existing named Tcl variable when `value` is omitted or `None`,
and generating a normal variable name when `name=""` is passed. `setvar(...)`
and `StringVar.set(...)` now write Python `None` as the string `"None"`.
`stdlib.tkinter.Variable(...)` exposes the same public constructor surface,
raw `get()` / `set(...)` behavior, and `initialize(...)` alias observed in
local Python 3.10.11; `initialize(...)` is also covered on `StringVar(...)`,
`IntVar(...)`, `DoubleVar(...)`, and `BooleanVar(...)` through the relevant
subclass conversion path. The
covered `IntVar(...)` slice matches the
local constructor signature `(master=None, value=None, name=None)`,
master/name/type-error wording, named-variable storage, `set()` returning
`None`, bool values becoming `1` / `0`, `"3.5"` reading back as integer `3`,
and invalid `"09"` / `"abc"` reads raising Tcl numeric parse errors.
`DoubleVar(...)` mirrors the same constructor surface and returns Tcl double
parses as floats, including `2` reading as `2.0` and invalid numeric strings
raising `TclError`. `BooleanVar(...)` stores Tcl boolean parses as `1` / `0`,
returns `stdlib.True` / `stdlib.False`, raises `TclError` from invalid `set()`
values, and raises `ValueError("invalid literal for getboolean()")` for invalid
underlying values read through `get()`. The
2026-06-01 local probe used
`F:\Python\Python310\python.exe` (`3.10.11`) and confirmed
`DLLs\tcl86t.dll`, `DLLs\tk86t.dll`, `tcl\tcl8.6`, and `tcl\tk8.6` exist.
`tkinter.Tcl(useTk=False).eval("info commands winfo")` returned `""`, while
`tkinter.Tcl(useTk=True)` returned `winfo` for that command and `8.6.12` for
`package require Tk`. The same probe confirmed `tkinter.Tk()` has a public
root-window constructor surface, returns a `Tk` object whose string form is
`.`, exposes `winfo`, reports `winfo exists .` as `1`, and whose `destroy()`
returns Python `None`. The first covered GUI/widget slice now verifies real
Tk-backed `Frame`, `Label`, and `Button` creation under a hidden `Tk` root,
including Python-style widget path strings such as `.!label` and
`.host.!button`, `_root()` identity, `winfo_exists()`, `cget("text")`,
`configure({ text: ... })`, `pack()`, `winfo_manager()`, widget `destroy()`,
and `Tk.title()` get/set behavior. The option-key slice adds `keys()` for
`Tk`, `Toplevel`, and representative Tk-backed widgets, returning Python-list
style arrays of option names in the same order as local Python 3.10.11
`configure` introspection and preserving the probed arity and destroyed-widget
errors. The classic display/container widget slice covers `Message(...)`,
`Menubutton(...)`, and `LabelFrame(...)` construction under an explicit master,
Python-style widget paths, `Message` `text` / `width` / `aspect` options,
`Menubutton` `text` / `direction` / `relief` / `menu` options with attached
`Menu` command invocation, `LabelFrame` `text` / `labelanchor` /
`labelwidget` / `width` / `height` options, child parent-path behavior,
`pack()`, `destroy()`, and the probed constructor / option `TclError` paths.
The `OptionMenu(...)` slice covers explicit-master construction, `StringVar`
`textvariable` binding, Python-style `.!optionmenu` path with `Menubutton`
Tk class, internal `Menu` exposure through `option["menu"]`, menu item label
creation for the first value and trailing values, menu command invocation
setting the bound variable before calling the optional command callback,
Python-compatible `"None"` menu invoke returns, default visual options, and
the probed missing-argument, invalid-master, and unknown-option errors.
The first toplevel-window slice now
matches local Python 3.10.11 probing for explicit-master `Toplevel(...)`
windows, including Python-style paths such as `.dialog`, `_root()` identity,
`winfo_exists()`, `winfo_manager()` returning `"wm"`, integer
`cget("width")` / `cget("height")`, `cget("bg")`, `title()` get/set,
`state()`, `withdraw()`, `iconify()`, `deiconify()`, child widget paths under the
toplevel, destroy behavior, and the probed constructor / Wm arity errors. The
first interactive `Button` slice now
matches the probed local Python 3.10.11 behavior for callable `command`
registration, `cget("command")` returning a registered Tcl command name,
`invoke()` executing the callback, no-command `invoke()` returning `""`,
callback `None` results returning `"None"`, string callback results passing
through, `configure({ command: callable })`, non-callable command values
remaining Tcl command names that raise `TclError("invalid command name ...")`
when invoked, and `Button.invoke()` arity validation. The first
`Checkbutton` control slice covers explicit-master
`Checkbutton(...)` construction, Python-style widget paths, variable binding
through `StringVar`, `cget("text")`, `cget("variable")`, `cget("onvalue")`,
`cget("offvalue")`, callable and non-callable `command` options,
`select()`, `deselect()`, `toggle()`, `invoke()`, `pack()`, destroy behavior,
no-command / `None` / string callback result handling, and the probed
constructor / method arity and bad-command `TclError` paths. The first
`Radiobutton` control slice covers explicit-master `Radiobutton(...)`
construction, Python-style widget paths, variable binding through `StringVar`,
`cget("text")`, `cget("variable")`, `cget("value")`, callable and
non-callable `command` options, `select()`, `deselect()`, `flash()`,
`invoke()`, `pack()`, destroy behavior, no-command / `None` / string callback
result handling, and the probed constructor / method arity and bad-command
`TclError` paths. The first `Scale` numeric-control slice covers
explicit-master `Scale(...)` construction, Python-style widget paths,
`from_` keyword-option mapping to Tcl's `from` option, `DoubleVar` variable
binding, float-valued `cget("from")`, `cget("to")`, and
`cget("resolution")`, integer `cget("length")`, `get()`, `set(value)`,
`coords(value := unset)`, `identify(x, y)`, `pack()`, destroy behavior,
callable `command` registration with Tcl argument forwarding for manually
invoked command names, and the probed constructor / method arity and invalid
floating-point `TclError` paths. The first `Scrollbar` control slice covers
explicit-master `Scrollbar(...)` construction, Python-style widget paths,
string-valued `cget("orient")`, `cget("command")`, and `cget("width")`,
float tuple `get()`, `set(first, last)`, `activate(index := unset)`,
`delta(deltax, deltay)`, `fraction(x, y)`, `identify(x, y)`, `pack()`,
destroy behavior, callable `command` registration with multi-argument Tcl
forwarding for manually invoked command names, and the probed constructor /
method arity and invalid floating-point `TclError` paths. The first `Menu`
command-entry slice covers explicit-master `Menu(...)` construction,
Python-style menu paths, integer `cget("tearoff")`, `cget("title")`,
`cget("type")`, `index(index)`, `type(index)`, `activate(index)`,
`add(itemType, cnf := unset)`, `add_command(...)`,
`add_cascade(cnf := unset)`,
`add_checkbutton(cnf := unset)`, `add_radiobutton(cnf := unset)`,
`add_separator(cnf := unset)`, `insert(index, itemType, cnf := unset)`,
`insert_cascade(index, cnf := unset)`,
`insert_checkbutton(index, cnf := unset)`,
`insert_command(index, cnf := unset)`,
`insert_radiobutton(index, cnf := unset)`,
`insert_separator(index, cnf := unset)`, `post(x, y)`, `unpost()`,
`yposition(index)`, `entrycget(index, option)`,
`entryconfigure(index)`, `entryconfigure(index, option)`,
`entryconfigure(index, options)`, `entryconfig(...)`, `invoke(index)`,
`delete(index1, index2 := unset)`, destroy behavior, callable `command` registration for
command entries, cascade submenu entries, checkbutton and radiobutton variable
entries, separator entries, generic and typed added entries, generic and helper
inserted entries, active-state mutation, insertion-order mutation, variable
mutation through `invoke(...)`, y-position queries, no-op unpost, entry type
queries, entry-configuration query/set behavior, disabled-entry invoke behavior, and the probed constructor / method
arity, bad-cnf, bad-option, bad-type, invalid-coordinate, and bad-index
`TclError` paths.
The next input-widget slice covers
`Entry(...)` with `StringVar` `textvariable` binding, `width` cget conversion,
`get()`, `insert(index, string)`, `delete(first, last := unset)`, `pack()`,
`winfo_manager()`, destroy behavior, and `Tk.update()` /
`Tk.update_idletasks()` returning `stdlib.None`. The cursor/selection
interaction slice covers `Entry.index(...)`, `Entry.icursor(...)`,
`select_range(...)` / `selection_range(...)`, `select_clear()` /
`selection_clear()`, `select_present()` / `selection_present()`,
`select_from(...)` / `selection_from(...)`, `select_to(...)` /
`selection_to(...)`, `select_adjust(...)` / `selection_adjust(...)`,
`selection_get()` text reads, no-selection `TclError`, bad entry-index
`TclError`, scan drag movement, XView movement/query behavior, and the probed
arity errors. The first `Spinbox(...)`
slice covers explicit-master construction, Python-style paths,
`StringVar` `textvariable` binding, integer `cget("width")`,
`get()`, `insert(index, s)`, `delete(first, last := unset)`,
`icursor(index)`, `index(index)`, `selection_range(start, end)`,
`selection_clear()`, `selection_present()`, `selection_get()`,
`invoke(element)`, `selection_element(element := unset)`, `bbox(index)`,
`identify(x, y)`, `xview()`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, callable command callbacks for spin-button
invocation, and the probed constructor / method arity and Tcl validation
errors. The first list-selection
widget slice covers `Listbox(...)` construction, Python-style paths,
`cget("height")` / `cget("width")` integer conversion, `cget("selectmode")`,
`size()`, `insert(index, *elements)`, `get(first, last := unset)`,
`index(index)`, `delete(first, last := unset)`, `curselection()`,
`selection_set(...)`, `selection_clear(...)`, `selection_includes(...)`,
`selection_anchor(index)`, Python-compatible `select_set(...)`,
`select_clear(...)`, `select_includes(...)`, and `select_anchor(...)` aliases,
`activate(index)`, `nearest(y)`, `see(index)`, `bbox(index)`,
`scan_mark(x, y)`,
`scan_dragto(x, y)`, `xview(...)`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, `yview(...)`, `yview_moveto(fraction)`,
`yview_scroll(number, what)`, `itemcget(index, option)`,
`itemconfigure(index, cnf_or_option := unset)`, `itemconfig(...)`, `pack()`,
destroy behavior, visual bbox integer tuple and non-visible `None` results,
and the probed constructor / method arity, bad-index, bad-integer, and
bad-option `TclError` paths. The first multiline `Text`
editing slice covers real Tk-backed `Text(...)` creation, integer
`cget("width")` / `cget("height")` conversion, `cget("wrap")`,
`get(index1, index2 := unset)`, `insert(index, chars, tags*)`,
`delete(index1, index2 := unset)`,
`replace(index1, index2, chars, *tags)`, `index(index)`,
`peer_create(newPathName, cnf := unset)`, `peer_names()`,
`dump(index1, index2 := unset, command := unset, **kw)`,
`debug(boolean := unset)`, `edit(*args)`, `edit_modified(arg := unset)`,
`edit_undo()`, `edit_redo()`, `edit_reset()`, `edit_separator()`,
`compare(index1, op, index2)`, `count(index1, index2, *args)`, `bbox(index)`,
`dlineinfo(index)`, `see(index)`, `scan_mark(x, y)`, `scan_dragto(x, y)`,
`search(pattern, index, stopindex := unset, forwards := unset, backwards := unset,
exact := unset, regexp := unset, nocase := unset, count := unset,
elide := unset)`,
`xview(...)`, `xview_moveto(fraction)`, `xview_scroll(number, what)`,
`yview(...)`, `yview_moveto(fraction)`, `yview_scroll(number, what)`,
`yview_pickplace(*what)`,
`mark_set(markName, index)`, `mark_unset(*markNames)`,
`mark_gravity(markName, direction := unset)`, `mark_names()`,
`mark_next(index)`, `mark_previous(index)`, `tag_add(tagName, index1, *args)`,
`tag_cget(tagName, option)`, `tag_configure(tagName, cnf := unset)`,
`tag_config(...)`, `tag_bind(tagName, sequence, func, add := unset)`,
`tag_unbind(tagName, sequence, funcid := unset)`,
`tag_remove(tagName, index1, index2 := unset)`, `tag_ranges(tagName)`,
`tag_names(index := unset)`,
`tag_nextrange(tagName, index1, index2 := unset)`,
`tag_prevrange(tagName, index1, index2 := unset)`,
`tag_raise(tagName, aboveThis := unset)`,
`tag_lower(tagName, belowThis := unset)`, and `tag_delete(*tagNames)`. It preserves Python-style
empty/end newline behavior, insert-cursor and end-index strings, visible-text
geometry tuple / non-visible `None` results, view mutation `None` returns,
view-query two-float tuples, yview pickplace visible-index movement and `None` returns, replace range mutation / insertion / deletion `None` returns, peer-name tuple results, peer creation `None` returns and shared-buffer behavior, dump list-of-triple tuple results and callback `None` returns, tag option string reads, tag configure tuple/dict results and mutation `None` returns, tag bind query strings/tuples, tag bind command ids, tag unbind `None` returns, debug boolean returns, edit modified/canundo/canredo integer flags, undo/redo/reset/separator return values, mark gravity query/set return values, tuple mark
name results, next/previous mark name or `None` results, bad-index,
bad-integer, search string returns and count-variable updates, count integer/tuple returns, compare boolean results, tag range/name tuples, tag-range mutation `None` returns,
missing-mark, and bad-gravity `TclError` paths, and the probed
arity errors. The first image-object slice covers
`PhotoImage(...)` creation under an explicit `master`, generated
Python-style `pyimageN` names, `width()`, `height()`, `type()`, string-valued
`cget(...)`, `config(...)`, `blank()`, `put(data, to=...)`, RGB tuple reads
through `get(x, y)`, image-backed `Label(..., { image: photo })` options, and
the probed first-slice arity / bad-coordinate `TclError` paths. The
PhotoImage transform/write slice covers `copy()`, `zoom(...)`,
`subsample(...)`, `write(...)`, `transparency_get(...)`, and
`transparency_set(...)`: copied images are new `PhotoImage` objects with the
same pixel data, zoom/subsample calls return dimension-adjusted images,
transparency calls return and set Python booleans, PNG writes create the
target file, and the probed arity plus Tcl validation errors are preserved.
The BitmapImage slice covers `BitmapImage(...)` creation with inline XBM
`data` and XBM `file` options under an explicit master, named image strings,
`width()`, `height()`, `type()`, `configure(...)`, image-backed
`Label(..., { image: bitmap })` options, image-registry membership, and the
probed constructor, image-method, bad-option, and bad-data errors.
The first drawable `Canvas`
slice covers real Tk-backed `Canvas(...)` creation, Python-style path strings,
raw string `cget("width")` / `cget("height")` values, `create_line(...)`,
`create_rectangle(...)`, numeric item ids, `coords(...)` returning Python-like
float lists and returning an empty list after coordinate mutation or deleted /
missing items, `itemcget(...)`, `itemconfigure(...)` returning `stdlib.None`,
and `delete(...)` returning `stdlib.None` for existing, missing, or omitted
item ids. The Canvas item discovery and movement slice covers `find_all()`,
`find_withtag(tagOrId)`, integer tuple item-id results, empty tuple missing-tag
results, `bbox(...)` integer tuple results, missing-item `None`, `type(...)`
string / `None` results, `move(...)` coordinate mutation, and the probed
TypeError / TclError paths.
The Canvas additional drawing slice covers `create_oval(...)`,
`create_polygon(...)`, and `create_text(...)` for probed item ids, item types,
coordinate lists, text / anchor / fill / outline option reads, shared tag
lookup, `IndexError("tuple index out of range")` for omitted coordinates, and
the observed wrong-coordinate-count and bad-distance `TclError` paths. The
Canvas arc/bitmap slice covers `create_arc(...)` and `create_bitmap(...)` for
probed item ids, item types, coordinate lists, arc start / extent / style /
outline / width option reads, built-in bitmap names, foreground / background /
anchor option reads, bounding boxes, shared tag lookup, and the observed
omitted-coordinate `IndexError`, wrong-coordinate-count, bad-distance, unknown
option, and missing-bitmap `TclError` paths. The
Canvas media item slice covers `create_image(...)` with `PhotoImage` options
and `create_window(...)` with embedded widgets, including `itemcget("image")`
and `itemcget("window")` Tcl-name reads, coordinate lists, bounding boxes,
shared tag lookup, `IndexError("tuple index out of range")` for omitted
coordinates, and wrong-coordinate-count / bad-distance `TclError` paths. The
Canvas view and coordinate slice covers `canvasx(screenx, gridspacing=None)`,
`canvasy(screeny, gridspacing=None)`, `xview(*args)`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, `yview(*args)`, `yview_moveto(fraction)`, and
`yview_scroll(number, what)`. It returns Python-shaped float coordinates and
float tuples, preserves explicit `None` gridspacing as the omitted-grid path,
returns `None` for mutating view calls, supports direct `xview("moveto", ...)`
and `yview("scroll", ...)` calls, and surfaces the probed Canvas / XView /
YView TypeError and Tcl validation paths. The Canvas tag-management slice
covers `addtag(*args)`, `addtag_above(newtag, tagOrId)`,
`addtag_all(newtag)`, `addtag_below(newtag, tagOrId)`,
`addtag_closest(newtag, x, y, halo=None, start=None)`,
`addtag_enclosed(newtag, x1, y1, x2, y2)`,
`addtag_overlapping(newtag, x1, y1, x2, y2)`,
`addtag_withtag(newtag, tagOrId)`, `dtag(*args)`, and `gettags(*args)`. It
returns Python-shaped tag tuples, preserves probed tag ordering after
selection, all-item, z-order, closest, enclosed, overlapping, raw withtag, and
delete-tag operations, returns an empty tuple for missing tags, and surfaces
the observed convenience-wrapper TypeError and raw Tcl validation paths. The
Canvas find-query slice covers `find(*args)`, `find_above(tagOrId)`,
`find_below(tagOrId)`, `find_closest(x, y, halo=None, start=None)`,
`find_enclosed(x1, y1, x2, y2)`, and
`find_overlapping(x1, y1, x2, y2)`. It returns Python-shaped integer tuples
for raw, tag, z-order, closest, enclosed, and overlapping searches, treats
explicit `None` optional closest arguments as the omitted path, returns empty
tuples for missing tags / no matches, and surfaces the probed arity TypeError
and Tcl search / coordinate validation paths. The Canvas text-item editing
slice covers `dchars(*args)`, `focus(*args)`,
`icursor(*args)`, `index(*args)`, `insert(*args)`,
`select_adjust(tagOrId, index)`, `select_clear()`,
`select_from(tagOrId, index)`, `select_item()`, and
`select_to(tagOrId, index)`. It returns Python-shaped `None`, empty string,
and integer item / index values for cursor, focus, selection, and text
mutation calls, preserves probed text insertion / deletion results, leaves
missing-item `dchars(...)` as a no-op, and surfaces the observed raw Tcl arity
errors, bad-index errors, non-indexable-item errors, and wrapper TypeError
paths. The Canvas scan/scale slice covers `scale(*args)`, `scan_mark(x, y)`,
and `scan_dragto(x, y, gain=10)`. It returns Python-shaped `None`, mutates
item coordinates for ids and tags, preserves the probed missing-tag no-op,
keeps `scan_mark(...)` as a view-state no-op, applies default and explicit
gain drag scrolling, and surfaces the observed raw Tcl arity / coordinate
validation errors and wrapper TypeError paths. The Canvas z-order/moveto slice
covers `itemconfig(tagOrId, cnf=None, **kw)`, `moveto(tagOrId, x='', y='')`,
`tag_raise(*args)`, and `tag_lower(*args)`. It returns Python-shaped `None`,
keeps `itemconfig(...)` error messages aligned with the `itemconfigure(...)`
alias, forwards empty-string `moveto(...)` defaults rather than omitting Tcl
arguments, moves item ids and tags to absolute positions, preserves
missing-tag no-op movement, reorders items through tag raise/lower calls, and
surfaces the observed wrapper TypeError and raw Tcl validation paths. The
Canvas tag-event slice covers `tag_bind(tagOrId, sequence=None, func=None,
add=None)` and `tag_unbind(tagOrId, sequence, funcid=None)`. It returns
Python-shaped sequence tuples, script strings, command names, and `None`,
routes canvas item-tag events through the existing Event object bridge,
supports additive bindings, clears the full tag/sequence script on unbind,
allows missing tag registration, and surfaces the observed arity and
`can't delete Tcl command` paths. The Canvas PostScript slice covers
`postscript(cnf={})`. It returns Tk EPS strings, supports option dictionaries
for color mode, output area, page geometry, and file output, preserves the
empty-string success result for file writes and Tk's returned open-error
string for an unwritable path, and surfaces the observed wrapper TypeError and
Tcl validation paths. The widget identity-tree
slice covers `winfo_children()`, `winfo_class()`, `winfo_name()`, and
`winfo_parent()` on roots, `Toplevel` windows, and child widgets. It returns
the same widget objects created through the public wrapper for child lists,
preserves Python-style Tk class/name/parent strings such as `Tk`, `tk`, `Frame`,
`host`, `.`, and `.dialog`, drops destroyed widgets from parent child lists,
and surfaces `TclError("bad window path name \"...\"")` for destroyed-widget
identity reads. The path lookup slice covers `nametowidget(name)` on roots and
widgets, matching local Python 3.10.11 absolute paths such as `.host.press`,
relative child names such as `press`, root lookup through `.`, and `KeyError`
messages for missing or destroyed widget names. The image registry query slice
covers `image_types()` and `image_names()` on roots and Tk-backed widgets,
matching local Python 3.10.11 tuple returns for `photo` / `bitmap` image
types, built-in icon registry names, named `PhotoImage` entries, image delete
updates, widget/root parity, and arity errors. The virtual event registry slice
covers `event_add(...)`, `event_delete(...)`, and `event_info(...)` on roots
and Tk-backed widgets, matching local Python 3.10.11 `None` returns, tuple
queries, virtual-event membership, `<Key-a>` normalization to `a`, duplicate
adds, delete updates, explicit `None` all-event queries, and arity / Tcl
validation errors. The bind-tag routing slice covers `bindtags(...)` on roots,
`Toplevel` windows, and child widgets, matching local Python 3.10.11 default
tag tuples such as `(".", "Tk", "all")` and `(".host.caption", "Label", ".",
"all")`, tuple/list/string set behavior, empty tuple no-op semantics,
explicit `None` query behavior, arity errors, and destroyed-widget `TclError`
paths. The class/all binding slice covers `bind_all(...)`, `bind_class(...)`,
`unbind(...)`, `unbind_all(...)`, and `unbind_class(...)` on roots and child
widgets, matching local Python 3.10.11 tuple/script query returns, callback
ids, widget/class/all delivery from a generated `<Button-1>` event, event
widget resolution through `%W`, full-sequence clearing for `unbind(...,
funcid)`, and observed TypeError arity messages. The Tcl-backed Misc conversion slice
covers `getint(s)`, `getdouble(s)`, and `getboolean(s)` on `Tcl()`, `Tk`, and
child widgets, matching local Python 3.10.11 `0x10`, signed and padded integer
strings, bool/object pass-through cases, Tcl `ValueError` text for invalid
integer and floating-point strings including `nan`, Python `TypeError` text
for `None` / list inputs, and observed arity errors. The layout
info/forget slice
covers `pack_info()`,
`pack_forget()`, `grid_forget()`, `grid_remove()`, and `place_forget()` from
fresh Python 3.10.11 probing. `pack_info()` returns the parent widget object
for `in`, integer values for `expand`, `ipadx`, `ipady`, `padx`, and `pady`,
and string values for `anchor`, `fill`, and `side`; `pack_forget()` clears the
manager and makes a subsequent `pack_info()` raise the observed Tcl
`isn't packed` error; bare `pack()` restores default pack options.
`grid_forget()` clears manager state and restores default grid options on a
bare `grid()`, while `grid_remove()` preserves the probed row/column/padding
state for a later bare `grid()` restore. `place_forget()` clears manager state
and leaves both `place_info()` and a later bare `place()` empty. The layout child-query
slice covers `pack_slaves()`, `grid_slaves(row=None, column=None)`, and
`place_slaves()`: parent containers return the same widget objects registered
through the public wrapper, root `pack_slaves()` sees packed top-level child
widgets, grid child queries preserve Tk's newest-first ordering and row/column
filters, place child queries preserve newest-first ordering, and forgotten
widgets disappear from the corresponding child lists. The grid geometry-query
slice covers `grid_size()`, `grid_bbox(column=None, row=None, col2=None,
row2=None)`, and `grid_location(x, y)` on roots and child widgets. It returns
integer tuples for grid dimensions, bboxes, and coordinate locations, supports
object-form keyword analogues for the covered keyword calls, preserves
Python's behavior where `grid_bbox(column)` / `grid_bbox(row=...)` with an
incomplete first coordinate pair returns the whole grid bbox without validating
the isolated value, and surfaces the observed TypeError/TclError paths for
bad arity, unexpected keywords, bad integer grid coordinates, and bad screen
distances. The grid row/column configuration slice covers
`grid_columnconfigure(index, cnf := {})`, `columnconfigure(...)`,
`grid_rowconfigure(index, cnf := {})`, and `rowconfigure(...)` on roots and
child widgets. It returns Python-shaped maps for full queries with integer
`minsize`, `pad`, and `weight` fields plus `None` / string `uniform` fields,
returns typed single-option values, supports option-object updates for
`minsize`, `pad`, `uniform`, and `weight`, preserves alias error messages, and
surfaces the observed Tcl validation paths for bad indices, options, and
integer values. The layout propagation slice covers `pack_propagate(flag)`,
`grid_propagate(flag)`, and `grid_anchor(anchor)` on roots and child widgets.
No-argument propagation queries return `True` for Tcl `1` and `None` for Tcl
`0`, set calls return `None`, explicit `None` arguments use the same
query/no-op path observed through Python 3.10.11 `_tkinter`, and invalid
boolean or anchor values surface the probed TclError messages. `grid_anchor()`
matches Python's wrapper behavior by discarding the Tcl return value and
returning `None` for both query and set paths. The layout alias slice covers
`pack_configure()`, `grid_configure()`, and `place_configure()` as direct
aliases for the corresponding manager methods; `info()` and `forget()` as the
`Pack` aliases selected by CPython's widget MRO; `slaves()` and `propagate()`
as the `Pack` root/widget aliases; and `anchor()`, `size()`, `bbox()`, and
widget `location()` as `Grid` aliases. It preserves the probed CPython arity
messages and intentionally leaves `Tk.location()` absent because local Python
3.10.11 has no such root method. The clipboard slice covers
`clipboard_clear(**kw)`, `clipboard_append(string, **kw)`, and
`clipboard_get(**kw)` on roots and child widgets. It preserves Python's `None`
return values for clear/append, appends multiple payloads into one clipboard
string, supports object-form keyword analogues for the covered `type` and
`displayof` options, returns clipboard text through `clipboard_get()`, and
surfaces the observed empty-clipboard, bad type, bad option, and arity error
paths. The option-database slice covers `option_add(pattern, value,
priority=None)`, `option_clear()`, `option_get(name, className)`, and
`option_readfile(fileName, priority=None)` on roots and child widgets. It
matches Python's `None` return values for mutating calls, keeps `option_get()`
scoped to the queried widget, applies option values to subsequently created
widgets, clears the database through `option_clear()`, reads Tk resource-file
syntax through `option_readfile()`, omits explicit `None` priorities so Tk's
default priority is used, and surfaces the observed missing-file, bad-file,
bad-priority, and arity error paths. The variable trace slice covers
`Variable.trace_add(mode, callback)`, `trace_remove(mode, cbname)`,
`trace_info()`, `trace_variable(mode, callback)`, `trace_vdelete(mode,
cbname)`, and `trace_vinfo()` across the public variable classes. It returns
registered callback names, delivers probed callback argument tuples for
`read`, `write`, `unset`, and legacy `w` traces, returns Python-shaped trace
info lists with mode tuples and callback names, removes callbacks when no
trace still references them, accepts list/tuple mode registration for
`trace_add(...)`, and surfaces the observed TypeError/TclError paths for
bad arity and invalid modes. The window iconify lifecycle
slice covers `Tk.iconify()` and
`Toplevel.iconify()` from fresh Python 3.10.11 probing, including `normal` to
`iconic` state transitions, `iconify()` from a withdrawn root, deiconifying
back to `normal`, root viewable/mapped observations, and the probed
`Wm.wm_iconify()` arity error text. The winfo coordinate-query slice covers
`winfo_x()`, `winfo_y()`, `winfo_rootx()`, `winfo_rooty()`,
`winfo_screenwidth()`, `winfo_screenheight()`, `winfo_reqwidth()`, and
`winfo_reqheight()` on roots and Tk-backed widgets, including integer returns,
geometry-position reads, widget-relative coordinate reads, root-coordinate
ordering, shared screen dimensions, request-size equality for settled packed
widgets, and the probed `Misc.winfo_*()` arity error text. The first geometry-manager
slice covers `grid(...)`, `grid_info()`, `place(...)`, and `place_info()` from
fresh Python 3.10.11 probing: `grid()` / `place()` return Python `None`,
`winfo_manager()` reports `"grid"` / `"place"`, `grid_info()` exposes integer
`row`, `column`, span, internal/external pad values plus normalized sticky
text such as `"nesw"`, and `place_info()` preserves the probed string values
for x/y, relative coordinates, width/height, anchor, and bordermode. Empty
`place()` on an unmanaged widget still returns `None` and leaves
`place_info()` empty, matching the local probe. The first event-loop slice now
covers `Tk.after(...)`, Tk-backed widget `after(...)`, `Tk.after_idle(...)`,
Tk-backed widget `after_idle(...)`, `Tk.after_cancel(...)`, Tk-backed widget
`after_cancel(...)`, `Tk.mainloop(...)`, and `Tk.quit()` from fresh Python
3.10.11 probing: `after(0)` without a callback returns `None`, callback-based
`after(...)` returns an `after#N` id and runs the callback on `update()` /
`mainloop()`, callback arguments are passed through,
`after_idle(func, *args)` returns an `after#N` id, runs idle callbacks on
`update()`, supports Tk-backed widget callers, and uses `after_cancel(id)`,
invalid millisecond values surface Tcl's `bad argument ...` error,
`after_cancel(id)` and `after_cancel("missing")` return `None`,
`mainloop()` returns `None` after a scheduled `quit()`, and the covered arity
errors match the local probe. The variable-wait slice covers
`wait_variable(...)` and `waitvar(...)`: variable objects and string variable
names unblock after scheduled `set()` / `setvar(...)` updates, omitted names
use the local Python 3.10.11 default variable name, Tk-backed widgets share the
same root interpreter wait path, and alias arity errors retain the
`Misc.wait_variable()` message. The window protocol slice covers `protocol()`
and `wm_protocol()` on Tk roots and `Toplevel` windows from fresh Python
3.10.11 probing: no-argument calls return the protocol-name tuple,
`WM_DELETE_WINDOW` is present by default, single-name calls return the Tcl
command string, callable callbacks are registered and executable through the
returned Tcl command, `None` callback results become `"None"`, string /
non-callable command assignments are preserved, unknown protocol names return
`""`, and the probed `Wm.wm_protocol()` arity error text is surfaced. The
focus-management slice covers `focus_set()`, `focus_force()`, `focus_get()`,
and `focus_displayof()` from fresh Python 3.10.11 probing, including `None`
returns from set/force calls, focused widget object mapping through
`focus_get()` / `focus_displayof()`, no-focus returning `None` after
withdrawal, and the probed `Misc.focus_*()` arity error text. The repository now carries
the probed Tcl/Tk DLLs at
`stdlib\tkinter\lib\tcl86t.dll` and `stdlib\tkinter\lib\tk86t.dll`, and the
AHK implementation prefers those bundled DLLs before falling back to the local
Python install. The tracked `stdlib\tkinter\lib\README.md` and
`stdlib\tkinter\lib\SHA256SUMS` record the CPython 3.10.11 source path,
official release URL, file sizes, Tcl/Tk 8.6.12 version metadata, and SHA256
hashes; `stdlib\tests\tkinter.test.ahk` recomputes the bundled DLL hashes from
that report. It still sets `TCL_LIBRARY` / `TK_LIBRARY` from the local Python
3.10 Tcl script libraries, then calls `Tk_Init` only when
`stdlib.tkinter.Tcl({ useTk: stdlib.True })` or `stdlib.tkinter.Tk()` requests
Tk.
The winfo distance/color promotion covers `winfo_pixels(number)`,
`winfo_fpixels(number)`, and `winfo_rgb(color)` for roots and Tk-backed
widgets, including CPython 3.10.11's logical-DPI pixel conversion for unit
distances, RGB tuples in the `0..65535` range, destroyed-widget Tcl errors,
bad distance/color Tcl errors, and `Misc.winfo_*()` arity messages.
The winfo screen-metadata promotion covers `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, and `winfo_server()` for roots
and Tk-backed widgets, including the local Python 3.10.11 screen/server values,
integer screen dimensions and color-depth data, destroyed-widget Tcl errors,
and `Misc.winfo_*()` arity messages.
The winfo logical-screen promotion covers CPython 3.10.11-aligned logical
returns from `winfo_screenwidth()` and `winfo_screenheight()` and adds
`winfo_vrootwidth()`, `winfo_vrootheight()`, `winfo_vrootx()`, and
`winfo_vrooty()` for roots and Tk-backed widgets, including DPI normalization
from AHK/Tk physical pixels, destroyed-widget Tcl errors, and `Misc.winfo_*()`
arity messages.
The winfo visual/colormap/pointer promotion covers `winfo_cells()`,
`winfo_colormapfull()`, `winfo_depth()`, `winfo_geometry()`, `winfo_id()`,
`winfo_pointerx()`, `winfo_pointerxy()`, `winfo_pointery()`, `winfo_visual()`,
`winfo_visualid()`, and `winfo_visualsavailable()` for roots and Tk-backed
widgets, including local Python 3.10.11 visual metadata, bool/integer/string
and list-of-tuple return conversion, destroyed-widget Tcl errors, and
`Misc.winfo_*()` arity messages.
The winfo atom/path/containing promotion covers `winfo_atom()`,
`winfo_atomname()`, `winfo_containing()`, `winfo_interps()`, and
`winfo_pathname()` for roots and Tk-backed widgets, including CPython 3.10.11
`_displayof` handling, atom name/id round-trips, empty interpreter tuple
returns on this host, raw hex window-id path lookup, widget/`None` containing
returns, and observed arity / Tcl validation messages.
Additional widgets and broader GUI/event-loop behavior remain deferred.

`stdlib.enum` is now direct as a first slice of Python 3.10.11 `enum`,
promoted from the old lightweight `std\metafunc\enum.ahk` source material and
the weakest remaining runtime candidate slot. The current public slice covers
`stdlib.enum.Enum(name, members, options?)` and `stdlib.enum.auto()` for the
functional API shapes that are directly expressible in AHK: whitespace/comma
separated member text, plain name arrays, explicit `[name, value]` pair lists,
ordered plain-object / `Map` name-value inputs, optional `{ start: value }`
numbering for name lists, member lookup by `.NAME`, `["NAME"]`, and
`EnumType(value)`, ordered iteration over enum members, ordered `__members__`
iteration, plus covered member `.name`, `.value`, `String(member)`, and
`__Repr()` behavior. Covered error branches currently match the local Python
3.10.11 baseline for bare `Enum()` call wording via `EnumMeta.__call__`,
unexpected keyword arguments, non-iterable integer member payloads, missing
member-name `KeyError`, invalid value `ValueError`, and `auto()` arity. This
first slice intentionally stops before `IntEnum`, decorator helpers, alias
rules, flag/bitmask variants, and deeper metaclass customisation because raw
AHK numeric operators do not yet provide a faithful Python-style int-like enum
surface without additional `stdlib.operator` integration.

`stdlib.copy` is now direct as a first slice of Python 3.10.11 `copy`,
promoted onto the public Python-path root as `stdlib.copy.*`. The current
slice covers `stdlib.copy.copy(x)` and `stdlib.copy.deepcopy(x)` for the
observable shapes that are straightforward to express in AHK today: shallow
and deep copying of lists, maps, plain objects, tuple-like `stdlib.tuple(...)`
values, immutable scalar passthrough for covered `str`/`int`-style inputs,
custom `__copy__()` and `__deepcopy__(memo)` hooks, and recursive cycle
preservation through memoized deep-copy traversal. Covered behavior currently
matches the local Python 3.10.11 probe for list/dict nested-identity
differences between shallow and deep copy, `tuple` shallow identity vs deep
copy rematerialization when nested mutable content is present, recursive
self-reference reconstruction, and the observed missing-argument `TypeError`
wording for bare `copy()` / `deepcopy()` calls. This first slice intentionally
stops before Python's full pickling-protocol integration, slots/descriptor
edge cases, and richer reducer/custom-dispatch machinery.

`stdlib.uuid` is now direct as a first slice of Python 3.10.11 `uuid`,
promoted onto the public Python-path root as `stdlib.uuid.*`. The current
slice covers `stdlib.uuid.UUID(...)` for the observed string parsing forms on
the local baseline: canonical hyphenated text, plain 32-hex text, brace-wrapped
text, `urn:uuid:` text, and a keyword-object `{ hex: ... }` analogue. Covered
observable surface currently includes normalized `String(...)`, `.hex`, `.urn`,
`.variant`, `.version`, and `__Repr()`, plus `stdlib.uuid.uuid4()` using
Windows GUID generation under the wrapper. This first slice intentionally stops
before `bytes`, `bytes_le`, `fields`, `int`, ordering/comparison helpers,
namespace constants, `SafeUUID`, and the wider `uuid1` / `uuid3` / `uuid5`
surface.

`stdlib.contextlib` is now direct as a first slice of Python 3.10.11
`contextlib`, promoted onto the public Python-path root as
`stdlib.contextlib.*`. The current slice covers `stdlib.contextlib.nullcontext`,
`stdlib.contextlib.suppress`, and `stdlib.contextlib.closing` for the
observable object behavior exercised by the local Python baseline: `__enter__`
return values, `__exit__` suppression decisions, Python-style `repr(...)`
object shapes, zero-argument `suppress()` permissiveness, `closing(...)`
calling `.close()` on exit, and the covered arity / bad-exception-type error
messages. This first slice intentionally stops before `ContextDecorator`,
`redirect_stdout`, `redirect_stderr`, `ExitStack`, `AsyncExitStack`, async
helpers, and generator-based decorators.

`stdlib.collections.Counter` now covers lazy `elements()` iteration, Python-style
dictionary-size and dictionary-keys mutation errors during iteration,
`eq`/`ne` booleans against non-Counter non-mapping values, missing-as-zero rich
comparison semantics, and a growing set of mixed-type count error-message
parity slices. Current mixed-type coverage includes Python-style ordering
comparison messages, unary `+`/`-`, set-style `&`/`|`, `add(str, int)` string
concatenation wording, and the Python 3.10 behavior where `add(str, str)` or
`add(list, list)` can reach the positive-count filter and then fail with a
Python-style `>`-vs-`int` type error instead of an earlier binary-operator
error, including the `Counter() + Counter(a=[...])` case where a right-only
key is carried straight into the positive-count filter instead of being
prematurely combined with an implicit zero, and the Python-specific
`add(list, non-list)` concatenation wording for left-side list counts. The
same "right-only key goes straight to the positive-count filter" rule now also
covers `Counter() | Counter(a=[...])`, matching Python's `>`-vs-`int` error
path instead of prematurely comparing implicit zero against the right count.
For `Counter() & Counter(a=[...])`, the current direct slice now matches Python
by skipping the right-only key entirely and returning an empty Counter instead
of attempting a mixed-type comparison against implicit zero.
For `Counter() - Counter(a=...)`, right-only keys now also follow Python's
direct algorithm: positive right-side counts are skipped, negative right-side
counts are negated into the result, and mixed-type right-only counts fail on
Python's `<`-vs-`int` guard instead of prematurely raising an `int`-vs-value
binary subtraction error.
The current direct slice now also matches Python's `Counter.total()` behavior
for covered direct numeric objects by routing same-type `Fraction` and
`Decimal` count payloads through their existing direct stdlib addition paths
and by preserving the covered Python 3.10.11 mixed-aggregation outcomes where
`Fraction` totals can absorb native `int` and `float` payloads while
`decimal.Decimal` totals absorb native `int` payloads but still reject native
`float` payloads,
instead of treating them as raw AHK non-numeric failures, while leaving mixed
`Fraction`/`Decimal` totals unsupported like local Python 3.10.11.
The current direct slice now also matches Python's `most_common()` ordering for
covered non-numeric and direct numeric count payloads: strings use
lexicographic ordering, lists use Python-style lexicographic element
comparison, same-type `Fraction` and `Decimal` counts use their direct stdlib
comparison paths, covered `Fraction`/`Decimal` mixed ordering follows the local
Python 3.10.11 comparison result via the `Decimal` path, covered mixed
`int`/`float` with `Fraction`/`Decimal` payload ordering now also follows the
local Python 3.10.11 result through the corresponding direct stdlib numeric
comparison path, and unsupported
payloads such as function objects now fail with Python's `'<'
not supported between instances of ...` wording instead of leaking AHK's raw
numeric comparison diagnostics. Covered `eq`/`ne` value equality now also
matches Python for direct numeric payload mixes, so `Fraction` / `Decimal`
counts compare by value against matching native `int` / `float` payloads in
both Counter-to-Counter and Counter-to-mapping equality paths instead of
falling back to raw object identity. Covered direct numeric `Fraction` /
`Decimal` rich ordering against matching native `int` / `float` payloads now
also follows the local Python 3.10.11 result instead of leaking raw AHK
comparison failures. The current direct slice also follows Python's
`most_common(limit)` argument rules for covered cases: `limit=None` returns the
full ordered result, native `bool` and root `stdlib.True` / `stdlib.False`
values follow Python's `int` subclass behavior,
only the covered `== 1` fast path is accepted for non-native numeric objects
such as `Fraction(1, 1)` and `Decimal("1")`, larger covered float / `Fraction`
/ `Decimal` limits now follow Python's later `slice indices must be integers or
None or have an __index__ method` failure when the implementation reaches the
slice path, smaller covered non-native numeric values preserve Python's
integer-interpretation `TypeError` wording, and string limits preserve
Python's `'>=' not supported between instances of 'str' and 'int'` wording.
Plain objects and custom AHK class instances in the `limit` slot now also
follow Python's `'>=' ... and 'int'` comparison wording instead of being
misreported as integer-interpretation failures.

Current tests live under `stdlib\tests`. Current examples live under
`stdlib\examples`. The old top-level `examples\stdlib` tree is not part of the
active surface.

## AhkTest Pytest 7.4.3 Parity Matrix

`ahktest` uses pytest 7.4.3 as the behavior benchmark, but public AHK
identifiers must stay under `ahktest`, `AhkTest`, or `ahk*` naming. Direct
Python naming is documentation-only and must not leak into the AHK public API.

| Pytest 7.4.3 area | Target AHK shape | Current status | Notes |
| --- | --- | --- | --- |
| Test discovery | `tools\run-ahktest.ps1`, `AhkTest.Collect`, future stdlib-aware discovery | partial | Current wrapper discovers `*.test.ahk`, supports repeatable/comma-split `-Ignore` entries that exclude matching files before include/load using case-insensitive PowerShell wildcard matching against file name, lib-relative path, or absolute path, now matches the observed local pytest 7.4.3 duplicate-target policy by collecting repeated explicit file targets again while still deduplicating repeated directory discovery, preserves that mixed directory-plus-file behavior for the same underlying test file, and now supports manifest-backed configurable discovery roots through `AhkTest.DiscoveryRoots` in JSON `-Config` files when `-Target` is omitted. Discovery roots are resolved relative to the config file, while an explicit `-Target` still overrides them. Class collection handles static `Test*` methods; result entries keep public suite/name node ids while rerun state can now use source-aware stable keys for same-name tests collected from different files. Need non-manifest discovery config and broader project-layout policy. |
| Collection model | Structured suite items with name, node id, source, marks, params, fixtures | partial | Current entries have names, node ids, status, marks, captured output, errors, and serializable source metadata. Manual tests can provide explicit `Source`, `AhkTest.SourceHere(kind)` creates a serializable current-file/current-line source object for manual registration, `Test` registrations record automatic source metadata through both suite and default-suite entrypoints, `Skip`/`XFail`/`Parametrize` registrations keep source kind and file/line metadata, `Collect` records class/method metadata, non-callable collected `Test*` members now surface as dedicated `AhkTestCollectionError` entries with preserved detail in `Extra`, `collect_finish` hook failures follow the same collection-failure error class instead of being reported as plain runtime errors, and wrapper-level top-level runtime include/import failures plus top-level syntax/load-time compiler failures before `AhkTest.Run(...)` now synthesize the same collection-failure error type into text/JSON/JUnit outputs instead of surfacing only as missing-report stderr. Covered collection-failure result objects now also report `ExitCode = 2` like local pytest 7.4.3 collection errors, while non-collection usage/runtime failures continue to use ordinary nonzero error exits. `collect_finish` hooks can still inspect or modify the per-run collected item list before filtering and execution, and covered rerun slices now use `Source.File` metadata to distinguish same-name tests loaded from different files. Need broader discovery collection failures and richer class-method line metadata where AHK permits. |
| Assertion rewriting | Explicit `AhkTest.Assert*` helpers and rich failure diagnostics | partial | AHK cannot rewrite `assert` expressions like Python import hooks. Equivalent path is dense helper coverage plus expected/actual/error metadata. |
| Fixtures | `AhkTest.Fixture`, `AhkTest.FixtureResult`, explicit fixture lists on tests and fixtures, scoped fixtures, test-local fixture overrides, `ahk_context` | partial | Current implementation supports function-scope fixture callbacks declared by name and injected into test callbacks in declared order, dependency fixtures, autouse fixtures, per-test function-scope fixture value caching, test-local function-scope fixture shadowing through `AhkFixtureOverrides`, suite-scoped fixture caching, session-scoped fixture caching keyed by suite/fixture definition with explicit cleanup, unknown-fixture errors, dependency cycle detection, LIFO cleanup via fixture results, fixture cleanup aggregation for function/suite/session cleanups, fixture-level `Params` that expand tests during collection, fixture param row ids and marks including skip/xfail marks, scoped fixture parameter cache isolation by fixture param id for suite/session lifecycles, scoped fixture setup-error caching for suite/session lifecycles, and the reserved built-in `ahk_context` fixture for `AddCleanup()`, dynamic `GetFixture()` lookup, row-level or fixture-level parameters through `ctx.Param` and `ctx.GetParam()` with a clear missing-parameter diagnostic, fixture-local parameter identity through `ctx.FixtureParamId`, request-like `ctx.FixtureNames` exposure for the current test's covered fixture graph, and current test metadata (`FixtureName`, `Scope`, `TestName`, `NodeId`, combined `ParamId`, `Params`, `Marks`, plus source/mark detail data when present). Covered dynamic `ctx.GetFixture(name)` now also updates `ctx.FixtureNames` like local pytest 7.4.3 `request.getfixturevalue(...)`: already-declared fixtures do not duplicate, while newly requested fixtures append their dependency graph in dependency-first order before the requested fixture name. Need richer setup reporting, override params/scoped override layering behavior, and fuller request-equivalent behavior beyond the covered fixture-name surface. |
| `tmp_path` / `tmp_path_factory` | `AhkTest.TempDir`, `AhkTest.TempPathFixture`, `AhkTest.TempPathFactoryFixture`, `AhkTestPath` path object | partial | Current temp dir creates one uniquely named directory, temp path fixture provides per-test isolation and cleanup, and temp path factory creates numbered directories cleaned at fixture teardown. `AhkTestTempDir.Join(...)` now returns an `AhkTestPath` object with explicit pathlib-like `Path`, `Name`, `Stem`, `Suffix`, `Join(...)`, `Parent()`, `Exists()`, `IsDir()`, `WriteText(...)`, `ReadText(...)`, `Mkdir({ Parents, ExistOk })`, `Unlink({ MissingOk })`, and `Rmdir()` helpers while preserving existing `.Path`, `.File(...)`, and `.PathJoin(...)` string APIs for compatibility. Covered `TempPathFactoryFixture` cleanup now uses one shared root temp directory with numbered child directories returned as full temp-dir objects, preserving existing `.File(...)`/`.Path` semantics while reducing repeated recursive teardown cost. `AhkTestTempDir` now includes a process-local counter in generated names and cleans temp roots directly with recursive `DirDelete` to avoid Windows fallback-delay paths. Need retained base dir policy, richer pathlib-style edge cases, and a documented stance on implicit object-to-string coercion under AHK v2. |
| Monkeypatch | `AhkTest.MonkeyPatchFixture` with env, map, working-directory, object property/method, global function strategy where possible | partial | Current implementation supports reversible environment variable set/delete, PATH-like environment prepending, reversible `Map` set/delete, reversible object property set/delete via own-property descriptors, reversible object method replacement through `DefineProp(..., { Call: ... })`, and reversible working-directory changes through fixture cleanup. AHK global namespace and built-ins limit parity. Need global function replacement strategies where possible. |
| Capture (`capsys`/`capfd`) | `AhkTest.CaptureFixture` for cooperative stdout/stderr capture, child-process command/argument capture, output-file capture, and future stream/process capture helpers | partial | Current harness writes reports, and `CaptureFixture` provides test-local cooperative `WriteOut`, `WriteErr`, and `Read` buffers for stdlib tests. `capture.Run(command, options)` preserves raw shell-command behavior through `RunWait`, captures child-process stdout/stderr into temp files, appends them to the fixture buffer, and returns an `AhkTestProcessResult` with `ExitCode`, `Out`, and `Err`; options currently include `WorkingDir` and `Encoding`. `capture.RunArgs(executable, args, options)` provides a safer argument-list path using Windows command-line quoting for literal argument values, writes child stdout/stderr and exit code through temporary files to avoid pipe backpressure on large output, appends output to the fixture buffer, supports `WorkingDir` and `Encoding`, preserves literal `%...%` arguments across its cmd wrapper, and supports `{ TimeoutSeconds: n }` by terminating the child process tree and returning `TimedOut: true`, `ExitCode: -1`, plus a captured stderr diagnostic. Unread captured output is attached to structured result entries, exported by `ToMap()`, and shown in failure/error text-report sections. Need fd-level limits documented for AHK's process model. |
| Parametrize | `AhkTest.Parametrize` with ids, generated ids, parameter metadata, parameterized node ids, row marks, option marks, fixture params, and stacked rows | partial | Current rows, explicit ids, generated ids, per-row marker metadata, option-level marker inheritance, option/row marker merging, exported `ParamId`/`Params`, parameterized node ids, empty parameter set skips, `Parametrize(..., { Stack: true })` Cartesian expansion, explicit fixture injection for parametrized tests, row-level `FixtureParams` exposed to fixtures through `ahk_context.Param`, merged stacked-row fixture params, and collection-time fixture-level `Params` expansion work. Need richer stacked marker diagnostics and fuller indirect/lazy fixture-style parameterization. |
| Marks | AHK-named marks on tests and parameter rows | partial | Current implementation supports plain string marks plus `AhkTest.Mark(name, data)` structured marks. `Marks` stays a plain marker-name array for `MarkFilter`, boolean `MarkExpr`, and strict registration checks, while structured `MarkDetails` preserves marker data in result entries and serialized maps. It supports `RegisterMark`, `Configure({ Marks: ... })`, plus `Run({ StrictMarkers: true })` validation for unregistered marks, exposes wrapper `-StrictMarkers`/`-RegisterMark`, and accepts AHK-named skip/xfail mark declarations without exposing pytest naming. Need richer marker inheritance rules. |
| Skip / xfail / xpass | `AhkTest.Skip`, `SkipIf`, `SkipNow`, `XFail`, `SkipMark`, `XFailMark`, `Run({ RunXFail: true })` | partial | Current behavior tracks skip, xfail, non-strict xpass, strict xpass failure semantics, mark-declared skip/xfail including strict xfail, a `RunXFail` mode that treats expected failures as ordinary tests for debugging, and grouped skip/xfail/xpass reason summaries in structured results and text reports. Need richer marker/config integration. |
| Exceptions | `AhkTest.Raises`, `RaisesMatch`, context-style helper if AHK ergonomics permit | partial | Current exception type and regex matching work, and structured result exports include AHK Error metadata (`File`, `Line`, `What`, `Extra`, `Stack`) for failed/error entries. Need richer captured exception info and nested assertion diagnostics. |
| Approximate comparisons | `AhkTest.Approx` / `AhkTest.AssertApprox` | partial | Current implementation covers pytest default relative tolerance `1e-6`, absolute tolerance `1e-12`, explicit abs-only behavior, arrays, maps, and `NanOk` handling. Need richer mismatch diagnostics and operator-like ergonomics where AHK permits. |
| Run control | `AhkTest.Run({ MaxFail: n })`, `AhkTest.Run({ ExitFirst: true })`, `AhkTest.Run({ RunXFail: true })`, `AhkTest.Run({ LastFailed: true })`, `AhkTest.Run({ LastFailedCache: path })`, `AhkTest.Run({ Stepwise: true })`, `tools\run-ahktest.ps1 -MaxFail n`, `-ExitFirst`, `-RunXFail`, `-LastFailed`, `-LastFailedCache`, `-Stepwise`, `-StepwiseCache` | partial | Current implementation stops after failed, errored, or strict unexpected-pass entries reach `MaxFail`, supports `ExitFirst` as a `MaxFail: 1` alias in both the AHK API and wrapper, supports `RunXFail` in the AHK API and wrapper, supports in-memory and file-backed last-failed reruns, falls back to the current full collection when a file-backed `LastFailedCache` contains no node ids that still exist in the current collected item set, and now matches the covered local pytest 7.4.3 explicit-selection override slices when `LastFailed`/`LastFailedCache` is combined with either a string or array `NodeFilter`, or with a `FilterExpr`, whose current selection falls entirely outside the cached failure set: ahktest runs that explicit selection, preserves prior cached failures after a clean selected pass, removes any executed cached node ids that now pass, and merges newly failing explicit selections into the persisted node-id cache. Covered multi-file duplicate-name reruns now also follow the observed local pytest 7.4.3 `--lf` and `--sw` behavior by tracking source-aware stable rerun keys, so same-name tests collected from different files stay scoped to the originally failing source file without changing the public result `NodeId` shape. When a mixed explicit node-id selection includes at least one cached failing node, the run still follows the cached intersection instead of overriding into the full explicit array. It also supports stepwise reruns that resume from the cached failing node, fall back to the current full collection when a cached stepwise node no longer exists in the current collected item set, fall back to the current filtered or node-selected subset when the cached stepwise node exists in the suite but is excluded by the current selection, preserve the prior cached stepwise node after a clean fallback run, and clear after the resumed failure passes. Need richer cache invalidation beyond the covered stale last-failed, explicit selection override, and stale/excluded stepwise fallback paths. |
| Warnings | `AhkTest.Warn`, `AhkTest.Warns`, warning capture/filter equivalent | partial | Current implementation supports ahktest-local warning records, regex message matching, category matching via `Warns(..., { Category: ... })`, warning source metadata (`File`, `Line`, `What`, `Extra`, `Stack`) captured from the `AhkTest.Warn()` call site and serialized by `ToMap()`, per-test warning capture on structured result entries, grouped `AhkTestResult.WarningSummary()` data, opt-in text warning summaries through `Run({ WarningSummary: true })` / `tools\run-ahktest.ps1 -WarningSummary`, and structured warning filters via `Configure({ WarningFilters: ... })`, `Configure({ AhkRunDefaults: { WarningFilters: ... } })`, or `Run({ WarningFilters: ... })` with `default`/`always`/`once`/`source`/`ignore`/`error` actions, category exact matching, message/source regex matching, line matching, last-match-wins precedence, run-option override of suite config, default exact-location de-duplication, once-level and source-level de-duplication, and local `Warns()` capture that remains isolated from suite-level error filters. The wrapper supports repeatable `-WarningFilter` entries, legacy `action:Category` entries without `=` may still be comma-split, and key/value entries such as `action=error;category=DeprecationWarning;message=old, deprecated path;source=\.test\.ahk;line=12` are never comma-split so message/source regular expressions may contain commas; the `file` key is accepted as a source alias. CI artifact coverage includes category-only, message-matched, comma-containing message, source/line warning-as-error runs, and invalid config-default warning-filter diagnostics through `-Config`. Need integration with a stdlib warning module and default reporting policy before broad stdlib migration. |
| Filtering | `AhkTest.Run({ Filter: ... })`, `AhkTest.Run({ FilterExpr: ... })`, `AhkTest.Run({ NodeFilter: ... })`, `AhkTest.Run({ MarkExpr: ... })`, `tools\run-ahktest.ps1 -FilterExpr/-NodeFilter/-MarkExpr` | partial | Current `Filter` is substring selection. `FilterExpr` supports name boolean expressions with `and`, `or`, `not`, parentheses, and quoted phrases; `NodeFilter` supports exact node-id selection by string or array, including parameterized node ids; `MarkExpr` applies the same expression grammar to marker metadata. Deselected tests are counted in structured results, invalid expressions raise diagnostics, wrapper expression and node-id flags are forwarded individually and in combination, wrapper `-List` lists filtered tests without executing callbacks or requiring a run summary, wrapper `-Config` can load AHK config files or a covered JSON manifest before test files, and config-provided `AhkRunDefaults` can supply default filter/list options unless explicit wrapper flags override them. The current JSON manifest slice accepts an `AhkTest` section with `AhkRunDefaults`, including covered `FilterExpr` defaults and JSON boolean normalization for flags such as `List`, matching the observed local pytest 7.4.3 `addopts` precedence where an explicit CLI `-k` override wins over a config-provided default. Covered file-backed `LastFailed` runs now also match the observed local pytest 7.4.3 `--lf -k` slice when a `FilterExpr` selects tests entirely outside the cached failure set: that explicit filtered selection runs, and prior cached failures remain recorded after a clean selected pass. Need richer token rules and broader manifest-backed default settings. |
| Reporting | Structured `AhkTestResult`, `AhkTestResult.ToMap`, `ToJson`, `ToJUnitXml`, `WriteJson`, `WriteJUnitXml`, text report, `tools\run-ahktest.ps1 -JsonReport/-JUnitReport/-WarningSummary/-Summary/-Traceback/-CaptureReport` | partial | Current stats and entries include pass/fail/error/skip/xfail/xpass counts, deselected count, durations, marks, structured mark details, source metadata, captured output, warnings, grouped outcome reasons, grouped warning summaries, error type/message/location/stack fields, and errors. `ToMap()` provides a serialization-ready result shape including `OutcomeReasons` and `WarningSummary`, `ToJson()` emits compact JSON, `ToJUnitXml()` emits a JUnit-style XML string, and collection-time failures now use the dedicated `AhkTestCollectionError` type with pytest-style `collection failure` JUnit/error-message wording while preserving the underlying detail in `Extra`. Covered collection-failure results now serialize `ExitCode: 2`, and wrapper-generated synthetic collection-failure artifacts now preserve that same exit-code distinction for top-level test/config/plugin auto-execute load failures and top-level compiler syntax failures, while non-collection early usage/runtime failures such as invalid reporting options continue to exit with ordinary error code `1`. Result objects plus the wrapper can write JSON/JUnit artifact files for CI adapters on passing and failing runs, wrapper JSON artifacts preserve combined-filter deselection counts and selected node ids, and the wrapper now clears any pre-existing JSON/JUnit artifact path before each run so stale structured reports cannot be mistaken for fresh results. For compatibility with existing local scripts, `tools\run-ahktest.ps1` now accepts legacy `-OutputJson` / `-OutputJUnit` aliases in addition to `-JsonReport` / `-JUnitReport`. Text reports include grouped skip/xfail/xpass reason lines by default, `Run({ Summary: "s"|"x"|"X"|"w"|... })` and wrapper `-Summary` can select grouped skip/xfail/xpass/warning summaries, optional grouped warning summaries remain available through `WarningSummary: true` / wrapper `-WarningSummary`, `Run({ Traceback: "auto"|"short" })` / wrapper `-Traceback auto|short` emits short traceback diagnostics with message, location, and extra data, `Run({ Traceback: "long"|"native" })` / wrapper `-Traceback long|native` adds AHK stack output for failure/error reports, `Run({ Traceback: "line" })` / wrapper `-Traceback line` emits a compact one-line `file:line: ErrorType: message` style diagnostic, `Run({ Traceback: "no"|"none" })` / wrapper `-Traceback no` suppresses location/stack traceback details while retaining error message and extra diagnostics, and `Run({ CaptureReport: "failures"|"all"|"none"|"no"|"stdout"|"stderr" })` / wrapper `-CaptureReport failures|all|none|stdout|stderr` controls captured stdout/stderr text-report sections while keeping structured captured data on result entries. `Traceback` and `CaptureReport` values are validated for direct AHK API calls, wrapper flags, and config defaults; invalid enum values raise `ValueError` before tests execute. The wrapper now records the actual `result.ExitCode` through a small status file, so list-only or quiet runs from either CLI flags or config defaults do not need text-summary parsing; explicit quiet runs may omit the text report while still preserving exit status and JSON/JUnit artifacts for CI. List-only wrapper reports forward selected test names without executing callbacks. `run_finish`/`report_finish` hook errors remain visible in text output and serialized in JSON/JUnit artifacts. Need remaining traceback style/detail levels. |
| Plugins / hooks | `suite.On(eventName, callback, options?)`, `AhkTest.On(eventName, callback, options?)`, and wrapper plugin files | partial | Current implementation supports opt-in `collect_finish`, `run_start`, `test_start`, `test_finish`, `run_finish`, and `report_finish` hooks on suites; `AhkTest.On` registers hooks on the default suite for wrapper/plugin files, `tools\run-ahktest.ps1 -Plugin path` loads one or more AHK plugin files after config files and before test files, hook options support `Priority` ordering with stable registration order for equal priorities and optional `Id` metadata, `Run({ DisableHookIds: [...] })` plus wrapper `-DisableHookId` can suppress matching hooks without editing plugin files, `collect_finish` receives a per-run item list that hooks can inspect or modify, collection/run/report hook errors are returned as structured result error entries, start-hook errors are reported as structured test errors, finish-hook errors convert the current result entry into a structured error without duplicating entries, and run/report-finish hook failures are now visible in wrapper text output plus JSON/JUnit artifacts. Need richer plugin metadata, grouped plugin-level disable controls, and non-AHK plugin manifests without exposing pytest naming. |
| Config | stdlib-local config object and wrapper options | partial | Current `AhkTest.Configure({ Marks: ... })` and `suite.Configure({ Marks: ... })` register marker names from AHK config objects, `AhkTest.Configure({ AhkRunDefaults: ... })` and `suite.Configure({ AhkRunDefaults: ... })` provide validated run-option defaults, including unknown option rejection, reporting enum validation for `Traceback` and `CaptureReport`, warning-filter shape normalization for `WarningFilter`/`WarningFilters`, and hook-disable id normalization for `DisableHookIds`. The direct AHK surface now also exposes `AhkTest.ConfigureManifest(path, sectionName := "AhkTest")` / `suite.ConfigureManifest(...)` for a first non-AHK JSON manifest slice, recursively converting JSON objects into AHK config objects while normalizing root `stdlib.True` / `stdlib.False` JSON booleans back to native AHK booleans before run-option consumption. `tools\run-ahktest.ps1 -Config path` now loads AHK config files or dispatches `.json` paths through that manifest loader before plugin and test files, and wrapper options cover plugin files, hook id disabling, strict marker registration, filters, list mode, rerun cache, max-fail, xfail debugging, summary/traceback selection, warning filters, and report artifacts. JSON manifest configs may now also provide `AhkTest.DiscoveryRoots` as wrapper-side default discovery targets when `-Target` is omitted; those roots are resolved relative to the JSON config file, and an explicit wrapper `-Target` still takes precedence. The wrapper now forwards only explicitly bound run options into `AhkTest.Run(...)`, so config defaults are not overwritten by empty string, false, or zero CLI defaults; explicit wrapper flags still take precedence. Need broader manifest-based settings for temp dirs and default reporting, plus additional non-AHK config formats. |
| Cache / rerun | In-memory suite last-failed cache, file-backed last-failed cache, and stepwise state | partial | Current suite instances remember failed/error/strict-xpass rerun keys for in-memory `LastFailed` reruns, `LastFailedCache` persists stable rerun keys across suite instances and wrapper invocations, and stale file-backed last-failed caches now follow local pytest 7.4.3's covered fallback by running the current full collection when none of the cached failed keys exist in the current collected item set. Those stable keys now include source context when available, matching the covered local pytest 7.4.3 duplicate-name multi-file behavior for both `--lf` and `--sw`: same-name tests from different files rerun or resume only from the originally failing source file. When `LastFailed`/`LastFailedCache` is combined with a string `NodeFilter` or an array of exact node ids whose current selection falls entirely outside the cached failure set, ahktest now follows the observed local pytest 7.4.3 explicit-selection slice by executing that explicit selection, preserving prior cached failures after a clean selected pass, and merging newly failing selected nodes into the persisted cache while removing executed cached ids that now pass. If the explicit node-id selection mixes cached and non-cached nodes, the run continues to follow the cached intersection instead of overriding into the whole array. `Stepwise`/`StepwiseCache` stores a single failing rerun key; if that key still exists inside the current selected set, the next run resumes from it and clears after the resumed failure passes. If the cached stepwise key is stale or excluded by the current filtered/node-selected subset, ahktest now follows the observed local pytest 7.4.3 fallback by running the current selection instead, updating to a new failing node when one appears there, and otherwise leaving the prior cached key in place after a clean fallback run. Need richer cache invalidation for broader multi-node and mixed-rerun interactions. |
| Doctest | AHK doc/example execution strategy | missing | Lower priority than fixtures/capture/approx for stdlib migration. |

## Target Packages

The machine-checkable framework map is `stdlib\STDLIB_FRAMEWORK.json`.
It currently defines planning groups only. These group names help prioritize
research, but they do not create public include directories. Direct Python
stdlib modules must declare `PythonPath`, and direct project support modules
must declare `Surface: "ahk-support"` plus `PublicPath`.
Runtime asset directories may be allowed only when they do not define public
includes; the current explicit exception is `stdlib\tkinter\lib` for the
bundled Tcl/Tk DLLs used by `stdlib.tkinter`.

| Planning group | Python analogue | Status |
| --- | --- | --- |
| `core` | builtins, types, operator, warnings, unittest-like support | `abc`, `types`, `operator`, and `warnings` direct as minimal Python subsets; `ahktest`, `assert`, and `base` direct support modules |
| `collections` | collections, bisect, heapq, itertools, functools | `bisect`, `heapq`, `itertools`, and `functools` direct as root Python modules; `collections.Counter` direct as `stdlib.collections.Counter`; other modules candidate |
| `math` | math, random, statistics | `math`, `random`, `statistics`, `fractions`, and `decimal` direct as first slices |
| `text` | json, csv, configparser, parser helpers | `json`, `csv`, `configparser`, and `re` direct as root Python modules; `comparser` and `toml` remain support modules |
| `datetime` | calendar, datetime, time | `calendar`, `datetime`, and `time` direct as first slices |
| `os` | os, pathlib, shutil, platform, Windows helpers | `os` direct as `stdlib.os`; `pathlib.Path` direct as `stdlib.pathlib.Path`; `shutil` direct as a first slice |
| `io` | io, tempfile | `io` direct first slice with `StringIO`; `tempfile` direct first slice |
| `runtime` | hashlib, logging, pprint, inspect/import-style helpers | `hashlib` direct as a first slice; `logging` direct as a first slice; `pprint` direct as a first slice; `inspect` direct as a predicate first slice; `socket` direct as a first networking/runtime slice; other runtime helpers still candidate |
| `concurrency` | asyncio, concurrent.futures, queue | `asyncio` and `queue` direct as first slices; other concurrency modules still candidate |
| `native` | ctypes and external bindings | native quarantine |

## Promotion Rules

A module is `direct` only when:

1. Its implementation lives at the Python-path-aligned `stdlib\...` location.
2. Its public include is `<stdlib\...>` and is mechanically derived from
   `PythonPath` or support `PublicPath`.
3. Its direct files have `#Requires AutoHotkey v2.0`.
4. It does not include old library paths such as `<json\Json>` or
   `<bisect\bisect>`.
5. It has behavior coverage in `stdlib\tests\stdlib.test.ahk` or a focused
   test file under `stdlib\tests`.
6. The framework manifest records `Include` and `Path`.
7. It has at least one usage example under `stdlib\examples`.
8. Its AHK source and stdlib examples do not introduce `pytest` or lowercase
   `py*` identifiers. Pytest is the behavior target for `ahktest`, but public
   AHK names must stay AHK-prefixed or use the existing `AhkTest` surface.
   This rule applies to identifiers, not documentation strings, official URLs,
   or source paths embedded in tests.
9. Its public API is designed toward namespace-style stdlib access, not only
   old global wrapper functions.

Candidate modules must keep `SourceCandidates` so the old library remains
searchable as implementation material. Direct modules use `MigratedFrom` only
as historical provenance; it is not a dependency or an active public include
surface. Old AHK entrypoints should be kept while they are still needed as
reference material, then removed after the corresponding stdlib module has
namespace-style behavior coverage under `ahktest`.

The stdlib wrapper is now stdlib-only: `tools\run-ahktest.ps1` defaults to
`.\stdlib\tests`, always includes `stdlib\ahktest.ahk`, and rejects tests that
still include `<ahktest\ahktest>`. Legacy old-path tests are reference material
until migrated; they are not part of the active runner surface.

## Global Symbol Safety

AutoHotkey includes share one global namespace, and identifiers are
case-insensitive. Before broadening stdlib entrypoints, check for class/function
name collisions. Prefer names that avoid built-in collisions, and avoid adding
two direct modules that define the same global symbol.

The public API contract is `stdlib.module.func(...)` or
`stdlib.module.Class(...)`; examples and active tests must not teach bare module
entrypoints even when AHK requires some implementation symbols in the shared
global namespace. The 2026-06-01 audit closed the active public-surface leaks
for `assert(...)`, bare `AssertionError`, and bare `Toml()` by promoting the
documented calls to `stdlib.assert.assert(...)`,
`stdlib.assert.AssertionError`, and `stdlib.toml.Toml(...)`. The same audit
found `comparser` legacy helpers (`com_parse`, `com_dumps`, `comParser`),
`tkinter`'s implementation `Tk` class, and `platform`'s `uname_result` class as
global implementation symbols, but not as active example/test public calls.

Because includes are full loads, `<stdlib\init>` deliberately reserves only the
root namespace object. A future aggregate file, if needed, must be opt-in and
separate from init so that users can control which modules add global symbols.
Each direct module should include `<stdlib\init>` and mount itself onto
`stdlib.<python_module_path>` using AHK-prefixed internal bridge names where a
bridge class is needed. This is an explicit module responsibility, not a
package-initialization side effect.

The inventory tools generate symbol evidence:

- `.codex/inventory/symbols.json`
- `.codex/inventory/symbol-conflicts.json`
- `.codex/inventory/summary.md`

## Test Gates

Use wrappers only. Do not run `..\AutoHotkey64.exe script.ahk` directly.

Baseline framework commands:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\test-stdlib-framework.ps1
powershell -ExecutionPolicy Bypass -File .\tools\test-stdlib-layout.ps1
powershell -ExecutionPolicy Bypass -File .\tools\run-ahktest.ps1 -Target .\stdlib\tests -TimeoutSeconds 90
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk-validate.ps1 -Path .\stdlib -TimeoutSeconds 20
powershell -ExecutionPolicy Bypass -File .\tools\build-ahk-inventory.ps1
powershell -ExecutionPolicy Bypass -File .\tools\test-ahk-inventory.ps1
powershell -ExecutionPolicy Bypass -File .\tools\stop-ahk-processes.ps1 -ListOnly
```

After every AHK test or validate run, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\stop-ahk-processes.ps1 -ListOnly
```

## TDD Migration Loop

For each candidate module:

1. Pick the Python `Lib` module path and record it as `PythonPath`; use
   `Surface: "ahk-support"` only for project-owned support modules.
2. Add the direct path to the manifest and let `tools\test-stdlib-layout.ps1`
   or a behavior test fail first.
3. Add an include and focused behavior test through `<stdlib\...>`.
4. Migrate implementation directly into the Python-path-aligned `stdlib\...`.
5. Replace internal includes with `<stdlib\...>` or local split files under
   the new subtree.
6. Run framework, layout, behavior, validate, inventory, and process checks.
7. Update this document with the module status and any syntax notes learned
   from `.codex\chm\docs`.

Foundation migration has started beyond `ahktest`: `stdlib\bisect`,
`stdlib\collections`, `stdlib\pathlib`, and `stdlib\statistics` are direct.
Their public behavior is checked against Python 3.10.11 rather than capped at
the older AHK source surface.

Recommended next candidates:

- `stdlib\ahktest` broader discovery collection failures, discovery duplicate
  policy beyond the covered duplicate-name rerun/cache parity, richer
  request-equivalent behavior beyond the
  covered fixture-name and JSON-manifest default-config surfaces, and broader
  multi-node rerun/filter interactions beyond the covered node-id and
  filter-expression explicit override slices
- residual `stdlib\itertools` wrapper parity once fresh Python probes expose
  new still-red branches beyond the current hot path
- deeper `stdlib\logging`, `stdlib\queue`, and filesystem/runtime slices after
  the current first promotions

These can proceed in parallel with continued ahktest hardening. `tempfile` is
already direct, so the next leverage is deeper parity inside covered direct
modules rather than another promotion from `candidate`.

## AHK V2 Notes

Use local CHM docs under `.codex\chm\docs` as the syntax reference. Relevant
starting points:

- `lib\_Include.htm` for include resolution and shared-source semantics.
- `lib\_Requires.htm` for version directives.
- `Scripts.htm` and `lib\_ErrorStdOut.htm` for `/Validate` and stderr behavior.
- `Functions.htm` and `Objects.htm` for callable objects, classes, and methods.

During migration, direct calls to undefined functions can fail during load or
validation. Use dynamic calls in tests only when a runtime behavior failure is
needed for a not-yet-created API.

AHK identifiers are case-insensitive, including locals versus built-in classes.
Avoid local names such as `buffer` when calling the built-in `Buffer` class.

`stdlib.os.system(command)` follows Python's raw shell-string shape, not a
safe argv API. AutoHotkey `RunWait` does not interpret shell syntax such as
redirection or pipes by itself, so the stdlib wrapper uses `A_ComSpec /c` and
returns the process exit code. It accepts only string commands and rejects
embedded null characters before shell execution, matching Python 3.10's
argument boundary. Output capture belongs in explicit process or ahktest
capture helpers, not in `os.system`.

`stdlib.operator` is a first slice of Python 3.10.11 `operator`. It exposes
comparison, truth, identity, arithmetic, sequence, item, getter, caller, and
length-hint helpers under `stdlib.operator`. `add` and `mul` now cover the
Python sequence cases for strings and AHK arrays used as Python-list
equivalents, including list concatenation and integer repetition. String
`countOf` and `indexOf` intentionally compare one-character sequence elements,
matching Python 3.10.11 `operator.countOf("aaa", "aa") == 0` and
`operator.indexOf("abc", "bc")` raising `ValueError`; substring membership is
covered by `operator.contains`. `length_hint` now follows Python's
`operator.length_hint` contract for covered custom stdlib iterators by honoring
an internal `__LengthHint()` hook; covered finite `itertools.repeat(...)`
objects report the current remaining count after partial consumption while
infinite repeats behave as unsized objects, so
`operator.length_hint(repeat(...), default)` returns the caller-provided
default, matching local Python 3.10.11 probing. Covered
`default` arguments are validated before sized-object lookup like Python,
accept negative integers and root `stdlib.True` / `stdlib.False` as bool-as-int
defaults for unsized objects, and surface Python-style integer-interpretation
`TypeError` messages for invalid defaults such as `stdlib.None`, strings, and
root `stdlib.tuple()` values. Covered custom `__LengthHint()` providers now
also follow Python's return protocol by accepting root bool results as
bool-as-int values, returning the default when the provider raises `TypeError`,
returning the default when the provider returns `stdlib.NotImplemented`,
propagating provider `ValueError`, rejecting negative hints with
`ValueError("__length_hint__() should return >= 0")`, and surfacing Python-style
`__length_hint__ must be an integer, not ...` diagnostics for non-integer hint
results. For AHK
`Map`, `contains`, `countOf`, and
`indexOf` follow Python dict iteration semantics by operating on keys.

`stdlib.pathlib.Path(parts*)` is a Windows-oriented first slice of Python
3.10.11 `pathlib.Path`. It supports string conversion through `String(path)`,
lowercase Python-style properties/methods such as `.name`, `.stem`,
`.suffix`, `.parent`, `.joinpath(...)`, `.exists()`, `.is_dir()`,
`.is_file()`, `.read_text()`, `.write_text()`, `.mkdir()`, `.unlink()`, and
`.rmdir()`. AHK cannot expose Python's `/` operator join ergonomics, so
`.joinpath(...)` and `.Join(...)` are the public AHK equivalent for now.
`write_text()` returns the written character count to match Python behavior.

`stdlib.bisect.bisect_left/right` follow Python's 0-based insertion
point convention even though AHK arrays are 1-based. `insort_left/right`
convert that public insertion point to the required AHK `InsertAt`/`Push`
operation internally.

`stdlib.heapq` is a first slice of Python 3.10.11 `heapq` over AHK arrays as
Python-list equivalents. It exposes `heappush`, `heappop`, `heapify`,
`heapreplace`, and `heappushpop` as min-heap operations. The old local
`binaryHeap` class is reference material only and is not included by the
direct module because it is a class-oriented max-heap by default rather than
Python's list-in-place `heapq` API.

`stdlib.collections.Counter` is a first slice of Python 3.10.11
`collections.Counter`. The direct surface now exposes
`stdlib.collections.Counter` as a class object while preserving the existing
constructor call shape `stdlib.collections.Counter(...)`. Covered Python 3.10.11
classmethod behavior now includes `Counter.fromkeys(...)`, which intentionally
raises `NotImplementedError("Counter.fromkeys() is undefined.  Use Counter(iterable) instead.")`
for the covered one- and two-argument paths, while preserving Python's
dedicated missing-iterable and too-many-positional-arguments `TypeError`
messages. The direct slice otherwise supports counting strings and AHK arrays, mapping
counts including negative counts, missing keys returning zero, `total()`,
`update(...)`, `subtract(...)`, `setdefault(...)`, `pop(...)`, `popitem(...)`, `elements()`, `most_common(...)`, `copy()`,
`Delete(...)`, `Clear()`, and a Python-style `Counter({...})` `__Repr()` for
covered numeric/string-key counters using Python's most-common ordering, with
an insertion-order fallback for covered unorderable count payloads like nested
mapping counts. The public AHK surface also accepts an explicit
`{ kwargs: Map(...) }` envelope as an analogue for Python constructor,
`update(...)`, and `subtract(...)` keyword counts, including source-plus-kwargs
merge order, while ordinary object literals such as `{ a: 2 }` remain
non-iterable sources and keep Python-style source validation errors. Covered
`update(...)` and `subtract(...)` now also match Python 3.10.11's dedicated
non-iterable and too-many-positional-arguments `TypeError` wording for
`Counter().update(42)`, `Counter().subtract(42)`, and two-source call shapes
such as `Counter().update({}, {})`. `setdefault(...)` now also matches local
Python 3.10.11 for existing-key passthrough, missing-key insertion order,
omitted-default `None` insertion, and the builtin `setdefault expected at least
1 argument, got 0` / `setdefault expected at most 2 arguments, got 3`
arity wording. `get(...)` now also matches local Python 3.10.11 by returning
the stored count for existing keys, `None` for missing keys without an explicit
default even though `counter["missing"]` still yields zero, caller-provided
defaults for missing keys, and the builtin `get expected at least 1 argument,
got 0` / `get expected at most 2 arguments, got 3` arity wording. `pop(...)`
now also matches local Python 3.10.11 for
existing-key removal, missing-key default passthrough, `KeyError("'key'")`
for missing keys without a default, and the builtin `pop expected at least 1
argument, got 0` / `pop expected at most 2 arguments, got 3` arity wording.
`popitem(...)` now also matches local Python 3.10.11 for LIFO removal order,
readonly tuple-like `(key, value)` return rows, empty-Counter
`KeyError("'popitem(): dictionary is empty'")`, and the builtin
`dict.popitem() takes no arguments (1 given)` arity wording. `copy()` now also
matches local Python 3.10.11 for covered subclass preservation: copying a
`Counter` subclass returns a distinct object of the same subclass with equal
counts and independent future mutation. `clear()` now also matches local
Python 3.10.11 by returning `None`, emptying the covered mapping view without
changing missing-item lookup semantics (`counter["missing"] == 0`,
`counter.get("missing") is None`), and restarting public Counter iteration from
fresh insertion order after subsequent updates such as `clear(); update("ba")`.
`Delete(key)` now also matches covered Python mapping deletion behavior for
Counter-backed public paths such as `stdlib.operator.delitem(counter, key)` by
removing existing keys and raising `KeyError("'key'")` for missing keys instead
of silently succeeding.
`elements()` now returns a lazy single-use AHK
enumerable that keeps its consumed position across repeated consumers, like
Python's iterator object. It observes existing-count updates made after
construction until a key's repeat has started; once that key is active, the
repeat count is fixed while later keys still read their current counts when
reached. This matches the
observed Python 3.10.11 `elements()` chain-of-repeat behavior, and the
elements object exposes the Python-style `<itertools.chain object at 0x...>`
`__Repr()` shape observed for `Counter(...).elements()`. Mapping-provided
counts preserve their source type on first insertion so
`elements()` accepts root `stdlib.True` / `stdlib.False` counts as Python
bool-as-int `1` / `0`, rejects float or string counts like Python when consumed, and now
raises `Error("dictionary changed size during iteration")` if the Counter grows
or shrinks after iteration begins, plus
`Error("dictionary keys changed during iteration")` if keys are replaced while
the size stays constant or if a key is deleted and re-added before the next
pull, even when size and apparent key order return to their original shape.
Source
classification accepts strings, arrays, `Map`/`Counter` mappings, and custom
AHK enumerables, while ordinary objects and non-iterable scalar values raise
`TypeError` like Python. The current arithmetic/comparison slice routes Python
operator behavior through `stdlib.operator`: `add`, `sub`, `and_`, `or_`,
`pos`, `neg`, and Counter-to-Counter rich comparisons now preserve Python's
positive-count result filtering and missing-key-as-zero comparison semantics,
while `eq`/`ne` against non-Counter non-mapping objects now return Python's
`False`/`True` booleans instead of raising, and mixed count types preserve
Python's split between boolean `eq`/`ne` and `TypeError` for ordering
comparisons. `eq`/`ne` for Counter-to-Counter and Counter-to-mapping
comparisons now also use Python-style value equality for nested `list`/`dict`
count payloads instead of falling back to AHK object identity. Root
`stdlib.True` / `stdlib.False` count payloads now also compare like Python
`bool` integers across both Counter-to-Counter and Counter-to-mapping equality
and rich comparison paths, so covered cases such as
`Counter(a=True) == Counter(a=1)`, `Counter(a=True) == {'a': 1}`,
`Counter(a=True) <= Counter(a=1)`, and `Counter(a=False) < Counter(a=1)`
follow Python 3.10.11 instead of leaking raw AHK boolean-vs-int comparison
behavior. The covered arithmetic and mapping-update slice now also treats root
`stdlib.True` / `stdlib.False` counts like Python `bool` integers for
`pos`, `neg`, `add`, `sub`, `and_`, `or_`, `total()`, `update(mapping)`, and
`subtract(mapping)`, while preserving Python's observable result payload shape:
covered cases such as `+Counter(a=True, b=False, c=-1)`,
`Counter(a=True) + Counter(a=True)`, `Counter() + Counter(a=True, b=False)`,
`Counter(a=True) & Counter(a=1)`, `Counter(a=1) & Counter(a=True)`,
`Counter(a=True).update({'a': 1})`, `Counter(a=1).subtract({'a': True})`, and
`Counter(a=True, b=False).total()` now match local Python 3.10.11 instead of
surfacing raw AHK `AhkStdlibBoolean` operator errors. Mixed count
payloads that combine root `stdlib.True` / `stdlib.False` with
`fractions.Fraction(...)` and `decimal.Decimal(...)` now also follow local
Python's numeric tower across covered unary, binary, and mapping-update paths:
covered cases such as `+Counter(a=Fraction(3, 2), b=Fraction(-1, 2))`,
`-Counter(a=Decimal('1.5'), b=Decimal('-0.5'))`,
`Counter(a=True) + Counter(a=Fraction(1, 2))`,
`Counter(a=True) - Counter(a=Fraction(1, 2))`,
`Counter(a=True) & Counter(a=Fraction(1, 2))`,
`Counter(a=True) | Counter(a=Fraction(3, 2))`,
`Counter(a=True) + Counter(a=Decimal('0.5'))`,
`Counter(a=True) - Counter(a=Decimal('0.5'))`,
`Counter(a=True).update({'a': Fraction(1, 2)})`,
`Counter(a=Fraction(1, 2)).update({'a': True})`,
`Counter(a=True).update({'a': Decimal('0.5')})`, and
`Counter(a=Decimal('1.5')).subtract({'a': True})` now match Python 3.10.11
instead of surfacing raw AHK bool-arithmetic or positive-filter mismatches.
Covered `Counter` rich equality now also treats
`fractions.Fraction(...)` counts and numerically-equal
`decimal.Decimal(...)` counts as equal when both sides are `Counter`
instances, so cases like `Counter(a=Fraction(1, 2)) == Counter(a=Decimal('0.5'))`
and the matching `!=` path now follow local Python 3.10.11 instead of failing
through the raw AHK decimal-conversion gap for Fraction payloads.
Covered `Counter` rich ordering now also treats
`fractions.Fraction(...)` counts and comparable `decimal.Decimal(...)` counts
through Python's numeric tower when both sides are `Counter` instances, so
cases like `Counter(a=Fraction(1, 2)) < Counter(a=Decimal('0.75'))`,
`Counter(a=Fraction(1, 2)) <= Counter(a=Decimal('0.5'))`,
`Counter(a=Fraction(3, 2)) > Counter(a=Decimal('0.5'))`, and
`Counter(a=Fraction(1, 2)) >= Counter(a=Decimal('0.5'))` now follow local
Python 3.10.11 instead of surfacing the raw AHK mixed-type comparison gap for
Fraction-vs-Decimal payloads.
Covered `Counter` comparison errors now also preserve Python 3.10.11's concrete
mapping-subclass type names on the right-hand side for non-equality ordering
comparisons: `eq` / `ne` still compare value-wise against mapping subclasses,
but cases like `Counter(a=1) < DemoDictLike(a=2)` now raise
`TypeError("'<' not supported between instances of 'Counter' and 'DemoDictLike'")`
instead of collapsing the mapping subclass to a generic `'dict'` label.
Covered `Counter` arithmetic and set-style operand validation now also preserve
those concrete right-hand mapping-subclass type names for `+`, `-`, and `&`,
so cases like `Counter(a=1) + DemoDictLike(a=1)` now raise
`TypeError("unsupported operand type(s) for +: 'Counter' and 'DemoDictLike'")`
instead of reporting a generic `'dict'` operand label.
Covered reverse arithmetic validation where a plain mapping or mapping subclass
appears on the left and `Counter` is on the right now also preserves Python
3.10.11's concrete left-hand mapping type names, so covered cases like
`{'a': 1} + Counter(a=1)` raise
`TypeError("unsupported operand type(s) for +: 'dict' and 'Counter'")` while
`DemoDictLike(a=1) + Counter(a=1)` raises
`TypeError("unsupported operand type(s) for +: 'DemoDictLike' and 'Counter'")`
instead of leaking host AHK `Map` names.
Covered `Counter | mapping` and `mapping | Counter` now also follow the local
Python 3.10.11 result-shape baseline for covered plain `dict` union behavior:
the operation returns a plain mapping instead of a `Counter` or a `TypeError`,
and right-hand values overwrite left-hand values on shared keys. On this AHK
host, native `Map` enumeration order for string keys does not preserve Python
`dict` insertion ordering closely enough to promise the exact covered CPython
key-order result for mixed `Map` / `Counter` unions, so this slice currently
claims value/result-type parity but not full Python key-order parity.
Mixed count
types in unary `pos`/`neg` and set-style `and_`/`or_` now also surface
Python-style comparison error messages instead of raw AHK numeric-type
diagnostics, while same-type non-numeric `list`/`str` counts in `and_`/`or_`
now also follow Python's later positive-filter failure stage (`value > 0`)
instead of failing early on pairwise `<` comparisons. `add(str, int)`
preserves Python's special string-concatenation `TypeError` wording.
`update(mapping)` now also follows Python's `new_count + existing_count`
ordering for covered existing `str`/`list` payloads, preserving Python's
`'yx'`/`[2, 1]` results and the corresponding `int`-vs-`str` / `int`-vs-`list`
TypeError paths instead of attempting raw AHK `existing + new` evaluation.
Covered `Fraction`/`float` mapping updates now also follow local Python's
float-result path instead of failing as unsupported mixed counts.
`subtract(mapping)` now likewise remaps covered existing non-numeric count
payload failures such as `str-str`, `list-list`, and `function-function` back
to Python's `unsupported operand type(s) for -: ...` wording instead of
leaking AHK's raw numeric-type diagnostics, and the same now holds for
right-only mapping counts such as `Counter().subtract({'a': 'y'})`, which
again report Python's `int`-vs-payload binary-op wording rather than raw
AHK `0 - value` numeric diagnostics. Covered `Fraction`/`float` mapping
subtract paths now likewise follow local Python's float-result behavior
instead of failing as unsupported mixed counts.
`total()` now also remaps covered non-numeric count payload failures such as
`str`, `list`, and `function` back to Python's `unsupported operand type(s)
for +: 'int' and ...` wording instead of leaking AHK's raw `+=` numeric
diagnostics.
Non-iterable custom AHK class instances now surface their leaf class name in
the `"'Type' object is not iterable"` path instead of leaking nested AHK
class names, and `elements()` now uses Python-style type names for
non-integer counts such as `float`, `str`, `NoneType`, `function`, and custom
class names instead of raw AHK `Type(...)` names.
Direct `Fraction(1, 1)` and `Decimal("1")` count payloads remain rejected by
`elements()` with Python's integer-interpretation `TypeError`, matching local
Python 3.10.11. Deeper non-integer count edge cases remain deferred.

`stdlib.itertools` is a first slice of Python 3.10.11 `itertools`. It exposes
`accumulate`, `count`, `repeat`, `chain`, `compress`, `cycle`, `pairwise`, `product`, `zip_longest`, `groupby`, `combinations`, `combinations_with_replacement`, `permutations`, `starmap`, `takewhile`, `dropwhile`, `filterfalse`, `tee`, and `islice` under `stdlib.itertools`,
with lazy AHK enumerable objects and Python-style zero-based indexes for
`islice`. The legacy global `accumulate`, `chain`, `repeat`, `count`,
`compress`, `cycle`, `pairwise`, `product`, `zip_longest`, `groupby`, `combinations`, `combinations_with_replacement`, `permutations`, `starmap`, `takewhile`, `dropwhile`, `filterfalse`, `tee`, `islice`, `Next`, `List`, and `Itertools` entrypoints from
`itertools\itertools.ahk` are intentionally not part of the direct surface
because AHK includes share a case-insensitive global namespace. The direct
slice now rejects non-integer `repeat(..., times)` values with Python-style
`TypeError`, including root `stdlib.NotImplemented` as `NotImplementedType`,
while accepting root `stdlib.True` / `stdlib.False` times as
Python bool-as-int counts, accepts root `stdlib.True` / `stdlib.False`
`count(start, step)` values as Python bool-as-int numeric inputs while
preserving the covered explicit-root-bool first-yield behavior from local
Python 3.10.11, rejects non-numeric `count(start, step)` values,
allows float `count` progressions, accepts an AHK options-object analogue for
Python's keyword-style `start` and `step`, such as
`count({ start: 3, step: 2 })` and `count(3, { step: 2 })`, accepts covered `stdlib.decimal.Decimal(...)` and
`stdlib.fractions.Fraction(...)` start/step values through
`stdlib.operator.add(...)` stepping instead of raw AHK `+=`, including covered
mixed float/Fraction progressions that follow local Python's float-result
behavior, while still rejecting unsupported non-numeric starts/steps with
Python's `a number is required` message. Covered `count(...)` objects now expose
Python-style parameterized `__Repr()` text that tracks the current next value
and omits only Python's default integer/bool-true step, while covered
`repeat(...)` objects expose Python-style parameterized `__Repr()` text that
keeps infinite repeats unbounded and reports the remaining finite count after
partial consumption, and covered finite `repeat(...)` objects also provide the
remaining count to `stdlib.operator.length_hint(...)` while infinite repeats
use Python's unsized-object path, returning the caller-provided default from
`operator.length_hint(repeat(...), default)`. Covered `repeat(object, times :=
unset)` now also accepts the AHK options-object analogue for Python's
keyword-style `object=` / `times=` calls, so
`repeat({ object: "x", times: 3 })`, `repeat({ object: "x" })`, and
`repeat("x", { times: 3 })` now follow local Python 3.10.11 behavior. Covered
split keyword-analogue shapes such as `repeat({ object: "x" }, { times: 3 })`
and `repeat({ times: 3 }, { object: "x" })` now also follow the same Python
keyword behavior instead of treating the reversed form as a positional
non-integer `times` payload. Covered
plain iterable object values that define their own `__Enum` are now also kept
on the positional value path even when they carry keyword-like own properties
such as `object` or `times`, so `repeat(plain_object_value)` and
`repeat(plain_times_value, 2)` now repeat the real object value instead of
misclassifying it as the AHK keyword-analogue wrapper shape. Covered plain
iterable or callable object values passed in the second `times` position are
also now kept on Python's non-integer validation path even when they carry
keyword-like own properties such as `times` or `object`, so
`repeat("x", plain_times_obj)` now raises the covered
`'object' object cannot be interpreted as an integer` timing instead of being
misclassified as an AHK keyword-analogue options object. Covered
options-only missing-`object`, single-extra-key, too-many-keyword,
duplicate-`object`, positional-plus-single-invalid-key, and positional-plus-options
three/four-argument analogue paths now keep Python's observable error priority,
including options-only plain-object shapes with no recognized repeat keys:
`repeat({ extra: 1 })` and `repeat({ extra: 1, another: 2 })` now raise
`repeat() missing required argument 'object' (pos 1)`, while
`repeat({ extra: 1, another: 2, third: 3 })` crosses into
`repeat() takes at most 2 keyword arguments (3 given)`.
Covered
split keyword-analogue error priority now also mirrors Python's order-insensitive
keyword behavior: `repeat({ object: "x" }, { extra: 1 })` and
`repeat({ extra: 1 }, { object: "x" })` raise the invalid-keyword branch,
`repeat({ times: 3 }, { extra: 1 })` and
`repeat({ extra: 1 }, { times: 3 })` stay on the missing-`object` branch, and
three-key mixed shapes such as `repeat({ object: "x" }, { times: 3, extra: 1 })`
raise `repeat() takes at most 2 keyword arguments (3 given)`. Three-way split
keyword-wrapper shapes such as `repeat({ object: "x" }, { times: 3 }, {
extra: 1 })` and `repeat({ extra: 1 }, { object: "x" }, { times: 3 })` now
reach that same too-many-keyword branch instead of stopping early at the raw
three-argument arity error.
Covered
split keyword-analogue duplicate names now also follow Python's multi-`**`
merge behavior: `repeat({ object: "x" }, { object: "y" })` raises
`got multiple values for keyword argument 'object'`, while
`repeat({ object: "x", times: 3 }, { times: 4 })` and the reversed
`times`-first split form raise the corresponding duplicate-`times` branch
instead of silently keeping the first value. The same duplicate-first priority
now also covers three-way split forms such as `repeat({ object: "x" }, {
times: 3 }, { times: 4 })`, `repeat({ object: "x" }, { object: "y" }, {
extra: 1 })`, and `repeat({ extra: 1 }, { extra: 2 }, { object: "x" })`.
Covered
including the covered options-only `repeat({ times: 3, extra: 1, another: 2 })`
shape now surfacing Python's `repeat() takes at most 2 keyword arguments (3 given)`
instead of stopping early at the missing-`object` branch,
instead of falling through to raw AHK integer-interpretation or stale
argument-count errors. Covered positional-plus-two-keyword-wrapper forms now
also preserve Python's duplicate/arity order: `repeat("x", { times: 3 }, {
times: 4 })` raises duplicate `times`, while `repeat("x", { times: 3 }, {
another: 2 })` keeps `repeat() takes at most 2 arguments (3 given)`. The
direct slice accepts `stdlib.None` as an unbounded
`islice` stop value, treats explicit
`stdlib.None` start as Python's default `0`, treats `stdlib.None` step as
Python's default `1`, treats root `stdlib.True` / `stdlib.False` as Python
bool-as-int values for covered `islice` start, stop, and step paths, including
the Python `ValueError` for a false step, and now distinguishes Python's
stop-specific `ValueError` wording for explicit invalid
`islice(..., start, stop)` arguments instead of collapsing everything into the
generic indices message. Covered `islice(...)` now also surfaces Python 3.10's
no-keyword `TypeError("islice() takes no keyword arguments")` for AHK
keyword-style options objects such as `islice(iterable, { stop: value })`
before iterable or index validation. Covered `islice(...)` now also matches
local Python 3.10.11 for duplicate split keyword-wrapper objects before later
no-keyword or arity branches, so shapes like
`stdlib.itertools.islice({ extra: 1 }, { extra: 2 })` and
`stdlib.itertools.islice({ stop: 1 }, { stop: 2 })` raise the corresponding
duplicate-keyword `TypeError(...)`, while later-keyword shapes such as
`stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })` still keep
Python's no-keyword priority ahead of raw arity errors. Covered `islice(...)`
now also mirrors Python's explicit `expected at least 2 arguments` /
`expected at most 4 arguments` wording for the 0-, 1-, and 5-argument forms.
Covered `islice(...)` now validates index
arguments before iterable construction, then rejects non-iterable inputs at
construction without pre-consuming valid iterables. Covered `cycle(...)`
behavior now follows Python's lazy cache-and-replay semantics for finite
iterables, preserves iterator position across multiple consumers, returns empty
for empty iterables, validates non-iterable inputs at construction without
pre-consuming valid iterables, and shares the same Python-style non-iterable
type-name parity as `chain(...)` and `islice(...)`. `repeat(value, stdlib.None)` now also
reports Python's `NoneType`-specific integer-interpretation error instead of a
generic object type name, and custom AHK class instances now surface their leaf
class name in that same error path instead of collapsing to `'object'`, and
covered AHK function objects now surface Python's `function` type name instead
of raw `Func` / `BoundFunc`. AHK arrays and maps now also surface Python's
`list` and `dict` type names in that same `repeat(..., times)` error path
instead of raw AHK `Array` and `Map` names. The shared iterable validation path
used by `chain(...)`, `cycle(...)`, and `islice(...)` now also surfaces
Python-style `int`, `function`, `object`, and custom leaf class names for
non-iterable inputs instead of raw AHK `Type(...)` names. Covered
direct `chain(...)` now also rejects AHK keyword-style options objects such as
`chain({ iterables: rows })`, `chain({ iterable: rows })`, generic
property-object shapes such as `chain({ extra: 1, another: 2 })`, and mixed
positional-plus-keyword analogue paths like
`chain(rows, { iterables: other })` with Python 3.10's observable
`TypeError("chain() takes no keyword arguments")` before iterator
construction, instead of deferring until a wrapped object later falls through
to the generic non-iterable error path. Covered split keyword duplicate
priority now also matches local Python 3.10.11, so
`stdlib.itertools.chain({ extra: 1 }, { extra: 2 })` raises
`TypeError("itertools.chain() got multiple values for keyword argument
'extra'")` before the later no-keyword branch. Covered
plain `Object` iterables that define their own `__Enum` now stay accepted even
when they carry keyword-like own properties such as `iterables`, matching local
Python 3.10.11's distinction between real iterable objects and keyword syntax.
Covered plain callable `Object` values with keyword-like own properties are now
likewise kept off the keyword-analogue path, so `chain(plain_callable_obj)` and
`chain(rows, plain_callable_obj)` now raise Python's observable non-iterable
`TypeError(...)` instead of being misclassified as keyword syntax.
Covered
`chain.from_iterable(iterable)` now mirrors Python 3.10.11's alternate
constructor shape by lazily flattening each inner iterable while preserving
iterator position across consumers, with `chain(...)` itself kept callable on
the public `stdlib.itertools.chain` surface. It now also rejects AHK
keyword-style options objects such as
`chain.from_iterable({ iterable: rows })` and generic property-object shapes
such as `chain.from_iterable({ extra: 1, another: 2 })` with Python 3.10's
`TypeError("chain.from_iterable() takes no keyword arguments")` before iterable
validation, including the mixed positional-plus-keyword analogue path
`chain.from_iterable(rows, { iterable: other })` that previously fell through
to the raw one-argument arity error and later-keyword-over-arity paths such as
`chain.from_iterable(rows, 2, { extra: 1 })` that now also keep Python's
no-keyword priority instead of falling through to the raw three-argument arity
error. Covered split keyword duplicate priority
now also matches local Python 3.10.11, so
`stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 })` raises
`TypeError("chain.from_iterable() got multiple values for keyword argument
'extra'")` before the later no-keyword branch. Covered plain callable `Object` values now
also stay off that keyword-analogue path, so
`chain.from_iterable(plain_callable_obj)` raises Python's observable
non-iterable `TypeError(...)` and
`chain.from_iterable(rows, plain_callable_obj)` keeps the exact
`chain.from_iterable() takes exactly one argument (2 given)` arity error.
Covered direct and
`from_iterable(...)` chain objects also expose Python-style
`<itertools.chain object at 0x...>` `__Repr()` text. Covered iterator objects
for `accumulate`, `compress`, `cycle`, `islice`, `pairwise`, `product`,
`zip_longest`, `groupby`, groupby `_grouper`, `combinations`,
`combinations_with_replacement`, `permutations`, `starmap`, `takewhile`,
`dropwhile`, and `filterfalse` now also expose the matching Python-style
`<itertools.name object at 0x...>` `__Repr()` shape while preserving existing
lazy iteration state. Covered
`accumulate(...)` now follows Python's lazy running-total behavior for default
addition, optional `initial`, empty iterables, and callable operator injection.
The public AHK surface also accepts an options-object analogue for Python's
keyword-only `initial`, such as `accumulate(iterable, { initial: value })` or
`accumulate(iterable, stdlib.None, { initial: value })`, while non-iterable
sources are validated at construction and non-callable accumulation functions
surface Python-style `TypeError` messages only when a merge step is consumed,
after Python-compatible first-item or `initial` emission. Covered
`compress(data, selectors)` now
follows Python's lazy truth-filtering behavior using shared stdlib truthiness
for selectors, including root `stdlib.True` / `stdlib.False`, empty arrays, and
empty maps, stops when either iterator is exhausted, preserves iterator
position across consumers, validates data first and selectors second at
construction without pre-consuming valid iterables, and reuses the same
Python-style non-iterable type-name parity on both sides.
Covered `pairwise(iterable)` now follows Python 3.10.11 by yielding lazy
overlapping root tuple pairs, returning empty results for zero- or one-item
iterables, preserving iterator position across multiple consumers, validating
non-iterable inputs at construction without pre-consuming valid iterables, and
reusing the same Python-style non-iterable type-name parity as the other shared
iterable validators. Covered argument parsing now also rejects the AHK keyword
analogue path, so calls like `stdlib.itertools.pairwise({ iterable: rows })`,
generic property-object shapes such as
`stdlib.itertools.pairwise({ extra: 1, another: 2 })`, and mixed
positional-plus-keyword analogues such as
`stdlib.itertools.pairwise([1, 2], { iterable: [3, 4] })` or
`stdlib.itertools.pairwise([1, 2], { extra: 1 })` now all raise Python's
observable `TypeError("pairwise() takes no keyword arguments")` instead of
falling through to the generic object-not-iterable path or leaking raw AHK
too-many-parameters behavior. Covered sentinel-position priority now also
matches Python 3.10.11 so `stdlib.itertools.pairwise(stdlib.None)` and
`stdlib.itertools.pairwise(stdlib.NotImplemented)` keep the shared
non-iterable `NoneType` / `NotImplementedType` errors, while
`stdlib.itertools.pairwise([1, 2], stdlib.None)` still raises
`TypeError("pairwise expected 1 argument, got 2")` as an extra positional
argument rather than being misclassified as a keyword analogue. Covered plain
callable `Object` values that define their own `Call` now also stay positional
even when they carry keyword-like own properties such as `iterable` or `extra`,
so `stdlib.itertools.pairwise(callable_obj)` surfaces Python's iterable
`TypeError`, while `stdlib.itertools.pairwise(rows, callable_obj)` keeps
Python's one-argument arity error instead of falling into the AHK no-keyword
path.
Covered `product(*iterables)` now follows Python 3.10.11 default `repeat=1`
behavior by materializing all input pools at construction, yielding readonly
root tuple rows in lexicographic order with the rightmost iterable advancing
fastest, returning one empty tuple row for zero input iterables, returning empty
when any materialized pool is empty, preserving iterator position across
consumers, and surfacing Python-style non-iterable type names for covered
invalid inputs. The current direct slice also covers an AHK options-object
analogue for Python's keyword-only `repeat`, using
`product(iterable1, { repeat: n })` to duplicate the input pools, including
Python-style `repeat=0`, root-bool repeat, invalid-repeat error behavior, and
the covered duplicate-keyword analogue
`stdlib.itertools.product([1, 2], { repeat: 2, iterables: "x" })`, which now
raises Python 3.10.11's `TypeError("product() takes at most 1 keyword argument (2 given)")`
instead of being accepted silently by the wrapper. The covered single-invalid-
keyword analogue `stdlib.itertools.product({ iterables: "x" })` now also raises
Python 3.10.11's `TypeError("'iterables' is an invalid keyword argument for product()")`
instead of falling through to `"'object' object is not iterable"`. Generic
plain-property-object shapes such as `stdlib.itertools.product({ extra: 1 })`
and `stdlib.itertools.product([1], { extra: 1 })` now also raise Python
3.10.11's `TypeError("'extra' is an invalid keyword argument for product()")`
instead of falling through to that same non-iterable fallback.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry their own `repeat` property, so shapes such as
`stdlib.itertools.product([1], iterable_obj)` mirror local Python 3.10.11
instead of misclassifying the trailing iterable as a keyword analogue.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as
`repeat`, `iterables`, `fillvalue`, or `extra`, so
`stdlib.itertools.product(callable_obj)`,
`stdlib.itertools.product([1], callable_obj)`,
`stdlib.itertools.zip_longest(callable_obj)`, and
`stdlib.itertools.zip_longest([1], callable_obj)` now all surface Python's
observable non-iterable `TypeError(...)` instead of being reclassified as AHK
keyword-analogue wrappers or silently consumed as trailing keyword options.
Covered AHK split trailing options-object analogues now also aggregate their
plain-object keyword payloads before validation, following the same observable
Python 3.10.11 keyword-count priority as equivalent direct probes such as
`product([1], repeat=2, extra=1)` and `product(repeat=2, extra=1)`. Shapes
such as `stdlib.itertools.product([1], { repeat: 2 }, { extra: 1 })`,
`stdlib.itertools.product({ repeat: 2 }, { extra: 1 })`, and
`stdlib.itertools.product([1], { extra: 1 }, { repeat: 2 })` now all raise
Python's `TypeError("product() takes at most 1 keyword argument (2 given)")`
instead of misclassifying only the final object and surfacing a single-invalid-
keyword or wrapped-object non-iterable fallback. Split trailing keyword-wrapper
duplicates now also follow Python's multi-`**` merge priority ahead of that
keyword-count branch, so shapes such as `stdlib.itertools.product([1], {
repeat: 2 }, { repeat: 3 })`, `stdlib.itertools.product({ repeat: 2 }, {
repeat: 3 })`, and `stdlib.itertools.product([1], { extra: 1 }, { extra: 2 })`
raise `TypeError("itertools.product() got multiple values for keyword argument '...'")`
before later keyword-count handling.
Covered `zip_longest(*iterables)` now follows Python 3.10.11 default
`fillvalue=None` behavior by creating input iterators without materializing or
pre-consuming sources at construction, yielding readonly root tuple rows until
the longest input is exhausted, filling shorter inputs with root `stdlib.None`,
returning empty for zero input iterables, preserving iterator position across
consumers, and surfacing Python-style non-iterable type names for covered
invalid inputs. The current direct slice also covers an AHK options-object
analogue for Python's keyword-only `fillvalue`, using
`zip_longest(iterable1, iterable2, { fillvalue: value })` to fill shorter
inputs with the supplied value. The covered duplicate-keyword analogue
`stdlib.itertools.zip_longest([1, 2], [3], { fillvalue: "X", iterables: "Y" })`
now also raises Python 3.10.11's
`TypeError("zip_longest() got an unexpected keyword argument")` instead of
being accepted silently by the wrapper. The covered single-invalid-key
analogue `stdlib.itertools.zip_longest({ iterables: "x" })` now also raises
that same Python 3.10.11 `TypeError("zip_longest() got an unexpected keyword argument")`
instead of falling through to `"'object' object is not iterable"`. Generic
plain-property-object shapes such as `stdlib.itertools.zip_longest({ extra: 1 })`
and `stdlib.itertools.zip_longest([1], { extra: 1 })` now also raise that same
Python 3.10.11 `TypeError("zip_longest() got an unexpected keyword argument")`
instead of falling through to that same non-iterable fallback.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry their own `fillvalue` property, so shapes such
as `stdlib.itertools.zip_longest([1], iterable_obj)` mirror local Python
3.10.11 instead of misclassifying the trailing iterable as a keyword analogue.
Covered AHK split trailing options-object analogues now also aggregate their
plain-object keyword payloads before validation, following the same observable
Python 3.10.11 unexpected-keyword result as direct probes such as
`zip_longest([1], fillvalue="X", extra=1)` and
`zip_longest(fillvalue="X", extra=1)`. Shapes such as
`stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { extra: 1 })`,
`stdlib.itertools.zip_longest({ fillvalue: "X" }, { extra: 1 })`, and
`stdlib.itertools.zip_longest([1], { extra: 1 }, { fillvalue: "X" })` now all
raise Python's `TypeError("zip_longest() got an unexpected keyword argument")`
instead of treating the earlier options object as a positional iterable and
falling through to `"'object' object is not iterable"`. Split trailing
keyword-wrapper duplicates now also follow Python's multi-`**` merge priority
ahead of that unexpected-keyword branch, so shapes such as
`stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { fillvalue: "Y" })`,
`stdlib.itertools.zip_longest({ fillvalue: "X" }, { fillvalue: "Y" })`, and
`stdlib.itertools.zip_longest([1], { extra: 1 }, { extra: 2 })` raise
`TypeError("itertools.zip_longest() got multiple values for keyword argument '...'")`
before later unexpected-keyword handling.
Covered `groupby(iterable, key := None)` now follows Python 3.10.11 by creating
the source iterator without pre-consuming it at construction, grouping
consecutive equal keys, treating omitted or explicit `stdlib.None` key as the
identity key, supporting covered callable keys and an AHK options-object
analogue for Python's keyword-style `key`, using
`groupby(iterable, { key: callable_or_None })`, returning `(key, group)` rows
as readonly root tuples, sharing source state between the outer iterator and
group iterators so advancing the outer iterator invalidates older unfinished
groups, and surfacing Python-style non-iterable and delayed non-callable-key
errors for covered invalid inputs.
Covered `combinations(iterable, r)` now follows Python 3.10.11 by
materializing the input pool at construction, yielding readonly root tuple rows
in lexicographic index order, preserving iterator position across consumers,
supporting `r=0`, oversized `r`, native bool-as-int `r`, and root
`stdlib.True` / `stdlib.False` `r` values, validating integer-interpretation
errors before iterable materialization, and surfacing
Python-style non-iterable and negative-`r` errors for covered inputs.
Covered `combinations_with_replacement(iterable, r)` now follows Python 3.10.11
by requiring the `r` argument, materializing the input pool at construction,
yielding readonly root tuple rows in lexicographic order with repeated element
positions, preserving iterator position across consumers, supporting `r=0`,
oversized `r`, native bool-as-int `r`, root `stdlib.True` / `stdlib.False` `r`
values, and empty-pool edge cases, validating integer-interpretation errors
before iterable materialization, and surfacing Python-style non-iterable and
negative-`r` errors for covered inputs.
Covered `permutations(iterable, r := None)` now follows Python 3.10.11 by
materializing the input pool at construction, treating omitted or explicit
`stdlib.None` `r` as the full pool length, yielding readonly root tuple rows in
lexicographic index order, preserving iterator position across consumers,
supporting `r=0`, oversized `r`, native bool-as-int `r`, and root
`stdlib.True` / `stdlib.False` `r` values, validating the iterable before `r`
for covered invalid inputs, and surfacing Python's `Expected int as r` and
negative-`r` messages after successful materialization.
The covered combinations-family wrappers now also keep plain iterable objects
with their own keyword-like props such as `iterable`, `r`, or `extra`
positional when those objects define `__Enum`, so
`combinations(iterable_obj, 1)`,
`combinations_with_replacement(iterable_obj, 1)`, and
`permutations(iterable_obj, 1)` enumerate their real values while
`combinations("ab", iterable_obj)` / `combinations_with_replacement("ab",
iterable_obj)` still raise Python's integer-interpretation TypeError and
`permutations("ab", iterable_obj)` still raises the covered `Expected int as r`
path instead of misclassifying those iterable objects as keyword syntax.
Covered `starmap(func, iterable)` now follows Python 3.10.11 by lazily
materializing each iterable row into positional call arguments, preserving
iterator position across multiple consumers, accepting string rows as
character arguments for covered callables, and reusing the shared
Python-style callable and non-iterable type-name parity for invalid inputs.
Covered non-callable `func` values are validated only when the iterator is
consumed, after the current argument row is materialized, including `int` and
root `stdlib.None` function cases, while non-iterable outer inputs are still
rejected at construction before any callable validation. Covered argument
parsing also now matches Python's no-keyword rejection on the AHK keyword
analogue path, including options-only property objects such as
`stdlib.itertools.starmap({ extra: 1, another: 2 })`, second-argument
property-object shapes such as
`stdlib.itertools.starmap(func, { extra: 1 })`, and a third argument such as
`{ iterable: ... }` after the two positional arguments, which now all raise
`TypeError("starmap() takes no keyword arguments")` instead of falling through
to raw arity or generic object-not-iterable errors.
Covered plain `Object` callables that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `function` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax. Covered plain callable second-argument
values such as `stdlib.itertools.starmap(func, callable_obj)` now likewise stay
positional and surface Python's non-iterable `TypeError`, while extra
positional callable third arguments such as `stdlib.itertools.starmap(func,
rows, callable_obj)` keep Python's exact-two-arguments arity error instead of
falling into the AHK no-keyword analogue path.
Covered `takewhile(predicate, iterable)` now follows Python 3.10.11 by lazily
yielding items while predicate results are true under shared stdlib truthiness,
including root `stdlib.True` / `stdlib.False`, empty arrays, empty maps, and
`stdlib.None`, preserving iterator position across consumers, accepting covered
string iterables, validating non-iterable inputs at construction, and surfacing
non-callable predicate errors only when consumed, including covered `int` and
root `stdlib.None` predicate cases. Covered non-iterable inputs are rejected at
construction before predicate callable validation, including the bad-predicate
plus bad-iterable priority case observed in local Python 3.10.11. Covered
argument parsing now also rejects the AHK keyword analogue path, so calls like
`stdlib.itertools.takewhile(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.takewhile(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.takewhile(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("takewhile() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `dropwhile(predicate, iterable)` now follows Python 3.10.11 by lazily
discarding items while the predicate is true, yielding the first false item and
all remaining items without calling the predicate again, preserving iterator
position across consumers, accepting covered string iterables, validating
non-iterable inputs at construction, surfacing non-callable predicate errors
only when consumed, and now rejecting the AHK keyword analogue path so calls
like `stdlib.itertools.dropwhile(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.dropwhile(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.dropwhile(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("dropwhile() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `filterfalse(predicate, iterable)` now follows Python 3.10.11 by
lazily yielding items where the predicate is false, using `stdlib.None` as the
Python `None` predicate to apply shared stdlib truthiness directly to each
item, preserving iterator position across consumers, validating non-iterable
inputs at construction, surfacing non-callable predicate errors only when the
iterator is consumed, and now rejecting the AHK keyword analogue path so calls
like `stdlib.itertools.filterfalse(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.filterfalse(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.filterfalse(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("filterfalse() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `cycle(iterable)` now also rejects the AHK keyword analogue path, so
calls like `stdlib.itertools.cycle({ iterable: rows })`,
`stdlib.itertools.cycle({ extra: 1, another: 2 })`, and
`stdlib.itertools.cycle(rows, { iterable: other })` raise Python's observable
`TypeError("cycle() takes no keyword arguments")` instead of falling through
to the raw iterable-type error for the first object argument, and now also
keeps plain `Object` iterables with their own `__Enum` accepted even when they
carry a keyword-like own `iterable` property, matching local Python 3.10.11's
behavior for real iterable instances versus keyword syntax. Covered plain
callable `Object` values with keyword-like own properties are now likewise kept
off the keyword-analogue path, so `cycle(plain_callable_obj)` raises Python's
observable non-iterable `TypeError(...)` and `cycle(rows, plain_callable_obj)`
keeps Python's exact-one-argument arity error instead of being misclassified as
keyword syntax. Covered split keyword duplicate priority now also matches local
Python 3.10.11, so `stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })`
raises `TypeError("itertools.cycle() got multiple values for keyword argument
'extra'")` before the later no-keyword or arity branch. Covered later-keyword
priority now also matches local Python 3.10.11, so
`stdlib.itertools.cycle(rows, 3, { extra: 1 })` raises
`TypeError("cycle() takes no keyword arguments")` before the raw
three-argument arity branch, and now also
matches Python 3.10.11's exact-one-argument call-shape messages so
`stdlib.itertools.cycle()` and `stdlib.itertools.cycle(rows, 3)` raise
`TypeError("cycle expected 1 argument, got N")` instead of leaking AutoHotkey's
raw missing-parameter error or misclassifying extra positional arguments as
keyword analogues.
Covered `count(start := 0, step := 1)` now also matches Python 3.10.11's
three-argument duplicate-start boundary, so
`stdlib.itertools.count(1, 2, { start: 3 })` raises
`TypeError("count() takes at most 2 arguments (3 given)")` instead of leaking
AutoHotkey's raw too-many-parameters error, and the covered extra-key analogue
`stdlib.itertools.count({ step: 2, extra: 3 })` now raises Python 3.10.11's
`TypeError("'extra' is an invalid keyword argument for count()")` instead of
silently ignoring the unexpected field.
Covered split plain-property keyword analogues now also follow Python 3.10.11's
observable keyword behavior, so
`stdlib.itertools.count({ start: 3 }, { step: 2 })` and
`stdlib.itertools.count({ step: 2 }, { start: 3 })` now yield the same rows as
Python `count(start=3, step=2)` instead of dropping the second options object
and falling through to `a number is required`. Options-only and split invalid-
keyword analogues such as `stdlib.itertools.count({ extra: 3 })`,
`stdlib.itertools.count({ start: 1 }, { extra: 3 })`, and
`stdlib.itertools.count({ step: 2 }, { extra: 3 })` now likewise raise Python's
`TypeError("'extra' is an invalid keyword argument for count()")` instead of
escaping into numeric coercion failures, while higher-cardinality split shapes
such as `stdlib.itertools.count({ start: 1 }, { step: 2, extra: 3 })` and
`stdlib.itertools.count({ start: 1, extra: 3 }, { step: 2 })` now raise
Python's `TypeError("count() takes at most 2 keyword arguments (3 given)")`
instead of miscounting the two plain objects as a positional value plus a
single keyword wrapper.
Covered plain callable `Object` values that define their own `Call` now also
stay on Python's numeric-validation path even when they carry keyword-like own
properties such as `start` or `step`, so
`stdlib.itertools.count(callable_obj)` and
`stdlib.itertools.count(0, callable_obj)` now still raise Python's observable
`TypeError("a number is required")` instead of being misclassified as AHK
keyword-analogue wrappers.
Covered `groupby(iterable, key := unset)` now also accepts Python 3.10.11's
`iterable=` keyword path through the AHK options-object analogue, so calls
like `stdlib.itertools.groupby({ iterable: rows })` and
`stdlib.itertools.groupby({ iterable: rows, key: keyfunc })` now materialize
the same lazy grouped output as Python instead of falling through to the raw
`'object' object is not iterable` failure on the wrapper object itself.
The covered options-only analogue path now also matches Python 3.10.11's
missing-required-argument wording: `stdlib.itertools.groupby({ key:
callable })` now raises `groupby() missing required argument 'iterable'
(pos 1)` instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
Generic plain-property-object shapes such as `stdlib.itertools.groupby({
extra: 1 })` now also preserve that same Python 3.10.11 missing-`iterable`
priority instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
The covered single-extra-key analogue path
`stdlib.itertools.groupby({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for groupby()`
instead of being misclassified as a too-many-keyword error.
The covered extra-key analogue path
`stdlib.itertools.groupby({ iterable: rows, key: callable, extra: 1 })` now
also raises Python 3.10.11's `groupby() takes at most 2 keyword arguments
(3 given)` instead of silently accepting the unexpected field.
The covered duplicate-key analogue path
`stdlib.itertools.groupby(rows, keyfunc, { key: other })` now also raises
Python 3.10.11's `groupby() takes at most 2 arguments (3 given)` instead of
leaking AutoHotkey's raw too-many-parameters error.
Covered split plain-property keyword analogues now also follow Python 3.10.11's
observable keyword behavior, so
`stdlib.itertools.groupby({ key: keyfunc }, { iterable: rows })` now yields
the same grouped rows as Python `groupby(key=keyfunc, iterable=rows)` instead
of stopping early at the missing-`iterable` branch. Split shapes such as
`stdlib.itertools.groupby({ extra: 1 }, { iterable: rows })` now likewise
raise Python's `'extra' is an invalid keyword argument for groupby()`, while
`stdlib.itertools.groupby({ key: keyfunc }, { extra: 1 })` preserves Python's
missing-`iterable` priority and
`stdlib.itertools.groupby({ key: keyfunc }, { iterable: rows, extra: 1 })`
raises Python's `groupby() takes at most 2 keyword arguments (3 given)`
instead of misclassifying the second plain object as a positional value
wrapper. Split keyword-wrapper duplicates now also follow Python's multi-`**`
merge priority, so `stdlib.itertools.groupby({ iterable: rows }, {
iterable: other_rows })` raises `itertools.groupby() got multiple values for
keyword argument 'iterable'`, while three-way shapes such as
`stdlib.itertools.groupby({ iterable: rows }, { key: keyfunc }, { key:
other_key })` and `stdlib.itertools.groupby({ extra: 1 }, { extra: 2 }, {
iterable: rows })` raise the corresponding duplicate-keyword branch ahead of
later keyword-count handling.
Positional-plus-keyword-analogue shapes such as
`stdlib.itertools.groupby(rows, { extra: 1 })`,
`stdlib.itertools.groupby(rows, { iterable: other_rows })`, and
`stdlib.itertools.groupby(rows, { key: keyfunc, extra: 1 })` now also raise
the same invalid-keyword, duplicate-name, and too-many-arguments Python
`TypeError(...)` forms instead of silently accepting or misclassifying the
wrapped object.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as
`iterable`, `key`, or `extra`, so `stdlib.itertools.groupby(callable_obj)`
surfaces Python's iterable `TypeError` while
`stdlib.itertools.groupby(rows, callable_obj)` still uses the callable as the
lazy key function instead of misclassifying it as a keyword-analogue wrapper.
Covered plain iterable `Object` values that define their own `__Enum` now also
stay positional when they are passed in the second `key` slot, even if they
carry keyword-like own properties such as `key`, `iterable`, or `extra`, so
`stdlib.itertools.groupby(rows, iterable_obj)` now mirrors Python 3.10.11's
lazy `TypeError("'object' object is not callable")` path instead of being
misclassified as an AHK keyword-analogue wrapper and failing during argument
parsing.
Covered `compress(data, selectors)` now also accepts Python 3.10.11's covered
keyword-capable paths through the AHK options-object analogue, so calls like
`stdlib.itertools.compress(rows, { selectors: mask })` and
`stdlib.itertools.compress({ data: rows, selectors: mask })` now yield the
same filtered output and surface the same non-iterable `TypeError` timing for
covered invalid `data`/`selectors` inputs instead of failing on the wrapper
object shape itself. The covered missing-`selectors` keyword shape
`stdlib.itertools.compress({ data: rows })` now also raises Python 3.10.11's
`compress() missing required argument 'selectors' (pos 2)` instead of leaking a
raw AHK `UnsetError`. The covered missing-`selectors`-plus-extra-key analogue
`stdlib.itertools.compress({ data: rows, extra: 1 })` now also preserves that
same Python priority instead of being misclassified as a too-many-keyword
error. The covered duplicate-selector-keyword shape
`stdlib.itertools.compress({ selectors: mask })` now also raises Python
3.10.11's `compress() missing required argument 'data' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. The covered duplicate-selector-keyword shape
`stdlib.itertools.compress({ extra: 1 })` now also preserves that same
missing-`data` priority instead of being misclassified as a missing-selectors
wrapper error. Positional-plus-keyword-analogue shapes such as
`stdlib.itertools.compress(rows, { extra: 1 })`,
`stdlib.itertools.compress(rows, { data: other_rows })`,
`stdlib.itertools.compress(rows, { selectors: mask, extra: 1 })`, and
`stdlib.itertools.compress(rows, { data: other_rows, selectors: mask })` now
also raise the same missing-`selectors` and too-many-arguments Python
`TypeError(...)` forms instead of silently accepting or misclassifying the
wrapped object.
The covered duplicate-selector-keyword shape
`stdlib.itertools.compress(rows, mask, { selectors: other_mask })` now also
raises Python 3.10.11's `compress() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw too-many-parameters error.
The covered extra-key analogue shape
`stdlib.itertools.compress({ data: rows, selectors: mask, extra: 1 })` now
also raises Python 3.10.11's `compress() takes at most 2 keyword arguments
(3 given)` instead of silently accepting the unexpected field. Covered plain
iterable `Object` instances that define their own `__Enum` are now also kept on
the positional iterable path even when they carry keyword-like own properties
such as `data` or `selectors`, so
`stdlib.itertools.compress(plain_data_obj, mask)`,
`stdlib.itertools.compress(rows, plain_selectors_obj)`, and
`stdlib.itertools.compress(plain_data_obj, plain_selectors_obj)` now match
local Python 3.10.11 instead of being misclassified as keyword-analogue
wrapper objects. Covered plain callable `Object` values that define their own
`Call` now also stay positional even when they carry keyword-like own
properties such as `data` or `selectors`, so
`stdlib.itertools.compress(callable_obj, mask)` and
`stdlib.itertools.compress(rows, callable_obj)` both surface Python's iterable
`TypeError` instead of being misclassified as keyword-analogue wrappers.
Covered `combinations(iterable, r)` now also accepts Python 3.10.11's covered
`r=` and `iterable=` keyword-capable paths through the AHK options-object
analogue, so calls like `stdlib.itertools.combinations(rows, { r: 2 })` and
`stdlib.itertools.combinations({ iterable: rows, r: 2 })` now yield the same
combination rows as Python and still surface the covered
`'str' object cannot be interpreted as an integer` `TypeError` timing for
invalid `r` values instead of misrouting the wrapper object into the numeric
slot. The covered options-only analogue path
`stdlib.itertools.combinations({ r: 2 })` now also raises Python 3.10.11's
`combinations() missing required argument 'iterable' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. Generic plain-property-object shapes such as
`stdlib.itertools.combinations({ extra: 1 })` and
`stdlib.itertools.combinations({ r: 2, extra: 1 })` now also preserve that
same missing-`iterable` priority, while higher-cardinality plain keyword-
analogue shapes such as `stdlib.itertools.combinations({ extra: 1, another:
2, third: 3 })` and `stdlib.itertools.combinations({ iterable: rows, extra:
1, another: 2 })` now raise Python 3.10.11's
`combinations() takes at most 2 keyword arguments (3 given)` instead of
collapsing to the same missing-required-argument fallback.
The covered iterable-plus-extra analogue path
`stdlib.itertools.combinations({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `combinations() missing required argument 'r' (pos 2)`
instead of falling through to an AutoHotkey `UnsetError` from the missing
wrapped `r` slot. The covered iterable-plus-`r`-plus-extra analogue
`stdlib.itertools.combinations({ iterable: rows, r: 2, extra: 1 })` now also
raises Python 3.10.11's `combinations() takes at most 2 keyword arguments (3
given)` instead of silently accepting the unexpected field. The covered
duplicate iterable analogue path
`stdlib.itertools.combinations(rows, { iterable: other_rows })` now also
raises Python 3.10.11's `combinations() missing required argument 'r' (pos
2)` instead of misrouting the second options object into the wrapped `r`
slot and surfacing `"'object' object cannot be interpreted as an integer"`.
Additional second-argument property-object shapes such as
`stdlib.itertools.combinations(rows, { extra: 1 })` now also preserve that
same missing-`r` priority, while shapes such as
`stdlib.itertools.combinations(rows, { r: 2, extra: 1, another: 2 })` now
surface Python's dynamic given-count form
`combinations() takes at most 2 arguments (4 given)` instead of collapsing
distinct multi-key cases into the same fixed three-argument wrapper error.
The covered three-argument duplicate-binding analogue
`stdlib.itertools.combinations(rows, 2, { iterable: other_rows })` now also
raises Python 3.10.11's `combinations() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.combinations(rows, { r: 1, extra: 1 })` now also
raises Python 3.10.11's `combinations() takes at most 2 arguments (3 given)`
instead of silently unwrapping the second object and discarding its unexpected
field. The current wrapper now also merges covered split plain-object keyword
analogues across both argument slots before validation, so
`stdlib.itertools.combinations({ iterable: rows }, { r: 2 })` and
`stdlib.itertools.combinations({ r: 2 }, { iterable: rows })` yield the same
rows as local Python `combinations(iterable=rows, r=2)`, while split error
priority shapes such as `stdlib.itertools.combinations({ extra: 1 }, {
iterable: rows })` and `stdlib.itertools.combinations({ r: 2 }, {
iterable: rows, extra: 1 })` now follow Python's missing-`r` and
too-many-keywords branches instead of stopping early at the first wrapper
object.
Covered `combinations_with_replacement(iterable, r)` now also accepts Python
3.10.11's covered `r=` and `iterable=` keyword-capable paths through the AHK
options-object analogue, so calls like
`stdlib.itertools.combinations_with_replacement(rows, { r: 2 })` and
`stdlib.itertools.combinations_with_replacement({ iterable: rows, r: 2 })`
now yield the same replacement-combination rows as Python and still surface
the covered `'str' object cannot be interpreted as an integer` `TypeError`
timing for invalid `r` values instead of misrouting the wrapper object into
the numeric slot. The covered options-only analogue path
`stdlib.itertools.combinations_with_replacement({ r: 2 })` now also raises
Python 3.10.11's `combinations_with_replacement() missing required argument
'iterable' (pos 1)` instead of falling through to the wrong missing-`r`
wrapper failure. Generic plain-property-object shapes such as
`stdlib.itertools.combinations_with_replacement({ extra: 1 })` now also
preserve that same missing-`iterable` priority, while higher-cardinality
plain keyword-analogue shapes such as
`stdlib.itertools.combinations_with_replacement({ extra: 1, another: 2,
third: 3 })` now raise Python 3.10.11's
`combinations_with_replacement() takes at most 2 keyword arguments (3 given)`
instead of collapsing to the same missing-`iterable` fallback.
The covered duplicate iterable analogue path
`stdlib.itertools.combinations_with_replacement(rows, { iterable: other_rows })`
now also raises Python 3.10.11's
`combinations_with_replacement() missing required argument 'r' (pos 2)`
instead of misrouting the second options object into the wrapped `r` slot
and surfacing `"'object' object cannot be interpreted as an integer"`. The
covered iterable-plus-`r`-plus-extra analogue
`stdlib.itertools.combinations_with_replacement({ iterable: rows, r: 2,
extra: 1 })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 keyword arguments (3 given)`
instead of silently accepting the unexpected field. The
covered three-argument duplicate-binding analogue
`stdlib.itertools.combinations_with_replacement(rows, 2, { iterable:
other_rows })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 arguments (3 given)` instead
of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.combinations_with_replacement(rows, { r: 1, extra:
1 })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 arguments (3 given)` instead
of silently unwrapping the second object and discarding its unexpected field.
Additional second-argument property-object shapes such as
`stdlib.itertools.combinations_with_replacement(rows, { extra: 1 })` now also
preserve Python's missing-`r` priority, while shapes such as
`stdlib.itertools.combinations_with_replacement(rows, { r: 2, extra: 1,
another: 2 })` now surface Python's dynamic given-count form
`combinations_with_replacement() takes at most 2 arguments (4 given)` instead
of collapsing distinct multi-key cases into the same fixed three-argument
wrapper error. The current wrapper now also merges covered split plain-object
keyword analogues across both argument slots before validation, so
`stdlib.itertools.combinations_with_replacement({ iterable: rows }, { r: 2 })`
and `stdlib.itertools.combinations_with_replacement({ r: 2 }, {
iterable: rows })` yield the same rows as local Python
`combinations_with_replacement(iterable=rows, r=2)`, while split error
priority shapes such as `stdlib.itertools.combinations_with_replacement({
extra: 1 }, { iterable: rows })` and
`stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: rows,
extra: 1 })` now follow Python's missing-`r` and too-many-keywords branches
instead of misclassifying the second wrapper object as a positional `r` value.
Covered `permutations(iterable, r := None)` now also accepts Python 3.10.11's
covered `r=` and `iterable=` keyword-capable paths through the AHK
options-object analogue, so calls like
`stdlib.itertools.permutations(rows, { r: 2 })` and
`stdlib.itertools.permutations({ iterable: rows, r: 2 })` now yield the same
permutation rows as Python and still surface the covered `Expected int as r`
`TypeError` timing for invalid `r` values instead of misrouting the wrapper
object into the numeric slot. The covered options-only analogue path
`stdlib.itertools.permutations({ r: 2 })` now also raises Python 3.10.11's
`permutations() missing required argument 'iterable' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. The covered single-invalid-key analogue path
`stdlib.itertools.permutations({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for permutations()`
instead of falling through to the raw wrapped-object `'object' object is not
iterable'` failure. The covered duplicate iterable analogue path
`stdlib.itertools.permutations(rows, { iterable: other_rows })` now also
raises Python 3.10.11's `argument for permutations() given by name
('iterable') and position (1)` instead of misrouting the second options
object into the wrapped `r` slot and surfacing `Expected int as r`. The
covered three-argument duplicate-binding analogue
`stdlib.itertools.permutations(rows, 2, { iterable: other_rows })` now also
raises Python 3.10.11's `permutations() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.permutations(rows, { r: 1, extra: 1 })` now also
raises Python 3.10.11's `permutations() takes at most 2 arguments (3 given)`
instead of silently unwrapping the second object and discarding its unexpected
field. Generic plain-property-object shapes such as
`stdlib.itertools.permutations({ extra: 1 })` and
`stdlib.itertools.permutations({ r: 2, extra: 1 })` now also preserve Python
3.10.11's missing-`iterable` priority, while higher-cardinality plain keyword-
analogue shapes such as
`stdlib.itertools.permutations({ extra: 1, another: 2, third: 3 })` now raise
Python 3.10.11's `permutations() takes at most 2 keyword arguments (3 given)`
instead of collapsing to missing-required-argument fallbacks. Additional
second-argument property-object shapes such as
`stdlib.itertools.permutations(rows, { extra: 1 })` now also raise Python
3.10.11's `'extra' is an invalid keyword argument for permutations()`, while
shapes such as `stdlib.itertools.permutations(rows, { r: 2, extra: 1,
another: 2 })` now surface Python's dynamic given-count form
`permutations() takes at most 2 arguments (4 given)` instead of collapsing
distinct multi-key cases into the same fixed three-argument wrapper error. The
current wrapper now also merges covered split plain-object keyword analogues
across both argument slots before validation, so
`stdlib.itertools.permutations({ iterable: rows }, { r: 2 })` and
`stdlib.itertools.permutations({ r: 2 }, { iterable: rows })` yield the same
rows as local Python keyword calls, while split error-priority shapes such as
`stdlib.itertools.permutations({ extra: 1 }, { iterable: rows })`,
`stdlib.itertools.permutations({ iterable: rows }, { extra: 1 })`, and
`stdlib.itertools.permutations({ r: 2 }, { iterable: rows, extra: 1 })` now
follow Python's invalid-keyword and too-many-keywords branches instead of
misclassifying the second wrapper object as a positional `r` value.
Covered plain callable `Object` values that define their own `Call` now also
stay positional across `combinations(...)`,
`combinations_with_replacement(...)`, and `permutations(...)` even when they
carry keyword-like own properties such as `iterable` or `r`, so callable first
arguments still surface Python's iterable `TypeError` and callable second
arguments still stay on each function's integer-interpretation path instead of
being misclassified as AHK keyword-analogue wrappers.
Covered `accumulate(iterable, func := unset, initial := unset)` now also
accepts Python 3.10.11's covered `iterable=` / `func=` / `initial=` keyword
paths through the AHK options-object analogue, so calls like
`stdlib.itertools.accumulate({ iterable: rows })`,
`stdlib.itertools.accumulate(rows, { func: callable })`, and
`stdlib.itertools.accumulate({ iterable: rows, func: callable, initial: 10 })`
now yield the same accumulated output as Python, while mixed positional plus
`iterable=` duplicate binding raises the covered
`argument for accumulate() given by name ('iterable') and position (1)`
`TypeError` instead of falling through to raw object-iterable failures. The
covered duplicate `func=` shape
`stdlib.itertools.accumulate(rows, callable, { func: other_callable })` now
also raises Python 3.10.11's
`argument for accumulate() given by name ('func') and position (2)` instead of
misrouting the third options object into the `initial` slot.
Covered split keyword-wrapper duplicates now also follow Python 3.10.11's
multi-`**` merge priority before later positional/name and invalid-keyword
branches, so shapes such as
`stdlib.itertools.accumulate(rows, { func: callable }, { func: other_callable })`,
`stdlib.itertools.accumulate(rows, { initial: 10 }, { initial: 11 })`, and
`stdlib.itertools.accumulate(rows, { extra: 1 }, { extra: 2 })` raise
`TypeError("itertools.accumulate() got multiple values for keyword argument '...'")`
first. Mixed shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, extra: 1 }, { func: other_callable })`
and
`stdlib.itertools.accumulate(rows, { initial: 10, extra: 1 }, { initial: 11 })`
keep that same duplicate-name priority ahead of later invalid-keyword
handling.
The covered options-only analogue path now also matches Python 3.10.11's
missing-required-argument wording: `stdlib.itertools.accumulate({ func:
callable })` now raises `accumulate() missing required argument 'iterable'
(pos 1)` instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
The covered single-extra-key analogue path
`stdlib.itertools.accumulate({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for accumulate()`
instead of being misclassified as a too-many-keyword error.
The covered extra-key analogue path
`stdlib.itertools.accumulate({ iterable: rows, func: callable, initial: 10,
extra: 1 })` now also raises Python 3.10.11's `accumulate() takes at most 3
keyword arguments (4 given)` instead of silently accepting the unexpected
field.
Covered plain property-object and positional-plus-second-object analogue paths
now also preserve Python 3.10.11's keyword-priority behavior. Options-only
shapes such as `stdlib.itertools.accumulate({ extra: 1 })` now keep Python's
missing-`iterable` priority instead of falling through to
`'object' object is not iterable`, while higher-cardinality options-only
shapes such as
`stdlib.itertools.accumulate({ extra: 1, another: 2, third: 3, fourth: 4 })`
now raise Python's observable
`accumulate() takes at most 3 keyword arguments (4 given)`. Covered
second-argument property-object shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, extra: 1 })` and
`stdlib.itertools.accumulate(rows, { initial: 10, extra: 1 })` now also raise
Python 3.10.11's `'extra' is an invalid keyword argument for accumulate()`,
while higher-cardinality shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, initial: 10, extra: 1 })`
and
`stdlib.itertools.accumulate(rows, { iterable: other_rows, func: callable, initial: 10 })`
now raise Python's `accumulate() takes at most 3 arguments (4 given)` instead
of miscounting or prioritizing duplicate-name fallbacks too early. The covered
second-argument keyword analogue
`stdlib.itertools.accumulate(rows, { func: callable, initial: 10 })` now also
matches Python's accumulated output instead of dropping the keyword-style
`initial` value during parsing.
Covered `accumulate(iterable, func := unset, initial := unset)` now also
accepts exposed stdlib operator class methods such as `stdlib.operator.mul` as
direct callback arguments by rebinding the underlying AHK method implementation
to the exported `stdlib.operator` object before consumption, so
`stdlib.itertools.accumulate(rows, stdlib.operator.mul)` now yields the same
accumulated product rows as Python `itertools.accumulate(rows, operator.mul)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
The covered lazy callback-arity path now also matches Python 3.10.11 for
unary stdlib operator predicates reused as binary accumulate callbacks:
`stdlib.itertools.accumulate(rows, stdlib.operator.truth, { initial: 10 })`
now emits the covered initial value and then raises Python's observable
`_operator.truth() takes exactly one argument (2 given)` on the next pull
instead of leaking AutoHotkey's raw `Too many parameters passed to function.`
error from the bound method object.
Covered plain callable object values that define their own `Call` while also
carrying keyword-like own props such as `iterable`, `func`, `initial`, or
`extra` now likewise stay off the keyword-analogue path. Local Python 3.10.11
keeps `accumulate(callable_obj)` on the observable non-iterable `TypeError`,
keeps `accumulate(rows, callable_obj)` on the callable-function path, and
preserves callable object identity for covered `initial=` values. The direct
AHK surface now mirrors those covered slices, including the existing direct
trailing-`initial` analogue, so callable value objects no longer leak
`'Call' is an invalid keyword argument for accumulate()` or duplicate-binding
diagnostics merely because they expose keyword-like attributes.
Covered `starmap(func, iterable)` now also accepts exposed stdlib operator
class methods such as `stdlib.operator.add` as direct callback arguments by
rebinding the underlying AHK method implementation to the exported
`stdlib.operator` object before consumption, so
`stdlib.itertools.starmap(stdlib.operator.add, rows)` now yields the same
row-wise mapped output as Python `itertools.starmap(operator.add, rows)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `takewhile(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.takewhile(stdlib.operator.truth, rows)` now yields the same
prefix output as Python `itertools.takewhile(operator.truth, rows)` instead of
failing with AutoHotkey's raw missing-parameter method-call error.
Covered `dropwhile(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.dropwhile(stdlib.operator.truth, rows)` now yields the same
suffix output as Python `itertools.dropwhile(operator.truth, rows)` instead of
failing with AutoHotkey's raw missing-parameter method-call error.
Covered `filterfalse(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.filterfalse(stdlib.operator.truth, rows)` now yields the
same filtered output as Python `itertools.filterfalse(operator.truth, rows)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `groupby(iterable, key := unset)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct key
functions by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy grouping, so
`stdlib.itertools.groupby(rows, stdlib.operator.truth)` now yields the same
key/group boundaries as Python `itertools.groupby(rows, operator.truth)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `tee(iterable, n := 2)` now returns a tuple-like readonly array of
independent lazy clones, supports Python's `n=0/1/2` and bool-as-int behavior,
including root `stdlib.True` / `stdlib.False` count values, preserves
independent consumer positions through a shared cache instead of eager
materialization, skips iterable validation when `n=0` like local Python 3.10.11,
exposes the outer return container itself as a readonly tuple-like object rather
than a mutable array,
exposes a Python-style `<itertools._tee object at 0x...>` `__Repr()` shape for
covered tee clone objects, exposes a callable `clone.__class__` provider so the
covered `_tee` type itself can be instantiated from an iterable or another tee
clone like local Python 3.10.11, and surfaces Python-style arity errors for
zero or more than two positional arguments, `ValueError("n must be >= 0")`,
integer-interpretation `TypeError` including root `stdlib.tuple()` count values,
no-keyword `TypeError("itertools.tee() takes no keyword arguments")` for the
AHK options-object analogue `{ n: value }`, the same covered no-keyword
`TypeError("itertools.tee() takes no keyword arguments")` path for the
options-only analogue `stdlib.itertools.tee({ n: 3 })`, the mixed positional
plus keyword-iterable analogue `stdlib.itertools.tee([1, 2], { iterable: [3, 4] })`,
and the three-argument analogue `stdlib.itertools.tee([1, 2], 2, { n: 3 })`, the matching
`TypeError("_tee() takes no keyword arguments")` path for the covered `_tee`
clone-type constructor when AHK passes the keyword analogue `{ iterable: ... }`
either by itself or alongside a positional iterable argument, and non-iterable
type-name parity for covered invalid inputs, including root `stdlib.True` /
`stdlib.False` iterable arguments as Python `bool`. Covered re-entry now also
matches local Python 3.10.11 by raising
`RuntimeError("cannot re-enter the tee iterator")` when a shared tee source
tries to advance another clone while an upstream pull is already active.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry keyword-like own properties such as `n` or
`iterable`, so shapes like `stdlib.itertools.tee(iterable_obj)` mirror local
Python 3.10.11 instead of being misclassified as the AHK keyword-analogue path.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as `n` or
`iterable`, so `stdlib.itertools.tee(callable_obj)` surfaces Python's iterable
`TypeError`, `stdlib.itertools.tee(rows, callable_obj)` surfaces Python's
integer-interpretation `TypeError`, and `stdlib.itertools.tee(rows, 2,
callable_obj)` keeps Python's at-most-two-arguments arity error instead of
falling into the AHK no-keyword analogue path.
Covered `chain.from_iterable(iterable)` now also rejects the mixed
positional-plus-keyword analogue path, so
`stdlib.itertools.chain.from_iterable(rows, { iterable: other })` raises
Python's observable `TypeError("chain.from_iterable() takes no keyword
arguments")` instead of falling through to the raw one-argument arity error.
Covered split-keyword `repeat(...)` parity now also matches local Python
3.10.11 for duplicate invalid names spread across two AHK keyword-wrapper
objects, so shapes like `stdlib.itertools.repeat({ extra: 1 }, { extra: 2 })`
raise `TypeError("itertools.repeat() got multiple values for keyword argument
'extra'")` before later missing-argument, invalid-keyword, or keyword-count
branches. The same priority now extends across three wrapper objects and
positional-plus-two-wrapper mixes: `stdlib.itertools.repeat({ object: "x" }, {
times: 3 }, { extra: 1 })` now raises the Python too-many-keyword branch
instead of the raw three-argument arity error, while
`stdlib.itertools.repeat("x", { times: 3 }, { times: 4 })` raises duplicate
`times` before later argument-count handling. Covered no-keyword `chain(...)`, `chain.from_iterable(...)`, and
`cycle(...)` parity now also matches local Python 3.10.11 for duplicate split
keyword names, so shapes like `stdlib.itertools.chain({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 })`, and
`stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })` raise the corresponding
Python duplicate-keyword `TypeError(...)` before later no-keyword or arity
branches, while `stdlib.itertools.chain.from_iterable(rows, 2, { extra: 1 })`
and `stdlib.itertools.cycle(rows, 3, { extra: 1 })` now also keep Python's
observable no-keyword priority ahead of the raw arity errors those call shapes
would otherwise reach.
Covered no-keyword `pairwise(...)`, `starmap(...)`, `takewhile(...)`,
`dropwhile(...)`, `filterfalse(...)`, and `tee(...)` parity now also matches
local Python 3.10.11 for duplicate split keyword names and late keyword
wrappers after extra positional arguments, so shapes like
`stdlib.itertools.pairwise({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.starmap({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.takewhile({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.dropwhile({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.filterfalse({ extra: 1 }, { extra: 2 })`, and
`stdlib.itertools.tee({ extra: 1 }, { extra: 2 })` now raise the corresponding
Python duplicate-keyword `TypeError(...)`, while later-keyword shapes such as
`stdlib.itertools.pairwise(rows, 3, { extra: 1 })`,
`stdlib.itertools.starmap(func, rows, 3, { extra: 1 })`,
`stdlib.itertools.takewhile(pred, rows, 3, { extra: 1 })`,
`stdlib.itertools.dropwhile(pred, rows, 3, { extra: 1 })`,
`stdlib.itertools.filterfalse(pred, rows, 3, { extra: 1 })`, and
`stdlib.itertools.tee(rows, 2, 3, { extra: 1 })` now also keep Python's
observable no-keyword priority ahead of the raw arity errors those call shapes
would otherwise reach.
Covered no-keyword `islice(...)` parity now also matches local Python 3.10.11
for duplicate split keyword names and late keyword wrappers after extra
positional arguments, so shapes like
`stdlib.itertools.islice({ extra: 1 }, { extra: 2 })` and
`stdlib.itertools.islice({ stop: 1 }, { stop: 2 })` now raise the
corresponding Python duplicate-keyword `TypeError(...)`, while
`stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })` keeps Python's
observable no-keyword priority ahead of the raw arity error the call shape
would otherwise reach. Covered `islice(...)` now also mirrors Python's
explicit `expected at least 2 arguments` / `expected at most 4 arguments`
wording for the 0-, 1-, and 5-argument forms.
Covered `tools\run-ahktest.ps1` discovery parity now also matches the observed
local pytest 7.4.3 duplicate-target policy: repeated explicit file targets are
collected again, repeated directory targets stay deduplicated, and mixed
directory-plus-file target lists still collect the explicit file a second time
without reloading the whole test script twice. The wrapper now tracks
per-include collected test ranges and duplicates those collected items to match
pytest's file-target semantics while leaving directory discovery de-duplication
in place. Wrapper self-tests and architecture bookkeeping were updated for the
promoted surface.
Covered `tools\run-ahktest.ps1` now also follows the observed local pytest
7.4.3 `testpaths` precedence slice through a manifest-backed AHK analogue:
when `-Target` is omitted, JSON `-Config` manifests may provide
`AhkTest.DiscoveryRoots` as default discovery targets resolved relative to the
config file, while an explicit wrapper `-Target` still overrides those manifest
roots entirely. Wrapper self-tests, examples, architecture notes, and framework
bookkeeping were updated for the promoted surface.
The current wrapper baseline after this slice is `stdlib/tests: 773 passed, 0
failed, 0 errors`.
More itertools functions remain deferred until their Python behavior matrices
are covered by ahktest tests.

The current root-level `stdlib.tuple(iterable?)` slice follows covered Python
3.10.11 builtin behavior by returning an empty readonly tuple-like value when
called without arguments, materializing strings and enumerable objects into a
readonly tuple-like object, preserving identity for existing stdlib tuple
instances, and surfacing Python-style non-iterable `TypeError` messages for
covered `NoneType`, `int`, `object`, and custom class inputs.

The current root-level `stdlib.True` / `stdlib.False` slice now acts as the
shared stdlib boolean singleton layer, analogous to `stdlib.None`: JSON
serialization and parsing paths consume and produce these same root-level
values, so callers can use `stdlib.True` / `stdlib.False` directly in
`stdlib.json.dumps(...)` input structures instead of routing through
module-specific boolean sentinels. `stdlib.json.True` / `stdlib.json.False`
remain available as aliases of those same root-level singleton values for
compatibility. Shared stdlib truthiness now also treats empty AHK arrays and
maps as false, matching the covered Python list/dict truthiness paths used by
`itertools.filterfalse(None, ...)` and `stdlib.json.Bool(...)`.

`stdlib.functools` is a first slice of Python 3.10.11 `functools`. It exposes
`reduce` and `partial` under `stdlib.functools`; the old global `reduce`,
`partial`, and `FuncTools` names from `functools\functools.ahk` are intentionally
not part of the direct surface. `reduce` follows Python's left-fold behavior,
initializer handling, empty-iterable `TypeError`, Python-style non-callable
argument type names (`int`, `object`, `bool`, `tuple`, custom leaf class names), plus Python's
dedicated `reduce() arg 2 must support iteration` message for non-iterable
second arguments; `partial` now uses Python 3.10.11's dedicated
`TypeError("type 'partial' takes at least one argument")` constructor message
for missing callable arguments, plus `TypeError("the first argument must be callable")`
for covered non-callable first arguments, and currently
covers positional argument binding through a callable AHK object and exposes the
Python 3.10 observable `func`, `args`, and `keywords` attributes, plus the
default `__module__ == "functools"` and exact default `__doc__` text including
its trailing newline, plus a stable default empty `__dict__` map for covered
fresh instances and Python-style dynamic attribute assignment that mirrors
assigned names into that stable map, including the flattened nested partial shape,
read-only metadata enforcement, and a stable readonly tuple-like object for `.args`, so
repeated metadata reads preserve object identity while item assignment attempts
fail with Python-style tuple mutation semantics instead of exposing a mutable
AHK array view; when a nested
`partial(partial_obj)` adds no new positional arguments, the wrapped object now
also preserves the original `.args` tuple identity instead of rebuilding a new
readonly view. Covered metadata assignment and deletion now also follow the
observable local Python 3.10.11 behavior for `__module__`, `__doc__`, and
`__dict__`: `partial.__module__` and `partial.__doc__` may be reassigned, and
those overrides are now stored in the instance `__dict__`, so covered reads of
`partial.__dict__['__module__']` / `['__doc__']`, `partial.__reduce__()`, and
`partial.__setstate__(...)` all roundtrip the same metadata view. Replacing
`partial.__dict__` with another map object now also clears those overrides and
falls back to the default `"functools"` / built-in doc string just like local
Python, while assigning non-dictionary values such as covered `int`, `list`, or
`NoneType` payloads still raises Python-style
`TypeError("__dict__ must be set to a dictionary, not a '...'")`. Deleting a
covered assigned `__module__` or `__doc__` entry now removes just that
`__dict__` override and falls back to the default value, while deleting either
name again without an override now follows the observed local Python 3.10.11
shape and raises bare `AttributeError("__module__")` /
`AttributeError("__doc__")` instead of an object-qualified AHK property
message. Deleting `__dict__` raises `TypeError("cannot delete __dict__")`,
and dynamic attributes written through `partial.custom := ...` are mirrored
through `partial.__dict__` and can be removed again with
`stdlib.base.delattr(...)` using Python-style missing-attribute errors after
deletion, so deleting the same covered dynamic name a second time now raises
bare `AttributeError("custom")` instead of an object-qualified AHK property
message, and reading the same missing dynamic name now also raises Python's
object-qualified `AttributeError("'functools.partial' object has no attribute 'custom'")`
instead of a host `PropertyError`. The current covered
metadata slice now also exposes Python 3.10 observable `partial.__reduce__()`
and `partial.__setstate__(state)` behavior: `__reduce__()` returns the
three-part tuple shape headed by the partial type and callable constructor
args, while `__setstate__()` accepts covered Python-shaped `(func, args,
keywords, dict)` state tuples, updates the public `func` / `args` /
`keywords` / `__dict__` metadata accordingly, now including covered
`__module__` / `__doc__` entries supplied through a mapping `dict` state,
Python 3.10's observable acceptance of `[]` and `()` as the state `dict`
payload, and `keywords=None` normalization back to an empty keyword dict, plus scalar
non-dictionary state payloads such as `5` preserved through `__dict__`; covered
non-dictionary state payloads now also make later `__reduce__()` calls raise
Python-style `SystemError("bad argument to internal function")`, and covered
dynamic attribute writes such as `partial.custom := 42` now also raise that
same Python-style `SystemError`; covered dynamic attribute reads such as
`partial.custom`, `partial.__module__`, and `partial.__doc__` on the same
scalar payload now also raise that same
Python-style `SystemError`; covered dynamic attribute deletes such as
`partial.DeleteProp("custom")`, `delattr(partial, "__module__")`, and
`delattr(partial, "__doc__")` on the same scalar payload now also raise that
same Python-style `SystemError` instead of leaking raw AHK property/method
errors; and uses Python-style
`TypeError` wording for the covered zero-argument and invalid-state failures
instead of missing-method or raw AHK parameter errors. The current covered
metadata slice also exposes Python-style
`partial.__Repr()` output for covered positional-partial cases so observable
repr text includes the underlying function name plus flattened bound positional
arguments. The covered repr slice now also follows Python string-literal
escaping for bound string arguments in covered backslash, newline, and quote
cases, plus Python literal shapes for covered bound `list`, `dict`, and
`None` values, root `stdlib.True` / `stdlib.False` values as Python `True` /
`False` literals for positional and observed keyword metadata, and Python-style
`<Type object at 0x...>` repr shapes for covered custom bound objects, and tuple
literal shapes such as `(1,)` when `partial.__Repr()` is observing the readonly
tuple-like `.args` metadata itself, plus Python-style `<function name at
0x...>` repr shapes when covered bound values are themselves callable function
objects, plus Python-style `name=value` keyword metadata in repr for covered
observed `.keywords` entries.
The current call slice now also consumes mutable `.keywords` map values at call
time for the covered direct AHK trailing-parameter shape, matching local Python
3.10.11's observable behavior where mutating `partial.keywords` changes later
calls while nested partials keep their copied keyword metadata. Full Python
keyword dispatch by parameter name remains constrained by AHK v2's callable
reflection surface and is still deferred.
`lru_cache`, `wraps`, `singledispatch`, and
comparison helpers remain deferred.

`stdlib.calendar` is a first slice of Python 3.10.11 `calendar`. It exposes
weekday/month constants, `IllegalMonthError`, `IllegalWeekdayError`, `isleap`,
`leapdays`, `weekday`, `monthrange`, `monthcalendar`, `firstweekday`, and
`setfirstweekday` under `stdlib.calendar`. The old global `isleap`,
`leapdays`, `weekday`, `monthrange`, `monthcalendar`, and `Calendar` names from
`calendar\calendar.ahk` are intentionally not part of the direct surface.
The direct module follows Python's proleptic Gregorian behavior for covered
cases, including year 0 in `monthrange`, and `monthcalendar` respects the
module-level first weekday. Formatting calendars, locale names, `Calendar`
classes, and `timegm` remain deferred.

`stdlib.time` is a first slice of Python 3.10.11 `time`. It exposes
`time()` and `time_ns()` under `stdlib.time`, returning Unix epoch seconds as
a Float and nanoseconds as an Integer derived from `A_NowUTC`, `A_MSec`, and
`DateDiff`. It also exposes `sleep(seconds)`, rejecting negative and
non-numeric durations before delegating to AutoHotkey's millisecond `Sleep`,
`monotonic()` / `monotonic_ns()` backed by `A_TickCount`, and
`perf_counter()` / `perf_counter_ns()` backed by `QueryPerformanceCounter`.
The current slice also
exposes `struct_time(sequence)`, `gmtime(seconds?)`, `localtime(seconds?)`,
`strftime(format, struct_time_or_tuple?)`, `asctime(struct_time_or_tuple?)`, and `ctime(seconds?)`.
`struct_time` is an enumerable tuple-like object with `tm_year` through
`tm_isdst` attributes; `gmtime` follows the local Python 3.10.11 Windows
runtime for covered Unix-second inputs, including fractional second flooring
and the observed pre-epoch boundary where `-86400` raises
`OSError("Invalid argument")`; `localtime` follows the same local runtime
baseline for covered inputs, including the current local offset and the
observed Windows behavior where negative Unix seconds raise
`OSError("Invalid argument")`; `strftime` currently supports a focused
directive set (`%Y`, `%m`, `%d`, `%H`, `%M`, `%S`, `%j`, `%w`, `%%`) over
`struct_time` inputs, root `stdlib.tuple(...)` values, or the current local
time when the tuple is omitted; and `asctime`/`ctime` currently emit Python-style fixed-width English
abbreviations over the covered `struct_time` and local-time inputs. Wider
directive coverage, timezone metadata, and clock-info APIs remain deferred.

`stdlib.warnings` is a first slice of Python 3.10.11 `warnings`. It exposes
`Warning`, `UserWarning`, `DeprecationWarning`, `warn`, `catch_warnings`,
`simplefilter`, and `resetwarnings` under `stdlib.warnings`. The old global
`Warning`, `UserWarning`, `DeprecationWarning`, `warn`, and warning registry
helpers from `warning\warning.ahk` are intentionally not part of the direct
surface. The first slice supports record-style warning capture through
`catch_warnings(true).Call(callback)`, category/source metadata, and
`simplefilter("error", category)` for warning-as-error behavior with
catch-scope filter restoration. It now has basic warning registries for
`default`, `module`, and `once` de-duplication, scoped to catch contexts when
recording warnings, and `warn(..., stacklevel)` records callsite-style
filename/line metadata for covered cases. Filter matching now covers warning
category subclasses and non-zero line-number predicates for direct warning
records. Full CPython filter precedence, formatting hooks, and deeper
integration with ahktest warning reporting remain deferred.

`stdlib.math` is a first slice of Python 3.10.11 `math`. It exposes
`pi`, `e`, `tau`, `floor`, `ceil`, `trunc`, `fabs`, `sqrt`, `factorial`,
`gcd`, `lcm`, `comb`, `perm`, `prod`, `fsum`, `degrees`, `radians`,
`dist`, `hypot`, and `isclose` under `stdlib.math`. It intentionally does
not export the legacy global `Math` class or bare functions from
`math\math.ahk`; internal helpers use the `AhkStdlibMath...` prefix to
avoid shared global namespace collisions. The direct slice now uses a
partials-based `fsum`, scaled `hypot`/`dist` calculations, and iterable
`dist` inputs for covered Python numeric edge cases. `inf`, `nan`, and the
rest of Python's floating-special behavior remain deferred until the project
has a consistent AHK representation for those values.

`stdlib.random` is a first slice of Python 3.10.11 `random`. It uses an
internal MT19937 implementation rather than AutoHotkey's built-in `Random()`,
and exposes deterministic module-level `seed(...)`, `random()`,
`getrandbits(k)`, `randrange(...)`, `randint(a, b)`, `choice(sequence)`,
`choices(population, weights?, cum_weights?, k?)`, `sample(population, k)`,
`shuffle(array)`, and `uniform(a, b)` under `stdlib.random`. The AHK
`choices` signature uses positional optional arguments because AutoHotkey has
no Python keyword-only call syntax. The initial slice
matches Python 3.10.11 integer seed fixtures for `random()`, `getrandbits`,
`randrange`, `randint`, `choice`, weighted/equal `choices`, `sample`, and
`shuffle`. Covered `choices(..., k)` and `sample(..., k)` now also accept
root `stdlib.True` / `stdlib.False` as Python bool-as-int `1` / `0` inputs
instead of rejecting them as foreign AHK object types. Covered
`choice(mapping)` now also follows local Python 3.10.11's observable
subscriptable-mapping branch for `Map` and `Map` subclasses, so
`stdlib.random.choice(Map("a", 1))` and equivalent dict-like subclasses now
raise `KeyError(0)` instead of falling through to the generic
`'... object is not subscriptable'` `TypeError`. Covered `choice(...)` and
`choices(..., k)` now also accept custom sequence-protocol objects that expose
AHK `__Len` and `__Item`, matching local Python 3.10.11's observable support
for non-list, non-string sequence objects such as `random.choice(custom_seq)`
and `random.choices(custom_seq, k=4)`, while `sample(...)` intentionally keeps
Python 3.10.11's stricter `Population must be a sequence...` rejection for
that same custom object shape. Covered readonly-sequence `shuffle(...)`
rejections now also use Python 3.10.11 type names for the observed string and
root `stdlib.tuple(...)` shapes, so `stdlib.random.shuffle("ab")` raises
`'str' object does not support item assignment` and
`stdlib.random.shuffle(stdlib.tuple([1, 2]))` raises
`'tuple' object does not support item assignment` instead of leaking host
AHK type names. String/bytes seed
expansion, `Random` instances, state
import/export, and distribution helpers remain deferred.

`stdlib.csv` is a first slice of Python 3.10.11 `csv`. It exposes dialect
constants, `Error`, `get_dialect()`, `list_dialects()`, `reader(...)`,
`writer(...)`, `DictReader(...)`, and `DictWriter(...)` under `stdlib.csv`.
Readers accept strings or line arrays and are enumerable through AHK `for`;
`reader(...)` is stateful like Python's reader iterator, treats array entries as
physical input lines, and updates `line_num` as rows are consumed.
writers accumulate output in `.text` because `io.StringIO` is not direct yet.
The direct reader supports quoted fields, embedded newlines, `escapechar`, and
`QUOTE_NONNUMERIC` float conversion for unquoted fields; the direct writer
supports minimal/all/none/nonnumeric quoting for the covered AHK value types,
with `writerows(...)` writing rows without returning a character count like
Python 3.10.
`Sniffer`, `field_size_limit`, fuller `DictReader` lifecycle/default handling,
and strict-mode edge cases such as text after a closing quote remain deferred.

`stdlib.configparser` is a first slice of Python 3.10.11 `configparser`. It
exposes `ConfigParser()` plus the exception classes `Error`,
`NoSectionError`, `NoOptionError`, `DuplicateSectionError`, and
`MissingSectionHeaderError` under `stdlib.configparser`. The initial slice
covers `read_string(...)`, `sections()`, `has_section(...)`, `add_section(...)`,
`get(...)`, `getint(...)`, `getfloat(...)`, `getboolean(...)`, `set(...)`,
`remove_option(...)`, `remove_section(...)`, `options(...)`,
`has_option(...)`, default lower-casing of option names with case-insensitive
option access, item-style section access through `parser["section"]["option"]`,
ordered `items(section)` results, and ordered `options(section)` results for
covered INI text, including DEFAULT-aware parser-level merge order where
`items("Server")` emits default keys first with local overrides and
`options("Server")` emits local keys before inherited defaults, plus
SectionProxy fallback for `parser["section"]["option"]`, `items()`, `keys()`,
and `values()` with inherited defaults visible in the section view. Covered
`getint(section, option)` now preserves the same
`NoOptionError` / `NoSectionError` precedence as `get(...)` and raises
`ValueError("invalid literal for int() with base 10: '...'")` for invalid
integer text. Covered `getfloat(section, option)` now follows observed Python
3.10.11 float parsing for valid numeric text, preserves the same
`NoOptionError` / `NoSectionError` precedence as `get(...)`, and raises
`ValueError("could not convert string to float: '...'")` for invalid float
text. Covered `set(section, option, value)` now also matches the observed
Python 3.10.11 value-type guard by accepting only string option values,
raising `TypeError("option values must be strings")` before section lookup for
non-string values, while still preserving `NoSectionError` for missing sections
when the passed value itself is a string. Covered `has_option(section, option)`
now follows observed Python 3.10.11 missing-section behavior by returning
`False`, while covered `options(section)` still raises `NoSectionError` for a
missing section. A first covered `DEFAULT` slice now treats `[DEFAULT]` as a
special parser section instead of a normal named section: `sections()` excludes
it, `has_section("DEFAULT")` stays false, `get("Server", option)` and
`has_option("Server", option)` can read defaulted options, `get("DEFAULT",
option)` reads the default option set directly, and `add_section("DEFAULT")`
raises `ValueError("Invalid section name: 'DEFAULT'")`. DEFAULT-aware section
view removal now allows `remove_option("DEFAULT", option)` to mutate fallback
state for other sections, while DEFAULT-aware section view mutation edge cases,
file-based
`read`/`write`, interpolation/fallback arguments, custom option-normalization
controls, and the broader CPython parser edge-case matrix remain deferred.

`stdlib.io` is a first slice of Python 3.10.11 `io`. It exposes
`StringIO(...)` plus the `SEEK_SET`, `SEEK_CUR`, and `SEEK_END` constants under
`stdlib.io`. The initial slice covers in-memory text streams with
`getvalue()`, `read(...)`, `readline(...)`, `write(...)`, `seek(...)`,
`tell()`, `truncate(...)`, `close()`, and the `closed` flag, including
Python-style closed-stream errors, default `None` initial value handling,
cur/end-relative seek restrictions, and NUL-padding when writing beyond the end
of the current buffer. `BytesIO`, newline-translation controls, text-wrapper
classes, and file-backed stream abstractions remain deferred.

`stdlib.shutil` is a first slice of Python 3.10.11 `shutil`. It exposes
`Error`, `SameFileError`, `copyfile(...)`, `copy(...)`, `move(...)`, and
`rmtree(...)` under `stdlib.shutil`. The initial slice covers real filesystem
copy/move/remove behavior against `stdlib.pathlib.Path` or string paths,
returns destination path strings like Python for the covered operations, raises
`SameFileError` for same-file `copyfile(...)`, treats missing sources and
missing destination parents as `OSError` with Python-style "No such file or
directory" messages, and treats directory use with `copyfile(...)` as
permission-denied `OSError` behavior. Metadata-copy helpers, ignore callbacks,
symlink policy, `copytree`, archive helpers, and the broader CPython callback
and permission edge-case matrix remain deferred.

`stdlib.json` is a first slice of Python 3.10.11 `json`. AHK v2 has no
distinct Boolean type: local docs define `true` and `false` as built-in
variables containing the integers `1` and `0`. Because of that, `dumps(true)`
and `dumps(1)` are not distinguishable at runtime. The direct module therefore
uses the shared root-level special values `stdlib.True` and `stdlib.False` for
guaranteed JSON `true`/`false` output while still preserving integer
serialization for plain `1` and `0`; `stdlib.json.True`, `stdlib.json.False`,
and `stdlib.json.Bool(value)` remain as module-level aliases/helpers over the
same root boolean singletons. The
direct serializer follows Python's default separators and `ensure_ascii=True`
escaping for covered BMP and supplementary-plane Unicode characters, and
surrogate-pair escapes load back to the equivalent AHK supplementary
character representation. Broader
CPython options such as configurable separators, `sort_keys`, `indent`,
`allow_nan`, and `JSONDecodeError` remain deferred.

`stdlib.re` is a first slice of Python 3.10.11 `re`. It exposes
`ASCII`/`A`, `IGNORECASE`/`I`, `MULTILINE`/`M`, `DOTALL`/`S`,
`VERBOSE`/`X`, `compile`, `search`, `match`, `fullmatch`, `findall`, and
`sub` under `stdlib.re`. Match objects expose zero-based Python-style
`group(...)`, `groups(...)`, `groupdict(...)`, `start(...)`, `end(...)`, and
`span(...)` helpers. Internally it uses AutoHotkey PCRE through `RegExMatch`
and `RegExReplace`, converting AHK's 1-based positions to Python's zero-based
half-open spans. Default string matching injects PCRE Unicode properties so
basic word-class behavior is closer to Python 3; `ASCII` disables that. Bytes
patterns, locale/debug flags, `split`, `finditer`, scanner APIs, `pos`/`endpos`,
callable replacements, and richer exception-class parity remain deferred.

`stdlib.statistics` exposes a Python-like `StatisticsError` class object
as `stdlib.statistics.StatisticsError`, backed by the internal
AHK-prefixed `AhkStdlibStatisticsError` global. The direct API currently
accepts AHK arrays and custom enumerable objects as iterable inputs, supports
the Python 3.10 optional known-mean parameters for `pvariance`, `variance`,
`pstdev`, and `stdev`, and follows Python 3.10.11 messages for the covered
empty/singleton error cases.

`stdlib.tempfile` is a first slice of Python 3.10.11 `tempfile` focused on
temporary directories. It exposes `gettempdir()`, `gettempprefix()`,
`mkdtemp(suffix?, prefix?, dir?)`, and `TemporaryDirectory(...).cleanup()`.
The Python 3.10 behavior where an explicit relative `dir` returns a relative
created path is preserved; this intentionally differs from newer Python
versions that make `mkdtemp()` absolute.

# stdlib for AutoHotkey v2

A Python 3.10-inspired standard library for AutoHotkey v2.

`stdlib` rebuilds common standard-library modules behind a predictable
`#Include <stdlib\...>` surface, with focused behavior tests and examples for
each promoted module.

## Requirements

`stdlib` requires AutoHotkey v2.0.5 or later because several modules depend on
`unset`-related language features. It is currently developed and tested with
AutoHotkey v2.0.26 and v2.1-alpha.30.

Local behavior probes use Python 3.10.11 as the authority.

## Runtime Assets

| Area | Notes |
| --- | --- |
| `stdlib.tkinter` | Bundles `tcl86t.dll` and `tk86t.dll` for `useTk`. Source and SHA256 notes are in `stdlib\tkinter\lib`. |

## Coverage And Examples

<details>
<summary>Promoted example index</summary>

| Example | Main coverage |
| --- | --- |
| `stdlib\examples\abc.ahk` | Abstract markers, virtual subclass registration, cache tokens, `update_abstractmethods`. |
| `stdlib\examples\array.ahk` | Fixed-type arrays, sequence operations, binary/unicode conversion, file round-trips. |
| `stdlib\examples\asyncio.ahk` | Cooperative futures/tasks, event-loop lifecycle, scheduling, queues, `stdlib.await(...)`. |
| `stdlib\examples\base64.ahk` | Standard, URL-safe, wrapped-bytes, and Base16 codecs. |
| `stdlib\examples\binascii.ahk` | Hexlify/unhexlify, CRC32, Base64 ASCII helpers. |
| `stdlib\examples\bisect.ahk` | Zero-based insertion points, key functions, sequence/insert targets. |
| `stdlib\examples\calendar.ahk` | Gregorian helpers, names, week headers, `timegm`, `Calendar` grids. |
| `stdlib\examples\collections.ahk` | `Counter`, `deque`, `defaultdict`, `OrderedDict`, `ChainMap`, named/user containers. |
| `stdlib\examples\contextlib.ahk` | `nullcontext`, `suppress`, `closing`, `ContextDecorator`, `ExitStack`, redirects. |
| `stdlib\examples\copy.ahk` | Shallow/deep copy, custom hooks, cycles, `Error` / `error`, `dispatch_table`. |
| `stdlib\examples\csv.ahk` | Reader/writer, dict reader/writer, dialects, `field_size_limit`, `Sniffer`. |
| `stdlib\examples\datetime.ahk` | Date/time/datetime/timedelta, bounds, `tzinfo`, fixed-offset `timezone`. |
| `stdlib\examples\decimal.ahk` | Decimal arithmetic, contexts, rounding constants, signal classes. |
| `stdlib\examples\init.ahk` | Root helpers including `stdlib.await(...)` and `stdlib.decorate(...)`. |
| `stdlib\examples\thread.ahk` | Process-backed workers, channels, shared memory, shared-object broker, pools. |
| `stdlib\examples\tkinter_gui.ahk` | Live tkinter / ttk window with variables, layout, callbacks, canvas, and tree data. |

</details>

## Quick Start

### Small Module

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

<details>
<summary>Thread worker, channel, shared memory, and pool example</summary>

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\thread>

ready := stdlib.thread.Event()
ready.set()

channel := stdlib.thread.Channel()
memory := stdlib.thread.SharedMemory({ size: 128 })
shared := stdlib.thread.SharedObject(Map("count", 0, "items", []))
memory.write("abcd", 0)
worker := stdlib.thread.Thread({
    name: "calc-worker",
    channel: channel,
    shared_memory: memory,
    shared_objects: Map("state", shared),
    source: "channel := stdlib.thread.current_channel()`n"
        . "memory := stdlib.thread.current_shared_memory()`n"
        . "request := channel.recv_worker(2)`n"
        . "seen := memory.read_text(0, 4)`n"
        . "memory.write(`"WXYZ`", 4)`n"
        . "memory.synchronized((shared) => (`n"
        . "    shared.write_json(Map(`"seen`", seen), 16, 48),`n"
        . "    shared.put(request[`"value`"] * 2, 80, `"UInt`"),`n"
        . "    shared.put(-123, 84, `"Int`")`n"
        . "), 2)`n"
        . "channel.send_worker(Map(`"answer`", memory.get(80, `"UInt`"), `"label`", request[`"label`"], `"address_type`", Type(memory.address)))`n"
        . "state := stdlib.thread.current_shared_object(`"state`")`n"
        . "state.acquire(true, 2)`n"
        . "try {`n"
        . "    state.append(`"items`", request[`"label`"])`n"
        . "    state.set(`"count`", state.get(`"count`") + 1)`n"
        . "} finally {`n"
        . "    state.release()`n"
        . "}`n"
        . "thread_result := Map(`"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
worker.start()
channel.send(Map("value", 21, "label", "json-message"))
reply := channel.recv(2)
worker.join(2)

result := worker.result()
worker_answer := reply["answer"]
worker_label := reply["label"]
worker_native_id := result["native_id"]
shared_text := memory.read_text(4, 4)
shared_payload := memory.read_json(16, 48)
shared_answer_slot := memory.get(80, "UInt")
shared_signed_slot := memory.get(84, "Int")
shared_state := shared.snapshot()

pool := stdlib.thread.ThreadPool({ max_workers: 1 })
first_future := pool.submit({ source: "thread_result := `"first`"" })
second_future := pool.submit({ source: "thread_result := `"second`"" })
future_events := []
first_future.add_done_callback((future) => future_events.Push(future.result()))
second_running_before := second_future.running()
first_value := first_future.result(2)
second_future.add_done_callback((future) => future_events.Push(future.result()))
second_value := stdlib.await(second_future, { timeout: 2 })
mapped_values := pool.map((value) => { source: "thread_result := " (value * 10) }, [3, 1, 2])
pool.shutdown()

persistent_pool := stdlib.thread.ThreadPool({
    max_workers: 1,
    worker_source: "AhkStdlibThreadPoolHandleTask(task) {`n"
        . "    return Map(`"label`", task[`"label`"], `"value`", task[`"value`"] * 10, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))`n"
        . "}"
})
persistent_first := persistent_pool.submit({ task: Map("label", "first", "value", 1) }).result(2)
persistent_second := persistent_pool.submit({ task: Map("label", "second", "value", 2) }).result(2)
persistent_reused_worker := persistent_first["pid"] = persistent_second["pid"]
persistent_pool.shutdown()

channel.close()
memory.close()
```

</details>

<details>
<summary>tkinter / ttk live window example</summary>

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

root := stdlib.tkinter.Tk()
root.title("stdlib tkinter demo")
root.geometry("740x480")

count := 0
name := stdlib.tkinter.StringVar(root, "AutoHotkey")
stage := stdlib.tkinter.StringVar(root, "draft")
status := stdlib.tkinter.StringVar(root, "Ready")
scoreValue := stdlib.tkinter.DoubleVar(root, 42)

style := stdlib.tkinter.ttk.Style(root)
try style.theme_use("clam")
style.configure("App.TFrame", { padding: 14 })
style.configure("Demo.Treeview", { rowheight: 24, foreground: "#203040" })
style.map("Demo.Treeview", { foreground: [["selected", "white"]], background: [["selected", "#2878b8"]] })

main := stdlib.tkinter.ttk.Frame(root, { padding: [16, 14], style: "App.TFrame" })
main.grid({ row: 0, column: 0, sticky: "nsew" })
root.columnconfigure(0, { weight: 1 })
root.rowconfigure(0, { weight: 1 })
main.columnconfigure(1, { weight: 1 })
main.rowconfigure(3, { weight: 1 })

stdlib.tkinter.ttk.Label(main, { text: "Name" })
    .grid({ row: 0, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
entry := stdlib.tkinter.ttk.Entry(main, { textvariable: name, width: 24 })
entry.grid({ row: 0, column: 1, pady: 6, sticky: "ew" })

stdlib.tkinter.ttk.Label(main, { text: "Stage" })
    .grid({ row: 1, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
stageChoice := stdlib.tkinter.ttk.Combobox(main, { textvariable: stage, values: ["draft", "review", "ship"], state: "readonly" })
stageChoice.grid({ row: 1, column: 1, pady: 6, sticky: "ew" })
stageChoice.current(0)

scoreRow := stdlib.tkinter.ttk.Frame(main)
scoreRow.grid({ row: 2, column: 0, columnspan: 2, pady: 8, sticky: "ew" })
scoreRow.columnconfigure(0, { weight: 1 })
scoreScale := stdlib.tkinter.ttk.Scale(scoreRow, { variable: scoreValue, from_: 0, to: 100, command: update_demo })
scoreScale.grid({ row: 0, column: 0, padx: [0, 10], sticky: "ew" })
progress := stdlib.tkinter.ttk.Progressbar(scoreRow, { maximum: 100, variable: scoreValue, mode: "determinate" })
progress.grid({ row: 0, column: 1, sticky: "ew" })

canvas := stdlib.tkinter.Canvas(main, { width: 300, height: 120, bg: "white", highlightthickness: 0 })
canvas.grid({ row: 3, column: 0, padx: [0, 12], pady: 8, sticky: "nsew" })
canvas.create_rectangle(12, 16, 288, 104, { fill: "#f7fbff", outline: "#d4e3ef" })
bar := canvas.create_rectangle(24, 72, 24, 92, { fill: "#2878b8", outline: "#2878b8" })
caption := canvas.create_text(24, 30, { text: "Ready", anchor: "nw", fill: "#203040" })

tree := stdlib.tkinter.ttk.Treeview(main, {
    columns: ["value"],
    show: ["tree", "headings"],
    height: 5,
    style: "Demo.Treeview"
})
tree.heading("#0", { text: "Signal" })
tree.heading("value", { text: "Value" })
tree.column("#0", { width: 120, anchor: "w" })
tree.column("value", { width: 100, anchor: "center" })
tree.insert("", "end", "stage", { text: "Stage", values: [stage.get()] })
tree.insert("", "end", "score", { text: "Score", values: [scoreValue.get() "%"] })
tree.insert("", "end", "updates", { text: "Updates", values: [0], tags: ["dynamic"] })
tree.tag_configure("dynamic", { foreground: "navy" })
tree.grid({ row: 3, column: 1, pady: 8, sticky: "nsew" })

notebook := stdlib.tkinter.ttk.Notebook(main, { height: 70 })
firstPage := stdlib.tkinter.ttk.Frame(notebook)
secondPage := stdlib.tkinter.ttk.Frame(notebook)
notebook.add(firstPage, { text: "Summary", padding: 8 })
notebook.add(secondPage, { text: "Details", padding: 8 })
stdlib.tkinter.ttk.Label(firstPage, { textvariable: status }).grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(secondPage, { text: "Variables, layout, callbacks, canvas, and ttk widgets." }).grid({ row: 0, column: 0, sticky: "w" })
notebook.grid({ row: 4, column: 0, columnspan: 2, pady: [6, 0], sticky: "ew" })

button := stdlib.tkinter.ttk.Button(main, { text: "Update", command: update_demo })
button.grid({ row: 5, column: 0, columnspan: 2, pady: 10, sticky: "ew" })

update_demo(*) {
    global count, name, stage, status, scoreValue, canvas, bar, caption, tree
    count += 1
    score := Integer(scoreValue.get())
    status.set(stage.get() " for " name.get() ": " score "%")
    canvas.coords(bar, 24, 72, 24 + Round(score * 2.4), 92)
    canvas.itemconfigure(caption, { text: status.get() })
    tree.set("stage", "value", stage.get())
    tree.set("score", "value", score "%")
    tree.set("updates", "value", count)
    tree.selection_set(["updates"])
    tree.see("updates")
    return stdlib.None
}

update_demo()
root.mainloop()
```

</details>

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

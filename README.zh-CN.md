# AutoHotkey v2 标准库 stdlib

`stdlib` 是面向 AutoHotkey v2 的 Python 3.10 风格标准库项目。

公开 include 路径保持稳定，公开 API 通过根命名空间访问：

```ahk
#Include <stdlib\base64>

encoded := stdlib.base64.b64encode(Buffer(0))
```

## 版本要求

| 项目 | 要求 |
| --- | --- |
| AutoHotkey | v2.0.5 或更高版本 |
| 行为权威 | 本机 Python 3.10.11 |
| 测试 | `stdlib\tests` |
| 示例 | `stdlib\examples` |
| 架构说明 | `docs\stdlib-architecture.md` |

`stdlib.tkinter` 内置用于 `useTk` 的 `tcl86t.dll` 与 `tk86t.dll`；来源和
SHA256 说明位于 `stdlib\tkinter\lib`。

## 示例

下面的片段尽量保持短小、可复制运行。更完整的脚本放在 `stdlib\examples`。

### 核心 helper、数组、字节流和编码

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\array>
#Include <stdlib\base64>
#Include <stdlib\io>

numbers := stdlib.array.array("i", [1, 2, 3, 4])
window := numbers[stdlib.slice(1, 4, 2)].tolist()

payload := Buffer(3, 0)
StrPut("abc", payload, "UTF-8")

stream := stdlib.io.BytesIO(payload)
stream.seek(0)
stream_bytes := stream.read()

encoded := stdlib.base64.b64encode(payload)
decoded := stdlib.base64.b64decode(encoded)

FileAppend "encoded=" StrGet(encoded, "UTF-8") "`n", "*", "UTF-8"
```

### 协作式 async

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\asyncio>

eventLoop := stdlib.asyncio.new_event_loop()

future := stdlib.asyncio.Future({ loop: eventLoop })
future.set_result("ready")
result := stdlib.await(future, { loop: eventLoop })

FileAppend "future=" result "`n", "*", "UTF-8"
```

### Pillow 风格图像处理

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\io>
#Include <stdlib\pillow>

image := stdlib.pillow.Image.new("RGB", [4, 3], [20, 40, 80])
image.putpixel([1, 1], [230, 80, 40])
image.putpixel([2, 1], [255, 210, 80])

gray := image.convert("L")
thumb := stdlib.pillow.ImageOps.contain(image, [2, 2])
sharpened := image.filter(stdlib.pillow.ImageFilter.SHARPEN)

bytes := stdlib.io.BytesIO()
image.save(bytes, "PNG")
opened := stdlib.pillow.Image.open(stdlib.io.BytesIO(bytes.getvalue()), "r", ["PNG"])

FileAppend "mode=" opened.mode " size=" opened.size[1] "x" opened.size[2] "`n", "*", "UTF-8"
```

<details>
<summary>Thread worker、channel、shared memory、shared object 和线程池</summary>

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
<summary>tkinter / ttk 实时窗口</summary>

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
style.configure("Demo.Treeview", { rowheight: 24, foreground: "navy" })
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

## 设计规则

- 对外公开 include 路径使用 `#Include <stdlib\module>`。
- 对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`。
- 模块路径尽量对齐 Python 3.10 `Lib` 标准库路径。
- `stdlib\init.ahk` 是轻量级命名空间根，不承担动态导入加载器职责。
- `stdlib.pillow` 是独立模块，需要时使用 `#Include <stdlib\pillow>`。
- 具体模块 promotion 和 gate 历史维护在 `docs\stdlib-architecture.md`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

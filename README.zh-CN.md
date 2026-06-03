# AutoHotkey v2 标准库 stdlib

`stdlib` 是一个面向 AutoHotkey v2 的标准库项目，设计参考 Python 3.10
标准库的模块划分和常用接口。

项目通过稳定的 `#Include <stdlib\...>` 引入路径组织模块，并为已提升的
模块维护行为测试和示例。

## 版本要求

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本，主要因为部分模块依赖
`unset` 相关语言特性。当前开发和测试环境为 AutoHotkey v2.0.26 与
v2.1-alpha.30。

`stdlib.tkinter` 切片包含用于 `useTk` 支持的 Tcl/Tk 运行时 DLL
（`tcl86t.dll` 与 `tk86t.dll`）。其 CPython 3.10.11 来源与 SHA256
校验报告已随 `stdlib\tkinter\lib\README.md` 和
`stdlib\tkinter\lib\SHA256SUMS` 一起纳入仓库。

## 快速开始

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
button.grid({ row: 3, column: 0, padx: 6, pady: 6, sticky: "ew" })
stdlib.tkinter.ttk.Label(frame, { textvariable: status })
    .grid({ row: 3, column: 1, padx: 6, pady: 6, sticky: "w" })

frame.columnconfigure(1, { weight: 1 })
root.columnconfigure(0, { weight: 1 })
root.mainloop()
```

## 设计规则

- 对外公开引入路径使用 `#Include <stdlib\module>`。
- 对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`。
- 模块路径尽量对齐 Python 3.10 `Lib` 标准库路径。
- `stdlib\init.ahk` 是轻量级命名空间根，不承担动态导入加载器职责。
- 提升为正式模块的内容必须在 `stdlib\tests` 下有行为覆盖。
- README 保持面向使用者的稳定内容；具体模块 promotion 和 gate 历史维护在
  `docs\stdlib-architecture.md`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

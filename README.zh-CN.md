# AutoHotkey v2 标准库 stdlib

`stdlib` 是一个面向 AutoHotkey v2 的标准库项目，设计参考 Python 3.10
标准库的模块划分和常用接口。

项目通过稳定的 `#Include <stdlib\...>` 引入路径组织模块，并为已提升的
模块维护行为测试和示例。

## 版本要求

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本，主要因为部分模块依赖
`unset` 相关语言特性。
`stdlib.tkinter` 切片包含用于 `useTk` 支持的 Tcl/Tk 运行时 DLL
（`tcl86t.dll` 与 `tk86t.dll`）。其 CPython 3.10.11 来源与 SHA256
校验报告已随 `stdlib\tkinter\lib\README.md` 和
`stdlib\tkinter\lib\SHA256SUMS` 一起纳入仓库。
当前已覆盖的 GUI 表面包括带可见性、状态、几何尺寸与窗口尺寸 API 的 `Tk` 根窗口、带几何尺寸与窗口尺寸 API 的 `Toplevel` 窗口、`Frame`、
`Label`、`Button`、`Checkbutton`、`Radiobutton`、`Scale`、`Scrollbar`、`Menu`、`Entry`、`Listbox`、`Text`、`Canvas` 控件与 `PhotoImage` 图像对象、控件可见性查询，
以及聚焦覆盖的 `pack`、`grid`、`place` 布局行为、通过 `invoke()` 执行的
`Button` / `Checkbutton` / `Radiobutton` command 回调、`Scale` 数值状态、`Scrollbar` 范围状态、`Menu` command 条目、`Entry` 光标与选区状态、事件绑定与合成事件生成、command 参数桥接、图像型控件选项，并包含聚焦覆盖的 `after` /
`mainloop` / `quit` 事件循环切片。

当前开发和测试环境为 AutoHotkey v2.0.26 与 v2.1-alpha.30。

## 项目状态

本项目正在持续重建和补齐中。

当前正在测试的直接模块：

- `collections`, `itertools`, `functools`
- `datetime`, `calendar`, `time`
- `math`, `random`, `statistics`, `decimal`, `fractions`
- `json`, `csv`, `configparser`, `re`, `toml`
- `os`, `pathlib`, `shutil`, `tempfile`, `io`
- `logging`, `queue`, `tkinter`
- `ahktest`, `assert`, `base`, `types`, `warnings`, `operator`

## 快速开始

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

## 设计规则

- 对外公开引入路径使用 `#Include <stdlib\module>`。
- 对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`。
- 模块路径尽量对齐 Python 3.10 `Lib` 标准库路径。
- `stdlib\init.ahk` 是轻量级命名空间根，不承担动态导入加载器职责。
- 提升为正式模块的内容必须在 `stdlib\tests` 下有行为覆盖。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

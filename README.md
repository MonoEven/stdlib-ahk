# stdlib for AutoHotkey v2

`stdlib` is a Python 3.10-inspired standard library for AutoHotkey v2.

`stdlib` 是一个面向 AutoHotkey v2 的标准库项目，设计参考 Python 3.10
标准库的模块划分和常用接口。

## Readme Versions

- [English](README.en.md)
- [中文](README.zh-CN.md)

## Overview

Public modules use the predictable `#Include <stdlib\...>` surface. Promoted
modules include focused behavior tests and examples.

对外公开模块使用稳定的 `#Include <stdlib\...>` 引入路径。提升为正式模块的
内容会配套维护行为测试和示例。

## Requirements

`stdlib` requires AutoHotkey v2.0.5 or later. It is currently developed and
tested with AutoHotkey v2.0.26 and v2.1-alpha.30.
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
window/widget stacking with `lift()` / `tkraise()` / `lower()`,
command argument bridging, Canvas drawing/image/window item creation, discovery, and movement, image-backed widget
options, and a focused `after` / `mainloop` / `quit` event-loop slice.

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本。当前开发和测试环境为
AutoHotkey v2.0.26 与 v2.1-alpha.30。
`stdlib.tkinter` 切片包含用于 `useTk` 支持的 Tcl/Tk 运行时 DLL
（`tcl86t.dll` 与 `tk86t.dll`）。其 CPython 3.10.11 来源与 SHA256
校验报告已随 `stdlib\tkinter\lib\README.md` 和
`stdlib\tkinter\lib\SHA256SUMS` 一起纳入仓库。
当前已覆盖的 GUI 表面包括带选项配置、可见性、状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Tk` 根窗口、带状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Toplevel` 窗口、`Frame`、
`Label`、`Button`、`Checkbutton`、`Radiobutton`、`Scale`、`Scrollbar`、`Menu`、`Entry`、`Listbox`、`Text`、`Canvas` 控件与 `PhotoImage` 图像对象、控件可见性、坐标/尺寸与身份树查询，
以及聚焦覆盖的 `pack`、`grid`、`place` 布局、信息查询、移除、子控件查询与网格几何查询行为、窗口管理 protocol 回调、通过 `invoke()` 执行的
`Button` / `Checkbutton` / `Radiobutton` command 回调、`Scale` 数值状态、`Scrollbar` 范围状态、`Menu` command 条目、`Entry` 光标与选区状态、焦点管理、事件绑定与合成事件生成、`lift()` / `tkraise()` / `lower()` 窗口/控件堆叠、command 参数桥接、Canvas 绘图/图像/窗口项目创建、查询与移动、图像型控件选项，并包含聚焦覆盖的 `after` /
`mainloop` / `quit` 事件循环切片。

## Current Scope

- `collections`, `itertools`, `functools`
- `datetime`, `calendar`, `time`
- `math`, `random`, `statistics`, `decimal`, `fractions`
- `json`, `csv`, `configparser`, `re`, `toml`
- `os`, `pathlib`, `shutil`, `tempfile`, `io`
- `logging`, `queue`, `tkinter`
- `ahktest`, `assert`, `base`, `types`, `warnings`, `operator`

Public calls use `stdlib.module.func(...)` or `stdlib.module.Class(...)`; the
stable include surface remains `#Include <stdlib\module>`.

对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`；稳定
引入面保持为 `#Include <stdlib\module>`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

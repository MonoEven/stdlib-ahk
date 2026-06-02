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
The covered GUI surface currently includes `Tk` roots with option configuration and `keys()` option introspection, visibility, state, transient relationships, overrideredirect, iconify/deiconify,
geometry, and window sizing APIs, `Toplevel` windows with state, transient relationships, overrideredirect, iconify/deiconify, geometry, and sizing APIs,
`Frame`, `Label`, `LabelFrame`, `Message`, `Button`, `Menubutton`, `OptionMenu`, `PanedWindow`, `Checkbutton`, `Radiobutton`, `Scale`, `Scrollbar`, `Menu`, `Entry`, `Spinbox`, `Listbox`, `Text`, and `Canvas` widgets,
`PhotoImage` image objects with pixel, copy/zoom/subsample, transparency, and PNG write coverage, `BitmapImage` image objects with data/file coverage, image registry queries including module-level `image_names()` / `image_types()`, default-root module-level `getboolean(s)` conversion, widget option-key introspection, visibility, coordinate/size, screen metadata, logical screen and virtual-root dimensions, pixel-distance and RGB color winfo queries, visual/colormap/pointer/geometry/id winfo queries, atom/path/containing/interpreter winfo queries, identity-tree queries, and path-to-widget lookup, plus focused `pack`, `grid`, and `place` layout/info/forget/child-query/geometry/row-column-configuration/propagation/anchor
behavior and Python-compatible layout aliases including `pack_configure()`, `grid_configure()`, `place_configure()`, `info()`, `forget()`, `slaves()`, `propagate()`, `anchor()`, `size()`, `bbox()`, and widget `location()`, window-manager protocol callbacks, `Button` / `Checkbutton` / `Radiobutton` command callbacks through `invoke()` plus flash behavior,
`Scale` numeric state, `Scrollbar` range state, `Menu` command entries,
`Entry` cursor/selection/XView/scan state, `Spinbox` value/selection/invoke/XView/scan state, `Listbox` active/nearest/see/view/scan/item-configuration and selection-alias state, `Text` search/count/compare/visual bbox/dlineinfo/see/view/scan, mark, and tag-range state, `OptionMenu` variable/menu/command behavior, `PanedWindow` pane/proxy/sash behavior, default-root variable/widget/image construction, `Message` / `Menubutton` / `LabelFrame` construction and option surfaces, focus management, clipboard access, option database APIs, variable trace callbacks, `getint()` / `getdouble()` / `getboolean()` conversions, event binding, `bind_all()` / `bind_class()` routing, unbind APIs, bind-tag routing, virtual event registry queries, and synthetic event generation,
window/widget stacking with `lift()` / `tkraise()` / `lower()`, local grab state with
`grab_set()` / `grab_release()` / `grab_current()` / `grab_status()`,
window lifecycle waits with `wait_variable()` / `waitvar()` / `wait_window()` / `wait_visibility()`,
command argument bridging, Canvas line/rectangle/oval/polygon/text/arc/bitmap/image/window item creation, text item editing and selection, raw and convenience find queries, discovery, tag management, tag event bindings, movement, absolute movement, coordinate conversion, coordinate scaling, scan-style drag scrolling, item z-order control, item configuration aliases, PostScript export, and scrolling view control, image-backed widget
options, and a focused `after` / `after_idle` / root and module-level `mainloop` / `quit` event-loop slice.

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本。当前开发和测试环境为
AutoHotkey v2.0.26 与 v2.1-alpha.30。
`stdlib.tkinter` 切片包含用于 `useTk` 支持的 Tcl/Tk 运行时 DLL
（`tcl86t.dll` 与 `tk86t.dll`）。其 CPython 3.10.11 来源与 SHA256
校验报告已随 `stdlib\tkinter\lib\README.md` 和
`stdlib\tkinter\lib\SHA256SUMS` 一起纳入仓库。
当前已覆盖的 GUI 表面包括带选项配置、`keys()` 选项自省、可见性、状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Tk` 根窗口、带状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Toplevel` 窗口、`Frame`、
`Label`、`LabelFrame`、`Message`、`Button`、`Menubutton`、`OptionMenu`、`PanedWindow`、`Checkbutton`、`Radiobutton`、`Scale`、`Scrollbar`、`Menu`、`Entry`、`Spinbox`、`Listbox`、`Text`、`Canvas` 控件与覆盖像素、复制、缩放、抽样、透明度和 PNG 写盘的 `PhotoImage` 图像对象、覆盖 data/file 初始化的 `BitmapImage` 图像对象、包含模块级 `image_names()` / `image_types()` 的图像注册表查询、default-root 模块级 `getboolean(s)` 转换、控件选项键自省、可见性、坐标/尺寸、屏幕元数据、逻辑屏幕与 virtual-root 尺寸、像素距离与 RGB 颜色 winfo 查询、visual/colormap/pointer/geometry/id winfo 查询、atom/path/containing/interpreter winfo 查询、身份树查询与路径反查，
以及聚焦覆盖的 `pack`、`grid`、`place` 布局、信息查询、移除、子控件查询、网格几何查询、行列配置、布局传播与 grid anchor 行为，以及 `pack_configure()`、`grid_configure()`、`place_configure()`、`info()`、`forget()`、`slaves()`、`propagate()`、`anchor()`、`size()`、`bbox()`、控件 `location()` 等 Python 兼容布局别名、窗口管理 protocol 回调、`Button` / `Checkbutton` / `Radiobutton` 通过 `invoke()` 执行的 command 回调与 flash 行为、`Scale` 数值状态、`Scrollbar` 范围状态、`Menu` command 条目、`Entry` 光标、选区、XView 与 scan 状态、`Spinbox` 值、选区、invoke、XView 与 scan 状态、`Listbox` active/nearest/see、view、scan、item 配置与 selection 别名状态、`Text` search/count/compare、视觉 bbox/dlineinfo/see、view、scan、mark 与 tag-range 状态、`OptionMenu` 变量、菜单与 command 行为、`PanedWindow` pane/proxy/sash 行为、default-root 变量/控件/图像构造、`Message` / `Menubutton` / `LabelFrame` 构造与选项表面、焦点管理、剪贴板访问、option database API、变量 trace 回调、`getint()` / `getdouble()` / `getboolean()` 转换、事件绑定、`bind_all()` / `bind_class()` 路由、unbind API、bind-tag 路由、虚拟事件注册表查询与合成事件生成、`lift()` / `tkraise()` / `lower()` 窗口/控件堆叠、`grab_set()` / `grab_release()` / `grab_current()` / `grab_status()` 本地 grab 状态、`wait_variable()` / `waitvar()` / `wait_window()` / `wait_visibility()` 变量与窗口生命周期等待、command 参数桥接、Canvas line/rectangle/oval/polygon/text/arc/bitmap/image/window 项目创建、文本项目编辑与选区、原始与便捷 find 查询、项目发现、tag 管理、tag 事件绑定、移动、绝对移动、坐标转换、坐标缩放、scan 拖拽滚动、项目层级控制、项目配置别名、PostScript 导出与滚动视图控制、图像型控件选项，并包含聚焦覆盖的 `after` /
`after_idle` / root 与模块级 `mainloop` / `quit` 事件循环切片。

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
The current full stdlib gate is `953 passed, 0 failed, 0 errors`; the
latest aggregate run completed under `-TimeoutSeconds 40`.

对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`；稳定
引入面保持为 `#Include <stdlib\module>`。
当前完整 stdlib gate 为 `953 passed, 0 failed, 0 errors`；
最新 aggregate 运行已在 `-TimeoutSeconds 40` 下完成。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

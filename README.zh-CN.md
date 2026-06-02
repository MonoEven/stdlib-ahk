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
当前已覆盖的 GUI 表面包括带选项配置、`keys()` 选项自省、可见性、状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Tk` 根窗口、带状态、transient 从属关系、overrideredirect、最小化/恢复、几何尺寸与窗口尺寸 API 的 `Toplevel` 窗口、`Frame`、
`Label`、`LabelFrame`、`Message`、`Button`、`Menubutton`、`OptionMenu`、`Checkbutton`、`Radiobutton`、`Scale`、`Scrollbar`、`Menu`、`Entry`、`Spinbox`、`Listbox`、`Text`、`Canvas` 控件与覆盖像素、复制、缩放、抽样、透明度和 PNG 写盘的 `PhotoImage` 图像对象、覆盖 data/file 初始化的 `BitmapImage` 图像对象、图像注册表查询、控件选项键自省、可见性、坐标/尺寸、屏幕元数据、逻辑屏幕与 virtual-root 尺寸、像素距离与 RGB 颜色 winfo 查询、visual/colormap/pointer/geometry/id winfo 查询、atom/path/containing/interpreter winfo 查询、身份树查询与路径反查，
以及聚焦覆盖的 `pack`、`grid`、`place` 布局、信息查询、移除、子控件查询、网格几何查询、行列配置、布局传播与 grid anchor 行为，以及 `pack_configure()`、`grid_configure()`、`place_configure()`、`info()`、`forget()`、`slaves()`、`propagate()`、`anchor()`、`size()`、`bbox()`、控件 `location()` 等 Python 兼容布局别名、窗口管理 protocol 回调、通过 `invoke()` 执行的
`Button` / `Checkbutton` / `Radiobutton` command 回调、`Scale` 数值状态、`Scrollbar` 范围状态、`Menu` command 条目、`Entry` 光标与选区状态、`Spinbox` 值、选区、invoke 与 XView 状态、`OptionMenu` 变量、菜单与 command 行为、`Message` / `Menubutton` / `LabelFrame` 构造与选项表面、焦点管理、剪贴板访问、option database API、变量 trace 回调、`getint()` / `getdouble()` / `getboolean()` 转换、事件绑定、`bind_all()` / `bind_class()` 路由、unbind API、bind-tag 路由、虚拟事件注册表查询与合成事件生成、`lift()` / `tkraise()` / `lower()` 窗口/控件堆叠、`grab_set()` / `grab_release()` / `grab_current()` / `grab_status()` 本地 grab 状态、`wait_variable()` / `waitvar()` / `wait_window()` / `wait_visibility()` 变量与窗口生命周期等待、command 参数桥接、Canvas line/rectangle/oval/polygon/text/arc/bitmap/image/window 项目创建、文本项目编辑与选区、原始与便捷 find 查询、项目发现、tag 管理、tag 事件绑定、移动、绝对移动、坐标转换、坐标缩放、scan 拖拽滚动、项目层级控制、项目配置别名、PostScript 导出与滚动视图控制、图像型控件选项，并包含聚焦覆盖的 `after` /
`after_idle` / `mainloop` / `quit` 事件循环切片。

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

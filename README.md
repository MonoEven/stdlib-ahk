# stdlib for AutoHotkey v2

## English

`stdlib` brings a Python 3.10-style standard-library surface to AutoHotkey v2.

Public modules keep a stable include path: `#Include <stdlib\...>`. Public APIs are exposed as `stdlib.module.func(...)` and `stdlib.module.Class(...)`.

Use the language-specific READMEs for setup notes, module coverage, and runnable examples.

- [English README](README.en.md)
- [Chinese README](README.zh-CN.md)

### Requirements

AutoHotkey v2.0.5 or later is required. Current local gates run on AutoHotkey v2.0.26 and v2.1-alpha.30.

`stdlib.tkinter` includes `tcl86t.dll` and `tk86t.dll` for `useTk`. The CPython 3.10.11 source reference and SHA256 report are kept in `stdlib\tkinter\lib\README.md` and `stdlib\tkinter\lib\SHA256SUMS`.

### Project Notes

- Behavior tests: `stdlib\tests`
- Examples: `stdlib\examples` and the language-specific READMEs.
  `stdlib\examples\tkinter_gui.ahk` opens a live tkinter / ttk dashboard demo.
- Architecture and promotion history: `docs\stdlib-architecture.md`

## 中文

`stdlib` 将 Python 3.10 风格的标准库接口带到 AutoHotkey v2。

公开模块保持稳定的引入路径：`#Include <stdlib\...>`。公开 API 使用 `stdlib.module.func(...)` 和 `stdlib.module.Class(...)`。

安装说明、模块覆盖范围和可运行示例请查看对应语言版本：

- [英文 README](README.en.md)
- [中文 README](README.zh-CN.md)

### 版本要求

需要 AutoHotkey v2.0.5 或更高版本。当前本地 gate 使用 AutoHotkey v2.0.26 与 v2.1-alpha.30。

`stdlib.tkinter` 内置 `tcl86t.dll` 和 `tk86t.dll` 以支持 `useTk`。CPython 3.10.11 来源记录和 SHA256 校验报告保存在 `stdlib\tkinter\lib\README.md` 与 `stdlib\tkinter\lib\SHA256SUMS`。

### 项目说明

- 行为测试：`stdlib\tests`
- 示例：`stdlib\examples` 与对应语言版本 README。
  `stdlib\examples\tkinter_gui.ahk` 会打开一个实时 tkinter / ttk 仪表盘示例窗口。
- 架构和 promotion 历史：`docs\stdlib-architecture.md`

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

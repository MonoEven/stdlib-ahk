# stdlib for AutoHotkey v2

## English

`stdlib` brings a Python 3.10-style standard-library surface to AutoHotkey v2.

Public modules keep a stable include path: `#Include <stdlib\...>`. Public APIs are exposed as `stdlib.module.func(...)` and `stdlib.module.Class(...)`.

Use the language-specific READMEs for setup notes, current coverage, and runnable examples:

- [English README](README.en.md)
- [Chinese README](README.zh-CN.md)

### Quick Notes

- Requires AutoHotkey v2.0.5 or later.
- Behavior authority is local Python 3.10.11.
- Behavior tests live in `stdlib\tests`.
- Runnable examples live in `stdlib\examples`; richer examples are documented in the language-specific READMEs.
- Architecture and promotion history live in `docs\stdlib-architecture.md`.
- `stdlib.tkinter` includes bundled Tcl/Tk runtime DLLs for `useTk`; source and SHA256 notes live in `stdlib\tkinter\lib`.

## 中文

`stdlib` 将 Python 3.10 风格的标准库接口带到 AutoHotkey v2。

公开模块保持稳定的引入路径：`#Include <stdlib\...>`。公开 API 使用 `stdlib.module.func(...)` 和 `stdlib.module.Class(...)`。

安装说明、当前覆盖范围和可运行示例请查看对应语言版本：

- [英文 README](README.en.md)
- [中文 README](README.zh-CN.md)

### 简要说明

- 需要 AutoHotkey v2.0.5 或更高版本。
- 行为权威是本机 Python 3.10.11。
- 行为测试位于 `stdlib\tests`。
- 可运行示例位于 `stdlib\examples`；更完整的示例说明放在对应语言版本 README。
- 架构和 promotion 历史位于 `docs\stdlib-architecture.md`。
- `stdlib.tkinter` 内置用于 `useTk` 的 Tcl/Tk 运行时 DLL；来源和 SHA256 说明位于 `stdlib\tkinter\lib`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

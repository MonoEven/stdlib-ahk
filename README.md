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

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本。当前开发和测试环境为
AutoHotkey v2.0.26 与 v2.1-alpha.30。
`stdlib.tkinter` 切片包含用于 `useTk` 支持的 Tcl/Tk 运行时 DLL
（`tcl86t.dll` 与 `tk86t.dll`）。其 CPython 3.10.11 来源与 SHA256
校验报告已随 `stdlib\tkinter\lib\README.md` 和
`stdlib\tkinter\lib\SHA256SUMS` 一起纳入仓库。

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

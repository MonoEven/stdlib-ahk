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
  `stdlib\examples\init.ahk` covers root helpers such as `stdlib.await(...)` and `stdlib.decorate(...)`.
  `stdlib\examples\array.ahk` covers fixed-type arrays, sequence operations, binary/unicode conversion, and file round-trips.
  `stdlib\examples\asyncio.ahk` covers the current cooperative asyncio task demo, event-loop lifecycle/time scheduling, AHK-callable `asyncio.coroutine(...)`, `wrap_future(asyncio.Future)` identity, a single-threaded `run_coroutine_threadsafe(...)` bridge, and Windows child-watcher public functions.
  `stdlib\examples\base64.ahk` covers standard, URL-safe, wrapped-bytes, and Base16 codecs.
  `stdlib\examples\binascii.ahk` covers hexlify/unhexlify, crc32, and Base64 ASCII helpers.
  `stdlib\examples\bisect.ahk` covers zero-based insertion points, key functions, and sequence/insert targets.
  `stdlib\examples\calendar.ahk` covers Gregorian date helpers, names, week headers, `timegm`, and `Calendar` month grids.
  `stdlib\examples\collections.ahk` covers `Counter` plus the core `deque`, `defaultdict`, `OrderedDict`, `ChainMap`, `namedtuple`, `UserDict`, `UserList`, and `UserString` public surface.
  `stdlib\examples\contextlib.ahk` covers `nullcontext`, `suppress`, `closing`, `ContextDecorator`, `ExitStack`, and AHK-target `redirect_stdout` / `redirect_stderr` context behavior.
  `stdlib\examples\copy.ahk` covers shallow/deep copy behavior, custom copy hooks, recursive cycles, `Error` / `error`, and the public `dispatch_table` shape.
  `stdlib\examples\csv.ahk` covers reader/writer, dict reader/writer, dialects, `field_size_limit`, and `Sniffer` delimiter/header helpers.
  `stdlib\examples\datetime.ahk` covers date/time/datetime/timedelta behavior, module year bounds, `tzinfo`, `timezone.utc`, and fixed-offset `timezone` basics.
  `stdlib\examples\decimal.ahk` covers Decimal arithmetic plus rounding constants, contexts, `getcontext` / `setcontext` / `localcontext`, and signal exception classes.
  `stdlib\examples\thread.ahk` demonstrates the new process-backed interpreter worker model using Windows system DLL calls, `Event`, `Thread`, `ResultQueue`, JSON-safe `Channel` communication, bounded `SharedMemory` with typed raw slots, broker/proxy `SharedObject` state, `ThreadPool` / `Future` scheduling, done callbacks, ordered `map(...)`, `worker_source` / `task` persistent workers, named mutex synchronization, and captured worker errors.
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
  `stdlib\examples\init.ahk` 覆盖 `stdlib.await(...)` 和 `stdlib.decorate(...)` 等根命名空间 helper。
  `stdlib\examples\array.ahk` 覆盖固定类型数组、序列操作、二进制 / unicode 转换和文件往返。
  `stdlib\examples\asyncio.ahk` 覆盖当前协作式 asyncio task 示例、event-loop 生命周期 / 时间调度、AHK callable `asyncio.coroutine(...)`、`wrap_future(asyncio.Future)` identity、单线程 `run_coroutine_threadsafe(...)` bridge 和 Windows child-watcher 公开函数。
  `stdlib\examples\base64.ahk` 覆盖 standard、URL-safe、wrapped-bytes 和 Base16 codec。
  `stdlib\examples\binascii.ahk` 覆盖 hexlify/unhexlify、crc32 和 Base64 ASCII helper。
  `stdlib\examples\bisect.ahk` 覆盖 zero-based 插入点、key 函数和 sequence/insert 目标。
  `stdlib\examples\calendar.ahk` 覆盖 Gregorian 日期 helper、名称、week header、`timegm` 和 `Calendar` 月表。
  `stdlib\examples\collections.ahk` 覆盖 `Counter` 以及核心 `deque`、`defaultdict`、`OrderedDict`、`ChainMap`、`namedtuple`、`UserDict`、`UserList`、`UserString` public surface。
  `stdlib\examples\contextlib.ahk` 覆盖 `nullcontext`、`suppress`、`closing`、`ContextDecorator`、`ExitStack`，以及面向 AHK target 的 `redirect_stdout` / `redirect_stderr` context 行为。
  `stdlib\examples\copy.ahk` 覆盖 shallow/deep copy 行为、自定义 copy hook、递归 cycle、`Error` / `error`，以及公开 `dispatch_table` 形状。
  `stdlib\examples\csv.ahk` 覆盖 reader/writer、dict reader/writer、dialect、`field_size_limit` 和 `Sniffer` delimiter/header helper。
  `stdlib\examples\datetime.ahk` 覆盖 date/time/datetime/timedelta 行为、模块 year bounds、`tzinfo`、`timezone.utc` 和 fixed-offset `timezone` 基础行为。
  `stdlib\examples\decimal.ahk` 覆盖 Decimal 运算、rounding 常量、context、`getcontext` / `setcontext` / `localcontext` 和 signal 异常类。
  `stdlib\examples\thread.ahk` 展示新的 process-backed 独立解释器 worker 模型，使用 Windows 系统 DLL 调用、`Event`、`Thread`、`ResultQueue`、JSON-safe `Channel` 通信、带 typed raw slot 的有界 `SharedMemory`、broker/proxy `SharedObject` 状态、`ThreadPool` / `Future` 调度、done callback、有序 `map(...)`、`worker_source` / `task` 常驻 worker、named mutex 同步，以及 worker 错误捕获。
- 架构和 promotion 历史：`docs\stdlib-architecture.md`

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

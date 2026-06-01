# AutoHotkey v2 标准库 stdlib

`stdlib` 是一个面向 AutoHotkey v2 的标准库项目，设计参考 Python 3.10
标准库的模块划分和常用接口。

项目通过稳定的 `#Include <stdlib\...>` 引入路径组织模块，并为已提升的
模块维护行为测试和示例。

## 版本要求

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本，主要因为部分模块依赖
`unset` 相关语言特性。

当前开发和测试环境为 AutoHotkey v2.0.26 与 v2.1-alpha.30。

## 项目状态

本项目正在持续重建和补齐中。

当前正在测试的直接模块：

- `collections`, `itertools`, `functools`
- `datetime`, `calendar`, `time`
- `math`, `random`, `statistics`, `decimal`, `fractions`
- `json`, `csv`, `configparser`, `re`, `toml`
- `os`, `pathlib`, `shutil`, `tempfile`, `io`
- `logging`, `queue`
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
- 模块路径尽量对齐 Python 3.10 `Lib` 标准库路径。
- `stdlib\init.ahk` 是轻量级命名空间根，不承担动态导入加载器职责。
- 提升为正式模块的内容必须在 `stdlib\tests` 下有行为覆盖。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

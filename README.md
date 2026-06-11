# stdlib for AutoHotkey v2

## English

`stdlib` brings a Python 3.10-style standard-library surface to AutoHotkey v2.

The public include path is stable:

```autohotkey
#Include <stdlib\module>
```

Public APIs are exposed through the root namespace:

```autohotkey
result := stdlib.module.func(args*)
value := stdlib.module.Class(args*)
```

### Project Notes

| Item | Status |
| --- | --- |
| AutoHotkey | v2.0.5 or later |
| Behavior authority | Local Python 3.10.11 |
| Tests | `stdlib\tests` |
| Examples | `stdlib\examples` |
| Detailed usage | `README.en.md` |
| Architecture notes | `docs\stdlib-architecture.md` |

Current work focuses on practical Python-compatible behavior. `stdlib.pillow` is an independent module and should be included with `#Include <stdlib\pillow>` when needed.

## 中文

`stdlib` 将 Python 3.10 风格的标准库接口带到 AutoHotkey v2。

公开 include 路径保持稳定：

```autohotkey
#Include <stdlib\module>
```

公开 API 通过根命名空间访问：

```autohotkey
result := stdlib.module.func(args*)
value := stdlib.module.Class(args*)
```

### 项目说明

| 项目 | 当前约定 |
| --- | --- |
| AutoHotkey | v2.0.5 或更高版本 |
| 行为权威 | 本机 Python 3.10.11 |
| 测试 | `stdlib\tests` |
| 示例 | `stdlib\examples` |
| 详细用法 | `README.zh-CN.md` |
| 架构说明 | `docs\stdlib-architecture.md` |

当前工作重点是实用的 Python 兼容行为。`stdlib.pillow` 是独立模块，需要时使用 `#Include <stdlib\pillow>` 引入。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

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
- `stdlib.io` provides in-memory `StringIO` and file-like `BytesIO` streams for shared examples and Pillow-style byte APIs.
- `stdlib.pillow` targets full Pillow-style behavior with native Windows imaging. Current promoted coverage includes Image core/helpers, registry dictionaries, font/draw/color/filter/ops/statistics surfaces, BDF/PCF font and palette-file parsers, PSDraw PostScript writer streams, TarIO tar-member streams, PdfParser PDF text/object/xref writer helpers, report `pilinfo` support/format helpers, Windows bridge modules, Pillow image plugins through `TiffImagePlugin`, `WalImageFile`, WIC-backed `WebPImagePlugin`, `WmfImagePlugin`, `XbmImagePlugin`, `XpmImagePlugin`, and `XVThumbImagePlugin`, including PNG/BMP/JPEG/GIF/TIFF/ICNS/ICO/IM/IMT/IPTC/JPEG2000/MCIDAS/MIC/MPEG/MPO/MSP/PALM/PCD/PCX/PDF/PXR/PSD/QOI/SGI/SPIDER/SUN/TGA/TIFF/XBM/XPM path and file-like byte streams plus GIF save_all two-frame streams, MPO animated-source save_all resaves, Teragon/GIMP palette streams, PCF bitmap glyph streams, WAL direct/open texture streams, WebP RGB/RGBA single-frame and full-frame animated streams, WMF/EMF header/handler streams, XBM bitmap open/save streams, XPM pixel-map open streams, and XV thumbnail P-mode byte streams.
- Latest Pillow promotion: `ImageFile.SAFEBLOCK`, `ImageFile.ImageFile`, `PyCodec`, `PyCodecState`, `PyDecoder`, `PyEncoder`, `StubHandler`, `StubImageFile`, and `raise_oserror(...)` now cover the probed Pillow 11.3.0 public base/codec/stub surface, alongside the existing incremental `ImageFile.Parser()` bridge.
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
- `stdlib.io` 提供内存 `StringIO` 和 file-like `BytesIO`，用于共享示例和 Pillow 风格字节 API。
- `stdlib.pillow` 的目标是用 Windows 原生图像栈复现 Pillow 行为。当前覆盖 Image core/helper、registry dictionary、font/draw/color/filter/ops/statistics、BDF/PCF font 与 palette-file parser、PSDraw PostScript writer 字节流、TarIO tar member 字节流、PdfParser PDF text/object/xref writer helper、report `pilinfo` 支持/格式报告 helper、Windows bridge 模块、推进到 `TiffImagePlugin` 的 Pillow image plugin、`WalImageFile`、WIC-backed `WebPImagePlugin`、`WmfImagePlugin`、`XbmImagePlugin`、`XpmImagePlugin` 和 `XVThumbImagePlugin`，包括 PNG/BMP/JPEG/GIF/TIFF/ICNS/ICO/IM/IMT/IPTC/JPEG2000/MCIDAS/MIC/MPEG/MPO/MSP/PALM/PCD/PCX/PDF/PXR/PSD/QOI/SGI/SPIDER/SUN/TGA/TIFF/XBM/XPM 路径及 file-like 字节流、GIF save_all 两帧字节流、MPO animated-source save_all 重新保存、Teragon/GIMP palette 字节流、PCF bitmap glyph 字节流、WAL direct/open texture stream、WebP RGB/RGBA 单帧和 full-frame animated stream、WMF/EMF header/handler stream、XBM bitmap open/save stream、XPM pixel-map open stream，以及 XV thumbnail P-mode 字节流。
- 最新 Pillow promotion：`ImageFile.SAFEBLOCK`、`ImageFile.ImageFile`、`PyCodec`、`PyCodecState`、`PyDecoder`、`PyEncoder`、`StubHandler`、`StubImageFile` 和 `raise_oserror(...)` 已覆盖探测到的 Pillow 11.3.0 公共 base/codec/stub surface，并与现有的 `ImageFile.Parser()` 增量桥接一起工作。
- 架构和 promotion 历史位于 `docs\stdlib-architecture.md`。
- `stdlib.tkinter` 内置用于 `useTk` 的 Tcl/Tk 运行时 DLL；来源和 SHA256 说明位于 `stdlib\tkinter\lib`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

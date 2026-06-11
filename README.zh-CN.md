# AutoHotkey v2 标准库 stdlib

`stdlib` 是一个面向 AutoHotkey v2 的标准库项目，设计参考 Python 3.10
标准库的模块划分和常用接口。

项目通过稳定的 `#Include <stdlib\...>` 引入路径组织模块，并为已提升的
模块维护行为测试和示例。

## 版本要求

`stdlib` 需要 AutoHotkey v2.0.5 或更高版本，主要因为部分模块依赖
`unset` 相关语言特性。当前开发和测试环境为 AutoHotkey v2.0.26 与
v2.1-alpha.30。

本机行为探针以 Python 3.10.11 为权威。

## 运行时资源

| 范围 | 说明 |
| --- | --- |
| `stdlib.tkinter` | 内置用于 `useTk` 的 `tcl86t.dll` 与 `tk86t.dll`；来源和 SHA256 说明位于 `stdlib\tkinter\lib`。 |

## 覆盖与示例

<details>
<summary>已提升示例索引</summary>

| 示例 | 主要覆盖 |
| --- | --- |
| `stdlib\examples\abc.ahk` | abstract marker 与构造错误、`abstractproperty` getter/setter/deleter wrapper、virtual subclass registration、防循环 `register`、cache token、`update_abstractmethods`、`__subclasshook`。 |
| `stdlib\examples\array.ahk` | 固定类型数组、只读元数据、根 bool 值/索引/搜索、字符串/bytes 初始化和 extend 规则、unicode repr、原地特殊方法、`stdlib.slice` 索引和赋值快照、copy/deepcopy、二进制/unicode 转换、文件往返和 EOF 读取。 |
| `stdlib\examples\asyncio.ahk` | 协作式 future/task、event loop 生命周期、调度、`gather`、队列、异常构造器、protocol/transport 基类、server 生命周期、`StreamReader` 缓冲读取、stream writer 包装、`IocpProactor` 生命周期/socket ops、`to_thread` callable await、localhost TCP `open_connection` / `start_server`、子进程 `Process.wait()` / `communicate()` stdout/stderr/stdin pipe、`STDOUT` / `DEVNULL`、生命周期控制、`stdlib.await(...)`。 |
| `stdlib\examples\base64.ahk` | standard、URL-safe、wrapped-bytes、Base16、Base32 和 Base85 codec。 |
| `stdlib\examples\binascii.ahk` | hexlify/unhexlify、CRC32、Base64 ASCII helper。 |
| `stdlib\examples\bisect.ahk` | zero-based 插入点、key 函数、sequence/insert 目标。 |
| `stdlib\examples\calendar.ahk` | Gregorian helper、名称、week header、`timegm`、`Calendar` 月表。 |
| `stdlib\examples\collections.ahk` | `Counter`、`deque`、`defaultdict`、`OrderedDict`、`ChainMap`、named/user container。 |
| `stdlib\examples\contextlib.ahk` | `nullcontext`、`suppress`、`closing`、`ContextDecorator`、`ExitStack`、redirect。 |
| `stdlib\examples\copy.ahk` | shallow/deep copy、自定义 hook、cycle、`Error` / `error`、`dispatch_table`。 |
| `stdlib\examples\csv.ahk` | reader/writer、dict reader/writer、dialect、`field_size_limit`、`Sniffer`。 |
| `stdlib\examples\datetime.ahk` | date/time/datetime/timedelta、边界、`tzinfo`、fixed-offset `timezone`。 |
| `stdlib\examples\decimal.ahk` | Decimal 运算、context、rounding 常量、signal 异常类。 |
| `stdlib\examples\init.ahk` | 根 helper，包括 builtin-style error、`stdlib.slice(...)`、`stdlib.await(...)` 和 `stdlib.decorate(...)`。 |
| `stdlib\examples\io.ahk` | 内存文本与 file-like 字节流，覆盖 `StringIO`、`BytesIO`、`read`/`readline`/`read1`/`readinto`/`readinto1`、`write`/`writelines`、`seek`、`tell`、`getvalue`、`flush`、能力查询和关闭状态。 |
| `stdlib\examples\pillow.ahk` | 基于 Windows 图像栈的 `stdlib.pillow.Image` 核心：Image mode/init/endian helper（`preinit`/`init`/`i32le`/`o32le`/`o32be`）、public Image errors/constants/Exif mapping/ExifTags/TiffTags/features/JpegPresets/FontFile/BdfFontFile/PcfFontFile/ContainerIO/AvifImagePlugin/BlpImagePlugin/BmpImagePlugin/BufrStubImagePlugin/CurImagePlugin/DcxImagePlugin/DdsImagePlugin/EpsImagePlugin/FitsImagePlugin/FliImagePlugin/FpxImagePlugin/FtexImagePlugin/GbrImagePlugin/GdImageFile/GifImagePlugin/GimpGradientFile/GimpPaletteFile/GribStubImagePlugin/Hdf5StubImagePlugin/IcnsImagePlugin、`ImageMode.getmode` / `ModeDescriptor`、`ImagePalette.ImagePalette` / `raw` / `wedge` / `sepia` / LUT helper、`ImageTransform` 描述对象、`ImagePath.Path` 坐标路径、`ImageMath` 表达式 helper、`ImageFile.Parser` 增量解码、`ImageFont.ImageFont` base 默认行为、`ImageFont.is_path` / `DeferredError`、`ImageFont.load_default`、`load_default_imagefont` 与 `ImageFont.load` / `load_path` bitmap font 度量以及直接 `ImageFont.FreeTypeFont`、`ImageFont.truetype` / `FreeTypeFont.getname` / `getmetrics` / `font_variant` / `ImageFont.TransposedFont`、ImageDraw2 Pen/Brush/Font/Draw 基础几何和 arc/chord/pieslice/settransform/render/text/textbbox/textlength 分发、模块级 helper/工厂（`is_path`/`new`/`open`/`frombytes`/`frombuffer`）、format 与 codec registry dictionary/helper（`OPEN`/`SAVE`/`SAVE_ALL`/`DECODERS`/`ENCODERS`/`EXTENSION`/`MIME`/`ID`/`MODES`、`registered_extensions`/`register_*`，自定义 open factory 调度，通过非 raw `frombytes`/`tobytes` 调用自定义 decoder/encoder，并调用自定义 save/save_all handler）、`features` support/version 查询和 `pilinfo`、JPEG preset quantization table、JpegImagePlugin JPEG metadata/header helper、FontFile.puti16 与 BdfFontFile/PcfFontFile bitmap font parse/compile/save 路径、ContainerIO bounded file-like region 读取、AvifImagePlugin accept/codec/version helper 与 AVIF registry 参数校验、BlpImagePlugin enum-like 常量、accept/565/DXT helper 以及 P-mode BLP1/BLP2 file-like 保存/打开往返、BmpImagePlugin BMP/DIB helper 与 factory 接口、BufrStubImagePlugin accept/handler/open/save stub adapter 接口、CurImagePlugin accept/CUR file-like 打开和最大 cursor 选择、DcxImagePlugin accept/DCX file-like RGB PCX frame 打开和 seek/tell、DdsImagePlugin 常量/enum-like flag 与 RGB/RGBA/L/LA raw DDS file-like 保存/打开往返、EpsImagePlugin EPS header 解析、registry、Ghostscript 可用性探测和 RGB/L EPS file-like 保存、FitsImagePlugin FITS header 解析、registry、raw/gzip tile metadata 与 direct/Image.open file-like metadata 打开、FliImagePlugin FLI/FLC header 解析、palette metadata、animation frame metadata 与 direct/Image.open file-like metadata 打开、FpxImagePlugin FlashPix OLE accept/registry 以及 direct/Image.open fake-OLE metadata 打开、FtexImagePlugin enum/registry 以及 uncompressed RGB 与 DXT1 tile metadata 打开、GbrImagePlugin GIMP brush v1/v2 L/RGBA metadata 与 pixel 打开、GdImageFile 直接 GD P-mode palette-index 加载、RGBX palette/transparency metadata 和不注册 Image.open 行为、GifImagePlugin GIF87a/GIF89a metadata/palette/pixel and file-like round-trips, GimpGradientFile `.ggr` parser and RGBA palette generation, GimpPaletteFile `.gpl` parser/frombytes RGB palette loading, GribStubImagePlugin GRIB accept/handler/open/save stub adapter surface, Hdf5StubImagePlugin HDF5 signature/handler/open/save stub adapter surface, IcnsImagePlugin PNG-backed ICNS container open/save, IcoImagePlugin PNG/BMP-backed ICO container open/save, ImImagePlugin IFUNC IM text-header/LUT/frame open/save, ImtImagePlugin IM Tools text-header L-image direct/open 与 no-extension registry 行为, JpegImagePlugin JPEG metadata direct and `Image.open(..., ["JPEG"])` paths, Jpeg2KImagePlugin JP2/J2K metadata direct/open 行为, ImageCms sRGB profile metadata 与 identity transform helper、ImageGrab 1x1 屏幕截图/keyword option/剪贴板访问、ImageWin HDC/HWND/Dib/window wrapper helper、ImageQt Qt image bridge helper、ImageMorph 二值形态学 LUT builder 与 MorphOp apply/match/LUT 文件 helper，`Dither`/`Quantize`/`Transform`/`Transpose`/`Resampling` 常量、`isImageType`、linear/radial gradient、Mandelbrot/noise 图像生成、ImageColor parser/string color、实例元数据（`readonly`/`format_description`/`draft`/`get_child_images`/`getxmp`/`getim`/`im`）、图像 inspection（`getbands`/`getbbox`/`getextrema`/`getcolors`/`histogram`/`entropy`/`getprojection`）、`ImageStat.Stat` 的 count/sum/sum2/mean/median/rms/var/stddev/extrema 统计、`ImageSequence.Iterator` / `all_frames` 单帧迭代和帧 copy helper、data access（`getdata`/`tobytes`/`tobitmap`/`frombytes`/`putdata`）、palette access（`getpalette`/`putpalette`/`remap_palette`）、palette transparency（`info["transparency"]` / `has_transparency_data` / `apply_transparency`）、frame lifecycle（`tell`/`seek`/`verify`）、ImageDraw point/line/bitmap/floodfill/rectangle/polygon outline width/regular_polygon/ellipse/arc/chord/pieslice/circle/rounded-rectangle geometry、RGB/L/RGBA/LA/1/P `new`、`open`、PNG/BMP/JPEG/TIFF `open`/`save` 与 file-like 输入/输出（含 `L` TIFF 往返）、RGBA PNG alpha 重开、pixel、channel、split/merge、point/eval、ImageFilter kernel/box/GaussianBlur/UnsharpMask/Color3DLUT/rank filter、ImageChops arithmetic/blend/composite/light/logical channel ops、ImageOps color/geometry ops（含 `contain`/`cover`/`scale`/`pad`/`fit`/`autocontrast`/`equalize`/`colorize`/`deform`/`exif_transpose`）、ImageEnhance brightness/color/contrast/sharpness、putalpha、paste、copy、crop、resize、transform、quantize、reduce、thumbnail、effect_spread、convert、transpose、rotate、blend、composite mask、alpha composite、close。 |
| `stdlib\examples\pillow.ahk` | TarIO tar member 字节流，覆盖 member 查找、bounded read、seek/tell、line read、能力查询和关闭状态。 |
| `stdlib\examples\pillow.ahk` | PdfParser 低层 PDF helper：文本编码/解码、`PdfName`/`PdfArray`/`PdfDict`、xref 输出和最小 object writer stream。 |
| `stdlib\examples\pillow.ahk` | `report.pilinfo` 支持报告，可选输出已支持格式列表。 |
| `stdlib\examples\thread.ahk` | process-backed worker、channel、shared memory、shared-object broker、线程池。 |
| `stdlib\examples\tkinter_gui.ahk` | 实时 tkinter / ttk 窗口、变量、布局、回调、canvas、tree 数据。 |

</details>

当前 Pillow 追加覆盖：`IptcImagePlugin` 的 IPTC/NAA helper、`.iim` 注册、direct 与 `Image.open(..., ["IPTC"])` raw L file-like 打开、重复 metadata tag 和 `getiptcinfo`；`JpegImagePlugin` 的 JPEG accept、registry、JFIF density、quantization、sampling 与 metadata direct/open 路径；`Jpeg2KImagePlugin` 的 JP2/J2K accept、registry、DPI、JPX mimetype、codestream comment 与 metadata direct/open 路径；`McIdasImagePlugin` 的 MCIDAS area accept、registry、无 extension/MIME 行为、descriptor metadata、1-byte L pixel load，以及 2/4-byte raw tile metadata direct/open 路径；`MicImagePlugin` 的 MIC/OLE accept、`.mic` 注册、fake-OLE `.ACI/Image` TIFF 子流加载、close 行为和 `Image.open(..., ["MIC"])` fallback error；`MpegImagePlugin` 的 BitStream bit 解析、MPEG sequence header 尺寸 metadata、`.mpg`/`.mpeg` 与 MIME 注册，以及不解码的 `load()` error；`MpoImagePlugin` 的 MPF/MPO frame metadata、JPEG factory `Image.open(..., ["JPEG"])` 自动提升、`adopt`、seek/tell、`.mpo`/MIME/save/save_all 注册、单帧/多帧 MPO file-like 保存，以及 animated source 的 `save_all=True` 重新保存；`MspImagePlugin` 的 DanM raw 与 LinS RLE Windows Paint MSP 打开路径、`MspDecoder`、`.msp`/open/save/decoder 注册、mode `1` 逐行补齐字节和 MSP file-like 保存；`PalmImagePlugin` 的 Palm colormap/prototype 常量、`.palm`/MIME/save 注册、mode `1` 与 `P` file-like 保存，以及当前 Pillow 11.3.0 的 `L`/非法模式错误行为；`PcdImagePlugin` 的 Kodak PhotoCD metadata 打开、`.pcd` extension/open 注册且没有 accept function、orientation post-rotate metadata、`pcd` tile metadata 和无像素数据时的 load error；`PcxImagePlugin` 的 Paintbrush `_accept`/binary helper/SAVE map、`.pcx`/MIME/open/save 注册、1/L/P/RGB RLE file-like 打开与保存、palette 处理、dpi metadata 和已覆盖错误路径；`PdfImagePlugin` 的 output-only `.pdf`/MIME/save/save_all 注册、RGB/L DCT PDF image stream、P indexed ASCIIHex stream、mode `1` CCITT metadata、title/author metadata、dpi/resolution MediaBox、多页 `append_images`，以及 arity/unsupported-mode 错误路径；`PixarImagePlugin` 的 PIXAR raster `_accept`/`i16` helper、`.pxr`/open 注册且无 save/MIME、direct 与 `Image.open(..., ["PIXAR"])` RGB raw file-like 加载、tile metadata，以及 bad magic/unknown-mode/arity 错误路径；`PngImagePlugin` 的 PNG magic/字节 helper/CRC/CID 检查、`PngInfo` text/iTXt chunk helper、`putchunk`/`getchunks`、registry、metadata direct/open 读取，以及携带 metadata 的 RGB/RGBA/L file-like 保存；`PpmImagePlugin` 的 PBM/PGM/PPM/PFM accept/registry 行为、plain/raw bitmap/gray/RGB/CMYK/P/RGBA/F file-like 打开、16-bit gray 与 PFM scale metadata，以及 mode `1`/`L`/`I`/`RGB`/`RGBA`/`F` file-like 保存；`PsdImagePlugin` 的 PSD accept/registry 行为、L/RGB/RGBA/P/CMYK raw file-like 打开、ICC resource、延迟 layer metadata、`seek`/`tell`，以及 constructor/header/channel/mode/layer-block 错误路径；`QoiImagePlugin` 的 QOI accept/open/save registry 行为、decoder/encoder factory、RGB/RGBA direct 与 `Image.open(..., ["QOI"])` file-like 打开、包含 `colorspace="sRGB"` 的精确 file-like 保存，以及 bad-magic/unsupported-mode/constructor arity 路径。

当前 Pillow 追加覆盖还包括：`SgiImagePlugin` 的 SGI `MODES`/`i16`/`o8`/`_accept` helper、`.bw`/`.rgb`/`.rgba`/`.sgi` 与 MIME 注册、`SGI16Decoder` metadata、raw/RLE SGI file-like 打开、`Image.open(..., ["SGI"])`、RGB/RGBA/L file-like 保存，以及 constructor/save 错误路径；`SpiderImagePlugin` 的 SPIDER `iforms`/`isInt`/`isSpiderHeader`/`isSpiderImage` helper、`SpiderImageFile` float 图像 direct 与 `Image.open(..., ["SPIDER"])` file-like 打开、little/big-endian raw mode、stack `seek`/`tell`、`convert2byte`、file-like/path 保存与动态 `.spi` 注册，以及 header/stack/constructor/save 错误路径；`SunImagePlugin` 的 Sun raster `_accept`、`.ras` open 注册、raw 1/4/8/24/32-bit 与 RLE file-like 打开、palette 处理，以及显式不支持保存行为；`TgaImagePlugin` 的 TGA `MODES`/`SAVE`、`.tga`/`.icb`/`.vda`/`.vst` 与 MIME 注册、raw/RLE file-like 打开、orientation 和 ID metadata、file-like 保存，以及 unsupported-mode 错误；`TiffImagePlugin` 的 TIFF constant/map/helper、prefix accept、`.tif`/`.tiff` 与 MIME 注册、direct 和 registered file-like 打开、save/save_all registry，以及已覆盖模式的 baseline/GDI-backed file-like 保存；`WalImageFile` 的 Quake2 WAL direct/open-function texture 加载、P-mode 像素、name/next-name metadata 和完整默认 Quake2 palette，且不注册到 `Image.open()`；`WebPImagePlugin` 的 `SUPPORTED`、VP8 mode mapping、`_accept`、`.webp`/MIME/open/save/save_all registry presence、WIC-backed 单帧 RGB/RGBA direct 和 registered file-like 打开、full-frame lossless animated WebP 的 `seek`/`tell`/`load_seek` metadata 与像素，以及 `_convert_frame`，复杂 blend/dispose 合成和真实 WebP 编码仍后续推进；`WmfImagePlugin` 的 `word`/`short`/`_long`、`_accept`、默认/custom handler 注册、WMF/EMF header 解析、`.wmf`/`.emf` open/save registry presence、custom handler load/save 委托、DPI size 更新，以及 invalid-header/save-without-handler 错误路径；`XbmImagePlugin` 的 whitespace-tolerant `_accept`、`XbmImageFile` direct 与 registered file-like 打开、hotspot metadata、XBM tile offset、`.xbm`/MIME/open/save 注册、mode `1` bitmap file-like 保存（含 hotspot encoder option），以及 bad-header/truncated-data/unsupported-mode 错误路径；`XpmImagePlugin` 的 XPM `_accept`、`XpmImageFile` 与 `XpmDecoder`、`.xpm`/MIME/open/decoder 注册且无 save 注册、P-mode palette/transparent-key file-like 打开、RGB 257 色 file-like 打开、tile metadata，以及 bad-header/palette/truncated-data 错误路径；`XVThumbImagePlugin` 的 `_MAGIC`/RGB332 `PALETTE`、`_accept`、uppercase `XVTHUMB` open registry、无 save/extension/MIME 注册、P-mode palette 图像 direct 与 `Image.open(..., ["XVThumb"])` file-like 打开、comment/whitespace header 解析、lazy pixel loading，以及 bad-magic/EOF/invalid-size/truncated-data 错误路径。

最新 Pillow promotion：`ImageFile.SAFEBLOCK`、`ImageFile.ImageFile`、`PyCodec`、`PyCodecState`、`PyDecoder`、`PyEncoder`、`StubHandler`、`StubImageFile` 和 `raise_oserror(...)` 已覆盖探测到的 Pillow 11.3.0 公共 base/codec/stub surface，并与现有的 `ImageFile.Parser()` 增量桥接一起工作。

## 快速开始

### 小模块示例

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

<details>
<summary>Thread worker、channel、shared memory 和线程池示例</summary>

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\thread>

ready := stdlib.thread.Event()
ready.set()

channel := stdlib.thread.Channel()
memory := stdlib.thread.SharedMemory({ size: 128 })
shared := stdlib.thread.SharedObject(Map("count", 0, "items", []))
memory.write("abcd", 0)
worker := stdlib.thread.Thread({
    name: "calc-worker",
    channel: channel,
    shared_memory: memory,
    shared_objects: Map("state", shared),
    source: "channel := stdlib.thread.current_channel()`n"
        . "memory := stdlib.thread.current_shared_memory()`n"
        . "request := channel.recv_worker(2)`n"
        . "seen := memory.read_text(0, 4)`n"
        . "memory.write(`"WXYZ`", 4)`n"
        . "memory.synchronized((shared) => (`n"
        . "    shared.write_json(Map(`"seen`", seen), 16, 48),`n"
        . "    shared.put(request[`"value`"] * 2, 80, `"UInt`"),`n"
        . "    shared.put(-123, 84, `"Int`")`n"
        . "), 2)`n"
        . "channel.send_worker(Map(`"answer`", memory.get(80, `"UInt`"), `"label`", request[`"label`"], `"address_type`", Type(memory.address)))`n"
        . "state := stdlib.thread.current_shared_object(`"state`")`n"
        . "state.acquire(true, 2)`n"
        . "try {`n"
        . "    state.append(`"items`", request[`"label`"])`n"
        . "    state.set(`"count`", state.get(`"count`") + 1)`n"
        . "} finally {`n"
        . "    state.release()`n"
        . "}`n"
        . "thread_result := Map(`"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))"
})
worker.start()
channel.send(Map("value", 21, "label", "json-message"))
reply := channel.recv(2)
worker.join(2)

result := worker.result()
worker_answer := reply["answer"]
worker_label := reply["label"]
worker_native_id := result["native_id"]
shared_text := memory.read_text(4, 4)
shared_payload := memory.read_json(16, 48)
shared_answer_slot := memory.get(80, "UInt")
shared_signed_slot := memory.get(84, "Int")
shared_state := shared.snapshot()

pool := stdlib.thread.ThreadPool({ max_workers: 1 })
first_future := pool.submit({ source: "thread_result := `"first`"" })
second_future := pool.submit({ source: "thread_result := `"second`"" })
future_events := []
first_future.add_done_callback((future) => future_events.Push(future.result()))
second_running_before := second_future.running()
first_value := first_future.result(2)
second_future.add_done_callback((future) => future_events.Push(future.result()))
second_value := stdlib.await(second_future, { timeout: 2 })
mapped_values := pool.map((value) => { source: "thread_result := " (value * 10) }, [3, 1, 2])
pool.shutdown()

persistent_pool := stdlib.thread.ThreadPool({
    max_workers: 1,
    worker_source: "AhkStdlibThreadPoolHandleTask(task) {`n"
        . "    return Map(`"label`", task[`"label`"], `"value`", task[`"value`"] * 10, `"pid`", DllCall(`"kernel32\GetCurrentProcessId`", `"UInt`"), `"native_id`", DllCall(`"kernel32\GetCurrentThreadId`", `"UInt`"))`n"
        . "}"
})
persistent_first := persistent_pool.submit({ task: Map("label", "first", "value", 1) }).result(2)
persistent_second := persistent_pool.submit({ task: Map("label", "second", "value", 2) }).result(2)
persistent_reused_worker := persistent_first["pid"] = persistent_second["pid"]
persistent_pool.shutdown()

channel.close()
memory.close()
```

</details>

<details>
<summary>tkinter / ttk 实时窗口示例</summary>

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\tkinter>

root := stdlib.tkinter.Tk()
root.title("stdlib tkinter demo")
root.geometry("740x480")

count := 0
name := stdlib.tkinter.StringVar(root, "AutoHotkey")
stage := stdlib.tkinter.StringVar(root, "draft")
status := stdlib.tkinter.StringVar(root, "Ready")
scoreValue := stdlib.tkinter.DoubleVar(root, 42)

style := stdlib.tkinter.ttk.Style(root)
try style.theme_use("clam")
style.configure("App.TFrame", { padding: 14 })
style.configure("Demo.Treeview", { rowheight: 24, foreground: "navy" })
style.map("Demo.Treeview", { foreground: [["selected", "white"]], background: [["selected", "#2878b8"]] })

main := stdlib.tkinter.ttk.Frame(root, { padding: [16, 14], style: "App.TFrame" })
main.grid({ row: 0, column: 0, sticky: "nsew" })
root.columnconfigure(0, { weight: 1 })
root.rowconfigure(0, { weight: 1 })
main.columnconfigure(1, { weight: 1 })
main.rowconfigure(3, { weight: 1 })

stdlib.tkinter.ttk.Label(main, { text: "Name" })
    .grid({ row: 0, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
entry := stdlib.tkinter.ttk.Entry(main, { textvariable: name, width: 24 })
entry.grid({ row: 0, column: 1, pady: 6, sticky: "ew" })

stdlib.tkinter.ttk.Label(main, { text: "Stage" })
    .grid({ row: 1, column: 0, padx: [0, 8], pady: 6, sticky: "w" })
stageChoice := stdlib.tkinter.ttk.Combobox(main, { textvariable: stage, values: ["draft", "review", "ship"], state: "readonly" })
stageChoice.grid({ row: 1, column: 1, pady: 6, sticky: "ew" })
stageChoice.current(0)

scoreRow := stdlib.tkinter.ttk.Frame(main)
scoreRow.grid({ row: 2, column: 0, columnspan: 2, pady: 8, sticky: "ew" })
scoreRow.columnconfigure(0, { weight: 1 })
scoreScale := stdlib.tkinter.ttk.Scale(scoreRow, { variable: scoreValue, from_: 0, to: 100, command: update_demo })
scoreScale.grid({ row: 0, column: 0, padx: [0, 10], sticky: "ew" })
progress := stdlib.tkinter.ttk.Progressbar(scoreRow, { maximum: 100, variable: scoreValue, mode: "determinate" })
progress.grid({ row: 0, column: 1, sticky: "ew" })

canvas := stdlib.tkinter.Canvas(main, { width: 300, height: 120, bg: "white", highlightthickness: 0 })
canvas.grid({ row: 3, column: 0, padx: [0, 12], pady: 8, sticky: "nsew" })
canvas.create_rectangle(12, 16, 288, 104, { fill: "#f7fbff", outline: "#d4e3ef" })
bar := canvas.create_rectangle(24, 72, 24, 92, { fill: "#2878b8", outline: "#2878b8" })
caption := canvas.create_text(24, 30, { text: "Ready", anchor: "nw", fill: "#203040" })

tree := stdlib.tkinter.ttk.Treeview(main, {
    columns: ["value"],
    show: ["tree", "headings"],
    height: 5,
    style: "Demo.Treeview"
})
tree.heading("#0", { text: "Signal" })
tree.heading("value", { text: "Value" })
tree.column("#0", { width: 120, anchor: "w" })
tree.column("value", { width: 100, anchor: "center" })
tree.insert("", "end", "stage", { text: "Stage", values: [stage.get()] })
tree.insert("", "end", "score", { text: "Score", values: [scoreValue.get() "%"] })
tree.insert("", "end", "updates", { text: "Updates", values: [0], tags: ["dynamic"] })
tree.tag_configure("dynamic", { foreground: "navy" })
tree.grid({ row: 3, column: 1, pady: 8, sticky: "nsew" })

notebook := stdlib.tkinter.ttk.Notebook(main, { height: 70 })
firstPage := stdlib.tkinter.ttk.Frame(notebook)
secondPage := stdlib.tkinter.ttk.Frame(notebook)
notebook.add(firstPage, { text: "Summary", padding: 8 })
notebook.add(secondPage, { text: "Details", padding: 8 })
stdlib.tkinter.ttk.Label(firstPage, { textvariable: status }).grid({ row: 0, column: 0, sticky: "w" })
stdlib.tkinter.ttk.Label(secondPage, { text: "Variables, layout, callbacks, canvas, and ttk widgets." }).grid({ row: 0, column: 0, sticky: "w" })
notebook.grid({ row: 4, column: 0, columnspan: 2, pady: [6, 0], sticky: "ew" })

button := stdlib.tkinter.ttk.Button(main, { text: "Update", command: update_demo })
button.grid({ row: 5, column: 0, columnspan: 2, pady: 10, sticky: "ew" })

update_demo(*) {
    global count, name, stage, status, scoreValue, canvas, bar, caption, tree
    count += 1
    score := Integer(scoreValue.get())
    status.set(stage.get() " for " name.get() ": " score "%")
    canvas.coords(bar, 24, 72, 24 + Round(score * 2.4), 92)
    canvas.itemconfigure(caption, { text: status.get() })
    tree.set("stage", "value", stage.get())
    tree.set("score", "value", score "%")
    tree.set("updates", "value", count)
    tree.selection_set(["updates"])
    tree.see("updates")
    return stdlib.None
}

update_demo()
root.mainloop()
```

</details>

## 设计规则

- 对外公开引入路径使用 `#Include <stdlib\module>`。
- 对外调用使用 `stdlib.module.func(...)` 或 `stdlib.module.Class(...)`。
- 模块路径尽量对齐 Python 3.10 `Lib` 标准库路径。
- `stdlib\init.ahk` 是轻量级命名空间根，不承担动态导入加载器职责。
- 提升为正式模块的内容必须在 `stdlib\tests` 下有行为覆盖。
- README 保持面向使用者的稳定内容；具体模块 promotion 和 gate 历史维护在
  `docs\stdlib-architecture.md`。

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

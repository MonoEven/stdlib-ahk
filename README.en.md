# stdlib for AutoHotkey v2

A Python 3.10-inspired standard library for AutoHotkey v2.

`stdlib` rebuilds common standard-library modules behind a predictable
`#Include <stdlib\...>` surface, with focused behavior tests and examples for
each promoted module.

## Requirements

`stdlib` requires AutoHotkey v2.0.5 or later because several modules depend on
`unset`-related language features. It is currently developed and tested with
AutoHotkey v2.0.26 and v2.1-alpha.30.

Local behavior probes use Python 3.10.11 as the authority.

## Runtime Assets

| Area | Notes |
| --- | --- |
| `stdlib.tkinter` | Bundles `tcl86t.dll` and `tk86t.dll` for `useTk`. Source and SHA256 notes are in `stdlib\tkinter\lib`. |

## Coverage And Examples

<details>
<summary>Promoted example index</summary>

| Example | Main coverage |
| --- | --- |
| `stdlib\examples\abc.ahk` | Abstract markers and constructor errors, `abstractproperty` getter/setter/deleter wrappers, virtual subclass registration, cycle-safe `register`, cache tokens, `update_abstractmethods`, `__subclasshook`. |
| `stdlib\examples\array.ahk` | Fixed-type arrays, readonly metadata, root bool values/index/search, string/bytes initializer and extend rules, unicode repr, in-place special methods, `stdlib.slice` indexing and assignment snapshots, copy/deepcopy, binary/unicode conversion, file round-trips and EOF reads. |
| `stdlib\examples\asyncio.ahk` | Cooperative futures/tasks, event-loop lifecycle, scheduling, `gather`, queues, exception constructors, protocol/transport bases, server lifecycle, `StreamReader` buffering, stream writer wrapping, `IocpProactor` lifecycle/socket ops, `to_thread` callable awaits, localhost TCP `open_connection` / `start_server`, subprocess `Process.wait()` / `communicate()` stdout/stderr/stdin pipes, `STDOUT` / `DEVNULL`, lifecycle controls, `stdlib.await(...)`. |
| `stdlib\examples\base64.ahk` | Standard, URL-safe, wrapped-bytes, Base16, Base32, and Base85 codecs. |
| `stdlib\examples\binascii.ahk` | Hexlify/unhexlify, CRC32, Base64 ASCII helpers. |
| `stdlib\examples\bisect.ahk` | Zero-based insertion points, key functions, sequence/insert targets. |
| `stdlib\examples\calendar.ahk` | Gregorian helpers, names, week headers, `timegm`, `Calendar` grids. |
| `stdlib\examples\collections.ahk` | `Counter`, `deque`, `defaultdict`, `OrderedDict`, `ChainMap`, named/user containers. |
| `stdlib\examples\contextlib.ahk` | `nullcontext`, `suppress`, `closing`, `ContextDecorator`, `ExitStack`, redirects. |
| `stdlib\examples\copy.ahk` | Shallow/deep copy, custom hooks, cycles, `Error` / `error`, `dispatch_table`. |
| `stdlib\examples\csv.ahk` | Reader/writer, dict reader/writer, dialects, `field_size_limit`, `Sniffer`. |
| `stdlib\examples\datetime.ahk` | Date/time/datetime/timedelta, bounds, `tzinfo`, fixed-offset `timezone`. |
| `stdlib\examples\decimal.ahk` | Decimal arithmetic, contexts, rounding constants, signal classes. |
| `stdlib\examples\init.ahk` | Root helpers including builtin-style errors, `stdlib.slice(...)`, `stdlib.await(...)`, and `stdlib.decorate(...)`. |
| `stdlib\examples\io.ahk` | In-memory text and file-like byte streams with `StringIO`, `BytesIO`, `read`/`readline`/`read1`/`readinto`/`readinto1`, `write`/`writelines`, `seek`, `tell`, `getvalue`, `flush`, capability probes, and close state. |
| `stdlib\examples\pillow.ahk` | Windows imaging backed `stdlib.pillow.Image` core: Image mode/init/endian helpers (`preinit`/`init`/`i32le`/`o32le`/`o32be`), public Image errors/constants/Exif mapping/ExifTags/TiffTags/features/JpegPresets/FontFile/BdfFontFile/PcfFontFile/ContainerIO/AvifImagePlugin/BlpImagePlugin/BmpImagePlugin/BufrStubImagePlugin/CurImagePlugin/DcxImagePlugin/DdsImagePlugin/EpsImagePlugin/FitsImagePlugin/FliImagePlugin/FpxImagePlugin/FtexImagePlugin/GbrImagePlugin/GdImageFile/GifImagePlugin/GimpGradientFile/GimpPaletteFile/GribStubImagePlugin/Hdf5StubImagePlugin/IcnsImagePlugin, IcoImagePlugin, ImImagePlugin IFUNC IM header/LUT/frame open/save, ImtImagePlugin IM Tools text-header L-image open and no-extension registry behavior, IptcImagePlugin IPTC/NAA helpers/direct raw L opens, JpegImagePlugin JPEG metadata opens, Jpeg2KImagePlugin JP2/J2K metadata opens, ImageCms sRGB profile metadata and identity transform helpers, ImageGrab 1x1 screen capture/keyword options/clipboard access, ImageShow viewer registry/base and platform command helpers, ImageTk Tk-compatible photo/bitmap image bridge helpers, ImageWin HDC/HWND/Dib/window wrapper helpers, ImageQt Qt-image bridge helpers, ImageMorph binary morphology LUT builder and MorphOp apply/match/LUT file helpers, `ImageMode.getmode` / `ModeDescriptor`, `ImagePalette.ImagePalette` / `raw` / `wedge` / `sepia` / LUT helpers, `ImageTransform` descriptor objects, `ImagePath.Path` coordinate paths, `ImageMath` expression helpers, `ImageFile.Parser` incremental decode, `ImageFont.ImageFont` base defaults, `ImageFont.is_path` / `DeferredError`, `ImageFont.load_default`, `load_default_imagefont`, and `ImageFont.load` / `load_path` bitmap font metrics plus direct `ImageFont.FreeTypeFont`, `ImageFont.truetype` / `FreeTypeFont.getname` / `getmetrics` / `font_variant` / `ImageFont.TransposedFont`, ImageDraw2 Pen/Brush/Font/Draw basic geometry plus arc/chord/pieslice/settransform/render/text/textbbox/textlength dispatch, module helpers/factories (`is_path`/`new`/`open`/`frombytes`/`frombuffer`), format and codec registry dictionaries/helpers (`OPEN`/`SAVE`/`SAVE_ALL`/`DECODERS`/`ENCODERS`/`EXTENSION`/`MIME`/`ID`/`MODES`, `registered_extensions`/`register_*`, custom open factory dispatch, custom decoder/encoder invocation through non-raw `frombytes`/`tobytes`, custom save/save_all handler invocation), `features` support/version queries and `pilinfo`, JPEG preset quantization tables, JpegImagePlugin JPEG metadata/header helpers, FontFile.puti16 plus BdfFontFile/PcfFontFile bitmap font parse/compile/save paths, ContainerIO bounded file-like region reads, AvifImagePlugin accept/codec/version helpers and AVIF registry parameter validation, BlpImagePlugin enum-like constants, accept/565/DXT helpers and P-mode BLP1/BLP2 file-like save/open round-trips, BmpImagePlugin BMP/DIB helper and factory surface, BufrStubImagePlugin accept/handler/open/save stub adapter surface, CurImagePlugin accept/CUR file-like open and largest cursor selection, DcxImagePlugin accept/DCX file-like RGB PCX frame open and seek/tell, DdsImagePlugin constants/enum-like flags and RGB/RGBA/L/LA raw DDS file-like save/open round-trips, EpsImagePlugin EPS header parsing, registry, Ghostscript availability probe, and RGB/L EPS file-like saves, FitsImagePlugin FITS header parsing, registry, raw/gzip tile metadata, and direct/Image.open file-like metadata opens, FliImagePlugin FLI/FLC header parsing, palette metadata, animation frame metadata, and direct/Image.open file-like metadata opens, FpxImagePlugin FlashPix OLE accept/registry plus fake-OLE metadata opens for direct and `Image.open(..., ["FPX"])` paths, FtexImagePlugin enum/registry plus uncompressed RGB and DXT1 tile metadata opens, GbrImagePlugin GIMP brush v1/v2 L/RGBA metadata and pixel opens, GdImageFile direct GD P-mode palette-index loader with RGBX palette/transparency metadata and no Image.open registration, GifImagePlugin GIF87a/GIF89a accept/registry metadata, single-frame P-mode metadata/palette/pixel loading, and P-mode GIF file-like save/open round-trips, GimpGradientFile `.ggr` parser and RGBA palette generation, GimpPaletteFile `.gpl` parser/frombytes RGB palette loading, GribStubImagePlugin GRIB accept/handler/open/save stub adapter surface, Hdf5StubImagePlugin HDF5 signature/handler/open/save stub adapter surface, IcnsImagePlugin PNG-backed ICNS container open/save, IcoImagePlugin PNG/BMP-backed ICO container open/save, ImImagePlugin IFUNC IM text-header/LUT/frame open/save, ImtImagePlugin IM Tools text-header L-image direct/open path, IptcImagePlugin IPTC/NAA metadata/raw L direct and `Image.open(..., ["IPTC"])` paths, JpegImagePlugin JPEG metadata direct and `Image.open(..., ["JPEG"])` paths, Jpeg2KImagePlugin JP2/J2K direct and `Image.open(..., ["JPEG2000"])` metadata paths, `Dither`/`Quantize`/`Transform`/`Transpose`/`Resampling` constants, `isImageType`, linear/radial gradients, Mandelbrot/noise image generation, ImageColor parser/string colors, image instance metadata (`readonly`/`format_description`/`draft`/`get_child_images`/`getxmp`/`getim`/`im`), image inspection (`getbands`/`getbbox`/`getextrema`/`getcolors`/`histogram`/`entropy`/`getprojection`), `ImageStat.Stat` count/sum/sum2/mean/median/rms/var/stddev/extrema statistics, `ImageSequence.Iterator` / `all_frames` single-frame iteration and frame-copy helpers, data access (`getdata`/`tobytes`/`tobitmap`/`frombytes`/`putdata`), palette access (`getpalette`/`putpalette`/`remap_palette`), palette transparency via `info["transparency"]` / `has_transparency_data` / `apply_transparency`, frame lifecycle (`tell`/`seek`/`verify`), ImageDraw point/line/bitmap/floodfill/rectangle/polygon with outline width/regular_polygon/ellipse/arc/chord/pieslice/circle/rounded-rectangle geometry, RGB/L/RGBA/LA/1/P `new`, `open`, PNG/BMP/JPEG/TIFF `open`/`save` with file-like input/output including `L` TIFF round-trips, RGBA PNG alpha reopen, pixels, channels, split/merge, point/eval, ImageFilter kernel/box/GaussianBlur/UnsharpMask/Color3DLUT/rank filters, ImageChops arithmetic/blend/composite/light/logical channel ops, ImageOps color/geometry ops including `contain`/`cover`/`scale`/`pad`/`fit`/`autocontrast`/`equalize`/`colorize`/`deform`/`exif_transpose`, ImageEnhance brightness/color/contrast/sharpness, putalpha, paste, copy, crop, resize, transform, quantize, reduce, thumbnail, effect_spread, convert, transpose, rotate, blend, composite masks, alpha composite, close. |
| `stdlib\examples\pillow.ahk` | TarIO tar-member byte streams with member lookup, bounded reads, seek/tell, line reads, capability probes, and close state. |
| `stdlib\examples\pillow.ahk` | PdfParser low-level PDF helpers: text encoding/decoding, `PdfName`/`PdfArray`/`PdfDict`, xref output, and minimal object writer streams. |
| `stdlib\examples\pillow.ahk` | `report.pilinfo` support reports with optional supported-format listings. |
| `stdlib\examples\thread.ahk` | Process-backed workers, channels, shared memory, shared-object broker, pools. |
| `stdlib\examples\tkinter_gui.ahk` | Live tkinter / ttk window with variables, layout, callbacks, canvas, and tree data. |

</details>

Current Pillow additions: `IptcImagePlugin` IPTC/NAA helpers, `.iim` registration, direct and `Image.open(..., ["IPTC"])` raw L file-like opens, repeated metadata tags, and `getiptcinfo`; `JpegImagePlugin` JPEG accept/registry/JFIF density/quantization/sampling metadata direct/open paths; `Jpeg2KImagePlugin` JP2/J2K accept/registry/DPI/JPX mimetype/codestream comment metadata direct/open paths; `McIdasImagePlugin` MCIDAS area accept/registry/no-extension behavior, descriptor metadata, 1-byte L pixel loads, and 2/4-byte raw tile metadata direct/open paths; `MicImagePlugin` MIC/OLE accept, `.mic` registration, fake-OLE `.ACI/Image` TIFF stream loading, close behavior, and `Image.open(..., ["MIC"])` fallback errors; `MpegImagePlugin` BitStream bit parsing, MPEG sequence header size metadata, `.mpg`/`.mpeg` and MIME registration, and non-decoding `load()` errors; `MpoImagePlugin` MPF/MPO frame metadata, JPEG-factory `Image.open(..., ["JPEG"])` promotion, `adopt`, seek/tell, `.mpo`/MIME/save/save_all registration, single/multi-frame MPO file-like saves, and animated-source `save_all=True` resaves; `MspImagePlugin` DanM raw and LinS RLE Windows Paint MSP open paths, `MspDecoder`, `.msp`/open/save/decoder registration, mode `1` row-padded bytes, and MSP file-like saves; `PalmImagePlugin` Palm colormap/prototype constants, `.palm`/MIME/save registration, mode `1` and `P` file-like saves, and current Pillow 11.3.0 `L`/invalid-mode error behavior; `PcdImagePlugin` Kodak PhotoCD metadata opens, `.pcd` extension/open registration with no accept function, orientation post-rotate metadata, `pcd` tile metadata, and no-pixel-data load errors; `PcxImagePlugin` Paintbrush `_accept`/binary helpers/SAVE map, `.pcx`/MIME/open/save registration, 1/L/P/RGB RLE file-like opens and saves, palette handling, dpi metadata, and covered error paths; `PdfImagePlugin` output-only `.pdf`/MIME/save/save_all registration, RGB/L DCT PDF image streams, P indexed ASCIIHex streams, mode `1` CCITT metadata, title/author metadata, dpi/resolution MediaBox handling, multi-page `append_images`, and covered arity/unsupported-mode errors; `PixarImagePlugin` PIXAR raster `_accept`/`i16` helpers, `.pxr`/open registration without save/MIME, direct and `Image.open(..., ["PIXAR"])` RGB raw file-like loads, tile metadata, and covered bad magic/unknown-mode/arity errors; `PngImagePlugin` PNG magic/byte helpers/CRC/CID checks, `PngInfo` text/iTXt chunk helpers, `putchunk`/`getchunks`, registry entries, metadata direct/open reads, and metadata-aware RGB/RGBA/L file-like saves; `PpmImagePlugin` PBM/PGM/PPM/PFM accept/registry behavior, plain and raw bitmap/gray/RGB/CMYK/P/RGBA/F file-like opens, 16-bit gray and PFM scale metadata, and mode `1`/`L`/`I`/`RGB`/`RGBA`/`F` file-like saves; `PsdImagePlugin` PSD accept/registry behavior, L/RGB/RGBA/P/CMYK raw file-like opens, ICC resources, lazy layer metadata, `seek`/`tell`, and covered constructor/header/channel/mode/layer-block error paths; `QoiImagePlugin` QOI accept/open/save registry behavior, decoder/encoder factories, RGB/RGBA direct and `Image.open(..., ["QOI"])` file-like opens, exact file-like saves including `colorspace="sRGB"`, and covered bad-magic/unsupported-mode/constructor arity paths.

Current Pillow additions also include: `SgiImagePlugin` SGI `MODES`/`i16`/`o8`/`_accept` helpers, `.bw`/`.rgb`/`.rgba`/`.sgi` and MIME registration, `SGI16Decoder` metadata, raw/RLE SGI file-like opens, `Image.open(..., ["SGI"])`, RGB/RGBA/L file-like saves, and covered constructor/save error paths; `SpiderImagePlugin` SPIDER `iforms`/`isInt`/`isSpiderHeader`/`isSpiderImage` helpers, `SpiderImageFile` float-image direct and `Image.open(..., ["SPIDER"])` file-like opens, little/big-endian raw modes, stack `seek`/`tell`, `convert2byte`, file-like/path saves with dynamic `.spi` registration, and covered header/stack/constructor/save error paths; `SunImagePlugin` Sun raster `_accept`, `.ras` open registration, raw 1/4/8/24/32-bit and RLE file-like opens, palette handling, and explicit unsupported save behavior; `TgaImagePlugin` TGA `MODES`/`SAVE`, `.tga`/`.icb`/`.vda`/`.vst` and MIME registration, raw/RLE file-like opens, orientation and ID metadata, file-like saves, and unsupported-mode errors; `TiffImagePlugin` TIFF constants/maps/helpers, prefix accept, `.tif`/`.tiff` and MIME registration, direct and registered file-like opens, save/save_all registry entries, and baseline/GDI-backed file-like saves for the covered modes; `WalImageFile` direct/open-function Quake2 WAL texture loads, P-mode pixels, name/next-name metadata, and the full default Quake2 palette without `Image.open()` registration; `WebPImagePlugin` `SUPPORTED`, VP8 mode mapping, `_accept`, `.webp`/MIME/open/save/save_all registry presence, WIC-backed single-frame RGB/RGBA direct and registered file-like opens, full-frame lossless animated WebP `seek`/`tell`/`load_seek` metadata and pixels, and `_convert_frame`, with complex blend/dispose composition and real WebP encoding still deferred; `WmfImagePlugin` `word`/`short`/`_long`, `_accept`, default/custom handler registration, WMF/EMF header parsing, `.wmf`/`.emf` open/save registry presence, custom handler load/save delegation, DPI-based size updates, and covered invalid-header/save-without-handler errors; `XbmImagePlugin` whitespace-tolerant `_accept`, `XbmImageFile` direct and registered file-like opens, hotspot metadata, XBM tile offsets, `.xbm`/MIME/open/save registration, mode `1` bitmap file-like saves including hotspot encoder options, and covered bad-header/truncated-data/unsupported-mode errors; `XpmImagePlugin` XPM `_accept`, `XpmImageFile` and `XpmDecoder`, `.xpm`/MIME/open/decoder registration without save registration, P-mode palette/transparent-key file-like opens, RGB >256-color file-like opens, tile metadata, and covered bad-header/palette/truncated-data errors; `XVThumbImagePlugin` `_MAGIC`/RGB332 `PALETTE`, `_accept`, uppercase `XVTHUMB` open registry, no save/extension/MIME registration, P-mode palette image direct and `Image.open(..., ["XVThumb"])` file-like opens, comment/whitespace header parsing, lazy pixel loading, and covered bad-magic/EOF/invalid-size/truncated-data errors.

Latest Pillow promotion: `ImageFile.SAFEBLOCK`, `ImageFile.ImageFile`, `PyCodec`, `PyCodecState`, `PyDecoder`, `PyEncoder`, `StubHandler`, `StubImageFile`, and `raise_oserror(...)` now cover the probed Pillow 11.3.0 public base/codec/stub surface alongside the existing incremental `ImageFile.Parser()` bridge.

## Quick Start

### Small Module

```ahk
#Requires AutoHotkey v2.0

#Include <stdlib\bisect>

bisect_example_values := [1, 2, 2, 3]
bisect_example_left := stdlib.bisect.bisect_left(bisect_example_values, 2)
bisect_example_right := stdlib.bisect.bisect_right(bisect_example_values, 2)
stdlib.bisect.insort_right(bisect_example_values, 2)
```

<details>
<summary>Thread worker, channel, shared memory, and pool example</summary>

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
<summary>tkinter / ttk live window example</summary>

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
style.configure("Demo.Treeview", { rowheight: 24, foreground: "#203040" })
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

## Design Rules

- Public includes use `#Include <stdlib\module>`.
- Public calls use `stdlib.module.func(...)` or `stdlib.module.Class(...)`.
- Module paths mirror Python 3.10 `Lib` module paths where practical.
- `stdlib\init.ahk` is a lightweight namespace root, not a dynamic import loader.
- Promoted modules must have behavior coverage under `stdlib\tests`.
- Keep README stable and user-facing; module promotion and gate-history notes
  live in `docs\stdlib-architecture.md`.

## Friendly Links

- [LINUX DO](https://linux.do/)
- [AutoHotkey Community Forum](https://www.autohotkey.com/boards/)

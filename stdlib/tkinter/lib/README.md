# Tcl/Tk Runtime DLLs

This directory carries the Tcl/Tk runtime DLLs used by `stdlib.tkinter` when
`stdlib.tkinter.Tcl({ useTk: stdlib.True })` needs to load Tk.

## Source

- Upstream distribution: CPython 3.10.11 Windows x86-64 installer from
  https://www.python.org/downloads/release/python-31011/
- Local runtime used for this snapshot:
  `F:\Python\Python310`
- Local source files:
  - `F:\Python\Python310\DLLs\tcl86t.dll`
  - `F:\Python\Python310\DLLs\tk86t.dll`
- Probe authority: `F:\Python\Python310\python.exe`
- Probe result: Python `3.10.11`, Tcl `8.6.12`, Tk `8.6.12`

## SHA256 Verification Report

Generated on 2026-06-01 with PowerShell `Get-FileHash -Algorithm SHA256`.
The source and bundled hashes matched byte-for-byte.

| File | Size | Product | Version | SHA256 |
| --- | ---: | --- | --- | --- |
| `tcl86t.dll` | 1866480 | Tcl 8.6 for Windows | 8.6.12 | `FBFD065F861EC0A90DD513BC209C56BBC23C54D2839964A0EC2DF95848AF7860` |
| `tk86t.dll` | 1541872 | Tk 8.6 for Windows | 8.6.12 | `CD2F60075064DFC2E65C88B239A970CB4BD07CB3EEC7CC26FB1BF978D4356B08` |

Canonical checksum lines are also stored in `SHA256SUMS`.

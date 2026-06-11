# AHK V2 Standard Library Architecture

This library is being rebuilt into a Python-standard-library-compatible
AutoHotkey v2 library. The behavior baseline is the local CPython runtime:
Python 3.10.11. Test infrastructure should target pytest 7.4.3 capability
parity, with AHK naming (`ahktest`, `AhkTest`, `ahk*`) instead of `pytest` or
`py*` public identifiers.

The target public include surface is `#Include <stdlib\...>`. Public module
paths must mirror Python 3.10's `Lib` module paths, with only the leading
`stdlib.` / `stdlib\` prefix added. For example, Python `Lib\bisect.py` maps to
`<stdlib\bisect>` and `stdlib.bisect`, not `stdlib.collections.bisect`.
Project-owned support modules such as `ahktest` may use root-level
`<stdlib\ahktest>` paths, but they must be marked as support surface in the
manifest instead of pretending to be Python stdlib modules.

The `stdlib` directory was reset on 2026-05-25. The restart policy is
framework-first:

1. Define Python-standard-library-like planning groups in
   `stdlib\STDLIB_FRAMEWORK.json`.
2. Mark legacy implementations as `candidate` source material.
3. Mark modules with no local implementation as `missing`.
4. Keep low-level FFI, generated bindings, and DLL-heavy code in
   `native-quarantine` until isolated.
5. Promote a module to `direct` only after adding a failing stdlib gate or
   behavior test, then migrating implementation to its Python-path-aligned
   `stdlib\...` include.

Old paths are source material during the rebuild. They are not the final
dependency shape.
Once a module has been promoted to `direct` and has behavior coverage under
`<stdlib\...>`, its old AHK entrypoint should be removed so it no longer
pollutes the shared global namespace. Unmigrated candidate sources remain as
reference material until they are promoted.

## Current Direct Surface

After the 2026-05-25 reset, the direct stdlib surface is being rebuilt in
small TDD slices. Current direct modules:

- `stdlib\init.ahk`
- `stdlib\ahktest.ahk`
- `stdlib\assert.ahk`
- `stdlib\base64.ahk`
- `stdlib\getpass.ahk`
- `stdlib\binascii.ahk`
- `stdlib\quopri.ahk`
- `stdlib\abc.ahk`
- `stdlib\base.ahk`
- `stdlib\types.ahk`
- `stdlib\operator.ahk`
- `stdlib\warnings.ahk`
- `stdlib\bisect.ahk`
- `stdlib\heapq.ahk`
- `stdlib\collections.ahk`
- `stdlib\itertools.ahk`
- `stdlib\functools.ahk`
- `stdlib\calendar.ahk`
- `stdlib\datetime.ahk`
- `stdlib\time.ahk`
- `stdlib\math.ahk`
- `stdlib\random.ahk`
- `stdlib\array.ahk`
- `stdlib\hashlib.ahk`
- `stdlib\pprint.ahk`
- `stdlib\statistics.ahk`
- `stdlib\decimal.ahk`
- `stdlib\fractions.ahk`
- `stdlib\comparser.ahk`
- `stdlib\json.ahk`
- `stdlib\keyword.ahk`
- `stdlib\string.ahk`
- `stdlib\html.ahk`
- `stdlib\textwrap.ahk`
- `stdlib\fnmatch.ahk`
- `stdlib\csv.ahk`
- `stdlib\configparser.ahk`
- `stdlib\io.ahk`
- `stdlib\re.ahk`
- `stdlib\toml.ahk`
- `stdlib\os.ahk`
- `stdlib\glob.ahk`
- `stdlib\platform.ahk`
- `stdlib\socket.ahk`
- `stdlib\pathlib.ahk`
- `stdlib\shutil.ahk`
- `stdlib\tempfile.ahk`
- `stdlib\logging.ahk`
- `stdlib\queue.ahk`
- `stdlib\thread.ahk`
- `stdlib\asyncio.ahk`
- `stdlib\enum.ahk`
- `stdlib\copy.ahk`
- `stdlib\contextlib.ahk`
- `stdlib\secrets.ahk`
- `stdlib\uuid.ahk`
- `stdlib\inspect.ahk`
- `stdlib\tkinter.ahk`
- `stdlib\pillow.ahk`

The framework manifest currently tracks `59` total module slots: `59` direct,
`0` candidate, and `0` native-quarantine.

Current verified wrapper baseline is
`stdlib/tests: 1140 passed, 0 failed, 0 errors` from
`run-ahktest stdlib/tests -TimeoutSeconds 90`, with the existing
`plain fallback` stderr line from the logging bootstrap smoke still treated as
expected output rather than a failure. This raises the aggregate evidence from
the previous 90-second 1139-test baseline; it uses the current 90-second
default aggregate gate and does not claim lower-timeout aggregate stability.

The latest concurrency slice expands `stdlib.thread` as a process-backed
interpreter worker module with bounded memory access. This follows the
requested AHK architecture: the main interpreter remains the scheduler and
state owner, Windows system DLL calls provide process/event/wait/
handle-redirection/file-mapping primitives, each `Thread` starts an independent
AutoHotkey interpreter process for its script fragment, and the main
interpreter polls `Thread`, `ResultQueue`, JSON-safe `Channel` messages, or
bounded `SharedMemory` regions to read worker state and update AHK state. It
does not claim that the current AHK VM executes shared script state on multiple
OS threads, and it does not share AHK object pointers across worker boundaries.
Fresh OS-thread callback probes confirm why this boundary matters: `CreateThread`
can enter an AHK `CallbackCreate` function on non-main thread IDs, and two such
callbacks can overlap before the first one releases. Therefore raw pointers are
only promoted as explicit shared-memory addresses and typed slots, not as a
general shared AHK object model.
An attempted GIL-style native wrapper was also probed and rejected for public
promotion: `.codex/thread_ahk_object_gil_probe.test.ahk` showed that a very small
direct `CreateThread` callback can serialize a shared `Map` / `Array` mutation
with a Win32 mutex, but `.codex/thread_native_min_probe.test.ahk` then reproduced
an ahktest no-status process exit once the behavior was wrapped as a reusable
`NativeThread` returning or sharing AHK objects. That is treated as crossing the
AHK VM object-memory boundary. The promoted path toward Python-like
shared-object threading is therefore a broker/proxy model:
`stdlib.thread.SharedObject(...)` keeps the real AHK object owned by the main
interpreter, workers access it through `current_shared_object(...)` proxy
handles, and JSON-safe operations are marshalled back to the main interpreter
for serialized execution. Large byte payloads should use `SharedMemory` typed
slots, not AHK object pointers.
Covered Python-guided surface now includes `Lock`, `RLock`, `Semaphore`,
`BoundedSemaphore`, `Condition`, `Barrier`, `Event`, `Thread`, `Timer`,
`Future`, `ThreadPool`, `WeakSet`, `ExceptHookArgs`, `local`,
trace/profile/stack helpers, current / main thread helpers, deprecated aliases
such as `activeCount()`,
`currentThread()`, `Event.isSet()`, `Thread.getName()/setName()`,
`Thread.isDaemon()/setDaemon()`, and object-level `Thread.run()` /
`Timer.run()` / `Timer.cancel()` / `Condition.wait_for(...)`. AHK extension
surface includes `stdlib.thread.Channel()` / `current_channel()` for
process-safe JSON message passing and `stdlib.thread.SharedMemory()` /
`current_shared_memory()` for named Win32 file-mapping regions with logical
size bounds, byte reads/writes, UTF-8 text helpers, and fixed-region JSON
helpers. Shared memory also exposes raw `SharedMemory.address`,
`SharedMemory.ptr()`, and fixed-width `SharedMemory.get(...)` /
`SharedMemory.put(...)` typed slots for low-level worker coordination, plus an
explicit named-mutex lock via `SharedMemory.lock()` and
`SharedMemory.synchronized(...)`; this protects caller-selected critical
sections instead of hiding every read/write behind an implicit lock.
`SharedObject` currently covers brokered `acquire(...)`, `release()`,
`get(...)`, `set(...)`, `append(...)`, `len(...)`, and `snapshot()` for
JSON-safe shared state, including duplicate public thread names; internal broker
identity is not derived from `Thread.name`. `Thread.join(...)` and
`Thread.is_alive()` pump broker requests for all active process-backed workers,
not only the worker being joined, so a worker holding a `SharedObject` lock can
release it while the main interpreter is currently waiting on another worker.
`ThreadPool` currently covers bounded `max_workers` scheduling, queued-future
cancelation, `Future.running()`, `Future.add_done_callback(...)`,
timeout-aware `Future.result(...)`, `Future.exception(...)`, worker exception
propagation, shutdown submit rejection, ordered single-iterable
`ThreadPool.map(...)`, `worker_source` / `task` persistent worker processes for
JSON-safe task payloads, `shutdown(wait := false)` completion of already running
persistent tasks, and `stdlib.await(future, { timeout: ... })` for thread
futures. Dynamic `{ source: ... }` tasks remain one-shot worker scripts; this
does not claim persistent worker-process reuse for arbitrary dynamic source
execution.
The JSON-file `Channel` spool retries transient Windows file-lock reads after a
worker publishes a message, uses string ordering for hyphenated sequence file
names, and preserves hard JSON/read errors. Worker
scripts are generated with
`#NoTrayIcon` as their first directive and
`#ErrorStdOut "UTF-8"`; `CreateProcessW` starts them with captured stdout/stderr
handles, so load-time worker failures are shaped into controlled
`RuntimeError("worker exited without a result: ...")` instead of warning/error
popups.

Fresh CPython 3.10.11 evidence includes `.codex/thread_python_probe.py`,
`.codex/threading_surface_probe.py`, `.codex/threading_thread_timer_probe.py`,
`.codex/threading_object_surface_probe.py`, `.codex/thread_shared_memory_probe.py`,
`.codex/thread_named_mutex_probe.py`, `.codex/thread_raw_memory_probe.py`,
`.codex/thread_shared_object_python310_probe.py`,
`.codex/thread_duplicate_name_python310_probe.py`,
`.codex/threadpool_executor_python310_probe.py`,
`.codex/threadpool_callbacks_map_python310_probe.py`,
`.codex/threadpool_worker_reuse_python310_probe.py`,
`.codex/threadpool_shutdown_wait_false_python310_probe.py`,
`.codex/thread_first_json_order_python310_probe.py`, and their JSON outputs.
These confirm the Python `threading` public names,
synchronization behavior, `Thread` lifecycle errors, `Timer`, `WeakSet`,
`ExceptHookArgs`, deprecated object aliases, object method surface, the Windows
shared-memory model used to guide bounded memory access, the Win32 named mutex
behavior used to guard cross-process critical sections, and the little-endian
fixed-width typed raw memory slot semantics used by `SharedMemory.get/put`.
They also confirm that Python 3.10.11 permits same-name threads and that
lock-guarded shared dict/list mutation produces the expected serialized count
and item-length outcomes. The thread-pool probe confirms Python 3.10.11
`ThreadPoolExecutor(max_workers=1)` queues later tasks, `Future.result(timeout)`
raises `TimeoutError`, queued futures can be cancelled, shutdown rejects new
submissions with `RuntimeError`, and worker exceptions are returned by
`Future.exception(...)` and re-raised by `Future.result(...)`. The callback/map
probe confirms `Future.running()` state transitions, done-callback registration
order, immediate callback execution after a future is already done, queued
cancellation callback state, and ordered `ThreadPoolExecutor.map(...)` results.
The worker-reuse and shutdown probes confirm that
`ThreadPoolExecutor(max_workers=1)` reuses the same worker identity for
sequential submit/map work, and that `shutdown(wait=False)` rejects later
submissions while letting a running future complete normally.
The JSON filename-order probe confirms that Python selects the first queue item
with string ordering for hyphenated names such as
`000000000001-...json`, not numeric coercion.
Fresh AHK evidence includes `.codex/thread_os_callback_probe.test.ahk` and
`.codex/thread_os_callback_concurrency_probe.test.ahk` proving non-main and
overlapping OS-thread callback entry, `.codex/thread_ahk_object_gil_probe.test.ahk`
showing the narrow mutex-serialized object probe, `.codex/thread_native_min_probe.test.ahk`
and `.codex/thread-native-min-probe-expanded-report.txt` recording the failed
public wrapper direction via an ahktest no-status process exit,
`.codex/thread-shared-memory-red-report.txt`
failing because `SharedMemory` was absent, `.codex/thread-shared-memory-green-report.txt`
passing `stdlib/tests/thread.test.ahk` 15/15 in 5609 ms after adding Win32
file-mapping shared memory, and `.codex/thread-shared-memory-mutex-red-report.txt`
failing because `SharedMemory.lock()` was absent, followed by
`.codex/thread-shared-memory-mutex-green-report.txt` passing
`stdlib/tests/thread.test.ahk` 16/16 in 5875 ms after adding named mutex locking
and `SharedMemory.synchronized(...)`, and `.codex/thread-shared-memory-raw-red-report.txt`
failing because `SharedMemory.address` was absent, followed by
`.codex/thread-shared-memory-raw-green-report.txt` passing
`stdlib/tests/thread.test.ahk` 17/17 in 8906 ms after adding raw address and
typed slot access, and `.codex/thread-channel-lock-retry-green-report.txt`
passing `stdlib/tests/thread.test.ahk` 18/18 in 9172 ms after adding a regression
for transient Channel JSON file locks, followed by
`.codex/thread-child-tray-hidden-green-report.txt` passing 19/19 after asserting
worker `A_IconHidden`, `.codex/thread-shared-object-red-report.txt` failing
because `SharedObject` was absent, `.codex/thread-shared-object-green-report.txt`
passing 20/20 after adding the broker/proxy shared object path, and
`.codex/thread-shared-object-duplicate-name-red-report.txt` failing because
broker identity used public `Thread.name`, followed by
`.codex/thread-shared-object-duplicate-name-green-report.txt` passing 21/21
after switching to unique worker broker keys, and
`.codex/thread-shared-object-global-pump-red-report.txt` failing because
joining one worker did not process another active worker's `SharedObject`
release request, followed by
`.codex/thread-shared-object-global-pump-green-report.txt` passing 22/22 after
adding a global active-worker broker pump, and `.codex/threadpool-red-report.txt`
failing because `Future` / `ThreadPool` were absent, followed by
`.codex/threadpool-green-report.txt` passing 24/24 after adding bounded
`ThreadPool` scheduling, `Future` result/exception/timeout/cancel behavior,
worker error propagation, shutdown submit rejection, README/example capture, and
`stdlib.await(...)` support for thread futures, and
`.codex/threadpool-callbacks-map-red-report.txt` failing because
`Future.running()` and `ThreadPool.map(...)` were absent, followed by
`.codex/threadpool-callbacks-map-green-1-report.txt` passing 26/26 after adding
`Future.running()`, `Future.add_done_callback(...)`, reentrancy-guarded pool
pumping, and ordered single-iterable `ThreadPool.map(...)`, followed by
`.codex/threadpool-persistent-worker-red-report.txt` failing because the
`worker_source` / `task` persistent-worker protocol was absent,
`.codex/threadpool-persistent-worker-green-1-report.txt` passing 27/27 after
adding hidden persistent worker processes for JSON-safe tasks, and
`.codex/threadpool-shutdown-wait-false-red-report.txt` failing because
`shutdown(false)` prevented a running persistent task result from being
collected. The user-reproduced `Expected a Number but got a String` failure at
`AhkStdlibThreadFirstJsonFile(...)` then identified the root cause: channel
queue file names such as `000000000001-...json` were compared with numeric
`<` instead of string comparison. `.codex/threadpool-shutdown-wait-false-after-firstjson-fix.txt`,
`.codex/threadpool-shutdown-wait-false-final-focused.txt`, and
`.codex/thread-channel-first-json-final-focused.txt` pass after switching the
queue selector to `StrCompare(...)`, preserving running persistent futures after
`shutdown(false)`, and explicitly covering hyphenated JSON file names. The final
`.codex/threadpool-persistent-worker-final-green-report.txt` thread gate passes
`stdlib/tests/thread.test.ahk` 29/29 at `TimeoutSeconds 90`. The
covered AHK behavior includes
worker reopen via `current_shared_memory()`, bounded out-of-range errors, raw
address/ptr exposure, typed `UInt`/`Int`/`UChar` slots, Channel communication and
file-lock retry, no-tray worker generation, captured worker error regression,
`SharedObject` broker/proxy operations through `current_shared_object(...)`,
duplicate public thread names, all-active-worker broker pumping during
`join(...)` / `is_alive()`, `ThreadPool` / `Future` task scheduling,
`Future.running()`, done callbacks, ordered `ThreadPool.map(...)`, JSON-safe
`worker_source` / `task` persistent worker reuse, `shutdown(false)` completion
for running persistent work, string-ordered channel queue file selection, and
README/example capture regression. The README
thread examples are extracted
and run through
`AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", ...])`
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. This slice does not promote the verified aggregate baseline beyond
1140/1140 because no fresh aggregate `stdlib/tests` gate was run for it.

The latest classic tkinter work-in-progress slice tightens grouped root and
public-widget option `keyword=None` behavior for `Tk.configure(...)`,
`Widget(...)`, `BaseWidget(...)`, `Menubutton(...)`, `clipboard_clear(...)`,
`clipboard_append(...)`, `clipboard_get(...)`, and the covered
`option_add(..., priority=None)` path. A fresh Python 3.10.11 probe confirmed
that root configure, public-widget constructors, classic `Menubutton`, and
clipboard keyword options skip covered `None` values before reaching Tcl, while
`option_add(pattern=None, ...)` and `option_add(..., value=None)` keep the
observed Tcl wrong-arity error and `tk_setPalette(...)` `None` paths remain
non-skip behavior. The AHK root configure and clipboard option writers now use
skip-`None` semantics for the covered paths, and `option_add(...)` preserves
the observed `priority=None` default-priority behavior while shaping
pattern/value `None` to the covered TclError. Fresh evidence includes
`.codex/tkinter_classic_root_public_option_none_probe.py` plus JSON output, a
focused red report where
`TestClassicRootPublicOptionKeywordNoneMatchesLocal310` failed because
`Tk.configure({ missing: stdlib.None })` reached Tcl as
`unknown option "-missing"`, focused green passing 1/1 in 282 ms, adjacent
serial gates passing for `Clipboard` 1/1 in 266 ms and `OptionDatabase` 1/1
in 297 ms, plus the full `stdlib/tests/tkinter.test.ahk` file gate passing
280/280 in 54797 ms at `-TimeoutSeconds 90`. This slice does not promote the
verified aggregate baseline beyond 1140/1140 because no fresh aggregate
`stdlib/tests` gate was run for it. At this point the tkinter / ttk surface is
treated as sufficient for rich example GUI work, with remaining tkinter parity
handled as maintenance rather than blocking the alphabetical stdlib pass.
Fresh example evidence for this handoff point includes
`.codex/tkinter_gui_example_capture.test.ahk` passing 1/1 in 766 ms for the
new standalone `stdlib/examples/tkinter_gui.ahk` live dashboard example,
README en/zh tkinter examples passing through ahktest capture with pollution
assertions in 1547 ms, README LabeledScale probes passing 2/2 in 1719 ms, and
`run-ahk-validate -Path stdlib/examples/tkinter.ahk -TimeoutSeconds 90`
passing for the existing coverage-style tkinter example.

The tkinter example/README regression surface has now been promoted from
ignored `.codex`-only checks into tracked stdlib tests. The tracked
`stdlib/tests/tkinter_examples.test.ahk` capture gate runs
`stdlib/examples/tkinter_gui.ahk` through
`AhkTest.CaptureFixture().RunArgs(A_AhkPath, ["/ErrorStdOut=UTF-8", ...])`,
asserts that the live example still exposes `root.mainloop()`, `--capture`,
Tk variables, ttk `Style`, `Entry`, `Combobox`, `Scale`, `Progressbar`,
`Treeview`, `Notebook`, `Canvas`, and callback-driven updates, and verifies the
capture marker. The same tracked gate extracts the README.en.md and
README.zh-CN.md tkinter code blocks, asserts the examples stay focused enough
for README use while still covering variables, grid layout, callbacks, canvas,
style, and the core ttk widgets, patches in a short `root.after(...)` close
only for captured test execution, and asserts the previous PowerShell regex
replacement pollution strings are absent. Fresh evidence includes focused red
`ReadmeTkinter` failing on the old overgrown README example, focused green
passing 1/1 in 1219 ms after the example was simplified, focused
`TkinterGuiExample` passing 1/1 in 672 ms, full
`stdlib/tests/tkinter_examples.test.ahk` passing 2/2 in 5282 ms, the legacy
`.codex/readme_tkinter_capture.test.ahk` passing 1/1 in 3094 ms, the legacy
`.codex/tkinter_gui_example_capture.test.ahk` passing 1/1 in 1391 ms, and the
README LabeledScale probes passing 2/2 in 2797 ms. This is an example and docs
hardening pass, not a new Python API parity claim.

The preceding classic tkinter work-in-progress slice tightens grouped classic
constructor keyword-`None` no-op behavior for `Label(...)`, `Frame(...)`,
`PanedWindow(...)`, `Canvas(...)`, `Text(...)`, and `Entry(...)`, while
preserving the probed `PhotoImage(width=None)` exception path. Fresh Python
3.10.11 probes confirmed that covered classic widget constructors skip single,
multiple, and unknown `keyword=None` option values before reaching Tcl, create
usable widgets with default option values, and support follow-on configure /
layout calls. A separate image-constructor probe confirmed that
`PhotoImage(width=None)` does not use this skip-`None` behavior and instead
raises `TclError("value for \"-width\" missing")` before the covered
`height=None` or unknown-option paths are reached. The AHK classic public
widget constructor helpers now use the local skip-`None` option formatter, and
the image constructor retains normal option forwarding with a covered
`PhotoImage` missing-value error shim for `width=None` / `height=None`. Fresh
evidence includes `.codex/tkinter_classic_constructor_kwargs_none_probe.py`,
`.codex/tkinter_image_constructor_kwargs_none_probe.py`, and JSON outputs, a
focused red report where
`TestClassicConstructorKeywordNoneNoopMatchesLocal310` failed because
`Label(..., { missing: stdlib.None })` reached Tcl as
`unknown color name "-missing"`, focused green passing 1/1 in 407 ms,
adjacent serial gates passing for `Classic` 22/22 in 2453 ms, `Widget` 22/22
in 4000 ms, and `PhotoImage` 3/3 in 438 ms, plus the full
`stdlib/tests/tkinter.test.ahk` file gate passing 279/279 in 69000 ms at
`-TimeoutSeconds 90`. This slice does not promote the verified aggregate
baseline beyond 1140/1140 because no fresh aggregate `stdlib/tests` gate was
run for it.

The preceding classic tkinter work-in-progress slice tightens grouped classic
creation/registration keyword-`None` no-op behavior for
`Canvas.create_line(...)`, `Canvas.create_text(...)`,
`Canvas.create_window(...)`, `Text.image_create(...)`,
`Text.window_create(...)`, and `Misc.selection_handle(...)`. A fresh Python
3.10.11 probe confirmed that covered single, multiple, and unknown
`keyword=None` option values are skipped before reaching Tcl; canvas creation
returns new item ids with default `SystemButtonText` fill / default geometry
options, `Text.image_create(...)` returns the generated image name with default
`align="center"` and `padx=0`, `Text.window_create(...)` returns `None` with
default window options, and `selection_handle(...)` returns `None`. The AHK
covered create/registration paths now use the local skip-`None` option
formatter while leaving unprobed constructor and ttk query-style paths
unchanged. Fresh evidence includes
`.codex/tkinter_classic_create_kwargs_none_probe.py` plus JSON output, a
focused red report where
`TestClassicCreateKeywordNoneNoopMatchesLocal310` failed because
`Canvas.create_line(..., { fill: stdlib.None, missing: stdlib.None })`
reached Tcl as `unknown color name "-missing"`, focused green passing 1/1 in
234 ms, adjacent serial gates passing for `Canvas` 15/15 in 1859 ms, `Text`
9/9 in 1032 ms, `Selection` 9/9 in 2188 ms, and `Classic` 21/21 in 2782 ms,
plus the full `stdlib/tests/tkinter.test.ahk` file gate passing 278/278 in
58109 ms at `-TimeoutSeconds 90`. This slice does not promote the verified
aggregate baseline beyond 1140/1140 because no fresh aggregate `stdlib/tests`
gate was run for it.

The preceding classic tkinter work-in-progress slice tightens grouped classic
mutation keyword-`None` no-op behavior for `Misc.configure(...)`,
`Pack.pack_configure(...)`, `Grid.grid_configure(...)`,
`Place.place_configure(...)`, `PhotoImage.configure(...)`,
`PanedWindow.add(...)`, `PanedWindow.paneconfigure(...)`,
`Menu.add_command(...)`, and `Menu.insert_command(...)`. A fresh Python
3.10.11 probe confirmed that covered single, multiple, and unknown
`keyword=None` values are skipped before reaching Tcl, return `None`, and leave
existing widget, geometry-manager, image, and pane option values unchanged;
the covered menu add/insert calls create the same default empty-label command
entries Python creates when all supplied entry kwargs are skipped. The AHK
mutation paths now use the local skip-`None` option formatter for these
covered calls, without changing constructor or ttk query-style behavior. Fresh
evidence includes `.codex/tkinter_classic_mutation_kwargs_none_probe.py` plus
JSON output, a focused red report where
`TestClassicMutationKeywordNoneNoopMatchesLocal310` failed because
`Label.configure(..., { missing: stdlib.None })` reached Tcl as
`unknown option "-missing"`, focused green passing 1/1 in 282 ms, adjacent
serial gates passing for `Classic` 20/20 in 1860 ms, `Menu` 8/8 in 1390 ms,
`PanedWindow` 6/6 in 860 ms, `PhotoImage` 3/3 in 297 ms, and `Layout` 5/5 in
765 ms, plus the full `stdlib/tests/tkinter.test.ahk` file gate passing
277/277 in 57156 ms at `-TimeoutSeconds 90`. This slice does not promote the
verified aggregate baseline beyond 1140/1140 because no fresh aggregate
`stdlib/tests` gate was run for it.

The preceding classic tkinter work-in-progress slice tightens embedded `Text`
image/window configuration keyword-`None` no-op behavior for
`Text.image_configure(...)` and `Text.window_configure(...)`. A fresh Python
3.10.11 probe confirmed that covered `padx=None`, `align=None`,
`stretch=None`, multiple `keyword=None` values, and unknown option names such
as `missing=None` all return `None` and leave the existing embedded image or
window option values unchanged. The AHK `Text` embedded configure mutation
paths now use the same local skip-`None` option formatter as the covered
classic widget configuration paths. Fresh evidence includes
`.codex/tkinter_classic_text_embed_config_kwargs_none_probe.py` plus JSON
output, a focused red report where
`TestClassicTextEmbedConfigureKeywordNoneNoopMatchesLocal310` failed because
`Text.image_configure(..., { missing: stdlib.None })` reached Tcl as
`unknown option "-missing"`, focused green passing 1/1 in 218 ms, and adjacent
serial gates passing for `Text` 9/9 in 1016 ms and `Classic` 19/19 in
2079 ms at `-TimeoutSeconds 90`. This slice does not promote the verified
aggregate baseline beyond 1140/1140 because no fresh aggregate gate was run
for it.

The preceding classic tkinter work-in-progress slice tightens classic widget
configuration keyword-`None` no-op behavior for `Menu.entryconfigure(...)`,
`Canvas.itemconfigure(...)`, `Listbox.itemconfigure(...)`, and
`Text.tag_configure(...)`. A fresh Python 3.10.11 probe confirmed that covered
single and multiple `keyword=None` calls, including unknown option names such
as `missing=None`, return `None` and leave existing option values unchanged
rather than querying or forwarding a bare `-option` token to Tcl. The AHK
classic configure paths now use a local skip-`None` option formatter for these
covered mutation-style calls, while existing ttk explicit-`None` query paths
continue to use their dedicated query handling. Fresh evidence includes
`.codex/tkinter_classic_config_kwargs_none_probe.py` plus JSON output, a
focused red report where
`TestClassicWidgetConfigureKeywordNoneNoopMatchesLocal310` failed because
`Text.tag_configure(..., { missing: stdlib.None })` reached Tcl as
`unknown option "-missing"`, focused green passing 1/1 in 219 ms, and adjacent
serial gates passing for `Menu` 8/8 in 1562 ms, `Canvas` 15/15 in 2031 ms,
`Text` 8/8 in 1156 ms, `Listbox` 2/2 in 578 ms, and `Classic` 18/18 in
2203 ms at `-TimeoutSeconds 90`. This slice does not promote the verified
aggregate baseline beyond 1140/1140 because no fresh aggregate gate was run
for it.

The preceding tkinter.ttk work-in-progress slice tightens
`ttk.Style.theme_settings(..., {"element create": ...})` value-shape and
script-formatting behavior for style element factories. A fresh Python 3.10.11
probe confirmed CPython's `_script_from_settings(...)` /
`_format_elemcreate(..., script=True)` behavior for covered `element create`
settings: `None` and empty lists are skipped as falsey settings, string values
are indexed and iterated character-by-character before Tcl reports
`TclError("No such element type f")`, scalar integer settings raise
`TypeError("'int' object is not subscriptable")`, `vsapi` settings missing
class/part arguments raise the same wrapper `ValueError` messages as direct
`Style.element_create(...)`, `image` settings missing the image name raise
`IndexError("tuple index out of range")`, bad image map entries raise the
covered Python unpacking errors, and script-mode image/vsapi specs are emitted
as one braced Tcl word rather than nesting a direct-call `[list ...]` command.
The AHK `theme_settings` element-create path now mirrors the covered Python
sequence/subscript and script-formatting behavior while leaving the public
direct `Style.element_create(...)` path unchanged. Fresh evidence includes
`.codex/tkinter_ttk_theme_settings_element_create_probe.py` plus JSON output, a
focused red report where
`TestTtkStyleThemeSettingsElementCreateValueShapesMatchLocal310` failed
because `"element create": "from"` raised AHK `TypeError` instead of the
Python-observed TclError path, focused green passing 1/1 in 172 ms, adjacent
`TtkStyle` passing 23/23 in 2266 ms, and broader `Ttk` filtering passing
195/195 in 32204 ms at `-TimeoutSeconds 90`. This slice does not promote the
verified aggregate baseline beyond 1140/1140 because no fresh aggregate gate
was run for it.

The preceding tkinter.ttk work-in-progress slice tightens
`ttk.Style.element_create(..., "vsapi", ...)` missing required factory-argument
unpacking. A fresh Python 3.10.11 probe confirmed that CPython's
`_format_elemcreate("vsapi", ...)` raises
`ValueError("not enough values to unpack (expected 2, got 0)")` when no
`class_name` / `part_id` arguments are supplied, and
`ValueError("not enough values to unpack (expected 2, got 1)")` when only the
class name is supplied. The AHK `vsapi` element-create formatter now raises the
same wrapper-level `ValueError` messages before Tcl evaluation instead of the
previous generic `IndexError("tuple index out of range")`. Fresh evidence
includes `.codex/tkinter_ttk_element_create_vsapi_probe.py` plus JSON output,
a focused red report where
`TestTtkStyleElementCreateVsapiMissingArgsMatchLocal310` failed because the
zero-argument `vsapi` path raised `"tuple index out of range"`, focused green
passing 1/1 in 234 ms, adjacent `TtkStyle` passing 22/22 in 4188 ms,
`Winfo` focused stability passing 6/6 in 1406 ms after replacing a
window-manager-sensitive border coordinate with a content-widget coordinate,
README en/zh capture passing 1/1 in 1718 ms with pollution assertions, example
validation passing, and the broader `Ttk` filter passing 194/194 in 74390 ms.
The full `tkinter.test.ahk` and aggregate `stdlib/tests` gates were attempted
with `-TimeoutSeconds 90` during this slice but timed out, so this slice does
not promote the verified aggregate baseline beyond 1140/1140 yet.

The preceding tkinter.ttk implementation slice tightens
`ttk.Style.element_create(..., "image", ...)` map-entry unpacking and value
formatting behavior. A fresh Python 3.10.11 probe confirmed CPython's covered
`_format_elemcreate(...)` behavior for image state/value entry shapes: scalar
entries such as `1` raise Python wrapper
`TypeError("cannot unpack non-iterable int object")`, strings remain iterable
and therefore reach the observed wrapper/Tcl path, single-state entries stay
legal, and covered list/tuple final image values are formatted into one Tcl
list word. The AHK element-create image formatter now performs the covered
Python unpacking checks before Tcl evaluation while preserving CPython's
string-iteration behavior. This slice did not require new visible
README/example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_element_create_map_shapes_probe.py` plus JSON output, a
focused red report where
`TestTtkStyleElementCreateImageMapEntryShapesMatchLocal310` failed because
`style.element_create(..., "image", ..., 1)` raised TclError instead of
Python's wrapper `TypeError`, focused green passing 1/1 in 141 ms, adjacent
`TtkStyle` passing 21/21 in 1422 ms, full tkinter filter passing 272/272 in
40625 ms, example validation passing, README en/zh capture passing 1/1 in
1313 ms with pollution assertions, and aggregate `stdlib/tests` passing
1140/1140 in 49797 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens `ttk.Scale.configure(...)`
`<<RangeChanged>>` virtual-event behavior. A fresh Python 3.10.11 probe
confirmed that successful `Scale.configure(...)` calls touching `from`,
`from_`, or `to` generate exactly one `<<RangeChanged>>` event after the
configuration succeeds, including a combined `from_`/`to` update in one call.
The same probe confirmed that configuring only `value`, querying one option,
querying the full option dictionary with `None`, and failed range
configuration do not add a `<<RangeChanged>>` event. The AHK
`AhkStdlibTkinterScale.configure(...)` override now delegates to the shared
widget configure path, then generates the virtual event only after a
successful covered range-option update. This slice did not require new visible
README/example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_scale_range_changed_probe.py` plus JSON output, a focused
red report where `TestTtkScaleConfigureRangeChangedEventMatchesLocal310`
failed because `scale.configure({ from_: 1.0 })` left the event list empty,
focused green passing 1/1 in 172 ms, adjacent `TtkScale` passing 5/5 in
516 ms, full tkinter filter passing 271/271 in 41453 ms, example validation
passing, README en/zh capture passing 1/1 in 1079 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1139/1139 in 49859 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens `ttk.Style.map(...)`
map-entry unpacking and value formatting behavior. A fresh Python 3.10.11
probe confirmed CPython's `_mapdict_values(...)` behavior for covered entry
shapes: empty list/tuple entries raise
`ValueError("not enough values to unpack (expected at least 1, got 0)")`,
scalar entry values such as `1` or `None` raise Python's
`cannot unpack non-iterable ... object` `TypeError`, non-string members in
multi-state specs raise Python's `sequence item ... expected str instance`
`TypeError`, single-state-only entries remain legal, `None` final values omit
the value word and continue to delegate Tcl's local odd-element error, and
list/tuple final values are joined into one Tcl list word. The AHK style-map
formatter now performs the covered Python unpacking checks before Tcl
evaluation and formats covered list/tuple final values through the same
joined-value path used by CPython's option formatting. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_ttk_style_map_entry_shapes_probe.py` plus
JSON output, a focused red report where
`TestTtkStyleMapEntryShapesMatchLocal310` failed because an empty entry raised
TclError instead of Python's `ValueError`, focused green passing 1/1 in
141 ms, adjacent `TtkStyle` passing 20/20 in 1469 ms, full tkinter filter
passing 270/270 in 41000 ms, example validation passing, README en/zh capture
passing 1/1 in 1078 ms with pollution assertions, and aggregate
`stdlib/tests` passing 1138/1138 in 50203 ms at `-TimeoutSeconds 90` with the
existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens `ttk.Style.map(...)`
map-dictionary value iteration behavior. A fresh Python 3.10.11 probe
confirmed CPython's `_mapdict_values(...)` behavior: `foreground=None`,
`foreground=1`, and boolean map values raise
`TypeError("'NoneType' object is not iterable")`,
`TypeError("'int' object is not iterable")`, and
`TypeError("'bool' object is not iterable")`; empty string and empty list map
values remain legal no-op map updates; and scalar string values are iterated
character by character into normal-state entries. The AHK implementation now
validates covered map values before Tcl mutation and expands string map values
through the same character iteration path while preserving legal empty
sequence behavior. This slice did not require new visible README/example code,
but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_style_map_values_probe.py` plus JSON output, a focused red
report where `TestTtkStyleMapValueIterationMatchesLocal310` failed because
`style.map(styleName, { foreground: 1 })` threw nothing instead of Python's
`TypeError`, focused green passing 1/1 in 156 ms, adjacent `TtkStyle` passing
19/19 in 1359 ms, full tkinter filter passing 269/269 in 40343 ms, example
validation passing, README en/zh capture passing 1/1 in 1016 ms with
pollution assertions, and aggregate `stdlib/tests` passing 1137/1137 in
50281 ms at `-TimeoutSeconds 90` with the existing `plain fallback` stderr
line.

The preceding tkinter.ttk implementation slice tightens `ttk.Style.configure(...)`
and `ttk.Style.map(...)` keyword-`None` behavior. A fresh Python 3.10.11 probe
confirmed that `Style.configure(style, background=None)` and
`padding=None` query the current option value through CPython's
`_val_or_dict(...)`, that missing or empty queried configure values return
`None`, and that `Style.map(style, foreground=None)` raises
`TypeError("'NoneType' object is not iterable")` before Tcl mutation rather
than acting as an option query. The AHK implementation now routes the covered
single-keyword `None` configure path through the existing style-value
conversion, normalizes empty keyword-query results to `stdlib.None`, and
prevalidates covered `Style.map(...)` keyword settings so `stdlib.None`
matches Python's iterable error. This slice did not require new visible
README/example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_style_kwargs_none_probe.py` plus JSON output, a focused
red report where `TestTtkStyleConfigureAndMapKwargsNoneMatchLocal310` failed
because `style.configure(styleName, { background: stdlib.None })` returned an
object instead of Python's `"red"`, focused green passing 1/1 in 141 ms,
adjacent `TtkStyle` passing 18/18 in 1391 ms, full tkinter filter passing
268/268 in 40438 ms, example validation passing, README en/zh capture passing
1/1 in 1109 ms with pollution assertions, and aggregate `stdlib/tests`
passing 1136/1136 in 49750 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
subcommand explicit-`None` keyword query behavior for `ttk.Panedwindow.pane`,
`ttk.Treeview.column`, `heading`, `item`, and `tag_configure`. A fresh Python
3.10.11 probe confirmed that a single keyword value of `None` in these
subcommands queries the corresponding option rather than configuring it:
covered values include Panedwindow `weight`, Treeview column `width`/`anchor`,
heading `text`/`anchor`, item `text`/`open`/`tags`/`values`, and tag
`foreground`/`font`. The AHK implementation now uses a shared
`AhkStdlibTkinterSingleNoneKeywordQueryOption(...)` helper so these
subcommands, plus the previously covered Notebook tab path, return the same
converted values as their positional option-query forms while ordinary
multi-option configuration still returns `Map()`. This slice did not require
new visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes `.codex/tkinter_ttk_subcommand_kwargs_none_probe.py` plus JSON
output, a focused red report where
`TestTtkSubcommandKwargsNoneQueryMethodsMatchLocal310` failed because
`pane(paneOne, { weight: stdlib.None })` returned `Map()` instead of the
Python-observed `2`, focused green passing 1/1 in 172 ms, adjacent
`TtkSubcommand` passing 2/2 in 297 ms, adjacent `TtkPanedwindow` passing 4/4
in 500 ms, adjacent `TtkTreeview` passing 22/22 in 2047 ms, adjacent
`TtkNotebook` passing 5/5 in 781 ms, adjacent `TtkStyle` passing 17/17 in
1516 ms, full tkinter filter passing 267/267 in 41610 ms, example validation
passing, README en/zh capture passing 1/1 in 1125 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1135/1135 in 50359 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
`ttk.Notebook.tab(tab_id, **kw)` explicit-`None` keyword query behavior. A
fresh Python 3.10.11 probe confirmed that a single keyword value of `None`,
such as `state=None`, `text=None`, `padding=None`, `compound=None`,
`underline=None`, or `image=None`, queries that tab option rather than
configuring it, and that multiple `None` keywords retain Tcl's local missing
value / bad-state errors without changing the tab's existing values. The AHK
`AhkStdlibTkinterNotebook.tab(...)` implementation now recognizes the covered
single-keyword `None` query case after Tcl evaluation and returns the same
Notebook tab-option conversion used by the positional option query path, while
leaving multi-option Tcl error behavior delegated to Tk. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes
`.codex/tkinter_ttk_notebook_tab_kwargs_none_probe.py` plus JSON output, a
focused red report where
`TestTtkNotebookTabKwargsNoneQueryMatchesLocal310` failed because
`tab(first, { state: stdlib.None })` returned `Map()` instead of the
Python-observed `"normal"`, focused green passing 1/1 in 156 ms, adjacent
`TtkNotebook` passing 5/5 in 703 ms, adjacent `TtkStyle` passing 17/17 in
1234 ms, adjacent `TtkTreeview` passing 22/22 in 2422 ms, adjacent
`TtkPanedwindow` passing 4/4 in 578 ms, full tkinter filter passing 266/266
in 41609 ms, example validation passing, README en/zh capture passing 1/1 in
1079 ms with pollution assertions, and aggregate `stdlib/tests` passing
1134/1134 in 51875 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
`ttk.Notebook.add(...)` and `insert(...)` child, position, and tab-option
sequence behavior. A fresh Python 3.10.11 probe confirmed that tab option
values of `None` omit the Tcl value word and therefore reach local wrong-args
errors, general list/tuple option values are joined into one Tcl word, empty
tuple `padding` queries return `""`, list/tuple child identifiers fold into a
single child path word, and list/tuple insert positions fold into a single
index word before Tcl validates them. The AHK implementation now lets
`AhkStdlibTkinterOptionsToScript(...)` omit `None` option values and join
general list/tuple option values, while `Notebook.add(...)` / `insert(...)`
stop covered argument emission at `None` and route child/position operands
through Notebook-specific Tcl-word helpers. This slice did not require new
visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes
`.codex/tkinter_ttk_notebook_add_insert_options_sequence_probe.py` plus JSON
output, a focused red report where
`TestTtkNotebookAddInsertOptionsNoneAndSequenceWordsMatchLocal310` failed
because `add(..., sticky=["n", "s"])` raised an AHK `TypeError` instead of the
Python-observed Tcl `Bad -sticky specification n s` error, focused green
passing 1/1 in 203 ms, adjacent `TtkNotebook` passing 4/4 in 672 ms, adjacent
`TtkPanedwindow` passing 4/4 in 687 ms, adjacent `TtkTreeview` passing 22/22
in 2000 ms, full tkinter filter passing 265/265 in 40579 ms, example
validation passing, README en/zh capture passing 1/1 in 1266 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1133/1133 in 49219 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
`ttk.Treeview.set(...)`, `selection_add(...)`, `selection_remove(...)`,
`selection_set(...)`, `selection_toggle(...)`, and `tag_bind(...)`
None/list/tuple/bool sequence behavior. A fresh Python 3.10.11 probe confirmed
that `Treeview.set(item, column, None)` queries the current column value rather
than writing `"None"`, list/tuple values are stored as Tcl joined words,
selection nested sequence operands become single item words before Tcl item
validation, and `tag_bind(...)` list/tuple tag and sequence operands use the
same single Tcl-word behavior observed through raw Tcl binding queries. The AHK
implementation now routes covered `Treeview.set` values, selection item lists,
and tag-bind sequence operands through Treeview-specific Tcl-word helpers while
leaving the existing public API shape unchanged. This slice did not require new
visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes
`.codex/tkinter_ttk_treeview_set_selection_bind_sequence_probe.py` plus JSON
output, a focused red report where
`TestTtkTreeviewSetValueAndTagBindSequenceMethodsMatchLocal310` failed because
`Treeview.set(first, "name", None)` returned `""` instead of Python's current
`"alpha"` value, focused green passing 1/1 in 219 ms, adjacent `TtkTreeview`
passing 22/22 in 2094 ms, full tkinter filter passing 264/264 in 40922 ms,
example validation passing, README en/zh capture passing 1/1 in 1203 ms with
pollution assertions, and aggregate `stdlib/tests` passing 1132/1132 in
49766 ms at `-TimeoutSeconds 90` with the existing `plain fallback` stderr
line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
subcommand option-query behavior for `ttk.Notebook.tab(...)`,
`ttk.Panedwindow.pane(...)`, inherited unsupported
`ttk.Panedwindow.panecget(...)` / `paneconfigure(...)`, and
`ttk.Treeview.column(...)`, `heading(...)`, `item(...)`, and
`tag_configure(...)`. A fresh Python 3.10.11 probe confirmed that these
subcommand wrappers preserve Python's raw `"-" + option` query construction:
leading-dash option names produce double-dash Tcl errors, trailing-underscore
names are not normalized away, bool options stringify as `True` / `False`,
list options raise `unhashable type: 'list'`, empty tuple options raise
`not enough arguments for format string`, and single-item tuple options follow
Python's wrapper formatting behavior. The AHK implementation now uses a
dedicated ttk subcommand query helper so return-value conversion receives a
clean option name while the Tcl call still receives the raw Python-style dash
word; the ttk Panedwindow inherited unsupported commands retain Python's
wrapper-level non-string option errors before reaching Tcl. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes
`.codex/tkinter_ttk_subcommand_option_sequence_probe.py` plus JSON output, a
focused red report where
`TestTtkSubcommandOptionSequenceMethodsMatchLocal310` errored on the old
`Notebook.tab(...)` normalized option path with an AHK tuple conversion error
instead of Python's observed tuple option behavior, focused green passing 1/1
in 156 ms, adjacent `TtkNotebook` passing 3/3 in 531 ms, adjacent
`TtkPanedwindow` passing 4/4 in 484 ms, adjacent `TtkTreeview` passing 21/21
in 2047 ms, full tkinter filter passing 263/263 in 40375 ms, example
validation passing, README en/zh capture passing 1/1 in 1125 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1131/1131 in 49016 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared themed-widget
configuration query behavior for specialized ttk widget wrappers that override
`cget(...)` or single-option `configure(...)`: `ttk.Combobox`,
`ttk.Spinbox`, `ttk.Menubutton`, `ttk.Progressbar`, `ttk.Notebook`, and
`ttk.Treeview`. A fresh Python 3.10.11 probe confirmed that these specialized
paths still preserve Python's `"-" + cnf` query construction for leading-dash
and trailing-underscore option names, raise Python's non-string `cget(...)`
`TypeError` messages, return dicts for `configure()` and `configure(None)`,
treat empty list/tuple `cnf` values as no-op updates, and raise the Python
`dict(...)` `ValueError` for non-empty list/tuple `cnf` updates. The AHK
specialized wrappers now use the shared dash-query helper for Tcl calls while
retaining normalized option names only for AHK-side return-value conversion.
This slice did not require new visible README/example code, but the existing
tkinter example and extracted README snippets were revalidated through the
capture harness. Fresh evidence includes
`.codex/tkinter_ttk_specialized_configure_sequence_probe.py` plus JSON output,
a focused red report where
`TestTtkSpecializedConfigureCgetSequenceMethodsMatchLocal310` failed because a
specialized `configure("-values")` path normalized the option and did not raise
the Python-observed TclError, focused green passing 1/1 in 172 ms, adjacent
`TtkSpinbox` passing 2/2 in 859 ms, adjacent `TtkMenubutton` passing 2/2 in
297 ms, adjacent `TtkProgressbar` passing 3/3 in 1390 ms, adjacent
`TtkNotebook` passing 3/3 in 750 ms, adjacent `TtkCombobox` passing 3/3 in
406 ms, adjacent `TtkTreeview` passing 21/21 in 2125 ms, full tkinter filter
passing 262/262 in 40797 ms, example validation passing, README en/zh capture
passing 1/1 in 1141 ms with pollution assertions, and aggregate `stdlib/tests`
passing 1130/1130 in 49953 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter.ttk implementation slice tightens the shared
themed-widget
`Widget.cget(...)`, `Widget.configure(...)`, `Widget.config(...)`, and
`Widget.keys(...)` configuration query surface. A fresh Python 3.10.11 probe
confirmed that `configure()`, `config()`, and `configure(None)` return the same
option dictionary, that empty list/tuple `cnf` values are no-op update paths,
that non-empty list/tuple `cnf` values raise the Python `dict(...)`
`ValueError`, and that queried options preserve Python's `"-" + cnf` behavior
for `cget("-text")` / `configure("-text")` and non-string `cget(...)`
`TypeError` messages. The AHK shared widget implementation now returns a
configure `Map` built from Tcl's option list, keeps keyword-object writes on the
existing normalized option path, and routes string query options through the
Python-style dash concatenation path so covered leading-dash and trailing
underscore query errors match CPython/Tk. This slice did not require new
visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes `.codex/tkinter_ttk_widget_configure_sequence_probe.py` plus JSON
output, a focused red report where
`TestTtkWidgetConfigureCgetSequenceMethodsMatchLocal310` failed because
`configure(None)` was sent to Tcl as an invalid `-__AhkStdlibNone` option,
focused green passing 1/1 in 157 ms, adjacent `TtkWidget` passing 11/11 in
1343 ms, adjacent `TtkButton` passing 3/3 in 516 ms, adjacent `TtkStyle`
passing 17/17 in 1625 ms, full tkinter filter passing 261/261 in 42360 ms,
example validation passing, README en/zh capture passing 1/1 in 1062 ms with
pollution assertions, and aggregate `stdlib/tests` passing 1129/1129 in
49625 ms at `-TimeoutSeconds 90` with the existing `plain fallback` stderr
line.

The preceding tkinter.ttk implementation slice tightens the shared
themed-widget
`Widget.state(...)` and `Widget.instate(...)` state-spec sequence handling. A
fresh Python 3.10.11 probe confirmed that `state(None)` is the same query path
as `state()`, empty list/tuple state specs are valid no-op / true-match paths,
multiple string states are joined into one Tcl state spec, and non-string
sequence elements fail in the Python wrapper with `sequence item 0: expected
str instance, ... found` instead of leaking AHK object conversion errors or Tcl
messages. The AHK implementation now validates state-spec sequence elements in
`AhkStdlibTkinterJoinStateSpec(...)`, preserving the existing string iterable
behavior where `"disabled"` is split character-by-character before Tcl rejects
state `d`. This slice did not require new visible README/example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_widget_state_sequence_probe.py` plus JSON output, a focused
red report where `TestTtkWidgetStateSpecSequenceTypeErrorsMatchLocal310` failed
because `state([None])` raised the host `"Expected a String but got an Object."`
message instead of Python's sequence-item `TypeError`, focused green passing
1/1 in 187 ms, adjacent `TtkWidget` passing 10/10 in 1031 ms, adjacent
`TtkButton` passing 3/3 in 484 ms, adjacent `TtkStyle` passing 17/17 in 1297 ms,
full tkinter filter passing 260/260 in 41016 ms, example validation passing,
README en/zh capture passing 1/1 in 1203 ms with pollution assertions, and
aggregate `stdlib/tests` passing 1128/1128 in 48813 ms at `-TimeoutSeconds 90`
with the existing `plain fallback` stderr line.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule with inherited classic command sequence behavior for
`ttk.Scrollbar.activate(...)` and `ttk.Panedwindow.proxy(...)`,
`proxy_place(...)`, `sash(...)`, `sash_coord(...)`, `sash_mark(...)`,
`sash_place(...)`, and `sashpos(...)`. A fresh Python 3.10.11 probe confirmed
that `ttk::scrollbar` rejects inherited `activate` calls with the local ttk
bad-command message, that `ttk::panedwindow` rejects inherited `proxy` calls
with the local ttk bad-command message, and that inherited `sash` wrappers on
`ttk::panedwindow` route through Tcl's `sashpos` command with CPython's
`None` truncation and list/tuple single-word behavior. The AHK ttk wrappers now
use `AhkStdlibTkinterTtkInheritedCommandWord(...)` for covered list/tuple words,
and the covered ttk `sash` / `sashpos` paths stop argument emission at
`None`, matching `_tkinter.tk.call` for the probed cases. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_ttk_inherited_command_sequence_probe.py` plus
JSON output, a focused red report where
`TestTtkInheritedClassicCommandSequenceMethodsMatchLocal310` failed because the
covered ttk inherited command path raised AHK `TypeError` instead of the
Python-observed TclError path, focused green passing 1/1 in 156 ms, adjacent
`TtkScrollbar` passing 3/3 in 391 ms, adjacent `TtkPanedwindow` passing 4/4 in
563 ms, full tkinter filter passing 259/259 in 40937 ms, example validation
passing, README en/zh capture passing 1/1 in 1109 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1127/1127 in 49734 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic
Canvas text-edit and selection command family with batched `None`/list/tuple
Tcl-word handling for `Canvas.dchars(...)`, `Canvas.focus(...)`,
`Canvas.icursor(...)`, `Canvas.index(...)`, `Canvas.insert(...)`,
`Canvas.select_adjust(...)`, `Canvas.select_from(...)`, and
`Canvas.select_to(...)`. A fresh Python 3.10.11 probe confirmed that covered
required `None` operands truncate the remaining Tcl argument vector into local
wrong-args paths, while list/tuple operands are folded into a single Tcl word
for covered item id, index, and inserted-text paths. The probe also confirmed
that `Canvas.focus(None)` preserves the no-argument/current-focus query shape
rather than clearing focus. The AHK Canvas wrapper now routes these covered
edit and selection operands through `AhkStdlibTkinterCanvasScript(...)` and
`AhkStdlibTkinterCanvasValueWord(...)`, while preserving existing return
normalization for focus, index, and selection queries. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_classic_canvas_edit_sequence_probe.py` plus
JSON output, a focused red report failing because `Canvas.dchars(None, 1)` did
not raise the Python-observed Tcl wrong-args error, focused green
`TestClassicCanvasTextEditSelectionSequenceMethodsMatchLocal310` passing 1/1
in 156 ms, adjacent `Canvas` filter passing 15/15 in 1219 ms, full tkinter
filter passing 258/258 in 41406 ms, example validation passing, README en/zh
capture passing 1/1 in 1219 ms with pollution assertions, and aggregate
`stdlib/tests` passing 1126/1126 in 49375 ms at `-TimeoutSeconds 90` with the
existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic
PhotoImage command family with batched `None`/list/tuple Tcl-word handling for
`PhotoImage.get(x, y)`, `PhotoImage.zoom(x, y=None)`,
`PhotoImage.subsample(x, y=None)`, `PhotoImage.transparency_get(x, y)`, and
`PhotoImage.transparency_set(x, y, boolean)`. A fresh Python 3.10.11 probe
confirmed that covered required `None` coordinate and boolean operands
truncate the remaining Tcl argument vector into local wrong-args paths, while
list/tuple operands are folded into a single Tcl word for covered integer and
boolean validation paths. The probe also confirmed Python's optional
`zoom`/`subsample` second-coordinate behavior, where `y=None` reuses the
single-coordinate path. The AHK `PhotoImage` wrapper now routes the covered
pixel, transform, and transparency operands through PhotoImage-specific
Tcl-word helpers while preserving returned `PhotoImage` objects and pixel
state. This slice did not require new visible README/example code, but the
existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_photoimage_sequence_probe.py` plus JSON output, a focused red
report erroring because a list coordinate reached AHK string conversion as an
Array, focused green `TestPhotoImageSequenceMethodsMatchLocal310` passing 1/1
in 156 ms, adjacent `PhotoImage` filter passing 3/3 in 344 ms, adjacent
`Image` filter passing 8/8 in 703 ms, example validation passing, README en/zh
capture passing 1/1 in 1063 ms with pollution assertions, and aggregate
`stdlib/tests` passing 1125/1125 in 49297 ms at `-TimeoutSeconds 90` with the
existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic
Scrollbar command family with batched `None`/list/tuple Tcl-word handling for
`Scrollbar.activate(index=None)`, `Scrollbar.delta(deltax, deltay)`,
`Scrollbar.fraction(x, y)`, `Scrollbar.identify(x, y)`, and
`Scrollbar.set(first, last)`. A fresh Python 3.10.11 probe confirmed that
`activate(None)` performs the same query/no-active path as `activate()`,
covered required `None` operands in delta/fraction/identify/set truncate the
remaining Tcl argument vector into local wrong-args paths, and list/tuple
operands are folded into a single Tcl word for covered element, integer, and
floating-point validation paths. The AHK classic Scrollbar wrapper now routes
covered operands through a Scrollbar-specific Tcl-word helper while preserving
the no-argument `activate()` query path. This slice did not require new visible
README/example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_classic_scrollbar_sequence_probe.py` plus JSON output, a
focused red report erroring because `Scrollbar.activate([])` reached AHK string
conversion instead of the Python-observed empty Tcl-word/no-active path,
focused green `TestClassicScrollbarSequenceMethodsMatchLocal310` passing 1/1
in 157 ms, adjacent `Scrollbar` filter passing 5/5 in 516 ms, example
validation passing, README en/zh capture passing 1/1 in 1141 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1124/1124 in 49547 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic
Scale command family with batched `None`/list/tuple Tcl-word handling for
`Scale.coords(value=None)`, `Scale.set(value)`, and `Scale.identify(x, y)`.
A fresh Python 3.10.11 probe confirmed that `coords(None)` performs the same
query as `coords()`, required `None` operands in `set(...)` and
`identify(...)` truncate the remaining Tcl argument vector into local
wrong-args paths, and list/tuple operands are folded into a single Tcl word,
including empty-string, one-value, and multi-value numeric Tcl validation
paths. The AHK classic Scale wrapper now routes covered operands through a
Scale-specific Tcl-word helper while preserving the no-argument `coords()`
query path. This slice did not require new visible README/example code, but
the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_classic_scale_sequence_probe.py` plus JSON output, a focused
red report failing because `Scale.coords(stdlib.None)` reported
`expected floating-point number but got "None"` instead of the Python-observed
query result, focused green `TestClassicScaleSequenceMethodsMatchLocal310`
passing 1/1 in 157 ms, adjacent `Scale` filter passing 9/9 in 859 ms, example
validation passing, README en/zh capture passing 1/1 in 1094 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1123/1123 in 48547 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic
PanedWindow command family with batched `None`/list/tuple Tcl-word handling for
`PanedWindow.add(...)`, `PanedWindow.remove(...)` / `forget(...)`,
`PanedWindow.panecget(...)`, `PanedWindow.paneconfigure(...)` /
`paneconfig(...)`, `PanedWindow.identify(...)`, `PanedWindow.proxy_place(...)`,
`PanedWindow.sash_coord(...)`, `PanedWindow.sash_mark(...)`, and
`PanedWindow.sash_place(...)`. A fresh Python 3.10.11 probe confirmed that
covered required `None` child, index, x, and y operands truncate the remaining
Tcl argument vector into local wrong-args paths; list/tuple operands are folded
into a single Tcl word; and list/tuple child operands containing widget objects
are folded through their widget path names. The probe also confirmed that
`panecget(child, None)` raises CPython's wrapper-level string-concatenation
`TypeError`, while `paneconfigure(child, None)` performs the same query as
`paneconfigure(child)`. The AHK classic PanedWindow wrapper now routes covered
operands through a PanedWindow-specific Tcl-word helper shared by the covered
child/path, coordinate, proxy, and sash command paths. This slice did not
require new visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_classic_panedwindow_sequence_probe.py` plus
JSON output, a focused red report failing because
`PanedWindow.add(stdlib.None)` reported `bad window path name "None"` instead
of the Python-observed wrong-args TclError, focused green
`TestClassicPanedWindowSequenceMethodsMatchLocal310` passing 1/1 in 172 ms,
adjacent `PanedWindow` filter passing 6/6 in 687 ms, example validation
passing, README en/zh capture passing 1/1 in 1062 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1122/1122 in 48485 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
Menu command family with batched `None`/list/tuple Tcl-word handling for
`Menu.add(...)`, `Menu.insert(...)`, `Menu.insert_command(...)`,
`Menu.index(...)`, `Menu.type(...)`, `Menu.activate(...)`,
`Menu.invoke(...)`, `Menu.delete(...)`, `Menu.entrycget(...)`,
`Menu.entryconfigure(...)`, `Menu.entryconfig(...)`, `Menu.xposition(...)`,
`Menu.yposition(...)`, and the covered non-posting `Menu.post(...)` error
paths. A fresh Python 3.10.11 probe confirmed that covered required `None`
operands truncate the remaining Tcl argument vector into local wrong-args
paths, list/tuple menu indexes and entry types are folded into a single Tcl
word, `entryconfigure(index, None)` performs the same query as CPython, and
`entrycget(index, None)` raises the Python wrapper string-concatenation
`TypeError`. The probe intentionally avoids a successful `post(...)` call
because that can enter platform popup UI state under a hidden root; only the
non-posting `None` error paths are claimed. The AHK classic Menu wrapper now
routes covered operands through a Menu-specific Tcl-word helper and preserves
CPython's `delete(...)` wrapper order by validating indexes before dispatching
the Tcl delete command. This slice did not require new visible README/example
code, but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_classic_menu_sequence_probe.py` plus JSON output, a focused red
report failing because `Menu.index(stdlib.None)` reported
`bad menu entry index "None"` instead of the Python-observed wrong-args
TclError, focused green `TestClassicMenuSequenceMethodsMatchLocal310` passing
1/1 in 188 ms, adjacent `Menu` filter passing 8/8 in 1063 ms, example
validation passing, README en/zh capture passing 1/1 in 1172 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1121/1121 in 49625 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
Listbox command family with batched `None`/list/tuple Tcl-word handling for
`Listbox.get(...)`, `Listbox.delete(...)`, `Listbox.index(...)`,
`Listbox.activate(...)`, `Listbox.bbox(...)`, `Listbox.insert(...)`,
`Listbox.selection_clear(...)`, `Listbox.selection_includes(...)`,
`Listbox.selection_anchor(...)`, `Listbox.selection_set(...)`,
`Listbox.nearest(...)`, `Listbox.see(...)`, `Listbox.itemcget(...)`, and
`Listbox.itemconfigure(...)`. A fresh Python 3.10.11 probe confirmed that
covered required `None` operands truncate the remaining Tcl argument vector
into the local wrong-args path, list/tuple index operands are folded into a
single Tcl list word, and inserted scalar strings with spaces remain one
listbox item for the covered path. Nested Python object identity for
`Listbox.insert(list/tuple)` remains intentionally unclaimed because the current
AHK Tcl string bridge cannot preserve `_tkinter` object payload identity. The
AHK classic Listbox wrapper now routes covered operands through the shared
Listbox Tcl-word helper and uses Tcl list splitting for covered range `get(...)`
results so item text containing spaces is preserved. This slice did not require
new visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes `.codex/tkinter_classic_listbox_sequence_probe.py` plus JSON output, a
focused red observation where `Listbox.get(stdlib.None)` reached Tcl as the
literal `"None"` and reported `bad listbox index "None"` instead of the
Python-observed wrong-args TclError, focused green
`TestClassicListboxSequenceMethodsMatchLocal310` passing 1/1 in 187 ms, example
validation passing, README en/zh capture passing 1/1 in 1437 ms with pollution
assertions, and aggregate `stdlib/tests` passing 1120/1120 in 49031 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
Entry/Spinbox command family with batched `None`/list/tuple Tcl-word handling
for `Entry.insert(...)`, `Entry.delete(...)`, `Entry.icursor(...)`,
`Entry.index(...)`, `Entry.selection_from(...)`, `Entry.selection_to(...)`,
`Entry.selection_range(...)`, `Spinbox.bbox(...)`, `Spinbox.delete(...)`,
`Spinbox.icursor(...)`, `Spinbox.identify(...)`, `Spinbox.index(...)`,
`Spinbox.insert(...)`, `Spinbox.invoke(...)`,
`Spinbox.selection_element(...)`, and `Spinbox.selection_range(...)`. A fresh
Python 3.10.11 probe confirmed that covered required `None` operands truncate
the remaining Tcl argument vector into the local wrong-args path, optional
`None` operands are omitted where CPython omits them, and list/tuple operands
are folded into a single Tcl list word for covered indexes, text payloads,
coordinates, element names, and selection bounds. The AHK classic Entry and
Spinbox wrappers now route covered operands through the shared Entry Tcl-word
conversion used by the selection helpers. This slice did not require new
visible README/example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes `.codex/tkinter_classic_entry_spinbox_sequence_probe.py` plus JSON
output, a focused red report failing because
`Entry.insert(stdlib.None, "X")` reported `bad entry index "None"` instead of
the Python-observed wrong-args TclError, focused green
`TestClassicEntrySpinboxSequenceMethodsMatchLocal310` passing 1/1 in 156 ms,
adjacent Entry passing 18/18 in 7516 ms, adjacent Spinbox passing 4/4 in
782 ms, adjacent Classic passing 10/10 in 922 ms, example validation passing,
README en/zh capture passing 1/1 in 1172 ms with pollution assertions, and
aggregate `stdlib/tests` passing 1119/1119 in 49109 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
miscellaneous edit/bind/view command family with batched `None`/list/tuple
Tcl-word handling for `Text.debug(...)`, `Text.edit(...)`,
`Text.yview_pickplace(...)`, `Text.tag_bind(...)`, and
`Text.tag_unbind(...)`. A fresh Python 3.10.11 probe confirmed that
`debug(None)` queries, tuple/list boolean values reach Tcl as one word,
`edit(None)` truncates to the wrong-args path, tuple/list edit options and
modified values are folded into a single Tcl list word, `yview_pickplace(None)`
truncates to the wrong-args path, tuple/list text indexes are folded into one
word, and covered tag bind/unbind tag-name and sequence operands follow the
same truncation/folding rules. The AHK classic Text wrappers now use the shared
Text Tcl-word conversion for these covered operands, and `tag_unbind` avoids
appending the empty script after a truncated tag or sequence operand. This slice
did not add visible README/example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_classic_text_misc_sequence_probe.py` plus
JSON output, a focused red report erroring because
`Text.debug(stdlib.tuple([stdlib.True]))` hit AHK tuple string conversion before
Tcl, focused green `TestClassicTextMiscSequenceMethodsMatchLocal310` passing
1/1 in 156 ms, adjacent Text passing 7/7 in 734 ms, adjacent Classic passing
9/9 in 797 ms, example validation passing, README en/zh capture passing 1/1 in
1000 ms with pollution assertions, and aggregate `stdlib/tests` passing
1118/1118 in 48969 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
edit/peer command family with batched `None`/list/tuple Tcl-word handling for
`Text.get(...)`, `Text.delete(...)`, `Text.insert(...)`,
`Text.replace(...)`, and `Text.peer_create(...)`. A fresh Python 3.10.11 probe
confirmed that covered required `None` operands truncate the remaining Tcl
argument vector into the local wrong-args path, optional `None` operands are
omitted where CPython omits them, and list/tuple operands are folded into a
single Tcl list word for covered text indexes, inserted/replaced character
payloads, tag lists, and peer path names. The probe also confirmed the covered
`Text.peer_create(path, None)` error shape as `AttributeError: 'NoneType'
object has no attribute 'items'`. The AHK classic Text edit and peer wrappers
now route covered operands through `AhkStdlibTkinterTextScript(...)` and
`AhkStdlibTkinterTextValueWord(...)`, and `peer_create` avoids appending
options after a truncated peer path. This slice did not add visible
README/example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_classic_text_edit_peer_sequence_probe.py` plus JSON output, a
focused red report failing because `Text.get(stdlib.None, "end")` reported
`bad text index "None"` instead of the Python-observed wrong-args TclError,
focused green `TestClassicTextEditPeerSequenceMethodsMatchLocal310` passing
1/1 in 156 ms, adjacent Text passing 6/6 in 625 ms, adjacent Classic passing
8/8 in 719 ms, example validation passing, README en/zh capture passing 1/1 in
1234 ms with pollution assertions, and aggregate `stdlib/tests` passing
1117/1117 in 48937 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
tag/embed/config command family with batched `None`/list/tuple Tcl-word
handling for `Text.tag_cget(...)`, `Text.tag_configure(...)`,
`Text.tag_delete(...)`, `Text.image_create(...)`, `Text.image_cget(...)`,
`Text.image_configure(...)`, `Text.window_create(...)`,
`Text.window_cget(...)`, and `Text.window_configure(...)`. A fresh Python
3.10.11 probe confirmed that covered tag-name or index `None` operands truncate
the remaining Tcl argument vector into the local wrong-args path, while
list/tuple operands are folded into a single Tcl list word. Covered configure
wrappers also avoid appending options after a truncated `None`; option
list/tuple values are not claimed by this slice. The AHK classic Text
tag/image/window wrappers now route covered tag-name and index operands through
`AhkStdlibTkinterTextScript(...)` and `AhkStdlibTkinterTextValueWord(...)`,
with local configure option/dict helpers for tag, image, and window commands.
This slice did not add visible README/example code, but the existing tkinter
example and extracted README snippets were revalidated through the capture
harness. Fresh evidence includes
`.codex/tkinter_classic_text_embed_config_sequence_probe.py` plus JSON output,
a focused red report failing because `Text.tag_cget(stdlib.None, "foreground")`
reported `tag "None" isn't defined in text widget` instead of the
Python-observed wrong-args TclError, focused green
`TestClassicTextEmbedConfigSequenceMethodsMatchLocal310` passing 1/1 in
156 ms, adjacent Text passing 5/5 in 562 ms, adjacent Classic passing 7/7 in
657 ms, example validation passing, README en/zh capture passing 1/1 in
1157 ms with pollution assertions, and aggregate `stdlib/tests` passing
1116/1116 in 48453 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
query/dump command family with batched `None`/list/tuple sequence handling for
`Text.count(...)`, `Text.search(...)`, and `Text.dump(...)`. A fresh Python
3.10.11 probe confirmed that covered `None` index or pattern operands truncate
the remaining Tcl argument vector into the local wrong-args or bad-index path,
while list/tuple operands are folded into a single Tcl list word. The covered
probe also confirms CPython's `Text.count` option-name formatting for a
single-item tuple, `Text.search(..., count=IntVar)` and
`count=(IntVar,)` behavior, `Text.search(..., stopindex=None)` omission, and
`Text.dump(..., index2=None)` omission. The AHK classic Text query methods now
route Tcl operands through `AhkStdlibTkinterTextScript(...)` and
`AhkStdlibTkinterTextValueWord(...)`, with local helpers for `count` option
formatting, `search` dash-prefix detection, and Text sequence joining that
preserves variable names. This slice did not add visible README/example code,
but the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_classic_text_query_sequence_probe.py` plus JSON output, a
focused red report failing because `Text.count(stdlib.None, "end", "chars")`
reported `bad text index "None"` instead of the Python-observed wrong-args
TclError, focused green `TestClassicTextQuerySequenceMethodsMatchLocal310`
passing 1/1 in 141 ms, adjacent Text filter passing 38/38 in 1016 ms, adjacent
Classic passing 6/6 in 562 ms, example validation passing, README en/zh capture
passing 1/1 in 1140 ms with pollution assertions, no README/example pollution
matches for `System.Text.RegularExpressions` or `MatchEvaluator`, Friendly Links
preserved, class-name collision scan passing, and aggregate `stdlib/tests`
passing 1115/1115 in 48453 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Text
mark/tag/index command family with batched `None`/list/tuple sequence handling
for `Text.index(...)`, `Text.compare(...)`, `Text.mark_set(...)`,
`Text.mark_unset(...)`, `Text.mark_gravity(...)`, `Text.mark_next(...)`,
`Text.mark_previous(...)`, `Text.tag_add(...)`, `Text.tag_remove(...)`,
`Text.tag_ranges(...)`, `Text.tag_names(...)`, `Text.tag_nextrange(...)`,
`Text.tag_prevrange(...)`, `Text.tag_raise(...)`, `Text.tag_lower(...)`,
`Text.bbox(...)`, `Text.dlineinfo(...)`, and `Text.see(...)`. A fresh Python
3.10.11 probe confirmed that covered `None` operands truncate the remaining Tcl
argument vector into the local wrong-args path, while list/tuple operands are
folded into a single Tcl list word. Empty sequences reach Tcl as `""`, one-item
sequences match their scalar equivalent where Tcl accepts them, and multi-item
sequences reach Tcl as one space-joined word. The AHK classic Text methods now
share `AhkStdlibTkinterTextScript(...)` and
`AhkStdlibTkinterTextValueWord(...)`, stopping operand emission at covered
`None` and preserving CPython-style Tcl word folding for covered sequence
operands. This slice did not add visible README/example code, but the existing
tkinter example and extracted README snippets were revalidated through the
capture harness. Fresh evidence includes
`.codex/tkinter_classic_text_mark_tag_sequence_probe.py` plus JSON output, a
focused red report failing because `Text.index(stdlib.None)` produced
`bad text index "None"` instead of the Python-observed wrong-args TclError,
focused green `TestClassicTextMarkTagSequenceMethodsMatchLocal310` passing 1/1
in 140 ms, adjacent Text passing 3/3 in 406 ms, adjacent Classic passing 5/5 in
547 ms, example validation passing, README en/zh capture passing 1/1 in
1157 ms with pollution assertions, no README/example pollution matches for
`System.Text.RegularExpressions` or `MatchEvaluator`, Friendly Links preserved,
class-name collision scan passing, and aggregate `stdlib/tests` passing
1114/1114 in 47563 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The preceding tkinter implementation slice extends the covered classic Canvas
Tcl-word command family with batched `None`/list/tuple sequence handling for
`Canvas.coords(...)`, `Canvas.find(...)`, `Canvas.find_withtag(...)`,
`Canvas.find_closest(...)`, `Canvas.bbox(...)`, `Canvas.move(...)`,
`Canvas.scale(...)`, `Canvas.addtag(...)`, `Canvas.addtag_all(...)`,
`Canvas.addtag_withtag(...)`, `Canvas.addtag_closest(...)`, `Canvas.dtag(...)`,
and `Canvas.gettags(...)`. A fresh Python 3.10.11 probe confirmed both the raw
`tk.call("list", ...)` argv rule and the Canvas method behavior: a `None`
operand truncates the remaining Tcl argument vector, while list/tuple operands
are folded into a single Tcl list word. Empty sequences reach Tcl as `""`,
one-item sequences such as `(lineId,)` match the same item as the scalar id, and
multi-item sequences such as `[1, 2]` or `["shape", "round"]` reach Tcl as one
space-joined word. The AHK classic Canvas methods now share
`AhkStdlibTkinterCanvasScript(...)` and
`AhkStdlibTkinterCanvasValueWord(...)`, stopping operand emission at covered
`None` and preserving CPython-style Tcl word folding for covered sequence
operands. This slice did not add visible README/example code, but the existing
tkinter example and extracted README snippets were revalidated through the
capture harness. Fresh evidence includes
`.codex/tkinter_classic_canvas_word_sequence_probe.py` plus JSON output, a
focused red report failing because `Canvas.coords(stdlib.None)` did not raise
the Python-observed wrong-args TclError, focused green
`TestClassicCanvasWordSequenceMethodsMatchLocal310` passing 1/1 in 235 ms,
adjacent Canvas passing 14/14 in 1406 ms, adjacent Classic passing 4/4 in
718 ms, example validation passing, README en/zh capture passing 1/1 in
1187 ms with pollution assertions, no README/example pollution matches for
`System.Text.RegularExpressions` or `MatchEvaluator`, Friendly Links preserved,
class-name collision scan passing, and aggregate `stdlib/tests` passing
1113/1113 in 51453 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line.

The latest tkinter implementation slice extends the covered classic-widget scan
command family with batched `None`/list/tuple sequence handling for
`Canvas.scan_mark(...)`, `Canvas.scan_dragto(...)`, `Text.scan_mark(...)`,
`Text.scan_dragto(...)`, `Listbox.scan_mark(...)`, `Listbox.scan_dragto(...)`,
`Entry.scan_mark(...)`, `Entry.scan_dragto(...)`, `Spinbox.scan_mark(...)`, and
`Spinbox.scan_dragto(...)`. A fresh Python 3.10.11 probe confirmed that covered
`None` operands truncate the remaining Tcl argument vector into the local
wrong-args path, that list/tuple operands are folded into a single Tcl word
before integer parsing, and that `Canvas.scan_dragto(..., gain=None)` succeeds
by omitting the optional gain operand. Empty sequences reach Tcl as `""`, while
multi-item sequences reach Tcl as one space-joined word such as `"5 6"` or
`"1 2"`. The AHK classic scan methods now share
`AhkStdlibTkinterScanScript(...)` and `AhkStdlibTkinterScanValueWord(...)`,
stopping operand emission at covered `None` and preserving CPython-style Tcl
word folding for covered sequence operands. README en/zh now include classic
Canvas scan sequence calls, and the tkinter example records classic
Spinbox/Entry/Listbox/Text/Canvas scan sequence calls without changing the
visible demo lifetime. Fresh evidence includes
`.codex/tkinter_classic_scan_sequence_probe.py` plus JSON output, a focused red
report for `ClassicScan` erroring on an unconverted `AhkStdlibTuple` scan
operand, focused green passing 1/1 in 313 ms, adjacent Canvas passing 13/13 in
1640 ms, adjacent Text passing 2/2 in 344 ms, adjacent Listbox passing 1/1 in
297 ms, adjacent Entry passing 17/17 in 9344 ms, adjacent Spinbox passing 3/3 in
875 ms, example validation passing, README en/zh capture passing 1/1 in 1610 ms
with pollution assertions, no README/example pollution matches for
`System.Text.RegularExpressions` or `MatchEvaluator`, class-name collision scan
passing, and aggregate `stdlib/tests` passing 1112/1112 in 56437 ms at
`-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The latest tkinter implementation slice extends the covered classic-widget view
command family with batched `None`/list/tuple sequence handling for
`Canvas.xview/yview`, `Text.xview/yview`, `Listbox.xview/yview`,
`Entry.xview`, and `Spinbox.xview`, including the `xview_moveto(...)`,
`xview_scroll(...)`, `yview_moveto(...)`, and `yview_scroll(...)` wrappers where
the class exposes them. A fresh Python 3.10.11 probe confirmed that raw
`xview(None)` / `yview(None)` truncate to the zero-argument query path, while
list/tuple operands are folded into a single Tcl word; empty sequences reach Tcl
as `""`, and multi-item sequences reach Tcl as one space-joined word such as
`"moveto 0.5"`, `"0.5 0.6"`, `"1 2"`, or `"units pages"`. The AHK classic view
methods now share `AhkStdlibTkinterViewScript(...)` and
`AhkStdlibTkinterViewValueWord(...)`, stopping operand emission at covered
`None` and preserving CPython-style Tcl word folding for covered sequence
operands. README en/zh and the tkinter example now include classic Canvas view
sequence calls, and the example also records classic Entry/Listbox/Text/Canvas
sequence view calls without changing the visible demo lifetime. Fresh evidence
includes `.codex/tkinter_classic_view_sequence_probe.py` plus JSON output, a
focused red report for `ClassicView` erroring because `Canvas.xview(stdlib.None)`
sent `"None"` to Tcl, focused green passing 1/1 in 328 ms, adjacent Canvas
passing 13/13 in 2875 ms, adjacent Text passing 2/2 in 578 ms, adjacent Listbox
passing 1/1 in 328 ms, adjacent Entry passing 17/17 in 15531 ms, adjacent
Spinbox passing 3/3 in 875 ms, example validation passing, README en/zh capture
passing 1/1 in 1344 ms with pollution assertions, no README/example pollution
matches for `System.Text.RegularExpressions` or `MatchEvaluator`, class-name
collision scan passing, and aggregate `stdlib/tests` passing 1111/1111 in
50937 ms at `-TimeoutSeconds 90` with the existing `plain fallback` stderr line.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with batched `ttk.Treeview` `xview(...)`, `xview_moveto(...)`,
`xview_scroll(...)`, `yview(...)`, `yview_moveto(...)`, and `yview_scroll(...)`
`None`/list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed
that raw `xview(None)` and `yview(None)` truncate to the zero-argument query
path, that raw command sequences such as `["moveto"]` and `["moveto", "0.5"]`
are folded into one Tcl word and rejected as integer operands, and that
`moveto`/`scroll` wrappers fold list/tuple fraction, number, and units/pages
operands into a single Tcl list word while `None` truncates into local
`expected integer but got "moveto"` / `"scroll"` or wrong-args TclError paths.
The AHK prefixed-internal `AhkStdlibTkinterTreeview` view methods now build Tcl
commands operand by operand, stop on covered `None`, and route covered sequence
operands through the ttk value-word conversion. The shared ttk join helper no
longer relies on ambient `A_Index`, preserving empty-sequence Tcl words for this
and other covered ttk sequence paths. README en/zh and the tkinter example now
include Treeview view sequence calls without changing the visible demo lifetime.
Fresh evidence includes `.codex/tkinter_ttk_treeview_view_sequence_probe.py`
plus JSON output, a focused red report for
`TtkTreeviewViewNoneAndSequenceWordsMatchLocal310` erroring because `None` was
sent as `"None"`, focused green passing 1/1 in 297 ms, adjacent `TtkTreeview`
passing 21/21 in 4891 ms, example validation passing, README en/zh capture
passing 1/1 in 1593 ms with pollution assertions, and aggregate `stdlib/tests`
passing 1110/1110 in 75110 ms at `-TimeoutSeconds 90` with the existing
`plain fallback` stderr line. No 40-second aggregate stability is claimed.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with batched Entry-family `xview_moveto(fraction)` and
`xview_scroll(number, what)` `None`/list/tuple sequence handling for
`ttk.Entry`, `ttk.Spinbox`, and `ttk.Combobox`. A fresh Python 3.10.11 probe
confirmed that list/tuple operands are folded into a single Tcl list word for
the covered fraction, number, and units/pages arguments, while `None` truncates
the remaining Tcl argument vector into the local bad-index or wrong-args TclError
paths. Empty sequences reach Tcl as an empty word, and multi-item sequences
reach Tcl as one space-joined word such as `"0.5 0.6"` or `"units pages"`. The
AHK prefixed-internal `AhkStdlibTkinterEntry.xview_moveto` and
`AhkStdlibTkinterEntry.xview_scroll` now build the Tcl command operand by
operand, stop on covered `None`, and route covered sequence/scalar operands
through the same ttk value-word conversion used by the concrete ttk subclasses.
README en/zh and the tkinter example now include Entry, Spinbox, and Combobox
sequence xview calls without changing the visible demo lifetime. Fresh evidence
includes `.codex/tkinter_ttk_entry_xview_sequence_probe.py` plus JSON output, a
focused red report for `TtkEntryFamilyXviewNoneAndSequenceWordsMatchLocal310`
erroring on an unconverted Array operand, focused green passing 1/1 in 719 ms,
adjacent `TtkEntry` passing 13/13 in 10500 ms, adjacent `TtkSpinbox` passing 2/2
in 719 ms, and adjacent `TtkCombobox` passing 3/3 in 1063 ms. Serial promotion
gates also include example validation passing and README en/zh capture passing
1/1 in 2016 ms with pollution assertions. The follow-up aggregate
`run-ahktest stdlib/tests -TimeoutSeconds 90` passed 1109/1109 in 47860 ms with
the existing `plain fallback` stderr line, raising the current aggregate
baseline without claiming 40-second aggregate stability.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with batched `identify` coordinate handling for the raw
`ttk.Widget` constructor and `ttk.Treeview.identify(...)` convenience wrappers.
A fresh Python 3.10.11 probe confirmed that `ttk.Widget.identify(x, y)` and
`ttk.Treeview.identify_row/identify_column/identify_region/identify_element`
fold list/tuple coordinates into one Tcl list word, while `None` truncates the
remaining Tcl argument vector and reaches the local Tcl wrong-args or
expected-integer error path. The AHK prefixed-internal `AhkStdlibTkinterTtkWidget`
now delegates `identify` through `AhkStdlibTkinterTtkWidgetIdentify`, and
`AhkStdlibTkinterTreeview.identify` routes coordinate operands through the same
ttk float value-word conversion while preserving the existing component word
conversion. README en/zh and the example now include raw `ttk.Widget` and
`Treeview` sequence-coordinate calls without changing the visible demo lifetime.
Fresh evidence includes
`.codex/tkinter_ttk_identify_wrappers_sequence_probe.py` plus JSON output,
focused red reports for `TtkWidgetIdentifyNoneAndSequenceWordsMatchLocal310`
failing on `"None"` string conversion and
`TtkTreeviewIdentifyWrapperCoordinatesNoneAndSequenceWordsMatchLocal310`
erroring on an unconverted Array coordinate, focused green reports passing 1/1
for each test, adjacent `TtkWidget` passing 9/9 in 2875 ms, and adjacent
`TreeviewIdentify` passing 3/3 in 547 ms, example validation passing, README
en/zh capture passing 1/1 in 1672 ms with pollution assertions, and aggregate
`stdlib/tests` passing 1108/1108 in 56094 ms at `-TimeoutSeconds 60`.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with a batched shared-widget `identify(x, y)` method and
`None`/list/tuple sequence pass for `ttk.Button`, `ttk.Checkbutton`,
`ttk.Radiobutton`, `ttk.Frame`, `ttk.Label`, `ttk.Menubutton`,
`ttk.Separator`, and `ttk.Progressbar`. A fresh Python 3.10.11 probe confirmed
that these concrete ttk widget classes expose `identify`, that scalar
coordinates return the covered element string, and that `None` coordinates
truncate remaining Tcl operands into the local wrong-args TclError while
list/tuple coordinate operands are folded into one Tcl word. Empty sequences
raise `expected integer but got ""`, one-item sequences behave like scalar
coordinates in the covered geometry, and multi-item sequences such as `["5",
"6"]` raise `expected integer but got "5 6"`. The AHK prefixed-internal
concrete ttk classes now expose `identify` and delegate to the new
`AhkStdlibTkinterTtkWidgetIdentify` helper, preserving the existing concrete
class hierarchy while routing covered coordinates through the ttk float
value-word helper. This batch did not add visible README or example code, but
the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_widget_identify_sequence_probe.py` and its output JSON, a
batched focused red report erroring for all eight new tests because the AHK
concrete ttk widgets had no `identify` method, batched focused green passing
8/8 in 1093 ms, adjacent button/checkbutton/radiobutton report passing 7/7 in
750 ms, adjacent frame/label family report passing 8/8 in 1125 ms, adjacent
`TtkMenubutton` passing 2/2 in 250 ms, adjacent `TtkSeparator` passing 2/2 in
250 ms, adjacent `TtkProgressbar` passing 3/3 in 3969 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1860 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with a batched `identify(x, y)` `None` and
list/tuple sequence pass for `ttk.Notebook`, `ttk.Panedwindow`, `ttk.Sizegrip`, and
`ttk.LabelFrame`. Fresh Python 3.10.11 probes confirmed for each covered widget
that a `None` coordinate truncates remaining Tcl operands and reaches the local
wrong-args TclError, while list/tuple coordinate operands are folded into one
Tcl word: empty sequences raise `expected integer but got ""`, one-item
sequences behave like scalar coordinates in the covered geometry, and multi-item
sequences such as `["5", "6"]` raise `expected integer but got "5 6"`. The AHK
prefixed-internal `AhkStdlibTkinterNotebook.identify`,
`AhkStdlibTkinterPanedwindow.identify`, `AhkStdlibTkinterSizegrip.identify`,
and `AhkStdlibTkinterLabelFrame.identify` now truncate on the first covered
`None` and route covered coordinate sequences through the ttk float value-word
helper. This batch does not raise a Notebook element-geometry parity claim
beyond the covered parameter semantics. It did not add visible README or example
code, but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_notebook_identify_sequence_probe.py`,
`.codex/tkinter_ttk_panedwindow_identify_sequence_probe.py`,
`.codex/tkinter_ttk_sizegrip_identify_sequence_probe.py`, and
`.codex/tkinter_ttk_labelframe_identify_sequence_probe.py` plus their output
JSON files; a batched focused red report failing all four new tests because
covered `identify(stdlib.None, 5)` paths reported `expected integer but got
"None"` instead of the Python-observed wrong-args TclErrors; batched focused
green passing 4/4 in 453 ms; adjacent `TtkNotebook` passing 3/3 in 828 ms,
`TtkPanedwindow` passing 4/4 in 1172 ms, `TtkSizegrip` passing 2/2 in 453 ms,
and `TtkLabelFrame` passing 2/2 in 500 ms; explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing; and README en/zh
examples passing through ahktest capture with pollution assertions in 1828 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.LabeledScale.identify(x, y)` `None` and
list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed that scalar
`identify(5, 5)` returns the empty string in the covered geometry, a `None`
argument truncates the remaining Tcl operands, and the covered
`identify(None, 5)`, `identify(5, None)`, and `identify(None, None)` paths
therefore raise the local wrong-args TclError from the underlying frame command.
List/tuple coordinate operands are folded into one Tcl word, so empty sequences
raise `expected integer but got ""`, one-item sequences behave like scalar
coordinates, and multi-item sequences such as `["5", "6"]` raise `expected
integer but got "5 6"`. The AHK prefixed-internal
`AhkStdlibTkinterTtkLabeledScale.identify` now truncates on the first covered
`None` and routes covered coordinate sequences through the ttk float value-word
helper. This slice did not add visible README or example code, but the existing
tkinter example and extracted README snippets were revalidated through the
capture harness. Fresh evidence includes
`.codex/tkinter_ttk_labeledscale_identify_sequence_probe.py` and
`.codex/tkinter_ttk_labeledscale_identify_sequence_probe.output.json`, a focused
red test failing because `labeled.identify(stdlib.None, 5)` reported `expected
integer but got "None"` instead of the Python-observed wrong-args TclError,
focused green `TtkLabeledScaleIdentifyNoneAndSequenceWordsMatchLocal310`
passing 1/1 in 140 ms, adjacent `TtkLabeledScale` report passing 2/2 in 375 ms,
explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and
README en/zh examples passing through ahktest capture with pollution assertions
in 1250 ms. No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.Scrollbar.identify(x, y)` `None` and
list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed that scalar
`identify(5, 5)` returns the empty string in the covered geometry, a `None`
argument truncates the remaining Tcl operands, and the covered
`identify(None, 5)`, `identify(5, None)`, and `identify(None, None)` paths
therefore raise the local wrong-args TclError. List/tuple coordinate operands
are folded into one Tcl word, so empty sequences raise `expected integer but
got ""`, one-item sequences behave like scalar coordinates, and multi-item
sequences such as `["5", "6"]` raise `expected integer but got "5 6"`. The AHK
prefixed-internal `AhkStdlibTkinterScrollbar.identify` now truncates on the
first covered `None` and routes covered coordinate sequences through the ttk
float value-word helper. This slice did not add visible README or example code,
but the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_scrollbar_identify_sequence_probe.py` and
`.codex/tkinter_ttk_scrollbar_identify_sequence_probe.output.json`, a focused
red test failing because `scrollbar.identify(stdlib.None, 5)` reported
`expected integer but got "None"` instead of the Python-observed wrong-args
TclError, focused green `TtkScrollbarIdentifyNoneAndSequenceWordsMatchLocal310`
passing 1/1 in 125 ms, adjacent `TtkScrollbar` report passing 3/3 in 328 ms,
explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and
README en/zh examples passing through ahktest capture with pollution assertions
in 1172 ms. No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.Scale.identify(x, y)` `None` and
list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed that scalar
`identify(5, 5)` returns the empty string in the covered geometry, a `None`
argument truncates the remaining Tcl operands, and the covered
`identify(None, 5)`, `identify(5, None)`, and `identify(None, None)` paths
therefore raise the local wrong-args TclError. List/tuple coordinate operands
are folded into one Tcl word, so empty sequences raise `expected integer but
got ""`, one-item sequences behave like scalar coordinates, and multi-item
sequences such as `["5", "6"]` raise `expected integer but got "5 6"`. The AHK
prefixed-internal `AhkStdlibTkinterScale.identify` now truncates on the first
covered `None` and routes covered coordinate sequences through the ttk scale
value-word helper. This slice did not add visible README or example code, but
the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_scale_identify_sequence_probe.py` and
`.codex/tkinter_ttk_scale_identify_sequence_probe.output.json`, a focused red
test failing because `scale.identify(stdlib.None, 5)` reported `expected
integer but got "None"` instead of the Python-observed wrong-args TclError,
focused green `TtkScaleIdentifyNoneAndSequenceWordsMatchLocal310` passing 1/1
in 328 ms, adjacent `TtkScale` report passing 4/4 in 875 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1875 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.Scale.get(*args)` `None` and list/tuple
sequence handling. A fresh Python 3.10.11 probe confirmed that no-arg `get()` returns
the current scale value as a number, coordinate arguments return Tcl's computed
scale value string, and a `None` argument truncates the remaining Tcl operands:
`get(None, 5)` and `get(None, None)` return the current value, while
`get(10, None)` reaches Tk as one coordinate and raises the local wrong-args
TclError. List/tuple coordinate operands are folded into one Tcl word, so empty
sequences raise `expected integer but got ""`, one-item sequences behave like
scalar coordinates, and multi-item sequences such as `["10", "11"]` raise
`expected integer but got "10 11"`. The AHK prefixed-internal
`AhkStdlibTkinterScale.get` now truncates on the first covered `None` and routes
sequence coordinates through the ttk scale value-word helper while preserving
the Python return rule for no-argument calls. This slice did not add visible
README or example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_scale_get_sequence_probe.py` and
`.codex/tkinter_ttk_scale_get_sequence_probe.output.json`, a focused red test
erroring because `scale.get(stdlib.None, 5)` reported `expected integer but got
"None"` instead of returning the current value, focused green
`TtkScaleGetNoneAndSequenceWordsMatchLocal310` passing 1/1 in 109 ms, adjacent
`TtkScale` report passing 3/3 in 297 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1188 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Combobox` inherited `ttk.Entry` public methods. A
fresh Python 3.10.11 probe confirmed that `ttk.Combobox.__mro__` includes
`Entry`, that entry methods such as `bbox`, `delete`, `insert`, `index`,
`icursor`, `selection_range`, `validate`, and `xview` are present, and that
the underlying `ttk::combobox` command supports the same core edit/index
operations while still reporting local `bad command` errors for inherited
`scan` and unsupported `selection from/to/adjust` paths. The AHK
prefixed-internal `AhkStdlibTkinterCombobox` now extends the prefixed ttk Entry
class and bypasses the Entry constructor with the shared widget constructor so
its command remains `ttk::combobox`, preserving existing `current`, `set`, and
configuration behavior while inheriting the covered Entry method surface. This
slice did not add visible README or example code, but the existing tkinter
example and extracted README snippets were revalidated through the capture
harness. Fresh evidence includes
`.codex/tkinter_ttk_combobox_inherited_entry_probe.py` and
`.codex/tkinter_ttk_combobox_inherited_entry_probe.output.json`, a focused red
test failing because `ttk.Combobox` lacked inherited Entry methods such as
`delete`, focused green `TtkComboboxInheritedEntryMethodsMatchLocal310`
passing 1/1 in 140 ms, adjacent `TtkCombobox` report passing 3/3 in 281 ms,
adjacent `TtkEntry` report passing 12/12 in 7938 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 2188 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.xview(*args)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that no-arg `xview()` returns
the visible fraction tuple, but any Python argument makes the method return
`None`; a `None` argument truncates the remaining Tcl operands, so
`xview(None)` becomes a no-op returning `None`, `xview("moveto", None)` reaches
Tk as `xview moveto` and raises `bad entry index "moveto"`, and
`xview("scroll", 1, None)` reaches Tk as `xview scroll 1` and raises the local
wrong-args TclError. List/tuple operands are folded into one Tcl word, with
empty sequences becoming the empty word and multi-item indexes such as
`["1", "2"]` raising `bad entry index "1 2"`. The AHK prefixed-internal
`AhkStdlibTkinterEntry.xview` now preserves the Python return rule, truncates
on the first covered `None`, and routes sequence operands through the ttk entry
index-word helper. This slice did not add visible README or example code, but
the existing tkinter example and extracted README snippets were revalidated
through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_xview_sequence_probe.py` and
`.codex/tkinter_ttk_entry_xview_sequence_probe.output.json`, a focused red test
erroring because `entry.xview(stdlib.None)` reported `bad entry index "None"`
instead of returning `None`, focused green
`TtkEntryXviewNoneAndSequenceWordsMatchLocal310` passing 1/1 in 1984 ms,
adjacent `TtkEntry` report passing 12/12 in 7984 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1235 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.selection_range(start, end)` / `select_range`
`None` and list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed
that `selection_range(None, ...)` and `selection_range(..., None)` omit covered
operands and raise the local wrong-args TclError, empty list/tuple start values
select no text, empty list/tuple end values extend through the widget end,
one-item list/tuple indexes behave like scalar values, and multi-item indexes
such as `["1", "2"]` raise `bad entry index "1 2"`. The same probe confirmed
that themed `selection_from`, `selection_to`, and `selection_adjust` still fail
through the local `ttk::entry` command as unsupported `bad command` paths, so
this slice does not promote them as working ttk functionality. The shared AHK
entry selection-range helper now builds the Tcl command operand by operand,
omitting covered `None` operands and using the ttk entry index-word helper for
sequence operands; focused classic `Entry` and `Spinbox` gates cover the shared
helper risk. This slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_selection_sequence_probe.py` and
`.codex/tkinter_ttk_entry_selection_sequence_probe.output.json`, a focused red
test failing because `entry.selection_range(stdlib.None, 3)` reported `bad
entry index "None"` instead of the local wrong-args TclError, focused green
`TtkEntrySelectionRangeNoneAndSequenceWordsMatchLocal310` passing 1/1 in
2406 ms, adjacent `TtkEntry` report passing 11/11 in 19656 ms, shared
classic `Entry`/`Spinbox` report passing 2/2 in 218 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1172 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.icursor(index)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that `icursor(None)` omits the
required position operand and raises the local wrong-args TclError, empty
list/tuple indexes position the insert cursor like `icursor("end")`, one-item
list/tuple indexes behave like their scalar value, and multi-item indexes such
as `["1", "2"]` raise `bad entry index "1 2"`. The AHK prefixed-internal
`AhkStdlibTkinterEntry` now builds the `icursor` Tcl command operand by
operand, omitting covered `None` operands and using the ttk entry index-word
helper for sequence operands while preserving `stdlib.None` return semantics.
This slice did not add visible README or example code, but the existing
tkinter example and extracted README snippets were revalidated through the
capture harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_icursor_sequence_probe.py` and
`.codex/tkinter_ttk_entry_icursor_sequence_probe.output.json`, a focused red
test failing because `entry.icursor(stdlib.None)` reported `bad entry index
"None"` instead of the local wrong-args TclError, focused green
`TtkEntryIcursorNoneAndSequenceWordsMatchLocal310` passing 1/1 in 1703 ms,
adjacent `TtkEntry` report passing 10/10 in 13234 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1047 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.index(index)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that `index(None)` omits the
required index operand and raises the local wrong-args TclError, empty
list/tuple indexes map to the same integer as `index("end")`, one-item
list/tuple indexes behave like their scalar value, and multi-item indexes such
as `["1", "2"]` raise `bad entry index "1 2"`. The AHK prefixed-internal
`AhkStdlibTkinterEntry` now builds the `index` Tcl command operand by operand,
omitting covered `None` operands and using the ttk entry index-word helper for
sequence operands while preserving scalar integer conversion. This slice did
not add visible README or example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_ttk_entry_index_sequence_probe.py` and
`.codex/tkinter_ttk_entry_index_sequence_probe.output.json`, a focused red test
failing because `entry.index(stdlib.None)` reported `bad entry index "None"`
instead of the local wrong-args TclError, focused green
`TtkEntryIndexNoneAndSequenceWordsMatchLocal310` passing 1/1 in 1735 ms,
adjacent `TtkEntry` report passing 9/9 in 11891 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1672 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.identify(x, y)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that covered `None` operands
are omitted and raise the local wrong-args TclError, empty list/tuple
coordinates become the empty Tcl word and raise `expected integer but got ""`,
one-item list/tuple coordinates behave like scalar integer strings, and
multi-item coordinate sequences such as `["1", "2"]` raise `expected integer
but got "1 2"`. The AHK prefixed-internal `AhkStdlibTkinterEntry` now builds
the `identify` Tcl command operand by operand, omitting covered `None`
operands and using the ttk entry index-word helper for sequence operands while
preserving scalar behavior. This slice did not add visible README or example
code, but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_identify_sequence_probe.py` and
`.codex/tkinter_ttk_entry_identify_sequence_probe.output.json`, a focused red
test failing because `entry.identify(stdlib.None, 1)` reported `expected
integer but got "None"` instead of the local wrong-args TclError, focused green
`TtkEntryIdentifyNoneAndSequenceWordsMatchLocal310` passing 1/1 in 2781 ms,
adjacent `TtkEntry` report passing 8/8 in 10609 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1844 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Entry.bbox(index)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that `bbox(None)` omits the
required index operand and raises the local wrong-args TclError, list/tuple
index operands join into one Tcl index word, empty list/tuple indexes map to
the same result as `bbox("end")`, and multi-item indexes such as `["0", "1"]`
raise `bad entry index "0 1"`. The AHK prefixed-internal
`AhkStdlibTkinterEntry` now builds the `bbox` Tcl command operand by operand,
omitting covered `None` operands and using the ttk entry index-word helper for
sequence operands while preserving scalar tuple conversion. This slice did not
add visible README or example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_ttk_entry_bbox_sequence_probe.py` and
`.codex/tkinter_ttk_entry_bbox_sequence_probe.output.json`, a focused red test
failing because `entry.bbox(stdlib.None)` reported `bad entry index "None"`
instead of the local wrong-args TclError, focused green
`TtkEntryBboxNoneAndSequenceWordsMatchLocal310` passing 1/1 in 1860 ms,
adjacent `TtkEntry` report passing 7/7 in 7547 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 2204 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.Entry.delete(first, last=None)` `None` and list/tuple
sequence handling. A fresh Python 3.10.11 probe confirmed that
`delete(None)` omits the required first index operand and raises the local
wrong-args TclError, list/tuple index operands join into one Tcl index word,
empty list/tuple index words are accepted by Tk, and `last=None` behaves like
the default one-character delete for the covered path. The AHK
prefixed-internal `AhkStdlibTkinterEntry` now builds the `delete` Tcl command
operand by operand, omitting covered `None` operands and using the ttk entry
index-word helper for sequence operands while preserving scalar behavior. This
slice did not add visible README or example code, but the existing tkinter
example and extracted README snippets were revalidated through the capture
harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_delete_sequence_probe.py` and
`.codex/tkinter_ttk_entry_delete_sequence_probe.output.json`, a focused red
test failing because `entry.delete(stdlib.None)` reported `bad entry index
"None"` instead of the local wrong-args TclError, focused green
`TtkEntryDeleteNoneAndSequenceWordsMatchLocal310` passing 1/1 in 1235 ms,
adjacent `TtkEntry` report passing 6/6 in 6047 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1828 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered
themed-widget submodule slice with `ttk.Entry.insert(index, string)` `None` and list/tuple
sequence handling. A fresh Python 3.10.11 probe confirmed that `None` for the
covered `index` or `string` operand is omitted and raises the local wrong-args
TclError, index list/tuple operands join into one index word such as `0 1`,
string list/tuple operands are passed as Tcl list values, and nested string
sequences such as `[["alpha", "delta"]]` insert `{alpha delta}`. The AHK
prefixed-internal `AhkStdlibTkinterEntry` now builds the `insert` Tcl command
operand by operand, using a ttk entry index-word helper for index operands and
a recursive Tcl list-word helper for sequence string values while preserving
scalar behavior. This slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_entry_insert_sequence_probe.py` and
`.codex/tkinter_ttk_entry_insert_sequence_probe.output.json`, a focused red
test failing because `entry.insert(stdlib.None, "X")` reported `bad entry index
"None"` instead of the local wrong-args TclError, focused green
`TtkEntryInsertNoneAndSequenceWordsMatchLocal310` passing 1/1 in 3218 ms,
adjacent `TtkEntry` JSON passing 5/5 in 4046 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1828 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Spinbox.set(value)` `None` and list/tuple sequence
handling. A fresh Python 3.10.11 probe confirmed that `set(None)` omits the Tcl
value operand and raises the local wrong-args TclError, empty list/tuple values
set the widget and linked variable to the empty string, one-item list/tuple
values are passed as one Tcl list value, multi-item sequences such as
`["alpha", "delta"]` set `alpha delta`, and nested sequences such as
`[["alpha", "delta"]]` set `{alpha delta}`. The AHK prefixed-internal
`AhkStdlibTkinterSpinbox` now omits covered `None` operands and routes sequence
values through a Spinbox-specific recursive Tcl list-word helper while
preserving scalar behavior. This slice did not add visible README or example
code, but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_spinbox_set_sequence_probe.py` and
`.codex/tkinter_ttk_spinbox_set_sequence_probe.output.json`, a focused red
test failing because `spin.set(stdlib.None)` did not raise the local wrong-args
TclError, focused green `TtkSpinboxSetNoneAndSequenceWordsMatchLocal310`
passing 1/1 in 1703 ms, adjacent `TtkSpinbox` JSON passing 2/2 in 1937 ms,
explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and
README en/zh examples passing through ahktest capture with pollution assertions
in 1938 ms. No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Panedwindow` inherited `tkinter.PanedWindow` public
methods: `panecget`, `paneconfigure`/`paneconfig`, `proxy*`, and `sash*`.
A fresh Python 3.10.11 probe confirmed that these names exist on
`ttk.Panedwindow` through the CPython MRO, while most calls still fail through
the underlying `ttk::panedwindow` command with local `bad command`, `sashpos`,
or Python helper TypeError/ValueError text. The AHK prefixed-internal
`AhkStdlibTkinterPanedwindow` now exposes those inherited method names, uses
CPython-like `'-' + option` TypeError behavior for non-string pane options,
formats list/tuple child operands as one Tcl word, and preserves the observed
ttk command failures rather than turning these inherited methods into extra
working ttk functionality. This slice did not add visible README or example
code, but the existing tkinter example and extracted README snippets were
revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_panedwindow_inherited_methods_probe.py` and
`.codex/tkinter_ttk_panedwindow_inherited_methods_probe.output.json`, a
focused red test failing because inherited method presence was missing,
focused green `TtkPanedwindowInheritedPanedWindowMethodsMatchLocal310` passing
1/1 in 281 ms, adjacent `TtkPanedwindow` JSON passing 3/3 in 1016 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1953 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Progressbar.start(interval=None)` and
`ttk.Progressbar.step(amount=None)` `None` and list/tuple sequence handling. A
fresh Python 3.10.11 probe confirmed that `start(None)` and `step(None)` both
omit the optional Tcl operand, empty list/tuple values reach Tcl as the empty
word, one-item list/tuple values are accepted as a single interval/amount word,
and multi-item list/tuple values join into one Tcl word such as `5 6` before
Tk reports the local bad-argument or floating-point error. The AHK
prefixed-internal `AhkStdlibTkinterProgressbar` now omits covered `None`
operands, routes `start(...)` interval values through a Progressbar interval
word helper, and routes `step(...)` amounts through the shared ttk float-value
word helper. This slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_progressbar_sequence_probe.py` and
`.codex/tkinter_ttk_progressbar_sequence_probe.output.json`, a focused red
test failing because `progress.start([])` raised host `TypeError` instead of
the local Tk `bad argument ""` TclError, focused green
`TtkProgressbarStartStepNoneAndSequenceWordsMatchLocal310` passing 1/1 in
3906 ms, adjacent `TtkProgressbar` JSON passing 2/2 in 4141 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1953 ms.
No aggregate baseline is raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Scrollbar.delta(deltax, deltay)`,
`ttk.Scrollbar.fraction(x, y)`, and `ttk.Scrollbar.set(first, last)` `None`
and list/tuple sequence handling. A fresh Python 3.10.11 probe confirmed that
`None` in any covered numeric operand is omitted from the Tcl command and
raises the local wrong-args error, empty list/tuple operands reach Tcl as the
empty float word, one-item list/tuple numeric operands are accepted, and
multi-item list/tuple operands join into one float word such as `10 11` or
`0.25 0.5`. The AHK prefixed-internal `AhkStdlibTkinterScrollbar` now builds
these Tcl commands operand by operand and routes covered numeric values through
the shared ttk float-value word helper while preserving scalar behavior. This
slice did not add visible README or example code, but the existing tkinter
example and extracted README snippets were revalidated through the capture
harness. Fresh evidence includes `.codex/tkinter_ttk_scrollbar_sequence_probe.py`
and `.codex/tkinter_ttk_scrollbar_sequence_probe.output.json`, a focused red
test failing because `scrollbar.delta(stdlib.None, 5)` reported
`expected floating-point number but got "None"`, focused green
`TtkScrollbarDeltaFractionSetNoneAndSequenceWords` passing 1/1 in 203 ms,
adjacent `TtkScrollbar` JSON passing 2/2 in 609 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, and README en/zh
examples passing through ahktest capture with pollution assertions in 1875 ms.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Scale.coords(value=None)` plus `ttk.Scale.set(value)`
`None` and list/tuple sequence handling. A fresh Python 3.10.11 probe
confirmed that `coords()` and `coords(None)` both query the slider coordinates,
empty list/tuple values reach Tcl as the empty float word and raise
`expected floating-point number but got ""`, one-item list/tuple numeric values
are accepted, and multi-item list/tuple values join into one float word such
as `5 6`. The same probe confirmed that `set(None)` omits the Tcl value
operand and raises the local wrong-args error, while list/tuple values follow
the same joined float-word behavior. The AHK prefixed-internal
`AhkStdlibTkinterScale` now exposes the public ttk `coords(...)` method and
routes covered `coords(...)` / `set(...)` values through a Scale value-word
helper while preserving scalar behavior. This slice did not add visible README
or example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_scale_coords_sequence_probe.py` and
`.codex/tkinter_ttk_scale_coords_sequence_probe.output.json`, a focused red
test erroring because `ttk.Scale` had no `coords` method, focused green
`TtkScaleCoordsSetNoneAndSequenceWords` passing 1/1 in 140 ms, adjacent
`TtkScale` JSON passing 2/2 in 250 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, and README en/zh examples passing
through ahktest capture with pollution assertions in 1203 ms.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Combobox.current(newindex=None)` and
`ttk.Combobox.set(value)` `None` and list/tuple sequence handling. A fresh
Python 3.10.11 probe confirmed that `current(None)` is the same current-index
query as `current()`, empty list/tuple indexes reach Tcl as the empty index and
raise `Incorrect index `, one-item list/tuple numeric indexes select the
matching row, and multi-item list/tuple indexes join into one index word such
as `1 2`. The same probe confirmed that `set(None)` omits the Tcl value
operand and raises the local wrong-args error, while list/tuple values are
passed as Tcl list values rather than plain joined strings, so `["beta gamma"]`
writes `{beta gamma}` and `["beta", "gamma"]` writes `beta gamma`. The AHK
prefixed-internal `AhkStdlibTkinterCombobox` now routes `current(...)` through
a sequence index-word helper and routes `set(...)` through a Tcl-list value
helper while preserving scalar behavior. This negative edge-behavior slice did
not add visible README or example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
evidence includes `.codex/tkinter_ttk_combobox_current_sequence_probe.py` and
`.codex/tkinter_ttk_combobox_current_sequence_probe.output.json`, a focused red
test erroring because `combo.current(stdlib.None)` reported
`Incorrect index None`, focused green
`TtkComboboxCurrentSetNoneAndSequenceWords` passing 1/1 in 282 ms, adjacent
`TtkCombobox` JSON passing 2/2 in 484 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, and README en/zh examples passing
through ahktest capture with pollution assertions in 1875 ms.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Panedwindow` pane-id `None` and list/tuple
sequence-word parity for `pane(pane, option=None)`, `insert(pos, child)`,
`forget(child)`, and `remove(child)`. A fresh Python 3.10.11 probe confirmed
that `pane(None)`, `pane(None, "weight")`, `insert(None, child)`,
`insert("end", None)`, `forget(None)`, and `remove(None)` omit the covered Tcl
operand and raise the local wrong-args errors; empty list/tuple operands reach
Tcl as the empty pane/slave specification; one-item list/tuple operands address
the matching pane path; and multi-item list/tuple operands are joined into one
Tcl word such as `missing pane`. The AHK prefixed-internal
`AhkStdlibTkinterPanedwindow` now routes covered pane/index/slave operands
through `AhkStdlibTkinterTtkPanedwindowPaneWord`, preserving widget-object to
path conversion for scalar and sequence elements while letting Tk produce the
observed wrong-args text for omitted `None` operands. This negative
edge-behavior slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_panedwindow_paneid_sequence_probe.py` and
`.codex/tkinter_ttk_panedwindow_paneid_sequence_probe.output.json`, a focused
red test failing because `paned.pane(stdlib.None)` reported
`Invalid slave specification None`, focused green
`TtkPanedwindowPaneIdNoneAndSequenceWords` passing 1/1 in 531 ms, adjacent
`TtkPanedwindow` JSON passing 2/2 in 797 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, and README en/zh examples passing
through ahktest capture with pollution assertions in 1828 ms.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Notebook` tab-id `None` and list/tuple sequence-word
parity for `index(tab_id)`, `select(tab_id=None)`, `tab(tab_id, option=None)`,
`hide(tab_id)`, and `forget(tab_id)`. A fresh Python 3.10.11 probe confirmed
that `index(None)`, `tab(None)`, `tab(None, "text")`, `hide(None)`, and
`forget(None)` omit the Tcl tab operand and raise the local wrong-args errors,
while `select(None)` remains the current-tab query. The same probe confirmed
that empty list/tuple tab ids reach Tcl as the empty slave specification,
one-item list/tuple tab ids address the matching page path, multi-item
list/tuple tab ids are joined into one Tcl word such as `missing tab`, and
`tab([page], {text: ...})` returns an empty map while updating the tab. The
AHK prefixed-internal `AhkStdlibTkinterNotebook` now routes covered tab ids
through `AhkStdlibTkinterTtkNotebookTabWord`, preserving widget-object to path
conversion for scalar and sequence elements while letting Tk produce the
observed wrong-args text for omitted `None` operands. This negative
edge-behavior slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_notebook_tabid_sequence_probe.py` and
`.codex/tkinter_ttk_notebook_tabid_sequence_probe.output.json`, a focused red
test failing because `notebook.index(stdlib.None)` reported
`Invalid slave specification None`, focused green
`TtkNotebookTabIdNoneAndSequenceWords` passing 1/1 in 656 ms, adjacent
`TtkNotebook` JSON passing 2/2 in 985 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, and README en/zh examples passing
through ahktest capture with pollution assertions in 1906 ms.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Treeview.bbox(item, column=None)` and
`ttk.Treeview.set(item, column=None, value=None)` column `None` and list/tuple
sequence-word parity. A fresh Python 3.10.11 probe confirmed that
`bbox(item, None)` omits the Tcl column word and returns the same empty bbox
as `bbox(item)`; empty list/tuple columns reach Tcl as the empty column id and
raise `Invalid column index `; and one- or multi-item list/tuple columns are
joined into one column word, so `["name"]` and `["two", "words"]` address the
`name` and `two words` columns across bbox, query, and value-set paths. The
probe also confirmed that `set(item, None, value)` follows CPython's direct
Tcl-call behavior and returns the raw column/value tuple instead of setting a
column or returning the Python dict path. The AHK prefixed-internal
`AhkStdlibTkinterTreeview.bbox(...)` and `.set(...)` now route covered column
operands through the Treeview column-word helper, distinguish the two-argument
and three-argument `None` `set` paths, and preserve existing item-word
handling. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_treeview_bbox_set_column_probe.py` and
`.codex/tkinter_ttk_treeview_bbox_set_column_probe.output.json`, a focused red
test failing because `tree.bbox("first", stdlib.None)` reported
`Invalid column index None`, a second red check failing because
`tree.set("first", stdlib.None, "none-updated")` returned the dict path instead
of `("name", "alpha", "two words", "beta")`, focused green
`TtkTreeviewBboxSetColumnNoneAndSequenceWords` passing 1/1 in 266 ms, adjacent
`TtkTreeview` JSON passing 19/19 in 5219 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, and README en/zh examples passing
through ahktest capture with pollution assertions in 2250 ms. A broader
`-FilterExpr Ttk` run produced a JSON report where the current Treeview slice
passed, but the selection also included an unrelated `TestTkWinfo...` identity
failure, so that run is not used as a passing ttk-subset gate for this slice.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Treeview.identify(component, x, y)` component
`None` and list/tuple sequence-word parity. A fresh Python 3.10.11 probe
confirmed that `identify(None, 5, 5)` reaches Tcl as a missing command word
and raises the local wrong-args error; empty list/tuple components reach Tcl
as the empty command word and raise `bad command ""`; and one- or multi-item
list/tuple components are joined into one command word, so `["element"]`
matches the scalar `element` path while `["element", "extra"]` reaches Tcl as
the invalid command `element extra`. The AHK prefixed-internal
`AhkStdlibTkinterTreeview.identify(...)` now routes covered component values
through a Treeview identify-component helper and uses an explicit wrong-args
path for `None` instead of falling into Tk's legacy two-coordinate
`identify x y` form. This negative edge-behavior slice did not add visible
README or example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_treeview_identify_component_probe.py` and
`.codex/tkinter_ttk_treeview_identify_component_probe.output.json`, a focused
red test failing because `tree.identify(stdlib.None, 5, 5)` reported
`bad command "None"` instead of Tcl wrong-args, focused green
`TtkTreeviewIdentifyComponentNoneAndSequenceWords` passing 1/1 in 297 ms,
adjacent `TtkTreeview` JSON passing 18/18 in 6625 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 2406 ms,
and a `Ttk`-filtered `stdlib/tests/tkinter.test.ahk` gate passing 141/141 in
43797 ms. The `stdlib/tests/tkinter.test.ahk -TimeoutSeconds 70` and default
aggregate `stdlib/tests -TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-identify-component-aggregate-60s.json` attempts timed out
before pass evidence, so neither the tkinter full-file baseline nor the
aggregate baseline is raised by this slice.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Treeview.tag_configure(...)` and
`ttk.Treeview.tag_bind(...)` tag-name `None` and list/tuple sequence-word
parity. A fresh Python 3.10.11 probe confirmed that `tag_configure(None)` and
`tag_bind(None)` omit the Tcl `tagName` word and raise the local wrong-args
errors; empty list/tuple tag names reach Tcl as the empty tag; and one- or
multi-item list/tuple tag names are joined into one Tcl tag word, so
`["odd"]` addresses tag `odd` and `["all", "rows"]` addresses tag
`all rows` across query, option-query, keyword configure, and bind configure
paths. The AHK prefixed-internal `AhkStdlibTkinterTreeview` now routes covered
Treeview tag names through a Treeview tag-word helper and preserves the
same `None` omission path. This negative edge-behavior slice did not add
visible README or example code, but the existing tkinter example and extracted
README snippets were revalidated through the capture harness. Fresh evidence
includes `.codex/tkinter_ttk_treeview_tag_sequence_probe.py` and
`.codex/tkinter_ttk_treeview_tag_sequence_probe.output.json`, a focused red
test failing because `tree.tag_configure(stdlib.None)` did not raise the Tcl
wrong-args error, focused green
`TtkTreeviewTagConfigureBindNoneAndSequenceWords` passing 1/1 in 375 ms,
adjacent `TtkTreeview` JSON passing 17/17 in 4156 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 2344 ms,
and full `stdlib/tests/tkinter.test.ahk` passing 203/203 in 53359 ms. The
default aggregate `stdlib/tests -TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-tag-sequence-aggregate-60s.json` attempt timed out before
producing JSON, so the aggregate baseline is not raised by this slice.

The latest tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Treeview.column(...)` and
`ttk.Treeview.heading(...)` column-id `None` and list/tuple sequence-word
parity. A fresh Python 3.10.11 probe confirmed that `column(None)` and
`heading(None)` omit the Tcl column word and raise the local wrong-args errors;
empty list/tuple column ids reach Tcl as an empty column id and raise
`Invalid column index `; and one- or multi-item list/tuple column ids are joined
into one Tcl column word, so `["name"]` addresses column `name` and
`["two", "words"]` addresses column `two words` across query, option-query,
and keyword configure paths. The AHK prefixed-internal
`AhkStdlibTkinterTreeview.column(...)` and `.heading(...)` now route covered
column ids through a Treeview column-word helper and preserve the same `None`
omission path. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_treeview_column_heading_sequence_probe.py` and
`.codex/tkinter_ttk_treeview_column_heading_sequence_probe.output.json`, a
focused red test failing because `tree.column(stdlib.None)` reported
`Invalid column index None` instead of Tcl wrong-args, focused green
`TtkTreeviewColumnHeadingNoneAndSequenceWords` passing 1/1 in 344 ms, adjacent
`TtkTreeview` JSON passing 16/16 in 3609 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 2047 ms, and full
`stdlib/tests/tkinter.test.ahk` passing 202/202 in 42703 ms. The default
aggregate `stdlib/tests -TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-column-heading-sequence-aggregate-60s.json` attempt timed
out before producing JSON, so the aggregate baseline is not raised by this
slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with `ttk.Treeview` mutation item/parent/id `None` and
list/tuple sequence-word parity for `insert`, `move`, `reattach`, and
`set_children`. A fresh Python 3.10.11 probe confirmed that required
`None` parent/item operands are omitted at the Tcl call boundary and produce
the local wrong-args errors; list and tuple parent/item/id operands are joined
into one Tcl item word, so `["first"]` addresses item `first` and
`["first", "child"]` addresses the single missing item `"first child"`; and
optional `iid=None` on `insert` omits `-id` so Tcl generates an `I...` id. The
AHK prefixed-internal `AhkStdlibTkinterTreeview` now routes covered mutation
parent/item/id operands through the Treeview item-word helper, uses a
Treeview child-list helper for `set_children` newchildren, and preserves
`None` newchildren as the string item id `None` to match CPython. This negative
edge-behavior slice did not add visible README or example code, but the
existing tkinter example and extracted README snippets were revalidated through
the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_treeview_mutation_sequence_probe.py` and
`.codex/tkinter_ttk_treeview_mutation_sequence_probe.output.json`, a focused
red test failing because `tree.insert(stdlib.None, "end", ...)` reported
`Item None not found` instead of Tcl wrong-args, focused green
`TtkTreeviewMutationNoneAndSequenceWords` passing 1/1 in 343 ms, adjacent
`TtkTreeview` JSON passing 15/15 in 3610 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 1937 ms, and full
`stdlib/tests/tkinter.test.ahk` passing 201/201 in 55047 ms. The default
aggregate `stdlib/tests -TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-mutation-sequence-aggregate-60s.json` attempt timed out
before producing JSON, so the aggregate baseline is not raised by this slice.

The preceding tkinter.ttk implementation slice extends the covered themed-widget
submodule slice with remaining `ttk.Treeview` item-argument `None` and
list/tuple sequence-word parity for `bbox`, `index`, `item`, `next`, `parent`,
`prev`, `see`, and `set`. A fresh Python 3.10.11 probe confirmed that
`None` omits the Tcl item word for these methods and raises the local Tcl
wrong-args errors, while list and tuple item names are joined into a single Tcl
item word: empty list/tuple address the root item, `["first"]` addresses item
`first`, and `["first", "child"]` addresses the single missing item
`"first child"`. The AHK prefixed-internal `AhkStdlibTkinterTreeview` now
routes the covered remaining item operands through the Treeview item-word
helper, preserves the method-specific `None` omission path, and returns the
local Python-shaped empty root `item([])` `values`/`tags` fields as empty
strings. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh evidence includes
`.codex/tkinter_ttk_treeview_remaining_item_sequence_probe.py` and
`.codex/tkinter_ttk_treeview_remaining_item_sequence_probe.output.json`, a
focused red test failing because `tree.bbox(stdlib.None)` reported `Item None
not found` instead of Tcl wrong-args, focused green
`TtkTreeviewRemainingItemNoneAndSequenceWords` passing 1/1 in 188 ms, adjacent
`TtkTreeview` JSON passing 14/14 in 1609 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 2156 ms, and full
`stdlib/tests/tkinter.test.ahk` passing 200/200 in 56625 ms. The default
aggregate `stdlib/tests -TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-remaining-item-sequence-aggregate-60s.json` attempt timed
out before producing JSON, so the aggregate baseline is not raised by this
slice.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview` item/tag `None` and list/tuple sequence-word parity
for `exists`, `get_children`, `focus`, and `tag_has`. A fresh Python 3.10.11
probe confirmed that `exists(None)` and `tag_has(None)` omit their Tcl item/tag
word and raise the local Tcl wrong-args errors, while `get_children(None)` and
`focus(None)` keep their query/root behavior; list and tuple item or tag names
are joined into one Tcl word, so `["first"]` addresses item `first`,
`["first", "child"]` addresses the single missing item `"first child"`, and
`["all", "rows"]` addresses the tag `"all rows"`. The AHK
prefixed-internal `AhkStdlibTkinterTreeview.exists(...)`, `.focus(...)`,
`.get_children(...)`, and `.tag_has(...)` now route covered item/tag operands
through a Treeview item-word helper while preserving method-specific `None`
handling. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh promotion evidence includes
`.codex/tkinter_ttk_treeview_item_sequence_probe.py` and
`.codex/tkinter_ttk_treeview_item_sequence_probe.output.json`, a focused red
test failing because `tree.exists(stdlib.None)` returned normally instead of
raising Tcl wrong-args, focused green passing 1/1 in 172 ms, adjacent
`TtkTreeview` JSON passing 13/13 in 3109 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 1687 ms, full
`stdlib/tests/tkinter.test.ahk` passing 199/199 in 42985 ms, and aggregate
`stdlib/tests` passing 1067/1067 with `-TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-treeview-item-tag-sequence-aggregate-60s.json` in 56016 ms with only
the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style` style-name `None` and list/tuple sequence-word parity
across `configure`, `lookup`, `map`, and `layout`. A fresh Python 3.10.11 probe
confirmed that `style=None` is omitted at the `_tkinter` call boundary for
`configure(None)`, `lookup(None, ...)`, `map(None)`, and `layout(None)`, raising
the local Tcl wrong-args errors; list and tuple style names are joined into one
Tcl style-name word; empty list and tuple style names keep CPython's
method-specific results (`configure([])` returns `None`, `map([])` returns `{}`,
`layout([])` raises `Layout  not found`, and `lookup([], ...)` resolves through
the local empty-style/default path). The AHK prefixed-internal
`AhkStdlibTkinterStyle.configure(...)`, `.lookup(...)`, `.map(...)`, and
`.layout(...)` now route style names through a shared style-name word helper,
with `lookup(stdlib.None, ...)` explicitly forcing the same Tcl wrong-args path
as CPython. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_style_name_sequence_probe.py` and
`.codex/tkinter_ttk_style_style_name_sequence_probe.output.json`, a focused red
test failing because `style.configure(stdlib.None)` returned normally instead
of raising Tcl wrong-args, focused green passing 1/1 in 328 ms, adjacent
`TtkStyle` JSON passing 17/17 in 3641 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 1859 ms, full
`stdlib/tests/tkinter.test.ahk` passing 198/198 in 39641 ms, and aggregate
`stdlib/tests` passing 1066/1066 with `-TimeoutSeconds 60 -Quiet -JsonReport
.codex/ttk-style-style-name-sequence-aggregate-60s-final-quiet.json` in
49000 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.element_create(elementname, etype, *args, **kw)`
top-level and `from`-factory `None`/sequence word parity. A fresh Python 3.10.11
probe confirmed that top-level `elementname=None` and `etype=None` are omitted
at the `_tkinter` call boundary and raise the local style-element wrong-args
`TclError`; list and tuple element names are passed as one Tcl list word and
create joined element names; `from` theme/source list and tuple values are
preserved as one Tcl word; `from` theme `None` raises the local
`theme ?element?` wrong-args error; and optional source-element `None` is
omitted so a theme-only clone succeeds. The AHK prefixed-internal
`AhkStdlibTkinterStyle.element_create(...)` now builds top-level element words
with the same `None` truncation semantics, treats list/tuple names as Tcl list
words, keeps factory dispatch keyed to plain string etypes, preserves sequence
words in `from` specs, and no longer treats trailing `stdlib.None` as keyword
options. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_element_create_sequence_probe.py` and
`.codex/tkinter_ttk_style_element_create_sequence_probe.output.json`, a focused
red test failing because `style.element_create(stdlib.None, "from", ...)`
returned normally instead of raising Tcl wrong-args, focused green passing 1/1
in 250 ms, adjacent `TtkStyle` JSON passing 16/16 in 1875 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1703 ms,
full `stdlib/tests/tkinter.test.ahk` passing 197/197 in 24297 ms, aggregate
`stdlib/tests` passing 1065/1065 with `-TimeoutSeconds 40` in 34609 ms, and
follow-up aggregate `stdlib/tests` passing 1065/1065 with `-TimeoutSeconds 70
-Quiet -JsonReport .codex/ttk-style-element-create-sequence-aggregate-70s.json`
in 35938 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.element_options(elementname)` element-name `None` and
sequence parity. A fresh Python 3.10.11 probe confirmed that
`element_options(None)` omits the element argument at the Tcl boundary and
raises the local wrong-args `TclError`, while empty strings, numeric and boolean
values, lists, and tuples all reach Tcl as element names and return empty option
tuples for the covered cases. The AHK prefixed-internal
`AhkStdlibTkinterStyle.element_options(...)` now uses an element-options
name-word helper so `stdlib.None` produces the same Tcl wrong-args path and
list/tuple names are joined into a single Tcl element-name word instead of
raising AHK string-conversion errors. This negative edge-behavior slice did not
add visible README or example code, but the existing tkinter example and
extracted README snippets were revalidated through the capture harness. Fresh
promotion evidence includes
`.codex/tkinter_ttk_style_element_options_sequence_probe.py` and
`.codex/tkinter_ttk_style_element_options_sequence_probe.output.json`, a
focused red test failing because `style.element_options(stdlib.None)` returned
normally instead of raising Tcl wrong-args, focused green passing 1/1 in 250 ms,
adjacent `TtkStyle` JSON passing 15/15 in 1547 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1500 ms,
full `stdlib/tests/tkinter.test.ahk` passing 196/196 in 24313 ms, aggregate
`stdlib/tests` passing 1064/1064 with `-TimeoutSeconds 40` in 33954 ms, and
follow-up aggregate `stdlib/tests` passing 1064/1064 with `-TimeoutSeconds 70
-Quiet -JsonReport .codex/ttk-style-element-options-sequence-aggregate-70s.json`
in 33563 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.lookup(style, option, state=None, default=None)` option
and default sequence parity. A fresh Python 3.10.11 probe confirmed that list
options are formatted by CPython as Python list text and return `""` for the
covered style, while tuple options use the old `%` formatting behavior: empty
tuples raise `TypeError("not enough arguments for format string")`, one-item
tuples query that option, and multi-item tuples raise `TypeError("not all
arguments converted during string formatting")`. The same probe confirmed that
list and tuple defaults round-trip through Tcl as tuple-shaped values, while
`False` and `0` defaults return Python integer `0`. The AHK prefixed-internal
`AhkStdlibTkinterStyle.lookup(...)` now routes option names through a
lookup-specific helper, quotes the full `-option` Tcl word so list repr strings
cannot trigger Tcl command substitution, and converts sequence defaults through
Tcl list argv semantics with tuple-shaped readback. This negative edge-behavior
slice did not add visible README or example code, but the existing tkinter
example and extracted README snippets were revalidated through the capture
harness. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_lookup_option_sequence_probe.py` and
`.codex/tkinter_ttk_style_lookup_option_sequence_probe.output.json`, a focused
red test erroring because `style.lookup(styleName, [])` attempted to convert an
AHK Array to a string, focused green passing 1/1 in 219 ms, adjacent `TtkStyle`
JSON passing 14/14 in 1671 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing, README en/zh examples passing through
ahktest capture with pollution assertions in 1375 ms, full
`stdlib/tests/tkinter.test.ahk` passing 195/195 in 23718 ms, aggregate
`stdlib/tests` passing 1063/1063 with `-TimeoutSeconds 40` in 34032 ms, and
follow-up aggregate `stdlib/tests` passing 1063/1063 with `-TimeoutSeconds 70
-Quiet -JsonReport .codex/ttk-style-lookup-sequence-options-aggregate-70s.json`
in 34359 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.configure(style, query_opt=None)` sequence query-option
parity. A fresh Python 3.10.11 probe confirmed that list query options are
handled by CPython as unhashable dict keys and raise `TypeError("unhashable
type: 'list'")`, while tuple query options follow the old `%` formatting path:
empty tuples raise `TypeError("not enough arguments for format string")`,
one-item tuples query that option and return the scalar value or `""`, and
multi-item tuples raise `TypeError("not all arguments converted during string
formatting")`. The AHK prefixed-internal
`AhkStdlibTkinterStyle.configure(...)` now routes non-dict query options through
a configure-specific helper so list and tuple behavior matches the local
CPython observations without changing the existing map/query or settings
branches. This negative edge-behavior slice did not add visible README or
example code, but the existing tkinter example and extracted README snippets
were revalidated through the capture harness. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_configure_sequence_query_probe.py` and
`.codex/tkinter_ttk_style_configure_sequence_query_probe.output.json`, a
focused red test failing because list query options raised the AHK
`Expected a String but got an Array.` path, focused green passing 1/1 in 235 ms,
adjacent `TtkStyle` JSON passing 13/13 in 1422 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1360 ms,
full `stdlib/tests/tkinter.test.ahk` passing 194/194 in 22937 ms, aggregate
`stdlib/tests` passing 1062/1062 with `-TimeoutSeconds 40` in 33797 ms, and
follow-up aggregate `stdlib/tests` passing 1062/1062 with `-TimeoutSeconds 70
-Quiet -JsonReport .codex/ttk-style-configure-sequence-query-aggregate-70s.json`
in 34047 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_settings(themename, settings)` settings-key parity
for tuple keys and keys containing spaces. A fresh Python 3.10.11 probe
confirmed that CPython interpolates settings dict keys raw into the generated
Tcl script: tuple style keys such as `("suffix", "Treeview")` and plain string
style keys containing spaces both reach Tcl and raise the local wrong-args
`TclError`, while tuple element keys in `"element create"` reach Tcl as the
Python tuple string and raise `TclError("No such element type 'field')")` in the
covered case. The AHK prefixed-internal theme-settings script builder now uses a
settings-key-only formatter so stdlib tuple keys are represented with
Python-like tuple text inside generated Tcl, while ordinary string style and
element names remain raw. This negative edge-behavior slice did not add visible
README or example code, but the existing tkinter example and extracted README
snippets were revalidated through the capture harness. Fresh promotion evidence
includes `.codex/tkinter_ttk_style_theme_settings_key_probe.py` and
`.codex/tkinter_ttk_style_theme_settings_key_probe.output.json`, a focused red
test failing because tuple settings keys raised an AHK `TypeError` before Tcl,
focused green passing 1/1 in 235 ms, adjacent `TtkStyle` JSON passing 12/12 in
1515 ms, explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing,
README en/zh examples passing through ahktest capture with pollution assertions
in 1297 ms, full `stdlib/tests/tkinter.test.ahk` passing 193/193 in 23531 ms,
aggregate `stdlib/tests` passing 1061/1061 with `-TimeoutSeconds 40` in 33953
ms, and follow-up aggregate `stdlib/tests` passing 1061/1061 with
`-TimeoutSeconds 70 -Quiet -JsonReport
.codex/ttk-style-theme-settings-tuple-keys-aggregate-70s.json` in 33093 ms with
only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_create(...)` and `ttk.Style.theme_settings(...)`
sequence theme-name parity. A fresh Python 3.10.11 probe confirmed that
`theme_create([name], [parent])` creates the theme named by tkinter/Tcl list
stringification, that multi-item names such as `[name, "space"]` create and
switch to `"name space"`, that an empty string item creates names ending in
`"{}"`, and that `theme_settings([current_theme], settings)` applies settings
to the current theme. The AHK prefixed-internal
`AhkStdlibTkinterStyle.theme_create(...)` and `theme_settings(...)` now reuse
the same style theme-name word conversion used by `theme_use(...)` for theme and
parent arguments, leaving settings script generation unchanged.
`stdlib/examples/tkinter.ahk` and the language-specific README tkinter examples
now exercise sequence `theme_create(...)` and sequence `theme_settings(...)`
without changing the visible demo window. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_theme_create_sequence_probe.py`, a focused red test
failing because `theme_create([name], [parent])` attempted to stringify an AHK
Array, focused green passing 1/1 in 219 ms, adjacent `TtkStyle` JSON passing
11/11 in 1359 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing after example sync, README en/zh examples
passing through ahktest capture with pollution assertions in 1.437 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 192/192 in 22.953 seconds, aggregate
`stdlib/tests` passing 1060/1060 with `-TimeoutSeconds 40` in 32171 ms, and
follow-up aggregate `stdlib/tests` passing 1060/1060 with `-TimeoutSeconds 70
-Quiet -JsonReport .codex/ttk-style-theme-create-sequence-aggregate-70s.json`
in 32625 ms with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_use(themename=None)` sequence theme-name parity. A
fresh Python 3.10.11 probe confirmed that omitted and explicit `None` query the
current theme, while `""`, `0`, `False`, `True`, empty lists, and empty tuples
are passed as theme names and raise the local Tcl missing-theme errors. The same
probe confirmed that one-item list/tuple theme names such as `[base_theme]`
switch themes successfully, multi-item lists/tuples join to Tcl theme names like
`"missing theme"`, and list items containing spaces are preserved as Tcl-list
words such as `"{missing theme}"`. The AHK prefixed-internal
`AhkStdlibTkinterStyle.theme_use(...)` now preserves query behavior only for
omitted/`None` and routes list/tuple theme names through a Tcl `[list ...]`
argument word so Python-observed sequence stringification reaches
`ttk::setTheme`. `stdlib/examples/tkinter.ahk` and the language-specific README
tkinter examples now exercise `style.theme_use([themeName])` alongside the
existing scalar theme switch without changing the visible demo window. Fresh
promotion evidence includes `.codex/tkinter_ttk_style_theme_use_probe.py`,
focused red reports showing list/tuple theme names previously errored during
AHK stringification or lost Tcl-list braces, focused green passing 1/1 in
281 ms, adjacent `TtkStyle` JSON passing 10/10 in 1078 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after example sync,
README en/zh examples passing through ahktest capture with pollution assertions
in 1.344 seconds, full `stdlib/tests/tkinter.test.ahk` passing 191/191 in
23.234 seconds, aggregate `stdlib/tests` passing 1059/1059 with
`-TimeoutSeconds 40` in 32625 ms, and follow-up aggregate `stdlib/tests` passing
1059/1059 with `-TimeoutSeconds 70 -Quiet -JsonReport
.codex/ttk-style-theme-use-aggregate-70s.json` in 33657 ms with only the known
`plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.map(style, query_opt=None)` explicit-`None`, scalar query,
and list/tuple query-option parity. A fresh Python 3.10.11 probe confirmed that
local `style.map(style_name, None)` returns the same map dict as an omitted
query option, that string, integer, boolean, and list query options are treated
as option lookups returning a state map list, that empty and single-item lists
return `[]` for the probed style, that a single-item tuple such as
`("foreground",)` is unpacked as the option name, and that empty or multi-item
tuples preserve CPython's old `%`-formatting `TypeError` messages. The AHK
prefixed-internal `AhkStdlibTkinterStyle.map(...)` now routes query options
through a map-scoped helper so arrays, stdlib tuples, booleans, and scalar values
follow the Python-observed query semantics while the existing Map/object
settings branch remains unchanged. `stdlib/examples/tkinter.ahk` and the
language-specific README tkinter examples now exercise `style.map(...,
stdlib.None)` and `style.map(..., [])` alongside the existing map-setting demo
without changing the visible demo window. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_map_option_none_bool_probe.py`, a focused red test
failing because `style.map(styleName, [])` attempted to stringify an Array
instead of returning Python's empty state map list, focused green passing 1/1 in
234 ms, the adjacent `TtkStyle` filter passing 9/9 in 921 ms, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after example sync,
README en/zh examples passing through ahktest capture with pollution assertions
in 1.406 seconds, full `stdlib/tests/tkinter.test.ahk` passing 190/190 in
21.922 seconds, aggregate `stdlib/tests` passing 1058/1058 with
`-TimeoutSeconds 40` in 32110 ms, and follow-up aggregate `stdlib/tests` passing
1058/1058 with `-TimeoutSeconds 70 -Quiet -JsonReport
.codex/ttk-style-map-scalar-query-aggregate-70s.json` in 32563 ms with only the
known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.configure(style, query_opt=None)` scalar falsy query
option parity. A fresh Python 3.10.11 probe confirmed that local
`style.configure(style_name, None)` returns the same config dict as an omitted
query option, that `""`, `0`, and `False` return Python `None`, that `True`
returns `""`, and that missing styles queried with `None`, `""`, `0`, or
`False` return Python `None`. The same probe also recorded the adjacent
`Style.map(...)` and `Style.lookup(...)` scalar behaviors so this configure fix
stays scoped rather than generalizing falsy iterables or unrelated query APIs.
The AHK prefixed-internal `AhkStdlibTkinterStyle.configure(...)` now treats
scalar falsy non-`None` query options as Python's `None` result while leaving
`stdlib.True` on the observed option-name lookup path. `stdlib/examples/tkinter.ahk`
and the language-specific README tkinter examples now exercise
`style.configure(..., "")` alongside the existing explicit-`None` query without
changing the visible demo window. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_option_none_bool_probe.py`, a focused red test failing
because `style.configure(styleName, "")` returned `""` instead of
`stdlib.None`, focused green passing 1/1 in 234 ms, the adjacent `TtkStyle`
filter passing 8/8 in 812 ms, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing after example sync, README en/zh examples
passing through ahktest capture with pollution assertions in 1.157 seconds,
full `stdlib/tests/tkinter.test.ahk` passing 189/189 in 30.938 seconds,
aggregate `stdlib/tests` passing 1057/1057 with `-TimeoutSeconds 70 -Quiet`
plus JSON artifact in 40.750 seconds with only the known `plain fallback`
stderr line, and renewed aggregate 40-second evidence after the threshold
timeout: one plain `-TimeoutSeconds 40` run passing 1057/1057 in 32141 ms plus
two quiet JSON 40-second reruns passing 1057/1057 with JSON durations of
32281 ms and 32218 ms. The earlier same-slice 40062 ms timeout remains recorded
as evidence that this aggregate gate is threshold-sensitive rather than a
reason to claim long-term 40-second stability from one run.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.column/heading/item(..., option=None, **kw)` explicit
`None` and boolean option-name parity. A fresh Python 3.10.11 probe confirmed
that local `Treeview.column`, `Treeview.heading`, and `Treeview.item` have
signatures `(column, option=None, **kw)` / `(item, option=None, **kw)`, treat an
explicit `None` option exactly like an omitted option by returning the metadata
dict, return individual option values for string option names, return an empty
dict for keyword updates, and treat `""`, `0`, `False`, and `True` as explicit
option names that raise Tcl errors for `"-"`, `"-0"`, `"-False"`, and
`"-True"`. The AHK prefixed-internal `AhkStdlibTkinterTreeview` now uses a
Treeview-scoped option-name helper for the `column(...)`, `heading(...)`, and
`item(...)` lookup paths so stdlib booleans become `True` / `False` only in
those Python-observed option-name contexts, while existing value conversion for
Treeview options such as `open`, `stretch`, and `values` remains unchanged.
`stdlib/examples/tkinter.ahk` and the language-specific README tkinter examples
now exercise `tree.heading(..., stdlib.None)`, `tree.column(..., stdlib.None)`,
and `tree.item(..., stdlib.None)` without changing the visible demo window.
Fresh promotion evidence includes
`.codex/tkinter_ttk_treeview_option_none_bool_probe.py`, a focused red test
failing because `tree.heading("name", stdlib.False)` produced Tcl option
`-0` instead of Python's `-False`, focused green passing 1/1 in 187 ms, the
adjacent `TtkTreeview` filter passing 12/12 in 1.344 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 189/189 in 21.015 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after example
sync, and README en/zh examples passing through ahktest capture with pollution
assertions in 1.203 seconds after README sync. Aggregate `stdlib/tests` passed
1057/1057 with `-TimeoutSeconds 40` in 31.297 seconds with only the known
`plain fallback` stderr line, and a follow-up `stdlib/tests` aggregate with
`-TimeoutSeconds 70 -Quiet` exited 0 with only the same known stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Notebook.tab(tab_id, option=None, **kw)` explicit-None and
boolean option-name parity. A fresh Python 3.10.11 probe confirmed the local
signature `(tab_id, option=None, **kw)`, that `notebook.tab(page)` and
`notebook.tab(page, None)` return the same tab metadata dict, that
`notebook.tab(page, "text")` returns the option value, that `""`, `0`, `False`,
and `True` are treated as explicit option names and raise Tcl errors for
`"-"`, `"-0"`, `"-False"`, and `"-True"`, and that keyword tab updates return
an empty dict before changing the stored tab metadata. The AHK prefixed-internal
`AhkStdlibTkinterNotebook` now treats `stdlib.None` as the tab-info query
sentinel and keeps Notebook tab option-name conversion scoped so stdlib
booleans become `True` / `False` only for the observed `tab(..., option)`
lookup path. `stdlib/examples/tkinter.ahk` and the language-specific README
tkinter examples now exercise a live `ttk.Notebook` and the explicit
`notebook.tab(page, stdlib.None)` query path without immediately destroying the
displayed window. Fresh promotion evidence includes
`.codex/tkinter_ttk_notebook_tab_explicit_none_probe.py`, a focused red test
failing because explicit `stdlib.None` was forwarded as Tcl option
`-__AhkStdlibNone`, focused green passing 1/1 in 187 ms, the adjacent
`TtkPublicAliases` filter passing 1/1 in 203 ms, full
`stdlib/tests/tkinter.test.ahk` passing 189/189 in 21.438 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.235 seconds after README sync, aggregate `stdlib/tests`
passing 1057/1057 with `-TimeoutSeconds 40` in 32.422 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` exiting 0 with
only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Panedwindow.remove(child)` alias parity. A fresh Python 3.10.11
probe confirmed that local `ttk.Panedwindow.remove` exists, is the same class
function object as `ttk.Panedwindow.forget`, has signature `(child)`, returns
`None`, removes the child from the managed panes while leaving the child widget
alive with an empty manager, and preserves the `PanedWindow.remove(...)` arity
messages plus Tcl's invalid-slave error. The AHK prefixed-internal
`AhkStdlibTkinterPanedwindow` now exposes `remove(args*)` as a direct delegate
to `forget(args*)`, preserving the existing Tcl call path and Python-observed
error text. `stdlib/examples/tkinter.ahk` and the language-specific README
tkinter examples now add and remove a temporary scratch pane through
`paned.remove(...)` while keeping the visible demo panes alive. Fresh promotion
evidence includes `.codex/tkinter_ttk_panedwindow_remove_alias_probe.py`, a
focused red test failing because `HasMethod(paned, "remove")` was false,
focused green passing 1/1 in 219 ms, the adjacent `TtkPublicAliases` filter
passing 1/1 in 157 ms, full `stdlib/tests/tkinter.test.ahk` passing 189/189
in 22.063 seconds, explicit `run-ahk-validate -Path
stdlib/examples/tkinter.ahk` passing after example sync, README en/zh examples
passing through ahktest capture with pollution assertions in 1.281 seconds
after README sync, aggregate `stdlib/tests` passing 1057/1057 with
`-TimeoutSeconds 40` in 30.359 seconds, and a follow-up aggregate
`stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` exiting 0 with only the
known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.layout(style, layoutspec=None)` falsy/None layoutspec
parity. A fresh Python 3.10.11 probe confirmed that local
`style.layout("Treeview", None)` is a query path identical to omitting the
second argument, missing styles still raise `TclError`, falsy layout specs
`[]`, `()`, `""`, `0`, and `False` return `[]` while installing a queryable
`[("null", {"sticky": "nswe"})]` layout, and truthy invalid specs preserve
CPython's `TypeError` / `ValueError` distinctions. The AHK `Style.layout(...)`
implementation now treats `stdlib.None` as a query sentinel, emits the Tcl
`null -sticky nswe` layout for falsy non-None specs, and keeps malformed
top-level strings and entries on the Python-observed unpacking error paths.
`stdlib/examples/tkinter.ahk` and the language-specific README tkinter examples
now record both the `layout("Treeview", stdlib.None)` query branch and an empty
scratch layout. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_layout_falsy_probe.py`, a focused red test failing
because `layout(emptyListStyle, [])` did not create a queryable null layout,
focused green rerun passing 1/1 in 172 ms, `TtkStyle` filter passing 8/8 in
688 ms, full `stdlib/tests/tkinter.test.ahk` passing 189/189 in 20.578
seconds, explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing
after example sync, README en/zh examples passing through ahktest capture with
pollution assertions in 1.125 seconds after README sync, aggregate
`stdlib/tests` passing 1057/1057 with `-TimeoutSeconds 40` in 31.282 seconds,
and a follow-up aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet`
exiting 0 with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Widget.instate(statespec, callback=None, *args)` callback-None
parity. A fresh Python 3.10.11 probe confirmed that local
`Widget.instate(...)` returns the boolean state match when `callback` is
`None`, still ignores callback arguments in that branch, skips callbacks when
the state does not match, and still invokes falsey callable objects. The AHK
shared widget implementation now treats `stdlib.None` as the no-callback
sentinel before attempting `callback.Call(...)`; other non-callable AHK values
continue to surface native AHK call errors. `stdlib/examples/tkinter.ahk` and
the language-specific README tkinter examples now record the `instate(...,
stdlib.None, ...)` no-callback branch, and the host-class-collision regression
test now avoids redeclaring AHK's built-in `Menu` while still validating
`Menu` plus additional ttk/classic public names against prefixed internal
classes. Fresh promotion evidence includes
`.codex/tkinter_ttk_widget_instate_callback_none_probe.py`, a focused red test
failing because `stdlib.None` was invoked as a callback, focused green passing
1/1 in 156 ms, `TtkButton` filter passing 2/2 in 297 ms, the repaired
host-class-collision focused test passing 1/1 in 250 ms, full
`stdlib/tests/tkinter.test.ahk` passing 188/188 in 20.562 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.062 seconds after README sync, aggregate `stdlib/tests`
passing 1056/1056 with `-TimeoutSeconds 40` in 30.297 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_settings(themename, settings)` element-create
settings parity. A fresh Python 3.10.11 probe confirmed that local
`theme_settings(...)` accepts the same `"element create"` setting syntax as
`theme_create(...)`, creates elements through `("from", theme, element)` and
`("from", theme)`, skips an empty element-create setting, leaves the active
theme unchanged, and preserves CPython errors for missing element-create tuple
entries, invalid style settings entries, and missing themes. The AHK settings
script builder now emits `ttk::style element create ...` statements for
truthy `"element create"` entries while reusing the existing element-create
formatter. `stdlib/examples/tkinter.ahk` and the language-specific README
tkinter examples record an element created through `theme_settings(...)`.
Fresh promotion evidence includes
`.codex/tkinter_ttk_style_theme_settings_element_create_probe.py`, a focused
red test failing because the element was not created by `theme_settings(...)`,
focused green passing 1/1 in 141 ms, `TtkStyle` filter passing 7/7 in 610 ms,
full `stdlib/tests/tkinter.test.ahk` passing 187/187 in 20.172 seconds,
explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after
the example sync, README en/zh examples passing through ahktest capture with
pollution assertions in 1.031 seconds, aggregate `stdlib/tests` passing
1055/1055 with `-TimeoutSeconds 40` in 30.500 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.OptionMenu.set_menu(...)` menu-entry kind parity. A fresh
Python 3.10.11 probe confirmed that local `ttk.OptionMenu(...)` and
`set_menu(default, *values)` populate the attached classic `Menu` with
`radiobutton` entries, each carrying the associated Tcl variable name and
per-entry `value`, and that invoking an entry updates the variable before the
public callback runs. The AHK surface now uses `Menu.add_radiobutton(...)` in
the internal `AhkStdlibTkinterTtkOptionMenuPopulate(...)` helper while
preserving the existing `_setit` callback wrapper. `stdlib/examples/tkinter.ahk`
records the entry type, variable, and value metadata before and after
`set_menu(...)` rebuilds. Fresh promotion evidence includes
`.codex/tkinter_ttk_optionmenu_radiobutton_entries_probe.py`, a focused red
test failing because the attached menu returned `command` instead of
`radiobutton`, focused green passing 1/1 in 187 ms, `TtkOptionMenu` filter
passing 3/3 in 343 ms, full `stdlib/tests/tkinter.test.ahk` passing 186/186 in
20.188 seconds, explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk`
passing after the example sync, README en/zh examples passing through ahktest
capture with pollution assertions in 1.188 seconds, aggregate `stdlib/tests`
passing 1054/1054 with `-TimeoutSeconds 40` in 30.390 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.OptionMenu` constructor and `set_menu(default=None, *values)`
default truthiness parity. A fresh Python 3.10.11 probe confirmed that local
`ttk.OptionMenu(...)` and `set_menu(...)` rebuild menu entries while
leaving the associated variable unchanged when `default` is omitted, `None`,
`""`, `0`, or `False`, and set the variable only for truthy defaults such as
`"default"`. The AHK surface now uses Python-style `AhkStdlibTruthValue(...)`
for both the public `stdlib.tkinter.ttk.OptionMenu(...)` constructor default
and `set_menu(...)` default branches. `stdlib/examples/tkinter.ahk` records an
empty-string `set_menu` rebuild that preserves the invoked variable value
before resetting the demo menu, and the language-specific README tkinter
examples call `choiceMenu.set_menu("", "draft", "review")` before restoring the
live menu with a truthy `"one"` default. Fresh promotion evidence includes
`.codex/tkinter_ttk_optionmenu_default_truthiness_probe.py`, a focused red test
failing because `default=""` changed the variable to an empty string, focused
green passing 1/1 in 203 ms, `TtkOptionMenu` filter passing 2/2 in 297 ms, full
`stdlib/tests/tkinter.test.ahk` passing 185/185 in 20.250 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.125 seconds after the README sync, aggregate `stdlib/tests`
passing 1053/1053 with `-TimeoutSeconds 40` in 30.016 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.lookup(style, option, state=None, default=None)` falsy
`state` parity. A fresh Python 3.10.11 probe confirmed that local
`Style.lookup(...)` treats `state=None`, empty list/tuple/string, `0`, and
`False` as an empty state, returning the fallback for a missing option and the
configured static value for a mapped option, while truthy non-iterable
`state=1` still raises `TypeError: can only join an iterable`. The AHK surface
now uses Python-style `AhkStdlibTruthValue(...)` before joining the public
`stdlib.tkinter.ttk.Style(...).lookup(...)` state argument, preserving the
existing `stdlib.None` default conversion. `stdlib/examples/tkinter.ahk`
records `lookup("Example.Treeview", "foreground", 0, "fallback")`, and the
language-specific README tkinter examples query
`style.lookup("Demo.Treeview", "foreground", 0, "navy")` without changing the
live window. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_lookup_state_truthiness_probe.py`, a focused red test
failing with `can only join an iterable`, focused green passing 1/1 in 156 ms,
`TtkStyle` filter passing 6/6 in 547 ms, full
`stdlib/tests/tkinter.test.ahk` passing 184/184 in 19.891 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.063 seconds after the README sync, aggregate `stdlib/tests`
passing 1052/1052 with `-TimeoutSeconds 40` in 29.672 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_create(themename, parent=None, settings=None)`
truthiness parity for `parent` and `settings`. A fresh Python 3.10.11 probe
confirmed that local `Style.theme_create(...)` returns Python `None`, creates
the requested theme, and leaves the current theme unchanged when `parent` is
omitted, `None`, `""`, `0`, or `False`, and when `settings` is `None`, an empty
dict, `""`, `0`, or `False`. The AHK surface now uses Python-style
`AhkStdlibTruthValue(...)` guards for the public
`stdlib.tkinter.ttk.Style(...).theme_create(...)` parent/settings branches, so
falsy parents do not emit `-parent` and falsy settings do not call the settings
script builder. `stdlib/examples/tkinter.ahk` records a scratch theme created
with an empty-string parent, and the language-specific README tkinter examples
create a scratch theme the same way before switching the live demo theme. Fresh
promotion evidence includes
`.codex/tkinter_ttk_style_theme_create_truthiness_probe.py`, a focused red test
failing with `theme "" doesn't exist`, focused green passing 1/1 in 172 ms,
`TtkStyle` filter passing 5/5 in 484 ms, full
`stdlib/tests/tkinter.test.ahk` passing 183/183 in 20.000 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.078 seconds after the README sync, aggregate `stdlib/tests`
passing 1051/1051 with `-TimeoutSeconds 40` in 29.906 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.configure(style, query_opt=None)` explicit-`None`
query parity. A fresh Python 3.10.11 probe confirmed that local
`Style.configure(style_name, None)` returns the same dict as an omitted
`query_opt`, that option queries such as `"background"` still return scalar
values, and that a missing style queried with explicit `None` returns Python
`None`. The AHK surface now treats `stdlib.None` as the explicit query sentinel
for `stdlib.tkinter.ttk.Style(...).configure(...)`, returning the style config
Map when options exist and `stdlib.None` when the explicit-None query yields no
settings. `stdlib/examples/tkinter.ahk` records
`style.configure("Example.Treeview", stdlib.None)`, and the language-specific
README tkinter examples query `style.configure("Demo.Treeview", stdlib.None)`
without changing the live window. Fresh promotion evidence includes
`.codex/tkinter_ttk_style_explicit_none_probe.py`, a focused red test failing
because explicit `stdlib.None` did not return a Map, focused green passing 1/1
in 172 ms, `TtkStyle` filter passing 4/4 in 375 ms, full
`stdlib/tests/tkinter.test.ahk` passing 182/182 in 19.875 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, and README en/zh examples passing through ahktest capture with pollution
assertions in 1.078 seconds after the README sync. The fresh aggregate
promotion gate `run-ahktest stdlib/tests -TimeoutSeconds 40` passed 1050/1050
in 29.953 seconds with only the known `plain fallback` stderr line; the
follow-up `run-ahktest stdlib/tests -TimeoutSeconds 70 -Quiet` aggregate also
completed successfully with only the same known stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.delete(*items)` and `ttk.Treeview.detach(*items)`
sequence-operand parity. A fresh Python 3.10.11 probe confirmed that local
`Treeview.delete()` and `Treeview.detach()` return `None` with zero positional
items, that multiple positional item ids are deleted as a Tcl list operand, and
that a single Python list/tuple argument is not flattened for these commands:
`delete([first, second])` raises `Item first second not found`, `delete([])`
raises `Cannot delete root item`, `detach((third, fourth))` raises
`Item third fourth not found`, and `detach(())` raises `Cannot detach root
item`. The AHK helper now builds the same list-of-items operand for
`delete`/`detach`, including one nested enumerable item converted to a Tcl list
string, while leaving the earlier `selection_*` single-sequence flattening
helper separate. `stdlib/examples/tkinter.ahk` records safe captured
single-sequence error messages and then exercises successful multi-positional
delete, while the language-specific README tkinter examples keep a live
Treeview demo with temporary scratch rows removed through `tree.delete(a, b)`.
Fresh promotion evidence includes
`.codex/tkinter_ttk_treeview_delete_detach_sequences_probe.py`, a focused red
test failing because `delete([first, second])` raised host `TypeError` instead
of TclError, focused green passing 1/1 in 172 ms, `TtkTreeview` filter passing
12/12 in 1.360 seconds, full `stdlib/tests/tkinter.test.ahk` passing 181/181 in
19.813 seconds, explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk`
passing after the example sync, and README en/zh examples passing through
ahktest capture with pollution assertions in 1.047 seconds after the README
sync. The fresh aggregate promotion gate
`run-ahktest stdlib/tests -TimeoutSeconds 40` passed 1049/1049 in 29.500
seconds with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.selection_set(*items)`,
`selection_add(*items)`, `selection_remove(*items)`, and
`selection_toggle(*items)` single-sequence parity. A fresh Python 3.10.11 probe
confirmed that local `Treeview._selection(...)` flattens one list/tuple
argument before calling Tcl, that zero-argument `selection_set()` returns
`None` and clears the selection, that list/tuple operands work for set/remove
and toggle, that varargs work for add, that an empty list is a no-op, and that
missing items still raise `Item missing not found`. The AHK helper now mirrors
that single-sequence flattening and always passes a Tcl list for the `items`
operand, so public `stdlib.tkinter.ttk.Treeview(...).selection_*` calls match
the CPython varargs shape while preserving the existing tuple-returning
`selection()` query. `stdlib/examples/tkinter.ahk` records list-based
`selection_toggle` and restore behavior, and the language-specific README
tkinter examples use list-based `selection_set`/`selection_toggle` on the live
Treeview. Fresh promotion evidence includes
`.codex/tkinter_ttk_treeview_selection_ops_probe.py`, a focused red test
failing because zero-argument `selection_set()` generated the wrong Tcl arity,
focused green passing 1/1 in 172 ms, `TtkTreeview` filter passing 11/11 in
1.704 seconds, full `stdlib/tests/tkinter.test.ahk` passing 180/180 in
19.375 seconds, explicit `run-ahk-validate -Path stdlib/examples/tkinter.ahk`
passing after the example sync, README en/zh examples passing through ahktest
capture with pollution assertions in 1.265 seconds after the README sync,
aggregate `stdlib/tests` passing 1048/1048 with `-TimeoutSeconds 40` in
29.703 seconds, and a follow-up aggregate `stdlib/tests` run with
`-TimeoutSeconds 70 -Quiet` completing successfully with only the known
`plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Entry.validate()`. A fresh Python 3.10.11 probe confirmed that
local `Entry.validate` has signature `(self)`, calls the underlying ttk entry
`validate` subcommand, returns Python booleans through `tk.getboolean`, returns
`True` with no validatecommand, calls validatecommand callbacks when validation
is enabled, sets the `invalid` state when the callback returns false, preserves
that invalid state on repeated failing validation, accepts string truth values
such as `"1"`, and raises `Entry.validate() takes 1 positional argument but 2
were given` for extra positional arguments. The AHK surface now implements this
on the prefixed-internal ttk Entry class by calling the Tcl `validate` command
and converting the result through the existing Tk boolean conversion path.
`stdlib/examples/tkinter.ahk` records a default `entry.validate()` result, and
the language-specific README tkinter examples call `entry.validate()` on the
live demo Entry without destroying the window. Fresh promotion evidence includes
`.codex/tkinter_ttk_entry_validate_probe.py`, a focused red test failing because
`Entry` had no `validate` method, focused green passing 1/1 in 156 ms,
`TtkEntry` filter passing 4/4 in 578 ms, full `stdlib/tests/tkinter.test.ahk`
passing 179/179 in 19.125 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.359 seconds after the README sync, aggregate `stdlib/tests`
passing 1047/1047 with `-TimeoutSeconds 40` in 29.640 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.element_create(elementname, etype, *args, **kw)`. A fresh
Python 3.10.11 probe confirmed that local `Style.element_create` has signature
`(self, elementname, etype, *args, **kw)`, returns `None`, creates new elements
in the current theme, supports cross-platform `from` element cloning from the
current theme, accepts `image` element creation with state/image pairs and
keyword options, ignores extra positional arguments after the optional source
element for `etype="from"`, and exposes created elements through
`element_names()` with empty `element_options(...)` tuples for the probed
elements. The same probe confirmed CPython helper-level errors:
missing `elementname`/`etype` raises the normal `Style.element_create()`
TypeErrors, missing tuple entries for `from` and `image` raise `IndexError:
tuple index out of range`, duplicate names raise `TclError: Duplicate element
<name>`, missing source themes raise `theme "missing-theme" doesn't exist`, and
unknown factories raise `No such element type unknown`. The AHK surface now
implements this on the prefixed-internal `AhkStdlibTkinterStyle` class with
small element-create formatting helpers for `from`, `image`, and `vsapi`, while
keeping the public surface at `stdlib.tkinter.ttk.Style(...).element_create(...)`.
`stdlib/examples/tkinter.ahk` records a unique cloned element and confirms it
appears in `element_names()`, and the language-specific README tkinter examples
create a unique clone before building the demo theme. Fresh promotion evidence
includes `.codex/tkinter_ttk_style_element_create_probe.py`, a focused red test
failing because `Style` had no `element_create` method, focused green passing
1/1 in 156 ms, `TtkStyle` filter passing 3/3 in 406 ms, full
`stdlib/tests/tkinter.test.ahk` passing 178/178 in 19.609 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 1.078 seconds after the README sync, aggregate `stdlib/tests`
passing 1046/1046 with `-TimeoutSeconds 40` in 29.813 seconds, and a follow-up
aggregate `stdlib/tests` run with `-TimeoutSeconds 70 -Quiet` completing
successfully with only the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style.theme_create(themename, parent=None, settings=None)`. A
fresh Python 3.10.11 probe confirmed that local `Style.theme_create` has
signature `(self, themename, parent=None, settings=None)`, returns `None`,
does not switch away from the current theme after creation, omits `-parent`
when `parent` is `None`, accepts the same settings shape as `theme_settings`,
raises `TclError` messages such as `Theme <name> already exists` and
`theme "missing-parent-theme" doesn't exist`, and raises Python-style
`AttributeError` text for invalid settings objects without `.items()` or
setting entries without `.get()`. The AHK surface now implements the method on
the prefixed-internal `AhkStdlibTkinterStyle` class using the existing ttk style
settings script builder, while tightening that helper so the public
`stdlib.tkinter.ttk.Style(...).theme_create(...)` error text matches the local
Python 3.10.11 probe. `stdlib/examples/tkinter.ahk` records theme creation,
the unchanged current theme after creation, explicit theme switching, created
style lookup, and restoration to the previous theme. The language-specific
README tkinter examples create a unique demo theme before switching to it, so
the live example exercises `theme_create` without failing on repeated runs.
Fresh promotion evidence includes `.codex/tkinter_ttk_style_theme_create_probe.py`,
a focused red test failing because `Style` had no `theme_create` method,
focused green passing 1/1 in 265 ms, `TtkStyle` filter passing 2/2 in
266 ms, `Ttk` filter passing 114/114 in 13.360 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 177/177 in 28.172 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing after the example
sync, README en/zh examples passing through ahktest capture with pollution
assertions in 2.407 seconds after the README sync, aggregate `stdlib/tests`
passing 1045/1045 with `-TimeoutSeconds 40 -Quiet` in 37.734 seconds, and
aggregate `stdlib/tests` passing 1045/1045 with `-TimeoutSeconds 70 -Quiet` in
37.343 seconds and the known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.reattach(item, parent, index)`. A fresh Python 3.10.11
probe confirmed that local `Treeview.reattach` exists, has signature
`(self, item, parent, index)`, is the same function object as `Treeview.move`
with `__name == "move"`, returns `None`, reattaches detached items to the root
or a parent at the requested index, and reports missing/extra positional
TypeErrors using `Treeview.move()` in the message. The AHK surface now preserves
that alias shape as a prefixed-internal Treeview method delegating to `move`,
so the public `stdlib.tkinter.ttk.Treeview(...).reattach(...)` method keeps the
same behavior and error text as the already-covered `move(...)` implementation.
`stdlib/examples/tkinter.ahk` records a reattach after detach, and the
language-specific README tkinter examples now reattach the detached "last" row
before restoring the visible Treeview children. Fresh promotion evidence
includes `.codex/tkinter_ttk_treeview_reattach_probe.py`, a focused red test
failing because `Treeview` had no `reattach` method, focused green passing 1/1
in 141 ms, `TtkTreeview` filter passing 10/10 in 1.219 seconds, `Ttk` filter
passing 113/113 in 13.406 seconds, full `stdlib/tests/tkinter.test.ahk`
passing 176/176 in 27.579 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1.094
seconds, aggregate `stdlib/tests` passing 1044/1044 with `-TimeoutSeconds 40
-Quiet` in 38.047 seconds, and aggregate `stdlib/tests` passing 1044/1044 with
`-TimeoutSeconds 70 -Quiet` in 37.531 seconds and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.tag_bind(tagname, sequence=None, callback=None)`. A
fresh Python 3.10.11 probe confirmed that local `Treeview.tag_bind` has
signature `(self, tagname, sequence=None, callback=None)`, returns `None` for
sequence queries, per-sequence script queries, string-script binding, callable
binding, `callback=None`, and missing-tag binding because the public method does
not return the internal `_bind(...)` result. The same probe confirmed that the
underlying Tcl tag binding state is still updated, that callable bindings route
real generated button events to tagged rows with `Event.type.name == "ButtonPress"`,
that no public `Treeview.tag_unbind` exists, and that missing/extra positional
TypeErrors match local Python. The AHK surface implements this as a
prefixed-internal Treeview method that delegates to Tcl `tag bind`, uses the
existing event bridge for callbacks, discards Tcl query/callable return values
to preserve Python's public `None` behavior, and intentionally leaves
`tag_unbind` absent. `stdlib/examples/tkinter.ahk` now records public
`tag_bind` setup, and the language-specific README tkinter examples bind the
dynamic Treeview tag to a status callback while still showing a real window.
Fresh promotion evidence includes `.codex/tkinter_ttk_treeview_tag_bind_probe.py`,
a focused red test failing because `Treeview` had no `tag_bind` method,
focused green passing 1/1 in 281 ms, `TtkTreeview` filter passing 9/9 in
1.156 seconds, `Ttk` filter passing 112/112 in 14.297 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 175/175 in 21.578 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1.094
seconds, aggregate `stdlib/tests` passing 1043/1043 with `-TimeoutSeconds 40
-Quiet` in 29.328 seconds, and aggregate `stdlib/tests` passing 1043/1043 with
`-TimeoutSeconds 70 -Quiet` in 29.015 seconds and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.tag_configure(tagname, option=None, **kw)`. A fresh
Python 3.10.11 probe confirmed that local `ttk.Treeview` exposes only
`tag_bind`, `tag_configure`, and `tag_has` among public `tag_*` methods, so the
nonexistent `tag_names` method remains intentionally unimplemented. The same
probe confirmed `tag_configure` returns a dict of simple option values for a
tag query, returns an option's string value when `option` is supplied, returns
an empty dict for mutation, accepts empty tag names, creates default empty
values for missing tags, reports Python's missing/extra positional TypeErrors,
and preserves Python's option formatting behavior where `option="-background"`
is passed through as the Tcl option `"--background"` and errors accordingly.
The AHK surface now implements this on the prefixed-internal Treeview class,
preserving the public `stdlib.tkinter.ttk.Treeview(...).tag_configure(...)`
shape without adding a public `tag_config` alias that local Python 3.10.11 does
not expose. `stdlib/examples/tkinter.ahk` now records Treeview tag configure
set/query behavior, and the language-specific README tkinter examples style a
live Treeview tag and toggle an alert tag from the update callback. Fresh
promotion evidence includes `.codex/tkinter_ttk_treeview_tag_configure_probe.py`,
a focused red test failing because `Treeview` had no `tag_configure` method,
focused green passing 1/1 in 188 ms with a final rerun passing 1/1 in 172 ms,
`TtkTreeview` filter passing 8/8 in
1.360 seconds, `Ttk` filter passing 111/111 in 14.735 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 174/174 in 21.609 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in 1.235
seconds, aggregate `stdlib/tests` passing 1042/1042 with `-TimeoutSeconds 40
-Quiet` in 31.672 seconds, and aggregate `stdlib/tests` passing 1042/1042 with
`-TimeoutSeconds 70 -Quiet` in 30.657 seconds and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with callable `ttk.Treeview` scrollcommand option registration for
`xscrollcommand` / `yscrollcommand`. A fresh Python 3.10.11 probe confirmed
that local `ttk.Treeview.configure(yscrollcommand=callable)` returns `None`,
stores a string Tcl command name in `cget("yscrollcommand")`, dispatches Tcl
calls back to the Python callable with string fractions such as `"0.0"` and
`"1.0"`, returns Python `None` from that registered command as Tcl `"None"`,
clears the option back to an empty string with `yscrollcommand=""`, preserves
literal string `xscrollcommand` values such as `"puts"`, and accepts the same
callable registration on a gridded Treeview. The AHK surface now registers any
callable widget option value through the existing Tcl command registry whenever
a Tk root is available, instead of only registering the option literally named
`command`. This preserves existing string option behavior while making
`tree.configure({ yscrollcommand: (args*) => treeScroll.set(args*) })` work in
captured README examples without hanging. Fresh promotion evidence includes
the CPython 3.10.11 probe in
`.codex/tkinter_ttk_treeview_scrollcommand_probe.py`, a focused red test
timing out on the callable `yscrollcommand` configuration path in 4.437
seconds, focused green passing 1/1 in 421 ms, `TtkTreeview` filter passing
7/7 in 1.078 seconds, `Ttk` filter passing 110/110 in 13.515 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 173/173 in 29.515 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in
1.829 seconds, aggregate `stdlib/tests` passing 1041/1041 with
`-TimeoutSeconds 40 -Quiet` in 38.969 seconds, and aggregate `stdlib/tests`
passing 1041/1041 with `-TimeoutSeconds 70 -Quiet` in 39.953 seconds and the
known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget
submodule slice with `ttk.Treeview.xview(...)`,
`ttk.Treeview.xview_moveto(fraction)`, `ttk.Treeview.xview_scroll(number,
what)`, `ttk.Treeview.yview(...)`, `ttk.Treeview.yview_moveto(fraction)`, and
`ttk.Treeview.yview_scroll(number, what)`. A fresh Python 3.10.11 probe
confirmed that local `Treeview` inherits the same XView/YView signatures used
by other tkinter widgets, query calls return two-float tuples in the probed
setup, `moveto` / `scroll` helpers and raw `xview("moveto", ...)` /
`yview("scroll", ...)` calls return `None`, and missing/extra argument plus
Tk bad-command errors match the observed Python 3.10.11 wording. The AHK
surface implements the six methods on the prefixed-internal Treeview class and
converts query results through the existing float tuple helper, preserving the
public `stdlib.tkinter.ttk.Treeview(...).xview(...)` /
`yview(...)` shape without adding host class-name collision risk.
`stdlib/examples/tkinter.ahk` now records Treeview x/y view query, moveto, and
scroll returns, and the README tkinter examples exercise `yview_moveto(0.0)`
inside the live update callback while still showing a real window. Fresh
promotion evidence includes the CPython 3.10.11 probe in
`.codex/tkinter_ttk_treeview_view_probe.py`, a focused red test failing because
Treeview had no `xview` method, focused green passing 1/1 in 203 ms with a
rerun passing 1/1 in 172 ms, `TtkTreeview` filter passing 6/6 in 797 ms,
`Ttk` filter passing 109/109 in 13.562 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 172/172 in 20.422 seconds, and the
later scrollcommand promotion gates above revalidating the expanded Treeview
surface in the 1041-test aggregate suite.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.tag_has(tagname, item=None)`. A fresh Python 3.10.11
probe confirmed that local `tkinter.ttk.Treeview.tag_has` has signature
`(self, tagname, item=None)`, returns a tuple of item ids when no item is
supplied, treats `item=None` like the tuple-returning all-items query, returns
Python booleans when an item id is supplied, handles tags containing spaces,
returns an empty tuple for missing tags, returns `False` for missing tag/item
membership, and raises Python's missing/extra argument `TypeError` wording
plus Tk's missing item `TclError` wording. The AHK surface implements this as
a prefixed-internal Treeview method that delegates to Tcl `tag has` and
converts the result into either `stdlib.tuple(...)` or stdlib booleans,
preserving the public `stdlib.tkinter.ttk.Treeview(...).tag_has(...)` shape
without adding host class-name collision risk. `stdlib/examples/tkinter.ahk`
now exercises both tuple and boolean `tag_has` paths, and the language-specific
README tkinter examples use `tag_has("dynamic")` inside the live update
callback while still showing a real window. Fresh promotion evidence includes
the CPython 3.10.11 probe in `.codex/tkinter_ttk_treeview_tag_has_probe.py`,
a focused red test failing because `Treeview` had no `tag_has` method,
focused green passing 1/1 in 328 ms, `TtkTreeview` filter passing 5/5 in
1.078 seconds, `Ttk` filter passing 108/108 in 15.953 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 171/171 in 20.250 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in
1.265 seconds, aggregate `stdlib/tests` passing 1039/1039 with
`-TimeoutSeconds 40 -Quiet` in 30.703 seconds, and aggregate `stdlib/tests`
passing 1039/1039 with `-TimeoutSeconds 70 -Quiet` in 38.687 seconds and the
known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget
submodule slice with `ttk.Treeview.set_children(item, *newchildren)`. A fresh
Python 3.10.11 probe confirmed that local `tkinter.ttk.Treeview.set_children` has
signature `(self, item, *newchildren)`, returns `None`, reorders the root item
children when passed a new sequence, detaches omitted existing children while
preserving `exists(item) == True`, clears an item's children when only `item`
is supplied, restores detached children when supplied later, accepts duplicate
child ids as observed by Tk, and raises Python's missing-argument `TypeError`
plus Tk's missing item / self-descendant `TclError` wording. The AHK surface
implements this as a prefixed-internal Treeview method that passes
`newchildren` as a single Tcl list word, preserving the public
`stdlib.tkinter.ttk.Treeview(...).set_children(...)` shape without adding host
class-name collision risk. `stdlib/examples/tkinter.ahk` now exercises
`set_children` beside Treeview detach/move/see and identify coverage, and the
language-specific README tkinter examples use it from the live update callback
while still showing a real window. Fresh promotion evidence includes the
CPython 3.10.11 probe in `.codex/tkinter_ttk_treeview_set_children_probe.py`,
a focused red test failing because `Treeview` had no `set_children` method,
focused green passing 1/1 in 187 ms, `TtkTreeview` filter passing 4/4 in
484 ms, `Ttk` filter passing 107/107 in 12.625 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 170/170 in 19.500 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions in
1.235 seconds, aggregate `stdlib/tests` passing 1038/1038 with
`-TimeoutSeconds 40 -Quiet` in 30.063 seconds, and aggregate `stdlib/tests`
passing 1038/1038 with `-TimeoutSeconds 70 -Quiet` in 29.734 seconds and the
known `plain fallback` stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget
submodule slice with `ttk.Treeview.identify_element(x, y)`. A fresh Python
3.10.11 probe confirmed that local `tkinter.ttk.Treeview.identify_element`
has signature `(self, x, y)`, returns the same result as
`Treeview.identify("element", x, y)`, returns an empty string for the observed
off-element coordinates, and raises Python's missing/extra argument `TypeError`
wording plus Tk's integer conversion `TclError` wording for bad coordinates.
The AHK surface implements this as a prefixed-internal Treeview method that
delegates through the existing `identify("element", ...)` behavior, preserving
the public `stdlib.tkinter.ttk.Treeview(...).identify_element(...)` shape
without adding host class-name collision risk. `stdlib/examples/tkinter.ahk`
now exercises `identify_element(5, 5)` beside the existing Treeview identify
row/column/region and structure-command coverage, and the language-specific
README tkinter examples call it from the live update callback while still
showing a real window. Fresh promotion evidence includes the CPython 3.10.11
probe in `.codex/tkinter_ttk_treeview_identify_element_probe.py`, a focused
red test failing because `Treeview` had no `identify_element` method, focused
green passing 1/1 in 156 ms, `TtkTreeview` filter passing 3/3 in 375 ms,
`Ttk` filter passing 106/106 in 12.984 seconds, full
`stdlib/tests/tkinter.test.ahk` passing 169/169 in 20.187 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions, aggregate
`stdlib/tests` passing 1037/1037 with `-TimeoutSeconds 40 -Quiet` in
29.969 seconds, and aggregate `stdlib/tests` passing 1037/1037 with
`-TimeoutSeconds 70 -Quiet` in 29.578 seconds and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview.detach(*items)`, `ttk.Treeview.move(item, parent,
index)`, and `ttk.Treeview.see(item)`. A fresh Python 3.10.11 probe confirmed
that local `tkinter.ttk.Treeview` exposes signatures `(self, *items)`,
`(self, item, parent, index)`, and `(self, item)` respectively; `detach()`
with no items returns `None`; detaching removes an item from its parent while
preserving `exists(item) == True`; `move(...)` reparents and reorders items;
`see(...)` returns `None`; and missing/bad item or index paths use the observed
Python/Tk `TypeError` and `TclError` wording. The AHK surface implements these
as prefixed-internal Treeview methods, preserving the public
`stdlib.tkinter.ttk.Treeview(...).detach(...)`, `.move(...)`, and `.see(...)`
shape without adding host class-name collision risk. `stdlib/examples/tkinter.ahk`
now exercises Treeview detach/move/see alongside existing item, selection,
focus, heading, and column coverage, and the language-specific README tkinter
examples use the same Treeview structure commands while still showing a real
window. Fresh promotion evidence includes the CPython 3.10.11 probe in
`.codex/tkinter_ttk_treeview_structure_probe.py`, a focused red test failing
because `Treeview` had no `detach` method, focused green passing 1/1 in
218 ms, `TtkTreeview` filter passing 2/2 in 235 ms, `Ttk` filter passing
105/105 in 14.375 seconds, full `stdlib/tests/tkinter.test.ahk` passing
168/168 in 21.094 seconds, explicit
`run-ahk-validate -Path stdlib/examples/tkinter.ahk` passing, README en/zh
examples passing through ahktest capture with pollution assertions, aggregate
`stdlib/tests` passing 1036/1036 with `-TimeoutSeconds 40 -Quiet` in
30.312 seconds, and aggregate `stdlib/tests` passing 1036/1036 with
`-TimeoutSeconds 70 -Quiet` in 30.609 seconds and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with public `ttk.tclobjs_to_py(adict)`. A fresh Python 3.10.11 probe
confirmed that `tkinter.ttk.tclobjs_to_py` has signature `(adict)`, imports
from `tkinter.ttk`, mutates the supplied dict in place, returns the same dict
object, converts Tcl/list-like values to Python lists, converts integer-looking
string values inside those lists to `int`, converts nested tuple/list values
through Python tuple-shaped string representations, leaves scalar strings and
integers unchanged, and raises Python's missing/extra argument TypeErrors plus
`AttributeError("'NoneType'/'list'/'str' object has no attribute 'items'")`
for non-mapping inputs. The AHK surface implements the covered dict-equivalent
path on `Map`, preserving in-place mutation and same-object return. The
examples now exercise `tclobjs_to_py` beside the other ttk helper functions.
Fresh promotion evidence includes the CPython 3.10.11 probe in
`.codex/tkinter_ttk_tclobjs_to_py_probe.py`, a focused red test failing
because `stdlib.tkinter.ttk` had no `tclobjs_to_py` method, focused green
passing 1/1, `Ttk` filter passing 104/104, full
`stdlib/tests/tkinter.test.ahk` passing 167/167,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README en/zh extracted
probes passing through ahktest capture, aggregate `stdlib/tests` passing
1035/1035 with `-TimeoutSeconds 40 -Quiet`, and aggregate `stdlib/tests`
passing 1035/1035 with `-TimeoutSeconds 70` and the known `plain fallback`
stderr line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with public `ttk.setup_master(master=None)`. A fresh Python 3.10.11
probe confirmed that `tkinter.ttk.setup_master` has signature
`(master=None)`, imports from `tkinter.ttk`, returns a supplied non-`None`
master without checking for `.tk`, creates and returns the default `Tk` root
when called before any default root exists, returns the current default root
for omitted or `None` master once it exists, rejects extra positional
arguments with `TypeError("setup_master() takes from 0 to 1 positional
arguments but 2 were given")`, and preserves the `NoDefaultRoot()` runtime
error path for omitted or `None` master. The AHK surface implements this as a
static public function on `stdlib.tkinter.ttk`, preserving the fixed public API
without adding a class-name collision risk. README tkinter examples were
revalidated unchanged through an ahktest capture wrapper with
`/ErrorStdOut=UTF-8`, including explicit checks that extracted probes did not
contain `System.Text.RegularExpressions` or `MatchEvaluator`. Fresh promotion
evidence includes the CPython 3.10.11 probe in
`.codex/tkinter_ttk_setup_master_probe.py`, a focused red test failing because
`stdlib.tkinter.ttk` had no `setup_master` method, focused green passing 1/1,
`Ttk` filter passing 103/103, full `stdlib/tests/tkinter.test.ahk` passing
166/166, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, README en/zh
extracted probes passing through ahktest capture, aggregate `stdlib/tests`
passing 1034/1034 with `-TimeoutSeconds 70` and the known `plain fallback`
stderr line, one same-slice `-TimeoutSeconds 40 -Quiet` attempt timing out,
and a fresh 40-second rerun passing 1034/1034 in 31.406 seconds.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.LabeledScale`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.LabeledScale` has signature `(master=None, variable=None,
from_=0, to=10, **kw)`, imports from `tkinter.ttk`, inherits from `ttk.Frame`,
rejects a string master with `AttributeError("'str' object has no attribute
'tk'")`, rejects unknown frame options with Tcl `unknown option "-bad"`, uses
`widgetName == "ttk::frame"` and `winfo_class() == "TFrame"`, creates public
`.scale` and `.label` child widgets while keeping `variable` private, initializes
the supplied or internal `IntVar` to `from_`, places the live label above or
below according to `compound`, exposes a `value` property synchronized with the
variable, clamps out-of-range values back to the last valid value, and sets
`.scale` / `.label` to `None` after destroy. The AHK surface implements this as
a prefixed internal `AhkStdlibTkinterTtkLabeledScale` class bound to public
`stdlib.tkinter.ttk.LabeledScale`, preserving the fixed public API while
avoiding raw AHK class-name collisions. The language-specific README tkinter
examples now include a real `ttk.LabeledScale` in the ttk pane, and
`stdlib/examples/tkinter.ahk` exercises constructor, child widget, layout,
`value`, variable sync, and clamp behavior. This pass also prefixed the
remaining ttk internal `Combobox`, `Separator`, `Progressbar`, and `Notebook`
classes so their public constructors stay bound through `stdlib.tkinter.ttk.*`
without colliding with AHK built-ins. Fresh promotion evidence includes a
CPython 3.10.11 probe in `.codex/tkinter_ttk_labeledscale_clean_probe.py`, a
focused red test failing because `stdlib.tkinter.ttk` had no `LabeledScale`
property, focused green passing 1/1, `Ttk` filter passing 102/102, full
`stdlib/tests/tkinter.test.ahk` passing 165/165,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing through an ahktest capture wrapper with `/ErrorStdOut=UTF-8`,
and aggregate `stdlib/tests` passing 1033/1033 with `-TimeoutSeconds 70` and
the known `plain fallback` stderr line. A repeat aggregate also passed
1033/1033 with `-TimeoutSeconds 80 -Quiet`; post-prefix repeat attempts at
`-TimeoutSeconds 60 -Quiet` and `-TimeoutSeconds 40 -Quiet` timed out, so they
are not claimed as final green evidence in this slice.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.OptionMenu`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.OptionMenu` has signature `(master, variable, default=None,
*values, **kwargs)`, imports from `tkinter.ttk`, inherits from
`ttk.Menubutton`, rejects missing `master`/`variable` with Python's
`OptionMenu.__init__` TypeErrors, rejects invalid masters with
`AttributeError("'int' object has no attribute 'tk'")`, and passes unknown
keyword options through as Tcl `unknown option -bad`. The covered behavior
includes default-value propagation into the supplied variable, `widgetName ==
"ttk::menubutton"`, `winfo_class() == "TMenubutton"`, attached classic
`Menu` creation with `tearoff == 0`, menu entry labels for `*values`, menu
`invoke(...)` updating the variable before calling the command callback,
`set_menu(default=None, *values)` rebuilding menu entries, and inherited ttk
`state(...)` / `instate(...)` behavior. The AHK surface implements this as a
prefixed internal `AhkStdlibTkinterTtkOptionMenu` class bound to public
`stdlib.tkinter.ttk.OptionMenu`, preserving the fixed public API while avoiding
raw AHK class-name collisions. The language-specific README tkinter examples
now include a real `ttk.OptionMenu` choice control, and
`stdlib/examples/tkinter.ahk` exercises the covered constructor, menu,
callback, and `set_menu(...)` paths. Fresh promotion evidence includes the
focused red test failing because `stdlib.tkinter.ttk` had no `OptionMenu`
property, focused green passing 1/1, `Ttk` filter passing 101/101, full
`stdlib/tests/tkinter.test.ahk` passing 164/164,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1032/1032 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line; the same aggregate suite also passed 1032/1032 with
`-TimeoutSeconds 60 -Quiet`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Widget`, plus explicit alias coverage for `ttk.Labelframe` and
`ttk.PanedWindow`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Widget` has signature `(master, widgetname, kw=None)`, imports
from `tkinter.ttk`, rejects missing `master`/`widgetname` with Python's
`Widget.__init__` TypeErrors, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, accepts `master=None`
by creating a default root, preserves `widgetName == "ttk::frame"` when asked
to construct a raw ttk frame command, reports `winfo_class() == "TFrame"`, and
exposes ttk `keys()`, `cget(key)`, `configure(...)`, `state(...)`,
`instate(...)`, and `identify(x, y)` behavior. The same probe confirmed that
`ttk.LabelFrame is ttk.Labelframe` and `ttk.Panedwindow is ttk.PanedWindow` in
CPython 3.10.11. The AHK surface implements `ttk.Widget` as a prefixed
internal `AhkStdlibTkinterTtkWidget` class bound to public
`stdlib.tkinter.ttk.Widget`, and keeps the alias identities on the public
`stdlib.tkinter.ttk` object without changing the fixed include/API surface.
The language-specific README tkinter examples now include a raw ttk widget
host built with `ttk.Widget(leftPane, "ttk::frame", ...)`, and
`stdlib/examples/tkinter.ahk` exercises the covered constructor, option,
state, and instate paths. Fresh promotion evidence includes the focused red
test failing because `stdlib.tkinter.ttk` had no `Widget` property, focused
green passing 1/1, alias coverage passing 1/1, `Ttk` filter passing 100/100,
full `stdlib/tests/tkinter.test.ahk` passing 163/163,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1031/1031 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line; the same aggregate suite also passed 1031/1031 with
`-TimeoutSeconds 60 -Quiet`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Menubutton`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Menubutton` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::menubutton"`,
reports `winfo_class() == "TMenubutton"`, and exposes `text`,
`textvariable`, `underline`, `width`, `direction`, `menu`, `state`, `cursor`,
`style`, `takefocus`, and `class` configure keys. The covered behavior
includes `keys()`, `cget(key)`, `configure(option)`, `configure(options)`,
`state(statespec=None)`, `instate(...)`, Tcl option errors, and the Python
`TypeError` wording for non-iterable state specs and arity mismatches. The AHK
surface implements this as a prefixed internal
`AhkStdlibTkinterTtkMenubutton` class bound to public
`stdlib.tkinter.ttk.Menubutton` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a real `ttk.Menubutton`
backed by a classic `Menu`, and `stdlib/examples/tkinter.ahk` exercises the
covered ttk Menubutton constructor, menu/textvariable options, configure,
state, and instate paths. Fresh promotion evidence includes the focused red
test failing because `stdlib.tkinter.ttk` had no `Menubutton` property,
focused green passing 1/1, `Ttk` filter passing 98/98, full
`stdlib/tests/tkinter.test.ahk` passing 161/161,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1029/1029 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line; the same aggregate suite also passed 1029/1029 with
`-TimeoutSeconds 60 -Quiet`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Spinbox`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Spinbox` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::spinbox"`,
reports `winfo_class() == "TSpinbox"`, inherits through `ttk.Entry`, and
exposes `from`, `to`, `increment`, `values`, `textvariable`, `width`, `wrap`,
`state`, `cursor`, `style`, and `class` configure keys. The covered behavior
includes `get()`, `set(value)`, `delete(first, last=None)`, `insert(index,
string)`, `index(index)`, `bbox(index)`, `identify(x, y)`,
`selection_present()`, `selection_range(start, end)`, `selection_clear()`,
`state(statespec=None)`, `instate(...)`, `xview(...)`, `xview_moveto(...)`,
and inherited `scan_mark/scan_dragto` Tcl errors for the unsupported `scan`
subcommand. The slice also keeps Python's public absence of `invoke` and
`selection_element` on `ttk.Spinbox`. The AHK surface implements this as a
prefixed internal `AhkStdlibTkinterSpinbox` class bound to public
`stdlib.tkinter.ttk.Spinbox` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a `ttk.Spinbox`
controlling the demo update step, and `stdlib/examples/tkinter.ahk` exercises
the covered ttk Spinbox constructor, option, value, selection, bbox/identify,
state, and xview paths. Fresh promotion evidence includes the focused red test
failing because `stdlib.tkinter.ttk` had no `Spinbox` property, focused green
passing 1/1, `Ttk` filter passing 97/97, full
`stdlib/tests/tkinter.test.ahk` passing 160/160,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1028/1028 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Style`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Style` has signature `(master=None)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates a default
`Tk` master when needed, and exposes `master`, `tk`, `theme_names()`,
`theme_use(themename=None)`, `configure(style, query_opt=None, **kw)`,
`lookup(style, option, state=None, default=None)`, `map(style,
query_opt=None, **kw)`, `layout(style, layoutspec=None)`,
`element_names()`, `element_options(elementname)`, and
`theme_settings(themename, settings)`. The covered behavior includes
Python-shaped dict/tuple/list readback for style `configure(...)`, state maps,
layout trees, element-name and element-option queries, theme settings script
application, Python-observed arity messages, missing-layout Tcl errors, and
missing-theme Tcl errors passing through unchanged. The AHK surface implements
this as a prefixed internal `AhkStdlibTkinterStyle` class bound to public
`stdlib.tkinter.ttk.Style` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now style the demo `ttk.Treeview`
through `ttk.Style`, and `stdlib/examples/tkinter.ahk` exercises the covered
Style constructor, theme, configure, lookup, map, layout, element, and
theme-settings paths. Fresh promotion evidence includes the focused red test
failing because `stdlib.tkinter.ttk` had no `Style` property, focused green
passing 1/1, `Ttk` filter passing 96/96, full
`stdlib/tests/tkinter.test.ahk` passing 159/159,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1027/1027 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Treeview`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Treeview` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::treeview"`,
reports `winfo_class() == "Treeview"`, and exposes `columns`,
`displaycolumns`, `height`, `padding`, `selectmode`, `show`, `style`,
`takefocus`, `cursor`, `class`, `xscrollcommand`, and `yscrollcommand`
configure keys. The covered behavior includes tuple-shaped `cget(...)` and
`configure(...)` readback for list options, integer readback for `height` and
`takefocus`, `heading(...)`, `column(...)`, `insert(...)`, `get_children(...)`,
`parent(...)`, `index(...)`, `exists(...)`, `item(...)`, `set(...)`,
`selection(...)`, `selection_set(...)`, `selection_add(...)`,
`selection_remove(...)`, `focus(...)`, `bbox(...)`, `identify_row(...)`,
`identify_column(...)`, `identify_region(...)`, `next(...)`, `prev(...)`, and
`delete(...)`, plus Python-observed arity messages and Tcl bad item/column
errors passing through unchanged. The AHK surface implements this as a
prefixed internal `AhkStdlibTkinterTreeview` class bound to public
`stdlib.tkinter.ttk.Treeview` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a real `ttk.Treeview`
inside the `ttk.Panedwindow` demo area, and `stdlib/examples/tkinter.ahk`
exercises the covered Treeview constructor, option, item, selection, focus,
and identify paths. Fresh promotion evidence includes the focused red test
failing because `stdlib.tkinter.ttk` had no `Treeview` property, focused green
passing 1/1, `Ttk` filter passing 95/95, full
`stdlib/tests/tkinter.test.ahk` passing 158/158,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1026/1026 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Sizegrip`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Sizegrip` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::sizegrip"`,
reports `winfo_class() == "TSizegrip"`, and exposes `class`, `cursor`,
`style`, and `takefocus` configure keys. The covered behavior includes
`cget(...)` and `configure(...)` readback for those keys, `identify(x, y)`,
the inherited `state(statespec=None)` and
`instate(statespec, callback=None, *args)` paths, Python-observed arity
messages, non-iterable state-spec `TypeError("can only join an iterable")`,
bare-string state Tcl errors, and Tcl bad-option errors passing through
unchanged. The AHK surface implements this as a prefixed internal
`AhkStdlibTkinterSizegrip` class bound to public
`stdlib.tkinter.ttk.Sizegrip` through `DefineProp(Get, Call)`, preserving the
fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a `ttk.Sizegrip` inside
the `ttk.Panedwindow` demo area; root `README.md` remains an English-first,
Chinese-second entry page with no code examples. Fresh promotion evidence
includes the focused red test failing because `stdlib.tkinter.ttk` had no
`Sizegrip` property, focused green passing 1/1, `Ttk` filter passing 94/94,
full `stdlib/tests/tkinter.test.ahk` passing 157/157,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probes passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1025/1025 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Panedwindow`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Panedwindow` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, rejects a string master with
`AttributeError("'str' object has no attribute 'tk'")`, creates default-root
widgets when no master is supplied, uses `widgetName == "ttk::panedwindow"`,
reports `winfo_class() == "TPanedwindow"`, exposes `orient`, `width`,
`height`, `takefocus`, `cursor`, `style`, and `class` configure keys, and
returns pane paths as tuples. The covered pane behavior includes
`add(child, **kw)`, `forget(child)`, `insert(pos, child, **kw)`,
`pane(pane, option=None, **kw)`, `panes()`, `sashpos(index, newpos=None)`,
and `identify(x, y)` with Python-observed arity messages, integer `weight`
readback, `pane(..., {weight: ...})` returning `{}`, empty-pane
`sashpos(0)` raising `TclError("sash index 0 out of range")`, and Tcl bad
option errors passing through unchanged. The AHK surface implements this as a
prefixed internal `AhkStdlibTkinterPanedwindow` class bound to public
`stdlib.tkinter.ttk.Panedwindow` through `DefineProp(Get, Call)`, preserving
the fixed public API while avoiding raw AHK class-name collisions. The
language-specific README tkinter examples now include a `ttk.Panedwindow`
container alongside ttk labels, entry, progressbar, variables, callbacks,
`grid`, and Canvas drawing; root `README.md` remains an English-first,
Chinese-second entry page with no code examples. Fresh promotion evidence
includes the focused red test failing because `stdlib.tkinter.ttk` had no
`Panedwindow` property, focused green passing 1/1, `Ttk` filter passing
93/93, full `stdlib/tests/tkinter.test.ahk` passing 156/156,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, README tkinter demo
probe passing with `/ErrorStdOut=UTF-8`, and aggregate `stdlib/tests` passing
1024/1024 with `-TimeoutSeconds 70` and the known `plain fallback` stderr
line.

The latest tkinter safety slice keeps the public `stdlib.tkinter.X` and
`stdlib.tkinter.ttk.X` class surface stable while moving classic tkinter
implementation classes off AHK's global class names. A fresh AHK parser probe
confirmed that same-name host classes such as `Menu`, `Button`, `Event`,
`Image`, and `Text` can be declared before including `stdlib\tkinter.ahk`
when the stdlib implementation classes are prefixed; a focused subprocess
regression now covers that include path and confirms
`stdlib.tkinter.Tcl() is stdlib.tkinter.Tk`,
`stdlib.tkinter.Event() is stdlib.tkinter.Event`, and
`stdlib.tkinter.EventType("4") is stdlib.tkinter.EventType` while
`stdlib.tkinter.Menu` is not the host `Menu` class. The implementation now
binds public class properties with `DefineProp(Get, Call)` shims for classic
tkinter and the renamed ttk nested classes, preserving
`stdlib.tkinter.Menu(...)` and `obj is stdlib.tkinter.Menu` while avoiding raw
top-level `class Menu extends ...` declarations. The language-specific
README tkinter demo snippets now keep the window visible with `root.mainloop()`
and exercise the covered `ttk` widgets, Tk variables, command callbacks,
`grid` layout, and Canvas drawing path instead of immediately withdrawing and
destroying a root; the root `README.md` remains a bilingual entry point that
links to the English and Chinese quick starts rather than duplicating code
examples.
A fresh Python 3.10.11 probe also confirmed that `Tk.mainloop()` returns
`None` after `root.destroy()` and that the default root is cleared, while a
direct Tcl-side `destroy .` still lets `mainloop()` return `None`; the AHK
surface now sets the default `WM_DELETE_WINDOW` protocol through a registered
callback that calls `root.destroy()` and treats the Tk `application has been
destroyed` state as normal `mainloop()` exit. Fresh gates: the focused
host-class collision regression passed 1/1, focused default-window-close
mainloop regression passed 1/1, README tkinter demo probe passed with
`/ErrorStdOut=UTF-8`, `Ttk` filter passed 91/91, full
`stdlib/tests/tkinter.test.ahk` passed 155/155,
`run-ahk-validate stdlib/examples/tkinter.ahk` passed, and aggregate
`stdlib/tests` passed 1023/1023 with `-TimeoutSeconds 70` and the known
`plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.LabelFrame`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.LabelFrame` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::labelframe"`, reports default `winfo_class()` from
the explicit class override, starts in the default empty state `()`, and
exposes `text`, `width`, `height`, `padding`, `labelanchor`, `takefocus`,
`cursor`, `style`, and `class` keys. The covered option behavior includes
string/integer/tuple-shaped cget and configure readback for those options,
`labelanchor` defaulting from `nw` to the supplied `ne`, `identify(5, 5) == ""`,
the observed bad constructor option path, plus inherited
`state(statespec := unset)` and `instate(statespec, callback := unset, args*)`
behavior for iterable state specs, current-state tuple queries, true/false
match results, callback-on-match-only behavior, `TypeError("can only join an
iterable")` for non-iterable statespec values, and raw Tcl invalid-state-name
errors for bare string statespec values. The AHK surface now covers
`stdlib.tkinter.ttk.LabelFrame(...)` for that observed
constructor/configure/query/state slice while leaving other themed widgets such
as `Treeview` and `Style` intentionally unclaimed. Fresh promotion gates include
the focused red test failing because `stdlib.tkinter.ttk` had no `LabelFrame`
property, focused green passing after exposing
`AhkStdlibTkinterTtk.LabelFrame`,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate passing, and the aggregate `stdlib/tests`
gate returning to 1021 passed, 0 failed, and 0 errors with
`-TimeoutSeconds 60` plus the known `plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Button.invoke()`, `ttk.Button.state(...)`, and
`ttk.Button.instate(...)`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Button` exposes `invoke(self)`, `state(self, statespec=None)`,
and `instate(self, statespec, callback=None, *args, **kw)` from
`tkinter.ttk.Widget`; that `invoke()` returns the command callback result with
`""` when no command is configured; that `state()` returns the current widget
state tuple when `statespec` is omitted or `None`, applies iterable state
specs such as `["disabled"]` and `["!disabled"]`, and returns the delta tuple
of changed flags; that `instate()` returns booleans for matching and
non-matching state specs and invokes the callback only on a true match; and
that non-iterable statespec values raise `TypeError("can only join an iterable")`
while bare string statespec values surface the raw Tcl state-name error such as
`TclError("Invalid state name d")`. The AHK surface now covers
`stdlib.tkinter.ttk.Button(...).invoke()`, `.state(statespec := unset)`, and
`.instate(statespec, callback := unset, args*)` for that observed slice while
keeping other themed widgets' state/instate parity intentionally unclaimed.
Fresh promotion gates include the focused red test erroring because
`AhkStdlibTkinterTtk.Button` had no `invoke` method, focused green passing 1/1
in 375ms after the themed-widget state helper and stdlib-boolean callback gate
fix, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, adjacent `Ttk`
coverage and the full `stdlib/tests/tkinter.test.ahk` gate passing, and the
aggregate `stdlib/tests` gate returning to 1016 passed, 0 failed, and 0 errors
with `-TimeoutSeconds 40` plus the known `plain fallback` stderr line.

The latest tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Notebook`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Notebook` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::notebook"`, reports
`winfo_class() == "TNotebook"`, and exposes `width`, `height`, `padding`,
`takefocus`, `cursor`, `style`, and `class` keys. The covered widget-option
behavior includes tuple readback for `padding`, integer readback for
`takefocus`, `cursor`, `style`, and `class` cget/configure shapes, and the
observed bad constructor option path. The covered tab behavior includes empty
`tabs()`, `index("end")`, and `select()` results, `add(...)`, `insert(...)`,
`forget(...)`, `hide(...)`, `tabs()`, `index(tab_id)`, `select(None)`,
`select(tab_id)` including the disabled-tab no-op, `tab(tab_id)`,
`tab(tab_id, option)`, `tab(tab_id, **kw)`, and `enable_traversal()` return
shapes. The `tab(...)` dict/list/tuple conversion is scoped to Notebook tab
metadata so generic widget option conversion remains unchanged. Fresh probes
also captured unmanaged-tab, invalid-slave, bad-option, and representative
arity messages. `Notebook.identify(...)` plus other ttk widgets such as
`Treeview`, `Style`, `Checkbutton`, `Radiobutton`, `Scale`, `Scrollbar`,
`Spinbox`, `LabelFrame`, `Menubutton`, `Panedwindow`, and `Sizegrip` remained
unclaimed at that point. Fresh promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Notebook` property, focused green passing 1/1 in
297ms after fresh probes corrected the disabled-tab selection expectation and
confirmed `identify(1, 1) == ""` while `identify(5, 5) == "tab"` in the
withdrawn-root coverage scenario,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, adjacent `Ttk` filter
coverage passing 84/84 in 17906ms, the full `stdlib/tests/tkinter.test.ahk`
gate at 147 passed, 0 failed, and 0 errors in 19532ms, and the aggregate
`stdlib/tests` gate at 1015 passed, 0 failed, and 0 errors in 42703ms with
`-TimeoutSeconds 120` and the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Progressbar`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Progressbar` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::progressbar"`, and reports
`winfo_class() == "TProgressbar"`. The covered option behavior includes default
`orient == "horizontal"`, `mode == "determinate"`, `maximum == 100`, and
`value == 0.0`, explicit horizontal `orient`, `length`, `mode`, `maximum`,
`value`, `variable`, `style`, `takefocus`, and `cursor`, Python integer-or-float
readback for `maximum`, float readback for `value`, and `keys()` membership for
`orient`, `length`, `mode`, `maximum`, `variable`, `value`, `phase`,
`takefocus`, `cursor`, `style`, and `class`. The covered command behavior
includes `step()`, `step(amount)`, `start()`, `start(interval)`, and `stop()`
returning Python `None`, with `step(...)` updating the linked `DoubleVar` and
observed `start/stop` stepping behavior. Fresh probes also captured bad
`start`, `step`, and `stop` arity text, bad-option, bad-orient, bad-mode, and
the vertical custom-style layout TclError path. A first implementation attempt
converted generic `value` options globally; the full tkinter gate caught that
as Menu/Radiobutton regressions, and the final implementation scopes
`maximum`/`value` conversion to `ttk.Progressbar`. Fresh promotion gates
include the focused red test failing because `stdlib.tkinter.ttk` had no
`Progressbar` property, focused green passing 1/1 in 328ms and 1/1 in 282ms
after the scoped-conversion repair, adjacent `Ttk` filter coverage passing
83/83 in 12921ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 146 passed, 0 failed, and
0 errors in 19391ms, and the aggregate `stdlib/tests` gate at 1014 passed,
0 failed, and 0 errors in 31109ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Separator`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Separator` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::separator"`, and reports
`winfo_class() == "TSeparator"`. The covered option behavior includes default
`orient == "horizontal"`, explicit `orient`, `style`, `cursor`, and
`takefocus`, Python integer readback for `takefocus`, `keys()` membership for
`orient`, `takefocus`, `cursor`, `style`, and `class`, representative
`configure(...)` tuple queries including `configure("class")`, orientation
and style setters returning Python `None`, and the observed bad-option and
bad-orient TclError messages. Fresh promotion gates include the focused red
test failing because `stdlib.tkinter.ttk` had no `Separator` property, focused
green passing 1/1 in 312ms and then 1/1 in 281ms after tightening the
default-root identity assertion, adjacent `Ttk` filter coverage passing
82/82 in 25719ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 145 passed, 0 failed, and
0 errors in 27656ms, and the aggregate `stdlib/tests` gate at 1013 passed,
0 failed, and 0 errors in 47625ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extends the covered themed-widget submodule
slice with `ttk.Combobox`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Combobox` has signature `(master=None, **kw)`, imports from
`tkinter.ttk`, creates a default root when no master is supplied, rejects a
string master with `AttributeError("'str' object has no attribute 'tk'")`,
uses `widgetName == "ttk::combobox"`, and reports
`winfo_class() == "TCombobox"`. The covered option behavior now includes
AHK iterable `values` serialization through a Tcl list, Python-style tuple
readback from `cget("values")` and `configure("values")`, empty `values`
readback as `""`, representative `textvariable`, `width`, `state`, and
`style` option reads, and `keys()` membership for `postcommand`, `values`,
`exportselection`, `state`, `textvariable`, `width`, `style`, and `class`.
The covered command behavior includes `current()` returning `-1` initially,
`current(index)` returning Python `None` while updating the current value and
linked `StringVar`, `get()`, and `set(value)` returning Python `None`, including
the observed `current() == -1` state after setting a value outside the values
list. Fresh probes also captured the covered bad `current(...)` TclError
messages, `Combobox.set(...)`, `Combobox.current(...)`, and inherited
`Entry.get(...)` arity text, plus bad-option construction. Full classic Entry
MRO parity for every inherited method remains intentionally unclaimed beyond
the methods exercised by this slice. Fresh promotion gates include the focused
red test failing because `stdlib.tkinter.ttk` had no `Combobox` property,
focused green passing 1/1 in 281ms, adjacent `Ttk` filter coverage passing
81/81 in 26438ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 144 passed, 0 failed, and
0 errors in 29985ms, and the aggregate `stdlib/tests` gate at 1012 passed,
0 failed, and 0 errors in 59968ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
`ttk.Entry` slice with XView and scan-command behavior. Fresh Python 3.10.11
probes confirmed that `ttk.Entry.xview()` returns the two-float view tuple,
`xview_moveto(...)` and `xview_scroll(...)` return Python `None`, raw
`xview("moveto")` without a fraction raises `TclError("bad entry index \"moveto\"")`,
and the XView helper arity errors match local Python messages. The same probe
confirmed `ttk.Entry` exposes `scan_mark(...)` and `scan_dragto(...)` Python
methods with classic `Entry` arity errors, but the underlying `ttk::entry` Tcl
command has no `scan` subcommand, so real calls raise `TclError` with
`bad command "scan": must be ... or xview`. The AHK surface now covers that
XView behavior and the themed-entry scan error path. Fresh promotion gates
include the focused red test erroring because `AhkStdlibTkinterTtk.Entry` had
no `xview` method, focused green passing 1/1 in 266ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk`
gate at 143 passed, 0 failed, and 0 errors in 37359ms, and the aggregate
`stdlib/tests` gate at 1011 passed, 0 failed, and 0 errors in 58609ms with
`-TimeoutSeconds 120` and the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
`ttk.Entry` slice with cursor and selection behavior. Fresh Python 3.10.11
probes confirmed that `ttk.Entry` preserves classic `Entry` cursor APIs for
`icursor(...)` and `index("insert")`, supports `select_present()` /
`selection_present()`, `select_range(...)` / `selection_range(...)`, and
`select_clear()` / `selection_clear()` through the `ttk::entry` Tcl command,
sets the PRIMARY selection owner so widget/root `selection_get()` returns the
selected text and `selection_own_get()` resolves to the widget, and clears
ownership through root `selection_clear()`. The same probe confirmed the
themed command only accepts `clear`, `present`, and `range`, so
`select_from(...)`, `selection_from(...)`, `select_to(...)`,
`selection_to(...)`, `select_adjust(...)`, and `selection_adjust(...)` raise
`TclError` messages such as `bad command "from": must be clear, present, or range`.
The AHK surface now covers that cursor/selection behavior while XView and
scan behavior remained intentionally unclaimed at that point. Fresh promotion
gates include the focused red test erroring because
`AhkStdlibTkinterTtk.Entry` had no `icursor` method, focused green passing
1/1 in 281ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 142 passed, 0 failed, and
0 errors in 35172ms, and the aggregate `stdlib/tests` gate at 1010 passed,
0 failed, and 0 errors in 58859ms with `-TimeoutSeconds 120` and the known
stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Entry`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk.Entry` has signature `(master=None, widget=None, **kw)`, MRO
`Entry -> Widget -> Entry -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> XView -> object`,
`widgetName == "ttk::entry"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TEntry"`, `cget("width")`,
`cget("textvariable")`, `cget("style")`, `StringVar`-backed initial value
retention, `delete(...)` and `insert(...)` returning Python `None`,
`get()` and the linked variable reflecting inserted text, `index("end")`,
`keys()` containing `class`, `width`, `textvariable`, and `style`,
`configure("width")` and `configure("style")` tuple queries, combined
`configure(...)` width/style setters returning Python `None`,
`nametowidget(...)` identity, and the observed bad master / bad option error
text. The AHK surface now exposes `stdlib.tkinter.ttk.Entry(master=None, **kw)`
for the covered explicit-root constructor, basic input, and representative
option/configure behavior. The Python `widget` constructor parameter, full
classic-Entry MRO equivalence, selection aliases, and XView behavior remained
intentionally unclaimed at that point. Other `ttk` widgets
such as `Notebook`, `Treeview`, `Style`, `Progressbar`, and
`Separator` also remain unclaimed. Fresh promotion gates include the focused
red test failing because `stdlib.tkinter.ttk` had no `Entry` property, focused
green passing 1/1 in 281ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 141 passed,
0 failed, and 0 errors in 28235ms, and the aggregate `stdlib/tests` gate at
1009 passed, 0 failed, and 0 errors in 48828ms with `-TimeoutSeconds 120` and
the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Label`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Label` has
signature `(master=None, **kw)`, MRO
`Label -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::label"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TLabel"`, `cget("text")`,
`cget("style")`, `keys()` containing `class`, `text`, and `style`,
`configure("text")` returning the 5-tuple
`("text", "text", "Text", "", current)`, `configure("style")` returning the
5-tuple `("style", "style", "Style", "", current)`, combined
`configure(...)` text/style setters returning Python `None`,
`nametowidget(...)` identity, and the
observed bad master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Label(master=None, **kw)` for the covered explicit-root
constructor/configure behavior while keeping other `ttk` widgets such as
`Entry`, `Combobox`, `Notebook`, `Treeview`, `Style`, `Progressbar`, and
`Separator` intentionally unclaimed at that point. Fresh
promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Label` property, focused green passing 1/1 in
281ms, adjacent `ttk.Frame` and `ttk.Button` passing,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 140 passed, 0 failed, and 0 errors in
37735ms, and the aggregate `stdlib/tests` gate at 1008 passed, 0 failed, and
0 errors in 57360ms with `-TimeoutSeconds 120` and the known stderr line
`plain fallback`.

The preceding tkinter.ttk promotion extended the covered themed-widget submodule
slice with `ttk.Frame`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Frame` has
signature `(master=None, **kw)`, MRO
`Frame -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::frame"`, default-root creation, explicit string path
naming with `name`, `winfo_class() == "TFrame"`, `cget("style")`,
`keys()` containing `class` and `style`, `configure("style")` returning the
5-tuple `("style", "style", "Style", "", current)`, `configure(style=...)`
returning Python `None`, `nametowidget(...)` identity, and the observed bad
master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Frame(master=None, **kw)` for the covered default-root and
explicit-root constructor/configure behavior while keeping other `ttk` widgets
such as `Label`, `Entry`, `Combobox`, `Notebook`, `Treeview`, `Style`,
`Progressbar`, and `Separator` intentionally unclaimed at that point. Fresh
promotion gates include the focused red test failing because
`stdlib.tkinter.ttk` had no `Frame` property, focused green passing 1/1,
adjacent `ttk.Button` passing, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 139 passed,
0 failed, and 0 errors in 29484ms, and the aggregate `stdlib/tests` gate at
1007 passed, 0 failed, and 0 errors in 62484ms with `-TimeoutSeconds 120` and
the known stderr line `plain fallback`.

The preceding tkinter.ttk promotion opened the covered themed-widget submodule
slice with `ttk.Button`. Fresh Python 3.10.11 probes confirmed that
`tkinter.ttk` imports as a `tkinter` submodule, that `ttk.Button` has
signature `(master=None, **kw)`, MRO
`Button -> Widget -> Widget -> BaseWidget -> Misc -> Pack -> Place -> Grid -> object`,
`widgetName == "ttk::button"`, string path naming with explicit `name`,
`winfo_class() == "TButton"`, `cget("text")`, empty default `style`,
`keys()` containing `class` and `text`, `configure("text")` returning the
5-tuple `("text", "text", "Text", "", current)`, `configure(text=...)`
returning Python `None`, `nametowidget(...)` identity, and the observed bad
master / bad option error text. The AHK surface now exposes
`stdlib.tkinter.ttk.Button(master=None, **kw)` for the covered explicit-root
constructor and representative option/configure behavior while keeping other
then-uncovered `ttk` widgets intentionally unclaimed until focused slices cover
them. Fresh promotion gates include the focused red
test failing because `stdlib.tkinter` had no `ttk` property, focused green
passing 1/1 in 297ms, adjacent root `configure`, `Widget`, and `BaseWidget`
filters passing, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 138 passed, 0 failed, and 0
errors in 36078ms, and the aggregate `stdlib/tests` gate at 1006 passed,
0 failed, and 0 errors in 64156ms with `-TimeoutSeconds 90` and the known
stderr line `plain fallback`.

The latest tkinter public TclError promotion closes the covered public
exception-constructor slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.TclError` has no inspectable signature, has MRO
`TclError -> Exception -> BaseException -> object`, is an `Exception` but not
a `RuntimeError`, and preserves Python `Exception` argument semantics:
`TclError()` has empty string text and `args == ()`, `TclError("bad")` has
text `bad` and one argument, and multi-argument construction such as
`TclError("bad", 3)` and `TclError("bad", -1)` formats the message as the
Python tuple string while preserving all values in `.args`. The AHK surface
now exposes `stdlib.tkinter.TclError(args*)` for that covered constructor
behavior and real Tcl/Tk failures still raise `TclError` with `.args`
containing the Tcl message. Full Python `repr` parity for arbitrary object
arguments remains intentionally unclaimed until a focused slice covers it.
Fresh promotion gates include the focused red test failing with
`TclError().Message` reporting `AhkStdlibTkinter.TclError`, focused green
passing 1/1 in 47ms after the final `-1` public-argument assertion, adjacent
`IntVar`, `Widget`, and `BaseWidget` error-path filters passing,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 137 passed, 0 failed, and 0 errors in
38328ms, and the aggregate `stdlib/tests` gate at 1005 passed, 0 failed, and
0 errors in 56563ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The latest tkinter public BaseWidget promotion closes the covered base widget
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.BaseWidget(master, widgetName, cnf={}, kw={}, extra=())` signature
behavior; `BaseWidget` MRO through `Misc` without `Pack` / `Place` / `Grid`;
the missing and extra positional `BaseWidget.__init__()` TypeError text; bad
`master`, bad `cnf`, bad `kw`, bad option, bad `widgetName`, and bad
string-`extra` error text; named `label` creation under an explicit `Tk()`
root; stored `widgetName`, `master`, and `tk` attributes; `cnf` / `kw`
merging with `kw` override; `nametowidget(...)` registry lookup; and
representative `Misc` methods including `cget(...)`, `configure(...)`,
`winfo_class()`, and `destroy()`. The AHK surface now exposes
`stdlib.tkinter.BaseWidget(master, widgetName, cnf={}, kw={}, extra=())` for
that covered public constructor and representative-Misc behavior while keeping
layout methods absent from `BaseWidget`. Full `Misc` method parity and full
constructor `extra` tuple behavior remain intentionally unclaimed until their
own focused slices cover them. Fresh promotion gates include the focused red
test failing at missing `BaseWidget`, focused green passing 1/1 in 375ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, an initial full
`stdlib/tests/tkinter.test.ahk` attempt observing a transient focus identity
failure followed by focused `TestTkFocusLastforMatchesLocal310` passing, the
authoritative full tkinter rerun at 136 passed, 0 failed, and 0 errors in
26891ms, and the aggregate `stdlib/tests` gate at 1004 passed, 0 failed, and
0 errors in 52438ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The preceding tkinter public Widget promotion closes the covered generic widget
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.Widget(master, widgetName, cnf={}, kw={}, extra=())` signature
behavior; the inherited `BaseWidget.__init__()` missing and extra positional
TypeError text; bad `master`, bad `cnf`, bad `kw`, bad option, and bad
`widgetName` error text; named `label` creation under an explicit `Tk()` root;
stored `widgetName`, `master`, and `tk` attributes; `cnf` / `kw` merging with
`kw` override; `nametowidget(...)` registry lookup; and representative `pack`
layout behavior inherited by `Widget`. The AHK surface now exposes
`stdlib.tkinter.Widget(master, widgetName, cnf={}, kw={}, extra=())` for that
covered public constructor behavior. Full constructor `extra` tuple behavior
remains intentionally unclaimed until its own focused slice covers it. Fresh
promotion gates include the focused red
test failing at missing `Widget`, focused green passing 1/1 in 375ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 135 passed, 0 failed, and 0 errors in
29687ms, and the aggregate `stdlib/tests` gate at 1003 passed, 0 failed, and
0 errors in 51859ms with `-TimeoutSeconds 90` and the known stderr line
`plain fallback`.

The preceding tkinter public Image promotion closes the covered base image
constructor slice. Fresh Python 3.10.11 probes confirmed
`tkinter.Image(imgtype, name=None, cnf={}, master=None, **kw)` signature
behavior; missing `imgtype`, extra positional argument, no-default-root,
bad image type, bad option, bad `cnf`, and bad `master` error text; named and
generated `photo` image creation under an explicit `Tk()` root; registry
membership through `image_names()`; and base `bitmap` image creation. The AHK
surface now exposes `stdlib.tkinter.Image(imgtype, name=None, cnf={}, master=None)`
for that covered public constructor behavior, sharing the existing image
query methods `width()`, `height()`, `type()`, `configure()`, `config()`, and
string conversion. `PhotoImage(...)` and `BitmapImage(...)` remain the covered
specialized image classes for their subclass-specific methods. Fresh promotion
gates include the focused red test failing at missing `Image`, focused green
passing 1/1 in 250ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
the full `stdlib/tests/tkinter.test.ahk` gate at 134 passed, 0 failed, and
0 errors in 38828ms, the aggregate `stdlib/tests` gate timing out under
`-TimeoutSeconds 60`, and the aggregate `stdlib/tests` gate passing at
1002 passed, 0 failed, and 0 errors in 58438ms with `-TimeoutSeconds 90` and
the known stderr line `plain fallback`.

The preceding tkinter public-mixin promotion closes the covered zero-argument
constructor slice for `Pack`, `Place`, `Grid`, `XView`, `YView`, `Misc`, and
`Wm`. Fresh Python 3.10.11 probes confirmed that these public mixin classes
construct with no arguments, produce empty instances without initial `tk` or
`_w` attributes, reject extra positional arguments with
`Class() takes no arguments`, expose representative inherited methods, raise
`AttributeError("'Class' object has no attribute 'tk'")` for representative
bare `tk`-dependent methods, and return Python `None` for bare
`Misc.destroy()`. The AHK surface now exposes
`stdlib.tkinter.Pack()`, `stdlib.tkinter.Place()`, `stdlib.tkinter.Grid()`,
`stdlib.tkinter.XView()`, `stdlib.tkinter.YView()`,
`stdlib.tkinter.Misc()`, and `stdlib.tkinter.Wm()` for that covered public
constructor behavior. Full mixin method parity on bare instances remains
unclaimed beyond the representative probed methods; widget-backed inherited
method behavior remains covered by the existing widget tests. Fresh promotion
gates include the focused red test failing at missing `Pack`, focused green
passing 1/1 in 0ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
the full `stdlib/tests/tkinter.test.ahk` gate at 133 passed, 0 failed, and
0 errors in 24047ms, and the aggregate `stdlib/tests` gate at 1001 passed,
0 failed, and 0 errors in 41281ms with `-TimeoutSeconds 60` and the known
stderr line `plain fallback`.

The preceding tkinter CallWrapper promotion closes the covered public callback
adapter slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.CallWrapper(func, subst, widget)` stores `func`, `subst`, and
`widget` on the instance; calls `func(*args)` directly when `subst` is `None`;
calls `func(*subst(*args))` when `subst` is provided; expands a string returned
by `subst` into individual characters; calls `widget._report_exception()` and
returns Python `None` when either `subst` or `func` raises; and raises the
observed constructor arity `TypeError` text for missing or extra positional
arguments. The AHK surface now exposes
`stdlib.tkinter.CallWrapper(func, subst, widget)` for that covered callback
adapter behavior while preserving existing widget command callback behavior.
Fresh promotion gates include the focused red test failing at missing
`CallWrapper`, the focused green test passing 1/1 in 0ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 132 passed, 0 failed, and 0 errors in
22516ms, and the aggregate `stdlib/tests` gate at 1000 passed, 0 failed, and
0 errors in 33188ms with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter EventType promotion closes the covered public event-type
constructor slice. Fresh Python 3.10.11 probes confirmed that
`tkinter.EventType` is a `str` / `Enum` class with 39 observed member names,
including aliases `Key` -> `KeyPress` and `Button` -> `ButtonPress`; that
calling `EventType(value)` accepts string event codes such as `"2"`, `"4"`,
`"35"`, and `"38"`; that the returned object exposes canonical `.name` and
string `.value`; that `str(member)` returns the value string; and that invalid
strings, integers, `None`, missing value, and extra positional arguments raise
the observed Python 3.10.11 `ValueError` / `TypeError` text. The AHK surface
now exposes `stdlib.tkinter.EventType(value)` for the covered value-code
constructor behavior and also preserves existing callback event objects by
giving them `.type.name`, `.type.value`, and value-string conversion. Full
enum metaclass behavior, `__members`, member attribute access such as
`EventType.ButtonPress`, `repr(...)`, and str-subclass equality remain
intentionally unclaimed until focused slices cover them. Fresh promotion gates
include the focused red test failing at missing `EventType` in 16ms, the
focused green test passing 1/1 in 16ms and follow-up focused green passing 1/1
in 0ms after example edits, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 131 passed, 0
failed, and 0 errors in 22656ms, and the aggregate `stdlib/tests` gate at 999
passed, 0 failed, and 0 errors in 32625ms with `-TimeoutSeconds 40` and the
known stderr line `plain fallback`.

The preceding tkinter Event promotion closes the public empty event-object
constructor slice. Fresh Python 3.10.11 probes confirmed that `tkinter.Event`
has signature `()`, creates an object with an empty `__dict`, does not
predefine `widget`, `x`, `y`, `type`, or `char`, accepts normal dynamic
attribute assignment, and raises `TypeError("Event() takes no arguments")` for
extra positional arguments. The AHK surface now exposes
`stdlib.tkinter.Event()` for that covered constructor behavior while preserving
the existing internal event-binding `Event` objects used by callbacks. The
observed CPython `Event.__repr__` path, which reads unset fields and can raise
`AttributeError`, remains intentionally unclaimed until a focused slice covers
it. Fresh promotion gates include the focused red test failing at missing
`Event` in 0ms, the focused green test passing 1/1 in 15ms and follow-up
focused green passing 1/1 in 0ms after example edits,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, the full
`stdlib/tests/tkinter.test.ahk` gate at 130 passed, 0 failed, and 0 errors in
22766ms, and the aggregate `stdlib/tests` gate at 998 passed, 0 failed, and 0
errors in 32734ms with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter NoDefaultRoot promotion closes the covered default-root
support disabling slice. Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed
that `NoDefaultRoot()` has signature `()`, returns `None`, rejects extra
positional arguments with `NoDefaultRoot()` TypeError wording, clears an
existing `_default_root`, flips `_support_default_root` false, and then routes
covered implicit-default helpers to
`RuntimeError("No master specified and tkinter is configured to not support default root")`
while still allowing explicit `Tk()` construction. The focused AHK test runs
this behavior in a child process because the Python API intentionally changes
process-global default-root state. Fresh promotion gates include the focused
child-process red test failing at missing `NoDefaultRoot` in 219ms, the focused
green test passing 1/1 in 359ms and follow-up focused green passing 1/1 in
313ms after example edits, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, the full `stdlib/tests/tkinter.test.ahk` gate at 129 passed, 0
failed, and 0 errors in 22734ms, and the aggregate `stdlib/tests` gate at 997
passed, 0 failed, and 0 errors in 32375ms with `-TimeoutSeconds 40` and the
known stderr line `plain fallback`.

The preceding tkinter module-constants promotion closes the covered
non-conflicting public constant slice. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed exact values for the observed constants, including geometry (`N`,
`NE`, `NSEW`, `W`, `X`, `Y`), state (`ACTIVE`, `DISABLED`, `NORMAL`, `HIDDEN`),
selection (`SEL`, `SEL_FIRST`, `SEL_LAST`), relief/orientation/scrolling
strings, boolean-style integer aliases (`TRUE`, `FALSE`, `YES`, `NO`, `ON`,
`OFF`), and `wantobjects == 1`. The AHK surface now exposes the covered names
as module attributes while preserving the existing public constructor API.
`CHECKBUTTON` and `RADIOBUTTON` remain intentionally unclaimed because AHK
class/property lookup is case-insensitive and those uppercase Python constants
collide with the already-public `Checkbutton(...)` and `Radiobutton(...)`
constructors. Fresh promotion gates included the focused constants red test
failing at missing `ACTIVE` in 0ms, an intermediate collection failure that
proved the `CHECKBUTTON` name collision, the narrowed focused constants green
test passing 1/1 in 0ms and follow-up focused green passing 1/1 in 16ms after
example edits, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, the
full `stdlib/tests/tkinter.test.ahk` gate at 128 passed, 0 failed, and 0
errors in 22125ms, and the aggregate `stdlib/tests` gate at 996 passed, 0
failed, and 0 errors in 31953ms with `-TimeoutSeconds 40` and the known stderr
line `plain fallback`.

The preceding tkinter module numeric-alias promotion closes the covered
module-level `getint()` / `getdouble()` slice. Fresh Python 3.10.11 probes on
Tk 8.6.12 confirmed that `tkinter.getint` is `int`, `tkinter.getdouble` is
`float`, and `tkinter.getboolean` remains a separate `(s)` function. The
covered AHK surface now matches the no-default-root Python alias behavior for
no-arg defaults, whitespace/sign handling, decimal `"09"` parsing, bool and
float inputs, and Python 3.10.11 `ValueError` / `TypeError` text for the
covered invalid inputs. Existing Tcl-backed `Tcl()` / `Tk` / widget
`getint()` and `getdouble()` conversions remain intentionally unchanged: for
example, the instance path still accepts Tcl hexadecimal integer strings and
preserves Tcl's `"09"` invalid-octal diagnostics. The two-argument
`int(x, base)` form, bytes-like inputs, and custom coercion protocols remain
unclaimed for a later focused slice. Fresh promotion gates include
the focused module-alias red test failing at missing `HasMethod` in 0ms, the
focused green test passing 1/1 in 0ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, the adjacent Tcl-backed numeric
conversion guard passing 1/1 in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 127 passed, 0 failed, and 0 errors in
22281ms, and the aggregate `stdlib/tests` gate at 995 passed, 0 failed, and 0
errors in 32437ms with `-TimeoutSeconds 40` and the known stderr line `plain
fallback`.

The preceding tkinter menu-tk-popup promotion closes the safe non-posting slice
of `Menu.tk_popup(x, y, entry='')`. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed that `tk_popup` is owned by `Menu` only, has signature
`(self, x, y, entry='')`, delegates to `self.tk.call('tk_popup', self._w, x, y,
entry)`, and produces Python 3.10.11 TypeError text for missing and extra
positional arguments plus TclError text for bad coordinate and bad-entry
values. The probe also showed that posting a real popup can block unattended
automation on this host, so this promotion intentionally claims only owner,
arity, and immediate Tcl validation behavior, not live popup posting. Fresh
promotion gates included the focused Menu command-entry red test failing at
missing `HasMethod` in 188ms, the focused green test at 1 passed in 469ms with
a follow-up focused confirmation at 1 passed in 422ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 126 passed, 0 failed, and 0
errors in 22157ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 994 passed, 0 failed, and 0 errors in
31797ms with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The earlier tkinter report-callback-exception promotion closes the root-level
custom callback exception reporter slice for `Tk.report_callback_exception()`.
Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed that
`report_callback_exception(self, exc, val, tb)` is owned by `Tk`, not `Misc`,
`BaseWidget`, or `Widget`; that missing and extra positional TypeError text
matches `Tk.report_callback_exception()`; and that CPython `CallWrapper`
routes widget command exceptions to `root.report_callback_exception(exc, val,
tb)` while the widget command returns the Python-observed `"None"` Tcl result.
The AHK promotion covers the same root override routing shape for registered
widget command callbacks by forwarding the AHK error type, value, and traceback
to the root override. CPython's default `sys.stderr` print and `sys.last_*`
side effects were observed in the probe but remain intentionally unpromoted
until they receive their own probe, failing test, fix, gate, and documentation
evidence. Fresh promotion gates include the focused report-callback red test
failing at missing `HasMethod` in 156ms, the focused green test at 1 passed in
172ms, serial callback-adjacent confirmations for `ButtonCommand` at 1 passed
in 406ms, `RegisterAndDeletecommand` at 1 passed in 141ms, `VariableTrace` at
1 passed in 15ms, and `WidgetBind` at 1 passed in 250ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 126 passed, 0 failed, and 0 errors in
21984ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 994 passed, 0 failed, and 0 errors in 32234ms
with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter readprofile promotion closes the Tcl profile-file sourcing
slice of `Tk.readprofile(baseName, className)` for `Tk()` roots. Fresh Python
3.10.11 probes on Tk 8.6.12 confirmed the `Tk.readprofile(self, baseName,
className)` signature, the CPython source lookup order of
`$HOME/.{className}.tcl`, `$HOME/.{className}.py`, `$HOME/.{baseName}.tcl`,
and `$HOME/.{baseName}.py`, Python `None` returns, no-op behavior when files
are missing, missing/extra positional TypeError text, and TclError propagation
when a sourced Tcl profile contains an invalid command. This promotion
intentionally claims only `.tcl` profile sourcing; the observed `.py` execution
path remains unpromoted until it receives its own probe, failing test, fix,
gate, and documentation evidence. Fresh promotion gates include the focused
readprofile red test failing at missing `HasMethod` in 641ms, the focused
green test at 1 passed in 844ms with a follow-up focused confirmation at 1
passed in 922ms after example edits, the full `stdlib/tests/tkinter.test.ahk`
gate at 125 passed, 0 failed, and 0 errors in 23438ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the aggregate
`stdlib/tests` gate at 993 passed, 0 failed, and 0 errors in 32469ms with
`-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter loadtk promotion closes the Tk-specific `loadtk()` method
gap on both already loaded `Tk()` roots and `Tcl()` interpreters created with
`useTk=False`. Fresh Python 3.10.11 probes confirmed `Tk.loadtk(self)`, the
CPython source guard that calls `self.tk.loadtk()` and `_loadtk()` only when
`_tkloaded` is false, no-op Python `None` returns for already loaded roots,
`Tcl()` interpreter `info commands winfo` changing from `''` before `loadtk()`
to `'winfo'` after loading, `package require Tk` returning `8.6.12`, repeated
`loadtk()` calls returning Python `None`, and extra-positional TypeError text.
Fresh promotion gates include the focused loadtk red test failing at missing
`HasMethod` in 78ms, the focused green test at 1 passed in 140ms with a
follow-up focused confirmation at 1 passed in 172ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 124 passed, 0 failed, and 0
errors in 21344ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 992 passed, 0 failed, and 0 errors in
31.407 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-iconphoto promotion closes the `Tk` / `Toplevel`
`iconphoto(default=False, *args)` / `wm_iconphoto(default=False, *args)` alias
gap in the window-manager surface. Fresh Python 3.10.11 probes on Tk 8.6.12
confirmed the `Wm.wm_iconphoto(self, default=False, *args)` signature,
`iconphoto` / `wm_iconphoto` alias identity, root and toplevel method
ownership, and the CPython source branch that forwards `-default` only when
`default` is truthy and otherwise directly forwards the image arguments.
Observed local behavior includes success returning Python `None` for root and
toplevel calls, multiple `PhotoImage` arguments, truthy non-bool defaults using
the `-default` branch, falsey `None` defaults not using that branch, first
`None` truncation in the photo argument list, TclError text for missing photo
arguments, and TclError text for non-photo image names/integers. Fresh
promotion gates include the focused wm-iconphoto red test failing at missing
`HasMethod` in 172ms, the focused green test at 1 passed in 1703ms with a
follow-up focused confirmation at 1 passed in 218ms after example edits, the
full `stdlib/tests/tkinter.test.ahk` gate at 123 passed, 0 failed, and 0
errors in 21453ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 991 passed, 0 failed, and 0 errors in
32.391 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-attributes promotion closes the `Tk` / `Toplevel`
`attributes(*args)` / `wm_attributes(*args)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes on Tk 8.6.12 confirmed the
`Wm.wm_attributes(self, *args)` signature, `attributes` / `wm_attributes`
alias identity, root and toplevel method ownership, and the CPython source
shape that forwards `('wm', 'attributes', self._w) + args` directly to
`tk.call`. Observed local behavior includes the Windows platform attribute
tuple `('-alpha', 1.0, '-transparentcolor', '', '-disabled', 0, '-fullscreen',
0, '-toolwindow', 0, '-topmost', 0)`, single-option getters returning typed
values such as `-alpha` as `1.0` / `0.75` floats and `-topmost` /
`-disabled` as integer flags, setter calls returning an empty string, and
TclError parity for unknown attributes, bad alpha values, missing dash option
names, and odd setter argument counts. Fresh promotion gates include the
focused wm-attributes red test failing at missing `HasMethod` in 172ms, the
focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 122 passed, 0 failed, and 0 errors in
21000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 990 passed, 0 failed, and 0 errors in 31.000
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-manage-forget promotion closes the `Tk` / `Toplevel`
`manage(widget)` / `wm_manage(widget)` and `forget(window)` /
`wm_forget(window)` alias gaps in the window-manager surface. Fresh Python
3.10.11 probes confirmed the `Wm.wm_manage(self, widget)` and
`Wm.wm_forget(self, window)` signatures, `manage` / `wm_manage` and `forget` /
`wm_forget` alias identities, root and toplevel method ownership, Python `None`
returns from both source methods, Frame-to-standalone top-level management with
`winfo manager` becoming `wm` and `wm state` becoming `normal`, forget returning
the frame to unmanaged state without destroying it, object and string-path
argument conversion, missing-window-path TclError text, missing-argument
TypeError text, extra-positional TypeError text, and the Python MRO detail that
`Toplevel.forget` resolves to `Wm.wm_forget` rather than the widget layout
`forget()` alias. Fresh promotion gates include the focused wm-manage-forget red
test failing at missing `HasMethod` in 187ms, the focused green test at 1 passed
in 172ms, the full `stdlib/tests/tkinter.test.ahk` gate at 121 passed, 0 failed,
and 0 errors in 20625ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 989 passed, 0 failed, and
0 errors in 31.907 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-iconbitmap promotion closes the `Tk` / `Toplevel`
`iconbitmap(bitmap=None, default=None)` /
`wm_iconbitmap(bitmap=None, default=None)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconbitmap(self, bitmap=None, default=None)` signature, `iconbitmap` /
`wm_iconbitmap` alias identity, root and toplevel method ownership, empty
initial getter strings, `None` preserving read semantics, built-in bitmap setter
empty-string returns, getter bitmap names after assignment, truthy `default`
branch `-default` behavior, falsey-default getter fallback, two-positional
default-wins behavior, empty-string clearing, undefined-bitmap TclError text,
and extra-positional TypeError text. Fresh promotion gates include the focused
wm-iconbitmap red test failing at missing `HasMethod` in 172ms, the focused
green test at 1 passed in 172ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 120 passed, 0 failed, and 0 errors in 20859ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
988 passed, 0 failed, and 0 errors in 31.141 seconds with `-TimeoutSeconds 40`
and the known stderr line `plain fallback`.

The preceding tkinter wm-iconmask promotion closes the `Tk` / `Toplevel`
`iconmask(bitmap=None)` / `wm_iconmask(bitmap=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconmask(self, bitmap=None)` signature, `iconmask` / `wm_iconmask`
alias identity, root and toplevel method ownership, empty initial getter
strings, `None` preserving read semantics, built-in bitmap setter empty-string
returns, getter bitmap names after assignment, empty-string clearing,
undefined-bitmap TclError text, and extra-positional TypeError text. Fresh
promotion gates include the focused wm-iconmask red test failing at missing
`HasMethod` in 188ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 119 passed, 0 failed, and 0 errors in
20828ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 987 passed, 0 failed, and 0 errors in 30.609
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconwindow promotion closes the `Tk` / `Toplevel`
`iconwindow(pathName=None)` / `wm_iconwindow(pathName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconwindow(self, pathName=None)` signature, `iconwindow` /
`wm_iconwindow` alias identity, root and toplevel method ownership, empty
initial getter strings, `None` preserving read semantics, object and string
path setter empty-string returns, getter path strings after iconwindow
assignment, empty-string clearing, non-top-level widget TclError text,
missing-window-path TclError text, and extra-positional TypeError text. Fresh
promotion gates include the focused wm-iconwindow red test failing at missing
`HasMethod` in 172ms, the focused green test at 1 passed in 157ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 118 passed, 0 failed, and 0 errors in
20750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 986 passed, 0 failed, and 0 errors in 31.187
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconposition promotion closes the `Tk` / `Toplevel`
`iconposition(x=None, y=None)` / `wm_iconposition(x=None, y=None)` alias gap in
the window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconposition(self, x=None, y=None)` signature, `iconposition` /
`wm_iconposition` alias identity, root and toplevel method ownership, initial
getter `None`, explicit `iconposition(None, None)` read semantics, two-integer
tuple getter state after setter calls, first-`None` argument truncation
preserving read semantics, empty-string clearing back to `None`, one-argument
TclError text, bad-integer TclError text, and extra-positional TypeError text.
Fresh promotion gates include the focused wm-iconposition red test failing at
missing `HasMethod` in 172ms, the focused green test at 1 passed in 156ms, the
full `stdlib/tests/tkinter.test.ahk` gate at 117 passed, 0 failed, and 0 errors
in 20516ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 985 passed, 0 failed, and 0 errors in 31.235
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-colormapwindows promotion closes the `Tk` / `Toplevel`
`colormapwindows(*wlist)` / `wm_colormapwindows(*wlist)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_colormapwindows(self, *wlist)` source shape, `colormapwindows` /
`wm_colormapwindows` alias identity, root and toplevel method presence, empty
getter list semantics, getter conversion from Tcl paths into widget objects,
single widget-object setter `None` returns, multi-window setter `None`
returns, AHK-array/list-style setter behavior matching Python list argument
conversion, `None` and empty-string clearing, string path setter handling,
literal `"None"` and missing-path TclError text. Fresh promotion gates include
the focused wm-colormapwindows red test failing at missing `HasMethod` in
172ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 116 passed, 0 failed, and 0 errors in
12468ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 984 passed, 0 failed, and 0 errors in 22.671
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-command promotion closes the `Tk` / `Toplevel`
`command(value=None)` / `wm_command(value=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_command(self, value=None)` signature, `command` / `wm_command` alias
identity, root and toplevel method presence, empty-string initial reads,
`None` preserving read semantics, string setter empty-string returns,
AHK array setter Tcl-list quoting such as `cmd {arg one}`, empty-string
clearing, and extra-positional TypeError text. Fresh promotion gates include
the focused wm-command red test failing at missing `HasMethod` in 157ms, the
focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 115 passed, 0 failed, and 0 errors in
11688ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 983 passed, 0 failed, and 0 errors in 22.578
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-group promotion closes the `Tk` / `Toplevel`
`group(pathName=None)` / `wm_group(pathName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_group(self, pathName=None)` signature, `group` / `wm_group` alias
identity, root and toplevel method presence, empty-string initial reads,
`None` preserving read semantics, widget-object and string-path setter
empty-string returns, getter path strings after group assignment, empty-string
clearing, invalid-window-path TclError text, and extra-positional TypeError
text. Fresh promotion gates include the focused wm-group red test failing at
missing `HasMethod` in 188ms, the focused green test at 1 passed in 156ms, the
full `stdlib/tests/tkinter.test.ahk` gate at 114 passed, 0 failed, and 0
errors in 11750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 982 passed, 0 failed, and 0 errors in
22.266 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-grid promotion closes the `Tk` / `Toplevel`
`grid(baseWidth=None, baseHeight=None, widthInc=None, heightInc=None)` /
`wm_grid(...)` alias gap in the window-manager surface, including the Python
MRO detail that `Tk.grid` and `Toplevel.grid` resolve to `Wm.wm_grid` rather
than the ordinary widget geometry-manager `grid()` method. Fresh Python 3.10.11
probes confirmed the `Wm.wm_grid(self, baseWidth=None, baseHeight=None,
widthInc=None, heightInc=None)` signature, `grid` / `wm_grid` alias identity,
root and toplevel method presence, unset getter `None`, 4-integer tuple getter
state after setter calls, `_tkinter.tk.call` first-`None` argument truncation,
empty-string clearing, partial-argument TclError text, invalid integer TclError
text, and extra-positional TypeError text. Fresh promotion gates include the
focused wm-grid red test failing at missing `HasMethod` in 156ms, the focused
green test at 1 passed in 172ms, the full `stdlib/tests/tkinter.test.ahk`
gate at 113 passed, 0 failed, and 0 errors in 12203ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
981 passed, 0 failed, and 0 errors in 22.312 seconds with `-TimeoutSeconds 40`
and the known stderr line `plain fallback`.

The preceding tkinter wm-aspect promotion closes the `Tk` / `Toplevel`
`aspect(minNumer=None, minDenom=None, maxNumer=None, maxDenom=None)` /
`wm_aspect(...)` alias gap in the window-manager surface. Fresh Python 3.10.11
probes confirmed the `Wm.wm_aspect(self, minNumer=None, minDenom=None,
maxNumer=None, maxDenom=None)` signature, `aspect` / `wm_aspect` alias
identity, root and toplevel method presence, unset getter `None`, 4-integer
tuple getter state after setter calls, `_tkinter.tk.call` first-`None` argument
truncation, empty-string clearing, partial-argument TclError text, invalid
integer TclError text, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-aspect red test failing at missing `HasMethod` in
156ms, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 112 passed, 0 failed, and 0 errors in
12000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 980 passed, 0 failed, and 0 errors in 22.297
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-client promotion closes the `Tk` / `Toplevel`
`client(name=None)` / `wm_client(name=None)` alias gap in the window-manager
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_client(self, name=None)` signature, `client` / `wm_client` alias
identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, string setter empty-string returns,
empty-string clearing, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-client red test failing at missing `HasMethod` in
313ms, the focused green test at 1 passed in 281ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 111 passed, 0 failed, and 0 errors in
11859ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 979 passed, 0 failed, and 0 errors in 22.219
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-iconname promotion closes the `Tk` / `Toplevel`
`iconname(newName=None)` / `wm_iconname(newName=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_iconname(self, newName=None)` signature, `iconname` / `wm_iconname`
alias identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, string setter empty-string returns,
empty-string clearing, and extra-positional TypeError text. Fresh promotion
gates include the focused wm-iconname red test failing at missing `HasMethod`
in 282ms, the focused green test at 1 passed in 235ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 110 passed, 0 failed, and 0 errors in
11375ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 978 passed, 0 failed, and 0 errors in 21.860
seconds with `-TimeoutSeconds 40` and the known stderr line `plain fallback`.

The preceding tkinter wm-sizefrom promotion closes the `Tk` / `Toplevel`
`sizefrom(who=None)` / `wm_sizefrom(who=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_sizefrom(self, who=None)` signature, `sizefrom` / `wm_sizefrom` alias
identity, root and toplevel method presence, initial empty-string reads,
`None` preserving read semantics, user/program setter empty-string returns,
empty-string clearing, and invalid-value TclError plus extra-positional
TypeError text. Fresh promotion gates include the focused wm-sizefrom red test
failing at missing `HasMethod` in 235ms, the focused green test at 1 passed in
219ms, the full `stdlib/tests/tkinter.test.ahk` gate at 109 passed, 0 failed,
and 0 errors in 11391ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 977 passed, 0 failed, and 0
errors in 21.516 seconds with `-TimeoutSeconds 40` and the known stderr line
`plain fallback`.

The preceding tkinter wm-positionfrom promotion closes the `Tk` / `Toplevel`
`positionfrom(who=None)` / `wm_positionfrom(who=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_positionfrom(self, who=None)` signature, `positionfrom` /
`wm_positionfrom` alias identity, root and toplevel method presence, initial
empty-string reads, `None` preserving read semantics, user/program setter
empty-string returns, empty-string clearing, and invalid-value TclError plus
extra-positional TypeError text. Fresh promotion gates include the focused
wm-positionfrom red test failing at missing `HasMethod` in 234ms, the focused
green test at 1 passed in 234ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 108 passed, 0 failed, and 0 errors in 11125ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
976 passed, 0 failed, and 0 errors in 21.563 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter wm-focusmodel promotion closes the `Tk` / `Toplevel`
`focusmodel(model=None)` / `wm_focusmodel(model=None)` alias gap in the
window-manager surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_focusmodel(self, model=None)` signature, `focusmodel` /
`wm_focusmodel` alias identity, root and toplevel method presence, default
`passive` reads, `None` preserving read semantics, active/passive setter empty
string returns, and invalid-value TclError plus extra-positional TypeError
text. Fresh promotion gates include the focused wm-focusmodel red test failing
at missing `HasMethod` in 266ms, the focused green test at 1 passed in 250ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 107 passed, 0 failed, and 0
errors in 11235ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and
the aggregate `stdlib/tests` gate at 975 passed, 0 failed, and 0 errors in
21.688 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter wm-frame promotion closes the `Tk` / `Toplevel`
`frame()` / `wm_frame()` native-frame query gap in the window-manager surface.
Fresh Python 3.10.11 probes confirmed the `Wm.wm_frame(self)` signature,
`frame` / `wm_frame` alias identity, root and toplevel method presence,
platform-specific non-empty string handle returns, alias-equivalent return
values, distinct root/toplevel frame handles on the local runtime, and
extra-positional TypeError text. Fresh promotion gates include the focused
wm-frame red test failing at missing `HasMethod` in 297ms, the focused green
test at 1 passed in 266ms with a 250ms PASS entry, the full
`stdlib/tests/tkinter.test.ahk` gate at 106 passed, 0 failed, and 0 errors in
10954ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 974 passed, 0 failed, and 0 errors in 21.203
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-iconify promotion closes the `Tk` / `Toplevel`
`wm_iconify()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_iconify(self)` signature,
`iconify` / `wm_iconify` alias identity, root and toplevel method presence,
empty-string return values, `normal` to `iconic` state transitions,
`withdrawn` to `iconic` state restoration, viewable/mapped state after
iconification, and extra-positional TypeError text. Fresh promotion gates
include the focused wm-iconify red test failing at missing `HasMethod` in
203ms, the focused green test at 1 passed in 468ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 105 passed, 0 failed, and 0 errors in
10844ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 973 passed, 0 failed, and 0 errors in 21.515
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-deiconify promotion closes the `Tk` / `Toplevel`
`wm_deiconify()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_deiconify(self)` signature,
`deiconify` / `wm_deiconify` alias identity, root and toplevel method presence,
empty-string return values, `withdrawn` to `normal` state restoration, and
extra-positional TypeError text. Fresh promotion gates include the focused
wm-deiconify red test failing at missing `HasMethod` in 250ms, the focused
green test at 1 passed in 219ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 104 passed, 0 failed, and 0 errors in 10594ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
972 passed, 0 failed, and 0 errors in 21.234 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter wm-withdraw promotion closes the `Tk` / `Toplevel`
`wm_withdraw()` alias gap in the window-manager lifecycle surface. Fresh
Python 3.10.11 probes confirmed the `Wm.wm_withdraw(self)` signature,
`withdraw` / `wm_withdraw` alias identity, root and toplevel method presence,
empty-string return values, `normal` to `withdrawn` state transitions, clean
`deiconify()` restoration to `normal`, and extra-positional TypeError text.

The preceding tkinter wm-state promotion closes the `Tk` / `Toplevel`
`wm_state(newstate=None)` alias gap in the window-manager lifecycle surface.
Fresh Python 3.10.11 probes confirmed the `Wm.wm_state(self, newstate=None)`
signature, `state` / `wm_state` alias identity, root and toplevel method
presence, no-arg and `None` reads returning the current state string, setters
returning an empty string while transitioning between `normal` and
`withdrawn`, extra-positional TypeError text, and bad state TclError text.
Fresh promotion gates include the focused wm-state red test failing at missing
`HasMethod` in 422ms, the focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 102 passed, 0 failed, and 0 errors in
10344ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 970 passed, 0 failed, and 0 errors in 21.578
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-maxsize promotion closes the `Tk` / `Toplevel`
`wm_maxsize(width=None, height=None)` alias gap in the window-manager
maximum-size surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_maxsize(self, width=None, height=None)` signature, `maxsize` /
`wm_maxsize` alias identity, root and toplevel method presence, no-arg reads
returning the current platform maximum-size tuple, setters returning `None`,
bool arguments coercing through Tcl to integer/platform maximum-size state,
leading `None` behaving as a read for `wm_maxsize(None)`,
`wm_maxsize(None, None)`, and `wm_maxsize(None, 1)`, one-argument and
trailing-`None` calls preserving the Tcl wrong-args path, extra-positional
TypeError text, and bad integer TclError text. Fresh promotion gates include
the focused wm-maxsize red test failing at missing `HasMethod` in 156ms, the
focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 101 passed, 0 failed, and 0 errors in
10391ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 969 passed, 0 failed, and 0 errors in 20.625
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-minsize promotion closes the `Tk` / `Toplevel`
`wm_minsize(width=None, height=None)` alias gap in the window-manager
minimum-size surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_minsize(self, width=None, height=None)` signature, root and toplevel
method presence, no-arg reads returning a two-integer tuple, setters returning
`None`, bool arguments coercing to integers, leading `None` behaving as a read
for `wm_minsize(None)`, `wm_minsize(None, None)`, and `wm_minsize(None, 1)`,
one-argument and trailing-`None` calls preserving the Tcl wrong-args path,
extra-positional TypeError text, and bad integer TclError text. Fresh
promotion gates include the focused wm-minsize red test failing at missing
`HasMethod`, the focused green test at 1 passed in 172ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 100 passed, 0 failed, and 0 errors in
10468ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 968 passed, 0 failed, and 0 errors in 20.328
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-resizable promotion closes the `Tk` / `Toplevel`
`wm_resizable(width=None, height=None)` alias gap in the window-manager
resizable surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_resizable(self, width=None, height=None)` signature, root and toplevel
method presence, no-arg reads returning a two-integer tuple, two-argument
setters returning an empty string, leading `None` behaving as a read for
`wm_resizable(None)`, `wm_resizable(None, None)`, and
`wm_resizable(None, True)`, trailing `None` preserving the Tcl wrong-args path,
extra-positional TypeError text, and bad boolean TclError text. Fresh promotion
gates include the focused wm-resizable red test failing at missing `HasMethod`,
the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 99 passed, 0 failed, and 0 errors in
10375ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 967 passed, 0 failed, and 0 errors in 21.094
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-geometry promotion closes the `Tk` / `Toplevel`
`wm_geometry(newGeometry=None)` alias gap in the window-manager geometry
surface. Fresh Python 3.10.11 probes confirmed the
`Wm.wm_geometry(self, newGeometry=None)` signature, root and toplevel method
presence, no-arg geometry reads, geometry setters returning an empty string,
`None` behaving as an omitted argument for both `geometry(None)` and
`wm_geometry(None)`, stable visible-window geometry readback after
`update_idletasks()` / `update()`, extra-positional TypeError text, and bad
geometry TclError text of `bad geometry specifier "bad"`. Fresh promotion
gates include the focused wm-geometry red test failing at missing `HasMethod`,
the focused green test at 1 passed in 281ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 98 passed, 0 failed, and 0 errors in
9734ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 966 passed, 0 failed, and 0 errors in 20.391
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter wm-title promotion closes the `Tk` / `Toplevel`
`wm_title(string=None)` alias gap in the window-manager title surface. A fresh
Python 3.10.11 probe under withdrawn roots confirmed the
`Wm.wm_title(self, string=None)` signature, root and toplevel method presence,
no-arg title reads, string setters returning an empty string, `None` behaving
as an omitted argument for both `title(None)` and `wm_title(None)`, already
created toplevel windows retaining their own title after a root title change,
and the extra-positional TypeError text
`Wm.wm_title() takes from 1 to 2 positional arguments but 3 were given`.
Fresh promotion gates include the focused wm-title red test failing at missing
`HasMethod`, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 97 passed, 0 failed, and 0 errors in
10343ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 965 passed, 0 failed, and 0 errors in 21.219
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter selection-handle promotion closes the root/widget inherited
`selection_handle(command, **kw)` gap in the Misc selection callback surface. A
fresh Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.selection_handle(self, command, **kw)` signature, root and widget method
presence, calls returning `None`, callbacks being invoked by `selection_get()`
with string offset/length arguments of `"0"` and `"4000"`, `type='STRING'`
option forwarding, non-callable command names being accepted at registration
time, missing-command and extra-positional TypeError text, and bad option
TclError text of `bad option "-bad": must be -format, -selection, or -type`.
Fresh promotion gates include the focused selection-handle red test failing at
missing `HasMethod`, the focused green test at 1 passed in 140ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 96 passed, 0 failed, and 0 errors in
9875ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 964 passed, 0 failed, and 0 errors in 22.344
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter send promotion closes the root/widget inherited `send()`
gap in the Misc Tcl command-forwarding surface. A fresh Python 3.10.11 probe
under a withdrawn root confirmed the `Misc.send(self, interp, cmd, *args)`
signature, root and widget method presence, missing-interp/cmd TypeError text,
the local Tk absence of an intrinsic Tcl `send` command raising
`invalid command name "send"`, and successful argument forwarding/return values
when a Tcl `send` proc is installed, including Tcl list quoting for arguments
with spaces. Fresh promotion gates include the focused send red test failing at
missing `HasMethod`, the focused green test at 1 passed in 156ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 95 passed, 0 failed, and 0 errors in
12063ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 963 passed, 0 failed, and 0 errors in 20.406
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter set-palette promotion closes the root/widget inherited
`tk_setPalette()` gap in the palette-management surface. A fresh Python 3.10.11
probe under a withdrawn root confirmed the `Misc.tk_setPalette(self, *args,
**kw)` signature, root and widget method presence, valid calls returning
`None`, positional background colors updating existing root/widget backgrounds,
keyword option/value pairs updating background and foreground defaults, the
Python source flattening kwargs as dashless Tcl `option value` pairs, no-arg and
two-positional TclError text of `must specify a background color`, and bad color
TclError text of `unknown color name "notacolor"`. Fresh promotion gates include
the focused set-palette red test failing at missing `HasMethod`, the focused
green test at 1 passed in 234ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 94 passed, 0 failed, and 0 errors in 11109ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the aggregate
`stdlib/tests` gate at 962 passed, 0 failed, and 0 errors in 20.594 seconds with
`-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter global-grab promotion closes the root/widget inherited
`grab_set_global()` gap in the grab modal-state surface. A fresh Python 3.10.11
probe under a withdrawn root confirmed the `Misc.grab_set_global(self)`
signature, root and widget method presence, calls returning `None`,
`grab_current()` pointing to the caller, the caller `grab_status()` becoming
`global`, non-caller `grab_status()` returning `None`, and the observed
`Misc.grab_set_global() takes 1 positional argument but 2 were given`
TypeError text. Fresh promotion gates include the focused global-grab red test
failing at missing `HasMethod`, the focused green test at 1 passed in 235ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 93 passed, 0 failed, and
0 errors in 11766ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
and the aggregate `stdlib/tests` gate at 961 passed, 0 failed, and 0 errors in
20.860 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter bell promotion closes the root/widget inherited
`bell(displayof=0)` gap in the Misc display routing surface. A fresh Python
3.10.11 probe under a withdrawn root confirmed the `Misc.bell(self,
displayof=0)` signature, root and widget method presence, default, `None`,
`0`, root, and widget display targets returning `None`, bad string display
targets raising `bad window path name "bad"`, and the observed
`Misc.bell() takes from 1 to 2 positional arguments but 3 were given`
TypeError text. Fresh promotion gates include the focused bell red test
failing at missing `HasMethod`, the focused green test at 1 passed in 188ms,
the full `stdlib/tests/tkinter.test.ahk` gate at 92 passed, 0 failed, and
0 errors in 18000ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing,
and the aggregate `stdlib/tests` gate at 960 passed, 0 failed, and 0 errors in
28.656 seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr
line.

The preceding tkinter focus-follows-mouse promotion closes the root/widget
inherited `tk_focusFollowsMouse()` gap in the focus-management surface. A fresh
Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.tk_focusFollowsMouse(self)` signature, root and widget calls returning
`None`, and the observed
`Misc.tk_focusFollowsMouse() takes 1 positional argument but 2 were given`
TypeError text. Fresh promotion gates include the focused focus-follows-mouse
red test failing at missing `HasMethod`, the focused green test at 1 passed in
218ms, the full `stdlib/tests/tkinter.test.ahk` gate at 91 passed, 0 failed,
and 0 errors in 18375ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the aggregate `stdlib/tests` gate at 959 passed, 0 failed, and
0 errors in 28.922 seconds with `-TimeoutSeconds 40` and the known
`plain fallback` stderr line.

The preceding tkinter command-registration promotion closes the root/widget
inherited callable `register()` and `deletecommand()` gap for Tcl command
callbacks. A fresh Python 3.10.11 probe under a withdrawn root confirmed the
`Misc.register(func, subst=None, needcleanup=1)` and `Misc.deletecommand(name)`
signatures, string command-name returns, Tcl argument delivery into the Python
callback, root and widget registration, `deletecommand()` returning `None`,
registered command removal from `info commands`, invalid-command behavior after
delete, second-delete `can't delete Tcl command` errors, and the observed
missing/extra positional TypeError text. Fresh promotion gates include the
focused register/delete red test failing at missing `HasMethod`, the focused
green test at 1 passed in 188ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 89 passed, 0 failed, and 0 errors in 9625ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
957 passed, 0 failed, and 0 errors in 20.781 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter strict-Motif promotion closes the root/widget inherited
`tk_strictMotif(boolean=None)` gap in the Misc Tcl-boolean surface. A fresh
Python 3.10.11 probe under a withdrawn root confirmed the signature, initial
`False` root and widget queries, `True` / `False` returns when setting from
root or child widgets, shared `tk_strictMotif` Tcl variable state, `None` as a
query rather than a set operation, accepted integer/string boolean spellings,
the bad-boolean TclError text, and the extra-positional TypeError text. Fresh
promotion gates include the focused strict-Motif red test failing at missing
`HasMethod`, the focused green test at 1 passed in 344ms, the full
`stdlib/tests/tkinter.test.ahk` gate at 88 passed, 0 failed, and 0 errors in
10031ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 956 passed, 0 failed, and 0 errors in 22.703
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.

The preceding tkinter focus-lastfor promotion closes the root/widget inherited
`focus_lastfor()` gap in the focus-management surface. Fresh Python 3.10.11
probes confirmed the `Misc.focus_lastfor(self)` signature, initial Tk-root
return for root and child widgets, last-for migration to the focused Entry and
Button after `focus_force()` plus update, retention of the last focused Button
after `withdraw()` makes `focus_get()` return `None`, and the observed
`Misc.focus_lastfor() takes 1 positional argument but 2 were given` TypeError
text for root and widget extra arguments. Fresh promotion gates include the
focused `focus_lastfor` red test failing at missing `HasMethod`, the focused
green test at 1 passed in 484ms, the full `stdlib/tests/tkinter.test.ahk` gate
at 87 passed, 0 failed, and 0 errors in 13641ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
955 passed, 0 failed, and 0 errors in 36.062 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line.

The preceding tkinter variable-access promotion closes the Tk-backed widget
inherited `getvar()` / `setvar()` gap beside the already covered root variable
surface. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed
that widget `getvar()` reads root-created Tcl variables, widget `setvar()`
creates variables visible from the root, `None` stores as the string `"None"`,
the default single-argument `setvar()` value is `"1"`, a missing widget variable
raises the observed TclError text, and missing/extra positional arguments keep
the observed `Misc.setvar()` / `Misc.getvar()` TypeError text. Fresh promotion
gates include the focused widget-variable red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 86 passed, 0 failed, and 0 errors in
14094ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 954 passed, 0 failed, and 0 errors in 28.438
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The same tkinter gate stabilization also moved the clipboard save/restore test
path to bounded best-effort retry helpers so transient Windows clipboard locks
do not mask tkinter parity failures.

The preceding tkinter menu-position promotion closes the `Menu.xposition(index)`
gap beside the already covered `Menu.yposition(index)` surface. A fresh Python
3.10.11 probe, run under a withdrawn root, confirmed the `Menu.xposition(self,
index)` signature, integer x-position returns for numeric and `"end"` indices,
`0` for the initially inactive `"active"` index, active-entry x-position after
`activate(0)`, the missing/extra positional `TypeError` text, and the bad-index
`TclError` text. Fresh promotion gates include the focused Menu xposition
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed,
0 failed, and 0 errors in 12781ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
953 passed, 0 failed, and 0 errors in 36.078 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line. The preceding tkinter selection
promotion expands the inherited-Misc selection
surface from root `selection_get()` into root/widget `selection_clear()`,
`selection_own()`, and `selection_own_get()`. A fresh Python 3.10.11 probe,
run under a withdrawn root, confirmed that a selected Entry range makes both
`root.selection_own_get()` and `entry.selection_own_get()` return the Entry,
that `root.selection_clear()` returns `None` and clears the PRIMARY owner while
leaving `entry.selection_present()` true, that `root.selection_own()` and
`entry.selection_own()` move ownership to the corresponding Tk object, and that
extra positional arguments raise the observed `Misc.selection_clear()`,
`Misc.selection_own()`, and `Misc.selection_own_get()` `TypeError` text. Fresh
promotion gates include the focused selection-ownership red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 9610ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors in 19.250
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The preceding tkinter selection promotion closed the `Tk.selection_get()`
inherited-Misc root gap. The preceding tkinter widget
event-loop promotion closes the Tk-backed widget
`mainloop()` / `quit()` inherited-Misc gap. A fresh Python 3.10.11 probe, run
under a withdrawn root, confirmed that `Label.quit()` and `Button.quit()`
return `None`, that `label.after(0, label.quit)` exits `Label.mainloop()` with
a `None` return, and that extra positional arguments raise the observed
`Misc.mainloop() takes from 1 to 2 positional arguments but 3 were given` and
`Misc.quit() takes 1 positional argument but 2 were given` `TypeError` text.
Fresh promotion gates include the focused widget-mainloop red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 15953ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
immediate aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 36.766
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The first aggregate attempt timed out at 40 seconds while running the tkinter
tail, so the passing rerun is the authoritative fresh aggregate evidence for
this slice. The preceding tkinter widget event-loop promotion closes the Tk-backed widget
`update()` / `update_idletasks()` inherited-Misc gap. A fresh Python 3.10.11
probe, run under a withdrawn root, confirmed that `Label.update()`,
`Label.update_idletasks()`, `Button.update()`, and root `update()` return
`None`, and that extra positional arguments raise the observed
`Misc.update() takes 1 positional argument but 2 were given` and
`Misc.update_idletasks() takes 1 positional argument but 2 were given`
`TypeError` text. Fresh promotion gates include the focused widget-update
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed,
0 failed, and 0 errors in 20828ms, `run-ahk-validate
stdlib/examples/tkinter.ahk` passing, and the aggregate `stdlib/tests` gate at
953 passed, 0 failed, and 0 errors in 38.906 seconds with `-TimeoutSeconds 40`
and the known `plain fallback` stderr line. The preceding tkinter focus-alias
promotion closes the `Misc.focus` /
`Misc.focus_set` alias gap on Tk roots and Tk-backed child widgets. A fresh
Python 3.10.11 probe, run under a withdrawn root, confirmed that
`tk.Misc.focus is tk.Misc.focus_set`, that `root.focus()`, `entry.focus()`,
and `button.focus()` return `None`, and that extra positional arguments raise
the observed `Misc.focus_set() takes 1 positional argument but 2 were given`
`TypeError`. Fresh promotion gates include the focused focus-alias red/green
test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed,
and 0 errors in 13468ms, `run-ahk-validate stdlib/examples/tkinter.ahk`
passing, and the immediate aggregate rerun gate at 953 passed, 0 failed, and
0 errors in 35.719 seconds with `-TimeoutSeconds 40` and the known
`plain fallback` stderr line. The first aggregate attempt timed out at 40
seconds while running the tkinter tail, so the passing rerun is the
authoritative fresh aggregate evidence for this slice. The preceding tkinter
widget event-loop promotion closes the first Tk-backed
widget `after(...)` and `after_cancel(...)` inherited-Misc gap. A fresh Python
3.10.11 probe, run under a withdrawn root, confirmed that `Label.after(0)`
returns `None`, callback-based `Label.after(0, func, *args)` returns an
`after#N` id, passes callback arguments on `update()`, cancellation through
`Label.after_cancel(id)` prevents the callback, `Label.after_cancel("missing")`
returns `None`, and the observed missing-ms, bad-ms, missing-id, and
extra-positional error text matches `Misc.after...` / `Misc.after_cancel...`.
Fresh promotion gates include the focused widget-after red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors
in 15750ms, `run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the
immediate aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 34.781
seconds with `-TimeoutSeconds 40` and the known `plain fallback` stderr line.
The first aggregate attempt timed out at 40 seconds while entering the tkinter
tail, so the passing rerun is the authoritative fresh aggregate evidence for
this slice. The preceding tkinter menu promotion closes the first
`Menu.entryconfigure(index)` / `Menu.entryconfigure(index, option)` and
`Menu.entryconfig(...)` query gap while preserving dictionary-set behavior. A
fresh Python 3.10.11 probe, run under a withdrawn root, confirmed full-query
`dict` returns, Python-style single-option tuples for command, cascade,
checkbutton, and radiobutton entries, `entryconfig(...)` alias keys, `None` returns for set
calls, label/state mutation, `underline` integer tuple values, and the observed
missing-index, extra-positional, non-dict-cnf, bad-index, bad-option, and
leading-dash-option error text. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 15625ms,
`run-ahk-validate stdlib/examples/tkinter.ahk` passing, and the immediate
aggregate rerun gate at 953 passed, 0 failed, and 0 errors in 37.734 seconds
with `-TimeoutSeconds 40` and the known `plain fallback` stderr line. The first
aggregate attempt timed out at 40 seconds while entering the tkinter tail, so
the passing rerun is the authoritative fresh aggregate evidence for this slice.
The preceding tkinter menu promotion closes the first stable `Menu.yposition(index)`
and `Menu.unpost()` gaps, plus Python-matched `Menu.post(x, y)` arity and
coordinate validation. A fresh Python 3.10.11 probe, run under a withdrawn root,
confirmed the `post(x, y)`, `unpost()`, and `yposition(index)` signatures,
`None` returns for `post(...)` / `unpost()`, integer y-position returns, withdrawn
root mapping state staying false around post/unpost, and the observed
post-missing, post-extra, invalid-coordinate, unpost-extra,
yposition-missing, yposition-extra, and bad-index errors. The AHK promotion
test covers positive `yposition(...)`, no-op `unpost()`, and the probed
`post(...)` error paths; direct positive popup posting remains deferred because
it was unstable under the 40-second aggregate gate when exercised through the
real Tk popup tracker. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 16563ms, the aggregate `stdlib/tests` gate
at 953 passed, 0 failed, and 0 errors in 38.281 seconds with `-TimeoutSeconds
40` and the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add(itemType, ...)`
gap. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed the
`(itemType, cnf={}, **kw)` signature, `None` returns for generic
command/cascade/checkbutton/radiobutton/separator additions, empty-dictionary
command creation, appended entry metadata through `entrycget(...)`, and
command/radio/checkbutton `invoke(...)` effects. The same probe preserves the
observed missing-itemType, bad-type, bad-cnf, bad-option, and extra-positional
error text. Fresh promotion gates include the focused Menu command-entry
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors in 13891ms, the aggregate `stdlib/tests` gate at 953
passed, 0 failed, and 0 errors in 22.921 seconds with `-TimeoutSeconds 40` and
the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.insert(...)` and
`Menu.insert_cascade(...)` / `Menu.insert_checkbutton(...)` /
`Menu.insert_command(...)` / `Menu.insert_radiobutton(...)` /
`Menu.insert_separator(...)` gaps. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed the `(index, itemType, cnf={}, **kw)` generic insert
signature and the `(index, cnf={}, **kw)` helper signatures, `None` returns,
generic command insertion, inserted command/cascade/radiobutton/tail/separator/
checkbutton order, empty-dictionary command and separator insertion, inserted
entry metadata through `entrycget(...)`, and command/radio/checkbutton
`invoke(...)` effects. The same probe preserves generic bad-type and missing
itemType errors, plus insert-command and insert-separator bad-cnf, bad-option,
bad-index, and extra-positional error text. Fresh promotion gates include the
focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
16547ms, the aggregate `stdlib/tests` rerun gate at 953 passed, 0 failed, and 0
errors in 36.828 seconds with `-TimeoutSeconds 40` and the known `plain
fallback` stderr line after one preceding timeout, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_checkbutton(...)`
and `Menu.add_radiobutton(...)` gaps. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed that both methods expose `(cnf={}, **kw)` signatures,
return `None`, append `checkbutton` and `radiobutton` entries, preserve label,
variable, on/off, and value options through `entrycget(...)`, and mutate their
bound variables through `invoke(...)` with the observed empty-string Tcl return.
The same probe preserves no-argument checkbutton creation, empty-dictionary
radiobutton creation, and the observed bad-cnf, bad-option, and
extra-positional error text. Fresh promotion gates include the focused Menu
command-entry red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at
85 passed, 0 failed, and 0 errors in 18578ms, the aggregate `stdlib/tests` gate
at 953 passed, 0 failed, and 0 errors in 22.656 seconds with `-TimeoutSeconds
40` and the known `plain fallback` stderr line, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_cascade(...)`
gap. A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed that
`Menu.add_cascade(cnf={}, **kw)` returns `None` for submenu-backed cascades,
no-argument calls, and empty dictionaries, appends `cascade` entries, preserves
submenu path strings through `entrycget(index, "menu")`, and preserves the
observed bad-cnf, bad-option, and extra-positional error text. Fresh promotion
gates include the focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
17234ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 33.719 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.activate(index)` gap.
A fresh Python 3.10.11 probe, run under a withdrawn root, confirmed that
`Menu.activate(index)` has a required single-index signature, returns `None`,
marks command entries as the active entry, clears active state for separator
entries and `"none"`, and preserves the observed missing-index,
extra-positional, and bad-index error text. Fresh promotion gates include the
focused Menu command-entry red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
17265ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 35.813 seconds with `-TimeoutSeconds 40` after one observed
aggregate timeout during the tkinter tail, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter menu promotion
closes the first `Menu.add_separator(...)`
and `Menu.type(index)` gap. A fresh Python 3.10.11 probe, run under a
withdrawn root, confirmed that `Menu.add_separator(cnf={}, **kw)` returns
`None` for omitted config and empty dictionaries, appends separator entries,
and preserves the observed bad-cnf, bad-option, and extra-positional error
text. The same probe confirmed that `Menu.type(index)` has a required
single-index signature, returns `""` for an empty menu's `"end"` entry, returns
`"command"` / `"separator"` strings for populated entries, and preserves the
observed missing-index, extra-positional, and bad-index errors. Fresh
promotion gates include the focused Menu command-entry red/green test, the
full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0
errors in 15875ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed,
and 0 errors in 37.750 seconds with `-TimeoutSeconds 40`, and
`run-ahk-validate stdlib/examples/tkinter.ahk` passing. The preceding tkinter
listbox promotion closes the first `Listbox.bbox(index)`
gap. A fresh Python 3.10.11 probe, run under the same withdrawn-root
condition used by the AHK gate, confirmed that `bbox(index)` has a required
single-index signature, returns a four-integer tuple for a visible row,
returns `None` for non-visible, `end`, and off-visible rows, maps `"active"`
to the active row geometry, and preserves the observed missing-index,
extra-positional, and bad-index error text. Fresh promotion gates include the
focused Listbox selection/item red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors in
9297ms, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 39.188 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first
`Text.yview_pickplace` gap. A fresh Python 3.10.11 probe, run under the same
withdrawn-root condition used by the AHK gate, confirmed that
`Text.yview_pickplace(*what)` has a varargs signature, returns `None` for a
single line/index argument, moves the visible top index to `20.0` for
`"20.0"` and to `31.0` for `"end"` in the probed 30-line text, and preserves
the observed Tcl missing-argument, bad-index, and extra-argument errors.
Fresh promotion gates include the focused Text yview-pickplace red/green test,
the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0
errors, the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0
errors in 20.046 seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first `Text` peer gap.
A fresh Python 3.10.11 probe confirmed that
`Text.peer_create(newPathName, cnf={}, **kw)` returns `None`, creates a Tk text
peer at the requested widget path, applies peer-local options such as width,
height, and wrap, and shares text-buffer edits in both directions between the
source widget and peer widget. The same probe confirmed that
`Text.peer_names()` returns an empty tuple before peers and then returns peer
path tuples in Tk order, with newer peers observed before older peers. It also
captured the probed missing-path, extra-positional, bad-option, duplicate-path,
and peer-names arity errors now covered by `stdlib/tests/tkinter.test.ahk`.
Fresh promotion gates include the focused Text peer red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, the
aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors in 38.344
seconds with `-TimeoutSeconds 40`, and `run-ahk-validate
stdlib/examples/tkinter.ahk` passing. The preceding tkinter multiline-text
promotion closes the first `Text.replace`
gap. A fresh Python 3.10.11 probe confirmed that
`Text.replace(index1, index2, chars, *tags)` returns `None`, replaces a text
range, inserts at an empty range, deletes when `chars` is empty, applies
provided tag names to inserted characters, and preserves the observed
missing-argument TypeError messages plus bad-index and reverse-range
`TclError` paths. Fresh promotion gates include the focused Text replace
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors, the aggregate `stdlib/tests` gate at 953 passed, 0
failed, and 0 errors in 34.719 seconds with `-TimeoutSeconds 40`, and
`run-ahk-validate stdlib/examples/tkinter.ahk` passing. The preceding tkinter
multiline-text promotion closes the first `Text`
embedded-window gap. A fresh Python 3.10.11 probe confirmed that
`Text.window_create(index, cnf={}, **kw)` returns `None`, embeds supplied Tk
child widgets by path, and rejects the observed missing-index,
extra-positional, bad-index, and bad-option paths. The same probe confirmed
that `Text.window_names()` returns an empty tuple before embedded windows and
then returns child path tuples in Tk order; `Text.window_cget` and
`Text.window_configure` preserve window/align string values while converting
`padx` / `pady` / `stretch` current values to integers;
`Text.window_configure(...)` returns Python-shaped option dictionaries and
five-field option tuples; `Text.window_config(...)` aliases
`window_configure(...)`; and `Text.dump(..., window=True)` reports embedded
window triples. Fresh promotion gates include the focused Text window
red/green test, the full `stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0
failed, and 0 errors, and the aggregate `stdlib/tests` gate at 953 passed, 0
failed, and 0 errors. The preceding tkinter multiline-text promotion closes
the first `Text`
embedded-image gap. A fresh Python 3.10.11 probe confirmed that
`Text.image_create(index, cnf={}, **kw)` returns the embedded image name,
reuses a supplied `PhotoImage` name for the first embedding, generates
`name#1` for a second embedding of the same image object, and rejects the
observed missing-index, extra-positional, bad-index, and bad-option paths.
The same probe confirmed that `Text.image_names()` returns `""` when no
embedded images exist and a tuple when images are present; `Text.image_cget`
and `Text.image_configure` preserve image/align string values while converting
`padx` / `pady` current values to integers; `Text.image_configure(...)`
returns Python-shaped option dictionaries and five-field option tuples; and
`Text.dump(..., image=True)` reports embedded image triples. Fresh promotion
gates include the focused Text image red/green test, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, and
the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors. The
preceding tkinter multiline-text promotion closes the first `Text` tag
configuration and tag binding gap. A fresh Python 3.10.11 probe confirmed that
`Text.tag_cget(tagName, option)` accepts both dashed and non-dashed option
names, strips trailing Python underscore aliases, and returns string option
values; `Text.tag_configure(tagName, cnf=None, **kw)` returns a Python-shaped
option dictionary for omitted config, a five-field tuple for a string option,
and `None` for mutation; `Text.tag_config(...)` aliases `tag_configure(...)`;
`Text.tag_bind(tagName, sequence, func, add=None)` requires the explicit
`func` argument, returns a tuple for all bound sequences when `sequence` is
falsey and `func` is falsey, returns the bound Tcl script for sequence queries,
and returns a command id for callable bindings; and `Text.tag_unbind(...)`
returns `None` while clearing the binding and deleting a truthy command id. The
probe also captured matching missing/extra positional TypeErrors, bad tag
option `TclError` paths, and missing-command deletion errors now covered by
`stdlib/tests/tkinter.test.ahk`. Fresh promotion gates include the isolated
HEAD red check for the new focused Text assertions, the full
`stdlib/tests/tkinter.test.ahk` gate at 85 passed, 0 failed, and 0 errors, and
the aggregate `stdlib/tests` gate at 953 passed, 0 failed, and 0 errors. The
preceding tkinter multiline-text
promotion closes the first `Text.dump`
serialization gap. A fresh Python 3.10.11 probe confirmed that
`Text.dump(index1, index2=None, command=None, **kw)` returns a list of
`(key, value, index)` tuples when no truthy command is provided, internally
uses the Tk `-command` callback path to collect triples, treats falsey `index2`
as omitted, emits default all-content triples when no true filter keyword is
present, honors true `text`, `tag`, `mark`, `all`, `image`, and `window`
filters, and returns `None` while invoking the supplied callback once for each
triple. The probe also captured matching missing-index, too-many-positional,
duplicate `index2`, duplicate `command`, unknown-option, and bad-index errors
now covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter
multiline-text promotion closes the first `Text` edit/debug
undo-stack gap. A fresh Python 3.10.11 probe confirmed that `Text.debug()`
queries the internal debug flag as a boolean, `Text.debug(boolean)` returns
`None`, `Text.edit_modified(arg=None)` queries or sets the modified flag,
`Text.edit("canundo")` / `Text.edit("canredo")` return integer flags, and
`Text.edit_separator()`, `Text.edit_undo()`, `Text.edit_redo()`, and
`Text.edit_reset()` preserve the probed Tk undo/redo stack mutation returns and
errors. The probe also captured matching `Text.debug`, `Text.edit_modified`,
`Text.edit_undo`, `Text.edit_redo`, `Text.edit_reset`, and
`Text.edit_separator` TypeError text plus Tcl bad-boolean, bad-edit-option,
wrong-arity, and empty-undo-stack errors now covered by
`stdlib/tests/tkinter.test.ahk`. The preceding tkinter multiline-text
promotion closes the first `Text` search
query gap. A fresh Python 3.10.11 probe confirmed that
`Text.search(pattern, index, stopindex=None, forwards=None, backwards=None,
exact=None, regexp=None, nocase=None, count=None, elide=None)` appends only
truthy flags, inserts `--` before patterns beginning with `-`, updates a truthy
`count` variable with the match length, returns `""` for missing matches, and
preserves the probed missing-argument, too-many-argument, unexpected-keyword,
duplicate-keyword, bad-index, and bad-regexp errors. The focused Text gate now
covers forward, stop-indexed, backward, nocase, regexp, exact, count-variable,
falsey-count, and leading-dash-pattern search behavior. The preceding tkinter
multiline-text promotion closes the first `Text` count
query gap. A fresh Python 3.10.11 probe confirmed that
`Text.count(index1, index2, *args)` auto-prefixes count options with `-`,
returns one-integer tuples for the default and single count-option forms,
returns multi-integer tuples for multiple count options, returns a bare integer
for the covered `update` plus single count-option form, preserves negative
counts for reverse index ranges, and keeps the probed missing-argument,
bad-index, and bad-option errors. The preceding tkinter multiline-text
promotion closes the first `Text` index
comparison gap. A fresh Python 3.10.11 probe confirmed that
`Text.compare(index1, op, index2)` returns Python booleans for `<`, `<=`, `==`,
`>=`, `>`, and `!=`, accepts canonical Tk text indexes such as `end`, and
preserves the probed missing-argument, extra-argument, bad-index, and
bad-operator errors. The preceding tkinter multiline-text promotion closes the
first `Text` tag-range
management gap. A fresh Python 3.10.11 probe confirmed that `Text.tag_add(...)`,
`Text.tag_remove(...)`, `Text.tag_raise(...)`, `Text.tag_lower(...)`, and
`Text.tag_delete(...)` return `None`, while `Text.tag_ranges(...)`,
`Text.tag_names(...)`, `Text.tag_nextrange(...)`, and `Text.tag_prevrange(...)`
return Python-shaped tuples including empty tuples for missing ranges. The
probe also captured matching `Text.tag_*` TypeError text plus Tcl bad-index
errors now covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter
multiline-text promotion closes the first `Text` mark
management gap. A fresh Python 3.10.11 probe confirmed that
`Text.mark_set(markName, index)`, `Text.mark_unset(*markNames)`, and missing
mark unsets return `None`, `Text.mark_gravity(markName)` returns `"left"` or
`"right"`, `Text.mark_gravity(markName, direction)` returns `""`,
`Text.mark_names()` returns a tuple of mark names, and `Text.mark_next(index)` /
`Text.mark_previous(index)` return a mark name or `None`. The probe also
captured matching `Text.mark_*` TypeError text plus Tcl bad-index, missing-mark,
and bad-gravity errors now covered by `stdlib/tests/tkinter.test.ahk`. The
preceding tkinter multiline-text promotion closed the first `Text` visual view
gap. A fresh Python 3.10.11 probe confirmed that `Text.bbox(index)` returns a
four-integer tuple for visible characters and `None` for non-visible indexes,
`Text.dlineinfo(index)` returns a five-integer tuple for visible display lines
and `None` for non-visible indexes, `Text.see(index)`,
`Text.scan_mark(x, y)`, `Text.scan_dragto(x, y)`, and mutating `xview(...)` /
`yview(...)` calls return `None`, and `Text.xview()` / `Text.yview()` return
two-float tuples. The probe also captured matching `Text.*`, `XView.*`, and
`YView.*` TypeError text plus Tcl bad-index and bad-integer errors now covered
by `stdlib/tests/tkinter.test.ahk`. The earlier tkinter list-selection
promotion closes the `Listbox` view and item configuration gap. A fresh Python
3.10.11 probe confirmed that
`Listbox.activate(index)`, `see(index)`, `scan_mark(x, y)`, `scan_dragto(x, y)`,
`selection_anchor(index)`, and the `select_*` aliases return `None`,
`nearest(y)` returns an integer index, `xview()` and `yview()` return two-float
tuples, mutating view calls return `None`, and `itemconfigure(index)` /
`itemconfigure(index, option)` return Python-shaped dict / tuple option
metadata while `itemconfigure(index, cnf)` and `itemconfig(...)` return `None`.
The probe also captured the matching `Listbox.*`, `XView.*`, `YView.*`
TypeError text and the Tcl bad-index, bad-integer, and bad-option errors now
covered by `stdlib/tests/tkinter.test.ahk`. The preceding tkinter entry-widget
promotion closes the `Entry` XView method gap. A fresh Python 3.10.11 probe
confirmed that `Entry.xview()` returns a two-float tuple, raw `xview(...)`
movement calls return `None`, `xview_moveto(fraction)` and
`xview_scroll(number, what)` preserve `XView.*` TypeError wording, and Tk still
owns bad index, bad fraction, bad number, bad unit, and wrong-arity `TclError`
messages. The earlier tkinter entry-widget promotion closed the scan method gap
for `Entry` and `Spinbox`: `Entry.scan_mark(x)` and
`Entry.scan_dragto(x)` return `None`, while `Spinbox.scan(...)`,
`Spinbox.scan_mark(x)`, and `Spinbox.scan_dragto(x)` return an empty tuple for
covered `mark` / `dragto` calls and preserve Tcl wrong-arity and invalid-x
errors.

The recent tkinter control-widget promotion closes the direct `flash()` method
gap for `Button` and `Checkbutton`. A fresh Python 3.10.11 probe confirmed that
`Button.flash()` and `Checkbutton.flash()` return `None` with no arguments and
raise `TypeError("<Class>.flash() takes 1 positional argument but 2 were given")`
for an extra positional argument, matching the already covered `Radiobutton`
shape.

The latest tkinter module-level numeric-alias promotion adds
`stdlib.tkinter.getint()` and `stdlib.tkinter.getdouble()` behavior. A fresh
Python 3.10.11 probe confirmed these are aliases for Python `int` and `float`,
not default-root Tcl conversion helpers, so the covered AHK surface now accepts
no default root, returns `0` / `0.0` with no arguments, parses signed and padded
decimal strings such as `"09"` through Python rules, truncates float input for
`getint`, maps bool input to numeric `1` / `0`, and preserves the observed
`ValueError` / `TypeError` text for the covered invalid inputs. The
two-argument `int(x, base)` form, bytes-like inputs, and custom coercion
protocols remain unclaimed.

The preceding tkinter module-level promotion adds default-root-backed
`stdlib.tkinter.getboolean(s)` behavior. A fresh Python 3.10.11 probe confirmed
that the module function validates arity before default-root lookup, raises
`RuntimeError` before a default root exists, returns bools for Tcl boolean
strings plus integer and bool inputs once a `Tk()` root exists, maps invalid
boolean literals to `ValueError("invalid literal for getboolean()")`, preserves
the observed `None` and float `TypeError` messages, and returns to the
too-early state after root destruction.

The recent tkinter module-level promotion adds default-root-backed
`stdlib.tkinter.image_names()`, `stdlib.tkinter.image_types()`, and
`stdlib.tkinter.mainloop(...)` behavior. A fresh Python 3.10.11 probe confirmed
that these functions raise `RuntimeError` before a default root exists, reject
extra positional arguments with module-function wording, use the first `Tk()`
root as `_default_root`, match root-level image registry tuples, run the
default root mainloop until a scheduled `quit()`, and return to the too-early
state after root destruction. The same slice moves no-master variable, widget,
and image construction toward Python's default-root behavior for covered
`StringVar()`, `Label(...)`, and `PhotoImage(...)` cases.

The latest tkinter pane-widget promotion adds `PanedWindow(...)` to the public
`stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the constructor
signature `(master=None, cnf={}, **kw)`, Python-style named paths, `Panedwindow`
Tk class naming, `panes()` path-tuple returns, `add(...)` / `remove(...)` /
`forget(...)` `None` returns, `panecget(...)`, `paneconfigure(...)` /
`paneconfig(...)` query and set behavior, `sticky` normalization to `nesw`,
`identify(...)`, `proxy_coord()` / `proxy_place(...)` / `proxy_forget()`, and
`sash_coord(...)` / `sash_mark(...)` / `sash_place(...)` return shapes plus
representative constructor, pane, proxy, and sash error paths. The aggregate
gate was also tightened by reducing pointer-query assertions to the independent
integer-return behavior that local Python/Tk actually guarantees across
separate `winfo_pointerxy()`, `winfo_pointerx()`, and `winfo_pointery()` calls.

The latest tkinter selection-widget promotion adds `OptionMenu(...)` to the
public `stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature `(master, variable, value, *values, **kwargs)`,
`OptionMenu` MRO over `Menubutton`, default `Menubutton` widget class with
Python-style `.!optionmenu` path, default `textvariable`, `menu`,
`borderwidth`, `indicatoron`, `relief`, `anchor`, and
`highlightthickness` options, internal `.menu` construction, menu labels,
menu `invoke(...)` setting the bound variable before calling the optional
command, Python's `"None"` command result, single-value menu behavior, and
observed missing-argument / master / unsupported-option errors. The AHK
surface maps Python keyword options to a trailing options object and currently
accepts only `{ command: callback }`, matching Python's supported
`OptionMenu` keyword.

The recent tkinter classic-widget promotion adds `Message(...)`,
`Menubutton(...)`, and `LabelFrame(...)` to the public `stdlib.tkinter`
surface. A fresh Python 3.10.11 probe confirmed their constructor signature,
Python-style widget paths, `_root()` identity, `winfo_class()` names,
representative `cget(...)` conversions and option keys, `Menubutton`
`Menu` attachment / command invocation, `LabelFrame` `labelwidget` and child
parent-path behavior, `destroy()` returns, and observed constructor plus
option-error paths. The implementation reuses the shared Tk-backed `Widget`
base and extends `cget("aspect")` conversion to match Python's integer
`Message` option value.

The recent tkinter widget promotion adds `Spinbox(...)` to the public
`stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature, value editing, `StringVar` `textvariable` binding,
`icursor(...)`, `index(...)`, selection query / range / clear behavior,
`invoke("buttonup")` / `invoke("buttondown")` command callbacks,
`selection_element(...)`, `bbox(index)`, `identify(x, y)`, `xview()`,
`xview_moveto(...)`, `xview_scroll(...)`, and observed constructor / method
arity plus Tcl validation errors.

The recent tkinter image-object promotion adds `BitmapImage(...)` to the
public `stdlib.tkinter` surface. A fresh Python 3.10.11 probe confirmed the
constructor signature, `data` and `file` XBM initialization, `width()`,
`height()`, `type()`, `config()` / `configure()` `None` returns, image-backed
`Label` options, image-registry membership, and observed constructor / image
method arity plus Tcl validation errors. The implementation reuses the shared
`Image` base and preserves raw bitmap `data` by quoting `-data` / `-maskdata`
options instead of brace-escaping their XBM braces.

The recent tkinter image-object promotion expands `PhotoImage` toward the
Python 3.10.11 public surface with `copy()`, `zoom(x, y="")`,
`subsample(x, y="")`, `write(filename, format=None, from_coords=None)`,
`transparency_get(x, y)`, and `transparency_set(x, y, boolean)`. A fresh
Python 3.10.11 probe confirmed the wrapper signatures, generated
`PhotoImage` return objects, copied pixel values, zoom/subsample dimensions,
boolean transparency returns, PNG write side effects, and observed arity / Tcl
validation errors.

The latest tkinter layout-alias promotion adds Python-compatible aliases for
the already covered layout-manager APIs on `Tk` roots and Tk-backed widgets:
`pack_configure()`, `grid_configure()`, `place_configure()`, `info()`,
`forget()`, `slaves()`, `propagate()`, `anchor()`, `size()`, `bbox()`, and
widget `location()`. A fresh Python 3.10.11 probe confirmed the `Pack`,
`Grid`, and `Place` alias resolution through `Label` MRO, selected arity
errors, string-valued `place_info()` coordinates, and the absence of
`Tk.location()`, so the AHK surface intentionally does not add a root
`location()` alias.

The latest tkinter promotion adds atom/path/containing/interpreter `winfo`
queries on `Tk` roots and Tk-backed widgets: `winfo_atom(name, displayof=0)`,
`winfo_atomname(id, displayof=0)`, `winfo_containing(rootX, rootY,
displayof=0)`, `winfo_interps(displayof=0)`, and `winfo_pathname(id,
displayof=0)`. A fresh Python 3.10.11 probe confirmed the `Misc` signatures,
atom round-trips, empty interpreter tuple returns on this host, raw hex window
id pathname lookup behavior, widget/`None` containing returns, `_displayof`
truthiness and `None` semantics, and observed arity / Tcl validation errors.

The recent tkinter visual-query promotion adds visual/colormap/pointer/geometry/id `winfo`
queries on `Tk` roots and Tk-backed widgets: `winfo_cells()`,
`winfo_colormapfull()`, `winfo_depth()`, `winfo_geometry()`, `winfo_id()`,
`winfo_pointerx()`, `winfo_pointerxy()`, `winfo_pointery()`,
`winfo_visual()`, `winfo_visualid()`, and `winfo_visualsavailable()`. A fresh
Python 3.10.11 probe confirmed the `Misc` signatures, local `256` color-cell
and `32` depth values, `truecolor` / `0x0` visual values, list-of-tuple
`visualsavailable` returns with integer includeids, pointer tuple behavior,
destroyed-widget `TclError` behavior, and observed arity errors.

The latest tkinter promotion tightens `winfo_screenwidth()` and
`winfo_screenheight()` to match CPython 3.10.11's DPI-unaware logical-pixel
screen dimensions on this Windows host, and adds `winfo_vrootwidth()`,
`winfo_vrootheight()`, `winfo_vrootx()`, and `winfo_vrooty()` on `Tk` roots
and Tk-backed widgets. A fresh Python 3.10.11 probe confirmed the `Misc`
signatures, `1707x1067` logical screen/virtual-root dimensions, zero virtual
root offsets, destroyed-widget `TclError` behavior, and observed arity errors.

The recent winfo screen-metadata promotion adds `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, and `winfo_server()` on `Tk`
roots and Tk-backed widgets. A fresh Python 3.10.11 probe confirmed the `Misc`
signatures, local screen name, millimeter dimensions, screen depth/cell counts,
visual model, Windows server string, destroyed-widget `TclError` behavior, and
observed arity errors.

The recent winfo distance/color promotion adds `winfo_pixels(number)`,
`winfo_fpixels(number)`, and `winfo_rgb(color)` on `Tk` roots and Tk-backed
widgets. A fresh Python 3.10.11 probe confirmed the `Misc` signatures,
integer/float pixel-distance returns, 16-bit RGB tuple returns, destroyed-widget
`TclError` behavior, and observed missing/extra-argument errors. The AHK
implementation keeps Tcl validation for screen distances and color names while
normalizing unit-based distance conversion back to CPython's DPI-unaware
logical-pixel behavior on this Windows host.

The recent tkinter root-window promotion moved GUI work back to the root-window surface:
`stdlib.tkinter.Tk()` now exposes Python 3.10.11-matched visibility, state, and
geometry APIs through `geometry()`, `state()`, `withdraw()`, `iconify()`, `deiconify()`,
`protocol()`, `wm_protocol()`,
`winfo_exists()`, `winfo_manager()`, `winfo_viewable()`, `winfo_ismapped()`,
`winfo_x()`, `winfo_y()`, `winfo_rootx()`, `winfo_rooty()`,
`winfo_screenwidth()`, `winfo_screenheight()`, `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, `winfo_server()`,
`winfo_reqwidth()`,
`winfo_reqheight()`, `winfo_vrootwidth()`, `winfo_vrootheight()`,
`winfo_vrootx()`, `winfo_vrooty()`, `winfo_pixels()`, `winfo_fpixels()`,
`winfo_rgb()`, `winfo_cells()`, `winfo_colormapfull()`, `winfo_depth()`,
`winfo_geometry()`, `winfo_id()`, `winfo_pointerx()`, `winfo_pointerxy()`,
`winfo_pointery()`, `winfo_visual()`, `winfo_visualid()`,
`winfo_visualsavailable()`, `winfo_atom()`, `winfo_atomname()`,
`winfo_containing()`, `winfo_interps()`, `winfo_pathname()`,
`winfo_width()`, `winfo_height()`, and
`winfo_toplevel()`.
The follow-up GUI promotion extends the visible-widget surface: Tk-backed
widgets and `Toplevel` windows now expose `winfo_viewable()`,
`winfo_ismapped()`, coordinate/root-coordinate/screen/request-size
`winfo_*()` queries, logical screen and virtual-root `winfo_*()` queries,
screen metadata `winfo_*()` queries, pixel-distance and RGB color `winfo_*()`
queries, visual/colormap/pointer/geometry/id `winfo_*()` queries,
atom/path/containing/interpreter `winfo_*()` queries,
`winfo_width()`, `winfo_height()`, and
`winfo_toplevel()`, while `Toplevel.geometry()` covers the observed get/set and
bad-geometry behavior. Tk roots and `Toplevel` windows also expose
`protocol()` / `wm_protocol()` for the covered window-manager callback paths.
The focus-management promotion adds `focus_set()`, `focus_force()`,
`focus_get()`, and `focus_displayof()` on Tk roots and child widgets.
The latest root-window option promotion adds `cget()`, `configure()`, and
`config()` on `Tk` roots for Python 3.10.11-matched root background option
set/read behavior, alias return values, and observed arity / option errors.
The latest option-key promotion adds `keys()` on `Tk` roots and Tk-backed
widgets, including Python 3.10.11-matched list returns, Tk `configure` option
ordering for representative root/window/widget classes, observed arity
errors, and destroyed-widget `TclError` behavior.
The latest window-decoration promotion adds `overrideredirect()` and
`wm_overrideredirect()` on `Tk` roots and `Toplevel` windows, including
Python 3.10.11-matched true-query values, false-query `None`, set-return
`None`, alias behavior, and observed arity / Tcl boolean validation errors.
The latest transient-window promotion adds `transient()` and `wm_transient()`
on `Tk` roots and `Toplevel` windows, including Python 3.10.11-matched master
path query/set/clear behavior, explicit `None` query behavior, alias behavior,
cycle errors, and bad-window-path validation.
The latest stacking promotion adds `lift()`, `tkraise()`, and `lower()` on
`Tk` roots and Tk-backed widgets, including Python 3.10.11-matched `None`
returns, explicit `None` target handling, widget/path targets, alias behavior,
and observed arity / bad-window-path errors.
The latest local-grab promotion adds `grab_set()`, `grab_release()`,
`grab_current()`, and `grab_status()` on `Tk` roots and Tk-backed widgets,
including Python 3.10.11-matched current-widget object mapping, local status
strings, no-grab `None` normalization, release idempotence, and observed arity
errors.
The latest wait promotion adds `wait_window()` and `wait_visibility()` on `Tk`
roots and Tk-backed widgets, including Python 3.10.11-matched default/self
targets, explicit `None` target behavior, widget targets, `None` returns,
event-loop-driven destroy/visibility completion, and observed arity /
AttributeError validation.
The latest variable-wait promotion adds `wait_variable(name='PY_VAR')` and its
`waitvar(...)` alias on `Tk` roots and Tk-backed widgets, including
Python 3.10.11-matched variable-object, string-name, default-name, and alias
behavior, `None` returns after scheduled variable updates, and observed arity
errors.
The latest idle-callback promotion adds `after_idle(func, *args)` on `Tk` roots
and Tk-backed widgets, including Python 3.10.11-matched required-`func`
validation, `after#N` id returns, callback argument delivery, idle execution on
`update()`, and cancellation through the existing `after_cancel(id)` path.
The widget identity-tree promotion adds `winfo_children()`, `winfo_class()`,
`winfo_name()`, and `winfo_parent()` for Tk roots, `Toplevel` windows, and
Tk-backed child widgets, including object identity for returned children,
root/child parent path strings, and destroyed-widget `TclError` behavior.
The latest path-lookup promotion adds `nametowidget(name)` on `Tk` roots and
Tk-backed widgets, including Python 3.10.11-matched absolute path, relative
child name, cross-widget root lookup, object identity returns, missing-name
`KeyError` messages, destroyed-widget `KeyError` behavior, and arity errors.
The latest image-registry promotion adds `image_names()` and `image_types()`
on `Tk` roots and Tk-backed widgets, including Python 3.10.11-matched tuple
returns for built-in Tk icons, named `PhotoImage` registry membership,
post-delete registry updates, widget/root parity, and arity errors.
The latest layout-manager promotion adds `pack_info()`, `pack_forget()`,
`grid_forget()`, `grid_remove()`, and `place_forget()` for Tk-backed widgets,
including probed manager state changes, `pack_info()` integer/string fields,
default bare-`pack()` restore behavior, `grid_forget()` default reset,
`grid_remove()` remembered-option restore behavior, `place_forget()` empty
info behavior, and observed arity / Tcl errors.
The layout child-query promotion adds `pack_slaves()`, `grid_slaves(...)`,
and `place_slaves()` on Tk roots and Tk-backed widgets, returning the same
wrapper objects that were laid out by the corresponding manager, preserving
the probed pack/grid/place ordering, row/column grid filters, forgotten-widget
removal, and observed arity / keyword / Tcl validation paths.
The latest grid geometry promotion adds `grid_size()`, `grid_bbox(...)`, and
`grid_location(x, y)` on Tk roots and Tk-backed widgets, including integer
tuple returns, full-grid and cell bbox reads, coordinate-to-cell reads,
object-form keyword analogues, Python's ignored-incomplete-argument behavior
for `grid_bbox(...)`, and observed arity / keyword / Tcl validation paths.
The grid row/column configuration promotion adds `grid_columnconfigure(...)`,
`columnconfigure(...)`, `grid_rowconfigure(...)`, and `rowconfigure(...)` on
Tk roots and Tk-backed widgets, including full-dict queries, single-option
queries, set returns, aliases, and observed arity / Tcl validation errors.
The latest layout propagation promotion adds `pack_propagate(...)`,
`grid_propagate(...)`, and `grid_anchor(...)` on Tk roots and Tk-backed
widgets, including Python 3.10.11's `None` argument handling, boolean-query
returns, set-return values, and observed arity / Tcl validation errors.
The latest clipboard promotion adds `clipboard_clear(...)`,
`clipboard_append(...)`, and `clipboard_get(...)` on Tk roots and Tk-backed
widgets, including concatenating append behavior, object-form keyword
analogues for `type` / `displayof`, empty-clipboard TclError behavior, and
observed arity / Tcl option validation errors.
The latest option-database promotion adds `option_add(...)`, `option_clear()`,
`option_get(...)`, and `option_readfile(...)` on Tk roots and Tk-backed
widgets, including new-widget option propagation, resource-file reads,
explicit `None` priority handling, and observed arity / Tcl validation errors.
The latest variable-trace promotion adds `trace_add(...)`,
`trace_remove(...)`, `trace_info()`, `trace_variable(...)`,
`trace_vdelete(...)`, and `trace_vinfo()` on `Variable`, `StringVar`,
`IntVar`, `DoubleVar`, and `BooleanVar`, including Python 3.10.11-matched
read/write/unset callback arguments, mode-list registration, legacy
`r`/`w`/`u` trace APIs, callback command cleanup, and observed arity /
bad-mode errors.
The latest window-management promotion adds Python 3.10.11-matched
`resizable()`, `minsize()`, and `maxsize()` behavior to `Tk` roots and
`Toplevel` windows, including tuple reads, set-return values, Tcl validation,
and arity errors.
The latest event promotion adds the first interaction slice: Tk-backed widgets
now expose `bind()` and `event_generate()` for the covered `<Button-1>` surface,
including synthetic event delivery, append binding, query behavior, minimal
`Event` / `EventType` fields, and observed TypeError/TclError paths.
The virtual-event promotion adds `event_add(...)`, `event_delete(...)`, and
`event_info(...)` on `Tk` roots and Tk-backed widgets, including global virtual
event table queries, physical sequence normalization, duplicate add behavior,
delete updates, explicit `None` query behavior, and observed arity / Tcl
validation errors.
The bind-tag routing promotion adds `bindtags(tagList := None)` on `Tk` roots,
`Toplevel` windows, and Tk-backed widgets, including default tag tuples,
tuple/list/string set behavior, empty tag-list no-op behavior, explicit
`None` query behavior, and observed arity / destroyed-widget errors.
The class/all binding promotion adds `bind_all(...)`, `bind_class(...)`,
`unbind(...)`, `unbind_all(...)`, and `unbind_class(...)` on `Tk` roots and
Tk-backed widgets, matching Python 3.10.11 query returns, callback ids,
widget/class/all event delivery, full-sequence unbind behavior, and observed
arity errors.
The Tcl-backed Misc conversion promotion adds `getint(s)`, `getdouble(s)`, and
`getboolean(s)` on `Tcl()` interpreters, `Tk` roots, and Tk-backed widgets,
matching Python 3.10.11 integer, float, bool, string, invalid literal, and
arity behavior.
The latest Entry promotion adds XView movement/query behavior:
`Entry(...)` now covers `xview(...)`, `xview_moveto(fraction)`, and
`xview_scroll(number, what)`, including tuple view queries, raw `moveto` /
`scroll` calls, index-form `xview(index)`, `XView.*` arity errors, and Tk-backed
bad index/fraction/number/unit errors. The previous Entry promotion added the
first cursor/selection interaction slice:
`Entry(...)` now covers `index(index)`, `icursor(index)`,
`select_range(...)` / `selection_range(...)`, `select_clear()` /
`selection_clear()`, `select_present()` / `selection_present()`,
`select_from(...)` / `selection_from(...)`, `select_to(...)` /
`selection_to(...)`, `select_adjust(...)` / `selection_adjust(...)`, and
`selection_get()` for the probed PRIMARY selection behavior.
The Canvas promotion adds item discovery and movement behavior:
`Canvas(...)` now covers `find_all()`, `find_withtag(tagOrId)`,
`bbox(*tagOrId)`, `move(tagOrId, xAmount, yAmount)`, and `type(tagOrId)` for
the probed item-id, tag, missing-item, and Tcl validation paths.
The Canvas drawing promotion adds `create_oval(...)`,
`create_polygon(...)`, and `create_text(...)`, including probed item types,
coordinate lists, item option reads, tag lookup, and coordinate/Tcl validation
errors.
The latest Canvas media promotion adds `create_image(...)` and
`create_window(...)`, covering PhotoImage-backed canvas images and embedded
widget windows with probed item ids, item types, coordinate lists, option
reads, bounding boxes, tag lookup, and coordinate/Tcl validation errors.
The latest Canvas view promotion adds `canvasx(...)`, `canvasy(...)`,
`xview(...)`, `xview_moveto(...)`, `xview_scroll(...)`, `yview(...)`,
`yview_moveto(...)`, and `yview_scroll(...)`, including coordinate
conversion, gridspacing rounding, explicit `None` gridspacing behavior,
view fraction tuples, direct `moveto` / `scroll` calls, wrapper aliases,
and observed arity / Tcl validation errors.
The Canvas tag promotion adds `addtag(...)`, `addtag_above(...)`,
`addtag_all(...)`, `addtag_below(...)`, `addtag_closest(...)`,
`addtag_enclosed(...)`, `addtag_overlapping(...)`, `addtag_withtag(...)`,
`dtag(...)`, and `gettags(...)`, including tag tuple ordering, raw Tcl-backed
search commands, convenience wrappers, tag deletion, missing-tag empty tuples,
and observed arity / Tcl validation errors.
The latest Canvas find-query promotion adds `find(...)`, `find_above(...)`,
`find_below(...)`, `find_closest(...)`, `find_enclosed(...)`, and
`find_overlapping(...)`, including raw Tcl-backed search commands, z-order
queries, closest-item optional `None` handling, enclosed / overlapping search
results, empty tuple missing-tag results, and observed TypeError / TclError
paths.
The latest Canvas arc/bitmap promotion adds `create_arc(...)` and
`create_bitmap(...)`, including probed item ids, item types, coordinate lists,
arc start / extent / style / outline / width options, bitmap name / color /
anchor options, bounding boxes, tag lookup, and observed IndexError / TclError
paths.
The latest Canvas text-item promotion adds `dchars(...)`, `focus(...)`,
`icursor(...)`, `index(...)`, `insert(...)`, `select_adjust(...)`,
`select_clear()`, `select_from(...)`, `select_item()`, and `select_to(...)`,
including text item cursor/index mutation, text insertion/deletion, focus item
queries, selection state, raw Tcl arity errors, and Python wrapper TypeError
paths.
The latest Canvas scan/scale promotion adds `scale(...)`, `scan_mark(x, y)`,
and `scan_dragto(x, y, gain=10)`, including coordinate scaling for item ids
and tags, missing-tag no-op behavior, scan-mark no-op view state, default and
explicit-gain drag scrolling, raw Tcl arity / coordinate validation errors,
and Python wrapper TypeError paths.
The latest Canvas z-order/moveto promotion adds `itemconfig(...)` as the
Python 3.10.11 alias for `itemconfigure(...)`, `moveto(tagOrId, x='', y='')`,
`tag_raise(...)`, and `tag_lower(...)`, including absolute item movement,
empty-string default coordinate forwarding, tag batch movement, item z-order
changes, missing-tag no-op movement, and observed TypeError / TclError paths.
The latest Canvas tag-event promotion adds `tag_bind(tagOrId, sequence=None,
func=None, add=None)` and `tag_unbind(tagOrId, sequence, funcid=None)`,
including tag sequence queries, event callback delivery through the existing
AHK event bridge, additive bindings, whole-sequence unbind behavior, missing
tag registration, and observed arity / command deletion errors.
The latest Canvas PostScript promotion adds `postscript(cnf={})`, including
EPS string export, option dictionaries for color mode, area and page settings,
file output with empty-string return, Tk's returned file-open error string,
and observed arity / option validation errors.

`stdlib\init.ahk` is a lightweight namespace root, not a Python-style dynamic
import loader. AutoHotkey includes are full file loads into a shared global
namespace, so `<stdlib\init>` must not include concrete modules such as
`<stdlib\toml>`. Module files include the root and explicitly mount their
namespace providers when that module is requested. For example,
`<stdlib\toml>` installs `stdlib.toml.*` because that module file
explicitly includes `<stdlib\init>` itself. AHK does not auto-load
`stdlib\init.ahk` from the directory layout. Callers should include the module
they use instead of expecting `<stdlib\init>` to load the whole stdlib.
Plain `#Include <stdlib\init>` is included only once by AutoHotkey, so repeated
module includes do not rerun the namespace root or clear earlier mounts.
`#IncludeAgain <stdlib\init>` and alternate-path includes are not allowed for
the stdlib surface because they can bypass that guarantee or cause duplicate
global class definitions.
The root namespace currently exposes `stdlib.None`, `stdlib.NotImplemented`,
`stdlib.NotImplementedError`, `stdlib.RuntimeError`, `stdlib.StopIteration`,
`stdlib.KeyError`, `stdlib.AttributeError`, `stdlib.SystemError`,
`stdlib.ModuleNotFoundError`, `stdlib.OverflowError`, `stdlib.EOFError`,
`stdlib.ProcessLookupError`, `stdlib.True`, `stdlib.False`,
`stdlib.tuple(...)`, `stdlib.slice(...)`, `stdlib.await(...)`, and
`stdlib.decorate(...)`.

The root namespace currently exposes builtins-style helpers:
`stdlib.None` as the shared AHK sentinel for Python `None` semantics where
omitted AHK parameters are not expressive enough, `stdlib.NotImplemented` as
the shared Python `NotImplemented` sentinel for covered provider-protocol and
type-name parity paths, `stdlib.NotImplementedError` /
`stdlib.RuntimeError` / `stdlib.StopIteration` / `stdlib.KeyError` /
`stdlib.AttributeError` / `stdlib.SystemError` /
`stdlib.ModuleNotFoundError` / `stdlib.OverflowError` / `stdlib.EOFError` /
`stdlib.ProcessLookupError` as root-level builtin-style error classes for
covered parity paths, `stdlib.True` / `stdlib.False` as
root-level shared boolean singleton values, and `stdlib.tuple(...)` as a first
root-level tuple constructor for cases where
the direct module surface needs stable Python-like readonly tuple materialization.
It now also exposes `stdlib.slice(...)` as a root-level Python-slice carrier for
AHK call sites that cannot use Python's colon slice syntax directly: covered
paths support `slice(stop)`, `slice(start, stop)`, `slice(start, stop, step)`,
observable `.start` / `.stop` / `.step`, `.__Repr()`, and `.indices(length)`.
It also exposes AHK-side convenience helpers: `stdlib.await(awaitable, options?)`
for covered asyncio and thread futures, and
`stdlib.decorate(target, decorators*)` for Python-style decorator application
order. `stdlib.decorate(target, outer, inner)` applies `inner(target)` first and
then `outer(...)`, matching Python's `@outer` / `@inner` expansion. This is a
library helper only; AutoHotkey still does not parse Python `@decorator` source
syntax, and `class X {}` global class declarations are not rewritten in place.
For example, `stdlib.itertools.islice(values, 1, stdlib.None, 2)` maps to
Python `itertools.islice(values, 1, None, 2)`, `stdlib.True` maps to Python
`True`, including covered bool-as-int argument paths such as
`itertools.combinations(values, True)`,
`itertools.combinations_with_replacement(values, True)`,
`itertools.permutations(values, True)`, `itertools.islice(values, True)`,
`itertools.repeat(value, True)`, and `itertools.tee(iterable, True)`, and
`stdlib.tuple("ab")` maps to Python `tuple("ab")`, including covered
type-name parity for integer-interpretation errors such as
`itertools.tee(iterable, tuple())`. Shared stdlib truthiness
treats `None`, `False`, empty arrays/maps, and empty stdlib tuples as false
for covered direct-module behavior such as `itertools.compress` selectors,
`itertools.takewhile` predicate results, and `itertools.filterfalse` with a
`None` predicate.

`stdlib.itertools` now follows Python 3.10.11 type-name parity for covered
non-iterable and integer-interpretation error paths across `repeat(...)`,
`chain(...)`, and `islice(...)`, including direct `Fraction` and
`decimal.Decimal` payloads. Covered error text now uses Python names such as
`Fraction`, `decimal.Decimal`, `function`, `list`, `dict`, and `NoneType`
instead of raw AHK implementation class names.
Its current `count(...)` slice also accepts root `stdlib.True` /
`stdlib.False` start and step values as Python bool-as-int numeric inputs,
including the Python 3.10.11 first-yield bool preservation for explicit root
bool starts outside the integer-step-`1` fast path. It accepts covered
same-family direct numeric progressions such as `Decimal + Decimal` and
`Fraction + Fraction`, while still rejecting mixed `decimal.Decimal` /
`Fraction` arithmetic at first iteration like local Python 3.10.11.
The covered keyword-capable `count` wrapper now also distinguishes Python's
single-invalid-key and too-many-keyword branches: `stdlib.itertools.count({
step: 2, extra: 3 })` still raises `'extra' is an invalid keyword argument for
count()`, while `stdlib.itertools.count({ start: 1, step: 2, extra: 3 })` now
raises `count() takes at most 2 keyword arguments (3 given)` instead of
stopping at the first unexpected field.

`stdlib.collections.Counter` now also follows Python 3.10.11 for covered
mapping-update and mapping-subtract arithmetic on direct numeric payloads:
same-family `Fraction` and same-family `decimal.Decimal` counts mutate through
their existing direct stdlib `__Add` / `__Sub` paths, while mixed
`Fraction` / `decimal.Decimal` mapping arithmetic remains unsupported with
Python-style binary-operator TypeErrors.

`stdlib.array` is now direct as a Python 3.10.11 `array` module slice, migrated
from the old `bufferarray` source material but exposed on the public
Python-path root as `stdlib.array.array(...)`. The current alphabetical restart
prioritizes public function coverage over fine parameter-corner parity. Fresh
Python 3.10.11 evidence from `.codex/array_function_surface_probe.py`
confirmed module public names `ArrayType`, `array`, and `typecodes`, plus main
paths for `.insert(...)`, `.fromlist(...)`, `.tobytes()`, `.frombytes(...)`,
`.byteswap()`, `.tounicode()`, `.fromunicode(...)`, `.tofile(...)`, and
`.fromfile(...)`. Fresh Python 3.10.11 evidence from
`.codex/array_sequence_dunder_python310_probe.py` plus JSON output confirmed
covered sequence behavior for `len(a)`, `bool(a)`, membership, equality across
same-value arrays with different typecodes, same-type concatenation,
different-type concatenation `TypeError("bad argument type for built-in
operation")`, left and right multiplication, and zero / negative repeat counts.
The AHK surface now exposes `ArrayType` as the same callable class as `array`,
supports those methods for the covered numeric / unicode / path-backed file
cases, preserves the earlier sequence slice for `.count(x)`, `.index(x)`,
`.remove(x)`, `.pop(i=-1)`, and `.reverse()`, and adds `__Len`,
`__Compare`, `__Add`, `__Mul`, `__Contains`, and `__LengthHint` hooks wired
through `stdlib.operator` for the covered array truth, contains, equality,
addition, and multiplication paths. The current in-place special-method slice
uses fresh Python 3.10.11 evidence from
`.codex/array_inplace_special_methods_probe.py` plus
`.codex/array_inplace_special_methods_probe.output.json` confirming direct
in-place add mutation and self return, wrong-kind and non-array
errors, in-place multiply mutation and self return for positive, zero, `True`,
and `False` counts, float count `TypeError`, and reverse multiply returning a
new repeated array without mutating the source. The AHK surface now exposes
AHK-style no-tail lower-case analogues `__iadd`, `__imul`, and `__rmul` on
`AhkStdlibArrayValue` while preserving the existing
`stdlib.operator` sequence hooks. Fresh AHK evidence includes
`.codex/array-inplace-special-methods-red-report.txt` erroring because
`AhkStdlibArrayValue` had no `__iadd` method, focused green
`.codex/array-inplace-special-methods-green-focused-report.txt` passing 1/1,
module green `.codex/array-inplace-special-methods-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 23/23, and root smoke
`.codex/array-inplace-special-methods-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233. Follow-up example capture
`.codex/array-inplace-special-methods-example-array-report.txt` loaded
`stdlib/examples/array.ahk` without warning/error, and validation
`.codex/array-inplace-special-methods-validate-report.txt` passed
`stdlib/array.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current copy interop slice also exposes Python's
observed array copy / deepcopy hook behavior through AHK-style no-tail
`__copy` and `__deepcopy` methods consumed by `stdlib.copy.copy(...)` and
`stdlib.copy.deepcopy(...)`:
shallow and deep copies preserve `typecode` / `itemsize`, return distinct
arrays, and keep subsequent source/copy mutations independent. Fresh Python
3.10.11 evidence in `.codex/array_copy_deepcopy_probe.py` plus
`.codex/array_copy_deepcopy_probe.output.json` confirmed those copy hooks and
independent mutation behavior. The current root-slice / array-slice interop
slice uses fresh Python 3.10.11 evidence from `.codex/array_slice_probe.py`
plus `.codex/array_slice_probe.output.json` confirming covered
`slice(...).indices(...)` normalization, `array.array` slicing reads returning
same-type arrays, ordinary slice assignment with resize, extended slice
assignment with same-size enforcement, ordinary and extended slice deletion,
wrong-typecode assignment `TypeError("bad argument type for built-in operation")`,
list assignment `TypeError("can only assign array (not \"list\") to array slice")`,
extended-size mismatch `ValueError`, and zero-step `ValueError("slice step cannot be zero")`.
The AHK surface covers those paths with `arrayValue[stdlib.slice(...)]` for
read/write and `arrayValue.Delete(stdlib.slice(...))` as the AHK syntax
replacement for Python `del array_value[...]`. Fresh AHK evidence for this
slice includes root focused red `.codex/init-slice-red-report.txt` failing
because `stdlib` had no `slice`, array focused red
`.codex/array-slice-red-report.txt` failing for the same missing root helper,
root focused green `.codex/init-slice-green-focused-report.txt` passing 1/1,
array focused green `.codex/array-slice-green-focused-report.txt` passing 1/1,
module green `.codex/array-slice-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 8/8, root smoke
`.codex/array-slice-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-slice-validate-report.txt` passing `stdlib/init.ahk`,
`stdlib/array.ahk`, `stdlib/tests/stdlib.test.ahk`,
`stdlib/tests/array.test.ahk`, `stdlib/examples/init.ahk`, and
`stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The follow-up operator
interop slice uses fresh Python 3.10.11 evidence from
`.codex/array_operator_slice_probe.py` plus
`.codex/array_operator_slice_probe.output.json` confirming
`operator.getitem(...)`, `operator.setitem(...)`, and `operator.delitem(...)`
with array slices. The AHK surface already routed get/set through the custom
array indexer, and now routes `stdlib.operator.delitem(arrayValue,
stdlib.slice(...))` through the array `Delete(...)` protocol. Fresh AHK
evidence includes `.codex/array-operator-slice-red-report.txt` failing because
`delitem` left the target unchanged, focused green
`.codex/array-operator-slice-green-focused-report.txt` passing 1/1, module
green `.codex/array-operator-slice-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 9/9, operator regression
`.codex/array-operator-slice-operator-green-report.txt` passing
`stdlib/tests/operator.test.ahk` 12/12, root smoke
`.codex/array-operator-slice-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-operator-slice-validate-report.txt` passing `stdlib/init.ahk`,
`stdlib/array.ahk`, `stdlib/operator.ahk`, related tests, and
`stdlib/examples/init.ahk` / `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current slice-RHS snapshot slice uses fresh Python
3.10.11 evidence from `.codex/array_slice_self_assignment_probe.py` plus
`.codex/array_slice_self_assignment_probe.output.json` confirming that
`array_value[::-1] = array_value` reads the original RHS snapshot and produces
the reversed array, ordinary self slice assignment can resize from the original
RHS, and stepped assignment from a slice copy keeps the expected values. The
AHK surface now clones the replacement array at the `stdlib.slice(...)`
assignment boundary before mutating the target, so extended self assignment no
longer reads values already overwritten by earlier positions. Fresh AHK
evidence includes `.codex/array-slice-self-assignment-red-report.txt` failing
because `a[::-1] = a` produced `[1, 2, 2, 1]`, focused green
`.codex/array-slice-self-assignment-green-focused-report.txt` passing 1/1,
module green `.codex/array-slice-self-assignment-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 19/19, and root smoke
`.codex/array-slice-self-assignment-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233. Follow-up example capture
`.codex/array-slice-self-assignment-example-array-report.txt` loaded
`stdlib/examples/array.ahk` without warning/error, and validation
`.codex/array-slice-self-assignment-validate-report.txt` passed
`stdlib/array.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current bounded-index slice uses fresh Python 3.10.11
evidence from `.codex/array_index_bounds_probe.py` plus
`.codex/array_index_bounds_probe.output.json` confirming
`array.index(x, start, stop)` with positive and negative bounds, not-found
`ValueError("array.index(x): x not in array")`, slice-index `TypeError` for
non-integer bounds, and Python 3.10 arity messages. The AHK surface now covers
those paths through `arrayValue.index(x, start?, stop?)`. Fresh AHK evidence
includes `.codex/array-index-bounds-red-report.txt` failing because the old
implementation rejected a second argument, focused green
`.codex/array-index-bounds-green-focused-report.txt` passing 1/1, module green
`.codex/array-index-bounds-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 10/10, root smoke
`.codex/array-index-bounds-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-index-bounds-validate-report.txt` passing `stdlib/array.ahk`,
`stdlib/tests/array.test.ahk`, `stdlib/tests/stdlib.test.ahk`, and
`stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The current extend/fromlist
input-rule slice uses fresh Python 3.10.11 evidence from
`.codex/array_extend_fromlist_probe.py` plus
`.codex/array_extend_fromlist_probe.output.json` confirming that
`extend(array)` requires an array of the same kind, ordinary list-style
iterables still extend successfully, and `fromlist(...)` accepts list while
rejecting tuple/array inputs with `TypeError("arg must be list")`. The AHK
surface now enforces those covered rules while preserving generic iterable
`extend(...)` for non-array inputs. Fresh AHK evidence includes
`.codex/array-extend-fromlist-red-report.txt` failing because wrong-typecode
array extension raised no exception, focused green
`.codex/array-extend-fromlist-green-focused-report.txt` passing 1/1, module
green `.codex/array-extend-fromlist-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 11/11, root smoke
`.codex/array-extend-fromlist-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-extend-fromlist-validate-report.txt` passing `stdlib/array.ahk`,
`stdlib/tests/array.test.ahk`, `stdlib/tests/stdlib.test.ahk`, and
`stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The current append/extend
return-protocol slice uses fresh Python 3.10.11 evidence from
`.codex/array_append_extend_return_probe.py` plus
`.codex/array_append_extend_return_probe.output.json` confirming that
successful `append(...)`, `extend(list)`, `extend(array)`, and unicode
`extend(str)` all return `None` while mutating the target. The AHK surface now
returns root `stdlib.None` from those successful mutation methods instead of an
empty string, and the root namespace smoke was updated to assert that protocol.
Fresh AHK evidence includes `.codex/array-append-extend-return-red-report.txt`
failing because `append(...)` returned `""`, focused green
`.codex/array-append-extend-return-green-focused-report.txt` passing 1/1,
module green `.codex/array-append-extend-return-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 20/20, root smoke
`.codex/array-append-extend-return-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233 after synchronizing the root smoke
assertion, example capture
`.codex/array-append-extend-return-example-array-report.txt` loading
`stdlib/examples/array.ahk` without warning/error, and validation
`.codex/array-append-extend-return-validate-report.txt` passing
`stdlib/array.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current integer-bounds
slice uses fresh Python 3.10.11 evidence from
`.codex/array_integer_bounds_probe.py` plus
`.codex/array_integer_bounds_probe.output.json` confirming min/max acceptance
and OverflowError text for the covered signed/unsigned 1-, 2-, and 4-byte
integer typecodes, plus observed 8-byte baseline evidence kept for backlog
where AHK's signed-64 integer ceiling limits full unsigned-64 coverage. The AHK
surface now rejects covered out-of-range integer writes before `NumPut` can
truncate/wrap them, and adds root `stdlib.OverflowError` as the Python-style
error class used by these paths. Fresh AHK evidence includes
`.codex/array-integer-bounds-red-report.txt` failing because an out-of-range
value raised no exception, focused green
`.codex/array-integer-bounds-green-focused-report.txt` passing 1/1, root error
builtin focused green `.codex/array-overflow-root-error-green-report.txt`
passing 1/1, module green `.codex/array-integer-bounds-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 12/12, root smoke
`.codex/array-integer-bounds-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-integer-bounds-validate-report.txt` passing `stdlib/init.ahk`,
`stdlib/array.ahk`, `stdlib/tests/array.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, `stdlib/examples/init.ahk`, and
`stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The current readonly /
fromfile EOF slice uses fresh Python 3.10.11 evidence from
`.codex/array_readonly_fromfile_probe.py` plus
`.codex/array_readonly_fromfile_probe.output.json` confirming
`typecode` and `itemsize` readonly `AttributeError` messages, successful exact
`fromfile(...)`, zero-count reads, negative-count and non-integer-count errors,
short reads raising `EOFError("read() didn't return enough bytes")`, complete
items already read being appended before that EOF, and non-item-aligned short
reads raising `ValueError("bytes length not a multiple of item size")` without
mutation. The AHK surface now exposes root `stdlib.EOFError`, keeps
`arrayValue.typecode` and `.itemsize` readonly, and preserves those covered
short-read mutation rules. Fresh AHK evidence includes
`.codex/array-readonly-fromfile-red-report.txt` failing because `typecode`
assignment raised no exception, root red
`.codex/array-eoferror-root-red-report.txt` erroring because `stdlib.EOFError`
was absent, focused green
`.codex/array-readonly-fromfile-green-focused-report.txt` passing 1/1, root
focused green `.codex/array-eoferror-root-green-focused-report.txt` passing
1/1, module green `.codex/array-readonly-fromfile-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 13/13, and root smoke
`.codex/array-readonly-fromfile-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233 at `TimeoutSeconds 90`. The current
string-initializer rule slice uses fresh Python 3.10.11 evidence from
`.codex/array_string_initializer_probe.py` plus
`.codex/array_string_initializer_probe.output.json` confirming that string
initializers are accepted for `typecode "u"`, rejected for non-unicode
typecodes with `TypeError("cannot use a str to initialize an array with
typecode 'x'")`, `extend("...")` appends characters for unicode arrays while
non-unicode arrays still fail item conversion, and `fromlist("...")` still
raises `TypeError("arg must be list")`. The AHK surface now rejects non-`u`
string constructor inputs before per-character validation while preserving the
covered unicode and extend/fromlist paths. Fresh AHK evidence includes
`.codex/array-string-initializer-red-report.txt` failing because
`array("i", "12")` reported the per-item integer-conversion error, focused
green `.codex/array-string-initializer-green-focused-report.txt` passing 1/1,
module green `.codex/array-string-initializer-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 14/14, root smoke
`.codex/array-string-initializer-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-string-initializer-validate-report.txt` passing
`stdlib/array.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current bytes-initializer slice uses fresh Python
3.10.11 evidence from `.codex/array_bytes_initializer_probe.py` plus
`.codex/array_bytes_initializer_probe.output.json` confirming that
`array("i", bytes)` and bytearray-style inputs initialize from raw bytes,
`array("u", bytes)` initializes unicode storage from raw bytes on this local
Windows Python build, and short byte payloads raise
`ValueError("bytes length not a multiple of item size")`. The AHK surface now
treats `Buffer` initializer inputs as bytes-like objects and routes them
through the existing `frombytes(...)` path before generic iterable handling,
while preserving the same short-buffer error. Fresh AHK evidence includes
`.codex/array-bytes-initializer-red-report.txt` erroring because `Buffer` was
not iterable, focused green
`.codex/array-bytes-initializer-green-focused-report.txt` passing 1/1, module
green `.codex/array-bytes-initializer-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 21/21, and root smoke
`.codex/array-bytes-initializer-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233. Follow-up example capture
`.codex/array-bytes-initializer-example-array-report.txt` loaded
`stdlib/examples/array.ahk` without warning/error, and validation
`.codex/array-bytes-initializer-validate-report.txt` passed
`stdlib/array.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. The current bytes-extend slice uses fresh Python 3.10.11
evidence from `.codex/array_bytes_extend_probe.py` plus
`.codex/array_bytes_extend_probe.output.json` confirming that `extend(bytes)`
and bytearray-style payloads iterate byte values, successful extension returns
`None`, unicode arrays reject byte integers with
`TypeError("array item must be unicode character")`, and constructor bytes-like
initialization remains raw-byte based. The AHK surface now treats `Buffer`
payloads to `extend(...)` as byte iterables while keeping
`array(typecode, Buffer)` on the raw `frombytes(...)` initializer path. Fresh
AHK evidence includes `.codex/array-bytes-extend-red-report.txt` erroring
because `Buffer` was not iterable, focused green
`.codex/array-bytes-extend-green-focused-report.txt` passing 1/1, module green
`.codex/array-bytes-extend-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 22/22, and root smoke
`.codex/array-bytes-extend-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233. Follow-up example capture
`.codex/array-bytes-extend-example-array-report.txt` loaded
`stdlib/examples/array.ahk` without warning/error, and validation
`.codex/array-bytes-extend-validate-report.txt` passed `stdlib/array.ahk`,
related tests, and `stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The current unicode-repr slice uses fresh Python 3.10.11
evidence from `.codex/array_unicode_repr_probe.py` plus
`.codex/array_unicode_repr_probe.output.json` confirming `array("u")` empty
repr, compact `array('u', 'Az')` non-empty repr, quote selection, backslash,
newline, tab, and `\xNN` control-character escaping. The AHK surface now
special-cases non-empty unicode arrays in `.__Repr()` through the covered
Python-style string repr while leaving numeric array reprs on the list form.
Fresh AHK evidence includes `.codex/array-unicode-repr-red-report.txt` failing
because unicode arrays were represented as `['A', 'z']`, focused green
`.codex/array-unicode-repr-green-focused-report.txt` passing 1/1, module green
`.codex/array-unicode-repr-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 15/15, root smoke
`.codex/array-unicode-repr-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-unicode-repr-validate-report.txt` passing `stdlib/array.ahk`,
related tests, and `stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The
current bool-value type slice uses fresh Python 3.10.11 evidence from
`.codex/array_bool_values_probe.py` plus
`.codex/array_bool_values_probe.output.json` confirming that `True` and
`False` construct and append as `1` / `0` for all covered integer typecodes
`bB hH iI lL qQ`, as `1.0` / `0.0` for float typecodes `f` and `d`, and still
raise `TypeError("array item must be unicode character")` for unicode arrays.
The AHK surface now maps root `stdlib.True` / `stdlib.False` through the same
numeric storage conversion while preserving unicode rejection. Fresh AHK
evidence includes `.codex/array-bool-values-red-report.txt` erroring because
root bool reached `NumPut` as an object, focused green
`.codex/array-bool-values-green-focused-report.txt` passing 1/1, module green
`.codex/array-bool-values-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 16/16, root smoke
`.codex/array-bool-values-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-bool-values-validate-report.txt` passing `stdlib/array.ahk`,
related tests, and `stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The
current bool-index/count slice uses fresh Python 3.10.11 evidence from
`.codex/array_bool_index_probe.py` plus
`.codex/array_bool_index_probe.output.json` confirming that `True` and
`False` act as indexes `1` and `0` for get, set, delete, `pop(...)`, and
`insert(...)`, act as start bounds for `index(...)`, and act as repeat counts
for multiplication. The AHK surface now maps root `stdlib.True` /
`stdlib.False` through those same index/count paths, including
`arrayValue[stdlib.True]`, `arrayValue.Delete(stdlib.True)`,
`arrayValue.pop(stdlib.True)`, `arrayValue.insert(stdlib.False, value)`, and
`stdlib.operator.mul(arrayValue, stdlib.True)`. Fresh AHK evidence includes
`.codex/array-bool-index-red-report.txt` erroring because root bool was not an
integer index, focused green `.codex/array-bool-index-green-focused-report.txt`
passing 1/1, module green `.codex/array-bool-index-module-green-report.txt`
passing `stdlib/tests/array.test.ahk` 17/17, root smoke
`.codex/array-bool-index-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-bool-index-validate-report.txt` passing `stdlib/array.ahk`,
related tests, and `stdlib/examples/array.ahk` at `TimeoutSeconds 90`. The
current bool-search/remove slice uses fresh Python 3.10.11 evidence from
`.codex/array_bool_search_probe.py` plus
`.codex/array_bool_search_probe.output.json` confirming that `True` and
`False` compare as numeric `1` and `0` for `count(...)`, `index(...)`,
`remove(...)`, and containment on numeric arrays, while unicode arrays still do
not treat root bool singletons as matching characters. The AHK surface now
normalizes the search needle for non-unicode arrays through the same scalar
conversion used by numeric storage, so `stdlib.array.array("i", [0, 1])`
matches `stdlib.True` and `stdlib.False` in search/removal paths while
preserving unicode rejection/no-match behavior. Fresh AHK evidence includes
`.codex/array-bool-search-red-report.txt` failing because root bool search
returned count `0`, focused green
`.codex/array-bool-search-green-focused-report.txt` passing 1/1, module green
`.codex/array-bool-search-module-green-report.txt` passing
`stdlib/tests/array.test.ahk` 18/18, root smoke
`.codex/array-bool-search-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/array-bool-search-validate-report.txt` passing `stdlib/array.ahk`,
related tests, and `stdlib/examples/array.ahk` at `TimeoutSeconds 90`. Earlier fresh AHK evidence includes focused red
`.codex/array-copy-deepcopy-red-report.txt` erroring because the generic object
deepcopy path hit `Type mismatch`, focused green
`.codex/array-copy-deepcopy-green-focused-report.txt` passing 1/1, module green
`.codex/array-copy-deepcopy-module-green-serial-report.txt` passing
`stdlib/tests/array.test.ahk` 7/7, copy regression
`.codex/array-copy-deepcopy-copy-regression-serial-report.txt` passing
`stdlib/tests/copy.test.ahk` 3/3, root smoke
`.codex/array-copy-deepcopy-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 232/232, and validation
`.codex/array-copy-deepcopy-validate-report.txt` passing `stdlib/array.ahk`,
`stdlib/tests/array.test.ahk`, `stdlib/tests/copy.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. Earlier fresh AHK evidence includes focused red
`.codex/array-sequence-dunder-red-report.txt` failing because
`AhkStdlibArrayValue` had no `__Len`, final module green
`.codex/array-sequence-dunder-final-green-report.txt` passing
`stdlib/tests/array.test.ahk` 6/6, operator regression
`.codex/array-sequence-dunder-operator-green-report.txt` passing
`stdlib/tests/operator.test.ahk` 12/12, root smoke
`.codex/array-sequence-dunder-stdlib-focused-report.txt` passing 1/1, and
`.codex/array-sequence-dunder-validate-report.txt` passing `stdlib/array.ahk`,
`stdlib/operator.ahk`, related tests, and `stdlib/examples/array.ahk` at
`TimeoutSeconds 90`. Earlier evidence also includes focused red
`array function surface covers binary unicode and file methods` failing because
`stdlib.array.ArrayType` was absent, focused green passing 1/1 in 0 ms, full
`stdlib/tests/array.test.ahk` passing 5/5 in 16 ms, and
`run-ahk-validate -Path stdlib/examples/array.ahk -TimeoutSeconds 90`
passing. The earlier `array` slice continues to cover module-level
`typecodes`, constructor-style `stdlib.array.array(typecode, initializer?)`,
observable `.typecode` and `.itemsize` properties, zero-based index get/set
semantics, `.append(...)`, `.extend(...)`, `.tolist()`, `.buffer_info()`,
iteration, Python-style `__Repr()` output for covered numeric arrays, bad
typecodes, non-iterable initializers and `extend(...)` payloads,
non-integer-compatible `append(...)` payloads, and out-of-range indexes. Full
Python file-object protocol parity and detailed parameter error wording remain
maintenance backlog.

`stdlib.pprint` is now direct as a first slice of Python 3.10.11's `pprint`
module, migrated from the old `print` source material but exposed on the
public Python-path root as `stdlib.pprint.*`. The current slice covers
module-level `pformat(...)`, `pprint(...)`, and `pp(...)`, plus
`stdlib.pprint.PrettyPrinter(...).pformat(...)` / `.pprint(...)` for the
covered constructor parameters `indent`, `width`, `depth`, `stream`,
`compact`, and `sort_dicts`. The covered pretty-printing surface currently
matches the local Python baseline for nested list/dict formatting, compact
multi-line list layout, depth truncation to `[...]`, stream writes through
`stdlib.io.StringIO`, default sorted-dict formatting, and the observed
`ValueError("invalid literal for int() with base 10: 'x'")` and
`AttributeError("'int' object has no attribute 'write'")` branches. AHK
`Map(...)` enumeration on this host is already key-sorted for the covered
inputs, so `sort_dicts=False` does not yet create an independently observable
order difference on plain maps in this slice.

`stdlib.hashlib` is now direct as a first runtime slice centered on local
Python 3.10.11 hashing behavior for covered named algorithms. The current
public shape covers `stdlib.hashlib.algorithms_guaranteed`, constructor-style
`stdlib.hashlib.new(name, data?)`, convenience constructors
`stdlib.hashlib.md5(...)`, `stdlib.hashlib.sha1(...)`, and
`stdlib.hashlib.sha256(...)`, plus hash-object `.name`, `.digest_size`,
`.block_size`, `.update(...)`, `.digest()`, `.hexdigest()`, and `.copy()`
behavior for the covered algorithms. The current slice accepts Buffer-like
byte payloads, preserves incremental update state, returns lowercase hex
digests matching local Python's covered vectors, clones state through
`.copy()` without mutating the original object, raises
`ValueError("unsupported hash type ...")` for covered unsupported algorithms
such as `crc32`, and raises Python-style
`TypeError("Strings must be encoded before hashing")` when passed text
payloads directly instead of bytes.

`stdlib.string` is now direct as a first slice of Python 3.10.11 `string`,
promoted onto the public Python-path root as `stdlib.string.*`. The current
slice covers the observed module constants `ascii_lowercase`,
`ascii_uppercase`, `ascii_letters`, `digits`, `hexdigits`, `octdigits`,
`punctuation`, `whitespace`, and `printable`, plus `capwords(s, sep?)` for the
observable local baseline. Covered behavior currently matches local Python
3.10.11 for default whitespace-collapsing title-casing, explicit `None`
separator parity, explicit string separators including repeated delimiters,
and the observed local error wording for missing source arguments, excess
positional arguments, non-string source payloads, non-string separators, empty
separators, and the covered `bool` separator split where `True` raises a
Python-style missing-`join` `AttributeError` while `False` raises the observed
`TypeError("must be str or None, not bool")`. `Formatter`, `Template`, named
constant helpers such as `digits`-driven classes, and the wider formatting
surface remain deferred. To keep the public root budget stable at 57 slots,
the old `kazmath` placeholder has been removed from the root-slot manifest
count in favor of this concrete Python stdlib root.

`stdlib.keyword` is now direct as a first slice of Python 3.10.11 `keyword`,
promoted onto the public Python-path root as `stdlib.keyword.*`. The current
slice covers the observed local 3.10.11 `kwlist` and `softkwlist` contents,
plus `iskeyword(value)` and `issoftkeyword(value)` for the covered predicate
behavior. Covered behavior currently matches the local runtime for classic
keywords such as `for`, soft keywords such as `match`, false results for
covered non-string payloads such as `1`, and the observed local
`frozenset.__contains__()` arity wording for zero-argument and two-argument
misuse. To keep the public root budget stable at 57 slots, the old
`algorithm` placeholder has been removed from the root-slot manifest count in
favor of this concrete Python stdlib root.

`stdlib.fnmatch` is now direct as a first slice of Python 3.10.11 `fnmatch`,
promoted onto the public Python-path root as `stdlib.fnmatch.*`. The current
slice covers `fnmatch(name, pat)`, `fnmatchcase(name, pat)`, `filter(names,
pat)`, and `translate(pat)` for the observed local baseline: Windows-style
case-normalized matching in `fnmatch`, case-sensitive matching in
`fnmatchcase`, iterable filtering, the covered `translate()` regex outputs for
`*.txt` and `[!a]*.txt`, direct wildcard/question/negated-bracket behavior,
and the observed local arity/type-error wording for missing arguments, too
many arguments, non-string inputs, and covered mixed string/bytes-like misuse.
To keep the public root budget stable at 57 slots, the old `vector`
placeholder has been removed from the root-slot manifest count in favor of
this concrete Python stdlib root.

`stdlib.glob` is now direct as a first slice of Python 3.10.11 `glob`,
promoted onto the public Python-path root as `stdlib.glob.*`. The current
slice covers `glob(pathname, { recursive: true|false }?)`, `escape(pathname)`,
and `has_magic(s)` for the observed local baseline: plain wildcard collection,
covered `**` recursive collection through the keyword-only `recursive`
analogue, direct `escape()` output for covered bracket/meta characters, direct
`has_magic()` behavior for covered plain and wildcard strings, and the
observed local arity/type-error wording for missing arguments, too many
positional arguments, and invalid non-string payloads. To keep the public
root budget stable at 57 slots, the old `keyboard` placeholder has been
removed from the root-slot manifest count in favor of this concrete Python
stdlib root.

`stdlib.textwrap` is now direct as a first slice of Python 3.10.11
`textwrap`, promoted onto the public Python-path root as `stdlib.textwrap.*`.
The current slice covers `dedent(text)` and
`indent(text, prefix, predicate := unset)` for the observed local baseline:
common-margin removal across covered mixed-indent multiline strings, blank-line
dedent normalization for covered whitespace-only lines, default indentation of
non-blank lines only, predicate-driven all-line and no-line indentation for
covered callable returns, and the observed local arity/type-error wording for
missing arguments, too many positional arguments, non-string text values,
non-string prefixes, and non-callable predicates. To keep the public root
budget stable at 57 slots, the last root-slot placeholder `linq` has been
removed from the manifest count in favor of this concrete Python stdlib root.

`stdlib.base64` is now direct as a first slice of Python 3.10.11 `base64`,
promoted onto the public Python-path root as `stdlib.base64.*`. The current
slice covers `b64encode(s, altchars := None)`,
`b64decode(s, altchars := None, validate := False)`,
`urlsafe_b64encode(s)`, and `urlsafe_b64decode(s)` for the observed local
baseline. The latest alphabetical pass slice adds `standard_b64encode(s)`,
`standard_b64decode(s)`, `encodebytes(s)`, `decodebytes(s)`,
`b16encode(s)`, and `b16decode(s, casefold := False)`. Fresh Python 3.10.11
evidence from `.codex/base64_standard_bytes_b16_probe.py` plus JSON output
confirmed standard Base64 wrappers, wrapped bytes output with 76-character
line folding and trailing newlines for non-empty input, `decodebytes(...)`
rejecting text input, Base16 uppercase encoding, bytes and ASCII-string
Base16 decode input, empty Base16 decode, default lowercase rejection with
`Error("Non-base16 digit found")`, and `casefold=True` accepting lowercase
hex digits. Fresh AHK evidence includes focused red
`.codex/base64-standard-bytes-b16-red-report.txt` failing because
`stdlib.base64.standard_b64encode` was absent, focused green
`.codex/base64-standard-bytes-b16-green-focused-report.txt` passing 1/1, full
module `.codex/base64-standard-bytes-b16-final-green-report.txt` passing
`stdlib/tests/base64.test.ahk` 4/4, root smoke
`.codex/base64-standard-bytes-b16-stdlib-focused-report.txt` passing 1/1, and
`.codex/base64-standard-bytes-b16-validate-report.txt` validating
`stdlib/base64.ahk`, `stdlib/tests/base64.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/base64.ahk` at
`TimeoutSeconds 90`. The current Base32 follow-up uses fresh Python 3.10.11
evidence from `.codex/base64_base32_probe.py` plus
`.codex/base64_base32_probe.output.json` confirming `MAXBINSIZE == 57`,
`MAXLINESIZE == 76`, `b32encode(...)`, `b32decode(...)`,
`b32hexencode(...)`, and `b32hexdecode(...)` for empty, ASCII, and binary
payloads, bytes and ASCII-string decode input, default lowercase rejection,
`casefold=True`, standard Base32 `map01`, and observed bad-padding /
bad-type errors. The AHK surface now covers those Base32 and Base32hex paths;
Base85/Ascii85 and file-object `encode(...)` / `decode(...)` APIs remain
explicit backlog. Fresh AHK evidence includes focused red
`.codex/base64-base32-red-report.txt` erroring because
`stdlib.base64.MAXBINSIZE` was absent, focused green
`.codex/base64-base32-green-focused-report.txt` passing 1/1, module green
`.codex/base64-base32-module-report.txt` passing `stdlib/tests/base64.test.ahk`
5/5, root smoke `.codex/base64-base32-stdlib-root-report.txt` passing 1/1,
and validation `.codex/base64-base32-validate-report.txt` passing
`stdlib/base64.ahk`, `stdlib/tests/base64.test.ahk`, and
`stdlib/examples/base64.ahk` at `TimeoutSeconds 90`. The earlier alphabetical pass slice added URL-safe Base64 encoding and
decoding, including the probed `b"\xfb\xff" -> b"-_8="` and `b"-_8=" ->
b"\xfb\xff"` behavior, ASCII-string decode input, and the observed local
arity/type-error wording for missing arguments, too many positional arguments,
text passed where bytes are required, and non-bytes decode payloads. Fresh
Python 3.10.11 evidence from `.codex/base64_urlsafe_probe.py` confirmed the
covered values and error text. Fresh AHK evidence includes focused red
`UrlsafeB64` failing because `stdlib.base64.urlsafe_b64encode` was absent,
focused green passing 1/1 in 16 ms, full `stdlib/tests/base64.test.ahk`
passing 3/3 in 47 ms, and `run-ahk-validate -Path
stdlib/examples/base64.ahk -TimeoutSeconds 90` passing. The earlier `base64`
slice continues to cover bytes-to-bytes Base64 encoding, bytes and
ASCII-string decode input, covered two-byte `altchars` handling, covered
bool-like `validate` acceptance, non-ASCII decode payloads, invalid
`altchars` length, and the observed local arity/type-error wording for the
covered `b64encode(...)` / `b64decode(...)` branches. To keep the public root
budget stable at 57 slots, one native-quarantine slot has been reclaimed in
favor of this concrete Python stdlib root.

The current Base85 follow-up uses fresh Python 3.10.11 evidence from
`.codex/base64_base85_probe.py` plus
`.codex/base64_base85_probe.output.json` confirming `b85encode(...)`,
`b85decode(...)`, `a85encode(...)`, and `a85decode(...)` for empty, ASCII, and
binary payloads, bytes and ASCII-string decode input, b85 padding, Ascii85
Adobe framing, fold-spaces shorthand, zero shorthand, padded Ascii85 output,
default whitespace ignoring, and observed bad-type decode errors. The AHK
surface now covers those core Base85 and Ascii85 paths with project-standard
options objects for keyword-only Ascii85 options such as `{ adobe: true }`,
`{ foldspaces: true }`, and `{ pad: true }`; `wrapcol`, custom `ignorechars`,
and deeper malformed-input parity remain backlog. Fresh AHK evidence includes
focused red `.codex/base64-base85-red-report.txt` erroring because
`stdlib.base64.b85encode` was absent, focused green
`.codex/base64-base85-green-focused-report.txt` passing 1/1, module green
`.codex/base64-base85-module-report.txt` passing `stdlib/tests/base64.test.ahk`
6/6, root smoke `.codex/base64-base85-stdlib-root-report.txt` passing 1/1,
and validation `.codex/base64-base85-validate-report.txt` passing
`stdlib/base64.ahk`, `stdlib/tests/base64.test.ahk`, and
`stdlib/examples/base64.ahk` at `TimeoutSeconds 90`.

`stdlib.getpass` is now direct as a first slice of Python 3.10.11 `getpass`,
promoted onto the public Python-path root as `stdlib.getpass.*`. The current
slice covers `getuser()` for the observed local Windows baseline: environment
variable priority `LOGNAME`, then `USER`, then `LNAME`, then `USERNAME`,
empty-string skipping for earlier variables, Python-style zero-argument arity
enforcement, and the observed local Windows fallback when every environment
variable is missing, which raises `ModuleNotFoundError("No module named
'pwd'")`. This promotion also adds root builtin-style
`stdlib.ModuleNotFoundError(...)` parity for covered direct-module behavior.
To keep the public root budget stable at 57 slots, the last remaining
native-quarantine slot has been reclaimed in favor of this concrete Python
stdlib root.

`stdlib.binascii` is now direct as a first slice of Python 3.10.11
`binascii`, promoted onto the public Python-path root as `stdlib.binascii.*`.
The current slice covers `hexlify(data, sep?, bytes_per_sep?)`,
`b2a_hex(...)`, `unhexlify(hexstr)`, `a2b_hex(...)`,
`b2a_base64(data, { newline: false }?)`, `a2b_base64(data)`, and
`crc32(data, value := 0)`, plus module-level `Error` and `Incomplete` error
aliases, for the observed local baseline. The latest alphabetical pass slice
adds Base64 ASCII helpers: default `b2a_base64(...)` trailing-newline output,
empty input newline output, binary bytes, AHK-side keyword-style
`{ newline: false }`, bytes and ASCII-string decode input, binary decode, and
Python 3.10.11 non-strict invalid-character filtering for `b"!!!!"`. Fresh
Python 3.10.11 evidence from `.codex/binascii_base64_probe.py` and
`.codex/binascii_base64_probe.output.json` confirmed those values and that
`strict_mode` is not supported in local 3.10.11. Fresh AHK evidence includes
focused red `.codex/binascii-base64-red-report.txt` failing because
`stdlib.binascii.b2a_base64` was absent, focused green
`.codex/binascii-base64-green-focused-report.txt` passing 1/1, and full module
`.codex/binascii-base64-final-green-report.txt` passing
`stdlib/tests/binascii.test.ahk` 4/4 at `TimeoutSeconds 90`; root smoke
`.codex/binascii-base64-stdlib-focused-report.txt` passing 1/1; and
`.codex/binascii-base64-validate-report.txt` validating
`stdlib/binascii.ahk`, `stdlib/tests/binascii.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/binascii.ahk` at
`TimeoutSeconds 90`. The earlier
CRC32 slice added `crc32(...)` for empty bytes, ASCII bytes, binary bytes,
explicit positive and negative seed values, and representative
missing/extra/type errors. Fresh Python 3.10.11 evidence from
`.codex/binascii_crc32_probe.py` confirmed `crc32(b"abc") == 891568578`,
`crc32(b"") == 0`, `crc32(b"\x00\xff") == 1826356594`,
`crc32(b"abc", 1) == 887499765`, `crc32(b"abc", -1) == 899311407`, and the
covered TypeError text. Fresh AHK evidence included focused red `Crc32`
failing because `stdlib.binascii.crc32` was absent, focused green passing 1/1
in 0 ms, full `stdlib/tests/binascii.test.ahk` passing 3/3 in 15 ms, and
`run-ahk-validate -Path stdlib/examples/binascii.ahk -TimeoutSeconds 90`
passing. The earlier
`binascii` slice continues to cover lowercase bytes-to-bytes hex encoding,
bytes and ASCII-string hex decode input, covered one-byte separator handling,
covered bool-like and integer `bytes_per_sep` grouping including zero and
negative values, and the observed local arity/type/value-error wording for
missing arguments, too many positional arguments, text passed where bytes are
required, bad separator length, non-length-like separators, non-integer
`bytes_per_sep`, odd-length decode strings, invalid hex digits, and
non-bytes/non-ASCII decode payloads. To keep the public root budget stable at
57 slots, another native-quarantine slot has been reclaimed in favor of this
concrete Python stdlib root.

`stdlib.quopri` is now direct as a first slice of Python 3.10.11 `quopri`,
promoted onto the public Python-path root as `stdlib.quopri.*`. The current
slice covers `encodestring(s, quotetabs := False, header := False)` and
`decodestring(s, header := False)` for the observed local baseline:
bytes-to-bytes quoted-printable encoding and decoding, covered header-mode
space and underscore handling, covered tab and trailing-whitespace quoting,
covered hex escape and soft line-break decoding, ASCII-string decode input,
and the observed local arity/type/value-error wording for missing arguments,
too many positional arguments, text passed where bytes are required on
encode, non-bytes/non-ASCII decode payloads, and non-integer-like flag
arguments. To keep the public root budget stable at 57 slots, another
native-quarantine slot has been reclaimed in favor of this concrete Python
stdlib root.

`stdlib.html` is now direct as a first slice of Python 3.10.11 `html`,
promoted onto the public Python-path root as `stdlib.html.*`. The current
slice covers `escape(s, quote := True)` and `unescape(s)` for the observed
local baseline that is practical in AHK v2: `&`, `<`, `>`, double-quote, and
single-quote escaping with covered bool-like `quote` handling, plus named and
numeric entity unescaping for the probe-covered local cases such as `&amp`,
`&nbsp;`, `&#62;`, and `&#x27;`. Covered error wording also follows the local
Python 3.10.11 baseline for missing arguments, too many positional arguments,
non-string `escape(...)` payloads raising `'... object has no attribute
'replace'`, and non-string `unescape(...)` payloads raising
`TypeError("argument of type '...' is not iterable")`. To keep the public root
budget stable at 57 slots, another native-quarantine slot has been reclaimed
in favor of this concrete Python stdlib root.

`stdlib.secrets` is now direct as a first slice of Python 3.10.11 `secrets`,
promoted onto the public Python-path root as `stdlib.secrets.*`. The current
slice covers `choice(sequence)`, `randbelow(exclusiveUpperBound)`,
`token_bytes(nbytes := 32)`, `token_hex(nbytes := 32)`, and
`compare_digest(left, right)` for the observable local baseline that is
practical in AHK v2. Covered behavior currently matches local Python 3.10.11
for list and string `choice(...)`, Python-style `IndexError` wording for empty
list and empty string input, Python-style no-`len()` `TypeError` wording for a
covered non-sequence integer input, `randbelow(1) == 0`, bool-as-int acceptance
for `randbelow(True)`, zero-bound `ValueError("Upper bound must be positive.")`,
the observed local `AttributeError` wording for float input, the observed local
`NoneType` comparison wording for `stdlib.None`, default 32-byte token
generation, explicit-length token generation including zero-length outputs,
Python-style `ValueError("negative argument not allowed")` for negative token
lengths, lowercase hexadecimal encoding for `token_hex(...)`, and covered
string-vs-string / bytes-vs-bytes `compare_digest(...)` equality plus mixed
text/bytes and bad-arity `TypeError` wording. Wider helpers such as
`token_urlsafe(...)`, direct `SystemRandom`, and deeper bytes-like protocol
coverage remain deferred. To keep the public root budget stable at 57 slots,
the old `stateflow` placeholder has been removed from the root-slot manifest
count until there is a concrete `concurrent.futures`-style Python root plan
worth promoting back into the public budget.

`stdlib.os` is treated as a top-level module object so that the Python-like
call shape is `stdlib.os.system(command)`. Future path APIs should mount as
`stdlib.pathlib` or another explicit top-level namespace, not as an
include-order-sensitive child such as `stdlib.os.pathlib`.

`stdlib.platform` is now direct as a first Windows-focused slice of Python
3.10.11 `platform`, promoted from the old `wmi` candidate slot but exposed on
the public Python-path root as `stdlib.platform.*`. The current slice covers
`system()`, `node()`, `release()`, `version()`, `machine()`, `processor()`,
`python_version()`, `python_implementation()`, `platform(aliased?, terse?)`,
`uname()`, `architecture(executable?, bits?, linkage?)`, and
`system_alias(system, release, version)` for the observed local Windows 3.10.11
baseline. Covered behavior currently matches the local probe for Windows root
strings such as `Windows`, host node name, `10` release, raw `A_OSVersion`
version text, `AMD64` machine, `PROCESSOR_IDENTIFIER` processor text,
`Windows-10-...-SP0` default `platform()` formatting, `Windows-10` terse
formatting, the six-field iterable `uname_result` shape with processor stored
but omitted from repr, and the observed architecture tuple slice
`("64bit", "WindowsPE")` plus `("", "")` linkage override behavior when both
string arguments are explicitly blank. Covered arity errors now also follow the
local Python 3.10.11 wording for zero-argument accessors, `platform(...)`, and
`system_alias(...)`.

`stdlib.socket` is now direct as a first runtime slice of Python 3.10.11
`socket`, promoted from the old `online` candidate slot but exposed on the
public Python-path root as `stdlib.socket.*`. The current slice covers module
constants `AF_INET`, `SOCK_STREAM`, `IPPROTO_TCP`, and `has_ipv6`,
`gethostname()`, and a minimal `socket.socket(...)` object with covered default
construction, covered keyword-object construction, `.family`, `.type`, `.proto`,
`.closed`, `.fileno()`, `.close()`, and `__Repr()` behavior. Covered behavior
currently matches the local Windows 3.10.11 probe for host name, default
`AF_INET`/`SOCK_STREAM`/`proto=0` sockets, explicit `proto=IPPROTO_TCP`
keyword construction, `fileno() == -1` after close, and the observed
`_socket.gethostname()` arity wording plus unexpected-keyword wording for the
covered AHK keyword-object adapter.

`stdlib.abc` is direct as a Python 3.10.11 `abc` slice, promoted from the old
`std` candidate slot but exposed on the public Python-path root as
`stdlib.abc.*`. The current alphabetical restart prioritizes public function
coverage over fine parameter-corner parity. Fresh Python 3.10.11 evidence from
`.codex/abc_public_surface_probe.py` confirms the public names `ABC`,
`ABCMeta`, `abstractmethod`, `abstractstaticmethod`, `abstractclassmethod`,
`abstractproperty`, `get_cache_token`, and `update_abstractmethods`. The AHK
surface now exposes all of those names, with `ABCMeta` mapped to the current
AHK `ABC` carrier, the three legacy abstract descriptor helpers marking their
wrapper objects and covered underlying callables according to the probe, and
`update_abstractmethods(cls)` returning `cls` while refreshing the current AHK
abstract-method cache when a class opts into that cache. AHK helper
`stdlib.abc.issubclass(subclass, cls)` now accompanies
`stdlib.abc.isinstance(instance, cls)` for the covered virtual-subclass checks.
The current functional-surface slice also covers `ABCMeta.__subclasshook__`
semantics through AHK-visible no-tail `static __subclasshook(subclass)` methods:
`True` accepts a class for both `issubclass(...)` and `isinstance(...)`,
`False` rejects even an actual subclass, `stdlib.NotImplemented` falls back to
ordinary inheritance / virtual registry checks, and any other return value
raises `stdlib.assert.AssertionError("__subclasshook__ must return either False, True, or NotImplemented")`.
Fresh Python 3.10.11 evidence includes `.codex/abc_subclasshook_probe.py` and
`.codex/abc_subclasshook_probe.output.json`. Fresh AHK evidence includes
focused red `.codex/abc-subclasshook-red-report.txt` failing because
`issubclass(...)` did not dispatch the hook, focused green
`.codex/abc-subclasshook-green-focused-report.txt` passing 1/1 after adding hook
dispatch and instance-class recovery, module green
`.codex/abc-subclasshook-module-report.txt` passing `stdlib/tests/abc.test.ahk`
7/7, and root smoke `.codex/abc-subclasshook-root-filter-report.txt` passing
1/1 at `TimeoutSeconds 90`. Follow-up serial gates
`.codex/abc-subclasshook-validate-report.txt` and
`.codex/abc-subclasshook-example-report.txt` validated the changed AHK files and
captured `stdlib/examples/abc.ahk` without warning/error.
The current register-cycle follow-up uses fresh Python 3.10.11 evidence from
`.codex/abc_register_cycle_probe.py` plus
`.codex/abc_register_cycle_probe.output.json` confirming that registering a
base class as a virtual subclass of its child raises
`RuntimeError("Refusing to create an inheritance cycle")`, while self-register
and foreign virtual registration still return the registered class. The AHK
surface now refuses the same virtual inheritance cycle before mutating the
registry or cache token. Fresh AHK evidence includes focused red
`.codex/abc-register-cycle-red-report.txt` failing because no exception was
thrown, focused green `.codex/abc-register-cycle-green-focused-report.txt`
passing 1/1, module green `.codex/abc-register-cycle-module-report.txt`
passing `stdlib/tests/abc.test.ahk` 8/8, root filter
`.codex/abc-register-cycle-root-filter-report.txt` passing 1/1, changed-file
validate `.codex/abc-register-cycle-validate-report.txt` passing, and example
capture `.codex/abc-register-cycle-example-report.txt` loading
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
The current virtual-registry transitivity follow-up uses fresh Python 3.10.11
evidence from `.codex/abc_virtual_registry_transitive_probe.py` plus
`.codex/abc_virtual_registry_transitive_probe.output.json` confirming that
`Root.register(Mid)` and `Mid.register(Leaf)` make `Leaf`, `Leaf()` and a real
`RealLeaf extends Leaf` visible through `Root`, with each first registration
incrementing the cache token by one. The AHK registry lookup now recursively
checks registered ABC registries while guarding cycles with an internal visited
map, and instance checks recover the current prototype's class before using the
same virtual-registry relation. Fresh AHK evidence includes focused red
`.codex/abc-virtual-registry-transitive-red-report.txt` failing because
`issubclass(Leaf, Root)` was false, focused green
`.codex/abc-virtual-registry-transitive-green-focused-report.txt` passing 1/1,
module green `.codex/abc-virtual-registry-transitive-module-report.txt` passing
`stdlib/tests/abc.test.ahk` 10/10, root filter
`.codex/abc-virtual-registry-transitive-root-filter-report.txt` passing 11/11,
changed-file validate `.codex/abc-virtual-registry-transitive-validate-report.txt`
passing, and example capture
`.codex/abc-virtual-registry-transitive-example-report.txt` loading
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
The current abstract-instantiation follow-up uses fresh Python 3.10.11 evidence
from `.codex/abc_abstract_instantiation_probe.py` plus
`.codex/abc_abstract_instantiation_probe.output.json` confirming that
`abc.ABC` subclasses with non-empty `__abstractmethods__` raise
`TypeError("Can't instantiate abstract class ... with abstract method need")`,
concrete overrides instantiate normally, and dynamically added abstract methods
only affect instantiation after `abc.update_abstractmethods(cls)`. The AHK
surface now checks `AhkStdlibAbstractMethods` from the inherited
`AhkStdlibAbcBase.__New` path and blocks covered abstract class construction
with the same observable message shape. This covers classes that use the
stdlib ABC carrier and preserve its construction path; full Python metaclass
mechanics remain unclaimed. Fresh AHK evidence includes focused red
`.codex/abc-abstract-instantiation-red-report.txt` failing because abstract
instantiation threw nothing, focused green
`.codex/abc-abstract-instantiation-green-focused-report.txt` passing 1/1,
module green `.codex/abc-abstract-instantiation-module-report.txt` passing
`stdlib/tests/abc.test.ahk` 11/11, root filter
`.codex/abc-abstract-instantiation-root-filter-report.txt` passing 12/12,
changed-file validate `.codex/abc-abstract-instantiation-validate-report.txt`
passing, and example capture
`.codex/abc-abstract-instantiation-example-report.txt` loading
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
The register-decorator coverage follow-up uses fresh Python 3.10.11 evidence
from `.codex/abc_register_decorator_probe.py` plus
`.codex/abc_register_decorator_probe.output.json` confirming that
`@Root.register` returns the decorated class, increments the cache token once,
and makes decorated instances virtual instances of `Root`. The AHK coverage
uses `stdlib.decorate(Target, (cls) => Root.register(cls))`, matching the
observable decorator result while respecting AHK's unbound class-method
reference semantics. This slice was a coverage addition rather than an
implementation fix: focused
`.codex/abc-register-decorator-focused-report.txt` passed 1/1, module
`.codex/abc-register-decorator-module-report.txt` passed
`stdlib/tests/abc.test.ahk` 12/12, root filter
`.codex/abc-register-decorator-root-filter-report.txt` passed 13/13,
changed-file validate `.codex/abc-register-decorator-validate-report.txt`
passed, and captured example
`.codex/abc-register-decorator-example-report.txt` loaded
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
The current `abstractproperty` follow-up uses fresh Python 3.10.11 evidence from
`.codex/abc_abstractproperty_probe.py` plus
`.codex/abc_abstractproperty_probe.output.json` confirming that zero-argument,
one-argument, and four-argument construction is accepted, missing
`fget`/`fset`/`fdel` slots are `None`, non-callable `fget` values are accepted
at construction time, wrapper objects report `__isabstractmethod__ == True`,
and five positional arguments raise
`TypeError("property() takes at most 4 arguments (5 given)")`. The AHK surface
now exposes AHK-visible no-tail `__isabstractmethod`, stores missing slots as
`stdlib.None`, and provides explicit `Get(instance)`, `Set(instance, value)`,
and `Delete(instance)` helpers for the currently supported descriptor-like
property operations. Fresh AHK evidence includes focused red
`.codex/abc-abstractproperty-red-report.txt` failing because zero-argument
construction still raised a missing-`fget` error, focused green
`.codex/abc-abstractproperty-green-focused-report.txt` passing 1/1 with
constructor, non-callable, and getter/setter/deleter assertions, module green
`.codex/abc-abstractproperty-module-report.txt` passing
`stdlib/tests/abc.test.ahk` 8/8, root filter
`.codex/abc-abstractproperty-root-filter-report.txt` passing 9/9, changed-file
validate `.codex/abc-abstractproperty-validate-report.txt` passing, and example
capture `.codex/abc-abstractproperty-example-report.txt` loading
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
The current descriptor-helper error slice uses fresh Python 3.10.11 evidence
from `.codex/abc_descriptor_helpers_probe.py` plus
`.codex/abc_descriptor_helpers_probe.output.json` confirming that
`abstractmethod(1)`, `abstractstaticmethod(1)`, and `abstractclassmethod(1)`
raise `AttributeError("'int' object has no attribute '__isabstractmethod__'")`,
while missing / extra `abstractstaticmethod` and `abstractclassmethod`
arguments use the probed `abstractstaticmethod.__init__()` /
`abstractclassmethod.__init__()` TypeError text. The AHK surface now marks
abstract-capable AHK objects without requiring callability at construction time
and raises the same probed AttributeError for primitive values. Fresh AHK
evidence includes focused red
`.codex/abc-descriptor-helper-errors-red-report.txt` failing because
`abstractmethod(1)` still raised TypeError, focused green
`.codex/abc-descriptor-helper-errors-green-focused-report.txt` passing 1/1,
module green `.codex/abc-descriptor-helper-errors-module-report.txt` passing
`stdlib/tests/abc.test.ahk` 9/9, root filter
`.codex/abc-descriptor-helper-errors-root-filter-report.txt` passing 10/10,
changed-file validate `.codex/abc-descriptor-helper-errors-validate-report.txt`
passing, and example capture
`.codex/abc-descriptor-helper-errors-example-report.txt` loading
`stdlib/examples/abc.ahk` without warning/error at `TimeoutSeconds 90`.
Fresh Python 3.10.11 evidence from
`.codex/abc_update_abstractmethods_probe.py` and
`.codex/abc_update_abstractmethods_probe.output.json` confirms that
`update_abstractmethods(cls)` recomputes inherited abstract-method state,
concrete subclass implementations clear same-name abstract methods inherited
from a base class, same-name abstract overrides remain abstract, subclasses
without an override inherit the abstract method, non-class inputs are returned
unchanged, and the function returns the original class object.
Fresh AHK evidence for this update slice includes focused red
`.codex/abc-update-override-red-20260606.txt` failing because a concrete
subclass override was still treated as abstract, focused green
`.codex/abc-update-override-green-focused-20260606.txt` passing 1/1 after
tracking seen subclass members while walking prototype ancestry, full
`.codex/abc-update-override-final-green-20260606.txt` passing
`stdlib/tests/abc.test.ahk` 6/6, root smoke
`.codex/abc-update-override-stdlib-focused-20260606.txt` passing
`stdlib/tests/stdlib.test.ahk` 232/232, and validation
`.codex/abc-update-override-validate-20260606.txt` passing `stdlib/abc.ahk`,
`stdlib/tests/abc.test.ahk`, `stdlib/tests/stdlib.test.ahk`, and
`stdlib/examples/abc.ahk` at `TimeoutSeconds 90`.
The earlier cache-token slice remains covered:
`.codex/abc_cache_register_probe.py` confirmed that
`get_cache_token()` returns an `int`, rejects positional arguments as
`_abc.get_cache_token() takes no arguments (1 given)`, first registration of a
new virtual subclass increments the token by one, duplicate registration leaves
the token unchanged, registering a second distinct subclass increments it
again, `ABC.register(ABC)` returns the ABC itself without token invalidation,
and missing / extra / non-class register calls use the probed Python error
text. Fresh CPython 3.10.11 virtual-registry evidence from
`.codex/abc_virtual_registry_python310_probe.py` plus JSON output confirms that
`ABC.register(Foreign)` leaves `Foreign.__bases__` and `Foreign.__mro__`
unchanged while `issubclass(Foreign, ABC)` and `isinstance(Foreign(), ABC)`
become true, real subclasses remain true, unrelated classes remain false, the
first register increments the cache token by one, and duplicate register leaves
the token unchanged. Fresh AHK evidence for this registry slice includes
focused red `.codex/abc-virtual-registry-red-report.txt` failing because
`ABC.register(...)` reparented the AHK prototype, focused green
`.codex/abc-virtual-registry-green-focused-report.txt` passing 1/1 after
switching to a virtual registry, full
`.codex/abc-virtual-registry-final-green-report.txt` passing
`stdlib/tests/abc.test.ahk` 5/5, root smoke
`.codex/abc-virtual-registry-stdlib-focused-report.txt` passing 1/1, and
`.codex/abc-virtual-registry-final-validate-report.txt` validating
`stdlib/abc.ahk`, `stdlib/tests/abc.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/abc.ahk`.
Earlier AHK evidence for the public-surface slice includes focused red
`TestPublicAbstractHelpersAndUpdateAbstractMethods` failing because
`stdlib.abc.ABCMeta` was absent, focused green passing 1/1 in 0 ms, full
`stdlib/tests/abc.test.ahk` passing 4/4 in 15 ms, and `run-ahk-validate -Path
stdlib/examples/abc.ahk -TimeoutSeconds 90` passing. This does not claim full
Python metaclass instantiation or descriptor binding parity; those parameter
and type-system edges stay in the maintenance backlog.

`ahktest` is the first-class stdlib test framework. It must grow toward
pytest 7.4.3 capability parity under AHK v2 constraints before broad module
migration, because every future Python-compatible stdlib module should be
specified through ahktest tests first. Current direct `ahktest` capabilities
include isolated suites, static test collection, parametrized cases with ids
and merged option/row marks,
runtime skips, conditional skips, expected-failure tracking, exception message
matching, deep equality for arrays/maps, approximate comparisons, regex/contains
assertions, explicit function-scope and suite-scoped fixtures, autouse fixtures,
structured results, max-fail run control, fixture cleanup, filter/list runs,
temporary directory fixtures, reversible environment monkeypatching, marker
metadata/filtering, source-location helpers, warning capture helpers,
child-process stdout/stderr capture helpers, summary selectors,
config-backed and JSON-manifest-backed run defaults, lifecycle hooks with priority/id controls,
request-like fixture parameter access, and temporary directory helpers.
This is progress toward parity, not a declaration that pytest equivalence is
complete.

Current practical estimate: ahktest is strong enough to start foundational
stdlib modules in parallel with further test-framework work. It covers the
core behaviors needed for pure modules and file/process smoke tests
(collection, parametrization, fixtures, temp paths, monkeypatch, capture,
marks, skip/xfail, approximate comparisons, warnings, filtering, reporting,
and hooks), but it is still not close to full pytest equivalence. Remaining
high-value gaps are filesystem discovery/config policy, richer assertion diffs,
warning-module integration, fixture/request edge cases, and plugin metadata.

`stdlib.base` remains a support-surface module rather than a Python-path
module, but it now carries one concrete Python-adjacent helper:
`stdlib.base.delattr(obj, name)`. The current direct slice removes own AHK
object properties through a stable public `stdlib.module.func(...)` shape,
raises Python-style `attribute name must be string, not 'int'` messages for
non-string attribute names, preserves readonly-property failures from
underlying AHK objects such as `functools.partial(...).func`, and raises
Python-style `'<type>' object has no attribute '<name>'` messages for missing
or non-object targets. This gives the stdlib surface a public deletion helper
without introducing a root-level `stdlib.del(...)` entrypoint that would break
the current module-oriented API policy.

`stdlib.datetime` is now direct as a first slice centered on
`stdlib.datetime.timedelta(...)`, `stdlib.datetime.date(...)`, and a first
`stdlib.datetime.datetime(...)` slice. The current public shape covers
normalized `timedelta` construction from an AHK object or `Map` with
Python-named duration components, readonly `.days` / `.seconds` /
`.microseconds` observations, `total_seconds()`, string formatting that
matches the local Python 3.10.11 baseline for covered cases, Python-style
component type errors and overflow checks, and arithmetic/comparison/unary
behavior through `stdlib.operator` dispatch (`add`, `sub`, `mul`, `neg`,
`pos`, `gt`, and related helpers). The `date` slice currently covers direct
construction, `today`, `min`, `max`, `resolution`, `fromordinal`,
`fromtimestamp`, `fromisoformat`, `toordinal`, `isoformat`, `ctime`, `weekday`,
`isoweekday`, `isocalendar`, `replace`, and `date +/- timedelta` plus
`date - date` behavior through the same operator dispatch path. The current
`datetime` slice covers direct construction, `now`, `utcnow`,
`fromtimestamp`, `utcfromtimestamp`, `fromisoformat`, `today`, `ctime()`,
`strftime()` (including `%f`), `isoformat(timespec?)`, `date()`, `time()`
returning a direct `time` object, `datetime.time(...)`,
`datetime.combine(date, time)`,
`time.fromisoformat(...)`, `time.isoformat(timespec?)`,
`time.min/max/resolution`, `time.replace(...)`, `time` rich comparison,
`replace(...)`, `datetime +/- timedelta`, `datetime - datetime`, rich
comparison, and Python-style cross-type equality/inequality behavior
through `stdlib.operator`. The latest public-surface slice adds module
constants `MINYEAR` and `MAXYEAR`, `tzinfo()`, `timezone(...)`, and
`timezone.utc`: fresh CPython 3.10.11 probe
`.codex/datetime_timezone_surface_probe.py` plus JSON output confirmed
`datetime.__all__`, `MINYEAR == 1`, `MAXYEAR == 9999`, `tzinfo` base methods
raising `NotImplementedError`, `tzinfo.fromutc(None)` raising
`TypeError("fromutc: argument must be a datetime")`, `timezone.utc` string/name
and zero offset behavior, named fixed-offset timezone behavior for `IST`
`+05:30`, generated negative offset names such as `UTC-04:00`, and covered
constructor errors. Focused red
`.codex/datetime-timezone-surface-red-report.txt` failed because
`stdlib.datetime.MINYEAR` was absent; focused green
`.codex/datetime-timezone-surface-green-focused-report.txt` passed 1/1; full
module `.codex/datetime-timezone-surface-final-green-report.txt` passed
`stdlib/tests/datetime.test.ahk` 32/32 at `TimeoutSeconds 90`; root smoke
`.codex/datetime-timezone-surface-stdlib-focused-report.txt` passed 1/1;
validation `.codex/datetime-timezone-surface-validate-report.txt` passed
`stdlib/datetime.ahk`, `stdlib/tests/datetime.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/datetime.ahk` at
`TimeoutSeconds 90`. This slice does not claim full aware `datetime` / `time`
integration, `fold`, `astimezone`, or complete timezone arithmetic.

Other modules remain `candidate`, `missing`, or `native-quarantine` until
promoted through the same red-green flow.

`stdlib.fractions` is now direct as a first slice of Python 3.10.11
`fractions`. The current slice covers `Fraction(...)` construction and
normalization, numerator/denominator observability, Python-style `str`/`repr`,
basic arithmetic and comparison through `stdlib.operator`, integer interop for
the covered arithmetic/comparison paths, covered native-float arithmetic and
comparison parity where local Python returns `float`, float conversion including
`Fraction.from_float(...)`, `as_integer_ratio()`, `limit_denominator(...)`,
unary/truth behavior, and Python 3.10 style constructor errors.

`stdlib.decimal` is now direct as a first slice of Python 3.10.11 `decimal`.
The current slice covers `Decimal(...)` construction from strings and integers,
preserved decimal/trailing-zero formatting, Python-style `repr`, basic
addition/subtraction/multiplication/division/floor-division/modulo/comparison through `stdlib.operator`,
integer interop for the covered arithmetic paths, unary/truth behavior,
`normalize()` including scientific-notation cases such as `500.000 -> 5E+2`,
finite-result decimal division such as `1.25 / 2 -> 0.625` and
`2 / Decimal("0.5") -> 4`, default-precision repeating-result division parity
for cases such as `1 / 3`, `2 / 3`, and `1 / 6` using Python's 28-digit
context behavior, preserved trailing-zero significance such as
`Decimal("1.00") / Decimal("2") -> 0.50`, covered comparison parity against
`Fraction` values for Python-valid `eq/ne/lt/le/gt/ge` paths, plus covered `//`
and `%` parity including integer interop, sign behavior, DivisionByZero on
`// 0`, and InvalidOperation on `% 0`, and Python 3.10 style invalid string
and dict-construction errors. Cross-type `Decimal`/`Fraction` arithmetic
remains unsupported, matching local Python 3.10.11. The latest public-surface
slice adds rounding constants, limit constants, `HAVE_CONTEXTVAR`,
`HAVE_THREADS`, signal exception classes, `Context(...)`, `DefaultContext`,
`BasicContext`, `ExtendedContext`, `getcontext()`, `setcontext(...)`, and
`localcontext(...)`. Fresh CPython 3.10.11 probe
`.codex/decimal_context_surface_probe.py` plus JSON output confirmed rounding
constant values, context defaults and custom attributes, flag/trap map sizes,
`getcontext` / `setcontext` / `localcontext` precision behavior, context
argument errors, and public signal exception relationships. Focused red
`.codex/decimal-context-surface-red-report.txt` failed because
`stdlib.decimal.ROUND_CEILING` was absent; focused green
`.codex/decimal-context-surface-green-focused-report.txt` passed 1/1; full
module `.codex/decimal-context-surface-final-green-report.txt` passed
`stdlib/tests/decimal.test.ahk` 7/7 at `TimeoutSeconds 90`; root smoke
`.codex/decimal-context-surface-stdlib-focused-report.txt` passed 1/1;
validation `.codex/decimal-context-surface-validate-report.txt` passed
`stdlib/decimal.ahk`, `stdlib/tests/decimal.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/decimal.ahk` at
`TimeoutSeconds 90`. This slice exposes the context/signals surface but does
not yet claim complete signal trapping, rounding-mode execution across all
arithmetic, `DecimalTuple`, or the full `Context` method suite.

`stdlib.logging` is now direct as a first slice of Python 3.10.11 `logging`.
The current slice exposes numeric level constants, `getLogger()`,
`basicConfig(...)`, module-level `debug(...)` / `info(...)` / `warning(...)` /
`error(...)` / `critical(...)` / `fatal(...)`, root/named logger objects with `name`, `level`,
`handlers`, `setLevel(...)`, `getEffectiveLevel()`, `isEnabledFor(...)`,
`debug(...)`, `info(...)`, `warning(...)`, `error(...)`, `critical(...)`, and `fatal(...)`, plus formatted
`%(levelname)s:%(name)s:%(message)s` stream output through a minimal
`StreamHandler`/`Formatter` path. The public direct surface now also exposes
`stdlib.logging.Formatter(...)`, `stdlib.logging.StreamHandler(...)`, and a
first direct `stdlib.logging.FileHandler(path, mode := "a", encoding := "UTF-8")`
slice. `basicConfig(...)` accepts a Python-style `format` string for the
initial root handler formatter and now also covers the observed Python 3.10.11
file-backed root setup slice through `filename`, `filemode`, and `encoding`,
including truncating behavior for `filemode := "w"` and the
`ValueError("'stream' and 'filename' should not be specified together")`
conflict path when both root-target options are provided on a fresh
configuration run. Fresh-root `basicConfig({ handlers: [handler, ...] })` now
also follows the observed Python 3.10.11 handler-list slice by installing the
same passed-in handler objects onto the root logger, supplying the default
`%(levelname)s:%(name)s:%(message)s` formatter only when a passed handler does
not already have one, preserving preconfigured handler formatters, and raising
`ValueError("'stream' or 'filename' should not be specified together with 'handlers'")`
when the handler-list path is mixed with `stream` or `filename`. The current direct handler slice also supports
`handler.setLevel(...)` filtering, `handler.close()`, formatter substitution of
`%(levelno)s` alongside `%(levelname)s`, `%(name)s`, and `%(message)s`, and
basic file-backed append/write logging behavior through `FileHandler`.
Covered handler lists now also accept broader iterable inputs beyond plain
arrays, matching the observed Python 3.10.11 behavior where `handlers=` can be
supplied as other iterables such as tuples or generator-backed iterables; the
current AHK direct slice accepts stdlib tuple-like arrays and custom
`__Enum`-backed iterables, materializes their handler objects, and then applies
the same default-formatter/preserved-formatter rules as the array path.
The direct behavior currently matches Python's
root-name normalization (`None`, `""`, and `"root"` all resolve to the root
logger), effective-level inheritance for named loggers, and `basicConfig(...)`
being a no-op after handlers already exist on the root logger unless
`force := true` is supplied. Covered `basicConfig({ ..., force: true })` now
follows the observed Python 3.10.11 root-reconfiguration slice by replacing
existing root handlers with the newly requested stream/file-backed handler,
closing prior file-backed root handlers so the old log target is released, and
letting removed stream-backed handlers leave caller-owned in-memory streams
readable after reconfiguration. The current
level-handling slice also accepts Python level-name strings such as `"INFO"`
and `"DEBUG"` for `basicConfig(level := ...)` and `logger.setLevel(...)`,
accepts the Python alias names `"WARN"` and `"FATAL"` alongside the
corresponding `stdlib.logging.WARN` and `stdlib.logging.FATAL` constants, and
raises Python-style `ValueError("Unknown level: 'NOPE'")` for unknown names on
fresh configuration paths. It also now
matches Python's named-logger no-handler fallback behavior: a named logger can
emit a bare message to stderr without auto-installing root handlers, but only
for `WARNING` and above, while the module-level logging helpers still
auto-configure the root logger and emit formatted output. Richer handler
classes and file-based configuration remain deferred. The current logger slice
now also exposes Python-style `logger.propagate` behavior: named loggers
default to propagation through ancestor handlers, so a child logger with its
own handler can duplicate emission into both the child and root streams, while
setting `logger.propagate := false` stops delivery to ancestor handlers without
falling back to the root logger.

`stdlib.queue` is now direct as a first slice of Python 3.10.11 `queue`.
The current slice exposes `stdlib.queue.Queue(maxsize := 0)`, `stdlib.queue.SimpleQueue()`,
`stdlib.queue.LifoQueue(maxsize := 0)`, `stdlib.queue.PriorityQueue(maxsize := 0)`, plus public
`stdlib.queue.Empty` and `stdlib.queue.Full` exception classes. Covered behavior includes `qsize()`,
`empty()`, `full()`, `put(...)`, `get(...)`, `put_nowait()`, and `get_nowait()`,
bounded-queue `Full` / empty-queue `Empty` parity for `block := false` and
`timeout := 0`, Python-style `ValueError("'timeout' must be a non-negative number")`
for negative timeout values on blocking calls, Python-style `timeout=None`
handling through `stdlib.None` for covered ready and non-blocking queue paths,
Python's unbounded behavior for
`maxsize <= 0`, Python-style passthrough `maxsize` observability for non-integer
constructor values such as `1.5`, `"1"`, and `None`, Python-style `full()`
comparison failures for unsupported `maxsize` values like `'<' not supported
between instances of 'int' and 'str'`, and covered task accounting through
`unfinished_tasks` plus `task_done()` including
`ValueError("task_done() called too many times")`, plus `join()` returning once
all unfinished tasks are complete for `Queue`, `LifoQueue`, and `PriorityQueue`,
while `SimpleQueue` currently
covers FIFO `put/get/put_nowait/get_nowait`, `qsize()/empty()`, empty-queue
`Empty` parity, Python 3.10.11 `put(...)` compatibility parameters that ignore
`block` and `timeout` including negative or non-numeric timeout values, and
Python-style negative-timeout `ValueError` on blocking `get(...)`,
and `LifoQueue` currently covers stack-order `put/get/put_nowait/get_nowait`,
`qsize()/empty()/full()`, bounded `Full` / empty `Empty` parity, and the same
covered timeout validation shape as `Queue`, and `PriorityQueue` currently covers
min-priority `put/get/put_nowait/get_nowait`, numeric and covered list-priority
ordering, `qsize()/empty()/full()`, bounded `Full` / empty `Empty` parity, and the
same covered timeout validation shape as `Queue`.

`stdlib.asyncio` is now direct as a Python 3.10.11 `asyncio` slice. The current
restart treats `asyncio` as a hard module that needs a real single-threaded
cooperative scheduler, not just public-name stubs. Fresh Python 3.10.11 evidence
from `.codex/asyncio_policy_queue_surface_probe.py` confirmed covered public
constants, event-loop policy/current-loop helpers, running-loop helper behavior,
queue nowait ordering, and public exception class shapes. Fresh evidence from
`.codex/asyncio_core_loop_probe.py` confirmed `call_soon` before
`call_later(0)`, handle cancellation, deferred `Future.add_done_callback(...)`
execution on the next loop tick, `remove_done_callback(...) == 0` for a missing
callback, `run_until_complete(...)` returning finished values and propagating
exceptions, `sleep(0, result=...)`, and `gather(...)` result ordering. The AHK
surface now includes cooperative `EventLoop` ready/timer queues, `Handle` /
`TimerHandle`, `create_future()`, `call_soon(...)`, `call_later(...)`,
`call_at(...)`, `time()`, `is_running()`, `is_closed()`, `close()`,
`call_soon_threadsafe(...)`, `run_until_complete(...)`, `run_forever()`,
`stop()`, Future done-callback
registration/removal/scheduling, `asyncio.sleep(...)`, and `asyncio.gather(...)`
for covered Future inputs, plus `Queue`, `PriorityQueue`, and `LifoQueue`
nowait operations. The current `gather(...)` follow-up uses fresh Python
3.10.11 evidence from `.codex/asyncio_gather_return_exceptions_probe.py` plus
`.codex/asyncio_gather_return_exceptions_probe.output.json` confirming default
exception propagation, `return_exceptions=True` result collection, and empty
gather result behavior. The AHK surface accepts the project-standard keyword
object form `stdlib.asyncio.gather(a, b, { return_exceptions: true })`, collects
child `Error` objects into result slots, and preserves the default propagation
path. Fresh AHK evidence includes focused red
`.codex/asyncio-gather-return-exceptions-red-report.txt` erroring because the
options object was treated as an awaitable, focused green
`.codex/asyncio-gather-return-exceptions-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-gather-return-exceptions-module-green-report.txt`
passing `stdlib/tests/asyncio.test.ahk` 16/16, root smoke
`.codex/asyncio-gather-return-exceptions-stdlib-root-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 233/233, and validation
`.codex/asyncio-gather-return-exceptions-validate-report.txt` passing
`stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/asyncio.ahk` at
`TimeoutSeconds 90`. The latest lifecycle/time slice uses fresh Python 3.10.11
evidence from `.codex/asyncio_loop_lifecycle_time_probe.py` plus JSON output to
cover `loop.time()` returning a float, initial / running / post-run / closed
`is_running()` and `is_closed()` states, `call_at(loop.time(), ...)`,
delayed `call_at(...)` timer scheduling, `call_at(...)` returning
`TimerHandle`, `close()` returning `None`, and closed-loop `call_soon(...)` /
`run_until_complete(...)` raising `RuntimeError("Event loop is closed")`.
Fresh AHK evidence includes focused red
`.codex/asyncio-loop-lifecycle-red-report.txt` failing because
`AhkStdlibAsyncioEventLoop` had no `time()` method, focused green
`.codex/asyncio-loop-lifecycle-green-focused-report.txt` passing 1/1, full
module `.codex/asyncio-loop-lifecycle-final-green-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 15/15, root smoke
`.codex/asyncio-loop-lifecycle-stdlib-focused-report.txt` passing 1/1, and
`.codex/asyncio-loop-lifecycle-validate-report.txt` validating
`stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/asyncio.ahk` at
`TimeoutSeconds 90`. The `run_coroutine_threadsafe(...)` slice uses fresh Python
3.10.11 evidence from `.codex/asyncio_run_coroutine_threadsafe_probe.py` and
`.codex/asyncio_run_coroutine_threadsafe_probe.json` to cover the public
function's arity/bad-coro/bad-loop errors, initial pending state, result
completion after loop ticks, exception propagation, and cancellation. The AHK
implementation is intentionally a single-threaded bridge: `call_soon_threadsafe`
is the current loop's scheduling alias and `run_coroutine_threadsafe(...)`
returns a covered `stdlib.asyncio.Future`, not a claim of Python
`concurrent.futures.Future` blocking/thread parity. Fresh AHK evidence includes
focused red `CoreEventLoopFutureCallbacksSleepAndGather` failing because
`EventLoop.call_soon_threadsafe` was absent, focused green passing 1/1 in 0 ms,
full `stdlib/tests/asyncio.test.ahk` passing 14/14 in 16 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing after the example was updated with the single-threaded bridge. The
follow-up Future-combinator slice uses fresh Python
3.10.11 evidence from `.codex/asyncio_future_combinators_probe.py` to cover
Future-input `ensure_future(...)` identity, `shield(...)`, `wait(...)`,
`wait_for(...)` including timeout cancellation, `as_completed(...)`, and
task-registry queries returning `None` / empty sets when no Task exists. A
small `wrap_future(...)` follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_wrap_future_probe.py` and
`.codex/asyncio_wrap_future_probe.json` to cover asyncio-Future identity for
default and explicit loop calls plus the probed missing/extra/bad-type errors;
`concurrent.futures.Future` bridge behavior remains backlog because this
stdlib tree does not yet expose a `concurrent.futures` module. Fresh
AHK evidence for that slice includes focused red
`FutureCombinatorsForSingleThreadedCore` failing because
`stdlib.asyncio.ensure_future` was absent, focused green passing 1/1 in 0 ms,
later focused red failing because `stdlib.asyncio.wrap_future` was absent,
focused green passing 1/1 in 0 ms, full `stdlib/tests/asyncio.test.ahk`
passing 14/14 in 47 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing. The next Task slice uses fresh Python 3.10.11 evidence from
`.codex/asyncio_task_core_probe.py` and
`.codex/asyncio_run_introspection_probe.py` to cover cooperative
AHK-step awaitables as `Task` inputs: `loop.create_task(...)`, module-level
`asyncio.create_task(...)` only inside a running loop, `asyncio.run(...)`,
`asyncio.iscoroutine(...)`, `asyncio.iscoroutinefunction(...)`,
`asyncio.current_task(...)`, `asyncio.all_tasks(...)`, awaiting `sleep(0)` and
child tasks, Task result / exception / cancellation state, and Python 3.10.11's
observed deferred cancellation settlement. A small `asyncio.coroutine(...)`
follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_coroutine_probe.py` and
`.codex/asyncio_coroutine_probe.json` to cover the deprecated public decorator's
arity errors, plain-callable wrapping into a coroutine-function, and identity
preservation when the AHK callable already returns a covered step-awaitable;
Python generator/native coroutine object parity remains backlog. Fresh AHK evidence for this slice
includes focused red `TaskDrivesCooperativeAwaitables...` failing because
`AhkStdlibAsyncioEventLoop.create_task` was absent, focused green passing 1/1
in 0 ms, focused red `RunCreateTaskAndCoroutineIntrospection...` failing
because `stdlib.asyncio.iscoroutine` was absent, focused green passing 1/1 in
0 ms, later focused red failing because `stdlib.asyncio.coroutine` was absent,
focused green passing 1/1 in 0 ms, and full `stdlib/tests/asyncio.test.ahk`
passing 14/14 in 31 ms. This
Task surface is intentionally single-threaded and protocol-based: it supports
AHK objects with `AhkStdlibAsyncioStep(...)` as awaitables, but does not claim
native Python `async def` syntax compatibility. The follow-up synchronization
slice for `asyncio.to_thread(...)` uses fresh Python 3.10.11 evidence from
`.codex/asyncio_to_thread_probe.py` plus
`.codex/asyncio_to_thread_probe.output.json` confirming the public signature
`(func, /, *args, **kwargs)`, coroutine return shape, callable result delivery,
exception propagation, missing-`func` TypeError, bad-callable TypeError, and
Python's real worker-thread identity difference. The AHK surface now removes
the previous NotImplemented placeholder for AHK callables: awaiting
`stdlib.asyncio.to_thread(func, args*)` calls the supplied callable, returns its
result, propagates callable errors through the asyncio Future/Task path, and
raises `TypeError("'int' object is not callable")` for primitive non-callables.
This slice does not yet claim Python's real background-thread identity or
`**kwargs` parity; those remain the next hard offload bridge tasks. Fresh AHK
evidence includes focused red
`.codex/asyncio-to-thread-callable-red-report.txt` erroring because awaiting
`to_thread(...)` still raised NotImplementedError, focused green
`.codex/asyncio-to-thread-callable-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-to-thread-callable-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 25/25, root filter
`.codex/asyncio-to-thread-callable-root-filter-report.txt` passing 27/27,
changed-file validate `.codex/asyncio-to-thread-callable-validate-report.txt`
passing, and example capture
`.codex/asyncio-to-thread-callable-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The follow-up synchronization
slice uses fresh Python 3.10.11 evidence from `.codex/asyncio_sync_queue_probe.py`
to cover `Lock`, `Event`, `Semaphore`, `BoundedSemaphore`, and async
`Queue.put(...)` / `Queue.get(...)` / `Queue.join()` / `Queue.task_done()`
waiter behavior. Fresh AHK evidence includes focused red
`SyncPrimitivesAndAsyncQueueWaiters...` failing because `stdlib.asyncio.Lock`
was absent, focused green passing 1/1 in 0 ms, full
`stdlib/tests/asyncio.test.ahk` passing 10/10 in 0 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing after the example was expanded to exercise cooperative lock, event,
semaphore, and queue paths.
The subsequent Condition slice uses fresh Python 3.10.11 evidence from
`.codex/asyncio_condition_probe.py` to cover `Condition.acquire()`,
`release()`, `locked()`, `wait()`, `notify()`, `notify_all()`, and unlocked
wait/notify/release errors. Fresh AHK evidence includes focused red
`ConditionWaitNotifyAndErrors...` failing because `stdlib.asyncio.Condition`
was absent, focused green passing 1/1 in 0 ms, and full
`stdlib/tests/asyncio.test.ahk` passing 11/11 in 16 ms. The same implementation
added Task exception reinjection through `AhkStdlibAsyncioThrow(...)` so
awaited Future failures can be handled by cooperative AHK-step awaitables. The
asyncio tests now use `stdlib.await(...)` for test-side waiting, while a
dedicated `TestEventLoopRunUntilCompleteReturnAndExceptionLikeLocal310` keeps
direct `EventLoop.run_until_complete(...)` return/exception assertions where
that API itself is under test; fresh AHK evidence for this simplification is
`stdlib/tests/asyncio.test.ahk` passing 13/13 in 32 ms at `TimeoutSeconds 90`.
The next wait-combinator slice uses fresh Python 3.10.11
evidence from `.codex/asyncio_wait_pending_probe.py` to cover pending
`asyncio.wait(...)` completion after all inputs finish, non-zero
`wait_for(...)` timeout cancellation, pending `wait_for(...)` success, and
`as_completed(...)` result ordering through coroutine-like awaitable wrappers.
Fresh AHK evidence includes focused red
`WaitWaitForAndAsCompletedResolvePendingInputsLikeLocal310` failing because
`wait(...)` returned pending inputs immediately, focused green passing 1/1 in
32 ms, full `stdlib/tests/asyncio.test.ahk` passing 12/12 in 31 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing after the example was updated to consume `as_completed(...)` through
`stdlib.await(...)`.
The Windows child-watcher surface slice uses fresh Python 3.10.11 evidence from
`.codex/asyncio_child_watcher_probe.py` and
`.codex/asyncio_child_watcher_probe.json` to cover public
`asyncio.get_child_watcher()` and `asyncio.set_child_watcher(watcher)` on the
local Windows policy: arity errors use the observed Python wording, while the
supported-arity calls raise `NotImplementedError`. Fresh AHK evidence includes
focused red `TestChildWatcherSurfaceMatchesLocalWindows310` failing because the
public functions were absent, focused green passing 1/1 in 0 ms, full
`stdlib/tests/asyncio.test.ahk` passing 14/14 in 31 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing after the example was updated to show the covered
`NotImplementedError` branch.
The earlier cooperative-core AHK evidence includes focused red
`CoreEventLoopFutureCallbacksSleepAndGather` failing because
`AhkStdlibAsyncioEventLoop.call_soon` was absent, focused green passing 1/1 in
0 ms, full `stdlib/tests/asyncio.test.ahk` passing 6/6 in 0 ms, and
`run-ahk-validate -Path stdlib/examples/asyncio.ahk -TimeoutSeconds 90`
passing. The earlier Future slice continues to cover construction,
`Future.get_loop()`, pending/finished/cancelled state transitions,
`cancel(msg)`, `result()`, `exception()`, `set_result(...)`,
`set_exception(...)`, covered repr shapes, and `asyncio.isfuture(...)`.
The current exception-class slice uses fresh Python 3.10.11 evidence from
`.codex/asyncio_exception_classes_probe.py` plus
`.codex/asyncio_exception_classes_probe.output.json` to cover direct public
exception constructors. `IncompleteReadError(partial, expected)` now extends
root `EOFError`, stores `.partial` and `.expected`, and generates the observed
`"3 bytes read on a total of ... expected bytes"` message including the
`undefined` wording for `expected=None`; `LimitOverrunError(message, consumed)`
stores `.consumed` while preserving the message. Fresh AHK evidence includes
focused red `.codex/asyncio-exception-classes-red-report.txt` failing because
`IncompleteReadError` was not an `EOFError`, focused green
`.codex/asyncio-exception-classes-green-focused-report.txt` passing 1/1, module
green `.codex/asyncio-exception-classes-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 25/25, and root filter
`.codex/asyncio-exception-classes-root-filter-report.txt` passing 2/2 at
`TimeoutSeconds 90`. Follow-up serial gates
`.codex/asyncio-exception-classes-validate-report.txt` and
`.codex/asyncio-exception-classes-example-report.txt` validated the changed AHK
files and captured `stdlib/examples/asyncio.ahk` without warning/error.
The earlier network/subprocess coroutine-surface follow-up uses fresh Python 3.10.11
evidence from `.codex/asyncio_missing_coroutine_surface_probe.py` plus
`.codex/asyncio_missing_coroutine_surface_probe.output.json` confirming
`asyncio.open_connection(...)`, `asyncio.start_server(...)`,
`asyncio.create_subprocess_exec(...)`, and
`asyncio.create_subprocess_shell(...)` exist and return Python coroutine
objects when called. The earlier AHK surface exposed the network entry points
as covered step-awaitables but still raised `NotImplementedError` when awaited;
that public surface placeholder has now been superseded by the localhost TCP
runtime slice below. Fresh historical AHK evidence for the public-name surface
includes focused red
`.codex/asyncio-missing-coroutine-surface-red-report.txt` failing because
`stdlib.asyncio.open_connection` was absent, focused green
`.codex/asyncio-missing-coroutine-surface-green-focused-report.txt` passing
1/1, module green `.codex/asyncio-missing-coroutine-surface-module-report.txt`
passing `stdlib/tests/asyncio.test.ahk` 17/17, root filter
`.codex/asyncio-missing-coroutine-surface-root-filter-report.txt` passing
2/2, and example capture `.codex/asyncio-missing-coroutine-surface-example-report.txt`
loading `stdlib/examples/asyncio.ahk` without warning/error.
The current network follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_network_probe.py` plus `.codex/asyncio_network_probe.output.json`
confirming a localhost TCP echo path: `asyncio.start_server(...)` returns a
serving `Server` with a bound `127.0.0.1` socket, `asyncio.open_connection(...)`
returns `StreamReader` / `StreamWriter`, the client can write `hello`, the
server handler reads it and writes `HELLO`, and `server.close()` flips
`is_serving()` to false. The AHK surface now implements the covered IPv4
localhost TCP path through Winsock-backed nonblocking polling in the existing
single-threaded event loop, creates real `StreamReader` / `StreamWriter` pairs,
and starts handler step-awaitables as tasks. This slice does not claim DNS,
IPv6, SSL, Unix sockets, socket options, full transport/protocol APIs, or
production-grade selector/proactor semantics. Fresh AHK evidence includes
focused red `.codex/asyncio-network-red-report.txt` erroring because
`asyncio.start_server()` still raised `NotImplementedError`, focused green
`.codex/asyncio-network-green-focused-report.txt` passing 1/1, module green
`.codex/asyncio-network-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 31/31, root filter
`.codex/asyncio-network-root-filter-report.txt` passing 33/33, changed-file
validate `.codex/asyncio-network-validate-report.txt` passing, and captured
example `.codex/asyncio-network-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The TCP stream extra-info follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_network_extra_info_probe.py` plus
`.codex/asyncio_network_extra_info_probe.output.json` confirming
`StreamWriter.get_extra_info("sockname")` and `"peername"` return localhost
address tuples with integer ports on both client and server sides, missing keys
return `None`, and missing keys with an explicit default return that default.
The AHK socket transport now exposes the covered `sockname` / `peername`
metadata through Winsock `getsockname` / `getpeername` while preserving default
fallback behavior for unknown keys. This slice does not claim the full
transport metadata catalog. Fresh AHK evidence includes focused red
`.codex/asyncio-network-extra-info-red-report.txt` erroring because
`get_extra_info("sockname")` returned the `None` sentinel, focused green
`.codex/asyncio-network-extra-info-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-network-extra-info-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 32/32, root filter
`.codex/asyncio-network-extra-info-root-filter-report.txt` passing 34/34,
changed-file validate `.codex/asyncio-network-extra-info-validate-report.txt`
passing, and captured example
`.codex/asyncio-network-extra-info-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The current subprocess follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_subprocess_wait_probe.py` plus
`.codex/asyncio_subprocess_wait_probe.output.json` confirming that awaiting
`asyncio.create_subprocess_exec(...)` and `asyncio.create_subprocess_shell(...)`
returns a `Process` object with integer `pid`, `returncode is None` before
`await process.wait()`, and `wait()` returns and stores the process exit code.
The AHK surface now starts hidden Windows child processes through
`CreateProcessW`, returns `AhkStdlibAsyncioProcess`, exposes `pid` and
AHK-visible `returncode`, and implements `Process.wait()` as a covered
awaitable using `WaitForSingleObject` / `GetExitCodeProcess`. This slice does
not yet claim stdout/stderr pipes, `communicate()`, signal, terminate, kill, or
network stream parity. Fresh AHK evidence includes focused red
`.codex/asyncio-subprocess-wait-red-report.txt` erroring because
`create_subprocess_exec(...)` still awaited to NotImplementedError, focused
green `.codex/asyncio-subprocess-wait-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-subprocess-wait-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 26/26, root filter
`.codex/asyncio-subprocess-wait-root-filter-report.txt` passing 28/28,
changed-file validate `.codex/asyncio-subprocess-wait-validate-report.txt`
passing, and example capture `.codex/asyncio-subprocess-wait-example-report.txt`
loading `stdlib/examples/asyncio.ahk` without warning/error at
`TimeoutSeconds 90`.
The subprocess pipe follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_subprocess_communicate_probe.py` plus
`.codex/asyncio_subprocess_communicate_probe.output.json` confirming
`asyncio.subprocess.PIPE == -1`, `stdout=PIPE` and `stderr=PIPE` expose
`StreamReader` objects, `await process.communicate()` returns captured stdout
and stderr bytes, updates `returncode`, and no-pipe `communicate()` returns
`[None, None]`. The AHK surface now exposes `stdlib.asyncio.subprocess.PIPE`,
accepts the project-standard trailing options object
`{ stdout: stdlib.asyncio.subprocess.PIPE, stderr: ... }`, starts hidden
Windows child processes with inherited temporary output handles, and returns
captured stdout/stderr as Buffers from `Process.communicate()`. This slice does
not yet claim stdin input, `STDOUT`, `DEVNULL`, streaming reads from the
returned `StreamReader` placeholders, or signal/terminate/kill behavior. Fresh
AHK evidence includes focused red
`.codex/asyncio-subprocess-communicate-red-report.txt` erroring because
`stdlib.asyncio.subprocess.PIPE` was absent, focused green
`.codex/asyncio-subprocess-communicate-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-subprocess-communicate-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 27/27, root filter
`.codex/asyncio-subprocess-communicate-root-filter-report.txt` passing 29/29,
changed-file validate
`.codex/asyncio-subprocess-communicate-validate-report.txt` passing, and
example capture `.codex/asyncio-subprocess-communicate-example-report.txt`
loading `stdlib/examples/asyncio.ahk` without warning/error at
`TimeoutSeconds 90`.
The subprocess stdin-pipe follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_subprocess_stdin_probe.py` plus
`.codex/asyncio_subprocess_stdin_probe.output.json` confirming that
`stdin=asyncio.subprocess.PIPE` exposes a `StreamWriter`, `communicate(input)`
writes bytes to the child process, returns captured stdout/stderr bytes, updates
`returncode`, and raises `AttributeError("'NoneType' object has no attribute
'write'")` when input is supplied without a stdin pipe. The AHK surface now
accepts `{ stdin: stdlib.asyncio.subprocess.PIPE }`, creates an inherited child
stdin read pipe plus a parent write handle, exposes `process.stdin` as an
`AhkStdlibAsyncioStreamWriter`, and closes stdin after writing
`Process.communicate(input)`. This slice still does not claim `STDOUT`,
`DEVNULL`, interactive streaming reads from the returned pipe placeholders, or
signal/terminate/kill behavior. Fresh AHK evidence includes focused red
`.codex/asyncio-subprocess-stdin-red-report.txt` erroring because
`AhkStdlibAsyncioProcess` had no `stdin` property, focused green
`.codex/asyncio-subprocess-stdin-green-focused-report.txt` passing 1/1, module
green `.codex/asyncio-subprocess-stdin-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 28/28, root filter
`.codex/asyncio-subprocess-stdin-root-filter-report.txt` passing 30/30,
changed-file validate `.codex/asyncio-subprocess-stdin-validate-report.txt`
passing, and captured example
`.codex/asyncio-subprocess-stdin-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The subprocess lifecycle-control follow-up uses fresh Python 3.10.11 evidence
from `.codex/asyncio_subprocess_lifecycle_probe.py` plus
`.codex/asyncio_subprocess_lifecycle_probe.output.json` confirming that on the
local Windows runtime `Process.terminate()`, `Process.kill()`, and
`Process.send_signal(signal.SIGTERM)` all return `None`, and after
`await wait()` leave `returncode == 1`. The AHK surface now exposes
`terminate()`, `kill()`, and `send_signal(signal)` on real
`AhkStdlibAsyncioProcess` objects and routes the covered Windows behavior
through `TerminateProcess(..., 1)`. Non-termination signal semantics beyond the
covered `SIGTERM`/exit-code path remain unclaimed. Fresh AHK evidence includes focused red
`.codex/asyncio-subprocess-lifecycle-red-report.txt` erroring because
`AhkStdlibAsyncioProcess` had no `terminate` method, focused green
`.codex/asyncio-subprocess-lifecycle-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-subprocess-lifecycle-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 29/29, root filter
`.codex/asyncio-subprocess-lifecycle-root-filter-report.txt` passing 31/31,
changed-file validate
`.codex/asyncio-subprocess-lifecycle-validate-report.txt` passing, and captured
example `.codex/asyncio-subprocess-lifecycle-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The follow-up completed the already-exited process error branch with fresh
Python 3.10.11 evidence from `.codex/asyncio_subprocess_process_lookup_probe.py`
plus `.codex/asyncio_subprocess_process_lookup_probe.output.json` confirming
that `ProcessLookupError("")` is an `OSError`, has an empty message, and is
raised by `terminate()`, `kill()`, and `send_signal(15)` after a process has
already exited with returncode `0`. The AHK surface now exposes root
`stdlib.ProcessLookupError` and raises it from `AhkStdlibAsyncioProcess`
control methods when `returncode` is already set or the Windows process is no
longer active. Fresh AHK evidence includes root focused red
`.codex/process-lookup-root-red-report.txt` erroring because the root namespace
had no `ProcessLookupError`, asyncio focused red
`.codex/asyncio-subprocess-process-lookup-red-report.txt` erroring for the same
missing root class, root focused green
`.codex/process-lookup-root-green-focused-report.txt` passing 1/1, asyncio
focused green `.codex/asyncio-subprocess-process-lookup-green-focused-report.txt`
passing 1/1, module green
`.codex/asyncio-subprocess-process-lookup-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 31/31, root filter
`.codex/asyncio-subprocess-process-lookup-root-filter-report.txt` passing
33/33, changed-file validate
`.codex/asyncio-subprocess-process-lookup-validate-report.txt` passing, and
captured examples `.codex/process-lookup-example-init-report.txt` and
`.codex/asyncio-subprocess-process-lookup-example-asyncio-report.txt` loading
the init and asyncio examples without warning/error at `TimeoutSeconds 90`.
The subprocess stdio-constant follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_subprocess_constants_probe.py` plus
`.codex/asyncio_subprocess_constants_probe.output.json` confirming
`asyncio.subprocess.PIPE == -1`, `STDOUT == -2`, `DEVNULL == -3`, stderr
merged into stdout when `stderr=STDOUT`, stdout/stderr discarded and returned
as `None` when redirected to `DEVNULL`, and stdin `DEVNULL` causing an immediate
EOF returncode of `0` for the covered child. The AHK surface now implements
`stderr: stdlib.asyncio.subprocess.STDOUT` by reusing the child stdout handle
and implements `stdin`/`stdout`/`stderr: stdlib.asyncio.subprocess.DEVNULL` via
inheritable Windows `NUL` handles. This slice still does not claim interactive
streaming pipe transports beyond the covered `communicate()` capture path.
Fresh AHK evidence includes focused red
`.codex/asyncio-subprocess-constants-red-report.txt` failing because stderr was
not merged and leaked to the captured test stderr, focused green
`.codex/asyncio-subprocess-constants-green-focused-report.txt` passing 1/1,
module green `.codex/asyncio-subprocess-constants-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 30/30, root filter
`.codex/asyncio-subprocess-constants-root-filter-report.txt` passing 32/32,
changed-file validate
`.codex/asyncio-subprocess-constants-validate-report.txt` passing, and captured
example `.codex/asyncio-subprocess-constants-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The public import-surface follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_public_surface_names_probe.py` plus
`.codex/asyncio_public_surface_names_probe.output.json` confirming that local
`dir(asyncio)` includes 107 public names and that the previously missing
submodule names are module objects with `__name__` values such as
`asyncio.events`, `asyncio.streams`, and `sys`; it also records the public
class signatures for `IocpProactor`, `StreamReader`,
`StreamReaderProtocol`, and `StreamWriter`. The AHK surface exposes the
missing public submodule names as lightweight module placeholders with AHK
no-tail `.__name` metadata. That import-surface slice did not claim real stream
runtime behavior by itself. Fresh AHK evidence includes focused red
`.codex/asyncio-public-surface-red-report.txt` failing because
`stdlib.asyncio.base_events` was absent, focused green
`.codex/asyncio-public-surface-green-focused-report.txt` passing 1/1, module
green `.codex/asyncio-public-surface-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 18/18, root filter
`.codex/asyncio-public-surface-root-filter-report.txt` passing 2/2, example
capture `.codex/asyncio-public-surface-example-report.txt` passing while also
asserting the example source contains no `System.Text.RegularExpressions` /
`MatchEvaluator` pollution, and validation
`.codex/asyncio-public-surface-validate-report.txt` passing
`stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`, and
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`.
The stream follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_stream_behavior_probe.py` plus
`.codex/asyncio_stream_behavior_probe.output.json` to cover observable
`StreamReader`, `StreamReaderProtocol`, and `StreamWriter` behavior instead of
class-name placeholders. Covered `StreamReader` behavior now includes
`feed_data(...)`, `feed_eof()`, `at_eof()`, `read(0)`, `read(n)` returning
available bytes without waiting to fill `n`, `read()` after EOF, `readline()`,
`readexactly(n)`, `readuntil(separator)`, and `IncompleteReadError` carrying
no-tail AHK-visible `.partial` and `.expected` fields. Covered protocol/writer
behavior includes `StreamReaderProtocol.data_received(...)` /
`eof_received()` feeding the reader and `StreamWriter` delegating
`write(...)`, `writelines(...)`, `write_eof()`, `can_write_eof()`, `close()`,
`is_closing()`, `get_extra_info(...)`, and immediate-complete `drain()` to an
AHK transport object. Fresh AHK evidence includes focused red
`.codex/asyncio-stream-red-report.txt` failing because `StreamReader()` still
returned `AhkStdlibAsyncioPublicClassInstance`, focused green
`.codex/asyncio-stream-green-focused-report.txt` passing 1/1, stream-focused
`.codex/asyncio-streams-focused-report.txt` passing 2/2, module green
`.codex/asyncio-streams-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 20/20, root filter
`.codex/asyncio-streams-root-filter-report.txt` passing 2/2, example validate
`.codex/asyncio-streams-example-validate-report.txt` passing, and changed-file
validate `.codex/asyncio-streams-validate-report.txt` passing
`stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`, and
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`.
The IocpProactor follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_iocp_proactor_lifecycle_probe.py` plus
`.codex/asyncio_iocp_proactor_lifecycle_probe.output.json` to cover the
no-socket lifecycle portion of `asyncio.IocpProactor`: signature
`(concurrency=4294967295)`, `IocpProactor(0)` and `IocpProactor(1)`
construction, the observed public method names, empty `select(0)` /
`select(0.001)` results, `set_loop(None)`, idempotent `close()`, and the
closed-proactor `select(0)` TypeError
`GetQueuedCompletionStatus() argument 1 must be int, not None`. The AHK surface
now exposes a real `AhkStdlibAsyncioIocpProactor` lifecycle object with those
covered behaviors and controlled `NotImplementedError` for pipe/file operations
and other socket variants that remain backlog. Fresh AHK evidence includes
focused red `.codex/asyncio-iocp-proactor-red-report.txt` erroring because
`IocpProactor(0)` was rejected, focused green
`.codex/asyncio-iocp-proactor-green-focused-report.txt` passing 1/1, module
green `.codex/asyncio-iocp-proactor-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 21/21, root filter
`.codex/asyncio-iocp-proactor-root-filter-report.txt` passing 2/2, and
changed-file validate `.codex/asyncio-iocp-proactor-validate-report.txt`
passing `stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`, and
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`. The asyncio example now
exercises construction, empty `select(...)`, `set_loop(...)`, repeated
`close()`, and the closed-select error path.
The IocpProactor socket-ops follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_iocp_socket_ops_probe.py` plus
`.codex/asyncio_iocp_socket_ops_probe.output.json` confirming that a manually
pumped `asyncio.IocpProactor` returns `_OverlappedFuture` objects for
`connect(sock, address)`, `send(sock, bytes)`, and `recv(sock, n)`, with
observable results of the socket object itself, sent byte count `4`, and
received bytes `PING` over a localhost TCP echo server. The AHK surface now
covers the public `stdlib.asyncio.IocpProactor.connect/send/recv` path for
`stdlib.socket.socket()` TCP sockets using Winsock-backed awaitables integrated
with `stdlib.await(...)`; this is a covered single-threaded emulation of the
observable result protocol, not a claim of true Windows IOCP overlapped
completion internals. Fresh AHK evidence includes focused red
`.codex/asyncio-iocp-socket-ops-red-report.txt` erroring because
`IocpProactor.connect()` still raised `NotImplementedError`, focused green
`.codex/asyncio-iocp-socket-ops-green-focused-report.txt` passing 1/1, module
green `.codex/asyncio-iocp-socket-ops-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 33/33, root filter
`.codex/asyncio-iocp-socket-ops-root-filter-report.txt` passing 35/35,
changed-file validate `.codex/asyncio-iocp-socket-ops-validate-report.txt`
passing, and captured example
`.codex/asyncio-iocp-socket-ops-example-report.txt` loading
`stdlib/examples/asyncio.ahk` without warning/error at `TimeoutSeconds 90`.
The protocol/transport base follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_protocol_transport_base_probe.py` plus
`.codex/asyncio_protocol_transport_base_probe.output.json` to cover another
set of class-object placeholders. `BaseProtocol`, `Protocol`,
`DatagramProtocol`, `SubprocessProtocol`, and `BufferedProtocol` now construct
distinct AHK objects and cover the observed no-op callback methods:
`connection_made(...)`, `connection_lost(...)`, `pause_writing()`,
`resume_writing()`, `data_received(...)`, `eof_received()`,
`datagram_received(...)`, `error_received(...)`, `pipe_data_received(...)`,
`pipe_connection_lost(...)`, `process_exited()`, `get_buffer(...)`, and
`buffer_updated(...)`. `BaseTransport`, `ReadTransport`, `WriteTransport`,
`Transport`, `DatagramTransport`, and `SubprocessTransport` now construct
distinct base objects, cover `BaseTransport.get_extra_info(...)` for extra data
and defaults, and expose the observed abstract methods as
`stdlib.NotImplementedError` rather than missing-method failures. Real
network/subprocess transport implementations remain backlog. Fresh AHK
evidence includes protocol focused red `.codex/asyncio-protocol-red-report.txt`
failing because `Protocol()` still returned `AhkStdlibAsyncioBaseProtocol`,
transport focused red `.codex/asyncio-transport-red-report.txt` erroring
because `BaseTransport(extra)` rejected the extra argument, focused green
`.codex/asyncio-protocol-green-focused-report.txt` and
`.codex/asyncio-transport-green-focused-report.txt` each passing 1/1, module
green `.codex/asyncio-protocol-transport-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 23/23, root filter
`.codex/asyncio-protocol-transport-root-filter-report.txt` passing 2/2, and
changed-file validate `.codex/asyncio-protocol-transport-validate-report.txt`
passing `stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`, and
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`.
The server lifecycle follow-up uses fresh Python 3.10.11 evidence from
`.codex/asyncio_server_lifecycle_probe.py` plus
`.codex/asyncio_server_lifecycle_probe.output.json` to cover
`AbstractServer` and an empty-socket `Server` without claiming real socket
serving. `AbstractServer` now exposes the observed abstract method surface
(`close()`, `get_loop()`, `is_serving()`, `start_serving()`,
`serve_forever()`, and `wait_closed()`) as `stdlib.NotImplementedError`.
`Server` is no longer an alias to the abstract empty object: the covered
no-socket lifecycle stores `.sockets`, returns its loop from `get_loop()`,
tracks `is_serving()`, has `start_serving()` complete with `None`, returns a
pending Future from `serve_forever()`, cancels that Future on `close()`, and
settles `wait_closed()` after close. Fresh AHK evidence includes focused red
`.codex/asyncio-server-red-report.txt` failing because `AbstractServer` methods
were missing, focused green `.codex/asyncio-server-green-focused-report.txt`
passing 1/1, module green `.codex/asyncio-server-module-report.txt` passing
`stdlib/tests/asyncio.test.ahk` 24/24, root filter
`.codex/asyncio-server-root-filter-report.txt` passing 2/2, and changed-file
validate `.codex/asyncio-server-validate-report.txt` passing
`stdlib/asyncio.ahk`, `stdlib/tests/asyncio.test.ahk`, and
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`.
Native Python coroutine object interop, real stream/network/subprocess APIs,
thread handoff APIs, and full Python parameter/error parity remain explicit
maintenance backlog. Separately, the root namespace now includes the AHK-only
bridge `stdlib.await(awaitable, options?)`, implemented in `stdlib\init.ahk`,
which delegates covered asyncio awaitables to an explicit loop or to
`asyncio.run(...)` when no event loop is already running. Fresh AHK evidence
for this bridge includes focused red `stdlib root namespace await runs asyncio
awaitables` failing because `stdlib.await` was absent, focused green passing
1/1 in 15 ms, and validation of `stdlib/examples/init.ahk` plus
`stdlib/examples/asyncio.ahk` at `TimeoutSeconds 90`.
Fresh decorator-helper evidence includes CPython 3.10.11 probe
`.codex/init_decorator_order_python310_probe.py` plus JSON output confirming
`@outer` / `@inner` expands as `outer(inner(target))`; focused red
`.codex/init-decorator-red-report.txt` failing because `stdlib.decorate` was
absent; focused green `.codex/init-decorator-final-green-report.txt` passing
`stdlib/tests/init.test.ahk` 2/2; root smoke
`.codex/init-decorator-stdlib-final-focused-report.txt` passing
`stdlib/tests/stdlib.test.ahk` 1/1; and final validation
`.codex/init-decorator-final-validate-report.txt` covering `stdlib/init.ahk`,
`stdlib/tests/init.test.ahk`, `stdlib/tests/stdlib.test.ahk`, and
`stdlib/examples/init.ahk`.

`stdlib.tkinter` is now direct as a first Tcl/Tk-oriented slice of Python 3.10.11
`tkinter`, promoted onto the public Python-path root as `stdlib.tkinter.*`.
The current slice exposes covered module constants `TclVersion`, `TkVersion`,
`READABLE`, `WRITABLE`, `EXCEPTION`, the non-conflicting Python 3.10.11
geometry/state/selection/relief/orientation/scrolling constants, boolean-style
integer constants, and `wantobjects` (with `CHECKBUTTON` / `RADIOBUTTON`
unclaimed because they collide with constructor names in AHK), module functions
`stdlib.tkinter.NoDefaultRoot()`, `stdlib.tkinter.getint()`, `stdlib.tkinter.getdouble()`,
`stdlib.tkinter.getboolean(s)`, `stdlib.tkinter.image_names()`,
`stdlib.tkinter.image_types()`, and
`stdlib.tkinter.mainloop(...)`, plus `stdlib.tkinter.Event()`,
`stdlib.tkinter.EventType(value)`,
`stdlib.tkinter.CallWrapper(func, subst, widget)`,
`stdlib.tkinter.Pack()`, `stdlib.tkinter.Place()`,
`stdlib.tkinter.Grid()`, `stdlib.tkinter.XView()`,
`stdlib.tkinter.YView()`, `stdlib.tkinter.Misc()`,
`stdlib.tkinter.Wm()`,
`stdlib.tkinter.Tcl(...)`,
`stdlib.tkinter.Tk(...)`, `stdlib.tkinter.Variable(...)`,
`stdlib.tkinter.StringVar(...)`,
`stdlib.tkinter.IntVar(...)`, `stdlib.tkinter.DoubleVar(...)`,
`stdlib.tkinter.BooleanVar(...)`, `stdlib.tkinter.Frame(...)`,
`stdlib.tkinter.BaseWidget(...)`,
`stdlib.tkinter.Widget(...)`,
`stdlib.tkinter.Label(...)`, `stdlib.tkinter.LabelFrame(...)`,
`stdlib.tkinter.Toplevel(...)`, `stdlib.tkinter.Message(...)`,
`stdlib.tkinter.Button(...)`, `stdlib.tkinter.Menubutton(...)`,
`stdlib.tkinter.OptionMenu(...)`, `stdlib.tkinter.PanedWindow(...)`,
`stdlib.tkinter.Checkbutton(...)`,
`stdlib.tkinter.Radiobutton(...)`, `stdlib.tkinter.Scale(...)`,
`stdlib.tkinter.Scrollbar(...)`, `stdlib.tkinter.Menu(...)`,
`stdlib.tkinter.Entry(...)`, `stdlib.tkinter.Spinbox(...)`,
`stdlib.tkinter.Listbox(...)`,
`stdlib.tkinter.Text(...)`,
`stdlib.tkinter.Image(...)`, `stdlib.tkinter.BitmapImage(...)`,
`stdlib.tkinter.PhotoImage(...)`,
`stdlib.tkinter.Canvas(...)`, and public
`stdlib.tkinter.TclError`, plus the first covered themed-widget submodule
surfaces `stdlib.tkinter.ttk.Widget(...)`,
`stdlib.tkinter.ttk.Frame(...)`, `stdlib.tkinter.ttk.Label(...)`,
`stdlib.tkinter.ttk.Entry(...)`, `stdlib.tkinter.ttk.Spinbox(...)`,
`stdlib.tkinter.ttk.Menubutton(...)`,
`stdlib.tkinter.ttk.OptionMenu(...)`, `stdlib.tkinter.ttk.Combobox(...)`,
`stdlib.tkinter.ttk.Button(...)`, `stdlib.tkinter.ttk.Checkbutton(...)`,
`stdlib.tkinter.ttk.Radiobutton(...)`, `stdlib.tkinter.ttk.Scale(...)`, and
`stdlib.tkinter.ttk.Scrollbar(...)`,
plus `stdlib.tkinter.ttk.Separator(...)`,
`stdlib.tkinter.ttk.Progressbar(...)`, `stdlib.tkinter.ttk.Notebook(...)`,
`stdlib.tkinter.ttk.LabelFrame(...)`, `stdlib.tkinter.ttk.Panedwindow(...)`,
`stdlib.tkinter.ttk.Sizegrip(...)`,
`stdlib.tkinter.ttk.Labelframe(...)`,
`stdlib.tkinter.ttk.PanedWindow(...)`, and
`stdlib.tkinter.ttk.Treeview(...)`, plus
`stdlib.tkinter.ttk.Style(...)` and
`stdlib.tkinter.ttk.setup_master(...)` and
`stdlib.tkinter.ttk.tclobjs_to_py(...)`. The
covered behavior matches local Python 3.10.11 probing for `Tcl()` argument-count
and keyword/type-error wording, Tcl interpreter creation with explicit local
Tcl library discovery, `eval(...)`, `setvar(...)`, `getvar(...)`, `_root()`
string shape, Tcl missing variable errors, and the observed `StringVar(...)`
constructor, generated-name, named-variable, `get()`, and `set()` behaviors for
the covered master-backed cases. The covered variable constructor path now also
matches local probing for `str(variable)` returning the Tcl variable name,
retaining an existing named Tcl variable when `value` is omitted or `None`,
and generating a normal variable name when `name=""` is passed. `setvar(...)`
and `StringVar.set(...)` now write Python `None` as the string `"None"`.
`stdlib.tkinter.Variable(...)` exposes the same public constructor surface,
raw `get()` / `set(...)` behavior, and `initialize(...)` alias observed in
local Python 3.10.11; `initialize(...)` is also covered on `StringVar(...)`,
`IntVar(...)`, `DoubleVar(...)`, and `BooleanVar(...)` through the relevant
subclass conversion path. The
covered `IntVar(...)` slice matches the
local constructor signature `(master=None, value=None, name=None)`,
master/name/type-error wording, named-variable storage, `set()` returning
`None`, bool values becoming `1` / `0`, `"3.5"` reading back as integer `3`,
and invalid `"09"` / `"abc"` reads raising Tcl numeric parse errors.
`DoubleVar(...)` mirrors the same constructor surface and returns Tcl double
parses as floats, including `2` reading as `2.0` and invalid numeric strings
raising `TclError`. `BooleanVar(...)` stores Tcl boolean parses as `1` / `0`,
returns `stdlib.True` / `stdlib.False`, raises `TclError` from invalid `set()`
values, and raises `ValueError("invalid literal for getboolean()")` for invalid
underlying values read through `get()`. The
2026-06-01 local probe used
`F:\Python\Python310\python.exe` (`3.10.11`) and confirmed
`DLLs\tcl86t.dll`, `DLLs\tk86t.dll`, `tcl\tcl8.6`, and `tcl\tk8.6` exist.
`tkinter.Tcl(useTk=False).eval("info commands winfo")` returned `""`, while
`tkinter.Tcl(useTk=True)` returned `winfo` for that command and `8.6.12` for
`package require Tk`. The same probe confirmed `tkinter.Tk()` has a public
root-window constructor surface, returns a `Tk` object whose string form is
`.`, exposes `winfo`, reports `winfo exists .` as `1`, and whose `destroy()`
returns Python `None`. The first covered GUI/widget slice now verifies real
Tk-backed `Frame`, `Label`, and `Button` creation under a hidden `Tk` root,
including Python-style widget path strings such as `.!label` and
`.host.!button`, `_root()` identity, `winfo_exists()`, `cget("text")`,
`configure({ text: ... })`, `pack()`, `winfo_manager()`, widget `destroy()`,
and `Tk.title()` get/set behavior. The option-key slice adds `keys()` for
`Tk`, `Toplevel`, and representative Tk-backed widgets, returning Python-list
style arrays of option names in the same order as local Python 3.10.11
`configure` introspection and preserving the probed arity and destroyed-widget
errors. The classic display/container widget slice covers `Message(...)`,
`Menubutton(...)`, and `LabelFrame(...)` construction under an explicit master,
Python-style widget paths, `Message` `text` / `width` / `aspect` options,
`Menubutton` `text` / `direction` / `relief` / `menu` options with attached
`Menu` command invocation, `LabelFrame` `text` / `labelanchor` /
`labelwidget` / `width` / `height` options, child parent-path behavior,
`pack()`, `destroy()`, and the probed constructor / option `TclError` paths.
The `OptionMenu(...)` slice covers explicit-master construction, `StringVar`
`textvariable` binding, Python-style `.!optionmenu` path with `Menubutton`
Tk class, internal `Menu` exposure through `option["menu"]`, menu item label
creation for the first value and trailing values, menu command invocation
setting the bound variable before calling the optional command callback,
Python-compatible `"None"` menu invoke returns, default visual options, and
the probed missing-argument, invalid-master, and unknown-option errors.
The first toplevel-window slice now
matches local Python 3.10.11 probing for explicit-master `Toplevel(...)`
windows, including Python-style paths such as `.dialog`, `_root()` identity,
`winfo_exists()`, `winfo_manager()` returning `"wm"`, integer
`cget("width")` / `cget("height")`, `cget("bg")`, `title()` get/set,
`state()`, `withdraw()`, `iconify()`, `deiconify()`, child widget paths under the
toplevel, destroy behavior, and the probed constructor / Wm arity errors. The
first interactive `Button` slice now
matches the probed local Python 3.10.11 behavior for callable `command`
registration, `cget("command")` returning a registered Tcl command name,
`invoke()` executing the callback, no-command `invoke()` returning `""`,
callback `None` results returning `"None"`, string callback results passing
through, `configure({ command: callable })`, non-callable command values
remaining Tcl command names that raise `TclError("invalid command name ...")`
when invoked, and `Button.invoke()` arity validation. The first
`Checkbutton` control slice covers explicit-master
`Checkbutton(...)` construction, Python-style widget paths, variable binding
through `StringVar`, `cget("text")`, `cget("variable")`, `cget("onvalue")`,
`cget("offvalue")`, callable and non-callable `command` options,
`select()`, `deselect()`, `toggle()`, `invoke()`, `pack()`, destroy behavior,
no-command / `None` / string callback result handling, and the probed
constructor / method arity and bad-command `TclError` paths. The first
`Radiobutton` control slice covers explicit-master `Radiobutton(...)`
construction, Python-style widget paths, variable binding through `StringVar`,
`cget("text")`, `cget("variable")`, `cget("value")`, callable and
non-callable `command` options, `select()`, `deselect()`, `flash()`,
`invoke()`, `pack()`, destroy behavior, no-command / `None` / string callback
result handling, and the probed constructor / method arity and bad-command
`TclError` paths. The first `Scale` numeric-control slice covers
explicit-master `Scale(...)` construction, Python-style widget paths,
`from_` keyword-option mapping to Tcl's `from` option, `DoubleVar` variable
binding, float-valued `cget("from")`, `cget("to")`, and
`cget("resolution")`, integer `cget("length")`, `get()`, `set(value)`,
`coords(value := unset)`, `identify(x, y)`, `pack()`, destroy behavior,
callable `command` registration with Tcl argument forwarding for manually
invoked command names, and the probed constructor / method arity and invalid
floating-point `TclError` paths. The first `Scrollbar` control slice covers
explicit-master `Scrollbar(...)` construction, Python-style widget paths,
string-valued `cget("orient")`, `cget("command")`, and `cget("width")`,
float tuple `get()`, `set(first, last)`, `activate(index := unset)`,
`delta(deltax, deltay)`, `fraction(x, y)`, `identify(x, y)`, `pack()`,
destroy behavior, callable `command` registration with multi-argument Tcl
forwarding for manually invoked command names, and the probed constructor /
method arity and invalid floating-point `TclError` paths. The first `Menu`
command-entry slice covers explicit-master `Menu(...)` construction,
Python-style menu paths, integer `cget("tearoff")`, `cget("title")`,
`cget("type")`, `index(index)`, `type(index)`, `activate(index)`,
`add(itemType, cnf := unset)`, `add_command(...)`,
`add_cascade(cnf := unset)`,
`add_checkbutton(cnf := unset)`, `add_radiobutton(cnf := unset)`,
`add_separator(cnf := unset)`, `insert(index, itemType, cnf := unset)`,
`insert_cascade(index, cnf := unset)`,
`insert_checkbutton(index, cnf := unset)`,
`insert_command(index, cnf := unset)`,
`insert_radiobutton(index, cnf := unset)`,
`insert_separator(index, cnf := unset)`, `post(x, y)`, `unpost()`,
`yposition(index)`, `entrycget(index, option)`,
`entryconfigure(index)`, `entryconfigure(index, option)`,
`entryconfigure(index, options)`, `entryconfig(...)`, `invoke(index)`,
`delete(index1, index2 := unset)`, destroy behavior, callable `command` registration for
command entries, cascade submenu entries, checkbutton and radiobutton variable
entries, separator entries, generic and typed added entries, generic and helper
inserted entries, active-state mutation, insertion-order mutation, variable
mutation through `invoke(...)`, y-position queries, no-op unpost, entry type
queries, entry-configuration query/set behavior, disabled-entry invoke behavior, and the probed constructor / method
arity, bad-cnf, bad-option, bad-type, invalid-coordinate, and bad-index
`TclError` paths.
The next input-widget slice covers
`Entry(...)` with `StringVar` `textvariable` binding, `width` cget conversion,
`get()`, `insert(index, string)`, `delete(first, last := unset)`, `pack()`,
`winfo_manager()`, destroy behavior, and `Tk.update()` /
`Tk.update_idletasks()` returning `stdlib.None`. The cursor/selection
interaction slice covers `Entry.index(...)`, `Entry.icursor(...)`,
`select_range(...)` / `selection_range(...)`, `select_clear()` /
`selection_clear()`, `select_present()` / `selection_present()`,
`select_from(...)` / `selection_from(...)`, `select_to(...)` /
`selection_to(...)`, `select_adjust(...)` / `selection_adjust(...)`,
`selection_get()` text reads, no-selection `TclError`, bad entry-index
`TclError`, scan drag movement, XView movement/query behavior, and the probed
arity errors. The first `Spinbox(...)`
slice covers explicit-master construction, Python-style paths,
`StringVar` `textvariable` binding, integer `cget("width")`,
`get()`, `insert(index, s)`, `delete(first, last := unset)`,
`icursor(index)`, `index(index)`, `selection_range(start, end)`,
`selection_clear()`, `selection_present()`, `selection_get()`,
`invoke(element)`, `selection_element(element := unset)`, `bbox(index)`,
`identify(x, y)`, `xview()`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, callable command callbacks for spin-button
invocation, and the probed constructor / method arity and Tcl validation
errors. The first list-selection
widget slice covers `Listbox(...)` construction, Python-style paths,
`cget("height")` / `cget("width")` integer conversion, `cget("selectmode")`,
`size()`, `insert(index, *elements)`, `get(first, last := unset)`,
`index(index)`, `delete(first, last := unset)`, `curselection()`,
`selection_set(...)`, `selection_clear(...)`, `selection_includes(...)`,
`selection_anchor(index)`, Python-compatible `select_set(...)`,
`select_clear(...)`, `select_includes(...)`, and `select_anchor(...)` aliases,
`activate(index)`, `nearest(y)`, `see(index)`, `bbox(index)`,
`scan_mark(x, y)`,
`scan_dragto(x, y)`, `xview(...)`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, `yview(...)`, `yview_moveto(fraction)`,
`yview_scroll(number, what)`, `itemcget(index, option)`,
`itemconfigure(index, cnf_or_option := unset)`, `itemconfig(...)`, `pack()`,
destroy behavior, visual bbox integer tuple and non-visible `None` results,
and the probed constructor / method arity, bad-index, bad-integer, and
bad-option `TclError` paths. The first multiline `Text`
editing slice covers real Tk-backed `Text(...)` creation, integer
`cget("width")` / `cget("height")` conversion, `cget("wrap")`,
`get(index1, index2 := unset)`, `insert(index, chars, tags*)`,
`delete(index1, index2 := unset)`,
`replace(index1, index2, chars, *tags)`, `index(index)`,
`peer_create(newPathName, cnf := unset)`, `peer_names()`,
`dump(index1, index2 := unset, command := unset, **kw)`,
`debug(boolean := unset)`, `edit(*args)`, `edit_modified(arg := unset)`,
`edit_undo()`, `edit_redo()`, `edit_reset()`, `edit_separator()`,
`compare(index1, op, index2)`, `count(index1, index2, *args)`, `bbox(index)`,
`dlineinfo(index)`, `see(index)`, `scan_mark(x, y)`, `scan_dragto(x, y)`,
`search(pattern, index, stopindex := unset, forwards := unset, backwards := unset,
exact := unset, regexp := unset, nocase := unset, count := unset,
elide := unset)`,
`xview(...)`, `xview_moveto(fraction)`, `xview_scroll(number, what)`,
`yview(...)`, `yview_moveto(fraction)`, `yview_scroll(number, what)`,
`yview_pickplace(*what)`,
`mark_set(markName, index)`, `mark_unset(*markNames)`,
`mark_gravity(markName, direction := unset)`, `mark_names()`,
`mark_next(index)`, `mark_previous(index)`, `tag_add(tagName, index1, *args)`,
`tag_cget(tagName, option)`, `tag_configure(tagName, cnf := unset)`,
`tag_config(...)`, `tag_bind(tagName, sequence, func, add := unset)`,
`tag_unbind(tagName, sequence, funcid := unset)`,
`tag_remove(tagName, index1, index2 := unset)`, `tag_ranges(tagName)`,
`tag_names(index := unset)`,
`tag_nextrange(tagName, index1, index2 := unset)`,
`tag_prevrange(tagName, index1, index2 := unset)`,
`tag_raise(tagName, aboveThis := unset)`,
`tag_lower(tagName, belowThis := unset)`, and `tag_delete(*tagNames)`. It preserves Python-style
empty/end newline behavior, insert-cursor and end-index strings, visible-text
geometry tuple / non-visible `None` results, view mutation `None` returns,
view-query two-float tuples, yview pickplace visible-index movement and `None` returns, replace range mutation / insertion / deletion `None` returns, peer-name tuple results, peer creation `None` returns and shared-buffer behavior, dump list-of-triple tuple results and callback `None` returns, tag option string reads, tag configure tuple/dict results and mutation `None` returns, tag bind query strings/tuples, tag bind command ids, tag unbind `None` returns, debug boolean returns, edit modified/canundo/canredo integer flags, undo/redo/reset/separator return values, mark gravity query/set return values, tuple mark
name results, next/previous mark name or `None` results, bad-index,
bad-integer, search string returns and count-variable updates, count integer/tuple returns, compare boolean results, tag range/name tuples, tag-range mutation `None` returns,
missing-mark, and bad-gravity `TclError` paths, and the probed
arity errors. The first image-object slice covers
`PhotoImage(...)` creation under an explicit `master`, generated
Python-style `pyimageN` names, `width()`, `height()`, `type()`, string-valued
`cget(...)`, `config(...)`, `blank()`, `put(data, to=...)`, RGB tuple reads
through `get(x, y)`, image-backed `Label(..., { image: photo })` options, and
the probed first-slice arity / bad-coordinate `TclError` paths. The
PhotoImage transform/write slice covers `copy()`, `zoom(...)`,
`subsample(...)`, `write(...)`, `transparency_get(...)`, and
`transparency_set(...)`: copied images are new `PhotoImage` objects with the
same pixel data, zoom/subsample calls return dimension-adjusted images,
transparency calls return and set Python booleans, PNG writes create the
target file, and the probed arity plus Tcl validation errors are preserved.
The BitmapImage slice covers `BitmapImage(...)` creation with inline XBM
`data` and XBM `file` options under an explicit master, named image strings,
`width()`, `height()`, `type()`, `configure(...)`, image-backed
`Label(..., { image: bitmap })` options, image-registry membership, and the
probed constructor, image-method, bad-option, and bad-data errors.
The first drawable `Canvas`
slice covers real Tk-backed `Canvas(...)` creation, Python-style path strings,
raw string `cget("width")` / `cget("height")` values, `create_line(...)`,
`create_rectangle(...)`, numeric item ids, `coords(...)` returning Python-like
float lists and returning an empty list after coordinate mutation or deleted /
missing items, `itemcget(...)`, `itemconfigure(...)` returning `stdlib.None`,
and `delete(...)` returning `stdlib.None` for existing, missing, or omitted
item ids. The Canvas item discovery and movement slice covers `find_all()`,
`find_withtag(tagOrId)`, integer tuple item-id results, empty tuple missing-tag
results, `bbox(...)` integer tuple results, missing-item `None`, `type(...)`
string / `None` results, `move(...)` coordinate mutation, and the probed
TypeError / TclError paths.
The Canvas additional drawing slice covers `create_oval(...)`,
`create_polygon(...)`, and `create_text(...)` for probed item ids, item types,
coordinate lists, text / anchor / fill / outline option reads, shared tag
lookup, `IndexError("tuple index out of range")` for omitted coordinates, and
the observed wrong-coordinate-count and bad-distance `TclError` paths. The
Canvas arc/bitmap slice covers `create_arc(...)` and `create_bitmap(...)` for
probed item ids, item types, coordinate lists, arc start / extent / style /
outline / width option reads, built-in bitmap names, foreground / background /
anchor option reads, bounding boxes, shared tag lookup, and the observed
omitted-coordinate `IndexError`, wrong-coordinate-count, bad-distance, unknown
option, and missing-bitmap `TclError` paths. The
Canvas media item slice covers `create_image(...)` with `PhotoImage` options
and `create_window(...)` with embedded widgets, including `itemcget("image")`
and `itemcget("window")` Tcl-name reads, coordinate lists, bounding boxes,
shared tag lookup, `IndexError("tuple index out of range")` for omitted
coordinates, and wrong-coordinate-count / bad-distance `TclError` paths. The
Canvas view and coordinate slice covers `canvasx(screenx, gridspacing=None)`,
`canvasy(screeny, gridspacing=None)`, `xview(*args)`, `xview_moveto(fraction)`,
`xview_scroll(number, what)`, `yview(*args)`, `yview_moveto(fraction)`, and
`yview_scroll(number, what)`. It returns Python-shaped float coordinates and
float tuples, preserves explicit `None` gridspacing as the omitted-grid path,
returns `None` for mutating view calls, supports direct `xview("moveto", ...)`
and `yview("scroll", ...)` calls, and surfaces the probed Canvas / XView /
YView TypeError and Tcl validation paths. The Canvas tag-management slice
covers `addtag(*args)`, `addtag_above(newtag, tagOrId)`,
`addtag_all(newtag)`, `addtag_below(newtag, tagOrId)`,
`addtag_closest(newtag, x, y, halo=None, start=None)`,
`addtag_enclosed(newtag, x1, y1, x2, y2)`,
`addtag_overlapping(newtag, x1, y1, x2, y2)`,
`addtag_withtag(newtag, tagOrId)`, `dtag(*args)`, and `gettags(*args)`. It
returns Python-shaped tag tuples, preserves probed tag ordering after
selection, all-item, z-order, closest, enclosed, overlapping, raw withtag, and
delete-tag operations, returns an empty tuple for missing tags, and surfaces
the observed convenience-wrapper TypeError and raw Tcl validation paths. The
Canvas find-query slice covers `find(*args)`, `find_above(tagOrId)`,
`find_below(tagOrId)`, `find_closest(x, y, halo=None, start=None)`,
`find_enclosed(x1, y1, x2, y2)`, and
`find_overlapping(x1, y1, x2, y2)`. It returns Python-shaped integer tuples
for raw, tag, z-order, closest, enclosed, and overlapping searches, treats
explicit `None` optional closest arguments as the omitted path, returns empty
tuples for missing tags / no matches, and surfaces the probed arity TypeError
and Tcl search / coordinate validation paths. The Canvas text-item editing
slice covers `dchars(*args)`, `focus(*args)`,
`icursor(*args)`, `index(*args)`, `insert(*args)`,
`select_adjust(tagOrId, index)`, `select_clear()`,
`select_from(tagOrId, index)`, `select_item()`, and
`select_to(tagOrId, index)`. It returns Python-shaped `None`, empty string,
and integer item / index values for cursor, focus, selection, and text
mutation calls, preserves probed text insertion / deletion results, leaves
missing-item `dchars(...)` as a no-op, and surfaces the observed raw Tcl arity
errors, bad-index errors, non-indexable-item errors, and wrapper TypeError
paths. The Canvas scan/scale slice covers `scale(*args)`, `scan_mark(x, y)`,
and `scan_dragto(x, y, gain=10)`. It returns Python-shaped `None`, mutates
item coordinates for ids and tags, preserves the probed missing-tag no-op,
keeps `scan_mark(...)` as a view-state no-op, applies default and explicit
gain drag scrolling, and surfaces the observed raw Tcl arity / coordinate
validation errors and wrapper TypeError paths. The Canvas z-order/moveto slice
covers `itemconfig(tagOrId, cnf=None, **kw)`, `moveto(tagOrId, x='', y='')`,
`tag_raise(*args)`, and `tag_lower(*args)`. It returns Python-shaped `None`,
keeps `itemconfig(...)` error messages aligned with the `itemconfigure(...)`
alias, forwards empty-string `moveto(...)` defaults rather than omitting Tcl
arguments, moves item ids and tags to absolute positions, preserves
missing-tag no-op movement, reorders items through tag raise/lower calls, and
surfaces the observed wrapper TypeError and raw Tcl validation paths. The
Canvas tag-event slice covers `tag_bind(tagOrId, sequence=None, func=None,
add=None)` and `tag_unbind(tagOrId, sequence, funcid=None)`. It returns
Python-shaped sequence tuples, script strings, command names, and `None`,
routes canvas item-tag events through the existing Event object bridge,
supports additive bindings, clears the full tag/sequence script on unbind,
allows missing tag registration, and surfaces the observed arity and
`can't delete Tcl command` paths. The Canvas PostScript slice covers
`postscript(cnf={})`. It returns Tk EPS strings, supports option dictionaries
for color mode, output area, page geometry, and file output, preserves the
empty-string success result for file writes and Tk's returned open-error
string for an unwritable path, and surfaces the observed wrapper TypeError and
Tcl validation paths. The widget identity-tree
slice covers `winfo_children()`, `winfo_class()`, `winfo_name()`, and
`winfo_parent()` on roots, `Toplevel` windows, and child widgets. It returns
the same widget objects created through the public wrapper for child lists,
preserves Python-style Tk class/name/parent strings such as `Tk`, `tk`, `Frame`,
`host`, `.`, and `.dialog`, drops destroyed widgets from parent child lists,
and surfaces `TclError("bad window path name \"...\"")` for destroyed-widget
identity reads. The path lookup slice covers `nametowidget(name)` on roots and
widgets, matching local Python 3.10.11 absolute paths such as `.host.press`,
relative child names such as `press`, root lookup through `.`, and `KeyError`
messages for missing or destroyed widget names. The image registry query slice
covers `image_types()` and `image_names()` on roots and Tk-backed widgets,
matching local Python 3.10.11 tuple returns for `photo` / `bitmap` image
types, built-in icon registry names, named `PhotoImage` entries, image delete
updates, widget/root parity, and arity errors. The virtual event registry slice
covers `event_add(...)`, `event_delete(...)`, and `event_info(...)` on roots
and Tk-backed widgets, matching local Python 3.10.11 `None` returns, tuple
queries, virtual-event membership, `<Key-a>` normalization to `a`, duplicate
adds, delete updates, explicit `None` all-event queries, and arity / Tcl
validation errors. The bind-tag routing slice covers `bindtags(...)` on roots,
`Toplevel` windows, and child widgets, matching local Python 3.10.11 default
tag tuples such as `(".", "Tk", "all")` and `(".host.caption", "Label", ".",
"all")`, tuple/list/string set behavior, empty tuple no-op semantics,
explicit `None` query behavior, arity errors, and destroyed-widget `TclError`
paths. The class/all binding slice covers `bind_all(...)`, `bind_class(...)`,
`unbind(...)`, `unbind_all(...)`, and `unbind_class(...)` on roots and child
widgets, matching local Python 3.10.11 tuple/script query returns, callback
ids, widget/class/all delivery from a generated `<Button-1>` event, event
widget resolution through `%W`, full-sequence clearing for `unbind(...,
funcid)`, and observed TypeError arity messages. The Tcl-backed Misc conversion slice
covers `getint(s)`, `getdouble(s)`, and `getboolean(s)` on `Tcl()`, `Tk`, and
child widgets, matching local Python 3.10.11 `0x10`, signed and padded integer
strings, bool/object pass-through cases, Tcl `ValueError` text for invalid
integer and floating-point strings including `nan`, Python `TypeError` text
for `None` / list inputs, and observed arity errors. The layout
info/forget slice
covers `pack_info()`,
`pack_forget()`, `grid_forget()`, `grid_remove()`, and `place_forget()` from
fresh Python 3.10.11 probing. `pack_info()` returns the parent widget object
for `in`, integer values for `expand`, `ipadx`, `ipady`, `padx`, and `pady`,
and string values for `anchor`, `fill`, and `side`; `pack_forget()` clears the
manager and makes a subsequent `pack_info()` raise the observed Tcl
`isn't packed` error; bare `pack()` restores default pack options.
`grid_forget()` clears manager state and restores default grid options on a
bare `grid()`, while `grid_remove()` preserves the probed row/column/padding
state for a later bare `grid()` restore. `place_forget()` clears manager state
and leaves both `place_info()` and a later bare `place()` empty. The layout child-query
slice covers `pack_slaves()`, `grid_slaves(row=None, column=None)`, and
`place_slaves()`: parent containers return the same widget objects registered
through the public wrapper, root `pack_slaves()` sees packed top-level child
widgets, grid child queries preserve Tk's newest-first ordering and row/column
filters, place child queries preserve newest-first ordering, and forgotten
widgets disappear from the corresponding child lists. The grid geometry-query
slice covers `grid_size()`, `grid_bbox(column=None, row=None, col2=None,
row2=None)`, and `grid_location(x, y)` on roots and child widgets. It returns
integer tuples for grid dimensions, bboxes, and coordinate locations, supports
object-form keyword analogues for the covered keyword calls, preserves
Python's behavior where `grid_bbox(column)` / `grid_bbox(row=...)` with an
incomplete first coordinate pair returns the whole grid bbox without validating
the isolated value, and surfaces the observed TypeError/TclError paths for
bad arity, unexpected keywords, bad integer grid coordinates, and bad screen
distances. The grid row/column configuration slice covers
`grid_columnconfigure(index, cnf := {})`, `columnconfigure(...)`,
`grid_rowconfigure(index, cnf := {})`, and `rowconfigure(...)` on roots and
child widgets. It returns Python-shaped maps for full queries with integer
`minsize`, `pad`, and `weight` fields plus `None` / string `uniform` fields,
returns typed single-option values, supports option-object updates for
`minsize`, `pad`, `uniform`, and `weight`, preserves alias error messages, and
surfaces the observed Tcl validation paths for bad indices, options, and
integer values. The layout propagation slice covers `pack_propagate(flag)`,
`grid_propagate(flag)`, and `grid_anchor(anchor)` on roots and child widgets.
No-argument propagation queries return `True` for Tcl `1` and `None` for Tcl
`0`, set calls return `None`, explicit `None` arguments use the same
query/no-op path observed through Python 3.10.11 `_tkinter`, and invalid
boolean or anchor values surface the probed TclError messages. `grid_anchor()`
matches Python's wrapper behavior by discarding the Tcl return value and
returning `None` for both query and set paths. The layout alias slice covers
`pack_configure()`, `grid_configure()`, and `place_configure()` as direct
aliases for the corresponding manager methods; `info()` and `forget()` as the
`Pack` aliases selected by CPython's widget MRO; `slaves()` and `propagate()`
as the `Pack` root/widget aliases; and `anchor()`, `size()`, `bbox()`, and
widget `location()` as `Grid` aliases. It preserves the probed CPython arity
messages and intentionally leaves `Tk.location()` absent because local Python
3.10.11 has no such root method. The clipboard slice covers
`clipboard_clear(**kw)`, `clipboard_append(string, **kw)`, and
`clipboard_get(**kw)` on roots and child widgets. It preserves Python's `None`
return values for clear/append, appends multiple payloads into one clipboard
string, supports object-form keyword analogues for the covered `type` and
`displayof` options, returns clipboard text through `clipboard_get()`, and
surfaces the observed empty-clipboard, bad type, bad option, and arity error
paths. The option-database slice covers `option_add(pattern, value,
priority=None)`, `option_clear()`, `option_get(name, className)`, and
`option_readfile(fileName, priority=None)` on roots and child widgets. It
matches Python's `None` return values for mutating calls, keeps `option_get()`
scoped to the queried widget, applies option values to subsequently created
widgets, clears the database through `option_clear()`, reads Tk resource-file
syntax through `option_readfile()`, omits explicit `None` priorities so Tk's
default priority is used, and surfaces the observed missing-file, bad-file,
bad-priority, and arity error paths. The variable trace slice covers
`Variable.trace_add(mode, callback)`, `trace_remove(mode, cbname)`,
`trace_info()`, `trace_variable(mode, callback)`, `trace_vdelete(mode,
cbname)`, and `trace_vinfo()` across the public variable classes. It returns
registered callback names, delivers probed callback argument tuples for
`read`, `write`, `unset`, and legacy `w` traces, returns Python-shaped trace
info lists with mode tuples and callback names, removes callbacks when no
trace still references them, accepts list/tuple mode registration for
`trace_add(...)`, and surfaces the observed TypeError/TclError paths for
bad arity and invalid modes. The window iconify lifecycle
slice covers `Tk.iconify()` and
`Toplevel.iconify()` from fresh Python 3.10.11 probing, including `normal` to
`iconic` state transitions, `iconify()` from a withdrawn root, deiconifying
back to `normal`, root viewable/mapped observations, and the probed
`Wm.wm_iconify()` arity error text. The winfo coordinate-query slice covers
`winfo_x()`, `winfo_y()`, `winfo_rootx()`, `winfo_rooty()`,
`winfo_screenwidth()`, `winfo_screenheight()`, `winfo_reqwidth()`, and
`winfo_reqheight()` on roots and Tk-backed widgets, including integer returns,
geometry-position reads, widget-relative coordinate reads, root-coordinate
ordering, shared screen dimensions, request-size equality for settled packed
widgets, and the probed `Misc.winfo_*()` arity error text. The first geometry-manager
slice covers `grid(...)`, `grid_info()`, `place(...)`, and `place_info()` from
fresh Python 3.10.11 probing: `grid()` / `place()` return Python `None`,
`winfo_manager()` reports `"grid"` / `"place"`, `grid_info()` exposes integer
`row`, `column`, span, internal/external pad values plus normalized sticky
text such as `"nesw"`, and `place_info()` preserves the probed string values
for x/y, relative coordinates, width/height, anchor, and bordermode. Empty
`place()` on an unmanaged widget still returns `None` and leaves
`place_info()` empty, matching the local probe. The first event-loop slice now
covers `Tk.after(...)`, Tk-backed widget `after(...)`, `Tk.after_idle(...)`,
Tk-backed widget `after_idle(...)`, `Tk.after_cancel(...)`, Tk-backed widget
`after_cancel(...)`, `Tk.mainloop(...)`, and `Tk.quit()` from fresh Python
3.10.11 probing: `after(0)` without a callback returns `None`, callback-based
`after(...)` returns an `after#N` id and runs the callback on `update()` /
`mainloop()`, callback arguments are passed through,
`after_idle(func, *args)` returns an `after#N` id, runs idle callbacks on
`update()`, supports Tk-backed widget callers, and uses `after_cancel(id)`,
invalid millisecond values surface Tcl's `bad argument ...` error,
`after_cancel(id)` and `after_cancel("missing")` return `None`,
`mainloop()` returns `None` after a scheduled `quit()`, and the covered arity
errors match the local probe. The variable-wait slice covers
`wait_variable(...)` and `waitvar(...)`: variable objects and string variable
names unblock after scheduled `set()` / `setvar(...)` updates, omitted names
use the local Python 3.10.11 default variable name, Tk-backed widgets share the
same root interpreter wait path, and alias arity errors retain the
`Misc.wait_variable()` message. The window protocol slice covers `protocol()`
and `wm_protocol()` on Tk roots and `Toplevel` windows from fresh Python
3.10.11 probing: no-argument calls return the protocol-name tuple,
`WM_DELETE_WINDOW` is present by default, single-name calls return the Tcl
command string, callable callbacks are registered and executable through the
returned Tcl command, `None` callback results become `"None"`, string /
non-callable command assignments are preserved, unknown protocol names return
`""`, and the probed `Wm.wm_protocol()` arity error text is surfaced. The
focus-management slice covers `focus_set()`, `focus_force()`, `focus_get()`,
and `focus_displayof()` from fresh Python 3.10.11 probing, including `None`
returns from set/force calls, focused widget object mapping through
`focus_get()` / `focus_displayof()`, no-focus returning `None` after
withdrawal, and the probed `Misc.focus_*()` arity error text. The repository now carries
the probed Tcl/Tk DLLs at
`stdlib\tkinter\lib\tcl86t.dll` and `stdlib\tkinter\lib\tk86t.dll`, and the
AHK implementation prefers those bundled DLLs before falling back to the local
Python install. The tracked `stdlib\tkinter\lib\README.md` and
`stdlib\tkinter\lib\SHA256SUMS` record the CPython 3.10.11 source path,
official release URL, file sizes, Tcl/Tk 8.6.12 version metadata, and SHA256
hashes; `stdlib\tests\tkinter.test.ahk` recomputes the bundled DLL hashes from
that report. It still sets `TCL_LIBRARY` / `TK_LIBRARY` from the local Python
3.10 Tcl script libraries, then calls `Tk_Init` only when
`stdlib.tkinter.Tcl({ useTk: stdlib.True })` or `stdlib.tkinter.Tk()` requests
Tk.
The winfo distance/color promotion covers `winfo_pixels(number)`,
`winfo_fpixels(number)`, and `winfo_rgb(color)` for roots and Tk-backed
widgets, including CPython 3.10.11's logical-DPI pixel conversion for unit
distances, RGB tuples in the `0..65535` range, destroyed-widget Tcl errors,
bad distance/color Tcl errors, and `Misc.winfo_*()` arity messages.
The winfo screen-metadata promotion covers `winfo_screen()`,
`winfo_screenmmwidth()`, `winfo_screenmmheight()`, `winfo_screendepth()`,
`winfo_screencells()`, `winfo_screenvisual()`, and `winfo_server()` for roots
and Tk-backed widgets, including the local Python 3.10.11 screen/server values,
integer screen dimensions and color-depth data, destroyed-widget Tcl errors,
and `Misc.winfo_*()` arity messages.
The winfo logical-screen promotion covers CPython 3.10.11-aligned logical
returns from `winfo_screenwidth()` and `winfo_screenheight()` and adds
`winfo_vrootwidth()`, `winfo_vrootheight()`, `winfo_vrootx()`, and
`winfo_vrooty()` for roots and Tk-backed widgets, including DPI normalization
from AHK/Tk physical pixels, destroyed-widget Tcl errors, and `Misc.winfo_*()`
arity messages.
The winfo visual/colormap/pointer promotion covers `winfo_cells()`,
`winfo_colormapfull()`, `winfo_depth()`, `winfo_geometry()`, `winfo_id()`,
`winfo_pointerx()`, `winfo_pointerxy()`, `winfo_pointery()`, `winfo_visual()`,
`winfo_visualid()`, and `winfo_visualsavailable()` for roots and Tk-backed
widgets, including local Python 3.10.11 visual metadata, bool/integer/string
and list-of-tuple return conversion, destroyed-widget Tcl errors, and
`Misc.winfo_*()` arity messages.
The winfo atom/path/containing promotion covers `winfo_atom()`,
`winfo_atomname()`, `winfo_containing()`, `winfo_interps()`, and
`winfo_pathname()` for roots and Tk-backed widgets, including CPython 3.10.11
`_displayof` handling, atom name/id round-trips, empty interpreter tuple
returns on this host, raw hex window-id path lookup, widget/`None` containing
returns, and observed arity / Tcl validation messages.
Additional widgets and broader GUI/event-loop behavior remain deferred.

`stdlib.enum` is now direct as a first slice of Python 3.10.11 `enum`,
promoted from the old lightweight `std\metafunc\enum.ahk` source material and
the weakest remaining runtime candidate slot. The current public slice covers
`stdlib.enum.Enum(name, members, options?)` and `stdlib.enum.auto()` for the
functional API shapes that are directly expressible in AHK: whitespace/comma
separated member text, plain name arrays, explicit `[name, value]` pair lists,
ordered plain-object / `Map` name-value inputs, optional `{ start: value }`
numbering for name lists, member lookup by `.NAME`, `["NAME"]`, and
`EnumType(value)`, ordered iteration over enum members, ordered `__members`
iteration, plus covered member `.name`, `.value`, `String(member)`, and
`__Repr()` behavior. Covered error branches currently match the local Python
3.10.11 baseline for bare `Enum()` call wording via `EnumMeta.__call__`,
unexpected keyword arguments, non-iterable integer member payloads, missing
member-name `KeyError`, invalid value `ValueError`, and `auto()` arity. This
first slice intentionally stops before `IntEnum`, decorator helpers, alias
rules, flag/bitmask variants, and deeper metaclass customisation because raw
AHK numeric operators do not yet provide a faithful Python-style int-like enum
surface without additional `stdlib.operator` integration.

`stdlib.copy` is now direct as a first slice of Python 3.10.11 `copy`,
promoted onto the public Python-path root as `stdlib.copy.*`. The current
slice covers `stdlib.copy.copy(x)` and `stdlib.copy.deepcopy(x)` for observable
shapes that are straightforward to express in AHK today: shallow and deep
copying of lists, maps, plain objects, tuple-like `stdlib.tuple(...)` values,
immutable scalar passthrough for covered `str`/`int`-style inputs, custom
`__copy()` and `__deepcopy(memo)` hooks, and recursive cycle preservation
through memoized deep-copy traversal. Covered behavior currently matches the
local Python 3.10.11 probe for list/dict nested-identity differences between
shallow and deep copy, `tuple` shallow identity vs deep copy rematerialization
when nested mutable content is present, recursive self-reference
reconstruction, and the observed missing-argument `TypeError` wording for bare
`copy()` / `deepcopy()` calls. The public-surface slice now also exposes
`stdlib.copy.Error`, the lowercase `stdlib.copy.error` alias through AHK's
case-insensitive class-property lookup, and the public `dispatch_table` shape.
Fresh CPython 3.10.11 probe `.codex/copy_public_surface_probe.py` plus JSON
output confirmed `copy.__all__ == ["Error", "copy", "deepcopy"]`, public names
`Error`, `copy`, `deepcopy`, `dispatch_table`, and `error`, `Error is error`,
and a three-entry dispatch table for `complex`, `types.UnionType`, and
`re.Pattern`; focused red `.codex/copy-public-surface-red-report.txt` failed
because `stdlib.copy.Error` was absent; focused green
`.codex/copy-public-surface-green-focused-report.txt` passed 1/1; full module
`.codex/copy-public-surface-final-green-report.txt` passed
`stdlib/tests/copy.test.ahk` 3/3 at `TimeoutSeconds 90`; root smoke
`.codex/copy-public-surface-stdlib-focused-report.txt` passed 1/1; validation
`.codex/copy-public-surface-validate-report.txt` passed `stdlib/copy.ahk`,
`stdlib/tests/copy.test.ahk`, `stdlib/tests/stdlib.test.ahk`, and
`stdlib/examples/copy.ahk` at `TimeoutSeconds 90`. This slice still
intentionally stops before Python's full pickling-protocol integration,
slots/descriptor edge cases, and richer reducer/custom-dispatch machinery; the
current `dispatch_table` is a public surface mirror, not a complete reducer
engine.

`stdlib.uuid` is now direct as a first slice of Python 3.10.11 `uuid`,
promoted onto the public Python-path root as `stdlib.uuid.*`. The current
slice covers `stdlib.uuid.UUID(...)` for the observed string parsing forms on
the local baseline: canonical hyphenated text, plain 32-hex text, brace-wrapped
text, `urn:uuid:` text, and a keyword-object `{ hex: ... }` analogue. Covered
observable surface currently includes normalized `String(...)`, `.hex`, `.urn`,
`.variant`, `.version`, and `__Repr()`, plus `stdlib.uuid.uuid4()` using
Windows GUID generation under the wrapper. This first slice intentionally stops
before `bytes`, `bytes_le`, `fields`, `int`, ordering/comparison helpers,
namespace constants, `SafeUUID`, and the wider `uuid1` / `uuid3` / `uuid5`
surface.

`stdlib.contextlib` is now direct as a Python 3.10.11 `contextlib` slice,
promoted onto the public Python-path root as `stdlib.contextlib.*`. The covered
surface includes `stdlib.contextlib.nullcontext`, `stdlib.contextlib.suppress`,
and `stdlib.contextlib.closing` for observable object behavior exercised by the
local Python baseline: `__enter` return values, `__exit` suppression
decisions, Python-style `repr(...)` object shapes, zero-argument `suppress()`
permissiveness, `closing(...)` calling `.close()` on exit, and the covered
arity / bad-exception-type error messages. The current promoted slice also
covers `ContextDecorator`, `ExitStack`, `redirect_stdout`, and
`redirect_stderr`: fresh CPython 3.10.11 probe
`.codex/contextlib_stack_decorator_redirect_probe.py` plus JSON output
confirmed decorator call order, `ExitStack` LIFO callback/context-exit order,
and redirect enter-target behavior; focused red
`.codex/contextlib-stack-decorator-redirect-red-report.txt` failed because
`redirect_stdout` was absent; focused green
`.codex/contextlib-stack-decorator-redirect-green-focused-report.txt` passed
1/1; root smoke
`.codex/contextlib-stack-decorator-redirect-stdlib-focused-report.txt` passed
1/1; full module
`.codex/contextlib-stack-decorator-redirect-final-green-report.txt` passed
`stdlib/tests/contextlib.test.ahk` 3/3 at `TimeoutSeconds 90`; validation
`.codex/contextlib-stack-decorator-redirect-validate-report.txt` passed
`stdlib/contextlib.ahk`, `stdlib/tests/contextlib.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/contextlib.ahk` at
`TimeoutSeconds 90`. Redirect coverage is intentionally scoped to AHK-target
context behavior and does not claim full Python process-global `sys.stdout` /
`sys.stderr` replacement. Remaining future work includes `contextmanager`,
async helpers, `AsyncExitStack`, broader parameter parity, and wider edge-error
parity.

`stdlib.collections.Counter` now covers lazy `elements()` iteration, Python-style
dictionary-size and dictionary-keys mutation errors during iteration,
`eq`/`ne` booleans against non-Counter non-mapping values, missing-as-zero rich
comparison semantics, and a growing set of mixed-type count error-message
parity slices. Current mixed-type coverage includes Python-style ordering
comparison messages, unary `+`/`-`, set-style `&`/`|`, `add(str, int)` string
concatenation wording, and the Python 3.10 behavior where `add(str, str)` or
`add(list, list)` can reach the positive-count filter and then fail with a
Python-style `>`-vs-`int` type error instead of an earlier binary-operator
error, including the `Counter() + Counter(a=[...])` case where a right-only
key is carried straight into the positive-count filter instead of being
prematurely combined with an implicit zero, and the Python-specific
`add(list, non-list)` concatenation wording for left-side list counts. The
same "right-only key goes straight to the positive-count filter" rule now also
covers `Counter() | Counter(a=[...])`, matching Python's `>`-vs-`int` error
path instead of prematurely comparing implicit zero against the right count.
For `Counter() & Counter(a=[...])`, the current direct slice now matches Python
by skipping the right-only key entirely and returning an empty Counter instead
of attempting a mixed-type comparison against implicit zero.
For `Counter() - Counter(a=...)`, right-only keys now also follow Python's
direct algorithm: positive right-side counts are skipped, negative right-side
counts are negated into the result, and mixed-type right-only counts fail on
Python's `<`-vs-`int` guard instead of prematurely raising an `int`-vs-value
binary subtraction error.
The current direct slice now also matches Python's `Counter.total()` behavior
for covered direct numeric objects by routing same-type `Fraction` and
`Decimal` count payloads through their existing direct stdlib addition paths
and by preserving the covered Python 3.10.11 mixed-aggregation outcomes where
`Fraction` totals can absorb native `int` and `float` payloads while
`decimal.Decimal` totals absorb native `int` payloads but still reject native
`float` payloads,
instead of treating them as raw AHK non-numeric failures, while leaving mixed
`Fraction`/`Decimal` totals unsupported like local Python 3.10.11.
The current direct slice now also matches Python's `most_common()` ordering for
covered non-numeric and direct numeric count payloads: strings use
lexicographic ordering, lists use Python-style lexicographic element
comparison, same-type `Fraction` and `Decimal` counts use their direct stdlib
comparison paths, covered `Fraction`/`Decimal` mixed ordering follows the local
Python 3.10.11 comparison result via the `Decimal` path, covered mixed
`int`/`float` with `Fraction`/`Decimal` payload ordering now also follows the
local Python 3.10.11 result through the corresponding direct stdlib numeric
comparison path, and unsupported
payloads such as function objects now fail with Python's `'<'
not supported between instances of ...` wording instead of leaking AHK's raw
numeric comparison diagnostics. Covered `eq`/`ne` value equality now also
matches Python for direct numeric payload mixes, so `Fraction` / `Decimal`
counts compare by value against matching native `int` / `float` payloads in
both Counter-to-Counter and Counter-to-mapping equality paths instead of
falling back to raw object identity. Covered direct numeric `Fraction` /
`Decimal` rich ordering against matching native `int` / `float` payloads now
also follows the local Python 3.10.11 result instead of leaking raw AHK
comparison failures. The current direct slice also follows Python's
`most_common(limit)` argument rules for covered cases: `limit=None` returns the
full ordered result, native `bool` and root `stdlib.True` / `stdlib.False`
values follow Python's `int` subclass behavior,
only the covered `== 1` fast path is accepted for non-native numeric objects
such as `Fraction(1, 1)` and `Decimal("1")`, larger covered float / `Fraction`
/ `Decimal` limits now follow Python's later `slice indices must be integers or
None or have an __index__ method` failure when the implementation reaches the
slice path, smaller covered non-native numeric values preserve Python's
integer-interpretation `TypeError` wording, and string limits preserve
Python's `'>=' not supported between instances of 'str' and 'int'` wording.
Plain objects and custom AHK class instances in the `limit` slot now also
follow Python's `'>=' ... and 'int'` comparison wording instead of being
misreported as integer-interpretation failures.

Current tests live under `stdlib\tests`. Current examples live under
`stdlib\examples`. The old top-level `examples\stdlib` tree is not part of the
active surface.

## AhkTest Pytest 7.4.3 Parity Matrix

`ahktest` uses pytest 7.4.3 as the behavior benchmark, but public AHK
identifiers must stay under `ahktest`, `AhkTest`, or `ahk*` naming. Direct
Python naming is documentation-only and must not leak into the AHK public API.

| Pytest 7.4.3 area | Target AHK shape | Current status | Notes |
| --- | --- | --- | --- |
| Test discovery | `tools\run-ahktest.ps1`, `AhkTest.Collect`, future stdlib-aware discovery | partial | Current wrapper discovers `*.test.ahk`, supports repeatable/comma-split `-Ignore` entries that exclude matching files before include/load using case-insensitive PowerShell wildcard matching against file name, lib-relative path, or absolute path, now matches the observed local pytest 7.4.3 duplicate-target policy by collecting repeated explicit file targets again while still deduplicating repeated directory discovery, preserves that mixed directory-plus-file behavior for the same underlying test file, and now supports manifest-backed configurable discovery roots through `AhkTest.DiscoveryRoots` in JSON `-Config` files when `-Target` is omitted. Discovery roots are resolved relative to the config file, while an explicit `-Target` still overrides them. Class collection handles static `Test*` methods; result entries keep public suite/name node ids while rerun state can now use source-aware stable keys for same-name tests collected from different files. Need non-manifest discovery config and broader project-layout policy. |
| Collection model | Structured suite items with name, node id, source, marks, params, fixtures | partial | Current entries have names, node ids, status, marks, captured output, errors, and serializable source metadata. Manual tests can provide explicit `Source`, `AhkTest.SourceHere(kind)` creates a serializable current-file/current-line source object for manual registration, `Test` registrations record automatic source metadata through both suite and default-suite entrypoints, `Skip`/`XFail`/`Parametrize` registrations keep source kind and file/line metadata, `Collect` records class/method metadata, non-callable collected `Test*` members now surface as dedicated `AhkTestCollectionError` entries with preserved detail in `Extra`, `collect_finish` hook failures follow the same collection-failure error class instead of being reported as plain runtime errors, and wrapper-level top-level runtime include/import failures plus top-level syntax/load-time compiler failures before `AhkTest.Run(...)` now synthesize the same collection-failure error type into text/JSON/JUnit outputs instead of surfacing only as missing-report stderr. Covered collection-failure result objects now also report `ExitCode = 2` like local pytest 7.4.3 collection errors, while non-collection usage/runtime failures continue to use ordinary nonzero error exits. `collect_finish` hooks can still inspect or modify the per-run collected item list before filtering and execution, and covered rerun slices now use `Source.File` metadata to distinguish same-name tests loaded from different files. Need broader discovery collection failures and richer class-method line metadata where AHK permits. |
| Assertion rewriting | Explicit `AhkTest.Assert*` helpers and rich failure diagnostics | partial | AHK cannot rewrite `assert` expressions like Python import hooks. Equivalent path is dense helper coverage plus expected/actual/error metadata. |
| Fixtures | `AhkTest.Fixture`, `AhkTest.FixtureResult`, explicit fixture lists on tests and fixtures, scoped fixtures, test-local fixture overrides, `ahk_context` | partial | Current implementation supports function-scope fixture callbacks declared by name and injected into test callbacks in declared order, dependency fixtures, autouse fixtures, per-test function-scope fixture value caching, test-local function-scope fixture shadowing through `AhkFixtureOverrides`, suite-scoped fixture caching, session-scoped fixture caching keyed by suite/fixture definition with explicit cleanup, unknown-fixture errors, dependency cycle detection, LIFO cleanup via fixture results, fixture cleanup aggregation for function/suite/session cleanups, fixture-level `Params` that expand tests during collection, fixture param row ids and marks including skip/xfail marks, scoped fixture parameter cache isolation by fixture param id for suite/session lifecycles, scoped fixture setup-error caching for suite/session lifecycles, and the reserved built-in `ahk_context` fixture for `AddCleanup()`, dynamic `GetFixture()` lookup, row-level or fixture-level parameters through `ctx.Param` and `ctx.GetParam()` with a clear missing-parameter diagnostic, fixture-local parameter identity through `ctx.FixtureParamId`, request-like `ctx.FixtureNames` exposure for the current test's covered fixture graph, and current test metadata (`FixtureName`, `Scope`, `TestName`, `NodeId`, combined `ParamId`, `Params`, `Marks`, plus source/mark detail data when present). Covered dynamic `ctx.GetFixture(name)` now also updates `ctx.FixtureNames` like local pytest 7.4.3 `request.getfixturevalue(...)`: already-declared fixtures do not duplicate, while newly requested fixtures append their dependency graph in dependency-first order before the requested fixture name. Need richer setup reporting, override params/scoped override layering behavior, and fuller request-equivalent behavior beyond the covered fixture-name surface. |
| `tmp_path` / `tmp_path_factory` | `AhkTest.TempDir`, `AhkTest.TempPathFixture`, `AhkTest.TempPathFactoryFixture`, `AhkTestPath` path object | partial | Current temp dir creates one uniquely named directory, temp path fixture provides per-test isolation and cleanup, and temp path factory creates numbered directories cleaned at fixture teardown. `AhkTestTempDir.Join(...)` now returns an `AhkTestPath` object with explicit pathlib-like `Path`, `Name`, `Stem`, `Suffix`, `Join(...)`, `Parent()`, `Exists()`, `IsDir()`, `WriteText(...)`, `ReadText(...)`, `Mkdir({ Parents, ExistOk })`, `Unlink({ MissingOk })`, and `Rmdir()` helpers while preserving existing `.Path`, `.File(...)`, and `.PathJoin(...)` string APIs for compatibility. Covered `TempPathFactoryFixture` cleanup now uses one shared root temp directory with numbered child directories returned as full temp-dir objects, preserving existing `.File(...)`/`.Path` semantics while reducing repeated recursive teardown cost. `AhkTestTempDir` now includes a process-local counter in generated names and cleans temp roots directly with recursive `DirDelete` to avoid Windows fallback-delay paths. Need retained base dir policy, richer pathlib-style edge cases, and a documented stance on implicit object-to-string coercion under AHK v2. |
| Monkeypatch | `AhkTest.MonkeyPatchFixture` with env, map, working-directory, object property/method, global function strategy where possible | partial | Current implementation supports reversible environment variable set/delete, PATH-like environment prepending, reversible `Map` set/delete, reversible object property set/delete via own-property descriptors, reversible object method replacement through `DefineProp(..., { Call: ... })`, and reversible working-directory changes through fixture cleanup. AHK global namespace and built-ins limit parity. Need global function replacement strategies where possible. |
| Capture (`capsys`/`capfd`) | `AhkTest.CaptureFixture` for cooperative stdout/stderr capture, child-process command/argument capture, output-file capture, and future stream/process capture helpers | partial | Current harness writes reports, and `CaptureFixture` provides test-local cooperative `WriteOut`, `WriteErr`, and `Read` buffers for stdlib tests. `capture.Run(command, options)` preserves raw shell-command behavior through `RunWait`, captures child-process stdout/stderr into temp files, appends them to the fixture buffer, and returns an `AhkTestProcessResult` with `ExitCode`, `Out`, and `Err`; options currently include `WorkingDir` and `Encoding`. `capture.RunArgs(executable, args, options)` provides a safer argument-list path using Windows command-line quoting for literal argument values, writes child stdout/stderr and exit code through temporary files to avoid pipe backpressure on large output, appends output to the fixture buffer, supports `WorkingDir` and `Encoding`, preserves literal `%...%` arguments across its cmd wrapper, and supports `{ TimeoutSeconds: n }` by terminating the child process tree and returning `TimedOut: true`, `ExitCode: -1`, plus a captured stderr diagnostic. Unread captured output is attached to structured result entries, exported by `ToMap()`, and shown in failure/error text-report sections. Need fd-level limits documented for AHK's process model. |
| Parametrize | `AhkTest.Parametrize` with ids, generated ids, parameter metadata, parameterized node ids, row marks, option marks, fixture params, and stacked rows | partial | Current rows, explicit ids, generated ids, per-row marker metadata, option-level marker inheritance, option/row marker merging, exported `ParamId`/`Params`, parameterized node ids, empty parameter set skips, `Parametrize(..., { Stack: true })` Cartesian expansion, explicit fixture injection for parametrized tests, row-level `FixtureParams` exposed to fixtures through `ahk_context.Param`, merged stacked-row fixture params, and collection-time fixture-level `Params` expansion work. Need richer stacked marker diagnostics and fuller indirect/lazy fixture-style parameterization. |
| Marks | AHK-named marks on tests and parameter rows | partial | Current implementation supports plain string marks plus `AhkTest.Mark(name, data)` structured marks. `Marks` stays a plain marker-name array for `MarkFilter`, boolean `MarkExpr`, and strict registration checks, while structured `MarkDetails` preserves marker data in result entries and serialized maps. It supports `RegisterMark`, `Configure({ Marks: ... })`, plus `Run({ StrictMarkers: true })` validation for unregistered marks, exposes wrapper `-StrictMarkers`/`-RegisterMark`, and accepts AHK-named skip/xfail mark declarations without exposing pytest naming. Need richer marker inheritance rules. |
| Skip / xfail / xpass | `AhkTest.Skip`, `SkipIf`, `SkipNow`, `XFail`, `SkipMark`, `XFailMark`, `Run({ RunXFail: true })` | partial | Current behavior tracks skip, xfail, non-strict xpass, strict xpass failure semantics, mark-declared skip/xfail including strict xfail, a `RunXFail` mode that treats expected failures as ordinary tests for debugging, and grouped skip/xfail/xpass reason summaries in structured results and text reports. Need richer marker/config integration. |
| Exceptions | `AhkTest.Raises`, `RaisesMatch`, context-style helper if AHK ergonomics permit | partial | Current exception type and regex matching work, and structured result exports include AHK Error metadata (`File`, `Line`, `What`, `Extra`, `Stack`) for failed/error entries. Need richer captured exception info and nested assertion diagnostics. |
| Approximate comparisons | `AhkTest.Approx` / `AhkTest.AssertApprox` | partial | Current implementation covers pytest default relative tolerance `1e-6`, absolute tolerance `1e-12`, explicit abs-only behavior, arrays, maps, and `NanOk` handling. Need richer mismatch diagnostics and operator-like ergonomics where AHK permits. |
| Run control | `AhkTest.Run({ MaxFail: n })`, `AhkTest.Run({ ExitFirst: true })`, `AhkTest.Run({ RunXFail: true })`, `AhkTest.Run({ LastFailed: true })`, `AhkTest.Run({ LastFailedCache: path })`, `AhkTest.Run({ Stepwise: true })`, `tools\run-ahktest.ps1 -MaxFail n`, `-ExitFirst`, `-RunXFail`, `-LastFailed`, `-LastFailedCache`, `-Stepwise`, `-StepwiseCache` | partial | Current implementation stops after failed, errored, or strict unexpected-pass entries reach `MaxFail`, supports `ExitFirst` as a `MaxFail: 1` alias in both the AHK API and wrapper, supports `RunXFail` in the AHK API and wrapper, supports in-memory and file-backed last-failed reruns, falls back to the current full collection when a file-backed `LastFailedCache` contains no node ids that still exist in the current collected item set, and now matches the covered local pytest 7.4.3 explicit-selection override slices when `LastFailed`/`LastFailedCache` is combined with either a string or array `NodeFilter`, or with a `FilterExpr`, whose current selection falls entirely outside the cached failure set: ahktest runs that explicit selection, preserves prior cached failures after a clean selected pass, removes any executed cached node ids that now pass, and merges newly failing explicit selections into the persisted node-id cache. Covered multi-file duplicate-name reruns now also follow the observed local pytest 7.4.3 `--lf` and `--sw` behavior by tracking source-aware stable rerun keys, so same-name tests collected from different files stay scoped to the originally failing source file without changing the public result `NodeId` shape. When a mixed explicit node-id selection includes at least one cached failing node, the run still follows the cached intersection instead of overriding into the full explicit array. It also supports stepwise reruns that resume from the cached failing node, fall back to the current full collection when a cached stepwise node no longer exists in the current collected item set, fall back to the current filtered or node-selected subset when the cached stepwise node exists in the suite but is excluded by the current selection, preserve the prior cached stepwise node after a clean fallback run, and clear after the resumed failure passes. Need richer cache invalidation beyond the covered stale last-failed, explicit selection override, and stale/excluded stepwise fallback paths. |
| Warnings | `AhkTest.Warn`, `AhkTest.Warns`, warning capture/filter equivalent | partial | Current implementation supports ahktest-local warning records, regex message matching, category matching via `Warns(..., { Category: ... })`, warning source metadata (`File`, `Line`, `What`, `Extra`, `Stack`) captured from the `AhkTest.Warn()` call site and serialized by `ToMap()`, per-test warning capture on structured result entries, grouped `AhkTestResult.WarningSummary()` data, opt-in text warning summaries through `Run({ WarningSummary: true })` / `tools\run-ahktest.ps1 -WarningSummary`, and structured warning filters via `Configure({ WarningFilters: ... })`, `Configure({ AhkRunDefaults: { WarningFilters: ... } })`, or `Run({ WarningFilters: ... })` with `default`/`always`/`once`/`source`/`ignore`/`error` actions, category exact matching, message/source regex matching, line matching, last-match-wins precedence, run-option override of suite config, default exact-location de-duplication, once-level and source-level de-duplication, and local `Warns()` capture that remains isolated from suite-level error filters. The wrapper supports repeatable `-WarningFilter` entries, legacy `action:Category` entries without `=` may still be comma-split, and key/value entries such as `action=error;category=DeprecationWarning;message=old, deprecated path;source=\.test\.ahk;line=12` are never comma-split so message/source regular expressions may contain commas; the `file` key is accepted as a source alias. CI artifact coverage includes category-only, message-matched, comma-containing message, source/line warning-as-error runs, and invalid config-default warning-filter diagnostics through `-Config`. Need integration with a stdlib warning module and default reporting policy before broad stdlib migration. |
| Filtering | `AhkTest.Run({ Filter: ... })`, `AhkTest.Run({ FilterExpr: ... })`, `AhkTest.Run({ NodeFilter: ... })`, `AhkTest.Run({ MarkExpr: ... })`, `tools\run-ahktest.ps1 -FilterExpr/-NodeFilter/-MarkExpr` | partial | Current `Filter` is substring selection. `FilterExpr` supports name boolean expressions with `and`, `or`, `not`, parentheses, and quoted phrases; `NodeFilter` supports exact node-id selection by string or array, including parameterized node ids; `MarkExpr` applies the same expression grammar to marker metadata. Deselected tests are counted in structured results, invalid expressions raise diagnostics, wrapper expression and node-id flags are forwarded individually and in combination, wrapper `-List` lists filtered tests without executing callbacks or requiring a run summary, wrapper `-Config` can load AHK config files or a covered JSON manifest before test files, and config-provided `AhkRunDefaults` can supply default filter/list options unless explicit wrapper flags override them. The current JSON manifest slice accepts an `AhkTest` section with `AhkRunDefaults`, including covered `FilterExpr` defaults and JSON boolean normalization for flags such as `List`, matching the observed local pytest 7.4.3 `addopts` precedence where an explicit CLI `-k` override wins over a config-provided default. Covered file-backed `LastFailed` runs now also match the observed local pytest 7.4.3 `--lf -k` slice when a `FilterExpr` selects tests entirely outside the cached failure set: that explicit filtered selection runs, and prior cached failures remain recorded after a clean selected pass. Need richer token rules and broader manifest-backed default settings. |
| Reporting | Structured `AhkTestResult`, `AhkTestResult.ToMap`, `ToJson`, `ToJUnitXml`, `WriteJson`, `WriteJUnitXml`, text report, `tools\run-ahktest.ps1 -JsonReport/-JUnitReport/-WarningSummary/-Summary/-Traceback/-CaptureReport` | partial | Current stats and entries include pass/fail/error/skip/xfail/xpass counts, deselected count, durations, marks, structured mark details, source metadata, captured output, warnings, grouped outcome reasons, grouped warning summaries, error type/message/location/stack fields, and errors. `ToMap()` provides a serialization-ready result shape including `OutcomeReasons` and `WarningSummary`, `ToJson()` emits compact JSON, `ToJUnitXml()` emits a JUnit-style XML string, and collection-time failures now use the dedicated `AhkTestCollectionError` type with pytest-style `collection failure` JUnit/error-message wording while preserving the underlying detail in `Extra`. Covered collection-failure results now serialize `ExitCode: 2`, and wrapper-generated synthetic collection-failure artifacts now preserve that same exit-code distinction for top-level test/config/plugin auto-execute load failures and top-level compiler syntax failures, while non-collection early usage/runtime failures such as invalid reporting options continue to exit with ordinary error code `1`. Result objects plus the wrapper can write JSON/JUnit artifact files for CI adapters on passing and failing runs, wrapper JSON artifacts preserve combined-filter deselection counts and selected node ids, and the wrapper now clears any pre-existing JSON/JUnit artifact path before each run so stale structured reports cannot be mistaken for fresh results. For compatibility with existing local scripts, `tools\run-ahktest.ps1` now accepts legacy `-OutputJson` / `-OutputJUnit` aliases in addition to `-JsonReport` / `-JUnitReport`. Text reports include grouped skip/xfail/xpass reason lines by default, `Run({ Summary: "s"|"x"|"X"|"w"|... })` and wrapper `-Summary` can select grouped skip/xfail/xpass/warning summaries, optional grouped warning summaries remain available through `WarningSummary: true` / wrapper `-WarningSummary`, `Run({ Traceback: "auto"|"short" })` / wrapper `-Traceback auto|short` emits short traceback diagnostics with message, location, and extra data, `Run({ Traceback: "long"|"native" })` / wrapper `-Traceback long|native` adds AHK stack output for failure/error reports, `Run({ Traceback: "line" })` / wrapper `-Traceback line` emits a compact one-line `file:line: ErrorType: message` style diagnostic, `Run({ Traceback: "no"|"none" })` / wrapper `-Traceback no` suppresses location/stack traceback details while retaining error message and extra diagnostics, and `Run({ CaptureReport: "failures"|"all"|"none"|"no"|"stdout"|"stderr" })` / wrapper `-CaptureReport failures|all|none|stdout|stderr` controls captured stdout/stderr text-report sections while keeping structured captured data on result entries. `Traceback` and `CaptureReport` values are validated for direct AHK API calls, wrapper flags, and config defaults; invalid enum values raise `ValueError` before tests execute. The wrapper now records the actual `result.ExitCode` through a small status file, so list-only or quiet runs from either CLI flags or config defaults do not need text-summary parsing; explicit quiet runs may omit the text report while still preserving exit status and JSON/JUnit artifacts for CI. List-only wrapper reports forward selected test names without executing callbacks. `run_finish`/`report_finish` hook errors remain visible in text output and serialized in JSON/JUnit artifacts. Need remaining traceback style/detail levels. |
| Plugins / hooks | `suite.On(eventName, callback, options?)`, `AhkTest.On(eventName, callback, options?)`, and wrapper plugin files | partial | Current implementation supports opt-in `collect_finish`, `run_start`, `test_start`, `test_finish`, `run_finish`, and `report_finish` hooks on suites; `AhkTest.On` registers hooks on the default suite for wrapper/plugin files, `tools\run-ahktest.ps1 -Plugin path` loads one or more AHK plugin files after config files and before test files, hook options support `Priority` ordering with stable registration order for equal priorities and optional `Id` metadata, `Run({ DisableHookIds: [...] })` plus wrapper `-DisableHookId` can suppress matching hooks without editing plugin files, `collect_finish` receives a per-run item list that hooks can inspect or modify, collection/run/report hook errors are returned as structured result error entries, start-hook errors are reported as structured test errors, finish-hook errors convert the current result entry into a structured error without duplicating entries, and run/report-finish hook failures are now visible in wrapper text output plus JSON/JUnit artifacts. Need richer plugin metadata, grouped plugin-level disable controls, and non-AHK plugin manifests without exposing pytest naming. |
| Config | stdlib-local config object and wrapper options | partial | Current `AhkTest.Configure({ Marks: ... })` and `suite.Configure({ Marks: ... })` register marker names from AHK config objects, `AhkTest.Configure({ AhkRunDefaults: ... })` and `suite.Configure({ AhkRunDefaults: ... })` provide validated run-option defaults, including unknown option rejection, reporting enum validation for `Traceback` and `CaptureReport`, warning-filter shape normalization for `WarningFilter`/`WarningFilters`, and hook-disable id normalization for `DisableHookIds`. The direct AHK surface now also exposes `AhkTest.ConfigureManifest(path, sectionName := "AhkTest")` / `suite.ConfigureManifest(...)` for a first non-AHK JSON manifest slice, recursively converting JSON objects into AHK config objects while normalizing root `stdlib.True` / `stdlib.False` JSON booleans back to native AHK booleans before run-option consumption. `tools\run-ahktest.ps1 -Config path` now loads AHK config files or dispatches `.json` paths through that manifest loader before plugin and test files, and wrapper options cover plugin files, hook id disabling, strict marker registration, filters, list mode, rerun cache, max-fail, xfail debugging, summary/traceback selection, warning filters, and report artifacts. JSON manifest configs may now also provide `AhkTest.DiscoveryRoots` as wrapper-side default discovery targets when `-Target` is omitted; those roots are resolved relative to the JSON config file, and an explicit wrapper `-Target` still takes precedence. The wrapper now forwards only explicitly bound run options into `AhkTest.Run(...)`, so config defaults are not overwritten by empty string, false, or zero CLI defaults; explicit wrapper flags still take precedence. Need broader manifest-based settings for temp dirs and default reporting, plus additional non-AHK config formats. |
| Cache / rerun | In-memory suite last-failed cache, file-backed last-failed cache, and stepwise state | partial | Current suite instances remember failed/error/strict-xpass rerun keys for in-memory `LastFailed` reruns, `LastFailedCache` persists stable rerun keys across suite instances and wrapper invocations, and stale file-backed last-failed caches now follow local pytest 7.4.3's covered fallback by running the current full collection when none of the cached failed keys exist in the current collected item set. Those stable keys now include source context when available, matching the covered local pytest 7.4.3 duplicate-name multi-file behavior for both `--lf` and `--sw`: same-name tests from different files rerun or resume only from the originally failing source file. When `LastFailed`/`LastFailedCache` is combined with a string `NodeFilter` or an array of exact node ids whose current selection falls entirely outside the cached failure set, ahktest now follows the observed local pytest 7.4.3 explicit-selection slice by executing that explicit selection, preserving prior cached failures after a clean selected pass, and merging newly failing selected nodes into the persisted cache while removing executed cached ids that now pass. If the explicit node-id selection mixes cached and non-cached nodes, the run continues to follow the cached intersection instead of overriding into the whole array. `Stepwise`/`StepwiseCache` stores a single failing rerun key; if that key still exists inside the current selected set, the next run resumes from it and clears after the resumed failure passes. If the cached stepwise key is stale or excluded by the current filtered/node-selected subset, ahktest now follows the observed local pytest 7.4.3 fallback by running the current selection instead, updating to a new failing node when one appears there, and otherwise leaving the prior cached key in place after a clean fallback run. Need richer cache invalidation for broader multi-node and mixed-rerun interactions. |
| Doctest | AHK doc/example execution strategy | missing | Lower priority than fixtures/capture/approx for stdlib migration. |

## Pillow Extension

`stdlib.pillow` is an explicitly added extension library, not a Python standard
library module. Its behavior authority is the local Python 3.10.11 environment
with Pillow 11.3.0, while the AHK implementation uses Windows system DLLs
instead of a Python subprocess backend. The target backend split is:
WIC (`windowscodecs.dll`) for image read/decode and pixel-format conversion,
Direct2D for filters, masks, blending, composition, and geometry/pixel-map
work, and WIC or GDI+ for save/output. The performance target is to move
behavior-locked CPU bridges behind these native backends slice by slice; no
slice should claim Pillow-level or better throughput until fresh local
benchmarks support that claim. The current promoted foundation uses WIC for
`Image.open(...)` read/decode and 32bpp BGRA pixel-format conversion, then
bridges into GDI+ (`gdiplus.dll`) for covered bitmap allocation, pixel access,
encode, crop, resize, and the first pixel-loop transform bridge; future slices
should migrate those internals behind the same public API rather than changing
callers. The first promoted slice covers `stdlib.pillow.Image`:
`Image.new("RGB", size, color)`, `Image.open(path)`, `.mode`, `.size`,
`.width`, `.height`, `.format`, `.getpixel(...)`, `.putpixel(...)`,
`.copy()`, `.crop(...)`, `.resize(...)`, `.save(path)`, `.close()`, and
Pillow-shaped `__Repr()` text.

Fresh behavior evidence comes from `.codex/pillow_image_core_probe.py` and
`.codex/pillow_image_core_probe.output.json`, which record Pillow 11.3.0
behavior for RGB image creation, pixel mutation, copy isolation, crop/resize
metadata, PNG save/open, and selected `ValueError` / `IndexError` messages.
Fresh AHK evidence includes focused red
`.codex/pillow-image-core-red-report.txt` failing at missing
`#Include <stdlib\pillow>`, focused green
`.codex/pillow-image-core-green-focused-report.txt` passing 1/1 after the
GDI+ implementation, module green `.codex/pillow-image-core-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 1/1, root filter
`.codex/pillow-image-core-root-filter-report.txt` passing 2/2, changed-file
validate `.codex/pillow-image-core-validate-report.txt` passing, and captured
example `.codex/pillow-image-core-example-report.txt` loading
`stdlib/examples/pillow.ahk` without warning/error at `TimeoutSeconds 90`.

The current Image module helper follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from `.codex/pillow_image_module_helpers_probe.py`
and `.codex/pillow_image_module_helpers_probe.output.json` confirming
`Image.getmodebands`, `Image.getmodebandnames`, `Image.getmodebase`,
`Image.getmodetype`, `Image.isImageType`, `Image.linear_gradient`, and
`Image.radial_gradient` for covered mode-table lookups, `L`/`P`/`1`
gradients, wrong-mode gradient errors, and bad-mode `KeyError` shape. The AHK
surface now exposes those module-level helpers, keeps the full mode lookup table
separate from `Image.new(...)` storage support, adds `P` scalar pixel support
for the promoted gradients, and generates the covered gradients through the
current pixel bridge. This locks more Pillow `Image` module behavior while the
target backend remains WIC for read/decode/pixel-format conversion, Direct2D for
filters, masks, blend, and composition, and WIC or GDI+ for save/output; this
slice does not claim Direct2D acceleration. Fresh AHK evidence includes focused
red `.codex/pillow-image-module-helpers-red-report.txt` failing because
`Image.getmodebands` was missing, focused green
`.codex/pillow-image-module-helpers-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-module-helpers-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 38/38, root filter
`.codex/pillow-image-module-helpers-root-filter-report.txt` passing 39/39, and
captured example `.codex/pillow-image-module-helpers-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The Image endian helper follow-up adds Pillow's public `Image.i32le(...)`,
`Image.o32le(...)`, and `Image.o32be(...)` module helpers. Fresh local Python
3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_endian_helpers_probe.py` and
`.codex/pillow-image-endian-helpers-probe.output.json` records signatures,
little-endian reads from bytes-like data with zero-based offsets, unsigned
32-bit little/big-endian packing, and the covered missing/extra argument,
short-buffer, bad-offset, string-input, non-integer, and out-of-range errors.
The AHK surface maps Python bytes-like inputs to covered `Array` and `Buffer`
values and maps Pillow's `struct.error` cases to generic AHK `Error` while
locking the observed messages. Focused red
`.codex/pillow-image-endian-helpers-red-report.txt` failed because the public
`i32le` helper was absent; focused green
`.codex/pillow-image-endian-helpers-green-focused-report.txt` passed 1/1 after
implementation. Fresh promotion gates include serial module
`.codex/pillow-image-endian-helpers-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 83/83 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-image-endian-helpers-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with README/example pollution assertions.

The Image init helper follow-up adds Pillow's public `Image.preinit()` and
`Image.init()` module helpers. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_image_init_probe.py` and
`.codex/pillow-image-init-probe.output.json` records the no-argument
signatures, `preinit()` returning `None`, first `init()` returning `True`,
subsequent `init()` returning `False`, second `preinit()` returning `None`,
key extension-registry visibility after plugin initialization, and the covered
extra-argument TypeErrors. Focused red
`.codex/pillow-image-init-red-report.txt` failed because the public
`preinit` helper was absent; focused green
`.codex/pillow-image-init-green-focused-report.txt` passed 1/1 after
implementation. Fresh promotion gates include serial module
`.codex/pillow-image-init-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 84/84 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-image-init-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with README/example pollution assertions. The current AHK registry is
eager/default-populated; this slice does not claim exact Python fresh-process
empty registry state or `registered_extensions()` implicit full plugin-load
parity.

The Image public registry dictionaries follow-up exposes the public registry
objects behind the existing registration helpers. Fresh local
Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_registry_dicts_probe.py` and
`.codex/pillow-image-registry-dicts-probe.output.json` records that
`Image.OPEN`, `Image.SAVE`, `Image.SAVE_ALL`, `Image.DECODERS`,
`Image.ENCODERS`, `Image.EXTENSION`, and `Image.MIME` are mutable dictionaries,
`Image.ID` and `Image.MODES` are mutable lists, registration helpers mutate
those same objects, format ids are uppercased for open/save/save_all/extension
/mime registries, decoder and encoder names preserve case, and
`registered_extensions()` returns the `Image.EXTENSION` object itself. The AHK
surface now exposes `stdlib.pillow.Image.OPEN`, `SAVE`, `SAVE_ALL`, `DECODERS`,
`ENCODERS`, `EXTENSION`, `MIME`, `ID`, and `MODES` as the public objects
backing the existing helper functions. AHK class member lookup is
case-insensitive, so a normal static `OPEN` declaration collides with the
existing `Image.open(...)` method; language probes
`.codex/pillow_registry_case_probe.test.ahk` /
`.codex/pillow-registry-case-probe-report.txt` and the class `DefineProp`
probe `.codex/pillow_class_defineprop_case_probe.test.ahk` /
`.codex/pillow-class-defineprop-case-probe-report.txt` document the chosen
bridge. Focused red `.codex/pillow-image-registry-dicts-red-report.txt` failed
because `Image.SAVE` was absent; focused green
`.codex/pillow-image-registry-dicts-green-focused-report.txt` passed 1/1 after
the first public properties were added; follow-up focused red
`.codex/pillow-image-open-registry-dict-red-report.txt` failed because
`Image.OPEN` still resolved as a method object; focused green
`.codex/pillow-image-open-registry-dict-green-focused-report.txt` passed 1/1
after the `DefineProp("OPEN", ...)` bridge was added. Serial module gate
`.codex/pillow-image-open-registry-dict-module-report.txt` plus
`.codex/pillow-image-open-registry-dict-module.json` passed
`stdlib/tests/pillow.test.ahk` 89/89 at `TimeoutSeconds 90`; and captured
example gate `.codex/pillow-image-open-registry-dict-example-report.txt`
passed `.codex/pillow_example_capture.test.ahk` 1/1 without warning/error
output and with explicit `System.Text.RegularExpressions` / `MatchEvaluator`
pollution assertions.

The Image path-helper follow-up adds Pillow's public `Image.is_path(...)`
module helper. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_is_path_probe.py` and
`.codex/pillow-image-is-path-probe.output.json` records true results for
`str`, `bytes`, `pathlib.Path`, and custom `os.PathLike`-style objects, false
for `bytearray`, `BytesIO`, `None`, `int`, and plain objects, plus the covered
missing/extra argument `TypeError` messages. The AHK surface now exposes
`stdlib.pillow.Image.is_path(...)`; AHK coverage maps `String`,
`stdlib.pathlib.Path`, and objects with `__fspath` as path-like, while
`stdlib.io.BytesIO`, `stdlib.None`, integers, maps, arrays, and buffers are
false. Native Python `bytes` path parity remains deferred until the stdlib has
a distinct bytes path object. Focused red
`.codex/pillow-image-is-path-red-report.txt` failed because the Image-level
helper was absent; focused green `.codex/pillow-image-is-path-green-focused-report.txt`
passed 1/1 after the helper was routed through the shared path predicate;
serial module gate `.codex/pillow-image-is-path-module-report.txt` and
structured `.codex/pillow-image-is-path-module.json` passed
`stdlib/tests/pillow.test.ahk` 86/86 at `TimeoutSeconds 90`; and captured
example `.codex/pillow-image-is-path-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The Image public errors/constants follow-up adds Pillow's
`Image.UnidentifiedImageError`, `Image.DecompressionBombWarning`,
`Image.DecompressionBombError`, `Image.MAX_IMAGE_PIXELS`, and
`Image.WARN_POSSIBLE_FORMATS` surface. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_image_public_errors_probe.py` and
`.codex/pillow-image-public-errors-probe.output.json` records the class names,
modules, MROs, empty and non-empty messages, `OSError` / `RuntimeWarning`
classification, and constants `89478485` / `False`. The AHK surface exposes the
three class objects and constructors under `stdlib.pillow.Image`; the
unidentified-image error extends `OSError`, the decompression-bomb error extends
`Error`, and the warning extends the current stdlib warning base. Focused red
`.codex/pillow-image-public-errors-red-report.txt` failed because
`Image.MAX_IMAGE_PIXELS` was absent; focused green
`.codex/pillow-image-public-errors-green-focused-report.txt` passed 1/1 after
the public attributes/classes were added; serial module gate
`.codex/pillow-image-public-errors-module-report.txt` plus
`.codex/pillow-image-public-errors-module.json` passed
`stdlib/tests/pillow.test.ahk` 87/87 at `TimeoutSeconds 90`; and captured
example gate `.codex/pillow-image-public-errors-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. An earlier parallel AHK gate attempt produced a no-status/BOM-only
runner artifact and was not used as promotion evidence; the trusted module and
example gates are the later serial reruns.

The Image compression constants follow-up adds Pillow's public integer
strategy constants `Image.DEFAULT_STRATEGY`, `Image.FILTERED`,
`Image.HUFFMAN_ONLY`, `Image.RLE`, `Image.FIXED`, and `Image.WEB`. Fresh local
Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_compression_constants_probe.py` and
`.codex/pillow-image-compression-constants-probe.output.json` records plain
`int` values `0`, `1`, `2`, `3`, `4`, and `0`, plus representative ordering
checks. Focused red `.codex/pillow-image-compression-constants-red-report.txt`
failed because `Image.DEFAULT_STRATEGY` was absent; focused green
`.codex/pillow-image-compression-constants-green-focused-report.txt` passed
1/1 after the constants were added; serial module gate
`.codex/pillow-image-compression-constants-module-report.txt` plus
`.codex/pillow-image-compression-constants-module.json` passed
`stdlib/tests/pillow.test.ahk` 90/90 at `TimeoutSeconds 90`; and captured
example gate `.codex/pillow-image-compression-constants-example-report.txt`
passed `.codex/pillow_example_capture.test.ahk` 1/1 without warning/error
output and with explicit `System.Text.RegularExpressions` / `MatchEvaluator`
pollution assertions. Top-level enum compatibility aliases such as
`Image.TRANSPOSE` remain unclaimed because AHK static property lookup is
case-insensitive; `.codex/pillow_static_property_defineprop_case_probe.test.ahk`
and `.codex/pillow-static-property-defineprop-case-probe-report.txt` show that
a `DefineProp("TRANSPOSE", ...)` bridge would overwrite both `Image.TRANSPOSE`
and the nested `Image.Transpose` class access.

The Image legacy alias and handler follow-up adds Pillow's module-level legacy
integer aliases for the covered `Resampling`, `Transform`, `Transpose`,
`Dither`, and `Quantize` enum members, plus the public `ImagePointHandler` and
`ImageTransformHandler` abstract class entries. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_image_legacy_surface_probe.py` and
`.codex/pillow_image_legacy_surface_probe.output.json` records the plain `int`
values for `Image.NEAREST`, `LANCZOS`, `BILINEAR`, `BICUBIC`, `BOX`,
`HAMMING`, `AFFINE`, `EXTENT`, `PERSPECTIVE`, `QUAD`, `MESH`,
`FLIP_LEFT_RIGHT`, `FLIP_TOP_BOTTOM`, `ROTATE_90`, `ROTATE_180`, `ROTATE_270`,
`TRANSVERSE`, `NONE`, `ORDERED`, `RASTERIZE`, `FLOYDSTEINBERG`, `WEB`,
`ADAPTIVE`, `MEDIANCUT`, `MAXCOVERAGE`, `FASTOCTREE`, and `LIBIMAGEQUANT`, and
records direct instantiation of the handler classes raising Pillow's abstract
class `TypeError` messages. The AHK surface intentionally keeps
`Image.TRANSPOSE` as the documented AHK case-insensitive collision with
`Image.Transpose` rather than replacing the nested enum class path. Focused red
`.codex/pillow-image-legacy-surface-red-report.txt` plus
`.codex/pillow-image-legacy-surface-red.json` failed because `Image.NEAREST`
was absent; focused green `.codex/pillow-image-legacy-surface-green-focused-report.txt`
plus `.codex/pillow-image-legacy-surface-green-focused.json` passed 1/1 after
implementation; captured example gate
`.codex/pillow-image-legacy-surface-example-report.txt` plus
`.codex/pillow-image-legacy-surface-example.json` passed
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions; and serial module gate
`.codex/pillow-image-legacy-surface-module-report.txt` plus
`.codex/pillow-image-legacy-surface-module.json` passed
`stdlib/tests/pillow.test.ahk` 170/170 at `TimeoutSeconds 90`.

The Image Exif follow-up adds Pillow's public `Image.Exif()` mutable mapping
surface and upgrades `Image.getexif()` from a plain internal map to the same
prefixed EXIF object class. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_image_exif_probe.py` and
`.codex/pillow-image-exif-probe.output.json` records the public class name,
no-argument constructor, missing constructor-arg `TypeError`, empty mapping
truth/length/keys/items/get behavior, empty `tobytes()` 20-byte EXIF header,
missing key `KeyError`, `get_ifd(...)` returning an empty dict for covered
inputs, mutation/deletion of tags `274` and `305`, and repeated
`Image.getexif()` returning the same image-owned object. The AHK surface now
exposes `stdlib.pillow.Image.Exif()` through `AhkStdlibPillowExif extends Map`,
keeps insertion order internally while matching the probed `keys()` /
`items()` order for covered updates, returns the probed empty EXIF header, and
preserves the EXIF object class through image copy/replace paths. This slice
still only claims in-memory EXIF mapping behavior; WIC/GDI+ file-level EXIF
decode/serialize and real IFD parsing remain deferred. Focused red
`.codex/pillow-image-exif-red-report.txt` failed because `Image.Exif` was
absent; focused green `.codex/pillow-image-exif-green-focused-report.txt`
passed 1/1 after implementation; trusted serial module gate
`.codex/pillow-image-exif-module-report.txt` plus
`.codex/pillow-image-exif-module.json` passed `stdlib/tests/pillow.test.ahk`
91/91 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-image-exif-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. An earlier serial module attempt produced a no-status runner
artifact and was not used as promotion evidence; the trusted module gate is the
later serial rerun.

The ExifTags follow-up adds Pillow's public `PIL.ExifTags` data surface as
`stdlib.pillow.ExifTags`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_exiftags_probe.py` and
`.codex/pillow-exiftags-probe.output.json` records module-level `TAGS` and
`GPSTAGS` dictionaries, their lengths (`273` and `32`), representative EXIF
and GPS tag names, the absence of `TAGS_V2` / `TAGS_V2_GROUPS` in this local
Pillow version, and the enum-like `Base`, `GPS`, `IFD`, `Interop`, and
`LightSource` public constants. The AHK surface now exposes
`stdlib.pillow.ExifTags.TAGS` and `.GPSTAGS` as shared Maps populated from the
local Pillow 11.3.0 tag tables, plus cached namespace objects for the covered
enum-like constants. This slice is tag metadata only; it does not claim file
EXIF parsing, TIFF tag decoding, or complete IntEnum method parity. Focused
red `.codex/pillow-exiftags-red-report.txt` failed because
`stdlib.pillow.ExifTags` was absent; focused green
`.codex/pillow-exiftags-green-focused-report.txt` passed 1/1 after the public
module surface was added; trusted serial module gate
`.codex/pillow-exiftags-module-report.txt` plus
`.codex/pillow-exiftags-module.json` passed `stdlib/tests/pillow.test.ahk`
92/92 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-exiftags-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The TiffTags follow-up adds Pillow's public `PIL.TiffTags` metadata surface as
`stdlib.pillow.TiffTags`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_tifftags_probe.py` and
`.codex/pillow-tifftags-probe.output.json` records constants, `TagInfo`
namedtuple fields/defaults/repr, `lookup(tag, group := None)`, `TAGS`
(`266` entries, including tuple-key enum rows), `TAGS_V2` (`110` entries),
empty `TYPES`, `LIBTIFF_CORE` (`36` entries), and `TAGS_V2_GROUPS` (`3`
groups: `34665`, `34853`, and `40965`). The AHK surface now exposes
`TiffTags.TAGS`, `.TAGS_V2`, `.TAGS_V2_GROUPS`, `.TYPES`,
`.LIBTIFF_CORE`, `.TagInfo(...)`, and `.lookup(...)`. Integer tag lookup and
group lookup follow Pillow semantics; tuple-key legacy enum rows from
`TAGS` are exposed with their probe-recorded string keys such as
`"(259, 5)"`, because AHK `Map` object keys do not provide Python tuple value
identity. This slice claimed metadata and lookup behavior only; TIFF image
I/O was promoted in the later built-in TIFF follow-up below.
Focused red `.codex/pillow-tifftags-red-report.txt` failed because
`stdlib.pillow.TiffTags` was absent; focused green
`.codex/pillow-tifftags-green-focused-report.txt` passed 1/1 after the module
surface and data tables were added; trusted serial module gate
`.codex/pillow-tifftags-module-report.txt` plus
`.codex/pillow-tifftags-module.json` passed `stdlib/tests/pillow.test.ahk`
93/93 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-tifftags-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The built-in TIFF image I/O follow-up extends `Image.open(...)` and
`Image.save(...)` to TIFF path and file-like streams for the covered RGB, L,
and RGBA round-trips. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_image_tiff_builtin_probe.py` and
`.codex/pillow-image-tiff-builtin-probe.output.json` records `.tif` and
`.tiff` registration, little-endian TIFF stream prefixes, `format == "TIFF"`,
`format_description == "Adobe TIFF"`, RGB/L/RGBA pixel round-trips, and
formats-filter `UnidentifiedImageError` behavior. The AHK surface now detects
TIFF magic bytes for file-like opens, keeps WIC decode for TIFF pixel reads,
uses TIFF IFD metadata to preserve grayscale `L` mode, and writes baseline
8-bit `L` TIFF byte streams for path and caller-owned file-like save targets.
Focused red `.codex/pillow-image-tiff-builtin-red-report.txt` captured the
missing/incomplete TIFF behavior before implementation; focused green
`.codex/pillow-image-tiff-builtin-green-focused-report.txt` passed 1/1 after
the TIFF metadata parser and `L` encoder were added; trusted serial module gate
`.codex/pillow-image-tiff-builtin-module-report.txt` plus
`.codex/pillow-image-tiff-builtin-module.json` passed
`stdlib/tests/pillow.test.ahk` 94/94 at `TimeoutSeconds 90`. The example was
updated to exercise TIFF path and file-like grayscale round-trips; captured
example gate `.codex/pillow-image-tiff-builtin-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The features follow-up adds Pillow's public `PIL.features` capability-query
surface as `stdlib.pillow.features`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_features_probe.py` and
`.codex/pillow-features-probe.output.json` records the module/codecs/features
tables, supported module/codec/feature list order, `check(...)` and
`version(...)` dispatch behavior, specialized `check_module` /
`check_codec` / `check_feature` and version helpers, unknown-name
`ValueError` messages for specialized helpers, unknown `check(...)`
`UserWarning`, deprecated WebP feature `DeprecationWarning`, and
`pilinfo(out=..., supported_formats=False)` returning `None` while writing
Pillow 11.3.0 information. The AHK surface exposes
`stdlib.pillow.features.modules`, `.codecs`, `.features`, `check(...)`,
`version(...)`, `check_module(...)`, `version_module(...)`,
`check_codec(...)`, `version_codec(...)`, `check_feature(...)`,
`version_feature(...)`, supported-list helpers, and `pilinfo(...)` against the
covered local Pillow 11.3.0 build matrix. Focused red
`.codex/pillow-features-red-report.txt` failed because
`stdlib.pillow.features` was absent; focused green
`.codex/pillow-features-green-focused-report.txt` passed 1/1 after
implementation; trusted serial module gate `.codex/pillow-features-module-report.txt`
plus `.codex/pillow-features-module.json` passed
`stdlib/tests/pillow.test.ahk` 95/95 at `TimeoutSeconds 90`; and captured
example gate `.codex/pillow-features-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The JpegPresets follow-up adds Pillow's public `PIL.JpegPresets.presets`
data surface as `stdlib.pillow.JpegPresets.presets`. Fresh local Python 3.10.11
plus Pillow 11.3.0 evidence from `.codex/pillow_jpegpresets_probe.py` and
`.codex/pillow-jpegpresets-probe.output.json` records that the module exposes
`presets` but no `samplings` attribute, the nine preset names, each
`subsampling` value, and all two-table 64-entry quantization matrices. The AHK
surface exposes the complete preset map with the covered quantization data and
keeps it mutable like the Python module dictionary; AHK `Map` key enumeration
uses AHK map ordering, so this slice claims the data keys and values rather
than Python insertion-order parity. Focused red
`.codex/pillow-jpegpresets-red-report.txt` failed because
`stdlib.pillow.JpegPresets` was absent; focused green
`.codex/pillow-jpegpresets-green-focused-report.txt` passed 1/1 after
implementation; trusted serial module gate
`.codex/pillow-jpegpresets-module-report.txt` plus
`.codex/pillow-jpegpresets-module.json` passed `stdlib/tests/pillow.test.ahk`
96/96 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-jpegpresets-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. JPEG save `quality="web_high"` style preset routing remains future
`JpegImagePlugin` / save-parameter work and is not claimed by this data slice.

The ContainerIO follow-up adds Pillow's public `PIL.ContainerIO.ContainerIO`
bounded file-like region reader as `stdlib.pillow.ContainerIO.ContainerIO(...)`.
Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_containerio_probe.py` and
`.codex/pillow-containerio-probe.output.json` records the public module names,
constructor arity errors, binary and text EOF behavior, region-relative
`tell()`, clamped `seek(...)` including unknown-mode default-to-set behavior,
`read(0)` reading the remaining region, `readline(...)`, `readlines(n)` as a
line-count limit, iterator StopIteration message, context-manager close
cascade, `readable`/`writable`/`seekable`/`isatty`, and delegated
`flush`/`fileno`/`close` plus write/truncate `NotImplementedError` paths. The
AHK surface follows the covered behavior while keeping the project-wide AHK
magic names `__Enter`/`__Exit` instead of Python's trailing-dunder names.
Focused red `.codex/pillow-containerio-red-report.txt` failed because
`stdlib.pillow.ContainerIO` was absent; focused green
`.codex/pillow-containerio-green-focused-report.txt` passed 1/1 after
implementation; trusted serial module gate
`.codex/pillow-containerio-module-report.txt` plus
`.codex/pillow-containerio-module.json` passed `stdlib/tests/pillow.test.ahk`
97/97 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-containerio-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The AvifImagePlugin follow-up adds the first real Pillow
`PIL.AvifImagePlugin` helper/registry slice as
`stdlib.pillow.AvifImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_avifimageplugin_probe.py` and
`.codex/pillow-avifimageplugin-probe.output.json` records the public module
names, `SUPPORTED`, `DECODE_CODEC_CHOICE`, `DEFAULT_MAX_THREADS`,
`get_codec_version(...)`, `_get_default_max_threads()`, `_accept(...)` for
`avif`/`avis`/`mif1`/`msf1` and rejected brands, the unsupported-AVIF accept
message, `AvifImageFile` format metadata, and invalid AVIF save parameter
errors for `quality` and `advanced`. A captured WIC feasibility probe
`.codex/pillow_avif_wic_probe.test.ahk` /
`.codex/pillow-avif-wic-probe-report.txt` shows the current Windows imaging
backend does not decode the local Pillow-generated AVIF sample, so actual AVIF
decode/save remains a backend task and is not claimed by this slice. The AHK
surface exposes the covered helpers, registers AVIF save/save_all/mime entries,
and routes `Image.save(..., "AVIF", params)` through Pillow-style parameter
validation before reporting that the AVIF encode backend is unavailable.
Focused red `.codex/pillow-avifimageplugin-red-report.txt` failed because
`stdlib.pillow.AvifImagePlugin` was absent; focused green
`.codex/pillow-avifimageplugin-green-focused-report.txt` passed 1/1 after
implementation; trusted serial module gate
`.codex/pillow-avifimageplugin-module-report.txt` plus
`.codex/pillow-avifimageplugin-module.json` passed `stdlib/tests/pillow.test.ahk`
99/99 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-avifimageplugin-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The BmpImagePlugin follow-up adds the first real Pillow
`PIL.BmpImagePlugin` slice as `stdlib.pillow.BmpImagePlugin`. Fresh local
Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_bmpimageplugin_probe.py` and
`.codex/pillow-bmpimageplugin-probe.output.json` records public module names,
`BIT2MODE`, `SAVE`, `USE_RAW_ALPHA`, `_accept(...)`, `_dib_accept(...)`,
`i16`/`i32`/`o8`/`o16`/`o32`, direct `BmpImageFile(...)` and
`DibImageFile(...)` construction from in-memory BMP/DIB streams, format and
format-description values, mode/size/pixel/compression metadata, and covered
bad-magic/header/arity errors. The AHK surface exposes the covered public
maps/helpers and real BMP/DIB factories: `BmpImageFile(...)` reuses the
existing WIC-backed BMP decode path, while `DibImageFile(...)` wraps a DIB
payload in a synthesized BMP file header before decoding and then reports
`format == "DIB"`. RLE decoding and the full Pillow `BmpRleDecoder` plugin
remain future slices and are not claimed here. Focused red
`.codex/pillow-bmpimageplugin-red-report.txt` failed because
`stdlib.pillow.BmpImagePlugin` was absent; focused green
`.codex/pillow-bmpimageplugin-green-focused-report.txt` passed 1/1 after
implementation; trusted serial module gate
`.codex/pillow-bmpimageplugin-module-report.txt` plus
`.codex/pillow-bmpimageplugin-module.json` passed `stdlib/tests/pillow.test.ahk`
98/98 at `TimeoutSeconds 90`; and captured example gate
`.codex/pillow-bmpimageplugin-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The Image DeferredError follow-up adds Pillow's public
`Image.DeferredError(...)` helper surface. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_image_deferred_error_probe.py` and
`.codex/pillow-image-deferred-error-probe.output.json` records the class name
`DeferredError`, module `PIL._util`, object-only MRO, constructor and
`DeferredError.new(ex)` storage of the wrapped exception, wrapped-exception
raising on arbitrary attribute access, and covered missing/extra argument
`TypeError` messages. The AHK surface now exposes
`stdlib.pillow.Image.DeferredError(...)` and
`stdlib.pillow.Image.DeferredError.new(...)` through the existing prefixed
`AhkStdlibPillowDeferredError` helper. Focused red
`.codex/pillow-image-deferred-error-red-report.txt` failed because
`Image.DeferredError` was absent; focused green
`.codex/pillow-image-deferred-error-green-focused-report.txt` passed 1/1 after
the Image module property and constructor were added; serial module gate
`.codex/pillow-image-deferred-error-module-report.txt` plus
`.codex/pillow-image-deferred-error-module.json` passed
`stdlib/tests/pillow.test.ahk` 88/88 at `TimeoutSeconds 90`; and captured
example gate `.codex/pillow-image-deferred-error-example-report.txt` passed
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions.

The current Image inspection follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_inspection_probe.py` and
`.codex/pillow_image_inspection_probe.output.json` confirming `Image.getbands`,
`Image.getbbox(alpha_only := true)`, `Image.getextrema`, `Image.getcolors`,
`Image.histogram`, and `Image.getprojection` for covered `RGB`, `L`, `RGBA`,
and `1` images. The probe locks alpha-only versus all-channel `RGBA` bounding
boxes, empty-image `None`, banded extrema, color count overflow returning
`None`, Pillow color ordering, 256-bin-per-band histograms, projection rows,
and representative `TypeError` / `AttributeError` shapes. The AHK surface now
exposes these read-only inspection methods through the existing GDI+ pixel
bridge. This expands real `Image` instance behavior while the target backend
remains WIC for read/decode/pixel-format conversion, Direct2D for filters,
masks, blend, and composition, and WIC or GDI+ for save/output; this slice does
not claim Direct2D acceleration. Fresh AHK evidence includes focused red
`.codex/pillow-image-inspection-red-report.txt` failing because `getbands` was
missing, focused green `.codex/pillow-image-inspection-green-focused-report.txt`
passing 1/1, module `.codex/pillow-image-inspection-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 39/39, root filter
`.codex/pillow-image-inspection-root-filter-report.txt` passing 40/40, and
captured example `.codex/pillow-image-inspection-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image data-access follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_data_probe.py` and
`.codex/pillow_image_data_probe.output.json` confirming `Image.getdata`,
`Image.tobytes`, `Image.frombytes`, and `Image.putdata` for covered `RGB`,
`L`, `RGBA`, and `1` images. The probe locks row-major data order, band
selection, raw byte order, packed `1`-mode bytes, raw `frombytes` mutation,
`putdata` scale/offset clipping, short `putdata` prefix writes, scalar RGB
fallback, and representative `ValueError` / `OSError` / `TypeError` shapes.
The AHK surface now exposes these data-access methods through array-backed byte
and pixel bridges. This expands the current Pillow data path while the target
backend remains WIC for read/decode/pixel-format conversion, Direct2D for
filters, masks, blend, and composition, and WIC or GDI+ for save/output; this
slice does not claim Direct2D acceleration. Fresh AHK evidence includes focused
red `.codex/pillow-image-data-red-report.txt` failing because `putdata` was
missing, focused green `.codex/pillow-image-data-green-focused-report.txt`
passing 1/1, module `.codex/pillow-image-data-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 40/40, root filter
`.codex/pillow-image-data-root-filter-report.txt` passing 41/41, and captured
example `.codex/pillow-image-data-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.

The current Image palette follow-up uses fresh local Python 3.10.11 + Pillow
11.3.0 evidence from `.codex/pillow_image_palette_probe.py` and
`.codex/pillow_image_palette_probe.output.json` confirming `Image.getpalette`
and `Image.putpalette` for covered `P` and `L` images, `RGB` and `RGBA`
rawmodes, default empty palettes, bytes/list palette input, RGB extraction from
RGBA palettes, RGBA expansion from RGB palettes, palette preservation of image
data, and representative `ValueError` / `TypeError` shapes. The AHK surface now
stores palette metadata on image objects and clones it through existing image
copy paths. This expands `P`-mode behavior while the target backend remains WIC
for read/decode/pixel-format conversion, Direct2D for filters, masks, blend,
and composition, and WIC or GDI+ for save/output; this slice does not claim
Direct2D acceleration. Fresh AHK evidence includes focused red
`.codex/pillow-image-palette-red-report.txt` failing because `getpalette` was
missing, focused green `.codex/pillow-image-palette-green-focused-report.txt`
passing 1/1, module `.codex/pillow-image-palette-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 41/41, root filter
`.codex/pillow-image-palette-root-filter-report.txt` passing 42/42, and
captured example `.codex/pillow-image-palette-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image apply-transparency follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from
`.codex/pillow_image_apply_transparency_probe.py` and
`.codex/pillow_image_apply_transparency_probe.output.json` confirming
`Image.apply_transparency()` for covered `P` images with
`info["transparency"]` as an integer palette index or bytes-like alpha table.
The probe also confirms `has_transparency_data` truthiness for alpha-capable
modes / info transparency / RGBA palettes, no-op behavior for non-`P` images
and `P` images without a transparency key, deletion of the consumed
`info["transparency"]` key for `P` conversions, preservation of indexed image
data, and representative bad string / out-of-range palette-index error shapes.
The AHK surface now exposes an `info` map on image objects,
`has_transparency_data`, and `apply_transparency()`, applying transparency into
the stored RGBA palette while preserving existing `getpalette("RGB")` behavior.
This remains a CPU metadata/palette bridge over the current image object model
and does not claim broader Pillow metadata parity. Fresh AHK evidence includes
focused red `.codex/pillow-image-apply-transparency-red-report.txt` failing
because `AhkStdlibPillowImage` had no `has_transparency_data` property,
focused green `.codex/pillow-image-apply-transparency-green-focused-report.txt`
passing 1/1, module `.codex/pillow-image-apply-transparency-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 46/46, and root filter
`.codex/pillow-image-apply-transparency-root-filter-report.txt` passing 47/47.

The current Image entropy follow-up uses fresh local Python 3.10.11 + Pillow
11.3.0 evidence from `.codex/pillow_image_entropy_probe.py` and
`.codex/pillow_image_entropy_probe.output.json` confirming `Image.entropy()`
for covered `L`, `RGB`, `RGBA`, and `1` images, flat-image `0.0` behavior,
`L` mask selection, and representative bad-mask, mask-size, and mask-mode
errors. The AHK surface now exposes `AhkStdlibPillowImage.entropy(...)` through
the existing histogram bridge and computes `-p * log2(p)` across populated bins.
This is a behavior lock for the target backend split: WIC handles
read/decode/pixel-format conversion, Direct2D is intended for accelerated
filters, masks, blend, composition, histogram/pixel-map work, and WIC or GDI+
handles save/output. The current entropy implementation remains CPU/pixel-loop
based and does not claim Direct2D acceleration. Fresh AHK evidence includes
focused red `.codex/pillow-image-entropy-red-report.txt` failing because
`AhkStdlibPillowImage` had no `entropy` method, focused green
`.codex/pillow-image-entropy-green-focused-report.txt` passing 1/1, module
`.codex/pillow-image-entropy-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 42/42, root filter
`.codex/pillow-image-entropy-root-filter-report.txt` passing 43/43, and
captured example `.codex/pillow-image-entropy-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image reduce follow-up uses fresh local Python 3.10.11 + Pillow
11.3.0 evidence from `.codex/pillow_image_reduce_probe.py` and
`.codex/pillow_image_reduce_probe.output.json` confirming `Image.reduce(...)`
for covered `RGB` and `L` images, integer and two-axis factors, optional source
box handling, rounded-up target sizes, factor-one copy isolation, and
representative factor, box, and wrong-mode error shapes. The AHK surface now
exposes `AhkStdlibPillowImage.reduce(...)` through a CPU block-average bridge
that preserves the current image object model and EXIF/palette metadata. This
is a behavior lock for the same target backend split: WIC handles
read/decode/pixel-format conversion, Direct2D is intended for accelerated
filters, masks, blend, composition, histogram/pixel-map/reduce work, and WIC or
GDI+ handles save/output. The current implementation does not yet claim
Direct2D acceleration or full premultiplied-alpha `LA` / `RGBA` reduce parity.
Fresh AHK evidence includes focused red
`.codex/pillow-image-reduce-red-report.txt` failing because
`AhkStdlibPillowImage` had no `reduce` method, focused green
`.codex/pillow-image-reduce-green-focused-report.txt` passing 1/1, module
`.codex/pillow-image-reduce-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 43/43, root filter
`.codex/pillow-image-reduce-root-filter-report.txt` passing 44/44, and
captured example `.codex/pillow-image-reduce-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image thumbnail follow-up uses fresh local Python 3.10.11 + Pillow
11.3.0 evidence from `.codex/pillow_image_thumbnail_probe.py` and
`.codex/pillow_image_thumbnail_probe.output.json` confirming
`Image.thumbnail(...)` in-place behavior for covered `RGB` and `L` images,
aspect-preserving target-size floor handling, no-op behavior when the requested
box is larger than the image, representative thumbnail pixels, and size /
`reducing_gap` error shapes. The AHK surface now exposes
`AhkStdlibPillowImage.thumbnail(...)` and replaces the image bitmap in place
after a CPU separable cubic resample bridge. This is a behavior lock for the
target backend split: WIC handles read/decode/pixel-format conversion, Direct2D
is intended for accelerated resize/thumbnail/reduce/filter/mask/blend/
composition work, and WIC or GDI+ handles save/output. The current thumbnail
implementation does not yet claim Direct2D acceleration or complete Pillow C
resampler parity outside the covered probe paths. Fresh AHK evidence includes
focused red `.codex/pillow-image-thumbnail-red-report.txt` failing because
`AhkStdlibPillowImage` had no `thumbnail` method, focused green
`.codex/pillow-image-thumbnail-green-focused-report.txt` passing 1/1, module
`.codex/pillow-image-thumbnail-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 44/44, root filter
`.codex/pillow-image-thumbnail-root-filter-report.txt` passing 45/45, and
captured example `.codex/pillow-image-thumbnail-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image effect_spread follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_effect_spread_probe.py` and
`.codex/pillow_image_effect_spread_probe.output.json` confirming
`Image.effect_spread(distance)` returns a new image, preserves mode and size,
copies pixels exactly for `distance == 0` and negative distances, keeps the
source image isolated from result mutation, accepts integer distances, and
raises the observed integer-conversion `TypeError` shapes for float, string,
and `None` distances. The probe also records that nonzero spread is
non-deterministic across calls, matching Pillow's random-pixel effect, so the
AHK test locks the public behavior by asserting size/mode preservation,
source/result isolation, and that nonzero result pixels come from the original
image's pixel set rather than claiming deterministic pixel parity. The current
implementation is a CPU pixel-loop bridge over the existing image object model
and does not claim Direct2D acceleration. Fresh AHK evidence includes focused
red `.codex/pillow-image-effect-spread-red-report.txt` failing because
`AhkStdlibPillowImage` had no `effect_spread` method, focused green
`.codex/pillow-image-effect-spread-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-effect-spread-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 45/45, and root filter
`.codex/pillow-image-effect-spread-root-filter-report.txt` passing 46/46.

The current Image frame-method follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_frame_methods_probe.py` and
`.codex/pillow_image_frame_methods_probe.output.json` confirming base
single-frame `Image.tell() == 0`, `seek(0)` and `seek(0.0)` returning `None`,
`verify()` returning `None` without changing decoded pixels, copy `tell()`
behavior, EOF errors for nonzero / negative / string frame seeks, and
representative missing/extra positional TypeError shapes. The AHK surface now
exposes `AhkStdlibPillowImage.tell(...)`, `seek(...)`, and `verify(...)` for
the covered base-image lifecycle path, which sets up later ImageSequence and
multi-frame file-handler work without claiming multi-frame format support yet.
Fresh AHK evidence includes focused red
`.codex/pillow-image-frame-methods-red-report.txt` failing because
`AhkStdlibPillowImage` had no `tell` method, focused green
`.codex/pillow-image-frame-methods-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-frame-methods-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 47/47, and root filter
`.codex/pillow-image-frame-methods-root-filter-report.txt` passing 48/48.

The current Image remap-palette follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_remap_palette_probe.py` and
`.codex/pillow_image_remap_palette_probe.output.json` confirming
`Image.remap_palette(dest_map, source_palette := None)` for covered `P` and
`L` images. The probe locks `dest_map` reordering, compacted RGB/RGBA palette
bytes, original-image isolation, `L` returning a `P` image with a generated
grayscale source palette, `source_palette` override behavior including RGBA
palette selection when the source palette is longer than 768 bytes,
transparency-index remapping and deletion for unused transparency, and
representative illegal-mode / non-integer dest-map / string-source-palette /
out-of-range dest-map error shapes. It also records Pillow's permissive empty
dest-map, negative dest-map, and short-source-palette cases, where pixels fall
back through zero-filled `new_positions` and palette bytes can be empty. The
AHK surface now exposes `AhkStdlibPillowImage.remap_palette(...)` through a CPU
palette/pixel remapping bridge that preserves the current public image object
model; this slice does not claim Direct2D acceleration. Fresh AHK evidence
includes focused red `.codex/pillow-image-remap-palette-red-report.txt`
failing because `AhkStdlibPillowImage` had no `remap_palette` method, focused
green `.codex/pillow-image-remap-palette-green-focused-report.txt` passing
1/1, module `.codex/pillow-image-remap-palette-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 48/48, root filter
`.codex/pillow-image-remap-palette-root-filter-report.txt` passing 49/49, and
captured example `.codex/pillow-image-remap-palette-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image transform follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_transform_probe.py` and
`.codex/pillow_image_transform_probe.output.json` confirming
`Image.Transform` and `Image.Resampling` constant values plus
`Image.transform(size, method, data, resample=NEAREST, fill=1, fillcolor=None)`
for covered `RGB` and `P` images. The probe locks exact NEAREST pixels for
`AFFINE`, `EXTENT`, `QUAD`, and `MESH`, fillcolor behavior outside the source
image, info-copy behavior, palette preservation for `P` images, old-style
`method.getdata()` compatibility, transform-handler delegation, and
representative missing-data / unknown-method / invalid-resampling error
messages. The AHK surface now exposes `Image.Transform`,
`Image.Resampling`, and `AhkStdlibPillowImage.transform(...)` through a CPU
geometry bridge that uses center-based NEAREST sampling and reuses the existing
mesh copy path. This is a behavior lock for later Direct2D geometry and
resampling acceleration; it does not claim BILINEAR/BICUBIC pixel parity beyond
covered validation and fallback paths. Fresh AHK evidence includes focused red
`.codex/pillow-image-transform-red-report.txt` failing because
`Image.Transform` was missing, focused green
`.codex/pillow-image-transform-green-focused-report.txt` passing 1/1, module
`.codex/pillow-image-transform-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 49/49, root filter
`.codex/pillow-image-transform-root-filter-report.txt` passing 50/50, and
captured example `.codex/pillow-image-transform-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image quantize follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_quantize_probe.py` and
`.codex/pillow_image_quantize_probe.output.json` confirming `Image.Dither`
and `Image.Quantize` constant values plus
`Image.quantize(colors=256, method=None, kmeans=0, palette=None,
dither=Image.Dither.FLOYDSTEINBERG)` for covered `RGB`, `L`, and `RGBA`
images. The probe locks default RGB/RGBA/L palette/data results, `colors=2`
RGB reduction, quantizing to an explicit `P` palette, representative RGBA
method restrictions, bad-palette mode errors, RGBA-to-palette errors,
negative-`kmeans` errors, and bad color-count errors. The AHK surface now
exposes `Image.Dither`, `Image.Quantize`, and
`AhkStdlibPillowImage.quantize(...)` through a CPU palette bridge, and fixes
`P` image conversion to `RGB`/`RGBA` through palette lookup. This locks
behavior for later WIC/Direct2D palette and pixel-map acceleration; it does
not claim Direct2D acceleration yet. Fresh AHK evidence includes focused red
`.codex/pillow-image-quantize-red-report.txt` failing because `Image.Dither`
was missing, focused green `.codex/pillow-image-quantize-green-focused-report.txt`
passing 1/1, module `.codex/pillow-image-quantize-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 50/50, root filter
`.codex/pillow-image-quantize-root-filter-report.txt` passing 51/51, and
captured example `.codex/pillow-image-quantize-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image instance-surface follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_instance_surface_probe.py`
and `.codex/pillow_image_instance_surface_probe.output.json` confirming
`readonly`, `format_description`, `draft(...)`, `get_child_images()`,
`getxmp()`, `getim()`, `im`, and `tobitmap(...)` for covered newly-created
images, reopened PNG images, and `1`-mode XBM output. The probe locks
new-image `readonly == 0`, reopened PNG `readonly == 1`,
`format_description == "Portable network graphics"` for PNG,
`draft(...) == None`, empty child-image and XMP containers, Pillow-shaped
`PyCapsule` / `ImagingCore` repr text, covered `tobitmap("x")` bytes, default
`image` XBM naming, `ValueError("not a bitmap")` for RGB `tobitmap`, and
representative extra/missing positional TypeError messages. The AHK surface
now exposes these instance metadata APIs plus a covered `1`-mode XBM byte
bridge while keeping the real native image backend encapsulated; this slice
does not claim raw Pillow ImagingCore pointer interoperability or Direct2D
acceleration. Fresh AHK evidence includes focused red
`.codex/pillow-image-instance-surface-red-report.txt` failing because
`readonly` was missing, focused green
`.codex/pillow-image-instance-surface-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-instance-surface-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 51/51, root filter
`.codex/pillow-image-instance-surface-root-filter-report.txt` passing 52/52,
and captured example `.codex/pillow-image-instance-surface-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image frombytes/frombuffer follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_frombytes_frombuffer_probe.py`
and `.codex/pillow_image_frombytes_frombuffer_probe.output.json` confirming
module-level `Image.frombytes(...)` and `Image.frombuffer(...)` for covered
`RGB`, `L`, `RGBA`, and `1` images. The probe locks RGB/L/RGBA pixel rows,
`1`-mode packed-bit behavior, `raw` / `BGR` channel swapping, covered
`frombuffer` `readonly` values, and representative bad-mode, short-data, and
bad-decoder errors. The AHK surface now exposes
`stdlib.pillow.Image.frombytes(...)` and `stdlib.pillow.Image.frombuffer(...)`
by constructing a normal image and routing through the existing raw byte
decoder; the covered `frombuffer("L", ..., "raw", "L", 0, 1)` path marks the
result readonly, but this slice does not claim Python bytearray buffer-alias
sharing yet. Fresh AHK evidence includes focused red
`.codex/pillow-image-frombytes-frombuffer-red-report.txt` failing because
`Image.frombytes` was missing, focused green
`.codex/pillow-image-frombytes-frombuffer-green-focused-report.txt` passing
1/1, module `.codex/pillow-image-frombytes-frombuffer-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 52/52, root filter
`.codex/pillow-image-frombytes-frombuffer-root-filter-report.txt` passing
53/53, and captured example
`.codex/pillow-image-frombytes-frombuffer-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image effect-mandelbrot follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_effect_mandelbrot_probe.py`
and `.codex/pillow_image_effect_mandelbrot_probe.output.json` confirming
`Image.effect_mandelbrot(size, extent, quality)` for covered small `L` images.
The probe locks mode, size, readonly, representative pixel rows, histogram
prefix data, zero-width extent behavior, and representative bad-size,
bad-extent, and bad-quality TypeError messages. The AHK surface now exposes
`stdlib.pillow.Image.effect_mandelbrot(...)` through a CPU pixel bridge matching
Pillow 11.3.0's `libImaging` iteration order and escape threshold for the
covered cases. This is a behavior lock for later Direct2D or compute-style
pixel generation and does not claim accelerated performance. Fresh AHK
evidence includes focused red `.codex/pillow-image-effect-mandelbrot-red-report.txt`
failing because `Image.effect_mandelbrot` was missing, focused green
`.codex/pillow-image-effect-mandelbrot-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-effect-mandelbrot-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 53/53, root filter
`.codex/pillow-image-effect-mandelbrot-root-filter-report.txt` passing 54/54,
and captured example `.codex/pillow-image-effect-mandelbrot-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image effect-noise follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_effect_noise_probe.py` and
`.codex/pillow-image-effect-noise-probe.output.json` confirming
`Image.effect_noise(size, sigma)`. The probe locks the public signature, `L`
mode output, size, readonly state, zero-sigma all-128 pixels, empty-image
behavior for `[0, 0]`, representative argument errors, and the fact that
nonzero-sigma rows are non-deterministic. The AHK surface now exposes
`stdlib.pillow.Image.effect_noise(...)` through a CPU Gaussian-noise bridge
returning byte-clamped `L` images for the covered cases. This slice deliberately
does not claim exact Pillow C RNG sequence parity for nonzero sigma; tests lock
mode/size/range/error behavior plus the deterministic sigma=0 case. Fresh AHK
evidence includes focused red `.codex/pillow-image-effect-noise-red-report.txt`
failing because `Image.effect_noise` was missing, focused green
`.codex/pillow-image-effect-noise-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-effect-noise-module-report.txt` and structured
`.codex/pillow-image-effect-noise-module.json` passing
`stdlib/tests/pillow.test.ahk` 85/85 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-image-effect-noise-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. A prior module-gate attempt produced no ahktest status artifact and
is not used as promotion evidence; the trusted module evidence is the later
85/85 run with JSON output.

The current Image registry follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_image_registry_probe.py` and
`.codex/pillow_image_registry_probe.output.json` confirming module-level
`register_open`, `register_save`, `register_save_all`, `register_decoder`,
`register_encoder`, `register_extension`, `register_extensions`,
`register_mime`, and `registered_extensions()`. The probe locks return values,
default extension mapping snapshots, custom extension registration, MIME
registration, registry membership for open/save/decoder/encoder tables, and
representative missing-argument `TypeError` messages. The AHK surface now
stores Pillow-shaped registry maps and returns a cloned extension mapping while
leaving actual custom plugin decoder/encoder invocation for a later slice. This
registry layer is Python-level behavior; it does not claim image codec coverage
or benchmark-backed Pillow performance parity. Fresh AHK evidence includes
focused red `.codex/pillow-image-registry-red-report.txt` failing because
`registered_extensions` was missing, focused green
`.codex/pillow-image-registry-green-focused-report.txt` passing 1/1, module
`.codex/pillow-image-registry-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 54/54, root filter
`.codex/pillow-image-registry-root-filter-report.txt` passing 55/55, and
captured example `.codex/pillow-image-registry-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current Image codec-registry invocation follow-up uses fresh local Python
3.10.11 + Pillow 11.3.0 evidence from
`.codex/pillow_image_codec_registry_probe.py` and
`.codex/pillow_image_codec_registry_probe.output.json` confirming that
`Image.frombytes(..., decoder_name, ...)`, instance
`image.frombytes(..., decoder_name, ...)`, and
`image.tobytes(encoder_name, ...)` consult registered custom
decoder/encoder factories before core codecs. The probe locks factory
argument normalization, `setimage(...)` calls, decoder `decode(data)` result
handling, encoder `encode(65536)` loop behavior, and representative
missing/short/error decoder and encoder exception messages. The AHK surface
now invokes registered decoder/encoder factories for non-`raw` codec names and
routes successful decoded bytes back through the existing raw byte bridge. This
is a registry/plugin invocation behavior lock; it does not claim arbitrary
Pillow file codec parity or benchmark-backed Pillow performance parity. Fresh
AHK evidence includes focused red
`.codex/pillow-image-codec-registry-red-report.txt` failing on the old
non-raw codec path, focused green
`.codex/pillow-image-codec-registry-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-codec-registry-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 55/55, root filter
`.codex/pillow-image-codec-registry-root-filter-report.txt` passing 56/56, and
captured example `.codex/pillow-image-codec-registry-example-report.txt`
passing 1/1 through the fixed `AhkTest.CaptureFixture().RunArgs(...)` path
which waits for the real AutoHotkey child process.

The current Image save-registry invocation follow-up uses fresh local Python
3.10.11 + Pillow 11.3.0 evidence from
`.codex/pillow_image_save_registry_probe.py` and
`.codex/pillow_image_save_registry_probe.output.json` confirming that
`Image.save(...)` consults registered `SAVE` and `SAVE_ALL` handlers after
format resolution. The probe locks extension-derived format lookup, explicit
format override, handler arguments `(image, fp, filename)`, handler-visible
`encoderinfo` / `_default_encoderinfo`, `save_all=True` routing to
`SAVE_ALL`, `append_images` routing to `SAVE_ALL`, new-file cleanup after a
handler exception, and representative unknown-extension `ValueError` messages.
The AHK surface now routes custom registered save handlers through a file
wrapper with `write(...)` and restores image encoder state after the call; the
existing GDI+ path remains responsible for built-in PNG/BMP/JPEG output. This
is a custom registry/plugin save behavior lock; it does not claim arbitrary
Pillow file codec parity or benchmark-backed Pillow performance parity. Fresh
AHK evidence includes focused red
`.codex/pillow-image-save-registry-red-report.txt` failing before
`Image.save(..., params)` and registry dispatch existed, focused green
`.codex/pillow-image-save-registry-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-save-registry-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 56/56, root filter
`.codex/pillow-image-save-registry-root-filter-report.txt` passing 57/57, and
captured example `.codex/pillow-image-save-registry-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current modes/formats follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_modes_formats_probe.py` and
`.codex/pillow_modes_formats_probe.output.json` confirming `L` pixels as
integers, `RGBA` pixels as four-element tuples, and PNG/BMP/JPEG save/open
format/mode/size behavior. The existing GDI+ backend already satisfied this
coverage, so no implementation change was required beyond examples and tests.
Fresh AHK evidence includes focused
`.codex/pillow-modes-formats-focused-report.txt` passing 1/1, module
`.codex/pillow-modes-formats-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 2/2, root filter
`.codex/pillow-modes-formats-root-filter-report.txt` passing 3/3,
changed-file validate `.codex/pillow-modes-formats-validate-report.txt`
passing, and captured example `.codex/pillow-modes-formats-example-report.txt`
loading `stdlib/examples/pillow.ahk` without warning/error at
`TimeoutSeconds 90`.

The current transform follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_transform_probe.py` and
`.codex/pillow_transform_probe.output.json` confirming
`Image.Transpose.FLIP_LEFT_RIGHT == 0`,
`Image.Transpose.ROTATE_90 == 2`, RGB-to-`L` luma values,
RGB/RGBA conversion alpha behavior, horizontal flip pixels, transpose rotate
90 pixels, and `rotate(90)` with and without `expand`. Fresh AHK evidence
includes focused red `.codex/pillow-transform-red-report.txt` failing at the
missing `Image.Transpose` surface, focused green
`.codex/pillow-transform-green-focused-report.txt` passing 1/1, module
`.codex/pillow-transform-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 3/3, root filter
`.codex/pillow-transform-root-filter-report.txt` passing 4/4, changed-file
validate `.codex/pillow-transform-validate-report.txt` passing, and captured
example `.codex/pillow-transform-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)` with explicit checks that
`stdlib/examples/pillow.ahk` contains no
`System.Text.RegularExpressions` or `MatchEvaluator` pollution.

The current WIC open follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_rgba_png_probe.py` and
`.codex/pillow_rgba_png_probe.output.json` confirming that an `RGBA` PNG saved
with alpha pixels reopens as `format == "PNG"`, `mode == "RGBA"`, preserves
four-channel pixels, and converts to RGB by dropping alpha channels. The AHK
`Image.open(path)` path now starts with WIC (`windowscodecs.dll`) decode and
pixel-format conversion to 32bpp BGRA, scans alpha to choose `RGB` versus
`RGBA`, and then bridges into the current GDI+ bitmap handle used by the public
image object. Fresh AHK evidence includes focused red
`.codex/pillow-rgba-png-open-red-report.txt` failing because the previous
extension-based path reopened the PNG as `RGB`, focused green
`.codex/pillow-rgba-png-open-green-focused-report.txt` passing 1/1, module
`.codex/pillow-rgba-png-open-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 4/4, root filter
`.codex/pillow-rgba-png-open-root-filter-report.txt` passing 5/5,
changed-file validate `.codex/pillow-rgba-png-open-validate-report.txt`
passing, and captured example `.codex/pillow-rgba-png-open-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current blend/composition follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_blend_probe.py` and `.codex/pillow_blend_probe.output.json`
confirming `Image.blend(image1, image2, alpha)` for RGB, RGBA, and `L` images,
including alpha values outside `[0, 1]`, channel clipping, result mode/size,
and `ValueError("images do not match")` for size or mode mismatch. The AHK
surface now exposes `stdlib.pillow.Image.blend(...)` as a public
composition-oriented API. The current implementation uses a pixel-loop bridge
over the existing bitmap object so tests can lock observable Pillow behavior;
the target backend remains Direct2D for accelerated blend/composition internals.
Fresh AHK evidence includes focused red `.codex/pillow-blend-red-report.txt`
failing because the `Image` module had no `blend` method, focused green
`.codex/pillow-blend-green-focused-report.txt` passing 1/1, module
`.codex/pillow-blend-module-report.txt` passing `stdlib/tests/pillow.test.ahk`
5/5, root filter `.codex/pillow-blend-root-filter-report.txt` passing 6/6,
changed-file validate `.codex/pillow-blend-validate-report.txt` passing, and
captured example `.codex/pillow-blend-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.

The current composite/mask follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_composite_probe.py` and
`.codex/pillow_composite_probe.output.json` confirming
`Image.composite(image1, image2, mask)` with `L` masks and `RGBA` masks,
including result pixels, result mode/size driven by the second image, permissive
input image mode/size differences, `ValueError("images do not match")` for a
mask smaller than the output image, and `ValueError("bad transparency mask")`
for unsupported mask modes. The AHK surface now exposes
`stdlib.pillow.Image.composite(...)` as the second composition-oriented API.
The current implementation is still a pixel-loop bridge over the existing
bitmap object, with Direct2D retained as the intended accelerated backend for
mask/composition internals. Fresh AHK evidence includes focused red
`.codex/pillow-composite-red-report.txt` failing because the `Image` module had
no `composite` method, focused green
`.codex/pillow-composite-green-focused-report.txt` passing 1/1, module
`.codex/pillow-composite-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 6/6, root filter
`.codex/pillow-composite-root-filter-report.txt` passing 7/7, changed-file
validate `.codex/pillow-composite-validate-report.txt` passing, and captured
example `.codex/pillow-composite-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.

The current alpha-composite follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_alpha_composite_probe.py` and
`.codex/pillow_alpha_composite_probe.output.json` confirming
`Image.alpha_composite(image1, image2)` for same-size `RGBA` images, including
ordinary semi-transparent overlay pixels, fully transparent/opaque edge cases,
result `RGBA` mode/size, and `ValueError("images do not match")` for size or
mode mismatch. The AHK surface now exposes
`stdlib.pillow.Image.alpha_composite(...)` as another composition-oriented API.
The current implementation is a pixel-loop bridge with integer alpha math that
matches the probed Pillow pixels; Direct2D remains the intended backend for
accelerated alpha composition internals. Fresh AHK evidence includes focused
red `.codex/pillow-alpha-composite-red-report.txt` failing because the `Image`
module had no `alpha_composite` method, focused green
`.codex/pillow-alpha-composite-green-focused-report.txt` passing 1/1, module
`.codex/pillow-alpha-composite-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 7/7, root filter
`.codex/pillow-alpha-composite-root-filter-report.txt` passing 8/8,
changed-file validate `.codex/pillow-alpha-composite-validate-report.txt`
passing, and captured example `.codex/pillow-alpha-composite-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current paste follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_paste_probe.py` and `.codex/pillow_paste_probe.output.json`
confirming in-place `Image.paste(...)` for color fill boxes, image paste at a
point, `L` mask paste, `RGBA` mask paste, point-box clipping when the source is
wider than the target, `None` return behavior, `ValueError("bad transparency
mask")` for unsupported mask modes, and the covered malformed-box
`TypeError`. The AHK image object now exposes `.paste(...)` as an in-place
composition/fill method. The current implementation is a pixel-loop bridge over
the existing bitmap object, with Direct2D retained as the intended backend for
accelerated fill/mask/composition internals. Fresh AHK evidence includes
focused red `.codex/pillow-paste-red-report.txt` failing because
`AhkStdlibPillowImage` had no `paste` method, focused green
`.codex/pillow-paste-green-focused-report.txt` passing 1/1, module
`.codex/pillow-paste-module-report.txt` passing `stdlib/tests/pillow.test.ahk`
8/8, root filter `.codex/pillow-paste-root-filter-report.txt` passing 9/9,
changed-file validate `.codex/pillow-paste-validate-report.txt` passing, and
captured example `.codex/pillow-paste-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.

The current channel/alpha follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_channel_alpha_probe.py` and
`.codex/pillow_channel_alpha_probe.output.json` confirming
`Image.getchannel(...)` by channel name and integer band index, returned `L`
channel images, missing-channel and out-of-range errors, and in-place
`Image.putalpha(...)` with constant alpha, `L` alpha image, `RGB` to `RGBA`,
`RGBA` alpha replacement, and `L` to `LA` promotion. The AHK surface now
exposes `.getchannel(...)` and `.putalpha(...)`, and the current mode support
adds covered `LA` pixel read/write behavior as `[l, a]`. Fresh AHK evidence
includes focused red `.codex/pillow-channel-alpha-red-report.txt` failing
because `AhkStdlibPillowImage` had no `getchannel` method, focused green
`.codex/pillow-channel-alpha-green-focused-report.txt` passing 1/1, module
`.codex/pillow-channel-alpha-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 9/9, root filter
`.codex/pillow-channel-alpha-root-filter-report.txt` passing 10/10,
changed-file validate `.codex/pillow-channel-alpha-validate-report.txt`
passing, and captured example `.codex/pillow-channel-alpha-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current split/merge follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_split_merge_probe.py` and
`.codex/pillow_split_merge_probe.output.json` confirming `Image.split()` for
`RGB`, `RGBA`, and `LA` images, tuple return shape, `L` band images, and
`Image.merge(...)` for `RGB`, `RGBA`, and `LA`, plus `wrong number of bands`,
`mode mismatch`, `size mismatch`, and unknown-mode `KeyError` behavior. The
AHK surface now exposes `.split()` on image instances and
`stdlib.pillow.Image.merge(mode, bands)` on the Image module, reusing the root
`stdlib.tuple(...)` carrier for split bands. Fresh AHK evidence includes
focused red `.codex/pillow-split-merge-red-report.txt` failing because
`AhkStdlibPillowImage` had no `split` method, focused green
`.codex/pillow-split-merge-green-focused-report.txt` passing 1/1, module
`.codex/pillow-split-merge-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 10/10, root filter
`.codex/pillow-split-merge-root-filter-report.txt` passing 11/11,
changed-file validate `.codex/pillow-split-merge-validate-report.txt` passing,
and captured example `.codex/pillow-split-merge-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current point/eval follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_point_eval_probe.py` and
`.codex/pillow_point_eval_probe.output.json` confirming `Image.point(...)`
callable and LUT behavior for `L`, `RGB`, `RGBA`, and `LA` images,
`L`-to-`RGB` LUT mode conversion, `Image.eval(image, function)`, 256-call LUT
construction semantics for callable functions, channel clipping, and the
covered `None`, bad-LUT, bad-mode, and callable-mode mismatch error messages.
The AHK surface now exposes `.point(lut, mode?)` on image instances and
`stdlib.pillow.Image.eval(image, function)` on the Image module. The current
implementation is still a pixel-loop bridge over an explicit 256-entry LUT
builder so public behavior is locked first; this LUT/apply layer is the
integration point for later Direct2D-backed pixel-map acceleration without
changing callers. Fresh AHK evidence includes focused red
`.codex/pillow-point-eval-red-report.txt` failing because
`AhkStdlibPillowImage` had no `point` method, focused green
`.codex/pillow-point-eval-green-focused-report.txt` passing 1/1, module
`.codex/pillow-point-eval-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 11/11, root filter
`.codex/pillow-point-eval-root-filter-report.txt` passing 12/12,
changed-file validate `.codex/pillow-point-eval-validate-report.txt` passing,
and captured example `.codex/pillow-point-eval-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current filter follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_filter_probe.py` and `.codex/pillow_filter_probe.output.json`
confirming `Image.filter(...)` with ImageFilter classes and `Kernel`
instances, the built-in `BLUR`, `CONTOUR`, `DETAIL`, `EDGE_ENHANCE`,
`EDGE_ENHANCE_MORE`, `EMBOSS`, `FIND_EDGES`, `SHARPEN`, `SMOOTH`, and
`SMOOTH_MORE` kernel parameters, 3x3 and 5x5 boundary-preservation behavior,
per-channel `RGB` / `RGBA` filtering, custom `Kernel` scale/offset behavior,
vertical kernel flipping, and the covered bad-filter, bad-kernel-size, and
bad-coefficient error messages. The AHK surface now exposes
`stdlib.pillow.ImageFilter`, built-in callable filter-class objects,
`ImageFilter.Kernel(size, kernel, scale?, offset?)`, and `.filter(filter)` on
image instances. The current implementation is a CPU kernel bridge over the
existing pixel object; this is the first public filter surface intended to move
behind Direct2D effects once enough behavior is locked. Fresh AHK evidence
includes focused red `.codex/pillow-filter-red-report.txt` failing because
`stdlib.pillow` had no `ImageFilter` surface, focused green
`.codex/pillow-filter-green-focused-report.txt` passing 1/1, module
`.codex/pillow-filter-module-report.txt` passing `stdlib/tests/pillow.test.ahk`
12/12, root filter `.codex/pillow-filter-root-filter-report.txt` passing
13/13, changed-file validate `.codex/pillow-filter-validate-report.txt`
passing, and captured example `.codex/pillow-filter-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageFilter rank-family follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from `.codex/pillow_imagefilter_rank_probe.py` and
`.codex/pillow_imagefilter_rank_probe.output.json` confirming
`ImageFilter.RankFilter`, `MinFilter`, `MaxFilter`, `MedianFilter`, and
`ModeFilter` for covered `L`, `RGB`, and `RGBA` paths. The probe records filter
object `.size` / `.rank` attributes, rank-family edge expansion, per-band
RGB/RGBA center pixels, `ModeFilter` boundary-window and replacement-threshold
behavior, and covered constructor/filter errors including bad even size, bad
rank, non-numeric median size, and string rank-filter size. The AHK surface now
exposes these ImageFilter constructors and applies them through a CPU pixel-loop
bridge. Fresh AHK evidence includes focused red
`.codex/pillow-imagefilter-rank-red-report.txt` failing because
`ImageFilter.RankFilter` was missing, focused green
`.codex/pillow-imagefilter-rank-green-focused-report.txt` passing 1/1, and
module `.codex/pillow-imagefilter-rank-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 33/33, root filter
`.codex/pillow-imagefilter-rank-root-filter-report.txt` passing 34/34, and
captured example `.codex/pillow-imagefilter-rank-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`. This behavior-locks
another local-window filter family for later Direct2D or pixel-map acceleration;
the current slice does not claim accelerated backend execution.

The current ImageFilter BoxBlur follow-up uses fresh local Python 3.10.11 +
Pillow 11.3.0 evidence from `.codex/pillow_imagefilter_boxblur_probe.py` and
`.codex/pillow_imagefilter_boxblur_probe.output.json` confirming
`ImageFilter.BoxBlur(radius)` for covered integer scalar radius `1`, tuple
radius `[1, 0]`, radius `0` copy behavior, `L` matrix rows, and `RGB`/`RGBA`
center and edge pixels. The probe also records Pillow's negative-radius,
string-radius, and short-tuple errors. The AHK surface now exposes
`ImageFilter.BoxBlur` through a separable CPU pixel-loop implementation that
matches the covered integer-radius Pillow rows and remains a behavior lock for
later Direct2D blur/effect acceleration. Fresh AHK evidence includes focused
red `.codex/pillow-imagefilter-boxblur-red-report.txt` failing because
`ImageFilter.BoxBlur` was missing, focused green
`.codex/pillow-imagefilter-boxblur-green-focused-report.txt` passing 1/1, and
module `.codex/pillow-imagefilter-boxblur-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 34/34, root filter
`.codex/pillow-imagefilter-boxblur-root-filter-report.txt` passing 35/35, and
captured example `.codex/pillow-imagefilter-boxblur-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`. Non-integer float radius
parity remains a later Pillow C / Direct2D fidelity slice.

The current ImageFilter GaussianBlur follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from `.codex/pillow_imagefilter_gaussianblur_probe.py`
and `.codex/pillow_imagefilter_gaussianblur_probe.output.json` confirming
`ImageFilter.GaussianBlur(radius := 2)` default/scalar/tuple/zero/float radius
attributes, `L` matrix rows for default radius `2`, scalar radius `1`, tuple
radius `[1, 0]`, float radius `1.5`, zero-radius copy isolation, `RGB`/`RGBA`
key pixels, negative-radius no-error behavior, and Pillow's string/short-tuple
filter-time `TypeError` shape. The AHK surface now exposes
`ImageFilter.GaussianBlur` through a CPU implementation of Pillow 11.3.0's
three-pass float box blur approximation, including the C-level float/fixed-point
weighting needed for pixel parity. This slice locks another blur/effect target
for later Direct2D acceleration but does not claim that Direct2D acceleration is
implemented. Fresh AHK evidence includes focused red
`.codex/pillow-imagefilter-gaussianblur-red-report.txt` failing because
`ImageFilter.GaussianBlur` was missing, focused green
`.codex/pillow-imagefilter-gaussianblur-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagefilter-gaussianblur-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 35/35, root filter
`.codex/pillow-imagefilter-gaussianblur-root-filter-report.txt` passing 36/36,
and captured example `.codex/pillow-imagefilter-gaussianblur-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageFilter UnsharpMask follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from `.codex/pillow_imagefilter_unsharpmask_probe.py`
and `.codex/pillow_imagefilter_unsharpmask_probe.output.json` confirming
`ImageFilter.UnsharpMask(radius := 2, percent := 150, threshold := 3)` default
attributes, explicit radius/percent/threshold attributes, `L` matrix rows for
default parameters, radius `1` / percent `150` / threshold `0`, threshold `20`,
percent `0`, percent `250`, radius `0`, negative radius, and `RGB`/`RGBA` key
pixels. The probe also records that string radius/percent/threshold constructors
are accepted and fail only when `.filter(...)` calls the Pillow C backend. The
AHK surface now exposes `ImageFilter.UnsharpMask` through the existing CPU
Gaussian blur parity backend plus Pillow C's per-channel diff/threshold/clip
formula. This behavior-locks another effect target for later Direct2D
acceleration without claiming that acceleration is already implemented. Fresh
AHK evidence includes focused red
`.codex/pillow-imagefilter-unsharpmask-red-report.txt` failing because
`ImageFilter.UnsharpMask` was missing, focused green
`.codex/pillow-imagefilter-unsharpmask-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagefilter-unsharpmask-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 36/36, root filter
`.codex/pillow-imagefilter-unsharpmask-root-filter-report.txt` passing 37/37,
and captured example `.codex/pillow-imagefilter-unsharpmask-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageFilter Color3DLUT follow-up uses fresh local Python 3.10.11
+ Pillow 11.3.0 evidence from `.codex/pillow_imagefilter_color3dlut_probe.py`
and `.codex/pillow_imagefilter_color3dlut_probe.output.json` confirming
`ImageFilter.Color3DLUT` construction, `generate`, `transform`, `with_normals`,
normalized coordinates, tuple-table flattening, `__Repr`, RGB/RGBA filtering,
`target_mode` RGBA output, and common constructor/filter errors. The AHK surface now exposes
`ImageFilter.Color3DLUT` through a class-style facade and CPU pixel-loop
trilinear interpolation for the covered RGB/RGBA behavior. This locks another
Pillow color-transform target while the intended high-performance backend split
remains WIC for read/decode/pixel-format conversion, Direct2D for filters,
masks, blend, and composition, and WIC or GDI+ for save/output; this slice does
not claim Direct2D acceleration yet. Fresh AHK evidence includes focused red
`.codex/pillow-imagefilter-color3dlut-red-report.txt` failing because
`ImageFilter.Color3DLUT` was missing, focused green
`.codex/pillow-imagefilter-color3dlut-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagefilter-color3dlut-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 37/37, root filter
`.codex/pillow-imagefilter-color3dlut-root-filter-report.txt` passing 38/38,
and captured example `.codex/pillow-imagefilter-color3dlut-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageChops follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_imagechops_probe.py` and
`.codex/pillow_imagechops_probe.output.json` confirming `ImageChops.add`,
`subtract`, `add_modulo`, `subtract_modulo`, `multiply`, `screen`,
`difference`, `lighter`, `darker`, `invert`, `offset`, `constant`, and
`duplicate` for covered `L`, `RGB`, and `RGBA` images. The probe also records
scaled add/subtract behavior, wraparound modulo arithmetic, screen/multiply
integer truncation, offset wrapping with omitted or `None` `yoffset`, constant
channel clipping, duplicate copy isolation, permissive smaller-image output
cropping, and `ValueError("images do not match")` for mode mismatch. The AHK
surface now exposes `stdlib.pillow.ImageChops` as a composition/channel-ops
module. The current implementation is still a pixel-loop bridge; these
channel-op and wraparound primitives are intended to migrate behind Direct2D
blend/composition internals after additional behavior is locked. Fresh AHK
evidence includes focused red `.codex/pillow-imagechops-red-report.txt`
failing because `stdlib.pillow` had no `ImageChops` surface, focused green
`.codex/pillow-imagechops-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imagechops-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 13/13, root filter
`.codex/pillow-imagechops-root-filter-report.txt` passing 14/14,
changed-file validate `.codex/pillow-imagechops-validate-report.txt` passing,
and captured example `.codex/pillow-imagechops-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageChops blend/light/logical follow-up uses fresh local
Python 3.10.11 + Pillow 11.3.0 evidence from
`.codex/pillow_imagechops_blend_light_logical_probe.py` and
`.codex/pillow_imagechops_blend_light_logical_probe.output.json` confirming
`ImageChops.blend`, `composite`, `overlay`, `hard_light`, `soft_light`,
`logical_and`, `logical_or`, and `logical_xor` for covered `L`, `RGB`, `RGBA`,
and mode `1` images. The probe records Pillow's C-level integer formulas for
overlay/hard-light/soft-light via the Pillow 11.3.0 source package staged under
`.codex/pillow-src`, smaller-image cropping for light ops, mode `1`
`getpixel`/`putpixel` behavior, and covered error messages for non-`1`
logical inputs, mismatched overlay/blend inputs, and invalid mode `1` tuple
colors. The AHK surface now exposes these ImageChops functions, with mode `1`
stored on the existing bitmap bridge while preserving Pillow-visible pixel
values. Fresh AHK evidence includes focused red
`.codex/pillow-imagechops-blend-light-logical-red-report.txt` failing because
`ImageChops.blend` was missing, focused green
`.codex/pillow-imagechops-blend-light-logical-green-focused-report.txt`
passing 1/1, and module
`.codex/pillow-imagechops-blend-light-logical-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 32/32, root filter
`.codex/pillow-imagechops-blend-light-logical-root-filter-report.txt` passing
33/33, and captured example
`.codex/pillow-imagechops-blend-light-logical-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`. These covered channel
operations remain the behavior lock for later Direct2D-backed
blend/composition acceleration; the current slice does not claim Direct2D
acceleration itself.

The current ImageOps follow-up uses fresh Pillow 11.3.0 evidence from
`.codex/pillow_imageops_probe.py` and `.codex/pillow_imageops_probe.output.json`
confirming deterministic `ImageOps.invert`, `mirror`, `flip`, `grayscale`,
`solarize`, `posterize`, `expand`, and `crop` behavior for covered `L`, `RGB`,
and `RGBA` paths. The probe records Pillow's rounded grayscale luma for
`ImageOps.grayscale`, `RGBA` grayscale alpha dropping, `RGBA` invert
`OSError("not supported for mode RGBA")`, scalar and tuple border expansion,
scalar and tuple crop behavior including empty-height output, solarize threshold
behavior, posterize masking, and the covered bad-bits `TypeError`. The AHK
surface now exposes `stdlib.pillow.ImageOps` as a color/geometry operations
module. Current geometry and pixel operations are still CPU bridges over the
existing image object, while the target backend remains Direct2D for later
accelerated pixel maps and geometry. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-red-report.txt` failing because `stdlib.pillow` had no
`ImageOps` surface, focused green
`.codex/pillow-imageops-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imageops-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 14/14, root filter
`.codex/pillow-imageops-root-filter-report.txt` passing 15/15,
changed-file validate `.codex/pillow-imageops-validate-report.txt` passing,
and captured example `.codex/pillow-imageops-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The ImageOps contain follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_contain_probe.py` and
`.codex/pillow_imageops_contain_probe.output.json` confirming
`ImageOps.contain(image, size, method=Image.Resampling.BICUBIC)` for wide,
tall, same-size, and narrow-target `RGB`, `L`, and `RGBA` images. The probe
records Pillow's aspect-ratio size calculations, new-object return behavior
even when the target size equals the input, and the covered `AttributeError`,
`IndexError`, `ValueError`, `ZeroDivisionError`, and string-size `TypeError`
paths. The AHK surface now exposes `stdlib.pillow.ImageOps.contain(...)` and
keeps the same public image object while delegating resized output through the
current bitmap bridge. Same-size containment returns a copy to preserve
semi-transparent `RGBA` pixels until the resize backend is migrated to the
target accelerated path. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-contain-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `contain` method, focused green
`.codex/pillow-imageops-contain-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imageops-contain-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 24/24, and root filter
`.codex/pillow-imageops-contain-root-filter-report.txt` passing 25/25. This
keeps the Pillow backend target split explicit: WIC for read/decode/pixel
format conversion, Direct2D for filters, masks, blend, composition, fills,
pixel maps, and geometry, and WIC or GDI+ for save/output.

The ImageOps cover/scale follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_cover_scale_probe.py` and
`.codex/pillow_imageops_cover_scale_probe.output.json` confirming
`ImageOps.cover(image, size, method=Image.Resampling.BICUBIC)` and
`ImageOps.scale(image, factor, resample=Image.Resampling.BICUBIC)` for covered
`RGB`, `L`, and `RGBA` paths. The probe records `cover`'s covering aspect-ratio
size expansion, `scale` factor sizing, `scale(..., 1)` copy behavior, and the
covered `AttributeError`, `IndexError`, `ZeroDivisionError`, `TypeError`, and
`ValueError` paths. The AHK surface now exposes
`stdlib.pillow.ImageOps.cover(...)` and `stdlib.pillow.ImageOps.scale(...)`.
This slice intentionally locks functional geometry and error behavior first;
exact resampling-kernel pixel parity remains a later backend task for the
Direct2D/GDI+ resize path. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-cover-scale-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `cover` method, focused green
`.codex/pillow-imageops-cover-scale-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imageops-cover-scale-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 25/25, and root filter
`.codex/pillow-imageops-cover-scale-root-filter-report.txt` passing 26/26.

The ImageOps pad/fit follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_pad_fit_probe.py` and
`.codex/pillow_imageops_pad_fit_probe.output.json` confirming
`ImageOps.pad(image, size, method=Image.Resampling.BICUBIC, color=None,
centering=(0.5, 0.5))` and `ImageOps.fit(image, size,
method=Image.Resampling.BICUBIC, bleed=0.0, centering=(0.5, 0.5))` for
covered `RGB`, `L`, and `RGBA` paths. The probe records padded background
placement, same-size copy behavior, fit output sizing, and the covered
`AttributeError`, `IndexError`, `ZeroDivisionError`, and `TypeError` paths.
The AHK surface now exposes `stdlib.pillow.ImageOps.pad(...)` and
`stdlib.pillow.ImageOps.fit(...)`, reusing the existing `contain`, `new`,
`paste`, `crop`, and `resize` bridges. Exact resampling-kernel and fractional
crop-box parity remains a later backend task for the Direct2D/GDI+ resize path.
Fresh AHK evidence includes focused red `.codex/pillow-imageops-pad-fit-red-report.txt`
failing because `AhkStdlibPillowImageOpsModule` had no `pad` method, focused
green `.codex/pillow-imageops-pad-fit-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imageops-pad-fit-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 26/26, and root filter
`.codex/pillow-imageops-pad-fit-root-filter-report.txt` passing 27/27.

The ImageOps autocontrast follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_autocontrast_probe.py` and
`.codex/pillow_imageops_autocontrast_probe.output.json` confirming
`ImageOps.autocontrast(image, cutoff=0, ignore=None, mask=None,
preserve_tone=False)` for covered `L` and `RGB` paths. The probe records
per-channel LUT mapping, `ignore`, symmetric `cutoff`, `L` mask histogram
selection, same-value no-op copy behavior, and the covered `RGBA`
`OSError`, `AttributeError`, `TypeError`, and mask `ValueError` paths. The AHK
surface now exposes `stdlib.pillow.ImageOps.autocontrast(...)` through a CPU
histogram/LUT bridge; this is a public behavior lock before migrating pixel-map
internals to Direct2D. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-autocontrast-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `autocontrast` method, focused green
`.codex/pillow-imageops-autocontrast-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imageops-autocontrast-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 27/27, and root filter
`.codex/pillow-imageops-autocontrast-root-filter-report.txt` passing 28/28.

The ImageOps equalize follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_equalize_probe.py` and
`.codex/pillow_imageops_equalize_probe.output.json` confirming
`ImageOps.equalize(image, mask=None)` for covered `L` and `RGB` paths. The
probe records identity LUT behavior, a non-trivial `L` histogram mapping,
optional `L` mask histogram selection, same-value no-op copy behavior, and the
covered `RGBA` `OSError`, `AttributeError`, and mask `ValueError` paths. The
AHK surface now exposes `stdlib.pillow.ImageOps.equalize(...)` through a CPU
histogram/LUT bridge; this shares the pixel-map path intended for later
Direct2D acceleration. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-equalize-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `equalize` method, focused green
`.codex/pillow-imageops-equalize-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imageops-equalize-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 28/28, and root filter
`.codex/pillow-imageops-equalize-root-filter-report.txt` passing 29/29, plus
captured example `.codex/pillow-imageops-equalize-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The ImageOps colorize follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_colorize_probe.py` and
`.codex/pillow_imageops_colorize_probe.output.json` confirming
`ImageOps.colorize(image, black, white, mid=None, blackpoint=0,
whitepoint=255, midpoint=127)` for covered `L` input. The probe records RGB
output mode and size, two-color string and tuple mappings, three-color mapping,
custom point mapping, source-image non-mutation, and the covered non-`L`
`AssertionError`, range `AssertionError`, bad-color `ValueError`,
`None`-image `AttributeError`, and integer-color `TypeError` paths. The AHK
surface now exposes `stdlib.pillow.ImageOps.colorize(...)` through a CPU RGB
LUT bridge that uses Python floor-division semantics for negative channel
slopes; this is a behavior-locked integration point for later Direct2D
pixel-map acceleration. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-colorize-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `colorize` method, focused green
`.codex/pillow-imageops-colorize-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imageops-colorize-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 29/29, root filter
`.codex/pillow-imageops-colorize-root-filter-report.txt` passing 30/30, and
captured example `.codex/pillow-imageops-colorize-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The ImageOps deform follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageops_deform_probe.py` and
`.codex/pillow_imageops_deform_probe.output.json` confirming
`ImageOps.deform(image, deformer, resample=Image.Resampling.BILINEAR)` as a
`getmesh(image)` protocol wrapper over Pillow mesh transforms. The covered
slice records identity and horizontal-shift axis-aligned mesh behavior for
`RGB`, horizontal-shift `L` behavior, empty mesh black output, source-image
non-mutation, new-object return, and covered `None` image/deformer,
`None` mesh, and malformed mesh item error paths. The AHK surface now exposes
`stdlib.pillow.ImageOps.deform(...)` through an axis-aligned mesh bridge that
keeps the public protocol stable while non-axis-aligned perspective mesh and
high-fidelity resampling remain pending Direct2D geometry/transform backend
work. Fresh AHK evidence includes focused red
`.codex/pillow-imageops-deform-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `deform` method, focused green
`.codex/pillow-imageops-deform-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imageops-deform-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 30/30, root filter
`.codex/pillow-imageops-deform-root-filter-report.txt` passing 31/31, and
captured example `.codex/pillow-imageops-deform-example-report.txt` passing
1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The ImageOps exif_transpose follow-up uses fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_imageops_exif_transpose_probe.py`
and `.codex/pillow_imageops_exif_transpose_probe.output.json` confirming
`ImageOps.exif_transpose(image, *, in_place=False)` for covered in-memory EXIF
Orientation behavior. The probe records Orientation tag `274`, no-orientation
and Orientation `1` copy returns, Orientation `2` through `8` transpose rows,
`L` mode Orientation `6`, source-image non-mutation for copy mode, orientation
removal from returned/transposed images, in-place Orientation `6` mutation with
`None` return, in-place no-orientation no-op, and the covered `None` image and
positional `in_place` error text. The AHK surface now exposes
`Image.getexif()` as an in-memory mutable EXIF map plus
`stdlib.pillow.ImageOps.exif_transpose(...)`; the covered slice intentionally
does not yet claim WIC/GDI+ file-level EXIF serialization or XMP cleanup parity.
Fresh AHK evidence includes focused red
`.codex/pillow-imageops-exif-transpose-red-report.txt` failing because
`AhkStdlibPillowImageOpsModule` had no `exif_transpose` method, positional
keyword-only red `.codex/pillow-imageops-exif-transpose-positional-red-report.txt`
failing because `exif_transpose(image, true)` did not throw, focused green
`.codex/pillow-imageops-exif-transpose-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imageops-exif-transpose-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 31/31, root filter
`.codex/pillow-imageops-exif-transpose-root-filter-report.txt` passing 32/32,
and captured example `.codex/pillow-imageops-exif-transpose-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageEnhance follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imageenhance_probe.py` and
`.codex/pillow_imageenhance_probe.output.json` confirming
`ImageEnhance.Brightness`, `Color`, `Contrast`, and `Sharpness` for covered
`RGB`, `L`, and `RGBA` paths, including factors `0`, `0.5`, `1`, `1.5`, and
negative factors, alpha-preserving degenerate images, rounded luma for color
and contrast degenerates, `SMOOTH`-based sharpness behavior, and the covered
bad-image / bad-factor errors. The AHK surface now exposes
`stdlib.pillow.ImageEnhance` with enhancer objects that provide
`.enhance(factor)`. The current implementation locks the public Pillow
behavior through CPU bridges over `Image.blend(...)`, grayscale degenerates,
and `ImageFilter.SMOOTH`; the target backend remains Direct2D for accelerated
filters, masks, blend, composition, fill, pixel maps, and geometry once more
behavior has been fixed by tests. Fresh AHK evidence includes focused red
`.codex/pillow-imageenhance-red-report.txt` failing because `stdlib.pillow`
had no `ImageEnhance` surface, focused green
`.codex/pillow-imageenhance-green-focused-report.txt` passing 1/1, and module
`.codex/pillow-imageenhance-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 15/15. Final slice gates also passed: root
filter `.codex/pillow-imageenhance-root-filter-report.txt` passed 16/16,
changed-file validate `.codex/pillow-imageenhance-validate-report.txt` passed,
and captured example `.codex/pillow-imageenhance-example-report.txt` passed 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageColor follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imagecolor_probe.py` and
`.codex/pillow_imagecolor_probe.output.json` confirming
`ImageColor.getrgb(...)`, `ImageColor.getcolor(...)`, and string-color
`Image.new(...)` behavior. Covered color specs include short and long hex
forms with alpha, integer and percent `rgb(...)`, `rgba(...)`, `hsl(...)`,
`hsv(...)`, `hsb(...)`, Pillow's 148-entry named color map, mode conversion
to `RGB`, `RGBA`, `L`, `LA`, and `HSV`, plus the covered unknown, too-long,
`None`, and bad-mode error messages. The AHK surface now exposes
`stdlib.pillow.ImageColor` and routes string colors through the same parser
before bitmap allocation. This is a normalization layer for later WIC/GDI+ save
paths and Direct2D fill/blend/composition internals; it does not change the
public image object shape. Fresh AHK evidence includes focused red
`.codex/pillow-imagecolor-red-report.txt` failing because `stdlib.pillow` had
no `ImageColor` surface, focused green
`.codex/pillow-imagecolor-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imagecolor-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 16/16, root filter
`.codex/pillow-imagecolor-root-filter-report.txt` passing 17/17,
changed-file validate `.codex/pillow-imagecolor-validate-report.txt` passing,
and captured example `.codex/pillow-imagecolor-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`.

The current ImageDraw follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imagedraw_probe.py`,
`.codex/pillow_imagedraw_probe.output.json`,
`.codex/pillow_imagedraw_ellipse_probe.py`, and
`.codex/pillow_imagedraw_ellipse_probe.output.json`,
`.codex/pillow_imagedraw_arc_chord_pieslice_probe.py`, and
`.codex/pillow_imagedraw_arc_chord_pieslice_probe.output.json`,
`.codex/pillow_imagedraw_circle_rounded_probe.py`, and
`.codex/pillow_imagedraw_circle_rounded_probe.output.json`,
`.codex/pillow_imagedraw_regular_polygon_probe.py`, and
`.codex/pillow_imagedraw_regular_polygon_probe.output.json`,
`.codex/pillow_imagedraw_bitmap_probe.py`, and
`.codex/pillow_imagedraw_bitmap_probe.output.json`,
`.codex/pillow_imagedraw_floodfill_probe.py`, and
`.codex/pillow_imagedraw_floodfill_probe.output.json` confirming
`ImageDraw.Draw(image)`, `.point(...)`, `.line(...)`, `.bitmap(...)`,
`ImageDraw.floodfill(...)`,
`.rectangle(...)`, `.polygon(...)` including outline `width`, `.regular_polygon(...)`,
`.ellipse(...)`, `.arc(...)`, `.chord(...)`, `.pieslice(...)`, `.circle(...)`,
and `.rounded_rectangle(...)` for covered
`RGB`, `RGBA`, and `L` paths. The probes record `None` return values,
string-color fills through the ImageColor parser, inclusive rectangle
coordinates, one-pixel line geometry, alpha-preserving RGBA rectangle, ellipse,
pieslice, and rounded-rectangle colors, grayscale conversion, a simple filled
polygon, filled/outlined integer ellipses, arc/chord/pieslice axial-angle
geometry, circle center/radius mapping, rounded-rectangle radius geometry,
regular-polygon vertex mapping, polygon outline-width mask clipping,
bitmap-mask grayscale color/alpha scaling, offscreen clipping, default-fill
no-op behavior, flood-fill same-color regions, border-bounded regions,
threshold-tolerant `L` regions, RGBA regions, seed-outside no-op behavior, and
the covered bad-image / bad-coordinate / bad-width errors.
The AHK surface now
exposes
`stdlib.pillow.ImageDraw` as a geometry/fill drawing module. The current
implementation is a CPU pixel bridge using `putpixel`, Bresenham line drawing,
inclusive rectangle fill/outline, scanline polygon fill, and the Pillow 11.3.0
integer ellipse quarter/segment raster path plus axial-angle arc shape
filtering; this is the public behavior lock before migrating drawing internals
to Direct2D geometry and fill paths. The target Pillow backend split is WIC for
read/decode/pixel-format conversion, Direct2D for filters, masks, blend,
composition, fills, pixel maps, and geometry, then WIC or GDI+ for
save/output. Fresh AHK evidence includes focused red
`.codex/pillow-imagedraw-red-report.txt`
failing because `stdlib.pillow` had no `ImageDraw` surface, focused green
`.codex/pillow-imagedraw-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imagedraw-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 17/17, root filter
`.codex/pillow-imagedraw-root-filter-report.txt` passing 18/18,
changed-file validate `.codex/pillow-imagedraw-validate-report.txt` passing,
and captured example `.codex/pillow-imagedraw-example-report.txt` passing 1/1
through `AhkTest.CaptureFixture().RunArgs(...)`. The ellipse follow-up evidence
adds focused red `.codex/pillow-imagedraw-ellipse-red-report.txt` failing
because `AhkStdlibPillowImageDraw` had no `ellipse` method, focused green
`.codex/pillow-imagedraw-ellipse-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imagedraw-ellipse-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 18/18, root filter
`.codex/pillow-imagedraw-ellipse-root-filter-report.txt` passing 19/19,
changed-file validate `.codex/pillow-imagedraw-ellipse-validate-report.txt`
passing, and captured example
`.codex/pillow-imagedraw-ellipse-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`. The arc/chord/pieslice follow-up
evidence adds focused red
`.codex/pillow-imagedraw-arc-chord-pieslice-red-report.txt` failing because
`AhkStdlibPillowImageDraw` had no `arc` method, focused green
`.codex/pillow-imagedraw-arc-chord-pieslice-green-focused-report.txt` passing
1/1, module `.codex/pillow-imagedraw-arc-chord-pieslice-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 19/19, root filter
`.codex/pillow-imagedraw-arc-chord-pieslice-root-filter-report.txt` passing
20/20, changed-file validate
`.codex/pillow-imagedraw-arc-chord-pieslice-validate-report.txt` passing, and
captured example `.codex/pillow-imagedraw-arc-chord-pieslice-example-report.txt`
passing 1/1 through `AhkTest.CaptureFixture().RunArgs(...)`.
The circle/rounded-rectangle follow-up evidence adds focused red
`.codex/pillow-imagedraw-circle-rounded-red-report.txt` failing because
`AhkStdlibPillowImageDraw` had no `circle` method, focused green
`.codex/pillow-imagedraw-circle-rounded-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagedraw-circle-rounded-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 20/20, root filter
`.codex/pillow-imagedraw-circle-rounded-root-filter-report.txt` passing 21/21,
changed-file validate `.codex/pillow-imagedraw-circle-rounded-validate-report.txt`
passing, and captured example
`.codex/pillow-imagedraw-circle-rounded-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.
The regular-polygon/polygon-width follow-up evidence adds focused red
`.codex/pillow-imagedraw-regular-polygon-red-report.txt` failing because
`AhkStdlibPillowImageDraw` had no `regular_polygon` method, focused green
`.codex/pillow-imagedraw-regular-polygon-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagedraw-regular-polygon-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 21/21, root filter
`.codex/pillow-imagedraw-regular-polygon-root-filter-report.txt` passing 22/22,
changed-file validate `.codex/pillow-imagedraw-regular-polygon-validate-report.txt`
passing, and captured example
`.codex/pillow-imagedraw-regular-polygon-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.
The bitmap follow-up evidence adds focused red
`.codex/pillow-imagedraw-bitmap-red-report.txt` failing because
`AhkStdlibPillowImageDraw` had no `bitmap` method, focused green
`.codex/pillow-imagedraw-bitmap-green-focused-report.txt` passing 1/1, module
`.codex/pillow-imagedraw-bitmap-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 22/22, root filter
`.codex/pillow-imagedraw-bitmap-root-filter-report.txt` passing 23/23,
combined changed-file validate
`.codex/pillow-imagedraw-bitmap-validate-report.txt` passing the pillow module,
root pillow smoke, and captured example, and captured example
`.codex/pillow-imagedraw-bitmap-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.
The floodfill follow-up evidence adds focused red
`.codex/pillow-imagedraw-floodfill-red-report.txt` failing because
`AhkStdlibPillowImageDrawModule` had no `floodfill` method, focused green
`.codex/pillow-imagedraw-floodfill-green-focused-report.txt` passing 1/1,
module `.codex/pillow-imagedraw-floodfill-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 23/23, root filter
`.codex/pillow-imagedraw-floodfill-root-filter-report.txt` passing 24/24,
combined changed-file validate
`.codex/pillow-imagedraw-floodfill-validate-report.txt` passing the pillow
module, root pillow smoke, and captured example, and captured example
`.codex/pillow-imagedraw-floodfill-example-report.txt` passing 1/1 through
`AhkTest.CaptureFixture().RunArgs(...)`.

The ordinary ImageDraw text follow-up extends `ImageDraw.Draw(image)` with
`getfont()`, `text(...)`, `textbbox(...)`, `textlength(...)`,
`multiline_text(...)`, and `multiline_textbbox(...)` for the covered local
Pillow default-font path. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagedraw_text_probe.py` and
`.codex/pillow_imagedraw_text_probe.output.json` records `getfont()` returning
a default `FreeTypeFont`, default and explicit-font `textbbox` / `textlength`
metrics for `"Hi"`, visible-pixel `text(...)` output, default-spacing
`multiline_textbbox(...)`, `multiline_text(...)` returning `None`, and the
covered missing-argument errors. The AHK surface reuses
`ImageFont.load_default()` and the existing prefixed ImageDraw2 text drawing
helper, and it also refreshes the default-font `i` glyph width to match the
fresh Pillow metrics. Anchor, direction, features, language, stroke, embedded
color, advanced shaping, and arbitrary font backend behavior remain unclaimed
until focused probes cover them. Fresh AHK evidence includes focused red
`.codex/pillow-imagedraw-text-red-report.txt` plus
`.codex/pillow-imagedraw-text-red.json` failing because ordinary
`ImageDraw.Draw(...)` lacked `getfont`, focused green
`.codex/pillow-imagedraw-text-green-focused-report.txt` plus
`.codex/pillow-imagedraw-text-green-focused.json` passing 1/1, related
ImageDraw regression `.codex/pillow-imagedraw-text-imagedraw-regression-report.txt`
plus `.codex/pillow-imagedraw-text-imagedraw-regression.json` passing 12/12,
captured example gate `.codex/pillow-imagedraw-text-example-report.txt` plus
`.codex/pillow-imagedraw-text-example.json` passing 2/2 without warning/error
output, and serial module gate `.codex/pillow-imagedraw-text-module-report.txt`
plus `.codex/pillow-imagedraw-text-module.json` passing
`stdlib/tests/pillow.test.ahk` 172/172 at `TimeoutSeconds 90`.

The instance alpha-composite follow-up extends `Image.Image` with in-place
`alpha_composite(image, dest=(0, 0), source=(0, 0))` behavior for the covered
local Pillow 11.3.0 RGBA path. Fresh Python evidence from
`.codex/pillow_image_instance_alpha_composite_probe.py`,
`.codex/pillow_image_instance_alpha_composite_probe.output.json`,
`.codex/pillow_image_instance_alpha_composite_extra_probe.py`, and
`.codex/pillow_image_instance_alpha_composite_extra_probe.output.json`
records `None` return behavior, target mutation, clipped source/destination
regions, allowed negative destination clipping, target mode validation,
overlay mode mismatch errors, and covered malformed destination/source
sequence errors. The AHK implementation reuses the existing alpha-composite
pixel helper while preserving instance mutation semantics. Fresh AHK evidence
includes focused red `.codex/pillow-image-instance-alpha-composite-red-report.txt`
plus `.codex/pillow-image-instance-alpha-composite-red.json` failing because
`AhkStdlibPillowImage` had no `alpha_composite`, focused green
`.codex/pillow-image-instance-alpha-composite-green-focused-report.txt` plus
`.codex/pillow-image-instance-alpha-composite-green-focused.json` passing 1/1,
related alpha-composite regression
`.codex/pillow-image-instance-alpha-composite-related-report.txt` plus
`.codex/pillow-image-instance-alpha-composite-related.json` passing 2/2,
captured example gate
`.codex/pillow-image-instance-alpha-composite-example-report.txt` plus
`.codex/pillow-image-instance-alpha-composite-example.json` passing 2/2, and
serial Pillow module gate
`.codex/pillow-image-instance-alpha-composite-module-report.txt` plus
`.codex/pillow-image-instance-alpha-composite-module.json` passing
`stdlib/tests/pillow.test.ahk` 173/173 at `TimeoutSeconds 90`. Broader
arbitrary sequence coercion, non-RGBA conversion paths, and Direct2D-backed
performance acceleration remain unclaimed until focused probes cover them.

The instance show/Qt bridge follow-up completes the currently probed public
`Image.Image` instance member surface by adding `show(title=None)`,
`toqimage()`, and `toqpixmap()`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_image_instance_show_qt_probe.py` and
`.codex/pillow_image_instance_show_qt_probe.output.json` records
`Image.show(...)` delegating to `ImageShow.show` while returning `None`, empty
viewer behavior, extra-position-argument errors, and installed-Qt delegation
from instance `toqimage()` / `toqpixmap()` into `ImageQt.toqimage` /
`ImageQt.toqpixmap`. The AHK implementation deliberately reuses the already
promoted `ImageShow` and `ImageQt` module surfaces instead of duplicating
viewer or Qt-image conversion logic on the image object. Fresh AHK evidence
includes focused red `.codex/pillow-image-instance-show-qt-red-report.txt`
plus `.codex/pillow-image-instance-show-qt-red.json` failing because
`AhkStdlibPillowImage` had no `show`, focused green
`.codex/pillow-image-instance-show-qt-green-focused-report.txt` plus
`.codex/pillow-image-instance-show-qt-green-focused.json` passing 1/1,
related regression `.codex/pillow-image-instance-show-qt-related-report.txt`
plus `.codex/pillow-image-instance-show-qt-related.json` passing 4/4,
captured example gate `.codex/pillow-image-instance-show-qt-example-report.txt`
plus `.codex/pillow-image-instance-show-qt-example.json` passing 2/2, and
serial Pillow module gate `.codex/pillow-image-instance-show-qt-module-report.txt`
plus `.codex/pillow-image-instance-show-qt-module.json` passing
`stdlib/tests/pillow.test.ahk` 174/174 at `TimeoutSeconds 90`. Qt-not-installed
`ImportError` behavior and real native Qt binding integration remain unclaimed
until focused AHK support exists for that environment state.

## Target Packages

The machine-checkable framework map is `stdlib\STDLIB_FRAMEWORK.json`.
It currently defines planning groups only. These group names help prioritize
research, but they do not create public include directories. Direct Python
stdlib modules must declare `PythonPath`, and direct project support modules
must declare `Surface: "ahk-support"` plus `PublicPath`.
Runtime asset directories may be allowed only when they do not define public
includes; the current explicit exception is `stdlib\tkinter\lib` for the
bundled Tcl/Tk DLLs used by `stdlib.tkinter`.

| Planning group | Python analogue | Status |
| --- | --- | --- |
| `core` | builtins, types, operator, warnings, unittest-like support | `abc`, `types`, `operator`, and `warnings` direct as minimal Python subsets; `ahktest`, `assert`, and `base` direct support modules |
| `collections` | collections, bisect, heapq, itertools, functools | `bisect`, `heapq`, `itertools`, and `functools` direct as root Python modules; `collections.Counter` direct as `stdlib.collections.Counter`; other modules candidate |
| `math` | math, random, statistics | `math`, `random`, `statistics`, `fractions`, and `decimal` direct as first slices |
| `text` | json, csv, configparser, parser helpers | `json`, `csv`, `configparser`, and `re` direct as root Python modules; `comparser` and `toml` remain support modules |
| `datetime` | calendar, datetime, time | `calendar`, `datetime`, and `time` direct as first slices |
| `os` | os, pathlib, shutil, platform, Windows helpers | `os` direct as `stdlib.os`; `pathlib.Path` direct as `stdlib.pathlib.Path`; `shutil` direct as a first slice |
| `io` | io, tempfile | `io` direct first slice with `StringIO`; `tempfile` direct first slice |
| `runtime` | hashlib, logging, pprint, inspect/import-style helpers | `hashlib` direct as a first slice; `logging` direct as a first slice; `pprint` direct as a first slice; `inspect` direct as a predicate first slice; `socket` direct as a first networking/runtime slice; other runtime helpers still candidate |
| `concurrency` | asyncio, concurrent.futures, queue, threading-style helpers | `asyncio`, `queue`, and process-backed `thread` direct as first slices; other concurrency modules still candidate |
| `native` | ctypes and external bindings | native quarantine |

## Promotion Rules

A module is `direct` only when:

1. Its implementation lives at the Python-path-aligned `stdlib\...` location.
2. Its public include is `<stdlib\...>` and is mechanically derived from
   `PythonPath` or support `PublicPath`.
3. Its direct files have `#Requires AutoHotkey v2.0`.
4. It does not include old library paths such as `<json\Json>` or
   `<bisect\bisect>`.
5. It has behavior coverage in `stdlib\tests\stdlib.test.ahk` or a focused
   test file under `stdlib\tests`.
6. The framework manifest records `Include` and `Path`.
7. It has at least one usage example under `stdlib\examples`.
8. Its AHK source and stdlib examples do not introduce `pytest` or lowercase
   `py*` identifiers. Pytest is the behavior target for `ahktest`, but public
   AHK names must stay AHK-prefixed or use the existing `AhkTest` surface.
   This rule applies to identifiers, not documentation strings, official URLs,
   or source paths embedded in tests.
9. Its public API is designed toward namespace-style stdlib access, not only
   old global wrapper functions.

Candidate modules must keep `SourceCandidates` so the old library remains
searchable as implementation material. Direct modules use `MigratedFrom` only
as historical provenance; it is not a dependency or an active public include
surface. Old AHK entrypoints should be kept while they are still needed as
reference material, then removed after the corresponding stdlib module has
namespace-style behavior coverage under `ahktest`.

The stdlib wrapper is now stdlib-only: `tools\run-ahktest.ps1` defaults to
`.\stdlib\tests`, always includes `stdlib\ahktest.ahk`, and rejects tests that
still include `<ahktest\ahktest>`. Legacy old-path tests are reference material
until migrated; they are not part of the active runner surface.

## Global Symbol Safety

AutoHotkey includes share one global namespace, and identifiers are
case-insensitive. Before broadening stdlib entrypoints, check for class/function
name collisions. Prefer names that avoid built-in collisions, and avoid adding
two direct modules that define the same global symbol.

The public API contract is `stdlib.module.func(...)` or
`stdlib.module.Class(...)`; examples and active tests must not teach bare module
entrypoints even when AHK requires some implementation symbols in the shared
global namespace. The 2026-06-01 audit closed the active public-surface leaks
for `assert(...)`, bare `AssertionError`, and bare `Toml()` by promoting the
documented calls to `stdlib.assert.assert(...)`,
`stdlib.assert.AssertionError`, and `stdlib.toml.Toml(...)`. The same audit
found `comparser` legacy helpers (`com_parse`, `com_dumps`, `comParser`),
`tkinter`'s implementation `Tk` class, and `platform`'s `uname_result` class as
global implementation symbols, but not as active example/test public calls.

Because includes are full loads, `<stdlib\init>` deliberately reserves only the
root namespace object. A future aggregate file, if needed, must be opt-in and
separate from init so that users can control which modules add global symbols.
Each direct module should include `<stdlib\init>` and mount itself onto
`stdlib.<python_module_path>` using AHK-prefixed internal bridge names where a
bridge class is needed. This is an explicit module responsibility, not a
package-initialization side effect.

The inventory tools generate symbol evidence:

- `.codex/inventory/symbols.json`
- `.codex/inventory/symbol-conflicts.json`
- `.codex/inventory/summary.md`

## Test Gates

Use wrappers only. Do not run `..\AutoHotkey64.exe script.ahk` directly.

Baseline framework commands:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\test-stdlib-framework.ps1
powershell -ExecutionPolicy Bypass -File .\tools\test-stdlib-layout.ps1
powershell -ExecutionPolicy Bypass -File .\tools\run-ahktest.ps1 -Target .\stdlib\tests -TimeoutSeconds 90
powershell -ExecutionPolicy Bypass -File .\tools\run-ahk-validate.ps1 -Path .\stdlib -TimeoutSeconds 20
powershell -ExecutionPolicy Bypass -File .\tools\build-ahk-inventory.ps1
powershell -ExecutionPolicy Bypass -File .\tools\test-ahk-inventory.ps1
powershell -ExecutionPolicy Bypass -File .\tools\stop-ahk-processes.ps1 -ListOnly
```

After every AHK test or validate run, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\stop-ahk-processes.ps1 -ListOnly
```

## TDD Migration Loop

For each candidate module:

1. Pick the Python `Lib` module path and record it as `PythonPath`; use
   `Surface: "ahk-support"` only for project-owned support modules.
2. Add the direct path to the manifest and let `tools\test-stdlib-layout.ps1`
   or a behavior test fail first.
3. Add an include and focused behavior test through `<stdlib\...>`.
4. Migrate implementation directly into the Python-path-aligned `stdlib\...`.
5. Replace internal includes with `<stdlib\...>` or local split files under
   the new subtree.
6. Run framework, layout, behavior, validate, inventory, and process checks.
7. Update this document with the module status and any syntax notes learned
   from `.codex\chm\docs`.

Foundation migration has started beyond `ahktest`: `stdlib\bisect`,
`stdlib\collections`, `stdlib\pathlib`, and `stdlib\statistics` are direct.
Their public behavior is checked against Python 3.10.11 rather than capped at
the older AHK source surface.

Recommended next candidates:

- `stdlib\ahktest` broader discovery collection failures, discovery duplicate
  policy beyond the covered duplicate-name rerun/cache parity, richer
  request-equivalent behavior beyond the
  covered fixture-name and JSON-manifest default-config surfaces, and broader
  multi-node rerun/filter interactions beyond the covered node-id and
  filter-expression explicit override slices
- residual `stdlib\itertools` wrapper parity once fresh Python probes expose
  new still-red branches beyond the current hot path
- deeper `stdlib\logging`, `stdlib\queue`, and filesystem/runtime slices after
  the current first promotions

These can proceed in parallel with continued ahktest hardening. `tempfile` is
already direct, so the next leverage is deeper parity inside covered direct
modules rather than another promotion from `candidate`.

## AHK V2 Notes

Use local CHM docs under `.codex\chm\docs` as the syntax reference. Relevant
starting points:

- `lib\_Include.htm` for include resolution and shared-source semantics.
- `lib\_Requires.htm` for version directives.
- `Scripts.htm` and `lib\_ErrorStdOut.htm` for `/Validate` and stderr behavior.
- `Functions.htm` and `Objects.htm` for callable objects, classes, and methods.

During migration, direct calls to undefined functions can fail during load or
validation. Use dynamic calls in tests only when a runtime behavior failure is
needed for a not-yet-created API.

AHK identifiers are case-insensitive, including locals versus built-in classes.
Avoid local names such as `buffer` when calling the built-in `Buffer` class.

`stdlib.os.system(command)` follows Python's raw shell-string shape, not a
safe argv API. AutoHotkey `RunWait` does not interpret shell syntax such as
redirection or pipes by itself, so the stdlib wrapper uses `A_ComSpec /c` and
returns the process exit code. It accepts only string commands and rejects
embedded null characters before shell execution, matching Python 3.10's
argument boundary. Output capture belongs in explicit process or ahktest
capture helpers, not in `os.system`.

`stdlib.operator` is a first slice of Python 3.10.11 `operator`. It exposes
comparison, truth, identity, arithmetic, sequence, item, getter, caller, and
length-hint helpers under `stdlib.operator`. `add` and `mul` now cover the
Python sequence cases for strings and AHK arrays used as Python-list
equivalents, including list concatenation and integer repetition. String
`countOf` and `indexOf` intentionally compare one-character sequence elements,
matching Python 3.10.11 `operator.countOf("aaa", "aa") == 0` and
`operator.indexOf("abc", "bc")` raising `ValueError`; substring membership is
covered by `operator.contains`. `length_hint` now follows Python's
`operator.length_hint` contract for covered custom stdlib iterators by honoring
an internal `__LengthHint()` hook; covered finite `itertools.repeat(...)`
objects report the current remaining count after partial consumption while
infinite repeats behave as unsized objects, so
`operator.length_hint(repeat(...), default)` returns the caller-provided
default, matching local Python 3.10.11 probing. Covered
`default` arguments are validated before sized-object lookup like Python,
accept negative integers and root `stdlib.True` / `stdlib.False` as bool-as-int
defaults for unsized objects, and surface Python-style integer-interpretation
`TypeError` messages for invalid defaults such as `stdlib.None`, strings, and
root `stdlib.tuple()` values. Covered custom `__LengthHint()` providers now
also follow Python's return protocol by accepting root bool results as
bool-as-int values, returning the default when the provider raises `TypeError`,
returning the default when the provider returns `stdlib.NotImplemented`,
propagating provider `ValueError`, rejecting negative hints with
`ValueError("__length_hint__() should return >= 0")`, and surfacing Python-style
`__length_hint__ must be an integer, not ...` diagnostics for non-integer hint
results. For AHK
`Map`, `contains`, `countOf`, and
`indexOf` follow Python dict iteration semantics by operating on keys.

`stdlib.pathlib.Path(parts*)` is a Windows-oriented first slice of Python
3.10.11 `pathlib.Path`. It supports string conversion through `String(path)`,
lowercase Python-style properties/methods such as `.name`, `.stem`,
`.suffix`, `.parent`, `.joinpath(...)`, `.exists()`, `.is_dir()`,
`.is_file()`, `.read_text()`, `.write_text()`, `.mkdir()`, `.unlink()`, and
`.rmdir()`. AHK cannot expose Python's `/` operator join ergonomics, so
`.joinpath(...)` and `.Join(...)` are the public AHK equivalent for now.
`write_text()` returns the written character count to match Python behavior.

`stdlib.bisect` exposes Python 3.10.11-style `bisect_left(...)`,
`bisect_right(...)`, `bisect(...)`, `insort_left(...)`, `insort_right(...)`,
and `insort(...)` over AHK arrays as Python-list equivalents and over covered
Python-style sequence targets with `__Len` / `__Item`. Public insertion points
remain Python-style zero-based even though AHK arrays are 1-based, and
`insort_left/right` convert that public insertion point to AHK `InsertAt` /
`Push` for native arrays or call the target's `insert(index, value)` protocol.
The latest alphabetical pass slice adds sequence and insert-target coverage:
`stdlib.array.array`, a custom `__Len` / `__Item` sequence, custom
`insert(index, value)` targets, and the missing-`insert` `AttributeError` path.
Fresh Python 3.10.11 evidence from `.codex/bisect_sequence_protocol_probe.py`
and `.codex/bisect_sequence_protocol_probe.output.json` confirmed
`array.array` return values, custom sequence `__len` / `__getitem__` event
order, `insort_left/right` calling `insert(...)` at zero-based indexes, and
`ProbeSequence` without `insert` raising an attribute error. Fresh AHK evidence
includes focused red `.codex/bisect-sequence-protocol-red-report.txt` failing
because `a must be an Array`, focused green
`.codex/bisect-sequence-protocol-green-focused-report.txt` passing 1/1, and
full module `.codex/bisect-sequence-protocol-final-green-report.txt` passing
`stdlib/tests/bisect.test.ahk` 6/6 at `TimeoutSeconds 90`; root smoke
`.codex/bisect-sequence-protocol-stdlib-focused-report.txt` passing 1/1; and
`.codex/bisect-sequence-protocol-validate-report.txt` validating
`stdlib/bisect.ahk`, `stdlib/tests/bisect.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/bisect.ahk` at
`TimeoutSeconds 90`. The earlier
alphabetical pass slice tightened Python signature and bounds behavior for
covered paths: missing
`a`/`x`, too many positional arguments, `lo=None`, explicit `hi=None`,
oversized `hi`, non-callable `key`, and `insort_right(...)` returning
`stdlib.None` while mutating the list. Fresh Python 3.10.11 evidence from
`.codex/bisect_signature_bounds_probe.py` confirmed the covered return values
and errors, including `bisect_left([1, 2, 3], 2, 0, None) == 1`,
`bisect_right([1, 2, 3], 2, 0, None) == 2`,
`bisect_left(..., hi=99)` raising `IndexError("list index out of range")`,
and `bisect_left(..., key=1)` raising `TypeError("'int' object is not callable")`.
Fresh AHK evidence includes focused red `SignatureBoundsAndKey` failing because
AHK's native parameter error escaped instead of the probed Python `TypeError`,
focused green passing 1/1 in 0 ms, full `stdlib/tests/bisect.test.ahk`
passing 5/5 in 0 ms, and `run-ahk-validate -Path
stdlib/examples/bisect.ahk -TimeoutSeconds 90` passing. The existing
compatibility treatment for `hi=-1` as an omitted-`hi` sentinel remains covered
locally for the current AHK call surface.

`stdlib.heapq` is a first slice of Python 3.10.11 `heapq` over AHK arrays as
Python-list equivalents. It exposes `heappush`, `heappop`, `heapify`,
`heapreplace`, and `heappushpop` as min-heap operations. The old local
`binaryHeap` class is reference material only and is not included by the
direct module because it is a class-oriented max-heap by default rather than
Python's list-in-place `heapq` API.

`stdlib.collections.Counter` is a first slice of Python 3.10.11
`collections.Counter`. The direct surface now exposes
`stdlib.collections.Counter` as a class object while preserving the existing
constructor call shape `stdlib.collections.Counter(...)`. Covered Python 3.10.11
classmethod behavior now includes `Counter.fromkeys(...)`, which intentionally
raises `NotImplementedError("Counter.fromkeys() is undefined.  Use Counter(iterable) instead.")`
for the covered one- and two-argument paths, while preserving Python's
dedicated missing-iterable and too-many-positional-arguments `TypeError`
messages. The direct slice otherwise supports counting strings and AHK arrays, mapping
counts including negative counts, missing keys returning zero, `total()`,
`update(...)`, `subtract(...)`, `setdefault(...)`, `pop(...)`, `popitem(...)`, `elements()`, `most_common(...)`, `copy()`,
`Delete(...)`, `Clear()`, and a Python-style `Counter({...})` `__Repr()` for
covered numeric/string-key counters using Python's most-common ordering, with
an insertion-order fallback for covered unorderable count payloads like nested
mapping counts. The public AHK surface also accepts an explicit
`{ kwargs: Map(...) }` envelope as an analogue for Python constructor,
`update(...)`, and `subtract(...)` keyword counts, including source-plus-kwargs
merge order, while ordinary object literals such as `{ a: 2 }` remain
non-iterable sources and keep Python-style source validation errors. Covered
`update(...)` and `subtract(...)` now also match Python 3.10.11's dedicated
non-iterable and too-many-positional-arguments `TypeError` wording for
`Counter().update(42)`, `Counter().subtract(42)`, and two-source call shapes
such as `Counter().update({}, {})`. `setdefault(...)` now also matches local
Python 3.10.11 for existing-key passthrough, missing-key insertion order,
omitted-default `None` insertion, and the builtin `setdefault expected at least
1 argument, got 0` / `setdefault expected at most 2 arguments, got 3`
arity wording. `get(...)` now also matches local Python 3.10.11 by returning
the stored count for existing keys, `None` for missing keys without an explicit
default even though `counter["missing"]` still yields zero, caller-provided
defaults for missing keys, and the builtin `get expected at least 1 argument,
got 0` / `get expected at most 2 arguments, got 3` arity wording. `pop(...)`
now also matches local Python 3.10.11 for
existing-key removal, missing-key default passthrough, `KeyError("'key'")`
for missing keys without a default, and the builtin `pop expected at least 1
argument, got 0` / `pop expected at most 2 arguments, got 3` arity wording.
`popitem(...)` now also matches local Python 3.10.11 for LIFO removal order,
readonly tuple-like `(key, value)` return rows, empty-Counter
`KeyError("'popitem(): dictionary is empty'")`, and the builtin
`dict.popitem() takes no arguments (1 given)` arity wording. `copy()` now also
matches local Python 3.10.11 for covered subclass preservation: copying a
`Counter` subclass returns a distinct object of the same subclass with equal
counts and independent future mutation. `clear()` now also matches local
Python 3.10.11 by returning `None`, emptying the covered mapping view without
changing missing-item lookup semantics (`counter["missing"] == 0`,
`counter.get("missing") is None`), and restarting public Counter iteration from
fresh insertion order after subsequent updates such as `clear(); update("ba")`.
`Delete(key)` now also matches covered Python mapping deletion behavior for
Counter-backed public paths such as `stdlib.operator.delitem(counter, key)` by
removing existing keys and raising `KeyError("'key'")` for missing keys instead
of silently succeeding.
`elements()` now returns a lazy single-use AHK
enumerable that keeps its consumed position across repeated consumers, like
Python's iterator object. It observes existing-count updates made after
construction until a key's repeat has started; once that key is active, the
repeat count is fixed while later keys still read their current counts when
reached. This matches the
observed Python 3.10.11 `elements()` chain-of-repeat behavior, and the
elements object exposes the Python-style `<itertools.chain object at 0x...>`
`__Repr()` shape observed for `Counter(...).elements()`. Mapping-provided
counts preserve their source type on first insertion so
`elements()` accepts root `stdlib.True` / `stdlib.False` counts as Python
bool-as-int `1` / `0`, rejects float or string counts like Python when consumed, and now
raises `Error("dictionary changed size during iteration")` if the Counter grows
or shrinks after iteration begins, plus
`Error("dictionary keys changed during iteration")` if keys are replaced while
the size stays constant or if a key is deleted and re-added before the next
pull, even when size and apparent key order return to their original shape.
Source
classification accepts strings, arrays, `Map`/`Counter` mappings, and custom
AHK enumerables, while ordinary objects and non-iterable scalar values raise
`TypeError` like Python. The current arithmetic/comparison slice routes Python
operator behavior through `stdlib.operator`: `add`, `sub`, `and_`, `or_`,
`pos`, `neg`, and Counter-to-Counter rich comparisons now preserve Python's
positive-count result filtering and missing-key-as-zero comparison semantics,
while `eq`/`ne` against non-Counter non-mapping objects now return Python's
`False`/`True` booleans instead of raising, and mixed count types preserve
Python's split between boolean `eq`/`ne` and `TypeError` for ordering
comparisons. `eq`/`ne` for Counter-to-Counter and Counter-to-mapping
comparisons now also use Python-style value equality for nested `list`/`dict`
count payloads instead of falling back to AHK object identity. Root
`stdlib.True` / `stdlib.False` count payloads now also compare like Python
`bool` integers across both Counter-to-Counter and Counter-to-mapping equality
and rich comparison paths, so covered cases such as
`Counter(a=True) == Counter(a=1)`, `Counter(a=True) == {'a': 1}`,
`Counter(a=True) <= Counter(a=1)`, and `Counter(a=False) < Counter(a=1)`
follow Python 3.10.11 instead of leaking raw AHK boolean-vs-int comparison
behavior. The covered arithmetic and mapping-update slice now also treats root
`stdlib.True` / `stdlib.False` counts like Python `bool` integers for
`pos`, `neg`, `add`, `sub`, `and_`, `or_`, `total()`, `update(mapping)`, and
`subtract(mapping)`, while preserving Python's observable result payload shape:
covered cases such as `+Counter(a=True, b=False, c=-1)`,
`Counter(a=True) + Counter(a=True)`, `Counter() + Counter(a=True, b=False)`,
`Counter(a=True) & Counter(a=1)`, `Counter(a=1) & Counter(a=True)`,
`Counter(a=True).update({'a': 1})`, `Counter(a=1).subtract({'a': True})`, and
`Counter(a=True, b=False).total()` now match local Python 3.10.11 instead of
surfacing raw AHK `AhkStdlibBoolean` operator errors. Mixed count
payloads that combine root `stdlib.True` / `stdlib.False` with
`fractions.Fraction(...)` and `decimal.Decimal(...)` now also follow local
Python's numeric tower across covered unary, binary, and mapping-update paths:
covered cases such as `+Counter(a=Fraction(3, 2), b=Fraction(-1, 2))`,
`-Counter(a=Decimal('1.5'), b=Decimal('-0.5'))`,
`Counter(a=True) + Counter(a=Fraction(1, 2))`,
`Counter(a=True) - Counter(a=Fraction(1, 2))`,
`Counter(a=True) & Counter(a=Fraction(1, 2))`,
`Counter(a=True) | Counter(a=Fraction(3, 2))`,
`Counter(a=True) + Counter(a=Decimal('0.5'))`,
`Counter(a=True) - Counter(a=Decimal('0.5'))`,
`Counter(a=True).update({'a': Fraction(1, 2)})`,
`Counter(a=Fraction(1, 2)).update({'a': True})`,
`Counter(a=True).update({'a': Decimal('0.5')})`, and
`Counter(a=Decimal('1.5')).subtract({'a': True})` now match Python 3.10.11
instead of surfacing raw AHK bool-arithmetic or positive-filter mismatches.
Covered `Counter` rich equality now also treats
`fractions.Fraction(...)` counts and numerically-equal
`decimal.Decimal(...)` counts as equal when both sides are `Counter`
instances, so cases like `Counter(a=Fraction(1, 2)) == Counter(a=Decimal('0.5'))`
and the matching `!=` path now follow local Python 3.10.11 instead of failing
through the raw AHK decimal-conversion gap for Fraction payloads.
Covered `Counter` rich ordering now also treats
`fractions.Fraction(...)` counts and comparable `decimal.Decimal(...)` counts
through Python's numeric tower when both sides are `Counter` instances, so
cases like `Counter(a=Fraction(1, 2)) < Counter(a=Decimal('0.75'))`,
`Counter(a=Fraction(1, 2)) <= Counter(a=Decimal('0.5'))`,
`Counter(a=Fraction(3, 2)) > Counter(a=Decimal('0.5'))`, and
`Counter(a=Fraction(1, 2)) >= Counter(a=Decimal('0.5'))` now follow local
Python 3.10.11 instead of surfacing the raw AHK mixed-type comparison gap for
Fraction-vs-Decimal payloads.
Covered `Counter` comparison errors now also preserve Python 3.10.11's concrete
mapping-subclass type names on the right-hand side for non-equality ordering
comparisons: `eq` / `ne` still compare value-wise against mapping subclasses,
but cases like `Counter(a=1) < DemoDictLike(a=2)` now raise
`TypeError("'<' not supported between instances of 'Counter' and 'DemoDictLike'")`
instead of collapsing the mapping subclass to a generic `'dict'` label.
Covered `Counter` arithmetic and set-style operand validation now also preserve
those concrete right-hand mapping-subclass type names for `+`, `-`, and `&`,
so cases like `Counter(a=1) + DemoDictLike(a=1)` now raise
`TypeError("unsupported operand type(s) for +: 'Counter' and 'DemoDictLike'")`
instead of reporting a generic `'dict'` operand label.
Covered reverse arithmetic validation where a plain mapping or mapping subclass
appears on the left and `Counter` is on the right now also preserves Python
3.10.11's concrete left-hand mapping type names, so covered cases like
`{'a': 1} + Counter(a=1)` raise
`TypeError("unsupported operand type(s) for +: 'dict' and 'Counter'")` while
`DemoDictLike(a=1) + Counter(a=1)` raises
`TypeError("unsupported operand type(s) for +: 'DemoDictLike' and 'Counter'")`
instead of leaking host AHK `Map` names.
Covered `Counter | mapping` and `mapping | Counter` now also follow the local
Python 3.10.11 result-shape baseline for covered plain `dict` union behavior:
the operation returns a plain mapping instead of a `Counter` or a `TypeError`,
and right-hand values overwrite left-hand values on shared keys. On this AHK
host, native `Map` enumeration order for string keys does not preserve Python
`dict` insertion ordering closely enough to promise the exact covered CPython
key-order result for mixed `Map` / `Counter` unions, so this slice currently
claims value/result-type parity but not full Python key-order parity.
Mixed count
types in unary `pos`/`neg` and set-style `and_`/`or_` now also surface
Python-style comparison error messages instead of raw AHK numeric-type
diagnostics, while same-type non-numeric `list`/`str` counts in `and_`/`or_`
now also follow Python's later positive-filter failure stage (`value > 0`)
instead of failing early on pairwise `<` comparisons. `add(str, int)`
preserves Python's special string-concatenation `TypeError` wording.
`update(mapping)` now also follows Python's `new_count + existing_count`
ordering for covered existing `str`/`list` payloads, preserving Python's
`'yx'`/`[2, 1]` results and the corresponding `int`-vs-`str` / `int`-vs-`list`
TypeError paths instead of attempting raw AHK `existing + new` evaluation.
Covered `Fraction`/`float` mapping updates now also follow local Python's
float-result path instead of failing as unsupported mixed counts.
`subtract(mapping)` now likewise remaps covered existing non-numeric count
payload failures such as `str-str`, `list-list`, and `function-function` back
to Python's `unsupported operand type(s) for -: ...` wording instead of
leaking AHK's raw numeric-type diagnostics, and the same now holds for
right-only mapping counts such as `Counter().subtract({'a': 'y'})`, which
again report Python's `int`-vs-payload binary-op wording rather than raw
AHK `0 - value` numeric diagnostics. Covered `Fraction`/`float` mapping
subtract paths now likewise follow local Python's float-result behavior
instead of failing as unsupported mixed counts.
`total()` now also remaps covered non-numeric count payload failures such as
`str`, `list`, and `function` back to Python's `unsupported operand type(s)
for +: 'int' and ...` wording instead of leaking AHK's raw `+=` numeric
diagnostics.
Non-iterable custom AHK class instances now surface their leaf class name in
the `"'Type' object is not iterable"` path instead of leaking nested AHK
class names, and `elements()` now uses Python-style type names for
non-integer counts such as `float`, `str`, `NoneType`, `function`, and custom
class names instead of raw AHK `Type(...)` names.
Direct `Fraction(1, 1)` and `Decimal("1")` count payloads remain rejected by
`elements()` with Python's integer-interpretation `TypeError`, matching local
Python 3.10.11. Deeper non-integer count edge cases remain deferred.

Fresh `collections` public-surface evidence from local Python 3.10.11 probe
`.codex/collections_public_surface_probe.py` plus
`.codex/collections_public_surface_probe.output.json` confirmed the module's
major public container names (`ChainMap`, `Counter`, `OrderedDict`,
`UserDict`, `UserList`, `UserString`, `defaultdict`, `deque`, and
`namedtuple`) and core behavior for bounded deque mutation, defaultdict
factory insertion, OrderedDict movement/pop order, ChainMap lookup and
`new_child(...)`, namedtuple fields/attribute lookup/`_asdict()`/`_replace()`/
`_make()`, and the UserDict/UserList/UserString wrapper surfaces. The focused
red `.codex/collections-public-surface-red-report.txt` failed because
`stdlib.collections.deque` was absent. The focused green
`.codex/collections-public-surface-green-focused-report.txt` passed 1/1,
root-smoke `.codex/collections-public-surface-stdlib-focused-report.txt`
passed 1/1, full module
`.codex/collections-public-surface-final-green-report.txt` passed
`stdlib/tests/collections.test.ahk` 64/64, and validation
`.codex/collections-public-surface-validate-report.txt` passed
`stdlib/collections.ahk`, `stdlib/tests/collections.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/collections.ahk` at
`TimeoutSeconds 90`. This slice intentionally claims public functionality
coverage for those container entrypoints first; detailed constructor keyword
parity, complete edge errors, and full `collections.abc` behavior remain
future maintenance work.

`stdlib.itertools` is a first slice of Python 3.10.11 `itertools`. It exposes
`accumulate`, `count`, `repeat`, `chain`, `compress`, `cycle`, `pairwise`, `product`, `zip_longest`, `groupby`, `combinations`, `combinations_with_replacement`, `permutations`, `starmap`, `takewhile`, `dropwhile`, `filterfalse`, `tee`, and `islice` under `stdlib.itertools`,
with lazy AHK enumerable objects and Python-style zero-based indexes for
`islice`. The legacy global `accumulate`, `chain`, `repeat`, `count`,
`compress`, `cycle`, `pairwise`, `product`, `zip_longest`, `groupby`, `combinations`, `combinations_with_replacement`, `permutations`, `starmap`, `takewhile`, `dropwhile`, `filterfalse`, `tee`, `islice`, `Next`, `List`, and `Itertools` entrypoints from
`itertools\itertools.ahk` are intentionally not part of the direct surface
because AHK includes share a case-insensitive global namespace. The direct
slice now rejects non-integer `repeat(..., times)` values with Python-style
`TypeError`, including root `stdlib.NotImplemented` as `NotImplementedType`,
while accepting root `stdlib.True` / `stdlib.False` times as
Python bool-as-int counts, accepts root `stdlib.True` / `stdlib.False`
`count(start, step)` values as Python bool-as-int numeric inputs while
preserving the covered explicit-root-bool first-yield behavior from local
Python 3.10.11, rejects non-numeric `count(start, step)` values,
allows float `count` progressions, accepts an AHK options-object analogue for
Python's keyword-style `start` and `step`, such as
`count({ start: 3, step: 2 })` and `count(3, { step: 2 })`, accepts covered `stdlib.decimal.Decimal(...)` and
`stdlib.fractions.Fraction(...)` start/step values through
`stdlib.operator.add(...)` stepping instead of raw AHK `+=`, including covered
mixed float/Fraction progressions that follow local Python's float-result
behavior, while still rejecting unsupported non-numeric starts/steps with
Python's `a number is required` message. Covered `count(...)` objects now expose
Python-style parameterized `__Repr()` text that tracks the current next value
and omits only Python's default integer/bool-true step, while covered
`repeat(...)` objects expose Python-style parameterized `__Repr()` text that
keeps infinite repeats unbounded and reports the remaining finite count after
partial consumption, and covered finite `repeat(...)` objects also provide the
remaining count to `stdlib.operator.length_hint(...)` while infinite repeats
use Python's unsized-object path, returning the caller-provided default from
`operator.length_hint(repeat(...), default)`. Covered `repeat(object, times :=
unset)` now also accepts the AHK options-object analogue for Python's
keyword-style `object=` / `times=` calls, so
`repeat({ object: "x", times: 3 })`, `repeat({ object: "x" })`, and
`repeat("x", { times: 3 })` now follow local Python 3.10.11 behavior. Covered
split keyword-analogue shapes such as `repeat({ object: "x" }, { times: 3 })`
and `repeat({ times: 3 }, { object: "x" })` now also follow the same Python
keyword behavior instead of treating the reversed form as a positional
non-integer `times` payload. Covered
plain iterable object values that define their own `__Enum` are now also kept
on the positional value path even when they carry keyword-like own properties
such as `object` or `times`, so `repeat(plain_object_value)` and
`repeat(plain_times_value, 2)` now repeat the real object value instead of
misclassifying it as the AHK keyword-analogue wrapper shape. Covered plain
iterable or callable object values passed in the second `times` position are
also now kept on Python's non-integer validation path even when they carry
keyword-like own properties such as `times` or `object`, so
`repeat("x", plain_times_obj)` now raises the covered
`'object' object cannot be interpreted as an integer` timing instead of being
misclassified as an AHK keyword-analogue options object. Covered
options-only missing-`object`, single-extra-key, too-many-keyword,
duplicate-`object`, positional-plus-single-invalid-key, and positional-plus-options
three/four-argument analogue paths now keep Python's observable error priority,
including options-only plain-object shapes with no recognized repeat keys:
`repeat({ extra: 1 })` and `repeat({ extra: 1, another: 2 })` now raise
`repeat() missing required argument 'object' (pos 1)`, while
`repeat({ extra: 1, another: 2, third: 3 })` crosses into
`repeat() takes at most 2 keyword arguments (3 given)`.
Covered
split keyword-analogue error priority now also mirrors Python's order-insensitive
keyword behavior: `repeat({ object: "x" }, { extra: 1 })` and
`repeat({ extra: 1 }, { object: "x" })` raise the invalid-keyword branch,
`repeat({ times: 3 }, { extra: 1 })` and
`repeat({ extra: 1 }, { times: 3 })` stay on the missing-`object` branch, and
three-key mixed shapes such as `repeat({ object: "x" }, { times: 3, extra: 1 })`
raise `repeat() takes at most 2 keyword arguments (3 given)`. Three-way split
keyword-wrapper shapes such as `repeat({ object: "x" }, { times: 3 }, {
extra: 1 })` and `repeat({ extra: 1 }, { object: "x" }, { times: 3 })` now
reach that same too-many-keyword branch instead of stopping early at the raw
three-argument arity error.
Covered
split keyword-analogue duplicate names now also follow Python's multi-`**`
merge behavior: `repeat({ object: "x" }, { object: "y" })` raises
`got multiple values for keyword argument 'object'`, while
`repeat({ object: "x", times: 3 }, { times: 4 })` and the reversed
`times`-first split form raise the corresponding duplicate-`times` branch
instead of silently keeping the first value. The same duplicate-first priority
now also covers three-way split forms such as `repeat({ object: "x" }, {
times: 3 }, { times: 4 })`, `repeat({ object: "x" }, { object: "y" }, {
extra: 1 })`, and `repeat({ extra: 1 }, { extra: 2 }, { object: "x" })`.
Covered
including the covered options-only `repeat({ times: 3, extra: 1, another: 2 })`
shape now surfacing Python's `repeat() takes at most 2 keyword arguments (3 given)`
instead of stopping early at the missing-`object` branch,
instead of falling through to raw AHK integer-interpretation or stale
argument-count errors. Covered positional-plus-two-keyword-wrapper forms now
also preserve Python's duplicate/arity order: `repeat("x", { times: 3 }, {
times: 4 })` raises duplicate `times`, while `repeat("x", { times: 3 }, {
another: 2 })` keeps `repeat() takes at most 2 arguments (3 given)`. The
direct slice accepts `stdlib.None` as an unbounded
`islice` stop value, treats explicit
`stdlib.None` start as Python's default `0`, treats `stdlib.None` step as
Python's default `1`, treats root `stdlib.True` / `stdlib.False` as Python
bool-as-int values for covered `islice` start, stop, and step paths, including
the Python `ValueError` for a false step, and now distinguishes Python's
stop-specific `ValueError` wording for explicit invalid
`islice(..., start, stop)` arguments instead of collapsing everything into the
generic indices message. Covered `islice(...)` now also surfaces Python 3.10's
no-keyword `TypeError("islice() takes no keyword arguments")` for AHK
keyword-style options objects such as `islice(iterable, { stop: value })`
before iterable or index validation. Covered `islice(...)` now also matches
local Python 3.10.11 for duplicate split keyword-wrapper objects before later
no-keyword or arity branches, so shapes like
`stdlib.itertools.islice({ extra: 1 }, { extra: 2 })` and
`stdlib.itertools.islice({ stop: 1 }, { stop: 2 })` raise the corresponding
duplicate-keyword `TypeError(...)`, while later-keyword shapes such as
`stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })` still keep
Python's no-keyword priority ahead of raw arity errors. Covered `islice(...)`
now also mirrors Python's explicit `expected at least 2 arguments` /
`expected at most 4 arguments` wording for the 0-, 1-, and 5-argument forms.
Covered `islice(...)` now validates index
arguments before iterable construction, then rejects non-iterable inputs at
construction without pre-consuming valid iterables. Covered `cycle(...)`
behavior now follows Python's lazy cache-and-replay semantics for finite
iterables, preserves iterator position across multiple consumers, returns empty
for empty iterables, validates non-iterable inputs at construction without
pre-consuming valid iterables, and shares the same Python-style non-iterable
type-name parity as `chain(...)` and `islice(...)`. `repeat(value, stdlib.None)` now also
reports Python's `NoneType`-specific integer-interpretation error instead of a
generic object type name, and custom AHK class instances now surface their leaf
class name in that same error path instead of collapsing to `'object'`, and
covered AHK function objects now surface Python's `function` type name instead
of raw `Func` / `BoundFunc`. AHK arrays and maps now also surface Python's
`list` and `dict` type names in that same `repeat(..., times)` error path
instead of raw AHK `Array` and `Map` names. The shared iterable validation path
used by `chain(...)`, `cycle(...)`, and `islice(...)` now also surfaces
Python-style `int`, `function`, `object`, and custom leaf class names for
non-iterable inputs instead of raw AHK `Type(...)` names. Covered
direct `chain(...)` now also rejects AHK keyword-style options objects such as
`chain({ iterables: rows })`, `chain({ iterable: rows })`, generic
property-object shapes such as `chain({ extra: 1, another: 2 })`, and mixed
positional-plus-keyword analogue paths like
`chain(rows, { iterables: other })` with Python 3.10's observable
`TypeError("chain() takes no keyword arguments")` before iterator
construction, instead of deferring until a wrapped object later falls through
to the generic non-iterable error path. Covered split keyword duplicate
priority now also matches local Python 3.10.11, so
`stdlib.itertools.chain({ extra: 1 }, { extra: 2 })` raises
`TypeError("itertools.chain() got multiple values for keyword argument
'extra'")` before the later no-keyword branch. Covered
plain `Object` iterables that define their own `__Enum` now stay accepted even
when they carry keyword-like own properties such as `iterables`, matching local
Python 3.10.11's distinction between real iterable objects and keyword syntax.
Covered plain callable `Object` values with keyword-like own properties are now
likewise kept off the keyword-analogue path, so `chain(plain_callable_obj)` and
`chain(rows, plain_callable_obj)` now raise Python's observable non-iterable
`TypeError(...)` instead of being misclassified as keyword syntax.
Covered
`chain.from_iterable(iterable)` now mirrors Python 3.10.11's alternate
constructor shape by lazily flattening each inner iterable while preserving
iterator position across consumers, with `chain(...)` itself kept callable on
the public `stdlib.itertools.chain` surface. It now also rejects AHK
keyword-style options objects such as
`chain.from_iterable({ iterable: rows })` and generic property-object shapes
such as `chain.from_iterable({ extra: 1, another: 2 })` with Python 3.10's
`TypeError("chain.from_iterable() takes no keyword arguments")` before iterable
validation, including the mixed positional-plus-keyword analogue path
`chain.from_iterable(rows, { iterable: other })` that previously fell through
to the raw one-argument arity error and later-keyword-over-arity paths such as
`chain.from_iterable(rows, 2, { extra: 1 })` that now also keep Python's
no-keyword priority instead of falling through to the raw three-argument arity
error. Covered split keyword duplicate priority
now also matches local Python 3.10.11, so
`stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 })` raises
`TypeError("chain.from_iterable() got multiple values for keyword argument
'extra'")` before the later no-keyword branch. Covered plain callable `Object` values now
also stay off that keyword-analogue path, so
`chain.from_iterable(plain_callable_obj)` raises Python's observable
non-iterable `TypeError(...)` and
`chain.from_iterable(rows, plain_callable_obj)` keeps the exact
`chain.from_iterable() takes exactly one argument (2 given)` arity error.
Covered direct and
`from_iterable(...)` chain objects also expose Python-style
`<itertools.chain object at 0x...>` `__Repr()` text. Covered iterator objects
for `accumulate`, `compress`, `cycle`, `islice`, `pairwise`, `product`,
`zip_longest`, `groupby`, groupby `_grouper`, `combinations`,
`combinations_with_replacement`, `permutations`, `starmap`, `takewhile`,
`dropwhile`, and `filterfalse` now also expose the matching Python-style
`<itertools.name object at 0x...>` `__Repr()` shape while preserving existing
lazy iteration state. Covered
`accumulate(...)` now follows Python's lazy running-total behavior for default
addition, optional `initial`, empty iterables, and callable operator injection.
The public AHK surface also accepts an options-object analogue for Python's
keyword-only `initial`, such as `accumulate(iterable, { initial: value })` or
`accumulate(iterable, stdlib.None, { initial: value })`, while non-iterable
sources are validated at construction and non-callable accumulation functions
surface Python-style `TypeError` messages only when a merge step is consumed,
after Python-compatible first-item or `initial` emission. Covered
`compress(data, selectors)` now
follows Python's lazy truth-filtering behavior using shared stdlib truthiness
for selectors, including root `stdlib.True` / `stdlib.False`, empty arrays, and
empty maps, stops when either iterator is exhausted, preserves iterator
position across consumers, validates data first and selectors second at
construction without pre-consuming valid iterables, and reuses the same
Python-style non-iterable type-name parity on both sides.
Covered `pairwise(iterable)` now follows Python 3.10.11 by yielding lazy
overlapping root tuple pairs, returning empty results for zero- or one-item
iterables, preserving iterator position across multiple consumers, validating
non-iterable inputs at construction without pre-consuming valid iterables, and
reusing the same Python-style non-iterable type-name parity as the other shared
iterable validators. Covered argument parsing now also rejects the AHK keyword
analogue path, so calls like `stdlib.itertools.pairwise({ iterable: rows })`,
generic property-object shapes such as
`stdlib.itertools.pairwise({ extra: 1, another: 2 })`, and mixed
positional-plus-keyword analogues such as
`stdlib.itertools.pairwise([1, 2], { iterable: [3, 4] })` or
`stdlib.itertools.pairwise([1, 2], { extra: 1 })` now all raise Python's
observable `TypeError("pairwise() takes no keyword arguments")` instead of
falling through to the generic object-not-iterable path or leaking raw AHK
too-many-parameters behavior. Covered sentinel-position priority now also
matches Python 3.10.11 so `stdlib.itertools.pairwise(stdlib.None)` and
`stdlib.itertools.pairwise(stdlib.NotImplemented)` keep the shared
non-iterable `NoneType` / `NotImplementedType` errors, while
`stdlib.itertools.pairwise([1, 2], stdlib.None)` still raises
`TypeError("pairwise expected 1 argument, got 2")` as an extra positional
argument rather than being misclassified as a keyword analogue. Covered plain
callable `Object` values that define their own `Call` now also stay positional
even when they carry keyword-like own properties such as `iterable` or `extra`,
so `stdlib.itertools.pairwise(callable_obj)` surfaces Python's iterable
`TypeError`, while `stdlib.itertools.pairwise(rows, callable_obj)` keeps
Python's one-argument arity error instead of falling into the AHK no-keyword
path.
Covered `product(*iterables)` now follows Python 3.10.11 default `repeat=1`
behavior by materializing all input pools at construction, yielding readonly
root tuple rows in lexicographic order with the rightmost iterable advancing
fastest, returning one empty tuple row for zero input iterables, returning empty
when any materialized pool is empty, preserving iterator position across
consumers, and surfacing Python-style non-iterable type names for covered
invalid inputs. The current direct slice also covers an AHK options-object
analogue for Python's keyword-only `repeat`, using
`product(iterable1, { repeat: n })` to duplicate the input pools, including
Python-style `repeat=0`, root-bool repeat, invalid-repeat error behavior, and
the covered duplicate-keyword analogue
`stdlib.itertools.product([1, 2], { repeat: 2, iterables: "x" })`, which now
raises Python 3.10.11's `TypeError("product() takes at most 1 keyword argument (2 given)")`
instead of being accepted silently by the wrapper. The covered single-invalid-
keyword analogue `stdlib.itertools.product({ iterables: "x" })` now also raises
Python 3.10.11's `TypeError("'iterables' is an invalid keyword argument for product()")`
instead of falling through to `"'object' object is not iterable"`. Generic
plain-property-object shapes such as `stdlib.itertools.product({ extra: 1 })`
and `stdlib.itertools.product([1], { extra: 1 })` now also raise Python
3.10.11's `TypeError("'extra' is an invalid keyword argument for product()")`
instead of falling through to that same non-iterable fallback.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry their own `repeat` property, so shapes such as
`stdlib.itertools.product([1], iterable_obj)` mirror local Python 3.10.11
instead of misclassifying the trailing iterable as a keyword analogue.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as
`repeat`, `iterables`, `fillvalue`, or `extra`, so
`stdlib.itertools.product(callable_obj)`,
`stdlib.itertools.product([1], callable_obj)`,
`stdlib.itertools.zip_longest(callable_obj)`, and
`stdlib.itertools.zip_longest([1], callable_obj)` now all surface Python's
observable non-iterable `TypeError(...)` instead of being reclassified as AHK
keyword-analogue wrappers or silently consumed as trailing keyword options.
Covered AHK split trailing options-object analogues now also aggregate their
plain-object keyword payloads before validation, following the same observable
Python 3.10.11 keyword-count priority as equivalent direct probes such as
`product([1], repeat=2, extra=1)` and `product(repeat=2, extra=1)`. Shapes
such as `stdlib.itertools.product([1], { repeat: 2 }, { extra: 1 })`,
`stdlib.itertools.product({ repeat: 2 }, { extra: 1 })`, and
`stdlib.itertools.product([1], { extra: 1 }, { repeat: 2 })` now all raise
Python's `TypeError("product() takes at most 1 keyword argument (2 given)")`
instead of misclassifying only the final object and surfacing a single-invalid-
keyword or wrapped-object non-iterable fallback. Split trailing keyword-wrapper
duplicates now also follow Python's multi-`**` merge priority ahead of that
keyword-count branch, so shapes such as `stdlib.itertools.product([1], {
repeat: 2 }, { repeat: 3 })`, `stdlib.itertools.product({ repeat: 2 }, {
repeat: 3 })`, and `stdlib.itertools.product([1], { extra: 1 }, { extra: 2 })`
raise `TypeError("itertools.product() got multiple values for keyword argument '...'")`
before later keyword-count handling.
Covered `zip_longest(*iterables)` now follows Python 3.10.11 default
`fillvalue=None` behavior by creating input iterators without materializing or
pre-consuming sources at construction, yielding readonly root tuple rows until
the longest input is exhausted, filling shorter inputs with root `stdlib.None`,
returning empty for zero input iterables, preserving iterator position across
consumers, and surfacing Python-style non-iterable type names for covered
invalid inputs. The current direct slice also covers an AHK options-object
analogue for Python's keyword-only `fillvalue`, using
`zip_longest(iterable1, iterable2, { fillvalue: value })` to fill shorter
inputs with the supplied value. The covered duplicate-keyword analogue
`stdlib.itertools.zip_longest([1, 2], [3], { fillvalue: "X", iterables: "Y" })`
now also raises Python 3.10.11's
`TypeError("zip_longest() got an unexpected keyword argument")` instead of
being accepted silently by the wrapper. The covered single-invalid-key
analogue `stdlib.itertools.zip_longest({ iterables: "x" })` now also raises
that same Python 3.10.11 `TypeError("zip_longest() got an unexpected keyword argument")`
instead of falling through to `"'object' object is not iterable"`. Generic
plain-property-object shapes such as `stdlib.itertools.zip_longest({ extra: 1 })`
and `stdlib.itertools.zip_longest([1], { extra: 1 })` now also raise that same
Python 3.10.11 `TypeError("zip_longest() got an unexpected keyword argument")`
instead of falling through to that same non-iterable fallback.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry their own `fillvalue` property, so shapes such
as `stdlib.itertools.zip_longest([1], iterable_obj)` mirror local Python
3.10.11 instead of misclassifying the trailing iterable as a keyword analogue.
Covered AHK split trailing options-object analogues now also aggregate their
plain-object keyword payloads before validation, following the same observable
Python 3.10.11 unexpected-keyword result as direct probes such as
`zip_longest([1], fillvalue="X", extra=1)` and
`zip_longest(fillvalue="X", extra=1)`. Shapes such as
`stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { extra: 1 })`,
`stdlib.itertools.zip_longest({ fillvalue: "X" }, { extra: 1 })`, and
`stdlib.itertools.zip_longest([1], { extra: 1 }, { fillvalue: "X" })` now all
raise Python's `TypeError("zip_longest() got an unexpected keyword argument")`
instead of treating the earlier options object as a positional iterable and
falling through to `"'object' object is not iterable"`. Split trailing
keyword-wrapper duplicates now also follow Python's multi-`**` merge priority
ahead of that unexpected-keyword branch, so shapes such as
`stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { fillvalue: "Y" })`,
`stdlib.itertools.zip_longest({ fillvalue: "X" }, { fillvalue: "Y" })`, and
`stdlib.itertools.zip_longest([1], { extra: 1 }, { extra: 2 })` raise
`TypeError("itertools.zip_longest() got multiple values for keyword argument '...'")`
before later unexpected-keyword handling.
Covered `groupby(iterable, key := None)` now follows Python 3.10.11 by creating
the source iterator without pre-consuming it at construction, grouping
consecutive equal keys, treating omitted or explicit `stdlib.None` key as the
identity key, supporting covered callable keys and an AHK options-object
analogue for Python's keyword-style `key`, using
`groupby(iterable, { key: callable_or_None })`, returning `(key, group)` rows
as readonly root tuples, sharing source state between the outer iterator and
group iterators so advancing the outer iterator invalidates older unfinished
groups, and surfacing Python-style non-iterable and delayed non-callable-key
errors for covered invalid inputs.
Covered `combinations(iterable, r)` now follows Python 3.10.11 by
materializing the input pool at construction, yielding readonly root tuple rows
in lexicographic index order, preserving iterator position across consumers,
supporting `r=0`, oversized `r`, native bool-as-int `r`, and root
`stdlib.True` / `stdlib.False` `r` values, validating integer-interpretation
errors before iterable materialization, and surfacing
Python-style non-iterable and negative-`r` errors for covered inputs.
Covered `combinations_with_replacement(iterable, r)` now follows Python 3.10.11
by requiring the `r` argument, materializing the input pool at construction,
yielding readonly root tuple rows in lexicographic order with repeated element
positions, preserving iterator position across consumers, supporting `r=0`,
oversized `r`, native bool-as-int `r`, root `stdlib.True` / `stdlib.False` `r`
values, and empty-pool edge cases, validating integer-interpretation errors
before iterable materialization, and surfacing Python-style non-iterable and
negative-`r` errors for covered inputs.
Covered `permutations(iterable, r := None)` now follows Python 3.10.11 by
materializing the input pool at construction, treating omitted or explicit
`stdlib.None` `r` as the full pool length, yielding readonly root tuple rows in
lexicographic index order, preserving iterator position across consumers,
supporting `r=0`, oversized `r`, native bool-as-int `r`, and root
`stdlib.True` / `stdlib.False` `r` values, validating the iterable before `r`
for covered invalid inputs, and surfacing Python's `Expected int as r` and
negative-`r` messages after successful materialization.
The covered combinations-family wrappers now also keep plain iterable objects
with their own keyword-like props such as `iterable`, `r`, or `extra`
positional when those objects define `__Enum`, so
`combinations(iterable_obj, 1)`,
`combinations_with_replacement(iterable_obj, 1)`, and
`permutations(iterable_obj, 1)` enumerate their real values while
`combinations("ab", iterable_obj)` / `combinations_with_replacement("ab",
iterable_obj)` still raise Python's integer-interpretation TypeError and
`permutations("ab", iterable_obj)` still raises the covered `Expected int as r`
path instead of misclassifying those iterable objects as keyword syntax.
Covered `starmap(func, iterable)` now follows Python 3.10.11 by lazily
materializing each iterable row into positional call arguments, preserving
iterator position across multiple consumers, accepting string rows as
character arguments for covered callables, and reusing the shared
Python-style callable and non-iterable type-name parity for invalid inputs.
Covered non-callable `func` values are validated only when the iterator is
consumed, after the current argument row is materialized, including `int` and
root `stdlib.None` function cases, while non-iterable outer inputs are still
rejected at construction before any callable validation. Covered argument
parsing also now matches Python's no-keyword rejection on the AHK keyword
analogue path, including options-only property objects such as
`stdlib.itertools.starmap({ extra: 1, another: 2 })`, second-argument
property-object shapes such as
`stdlib.itertools.starmap(func, { extra: 1 })`, and a third argument such as
`{ iterable: ... }` after the two positional arguments, which now all raise
`TypeError("starmap() takes no keyword arguments")` instead of falling through
to raw arity or generic object-not-iterable errors.
Covered plain `Object` callables that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `function` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax. Covered plain callable second-argument
values such as `stdlib.itertools.starmap(func, callable_obj)` now likewise stay
positional and surface Python's non-iterable `TypeError`, while extra
positional callable third arguments such as `stdlib.itertools.starmap(func,
rows, callable_obj)` keep Python's exact-two-arguments arity error instead of
falling into the AHK no-keyword analogue path.
Covered `takewhile(predicate, iterable)` now follows Python 3.10.11 by lazily
yielding items while predicate results are true under shared stdlib truthiness,
including root `stdlib.True` / `stdlib.False`, empty arrays, empty maps, and
`stdlib.None`, preserving iterator position across consumers, accepting covered
string iterables, validating non-iterable inputs at construction, and surfacing
non-callable predicate errors only when consumed, including covered `int` and
root `stdlib.None` predicate cases. Covered non-iterable inputs are rejected at
construction before predicate callable validation, including the bad-predicate
plus bad-iterable priority case observed in local Python 3.10.11. Covered
argument parsing now also rejects the AHK keyword analogue path, so calls like
`stdlib.itertools.takewhile(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.takewhile(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.takewhile(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("takewhile() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `dropwhile(predicate, iterable)` now follows Python 3.10.11 by lazily
discarding items while the predicate is true, yielding the first false item and
all remaining items without calling the predicate again, preserving iterator
position across consumers, accepting covered string iterables, validating
non-iterable inputs at construction, surfacing non-callable predicate errors
only when consumed, and now rejecting the AHK keyword analogue path so calls
like `stdlib.itertools.dropwhile(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.dropwhile(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.dropwhile(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("dropwhile() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `filterfalse(predicate, iterable)` now follows Python 3.10.11 by
lazily yielding items where the predicate is false, using `stdlib.None` as the
Python `None` predicate to apply shared stdlib truthiness directly to each
item, preserving iterator position across consumers, validating non-iterable
inputs at construction, surfacing non-callable predicate errors only when the
iterator is consumed, and now rejecting the AHK keyword analogue path so calls
like `stdlib.itertools.filterfalse(predicate, { iterable: rows })`, generic
property-object shapes such as
`stdlib.itertools.filterfalse(predicate, { extra: 1 })`, and third-argument
keyword-analogue objects such as
`stdlib.itertools.filterfalse(predicate, rows, { extra: 1 })` raise Python's
observable `TypeError("filterfalse() takes no keyword arguments")` instead of
falling through to raw AHK arity errors.
Covered plain `Object` predicates that define their own `Call` and plain
`Object` iterables that define their own `__Enum` now also stay positional even
when they carry keyword-like own properties such as `predicate` or `iterable`,
matching local Python 3.10.11's behavior for real callable and iterable
instances versus actual keyword syntax.
Covered `cycle(iterable)` now also rejects the AHK keyword analogue path, so
calls like `stdlib.itertools.cycle({ iterable: rows })`,
`stdlib.itertools.cycle({ extra: 1, another: 2 })`, and
`stdlib.itertools.cycle(rows, { iterable: other })` raise Python's observable
`TypeError("cycle() takes no keyword arguments")` instead of falling through
to the raw iterable-type error for the first object argument, and now also
keeps plain `Object` iterables with their own `__Enum` accepted even when they
carry a keyword-like own `iterable` property, matching local Python 3.10.11's
behavior for real iterable instances versus keyword syntax. Covered plain
callable `Object` values with keyword-like own properties are now likewise kept
off the keyword-analogue path, so `cycle(plain_callable_obj)` raises Python's
observable non-iterable `TypeError(...)` and `cycle(rows, plain_callable_obj)`
keeps Python's exact-one-argument arity error instead of being misclassified as
keyword syntax. Covered split keyword duplicate priority now also matches local
Python 3.10.11, so `stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })`
raises `TypeError("itertools.cycle() got multiple values for keyword argument
'extra'")` before the later no-keyword or arity branch. Covered later-keyword
priority now also matches local Python 3.10.11, so
`stdlib.itertools.cycle(rows, 3, { extra: 1 })` raises
`TypeError("cycle() takes no keyword arguments")` before the raw
three-argument arity branch, and now also
matches Python 3.10.11's exact-one-argument call-shape messages so
`stdlib.itertools.cycle()` and `stdlib.itertools.cycle(rows, 3)` raise
`TypeError("cycle expected 1 argument, got N")` instead of leaking AutoHotkey's
raw missing-parameter error or misclassifying extra positional arguments as
keyword analogues.
Covered `count(start := 0, step := 1)` now also matches Python 3.10.11's
three-argument duplicate-start boundary, so
`stdlib.itertools.count(1, 2, { start: 3 })` raises
`TypeError("count() takes at most 2 arguments (3 given)")` instead of leaking
AutoHotkey's raw too-many-parameters error, and the covered extra-key analogue
`stdlib.itertools.count({ step: 2, extra: 3 })` now raises Python 3.10.11's
`TypeError("'extra' is an invalid keyword argument for count()")` instead of
silently ignoring the unexpected field.
Covered split plain-property keyword analogues now also follow Python 3.10.11's
observable keyword behavior, so
`stdlib.itertools.count({ start: 3 }, { step: 2 })` and
`stdlib.itertools.count({ step: 2 }, { start: 3 })` now yield the same rows as
Python `count(start=3, step=2)` instead of dropping the second options object
and falling through to `a number is required`. Options-only and split invalid-
keyword analogues such as `stdlib.itertools.count({ extra: 3 })`,
`stdlib.itertools.count({ start: 1 }, { extra: 3 })`, and
`stdlib.itertools.count({ step: 2 }, { extra: 3 })` now likewise raise Python's
`TypeError("'extra' is an invalid keyword argument for count()")` instead of
escaping into numeric coercion failures, while higher-cardinality split shapes
such as `stdlib.itertools.count({ start: 1 }, { step: 2, extra: 3 })` and
`stdlib.itertools.count({ start: 1, extra: 3 }, { step: 2 })` now raise
Python's `TypeError("count() takes at most 2 keyword arguments (3 given)")`
instead of miscounting the two plain objects as a positional value plus a
single keyword wrapper.
Covered plain callable `Object` values that define their own `Call` now also
stay on Python's numeric-validation path even when they carry keyword-like own
properties such as `start` or `step`, so
`stdlib.itertools.count(callable_obj)` and
`stdlib.itertools.count(0, callable_obj)` now still raise Python's observable
`TypeError("a number is required")` instead of being misclassified as AHK
keyword-analogue wrappers.
Covered `groupby(iterable, key := unset)` now also accepts Python 3.10.11's
`iterable=` keyword path through the AHK options-object analogue, so calls
like `stdlib.itertools.groupby({ iterable: rows })` and
`stdlib.itertools.groupby({ iterable: rows, key: keyfunc })` now materialize
the same lazy grouped output as Python instead of falling through to the raw
`'object' object is not iterable` failure on the wrapper object itself.
The covered options-only analogue path now also matches Python 3.10.11's
missing-required-argument wording: `stdlib.itertools.groupby({ key:
callable })` now raises `groupby() missing required argument 'iterable'
(pos 1)` instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
Generic plain-property-object shapes such as `stdlib.itertools.groupby({
extra: 1 })` now also preserve that same Python 3.10.11 missing-`iterable`
priority instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
The covered single-extra-key analogue path
`stdlib.itertools.groupby({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for groupby()`
instead of being misclassified as a too-many-keyword error.
The covered extra-key analogue path
`stdlib.itertools.groupby({ iterable: rows, key: callable, extra: 1 })` now
also raises Python 3.10.11's `groupby() takes at most 2 keyword arguments
(3 given)` instead of silently accepting the unexpected field.
The covered duplicate-key analogue path
`stdlib.itertools.groupby(rows, keyfunc, { key: other })` now also raises
Python 3.10.11's `groupby() takes at most 2 arguments (3 given)` instead of
leaking AutoHotkey's raw too-many-parameters error.
Covered split plain-property keyword analogues now also follow Python 3.10.11's
observable keyword behavior, so
`stdlib.itertools.groupby({ key: keyfunc }, { iterable: rows })` now yields
the same grouped rows as Python `groupby(key=keyfunc, iterable=rows)` instead
of stopping early at the missing-`iterable` branch. Split shapes such as
`stdlib.itertools.groupby({ extra: 1 }, { iterable: rows })` now likewise
raise Python's `'extra' is an invalid keyword argument for groupby()`, while
`stdlib.itertools.groupby({ key: keyfunc }, { extra: 1 })` preserves Python's
missing-`iterable` priority and
`stdlib.itertools.groupby({ key: keyfunc }, { iterable: rows, extra: 1 })`
raises Python's `groupby() takes at most 2 keyword arguments (3 given)`
instead of misclassifying the second plain object as a positional value
wrapper. Split keyword-wrapper duplicates now also follow Python's multi-`**`
merge priority, so `stdlib.itertools.groupby({ iterable: rows }, {
iterable: other_rows })` raises `itertools.groupby() got multiple values for
keyword argument 'iterable'`, while three-way shapes such as
`stdlib.itertools.groupby({ iterable: rows }, { key: keyfunc }, { key:
other_key })` and `stdlib.itertools.groupby({ extra: 1 }, { extra: 2 }, {
iterable: rows })` raise the corresponding duplicate-keyword branch ahead of
later keyword-count handling.
Positional-plus-keyword-analogue shapes such as
`stdlib.itertools.groupby(rows, { extra: 1 })`,
`stdlib.itertools.groupby(rows, { iterable: other_rows })`, and
`stdlib.itertools.groupby(rows, { key: keyfunc, extra: 1 })` now also raise
the same invalid-keyword, duplicate-name, and too-many-arguments Python
`TypeError(...)` forms instead of silently accepting or misclassifying the
wrapped object.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as
`iterable`, `key`, or `extra`, so `stdlib.itertools.groupby(callable_obj)`
surfaces Python's iterable `TypeError` while
`stdlib.itertools.groupby(rows, callable_obj)` still uses the callable as the
lazy key function instead of misclassifying it as a keyword-analogue wrapper.
Covered plain iterable `Object` values that define their own `__Enum` now also
stay positional when they are passed in the second `key` slot, even if they
carry keyword-like own properties such as `key`, `iterable`, or `extra`, so
`stdlib.itertools.groupby(rows, iterable_obj)` now mirrors Python 3.10.11's
lazy `TypeError("'object' object is not callable")` path instead of being
misclassified as an AHK keyword-analogue wrapper and failing during argument
parsing.
Covered `compress(data, selectors)` now also accepts Python 3.10.11's covered
keyword-capable paths through the AHK options-object analogue, so calls like
`stdlib.itertools.compress(rows, { selectors: mask })` and
`stdlib.itertools.compress({ data: rows, selectors: mask })` now yield the
same filtered output and surface the same non-iterable `TypeError` timing for
covered invalid `data`/`selectors` inputs instead of failing on the wrapper
object shape itself. The covered missing-`selectors` keyword shape
`stdlib.itertools.compress({ data: rows })` now also raises Python 3.10.11's
`compress() missing required argument 'selectors' (pos 2)` instead of leaking a
raw AHK `UnsetError`. The covered missing-`selectors`-plus-extra-key analogue
`stdlib.itertools.compress({ data: rows, extra: 1 })` now also preserves that
same Python priority instead of being misclassified as a too-many-keyword
error. The covered duplicate-selector-keyword shape
`stdlib.itertools.compress({ selectors: mask })` now also raises Python
3.10.11's `compress() missing required argument 'data' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. The covered duplicate-selector-keyword shape
`stdlib.itertools.compress({ extra: 1 })` now also preserves that same
missing-`data` priority instead of being misclassified as a missing-selectors
wrapper error. Positional-plus-keyword-analogue shapes such as
`stdlib.itertools.compress(rows, { extra: 1 })`,
`stdlib.itertools.compress(rows, { data: other_rows })`,
`stdlib.itertools.compress(rows, { selectors: mask, extra: 1 })`, and
`stdlib.itertools.compress(rows, { data: other_rows, selectors: mask })` now
also raise the same missing-`selectors` and too-many-arguments Python
`TypeError(...)` forms instead of silently accepting or misclassifying the
wrapped object.
The covered duplicate-selector-keyword shape
`stdlib.itertools.compress(rows, mask, { selectors: other_mask })` now also
raises Python 3.10.11's `compress() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw too-many-parameters error.
The covered extra-key analogue shape
`stdlib.itertools.compress({ data: rows, selectors: mask, extra: 1 })` now
also raises Python 3.10.11's `compress() takes at most 2 keyword arguments
(3 given)` instead of silently accepting the unexpected field. Covered plain
iterable `Object` instances that define their own `__Enum` are now also kept on
the positional iterable path even when they carry keyword-like own properties
such as `data` or `selectors`, so
`stdlib.itertools.compress(plain_data_obj, mask)`,
`stdlib.itertools.compress(rows, plain_selectors_obj)`, and
`stdlib.itertools.compress(plain_data_obj, plain_selectors_obj)` now match
local Python 3.10.11 instead of being misclassified as keyword-analogue
wrapper objects. Covered plain callable `Object` values that define their own
`Call` now also stay positional even when they carry keyword-like own
properties such as `data` or `selectors`, so
`stdlib.itertools.compress(callable_obj, mask)` and
`stdlib.itertools.compress(rows, callable_obj)` both surface Python's iterable
`TypeError` instead of being misclassified as keyword-analogue wrappers.
Covered `combinations(iterable, r)` now also accepts Python 3.10.11's covered
`r=` and `iterable=` keyword-capable paths through the AHK options-object
analogue, so calls like `stdlib.itertools.combinations(rows, { r: 2 })` and
`stdlib.itertools.combinations({ iterable: rows, r: 2 })` now yield the same
combination rows as Python and still surface the covered
`'str' object cannot be interpreted as an integer` `TypeError` timing for
invalid `r` values instead of misrouting the wrapper object into the numeric
slot. The covered options-only analogue path
`stdlib.itertools.combinations({ r: 2 })` now also raises Python 3.10.11's
`combinations() missing required argument 'iterable' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. Generic plain-property-object shapes such as
`stdlib.itertools.combinations({ extra: 1 })` and
`stdlib.itertools.combinations({ r: 2, extra: 1 })` now also preserve that
same missing-`iterable` priority, while higher-cardinality plain keyword-
analogue shapes such as `stdlib.itertools.combinations({ extra: 1, another:
2, third: 3 })` and `stdlib.itertools.combinations({ iterable: rows, extra:
1, another: 2 })` now raise Python 3.10.11's
`combinations() takes at most 2 keyword arguments (3 given)` instead of
collapsing to the same missing-required-argument fallback.
The covered iterable-plus-extra analogue path
`stdlib.itertools.combinations({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `combinations() missing required argument 'r' (pos 2)`
instead of falling through to an AutoHotkey `UnsetError` from the missing
wrapped `r` slot. The covered iterable-plus-`r`-plus-extra analogue
`stdlib.itertools.combinations({ iterable: rows, r: 2, extra: 1 })` now also
raises Python 3.10.11's `combinations() takes at most 2 keyword arguments (3
given)` instead of silently accepting the unexpected field. The covered
duplicate iterable analogue path
`stdlib.itertools.combinations(rows, { iterable: other_rows })` now also
raises Python 3.10.11's `combinations() missing required argument 'r' (pos
2)` instead of misrouting the second options object into the wrapped `r`
slot and surfacing `"'object' object cannot be interpreted as an integer"`.
Additional second-argument property-object shapes such as
`stdlib.itertools.combinations(rows, { extra: 1 })` now also preserve that
same missing-`r` priority, while shapes such as
`stdlib.itertools.combinations(rows, { r: 2, extra: 1, another: 2 })` now
surface Python's dynamic given-count form
`combinations() takes at most 2 arguments (4 given)` instead of collapsing
distinct multi-key cases into the same fixed three-argument wrapper error.
The covered three-argument duplicate-binding analogue
`stdlib.itertools.combinations(rows, 2, { iterable: other_rows })` now also
raises Python 3.10.11's `combinations() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.combinations(rows, { r: 1, extra: 1 })` now also
raises Python 3.10.11's `combinations() takes at most 2 arguments (3 given)`
instead of silently unwrapping the second object and discarding its unexpected
field. The current wrapper now also merges covered split plain-object keyword
analogues across both argument slots before validation, so
`stdlib.itertools.combinations({ iterable: rows }, { r: 2 })` and
`stdlib.itertools.combinations({ r: 2 }, { iterable: rows })` yield the same
rows as local Python `combinations(iterable=rows, r=2)`, while split error
priority shapes such as `stdlib.itertools.combinations({ extra: 1 }, {
iterable: rows })` and `stdlib.itertools.combinations({ r: 2 }, {
iterable: rows, extra: 1 })` now follow Python's missing-`r` and
too-many-keywords branches instead of stopping early at the first wrapper
object.
Covered `combinations_with_replacement(iterable, r)` now also accepts Python
3.10.11's covered `r=` and `iterable=` keyword-capable paths through the AHK
options-object analogue, so calls like
`stdlib.itertools.combinations_with_replacement(rows, { r: 2 })` and
`stdlib.itertools.combinations_with_replacement({ iterable: rows, r: 2 })`
now yield the same replacement-combination rows as Python and still surface
the covered `'str' object cannot be interpreted as an integer` `TypeError`
timing for invalid `r` values instead of misrouting the wrapper object into
the numeric slot. The covered options-only analogue path
`stdlib.itertools.combinations_with_replacement({ r: 2 })` now also raises
Python 3.10.11's `combinations_with_replacement() missing required argument
'iterable' (pos 1)` instead of falling through to the wrong missing-`r`
wrapper failure. Generic plain-property-object shapes such as
`stdlib.itertools.combinations_with_replacement({ extra: 1 })` now also
preserve that same missing-`iterable` priority, while higher-cardinality
plain keyword-analogue shapes such as
`stdlib.itertools.combinations_with_replacement({ extra: 1, another: 2,
third: 3 })` now raise Python 3.10.11's
`combinations_with_replacement() takes at most 2 keyword arguments (3 given)`
instead of collapsing to the same missing-`iterable` fallback.
The covered duplicate iterable analogue path
`stdlib.itertools.combinations_with_replacement(rows, { iterable: other_rows })`
now also raises Python 3.10.11's
`combinations_with_replacement() missing required argument 'r' (pos 2)`
instead of misrouting the second options object into the wrapped `r` slot
and surfacing `"'object' object cannot be interpreted as an integer"`. The
covered iterable-plus-`r`-plus-extra analogue
`stdlib.itertools.combinations_with_replacement({ iterable: rows, r: 2,
extra: 1 })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 keyword arguments (3 given)`
instead of silently accepting the unexpected field. The
covered three-argument duplicate-binding analogue
`stdlib.itertools.combinations_with_replacement(rows, 2, { iterable:
other_rows })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 arguments (3 given)` instead
of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.combinations_with_replacement(rows, { r: 1, extra:
1 })` now also raises Python 3.10.11's
`combinations_with_replacement() takes at most 2 arguments (3 given)` instead
of silently unwrapping the second object and discarding its unexpected field.
Additional second-argument property-object shapes such as
`stdlib.itertools.combinations_with_replacement(rows, { extra: 1 })` now also
preserve Python's missing-`r` priority, while shapes such as
`stdlib.itertools.combinations_with_replacement(rows, { r: 2, extra: 1,
another: 2 })` now surface Python's dynamic given-count form
`combinations_with_replacement() takes at most 2 arguments (4 given)` instead
of collapsing distinct multi-key cases into the same fixed three-argument
wrapper error. The current wrapper now also merges covered split plain-object
keyword analogues across both argument slots before validation, so
`stdlib.itertools.combinations_with_replacement({ iterable: rows }, { r: 2 })`
and `stdlib.itertools.combinations_with_replacement({ r: 2 }, {
iterable: rows })` yield the same rows as local Python
`combinations_with_replacement(iterable=rows, r=2)`, while split error
priority shapes such as `stdlib.itertools.combinations_with_replacement({
extra: 1 }, { iterable: rows })` and
`stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: rows,
extra: 1 })` now follow Python's missing-`r` and too-many-keywords branches
instead of misclassifying the second wrapper object as a positional `r` value.
Covered `permutations(iterable, r := None)` now also accepts Python 3.10.11's
covered `r=` and `iterable=` keyword-capable paths through the AHK
options-object analogue, so calls like
`stdlib.itertools.permutations(rows, { r: 2 })` and
`stdlib.itertools.permutations({ iterable: rows, r: 2 })` now yield the same
permutation rows as Python and still surface the covered `Expected int as r`
`TypeError` timing for invalid `r` values instead of misrouting the wrapper
object into the numeric slot. The covered options-only analogue path
`stdlib.itertools.permutations({ r: 2 })` now also raises Python 3.10.11's
`permutations() missing required argument 'iterable' (pos 1)` instead of
falling through to the raw wrapped-object `'object' object is not iterable`
failure. The covered single-invalid-key analogue path
`stdlib.itertools.permutations({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for permutations()`
instead of falling through to the raw wrapped-object `'object' object is not
iterable'` failure. The covered duplicate iterable analogue path
`stdlib.itertools.permutations(rows, { iterable: other_rows })` now also
raises Python 3.10.11's `argument for permutations() given by name
('iterable') and position (1)` instead of misrouting the second options
object into the wrapped `r` slot and surfacing `Expected int as r`. The
covered three-argument duplicate-binding analogue
`stdlib.itertools.permutations(rows, 2, { iterable: other_rows })` now also
raises Python 3.10.11's `permutations() takes at most 2 arguments (3 given)`
instead of leaking AutoHotkey's raw non-variadic call error before wrapper
translation can run. The covered positional-iterable plus second-options-object
analogue `stdlib.itertools.permutations(rows, { r: 1, extra: 1 })` now also
raises Python 3.10.11's `permutations() takes at most 2 arguments (3 given)`
instead of silently unwrapping the second object and discarding its unexpected
field. Generic plain-property-object shapes such as
`stdlib.itertools.permutations({ extra: 1 })` and
`stdlib.itertools.permutations({ r: 2, extra: 1 })` now also preserve Python
3.10.11's missing-`iterable` priority, while higher-cardinality plain keyword-
analogue shapes such as
`stdlib.itertools.permutations({ extra: 1, another: 2, third: 3 })` now raise
Python 3.10.11's `permutations() takes at most 2 keyword arguments (3 given)`
instead of collapsing to missing-required-argument fallbacks. Additional
second-argument property-object shapes such as
`stdlib.itertools.permutations(rows, { extra: 1 })` now also raise Python
3.10.11's `'extra' is an invalid keyword argument for permutations()`, while
shapes such as `stdlib.itertools.permutations(rows, { r: 2, extra: 1,
another: 2 })` now surface Python's dynamic given-count form
`permutations() takes at most 2 arguments (4 given)` instead of collapsing
distinct multi-key cases into the same fixed three-argument wrapper error. The
current wrapper now also merges covered split plain-object keyword analogues
across both argument slots before validation, so
`stdlib.itertools.permutations({ iterable: rows }, { r: 2 })` and
`stdlib.itertools.permutations({ r: 2 }, { iterable: rows })` yield the same
rows as local Python keyword calls, while split error-priority shapes such as
`stdlib.itertools.permutations({ extra: 1 }, { iterable: rows })`,
`stdlib.itertools.permutations({ iterable: rows }, { extra: 1 })`, and
`stdlib.itertools.permutations({ r: 2 }, { iterable: rows, extra: 1 })` now
follow Python's invalid-keyword and too-many-keywords branches instead of
misclassifying the second wrapper object as a positional `r` value.
Covered plain callable `Object` values that define their own `Call` now also
stay positional across `combinations(...)`,
`combinations_with_replacement(...)`, and `permutations(...)` even when they
carry keyword-like own properties such as `iterable` or `r`, so callable first
arguments still surface Python's iterable `TypeError` and callable second
arguments still stay on each function's integer-interpretation path instead of
being misclassified as AHK keyword-analogue wrappers.
Covered `accumulate(iterable, func := unset, initial := unset)` now also
accepts Python 3.10.11's covered `iterable=` / `func=` / `initial=` keyword
paths through the AHK options-object analogue, so calls like
`stdlib.itertools.accumulate({ iterable: rows })`,
`stdlib.itertools.accumulate(rows, { func: callable })`, and
`stdlib.itertools.accumulate({ iterable: rows, func: callable, initial: 10 })`
now yield the same accumulated output as Python, while mixed positional plus
`iterable=` duplicate binding raises the covered
`argument for accumulate() given by name ('iterable') and position (1)`
`TypeError` instead of falling through to raw object-iterable failures. The
covered duplicate `func=` shape
`stdlib.itertools.accumulate(rows, callable, { func: other_callable })` now
also raises Python 3.10.11's
`argument for accumulate() given by name ('func') and position (2)` instead of
misrouting the third options object into the `initial` slot.
Covered split keyword-wrapper duplicates now also follow Python 3.10.11's
multi-`**` merge priority before later positional/name and invalid-keyword
branches, so shapes such as
`stdlib.itertools.accumulate(rows, { func: callable }, { func: other_callable })`,
`stdlib.itertools.accumulate(rows, { initial: 10 }, { initial: 11 })`, and
`stdlib.itertools.accumulate(rows, { extra: 1 }, { extra: 2 })` raise
`TypeError("itertools.accumulate() got multiple values for keyword argument '...'")`
first. Mixed shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, extra: 1 }, { func: other_callable })`
and
`stdlib.itertools.accumulate(rows, { initial: 10, extra: 1 }, { initial: 11 })`
keep that same duplicate-name priority ahead of later invalid-keyword
handling.
The covered options-only analogue path now also matches Python 3.10.11's
missing-required-argument wording: `stdlib.itertools.accumulate({ func:
callable })` now raises `accumulate() missing required argument 'iterable'
(pos 1)` instead of falling through to the raw wrapped-object
`'object' object is not iterable` failure.
The covered single-extra-key analogue path
`stdlib.itertools.accumulate({ iterable: rows, extra: 1 })` now also raises
Python 3.10.11's `'extra' is an invalid keyword argument for accumulate()`
instead of being misclassified as a too-many-keyword error.
The covered extra-key analogue path
`stdlib.itertools.accumulate({ iterable: rows, func: callable, initial: 10,
extra: 1 })` now also raises Python 3.10.11's `accumulate() takes at most 3
keyword arguments (4 given)` instead of silently accepting the unexpected
field.
Covered plain property-object and positional-plus-second-object analogue paths
now also preserve Python 3.10.11's keyword-priority behavior. Options-only
shapes such as `stdlib.itertools.accumulate({ extra: 1 })` now keep Python's
missing-`iterable` priority instead of falling through to
`'object' object is not iterable`, while higher-cardinality options-only
shapes such as
`stdlib.itertools.accumulate({ extra: 1, another: 2, third: 3, fourth: 4 })`
now raise Python's observable
`accumulate() takes at most 3 keyword arguments (4 given)`. Covered
second-argument property-object shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, extra: 1 })` and
`stdlib.itertools.accumulate(rows, { initial: 10, extra: 1 })` now also raise
Python 3.10.11's `'extra' is an invalid keyword argument for accumulate()`,
while higher-cardinality shapes such as
`stdlib.itertools.accumulate(rows, { func: callable, initial: 10, extra: 1 })`
and
`stdlib.itertools.accumulate(rows, { iterable: other_rows, func: callable, initial: 10 })`
now raise Python's `accumulate() takes at most 3 arguments (4 given)` instead
of miscounting or prioritizing duplicate-name fallbacks too early. The covered
second-argument keyword analogue
`stdlib.itertools.accumulate(rows, { func: callable, initial: 10 })` now also
matches Python's accumulated output instead of dropping the keyword-style
`initial` value during parsing.
Covered `accumulate(iterable, func := unset, initial := unset)` now also
accepts exposed stdlib operator class methods such as `stdlib.operator.mul` as
direct callback arguments by rebinding the underlying AHK method implementation
to the exported `stdlib.operator` object before consumption, so
`stdlib.itertools.accumulate(rows, stdlib.operator.mul)` now yields the same
accumulated product rows as Python `itertools.accumulate(rows, operator.mul)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
The covered lazy callback-arity path now also matches Python 3.10.11 for
unary stdlib operator predicates reused as binary accumulate callbacks:
`stdlib.itertools.accumulate(rows, stdlib.operator.truth, { initial: 10 })`
now emits the covered initial value and then raises Python's observable
`_operator.truth() takes exactly one argument (2 given)` on the next pull
instead of leaking AutoHotkey's raw `Too many parameters passed to function.`
error from the bound method object.
Covered plain callable object values that define their own `Call` while also
carrying keyword-like own props such as `iterable`, `func`, `initial`, or
`extra` now likewise stay off the keyword-analogue path. Local Python 3.10.11
keeps `accumulate(callable_obj)` on the observable non-iterable `TypeError`,
keeps `accumulate(rows, callable_obj)` on the callable-function path, and
preserves callable object identity for covered `initial=` values. The direct
AHK surface now mirrors those covered slices, including the existing direct
trailing-`initial` analogue, so callable value objects no longer leak
`'Call' is an invalid keyword argument for accumulate()` or duplicate-binding
diagnostics merely because they expose keyword-like attributes.
Covered `starmap(func, iterable)` now also accepts exposed stdlib operator
class methods such as `stdlib.operator.add` as direct callback arguments by
rebinding the underlying AHK method implementation to the exported
`stdlib.operator` object before consumption, so
`stdlib.itertools.starmap(stdlib.operator.add, rows)` now yields the same
row-wise mapped output as Python `itertools.starmap(operator.add, rows)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `takewhile(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.takewhile(stdlib.operator.truth, rows)` now yields the same
prefix output as Python `itertools.takewhile(operator.truth, rows)` instead of
failing with AutoHotkey's raw missing-parameter method-call error.
Covered `dropwhile(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.dropwhile(stdlib.operator.truth, rows)` now yields the same
suffix output as Python `itertools.dropwhile(operator.truth, rows)` instead of
failing with AutoHotkey's raw missing-parameter method-call error.
Covered `filterfalse(predicate, iterable)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct predicate
arguments by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy consumption, so
`stdlib.itertools.filterfalse(stdlib.operator.truth, rows)` now yields the
same filtered output as Python `itertools.filterfalse(operator.truth, rows)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `groupby(iterable, key := unset)` now also accepts exposed stdlib
operator class methods such as `stdlib.operator.truth` as direct key
functions by rebinding the underlying AHK method implementation to the
exported `stdlib.operator` object before lazy grouping, so
`stdlib.itertools.groupby(rows, stdlib.operator.truth)` now yields the same
key/group boundaries as Python `itertools.groupby(rows, operator.truth)`
instead of failing with AutoHotkey's raw missing-parameter method-call error.
Covered `tee(iterable, n := 2)` now returns a tuple-like readonly array of
independent lazy clones, supports Python's `n=0/1/2` and bool-as-int behavior,
including root `stdlib.True` / `stdlib.False` count values, preserves
independent consumer positions through a shared cache instead of eager
materialization, skips iterable validation when `n=0` like local Python 3.10.11,
exposes the outer return container itself as a readonly tuple-like object rather
than a mutable array,
exposes a Python-style `<itertools._tee object at 0x...>` `__Repr()` shape for
covered tee clone objects, exposes a callable `clone.__class` provider so the
covered `_tee` type itself can be instantiated from an iterable or another tee
clone like local Python 3.10.11, and surfaces Python-style arity errors for
zero or more than two positional arguments, `ValueError("n must be >= 0")`,
integer-interpretation `TypeError` including root `stdlib.tuple()` count values,
no-keyword `TypeError("itertools.tee() takes no keyword arguments")` for the
AHK options-object analogue `{ n: value }`, the same covered no-keyword
`TypeError("itertools.tee() takes no keyword arguments")` path for the
options-only analogue `stdlib.itertools.tee({ n: 3 })`, the mixed positional
plus keyword-iterable analogue `stdlib.itertools.tee([1, 2], { iterable: [3, 4] })`,
and the three-argument analogue `stdlib.itertools.tee([1, 2], 2, { n: 3 })`, the matching
`TypeError("_tee() takes no keyword arguments")` path for the covered `_tee`
clone-type constructor when AHK passes the keyword analogue `{ iterable: ... }`
either by itself or alongside a positional iterable argument, and non-iterable
type-name parity for covered invalid inputs, including root `stdlib.True` /
`stdlib.False` iterable arguments as Python `bool`. Covered re-entry now also
matches local Python 3.10.11 by raising
`RuntimeError("cannot re-enter the tee iterator")` when a shared tee source
tries to advance another clone while an upstream pull is already active.
Covered plain `Object` iterables that define their own `__Enum` now also stay
positional even when they carry keyword-like own properties such as `n` or
`iterable`, so shapes like `stdlib.itertools.tee(iterable_obj)` mirror local
Python 3.10.11 instead of being misclassified as the AHK keyword-analogue path.
Covered plain callable `Object` values that define their own `Call` now also
stay positional even when they carry keyword-like own properties such as `n` or
`iterable`, so `stdlib.itertools.tee(callable_obj)` surfaces Python's iterable
`TypeError`, `stdlib.itertools.tee(rows, callable_obj)` surfaces Python's
integer-interpretation `TypeError`, and `stdlib.itertools.tee(rows, 2,
callable_obj)` keeps Python's at-most-two-arguments arity error instead of
falling into the AHK no-keyword analogue path.
Covered `chain.from_iterable(iterable)` now also rejects the mixed
positional-plus-keyword analogue path, so
`stdlib.itertools.chain.from_iterable(rows, { iterable: other })` raises
Python's observable `TypeError("chain.from_iterable() takes no keyword
arguments")` instead of falling through to the raw one-argument arity error.
Covered split-keyword `repeat(...)` parity now also matches local Python
3.10.11 for duplicate invalid names spread across two AHK keyword-wrapper
objects, so shapes like `stdlib.itertools.repeat({ extra: 1 }, { extra: 2 })`
raise `TypeError("itertools.repeat() got multiple values for keyword argument
'extra'")` before later missing-argument, invalid-keyword, or keyword-count
branches. The same priority now extends across three wrapper objects and
positional-plus-two-wrapper mixes: `stdlib.itertools.repeat({ object: "x" }, {
times: 3 }, { extra: 1 })` now raises the Python too-many-keyword branch
instead of the raw three-argument arity error, while
`stdlib.itertools.repeat("x", { times: 3 }, { times: 4 })` raises duplicate
`times` before later argument-count handling. Covered no-keyword `chain(...)`, `chain.from_iterable(...)`, and
`cycle(...)` parity now also matches local Python 3.10.11 for duplicate split
keyword names, so shapes like `stdlib.itertools.chain({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 })`, and
`stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })` raise the corresponding
Python duplicate-keyword `TypeError(...)` before later no-keyword or arity
branches, while `stdlib.itertools.chain.from_iterable(rows, 2, { extra: 1 })`
and `stdlib.itertools.cycle(rows, 3, { extra: 1 })` now also keep Python's
observable no-keyword priority ahead of the raw arity errors those call shapes
would otherwise reach.
Covered no-keyword `pairwise(...)`, `starmap(...)`, `takewhile(...)`,
`dropwhile(...)`, `filterfalse(...)`, and `tee(...)` parity now also matches
local Python 3.10.11 for duplicate split keyword names and late keyword
wrappers after extra positional arguments, so shapes like
`stdlib.itertools.pairwise({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.starmap({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.takewhile({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.dropwhile({ extra: 1 }, { extra: 2 })`,
`stdlib.itertools.filterfalse({ extra: 1 }, { extra: 2 })`, and
`stdlib.itertools.tee({ extra: 1 }, { extra: 2 })` now raise the corresponding
Python duplicate-keyword `TypeError(...)`, while later-keyword shapes such as
`stdlib.itertools.pairwise(rows, 3, { extra: 1 })`,
`stdlib.itertools.starmap(func, rows, 3, { extra: 1 })`,
`stdlib.itertools.takewhile(pred, rows, 3, { extra: 1 })`,
`stdlib.itertools.dropwhile(pred, rows, 3, { extra: 1 })`,
`stdlib.itertools.filterfalse(pred, rows, 3, { extra: 1 })`, and
`stdlib.itertools.tee(rows, 2, 3, { extra: 1 })` now also keep Python's
observable no-keyword priority ahead of the raw arity errors those call shapes
would otherwise reach.
Covered no-keyword `islice(...)` parity now also matches local Python 3.10.11
for duplicate split keyword names and late keyword wrappers after extra
positional arguments, so shapes like
`stdlib.itertools.islice({ extra: 1 }, { extra: 2 })` and
`stdlib.itertools.islice({ stop: 1 }, { stop: 2 })` now raise the
corresponding Python duplicate-keyword `TypeError(...)`, while
`stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })` keeps Python's
observable no-keyword priority ahead of the raw arity error the call shape
would otherwise reach. Covered `islice(...)` now also mirrors Python's
explicit `expected at least 2 arguments` / `expected at most 4 arguments`
wording for the 0-, 1-, and 5-argument forms.
Covered `tools\run-ahktest.ps1` discovery parity now also matches the observed
local pytest 7.4.3 duplicate-target policy: repeated explicit file targets are
collected again, repeated directory targets stay deduplicated, and mixed
directory-plus-file target lists still collect the explicit file a second time
without reloading the whole test script twice. The wrapper now tracks
per-include collected test ranges and duplicates those collected items to match
pytest's file-target semantics while leaving directory discovery de-duplication
in place. Wrapper self-tests and architecture bookkeeping were updated for the
promoted surface.
Covered `tools\run-ahktest.ps1` now also follows the observed local pytest
7.4.3 `testpaths` precedence slice through a manifest-backed AHK analogue:
when `-Target` is omitted, JSON `-Config` manifests may provide
`AhkTest.DiscoveryRoots` as default discovery targets resolved relative to the
config file, while an explicit wrapper `-Target` still overrides those manifest
roots entirely. Wrapper self-tests, examples, architecture notes, and framework
bookkeeping were updated for the promoted surface.
The current wrapper baseline after this slice is `stdlib/tests: 773 passed, 0
failed, 0 errors`.
More itertools functions remain deferred until their Python behavior matrices
are covered by ahktest tests.

The current root-level `stdlib.tuple(iterable?)` slice follows covered Python
3.10.11 builtin behavior by returning an empty readonly tuple-like value when
called without arguments, materializing strings and enumerable objects into a
readonly tuple-like object, preserving identity for existing stdlib tuple
instances, and surfacing Python-style non-iterable `TypeError` messages for
covered `NoneType`, `int`, `object`, and custom class inputs.

The current root-level `stdlib.True` / `stdlib.False` slice now acts as the
shared stdlib boolean singleton layer, analogous to `stdlib.None`: JSON
serialization and parsing paths consume and produce these same root-level
values, so callers can use `stdlib.True` / `stdlib.False` directly in
`stdlib.json.dumps(...)` input structures instead of routing through
module-specific boolean sentinels. `stdlib.json.True` / `stdlib.json.False`
remain available as aliases of those same root-level singleton values for
compatibility. Shared stdlib truthiness now also treats empty AHK arrays and
maps as false, matching the covered Python list/dict truthiness paths used by
`itertools.filterfalse(None, ...)` and `stdlib.json.Bool(...)`.

`stdlib.functools` is a first slice of Python 3.10.11 `functools`. It exposes
`reduce` and `partial` under `stdlib.functools`; the old global `reduce`,
`partial`, and `FuncTools` names from `functools\functools.ahk` are intentionally
not part of the direct surface. `reduce` follows Python's left-fold behavior,
initializer handling, empty-iterable `TypeError`, Python-style non-callable
argument type names (`int`, `object`, `bool`, `tuple`, custom leaf class names), plus Python's
dedicated `reduce() arg 2 must support iteration` message for non-iterable
second arguments; `partial` now uses Python 3.10.11's dedicated
`TypeError("type 'partial' takes at least one argument")` constructor message
for missing callable arguments, plus `TypeError("the first argument must be callable")`
for covered non-callable first arguments, and currently
covers positional argument binding through a callable AHK object and exposes the
Python 3.10 observable `func`, `args`, and `keywords` attributes, plus the
default `__module == "functools"` and exact default `__doc` text including
its trailing newline, plus a stable default empty `__dict` map for covered
fresh instances and Python-style dynamic attribute assignment that mirrors
assigned names into that stable map, including the flattened nested partial shape,
read-only metadata enforcement, and a stable readonly tuple-like object for `.args`, so
repeated metadata reads preserve object identity while item assignment attempts
fail with Python-style tuple mutation semantics instead of exposing a mutable
AHK array view; when a nested
`partial(partial_obj)` adds no new positional arguments, the wrapped object now
also preserves the original `.args` tuple identity instead of rebuilding a new
readonly view. Covered metadata assignment and deletion now follow the observed
local Python 3.10.11 behavior while exposing the AHK-style no-tail metadata
names `__module`, `__doc`, and `__dict`: `partial.__module` and `partial.__doc` may be reassigned, and
those overrides are now stored in the instance `__dict`, so covered reads of
`partial.__dict['__module']` / `['__doc']`, `partial.__reduce()`, and
`partial.__setstate(...)` all roundtrip the same metadata view. Replacing
`partial.__dict` with another map object now also clears those overrides and
falls back to the default `"functools"` / built-in doc string just like local
Python, while assigning non-dictionary values such as covered `int`, `list`, or
`NoneType` payloads still raises Python-style
`TypeError("__dict must be set to a dictionary, not a '...'")`. Deleting a
covered assigned `__module` or `__doc` entry now removes just that
`__dict` override and falls back to the default value, while deleting either
name again without an override now follows the observed local Python 3.10.11
shape and raises bare `AttributeError("__module")` /
`AttributeError("__doc")` instead of an object-qualified AHK property
message. Deleting `__dict` raises `TypeError("cannot delete __dict")`,
and dynamic attributes written through `partial.custom := ...` are mirrored
through `partial.__dict` and can be removed again with
`stdlib.base.delattr(...)` using Python-style missing-attribute errors after
deletion, so deleting the same covered dynamic name a second time now raises
bare `AttributeError("custom")` instead of an object-qualified AHK property
message, and reading the same missing dynamic name now also raises Python's
object-qualified `AttributeError("'functools.partial' object has no attribute 'custom'")`
instead of a host `PropertyError`. The current covered metadata slice now also
exposes AHK-style no-tail analogues for Python 3.10's observable partial reduce
/ setstate behavior: `partial.__reduce()` returns the
three-part tuple shape headed by the partial type and callable constructor
args, while `__setstate()` accepts covered Python-shaped `(func, args,
keywords, dict)` state tuples, updates the public `func` / `args` /
`keywords` / `__dict` metadata accordingly, now including covered
`__module` / `__doc` entries supplied through a mapping `dict` state,
Python 3.10's observable acceptance of `[]` and `()` as the state `dict`
payload, and `keywords=None` normalization back to an empty keyword dict, plus scalar
non-dictionary state payloads such as `5` preserved through `__dict`; covered
non-dictionary state payloads now also make later `__reduce()` calls raise
Python-style `SystemError("bad argument to internal function")`, and covered
dynamic attribute writes such as `partial.custom := 42` now also raise that
same Python-style `SystemError`; covered dynamic attribute reads such as
`partial.custom`, `partial.__module`, and `partial.__doc` on the same
scalar payload now also raise that same
Python-style `SystemError`; covered dynamic attribute deletes such as
`partial.DeleteProp("custom")`, `delattr(partial, "__module")`, and
`delattr(partial, "__doc")` on the same scalar payload now also raise that
same Python-style `SystemError` instead of leaking raw AHK property/method
errors; and uses Python-style
`TypeError` wording for the covered zero-argument and invalid-state failures
instead of missing-method or raw AHK parameter errors. The current covered
metadata slice also exposes Python-style
`partial.__Repr()` output for covered positional-partial cases so observable
repr text includes the underlying function name plus flattened bound positional
arguments. The covered repr slice now also follows Python string-literal
escaping for bound string arguments in covered backslash, newline, and quote
cases, plus Python literal shapes for covered bound `list`, `dict`, and
`None` values, root `stdlib.True` / `stdlib.False` values as Python `True` /
`False` literals for positional and observed keyword metadata, and Python-style
`<Type object at 0x...>` repr shapes for covered custom bound objects, and tuple
literal shapes such as `(1,)` when `partial.__Repr()` is observing the readonly
tuple-like `.args` metadata itself, plus Python-style `<function name at
0x...>` repr shapes when covered bound values are themselves callable function
objects, plus Python-style `name=value` keyword metadata in repr for covered
observed `.keywords` entries.
The current call slice now also consumes mutable `.keywords` map values at call
time for the covered direct AHK trailing-parameter shape, matching local Python
3.10.11's observable behavior where mutating `partial.keywords` changes later
calls while nested partials keep their copied keyword metadata. Full Python
keyword dispatch by parameter name remains constrained by AHK v2's callable
reflection surface and is still deferred.
`lru_cache`, `wraps`, `singledispatch`, and
comparison helpers remain deferred.

`stdlib.calendar` is a first slice of Python 3.10.11 `calendar`. It exposes
weekday/month constants, `IllegalMonthError`, `IllegalWeekdayError`, `isleap`,
`leapdays`, `weekday`, `monthrange`, `monthcalendar`, `firstweekday`, and
`setfirstweekday` under `stdlib.calendar`. The latest alphabetical pass slice
adds `day_name`, `day_abbr`, `month_name`, `month_abbr`, `weekheader(width)`,
`timegm(tuple)`, and the covered `Calendar(firstweekday := 0)` class surface:
`getfirstweekday()`, `iterweekdays()`, `itermonthdays(...)`,
`itermonthdays2(...)`, `itermonthdays3(...)`, `itermonthdays4(...)`,
`monthdayscalendar(...)`, and `monthdays2calendar(...)`. Fresh Python 3.10.11
evidence from `.codex/calendar_sequence_timegm_probe.py` and
`.codex/calendar_sequence_timegm_probe.output.json` confirmed the covered
names, week header text, Unix-second conversion, weekday iteration order, and
February 2024 month-grid shapes. Fresh AHK evidence includes focused red
`.codex/calendar-sequence-timegm-red-report.txt` failing because
`stdlib.calendar.weekheader` was absent, focused green
`.codex/calendar-sequence-timegm-green-focused-report.txt` passing 1/1, and
full module `.codex/calendar-sequence-timegm-final-green-report.txt` passing
`stdlib/tests/calendar.test.ahk` 5/5 at `TimeoutSeconds 90`; root smoke
`.codex/calendar-sequence-timegm-stdlib-focused-report.txt` passing 1/1; and
`.codex/calendar-sequence-timegm-validate-report.txt` validating
`stdlib/calendar.ahk`, `stdlib/tests/calendar.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/calendar.ahk` at
`TimeoutSeconds 90`. The direct module
follows Python's proleptic Gregorian behavior for covered cases, including year
0 in `monthrange`, and `monthcalendar` respects the module-level first weekday.
Formatting calendars, locale-specific names, `monthdatescalendar`, and
`yeardatescalendar` remain deferred.

`stdlib.time` is a first slice of Python 3.10.11 `time`. It exposes
`time()` and `time_ns()` under `stdlib.time`, returning Unix epoch seconds as
a Float and nanoseconds as an Integer derived from `A_NowUTC`, `A_MSec`, and
`DateDiff`. It also exposes `sleep(seconds)`, rejecting negative and
non-numeric durations before delegating to AutoHotkey's millisecond `Sleep`,
`monotonic()` / `monotonic_ns()` backed by `A_TickCount`, and
`perf_counter()` / `perf_counter_ns()` backed by `QueryPerformanceCounter`.
The current slice also
exposes `struct_time(sequence)`, `gmtime(seconds?)`, `localtime(seconds?)`,
`strftime(format, struct_time_or_tuple?)`, `asctime(struct_time_or_tuple?)`, and `ctime(seconds?)`.
`struct_time` is an enumerable tuple-like object with `tm_year` through
`tm_isdst` attributes; `gmtime` follows the local Python 3.10.11 Windows
runtime for covered Unix-second inputs, including fractional second flooring
and the observed pre-epoch boundary where `-86400` raises
`OSError("Invalid argument")`; `localtime` follows the same local runtime
baseline for covered inputs, including the current local offset and the
observed Windows behavior where negative Unix seconds raise
`OSError("Invalid argument")`; `strftime` currently supports a focused
directive set (`%Y`, `%m`, `%d`, `%H`, `%M`, `%S`, `%j`, `%w`, `%%`) over
`struct_time` inputs, root `stdlib.tuple(...)` values, or the current local
time when the tuple is omitted; and `asctime`/`ctime` currently emit Python-style fixed-width English
abbreviations over the covered `struct_time` and local-time inputs. Wider
directive coverage, timezone metadata, and clock-info APIs remain deferred.

`stdlib.warnings` is a first slice of Python 3.10.11 `warnings`. It exposes
`Warning`, `UserWarning`, `DeprecationWarning`, `warn`, `catch_warnings`,
`simplefilter`, and `resetwarnings` under `stdlib.warnings`. The old global
`Warning`, `UserWarning`, `DeprecationWarning`, `warn`, and warning registry
helpers from `warning\warning.ahk` are intentionally not part of the direct
surface. The first slice supports record-style warning capture through
`catch_warnings(true).Call(callback)`, category/source metadata, and
`simplefilter("error", category)` for warning-as-error behavior with
catch-scope filter restoration. It now has basic warning registries for
`default`, `module`, and `once` de-duplication, scoped to catch contexts when
recording warnings, and `warn(..., stacklevel)` records callsite-style
filename/line metadata for covered cases. Filter matching now covers warning
category subclasses and non-zero line-number predicates for direct warning
records. Full CPython filter precedence, formatting hooks, and deeper
integration with ahktest warning reporting remain deferred.

`stdlib.math` is a first slice of Python 3.10.11 `math`. It exposes
`pi`, `e`, `tau`, `floor`, `ceil`, `trunc`, `fabs`, `sqrt`, `factorial`,
`gcd`, `lcm`, `comb`, `perm`, `prod`, `fsum`, `degrees`, `radians`,
`dist`, `hypot`, and `isclose` under `stdlib.math`. It intentionally does
not export the legacy global `Math` class or bare functions from
`math\math.ahk`; internal helpers use the `AhkStdlibMath...` prefix to
avoid shared global namespace collisions. The direct slice now uses a
partials-based `fsum`, scaled `hypot`/`dist` calculations, and iterable
`dist` inputs for covered Python numeric edge cases. `inf`, `nan`, and the
rest of Python's floating-special behavior remain deferred until the project
has a consistent AHK representation for those values.

`stdlib.random` is a first slice of Python 3.10.11 `random`. It uses an
internal MT19937 implementation rather than AutoHotkey's built-in `Random()`,
and exposes deterministic module-level `seed(...)`, `random()`,
`getrandbits(k)`, `randrange(...)`, `randint(a, b)`, `choice(sequence)`,
`choices(population, weights?, cum_weights?, k?)`, `sample(population, k)`,
`shuffle(array)`, and `uniform(a, b)` under `stdlib.random`. The AHK
`choices` signature uses positional optional arguments because AutoHotkey has
no Python keyword-only call syntax. The initial slice
matches Python 3.10.11 integer seed fixtures for `random()`, `getrandbits`,
`randrange`, `randint`, `choice`, weighted/equal `choices`, `sample`, and
`shuffle`. Covered `choices(..., k)` and `sample(..., k)` now also accept
root `stdlib.True` / `stdlib.False` as Python bool-as-int `1` / `0` inputs
instead of rejecting them as foreign AHK object types. Covered
`choice(mapping)` now also follows local Python 3.10.11's observable
subscriptable-mapping branch for `Map` and `Map` subclasses, so
`stdlib.random.choice(Map("a", 1))` and equivalent dict-like subclasses now
raise `KeyError(0)` instead of falling through to the generic
`'... object is not subscriptable'` `TypeError`. Covered `choice(...)` and
`choices(..., k)` now also accept custom sequence-protocol objects that expose
AHK `__Len` and `__Item`, matching local Python 3.10.11's observable support
for non-list, non-string sequence objects such as `random.choice(custom_seq)`
and `random.choices(custom_seq, k=4)`, while `sample(...)` intentionally keeps
Python 3.10.11's stricter `Population must be a sequence...` rejection for
that same custom object shape. Covered readonly-sequence `shuffle(...)`
rejections now also use Python 3.10.11 type names for the observed string and
root `stdlib.tuple(...)` shapes, so `stdlib.random.shuffle("ab")` raises
`'str' object does not support item assignment` and
`stdlib.random.shuffle(stdlib.tuple([1, 2]))` raises
`'tuple' object does not support item assignment` instead of leaking host
AHK type names. String/bytes seed
expansion, `Random` instances, state
import/export, and distribution helpers remain deferred.

`stdlib.csv` is a Python 3.10.11 `csv` slice. It exposes dialect constants,
`Error`, `get_dialect()`, `list_dialects()`, `reader(...)`, `writer(...)`,
`DictReader(...)`, `DictWriter(...)`, `field_size_limit(...)`, and
`Sniffer()` under `stdlib.csv`.
Readers accept strings or line arrays and are enumerable through AHK `for`;
`reader(...)` is stateful like Python's reader iterator, treats array entries as
physical input lines, and updates `line_num` as rows are consumed.
writers accumulate output in `.text` because `io.StringIO` is not direct yet.
The direct reader supports quoted fields, embedded newlines, `escapechar`, and
`QUOTE_NONNUMERIC` float conversion for unquoted fields; the direct writer
supports minimal/all/none/nonnumeric quoting for the covered AHK value types,
with `writerows(...)` writing rows without returning a character count like
Python 3.10. The latest promoted slice adds `field_size_limit(...)` and
`Sniffer()`: fresh CPython 3.10.11 probe
`.codex/csv_sniffer_field_size_probe.py` plus JSON output confirmed the
default field limit `131072`, old-limit return values during set/restore,
`csv.Error("field larger than field limit (5)")`, `Sniffer.sniff(...)`
delimiter inference for semicolon, tab, and restricted pipe delimiters,
`Sniffer.has_header(...)` true/false basics, and
`csv.Error("Could not determine delimiter")`; focused red
`.codex/csv-sniffer-field-size-red-report.txt` failed because
`stdlib.csv.field_size_limit` was absent; focused green
`.codex/csv-sniffer-field-size-green-focused-report.txt` passed 1/1; full
module `.codex/csv-sniffer-field-size-final-green-report.txt` passed
`stdlib/tests/csv.test.ahk` 20/20 at `TimeoutSeconds 90`; root smoke
`.codex/csv-sniffer-field-size-stdlib-focused-report.txt` passed 1/1;
validation `.codex/csv-sniffer-field-size-validate-report.txt` passed
`stdlib/csv.ahk`, `stdlib/tests/csv.test.ahk`,
`stdlib/tests/stdlib.test.ahk`, and `stdlib/examples/csv.ahk` at
`TimeoutSeconds 90`. Because the current AHK reader eagerly parses in its
constructor, covered field-size-limit failures occur during
`stdlib.csv.reader(...)` construction rather than at first row iteration.
Fuller `DictReader` lifecycle/default handling, full Sniffer heuristics, and
strict-mode edge cases such as text after a closing quote remain deferred.

`stdlib.configparser` is a first slice of Python 3.10.11 `configparser`. It
exposes `ConfigParser()` plus the exception classes `Error`,
`NoSectionError`, `NoOptionError`, `DuplicateSectionError`, and
`MissingSectionHeaderError` under `stdlib.configparser`. The initial slice
covers `read_string(...)`, `sections()`, `has_section(...)`, `add_section(...)`,
`get(...)`, `getint(...)`, `getfloat(...)`, `getboolean(...)`, `set(...)`,
`remove_option(...)`, `remove_section(...)`, `options(...)`,
`has_option(...)`, default lower-casing of option names with case-insensitive
option access, item-style section access through `parser["section"]["option"]`,
ordered `items(section)` results, and ordered `options(section)` results for
covered INI text, including DEFAULT-aware parser-level merge order where
`items("Server")` emits default keys first with local overrides and
`options("Server")` emits local keys before inherited defaults, plus
SectionProxy fallback for `parser["section"]["option"]`, `items()`, `keys()`,
and `values()` with inherited defaults visible in the section view. Covered
`getint(section, option)` now preserves the same
`NoOptionError` / `NoSectionError` precedence as `get(...)` and raises
`ValueError("invalid literal for int() with base 10: '...'")` for invalid
integer text. Covered `getfloat(section, option)` now follows observed Python
3.10.11 float parsing for valid numeric text, preserves the same
`NoOptionError` / `NoSectionError` precedence as `get(...)`, and raises
`ValueError("could not convert string to float: '...'")` for invalid float
text. Covered `set(section, option, value)` now also matches the observed
Python 3.10.11 value-type guard by accepting only string option values,
raising `TypeError("option values must be strings")` before section lookup for
non-string values, while still preserving `NoSectionError` for missing sections
when the passed value itself is a string. Covered `has_option(section, option)`
now follows observed Python 3.10.11 missing-section behavior by returning
`False`, while covered `options(section)` still raises `NoSectionError` for a
missing section. A first covered `DEFAULT` slice now treats `[DEFAULT]` as a
special parser section instead of a normal named section: `sections()` excludes
it, `has_section("DEFAULT")` stays false, `get("Server", option)` and
`has_option("Server", option)` can read defaulted options, `get("DEFAULT",
option)` reads the default option set directly, and `add_section("DEFAULT")`
raises `ValueError("Invalid section name: 'DEFAULT'")`. DEFAULT-aware section
view removal now allows `remove_option("DEFAULT", option)` to mutate fallback
state for other sections, while DEFAULT-aware section view mutation edge cases,
file-based
`read`/`write`, interpolation/fallback arguments, custom option-normalization
controls, and the broader CPython parser edge-case matrix remain deferred.

`stdlib.io` is a first slice of Python 3.10.11 `io`. It exposes
`StringIO(...)`, `BytesIO(...)`, plus the `SEEK_SET`, `SEEK_CUR`, and
`SEEK_END` constants under `stdlib.io`. The text slice covers in-memory
`StringIO` streams with `getvalue()`, `read(...)`, `readline(...)`,
`write(...)`, `seek(...)`, `tell()`, `truncate(...)`, `close()`, and the
`closed` flag, including Python-style closed-stream errors, default `None`
initial value handling, cur/end-relative seek restrictions, and NUL-padding
when writing beyond the end of the current buffer. The byte slice uses AHK
arrays of integers in the range 0..255 as the public bytes representation and
covers `BytesIO` construction from `None`, arrays, and `Buffer`, `getvalue()`,
`read(...)`, `readline(...)`, `readlines(...)`, `write(...)`, Python-style
`SEEK_SET`/`SEEK_CUR`/`SEEK_END`, `tell()`, `truncate(...)`, `close()`,
`read1(...)`, `readinto(...)`, `readinto1(...)`, `writelines(...)`, `readable()`,
`writable()`, `seekable()`, `isatty()`, `flush()`, `fileno()` /
`detach()` unsupported-operation errors, and `closed` errors.
Newline-translation controls, text-wrapper classes, `getbuffer()` /
memoryview parity, and file-backed stream abstractions remain deferred.

2026-06-07 `stdlib.io.BytesIO` promotion: fresh Python 3.10.11 evidence from
`.codex/io_bytesio_probe.py` and `.codex/io_bytesio_probe.output.json`
records construction, read/readline/readlines, write overwrite and NUL padding,
seek/truncate behavior, closed-stream errors, and key invalid-argument
messages. Focused red `.codex/io-bytesio-red-report.txt` failed because
`stdlib.io.BytesIO` was absent; focused green
`.codex/io-bytesio-green-focused-report.txt` passed 3/3; final module gate
`.codex/io-bytesio-final-module-report.txt` passed `stdlib/tests/io.test.ahk`
6/6; root smoke `.codex/io-bytesio-root-focused-report.txt` passed 1/1; and
captured example `.codex/io-bytesio-example-report.txt` passed 1/1 without
warning/error output. The same slice was wired into Pillow file-like examples
and tests so built-in PNG/BMP/JPEG save/open now use the shared
`stdlib.io.BytesIO` surface instead of local ad-hoc memory stream classes.

2026-06-07 `stdlib.io.BytesIO` file-like unification: fresh Python 3.10.11
evidence from `.codex/io_bytesio_filelike_probe.py` and
`.codex/io_bytesio_filelike_probe.output.json` records `readable()`,
`writable()`, `seekable()`, `isatty()`, `flush()`, `read1(...)`,
`readinto(...)`, `writelines(...)`, `fileno()` / `detach()` unsupported
operation errors, closed-stream errors for capability probes/flush, and key
invalid-argument messages. Focused red
`.codex/io-bytesio-filelike-red-report.txt` failed because `BytesIO` lacked
`readable()`; focused green `.codex/io-bytesio-filelike-green-focused-report.txt`
and final module gate `.codex/io-bytesio-filelike-final-module-report.txt`
passed `stdlib/tests/io.test.ahk` 7/7; captured example gate
`.codex/io-bytesio-filelike-example-report.txt` passed 1/1 without
warning/error output. This keeps `stdlib.io.BytesIO` as the shared in-memory
binary stream for Pillow and later file-like stdlib modules.
Pillow regression evidence includes
`.codex/pillow-bytesio-filelike-focused-report.txt` passing 3/3,
`.codex/pillow-open-builtin-formats-final-focused-report.txt` passing 1/1,
`.codex/pillow-bytesio-final-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 62/62, and
`.codex/pillow-bytesio-final-example-report.txt` passing the captured example
without warning/error output.

2026-06-07 `stdlib.io.BytesIO` `readinto1(...)` unification: fresh Python
3.10.11 evidence from `.codex/io_bytesio_filelike_probe.py` and
`.codex/io-bytesio-readinto1-probe.output.json` records that
`io.BytesIO.readinto1(bytearray(3))` returns `3`, writes the next three bytes,
and advances the stream position to `3`. Focused red
`.codex/io-bytesio-readinto1-red-report.txt` failed because
`AhkStdlibIoBytesIO` had no `readinto1` method; focused green
`.codex/io-bytesio-readinto1-green-focused-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`; captured example gate
`.codex/io-bytesio-readinto1-example-report.txt` passed 1/1 through
`AhkTest.CaptureFixture().RunArgs(..., ["/ErrorStdOut=UTF-8", examplePath])`
without warning/error output and with explicit pollution assertions. This keeps
`readinto(...)` and `readinto1(...)` available through the same shared
`stdlib.io.BytesIO` object for Pillow-style file-like consumers.

2026-06-07 `stdlib.io.BytesIO` user-requested unification confirmation:
fresh Python 3.10.11 probes `.codex/io_bytesio_probe.py` and
`.codex/io_bytesio_filelike_probe.py` were rerun to
`.codex/io-bytesio-user-fresh-probe.output.json` and
`.codex/io-bytesio-filelike-user-fresh-probe.output.json`, confirming the
covered construction, read/write/seek/tell/truncate, line reading, file-like
capability, `read1(...)`, `readinto(...)`, `readinto1(...)`, `writelines(...)`,
unsupported-operation, closed-stream, and invalid-argument behavior. Serial
AHK gate `.codex/io-bytesio-user-module-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`; captured example gate
`.codex/io-bytesio-user-example-report.txt` loaded `stdlib/examples/io.ahk`
without warning/error output; and README/example pollution scan for
`System.Text.RegularExpressions` / `MatchEvaluator` was clean. Pillow file-like
tests and examples continue to use `stdlib.io.BytesIO(...)` directly, so no
separate Pillow-local memory stream was introduced for byte APIs.

2026-06-07 `stdlib.io.BytesIO` current unification recheck: fresh Python
3.10.11 probes `.codex/io_bytesio_probe.py` and
`.codex/io_bytesio_filelike_probe.py` were rerun to
`.codex/io-bytesio-current-unification-probe.output.json` and
`.codex/io-bytesio-current-filelike-probe.output.json`. The covered behavior
remains construction from `None`/arrays/`Buffer`, `getvalue()`, read/write
positioning, line reads, `seek(...)` / `tell()` / `truncate(...)`, file-like
capability helpers, `read1(...)`, `readinto(...)`, `readinto1(...)`,
`writelines(...)`, unsupported-operation errors, closed-stream errors, and key
invalid-argument messages. Serial AHK gate
`.codex/io-bytesio-current-module-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`; captured example gate
`.codex/io-bytesio-current-example-report.txt` passed 1/1 through
`tools/run-ahktest.ps1 -Target .codex/io_example_capture.test.ahk
-TimeoutSeconds 90` without warning/error output and with explicit
 `System.Text.RegularExpressions` / `MatchEvaluator` pollution assertions. This
confirms `stdlib.io.BytesIO(...)` as the shared in-memory byte stream before
continuing Pillow file-like and codec work.

2026-06-07 `stdlib.io.BytesIO` pre-Pillow unification gate: per the latest
library-ordering requirement, the shared `BytesIO` surface was rechecked before
continuing image work. Fresh Python 3.10.11 probes `.codex/io_bytesio_probe.py`
and `.codex/io_bytesio_filelike_probe.py` were rerun to
`.codex/io-bytesio-user-request-probe.output.json` and
`.codex/io-bytesio-user-request-filelike-probe.output.json`. Serial AHK gate
`.codex/io-bytesio-user-request-module-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`, and captured example
gate `.codex/io-bytesio-user-request-example-report.txt` passed
`.codex/io_example_capture.test.ahk` 1/1 without warning/error output and with
the explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. No separate Pillow-local byte stream is needed; future Pillow and
file-like stdlib slices should consume `stdlib.io.BytesIO(...)` directly.

2026-06-08 `stdlib.io.BytesIO` Pillow-front unification recheck: before
resuming Pillow implementation work, the shared `BytesIO` layer was reverified
as the single in-memory byte stream. Fresh Python 3.10.11 probes
`.codex/io_bytesio_probe.py` and `.codex/io_bytesio_filelike_probe.py` were
rerun to `.codex/io-bytesio-pre-pillow-unification-probe.output.json` and
`.codex/io-bytesio-pre-pillow-filelike-probe.output.json`, preserving the
covered construction, read/write/seek/tell/truncate, line-reading,
file-like capability, `read1(...)`, `readinto(...)`, `readinto1(...)`,
`writelines(...)`, unsupported-operation, closed-stream, and invalid-argument
behavior. Serial AHK gate `.codex/io-bytesio-pre-pillow-module-report.txt`
passed `stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`; captured example
gate `.codex/io-bytesio-pre-pillow-example-report.txt` passed
`.codex/io_example_capture.test.ahk` 1/1 through `tools/run-ahktest.ps1`
without warning/error output and with explicit `System.Text.RegularExpressions`
/ `MatchEvaluator` pollution assertions. This keeps Pillow file-like work and
later stdlib file-like slices on `stdlib.io.BytesIO(...)` instead of separate
module-local byte stream implementations.

2026-06-08 `stdlib.io.BytesIO` stdlib-unification confirmation: before
continuing Pillow and the alphabetical stdlib pass, the shared byte stream
surface was rechecked as the canonical in-memory file-like object. Fresh local
Python 3.10.11 probes `.codex/io_bytesio_probe.py` and
`.codex/io_bytesio_filelike_probe.py` were rerun to
`.codex/io-bytesio-stdlib-unify-fresh-probe.output.json` and
`.codex/io-bytesio-stdlib-unify-filelike-fresh-probe.output.json`. Serial AHK
gate `.codex/io-bytesio-stdlib-unify-module-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7 at `TimeoutSeconds 90`, and captured example
gate `.codex/io-bytesio-stdlib-unify-example-report.txt` passed
`.codex/io_example_capture.test.ahk` 1/1 without warning/error output and with
the explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. The covered surface remains `BytesIO(...)`, `getvalue()`,
`read(...)`, `readline(...)`, `readlines(...)`, `read1(...)`,
`readinto(...)`, `readinto1(...)`, `write(...)`, `writelines(...)`,
`seek(...)`, `tell()`, `truncate(...)`, `flush()`, capability probes, close
state, unsupported-operation errors, and key invalid-argument paths.

2026-06-08 `stdlib.io.BytesIO` shared-API recheck before Pillow continuation:
the user-requested unification step was confirmed before adding more image
surface. Fresh local Python 3.10.11 probes `.codex/io_bytesio_probe.py` and
`.codex/io_bytesio_filelike_probe.py` were rerun to
`.codex/io-bytesio-stdlib-io-unify-fresh-probe.output.json` and
`.codex/io-bytesio-stdlib-io-unify-filelike-fresh-probe.output.json`.
Focused AHK gate `.codex/io-bytesio-stdlib-io-unify-focused-report.txt` passed
the four `StdlibIoTest.TestBytesIO*` tests 4/4 at `TimeoutSeconds 90`; serial
module gate `.codex/io-bytesio-stdlib-io-unify-module-report.txt` passed
`stdlib/tests/io.test.ahk` 7/7; and captured example gate
`.codex/io-bytesio-stdlib-io-unify-example-report.txt` passed
`.codex/io_example_capture.test.ahk` 1/1 without warning/error output and with
explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. No new implementation was needed in this checkpoint because
`stdlib.io.BytesIO(...)` was already the public shared in-memory byte-stream
entry; historical introduction red evidence remains
`.codex/io-bytesio-red-report.txt` and file-like/readinto1 red evidence remains
`.codex/io-bytesio-filelike-red-report.txt` /
`.codex/io-bytesio-readinto1-red-report.txt`.

2026-06-08 `stdlib.io.BytesIO` current requested unification: before resuming
Pillow work, a fresh local Python 3.10.11 probe
`.codex/io_bytesio_current_unification_probe.py` generated
`.codex/io-bytesio-current-unification-20260608-probe.output.json`, confirming
the covered construction, read/write position flow, line reads, relative
`seek(...)`, `truncate(...)`, file-like capability, `readinto(...)`,
`readinto1(...)`, `writelines(...)`, unsupported-operation errors, closed-file
errors, and invalid-argument messages. Focused AHK gate
`.codex/io-bytesio-current-unification-20260608-focused-report.txt` passed the
four `StdlibIoTest.TestBytesIO*` tests 4/4 at `TimeoutSeconds 90`; serial
module gate `.codex/io-bytesio-current-unification-20260608-module-report.txt`
plus `.codex/io-bytesio-current-unification-20260608-module.json` passed
`stdlib/tests/io.test.ahk` 7/7; and captured example gate
`.codex/io-bytesio-current-unification-20260608-example-report.txt` passed
`.codex/io_example_capture.test.ahk` 1/1 without warning/error output and with
explicit `System.Text.RegularExpressions` / `MatchEvaluator` pollution
assertions. No implementation change was needed in this checkpoint because
`stdlib.io.BytesIO(...)` is already the shared public in-memory byte stream.

`stdlib.shutil` is a first slice of Python 3.10.11 `shutil`. It exposes
`Error`, `SameFileError`, `copyfile(...)`, `copy(...)`, `move(...)`, and
`rmtree(...)` under `stdlib.shutil`. The initial slice covers real filesystem
copy/move/remove behavior against `stdlib.pathlib.Path` or string paths,
returns destination path strings like Python for the covered operations, raises
`SameFileError` for same-file `copyfile(...)`, treats missing sources and
missing destination parents as `OSError` with Python-style "No such file or
directory" messages, and treats directory use with `copyfile(...)` as
permission-denied `OSError` behavior. Metadata-copy helpers, ignore callbacks,
symlink policy, `copytree`, archive helpers, and the broader CPython callback
and permission edge-case matrix remain deferred.

`stdlib.json` is a first slice of Python 3.10.11 `json`. AHK v2 has no
distinct Boolean type: local docs define `true` and `false` as built-in
variables containing the integers `1` and `0`. Because of that, `dumps(true)`
and `dumps(1)` are not distinguishable at runtime. The direct module therefore
uses the shared root-level special values `stdlib.True` and `stdlib.False` for
guaranteed JSON `true`/`false` output while still preserving integer
serialization for plain `1` and `0`; `stdlib.json.True`, `stdlib.json.False`,
and `stdlib.json.Bool(value)` remain as module-level aliases/helpers over the
same root boolean singletons. The
direct serializer follows Python's default separators and `ensure_ascii=True`
escaping for covered BMP and supplementary-plane Unicode characters, and
surrogate-pair escapes load back to the equivalent AHK supplementary
character representation. Broader
CPython options such as configurable separators, `sort_keys`, `indent`,
`allow_nan`, and `JSONDecodeError` remain deferred.

`stdlib.re` is a first slice of Python 3.10.11 `re`. It exposes
`ASCII`/`A`, `IGNORECASE`/`I`, `MULTILINE`/`M`, `DOTALL`/`S`,
`VERBOSE`/`X`, `compile`, `search`, `match`, `fullmatch`, `findall`, and
`sub` under `stdlib.re`. Match objects expose zero-based Python-style
`group(...)`, `groups(...)`, `groupdict(...)`, `start(...)`, `end(...)`, and
`span(...)` helpers. Internally it uses AutoHotkey PCRE through `RegExMatch`
and `RegExReplace`, converting AHK's 1-based positions to Python's zero-based
half-open spans. Default string matching injects PCRE Unicode properties so
basic word-class behavior is closer to Python 3; `ASCII` disables that. Bytes
patterns, locale/debug flags, `split`, `finditer`, scanner APIs, `pos`/`endpos`,
callable replacements, and richer exception-class parity remain deferred.

`stdlib.statistics` exposes a Python-like `StatisticsError` class object
as `stdlib.statistics.StatisticsError`, backed by the internal
AHK-prefixed `AhkStdlibStatisticsError` global. The direct API currently
accepts AHK arrays and custom enumerable objects as iterable inputs, supports
the Python 3.10 optional known-mean parameters for `pvariance`, `variance`,
`pstdev`, and `stdev`, and follows Python 3.10.11 messages for the covered
empty/singleton error cases.

`stdlib.tempfile` is a first slice of Python 3.10.11 `tempfile` focused on
temporary directories. It exposes `gettempdir()`, `gettempprefix()`,
`mkdtemp(suffix?, prefix?, dir?)`, and `TemporaryDirectory(...).cleanup()`.
The Python 3.10 behavior where an explicit relative `dir` returns a relative
created path is preserved; this intentionally differs from newer Python
versions that make `mkdtemp()` absolute.

2026-06-06 no-tail magic surface sweep: AHK-visible pseudo-magic members now
follow the AutoHotkey convention of a leading double underscore without the
Python trailing double underscore. The swept runtime/test/example surface now
uses names such as `__name`, `__dict`, `__module`, `__doc`,
`__isabstractmethod`, `__func`, `__members`, `__class`, `__version`,
`__copy`, `__deepcopy`, `__enter`, `__exit`, `__reduce`, `__setstate`,
`__len`, `__iadd`, `__imul`, and `__rmul`. Python-style names that remain in
the tree are CPython diagnostic or baseline text such as `__init__`,
`__index__`, and `__length_hint__`, not AHK-visible stdlib member names.
Fresh gate evidence for the sweep: `.codex/magic-names-array-red-report.txt`
failed before implementation because `__iadd` was absent; focused green
`.codex/magic-names-array-green-focused-report.txt` passed 1/1; affected
module gates passed `array` 23/23, `copy` 3/3, `contextlib` 3/3, `decimal`
7/7, `functools` 32/32, `abc` 6/6, `enum` 2/2, `types` 4/4, `csv` 20/20,
`collections` 64/64, `itertools` 233/233, and `thread` 29/29 at
`TimeoutSeconds 90`; root smoke `.codex/magic-names-stdlib-root-report.txt`
passed 233/233; example captures passed `abc`, `array`, `contextlib`, `copy`,
`decimal`, `enum`, `functools`, and `itertools`; full-tree validation
`.codex/magic-names-validate-report.txt` passed; framework/layout gates and
README pollution scans passed. The aggregate full-suite run
`.codex/magic-names-full-suite-report.txt` timed out at 90 seconds and is not
claimed as green. A follow-up guard added on 2026-06-06 pins Python-visible
metadata names to the same AHK no-tail convention: `types.ModuleType` exposes
`__name` / `__doc` but not `__name__` / `__doc__`, `enum.Enum` exposes
`__name` / `__members` and enum members expose `__class` but not their
trailing-dunder forms, and `functools.partial` exposes `__module`, `__doc`,
and `__dict` but not `__module__`, `__doc__`, or `__dict__`. Fresh focused
gates passed `types` 4/4, `enum` 2/2, and `functools` 32/32 through
`tools\run-ahktest.ps1 -AhkExe ..\AutoHotkey.exe -TimeoutSeconds 90`.

2026-06-07 Pillow registered open dispatch follow-up: fresh local Python
3.10.11 + Pillow 11.3.0 evidence from
`.codex/pillow_image_open_registry_probe.py` and
`.codex/pillow_image_open_registry_probe.output.json` confirms that
`Image.open(path, "r", formats)` reads the first 16 bytes as a prefix, calls
registered `accept(prefix)` handlers in format order, treats a string accept
result as a warning rather than acceptance, seeks the file object back to zero
before `factory(fp, filename)`, and preserves normal file-not-found behavior
before plugin dispatch. The AHK surface now routes `stdlib.pillow.Image.open`
through registered `OPEN` handlers when a handler accepts, while falling back to
the existing WIC decode path for ordinary PNG/BMP/JPEG-style opens. Fresh AHK
evidence includes focused red `.codex/pillow-image-open-registry-red-report.txt`
failing before `Image.open(..., mode, formats)` existed, focused green
`.codex/pillow-image-open-registry-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-open-registry-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 57/57, and the captured pillow example gate after
example sync. This is registered plugin open dispatch coverage; it does not
claim arbitrary Pillow decoder parity or benchmark-backed Pillow performance
parity.

The registered open file-like follow-up extends the same Pillow 11.3.0
`Image.open` dispatch slice to objects that provide `read`, `seek`, and `tell`.
The existing fresh Python probe records `io.BytesIO` behavior: filename passed
to the factory is an empty string, Pillow seeks the object to zero before
factory invocation, factory `read(7)` leaves the caller-owned stream at offset
7, and `_exclusive_fp` is false. The AHK registered-open path now detects such
file-like objects, leaves ownership with the caller, and still keeps ordinary
path opens on the WIC fallback when no registered handler accepts. Fresh AHK
evidence includes `.codex/pillow-image-open-filelike-red-report.txt` failing
because `FileExist` received a file-like object, focused green
`.codex/pillow-image-open-filelike-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-open-filelike-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 57/57, and captured example
`.codex/pillow-image-open-filelike-example-report.txt` passing 1/1.

The Pillow registry id normalization follow-up uses fresh local Python 3.10.11
plus Pillow 11.3.0 evidence from `.codex/pillow_image_registry_case_probe.py`
and `.codex/pillow_image_registry_case_probe.output.json` confirming that format
ids passed to `register_open`, `register_save`, `register_save_all`,
`register_extension`, and `register_mime` are normalized to uppercase registry
ids, while decoder/encoder names remain exact names. The AHK surface now stores
custom `SAVE`, `SAVE_ALL`, extension, and MIME format ids under uppercase keys,
so lowercase custom format registration matches extension-derived saves,
explicit lowercase `save(..., format)`, and `save_all` routing. Fresh AHK
evidence includes `.codex/pillow-image-registry-case-red-report.txt` failing
because `registered_extensions()` returned a lowercase id, focused green
`.codex/pillow-image-registry-case-green-focused-report.txt` passing 1/1,
module `.codex/pillow-image-registry-case-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 58/58, and captured example
`.codex/pillow-image-registry-case-example-report.txt` passing 1/1.

The registered save file-like follow-up extends Pillow 11.3.0 custom
`Image.save` registry dispatch to caller-owned objects with `write(...)`.
Fresh local Python evidence from `.codex/pillow_image_save_filelike_probe.py`
and `.codex/pillow_image_save_filelike_probe.output.json` confirms that
`image.save(fp, format)` passes `filename == ""`, exposes matching
`encoderinfo` and `_default_encoderinfo`, routes `save_all=True` and
`append_images` to `SAVE_ALL`, preserves already-written bytes on handler
exceptions, requires an explicit format when no filename/extension exists, and
does not close caller-owned file-like objects. The AHK surface now detects such
file-like save targets for registered custom handlers, passes the original
object to the handler, and only closes internally-created path wrappers. Fresh
AHK evidence includes `.codex/pillow-save-filelike-red-report.txt` failing
because `FileExist` received a file-like object, focused green
`.codex/pillow-save-filelike-green-focused-report.txt` passing 1/1, module
`.codex/pillow-save-filelike-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 59/59, and captured example
`.codex/pillow-save-filelike-example-report.txt` passing 1/1.

The built-in save file-like follow-up extends the Windows GDI+ encoder path to
caller-owned `write(...)` targets for explicit `PNG`, `BMP`, and `JPEG`
formats. Fresh local Python evidence from
`.codex/pillow_image_save_builtin_filelike_probe.py` and
`.codex/pillow_image_save_builtin_filelike_probe.output.json` records Pillow
11.3.0 `BytesIO` behavior: each save returns `None`, writes format-specific
headers, advances the stream position to the byte length, leaves the stream
open, and still raises `ValueError("unknown file extension: ")` when no format
or filename-derived extension exists. The AHK surface now uses the system GDI+
`GdipSaveImageToStream` API with an in-memory `IStream` / `HGLOBAL`, copies the
encoded bytes into the caller's `write(...)` target, and keeps ordinary path
saves on `GdipSaveImageToFile`. Fresh AHK evidence includes
`.codex/pillow-save-builtin-filelike-red-report.txt` failing because
`GdipSaveImageToFile` expected a string path, focused green
`.codex/pillow-save-builtin-filelike-green-focused-report.txt` passing 1/1,
module `.codex/pillow-save-builtin-filelike-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 60/60, and captured example
`.codex/pillow-save-builtin-filelike-example-report.txt` passing 1/1.

The built-in open file-like follow-up completes the PNG/BMP/JPEG memory I/O
round trip for caller-owned objects with `read`, `seek`, and `tell`. Fresh
local Python evidence from `.codex/pillow_image_open_builtin_filelike_probe.py`
and `.codex/pillow_image_open_builtin_filelike_probe.output.json` records
Pillow 11.3.0 `BytesIO` behavior for PNG alpha preservation, BMP/JPEG RGB
decode, stream ownership, and invalid-input `cannot identify image file`
errors. The AHK surface now feeds file-like bytes to WIC through
`CreateStreamOnHGlobal` plus `IWICImagingFactory.CreateDecoderFromStream`,
preserves caller ownership, detects PNG/BMP/JPEG format from magic bytes, and
keeps path-based opens on `CreateDecoderFromFilename`. Fresh AHK evidence
includes `.codex/pillow-open-builtin-filelike-red-report.txt` failing because
the old WIC filename decode expected a string path, focused green
`.codex/pillow-open-builtin-filelike-green-focused-report.txt` passing 1/1,
module `.codex/pillow-open-builtin-filelike-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 61/61, and captured example
`.codex/pillow-open-builtin-filelike-example-report.txt` passing 1/1.

The ImageStat follow-up adds the first dedicated Pillow statistics submodule
surface as `stdlib.pillow.ImageStat.Stat(...)`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_image_stat_probe.py` and
`.codex/pillow_image_stat_probe.output.json` records `ImageStat.Stat(image)`,
`ImageStat.Stat(image, mask)`, and `ImageStat.Stat(histogram_list)` behavior
for `count`, `sum`, `sum2`, `mean`, `median`, `rms`, `var`, `stddev`, and
`extrema`, plus first-argument and mask size/mode errors. The AHK surface now
routes image inputs through the existing 256-bin `histogram(mask)` path and
derives the same per-band statistics from the stored histogram, while list
inputs are treated as precomputed histograms. The same slice also tightens
histogram mask validation for non-`L` / non-`1` masks to match Pillow's
`ValueError("bad transparency mask")`. Fresh AHK evidence includes
`.codex/pillow-image-stat-red-report.txt` failing because `stdlib.pillow` had
no `ImageStat` property, `.codex/pillow-image-stat-green-focused-report.txt`
passing `stdlib/tests/pillow.test.ahk` 63/63, plus final module and captured
example gates after promotion sync.

The ImageSequence follow-up adds the dedicated Pillow frame-sequence helper
surface as `stdlib.pillow.ImageSequence.Iterator(...)` and
`stdlib.pillow.ImageSequence.all_frames(...)` for the covered single-frame
image lifecycle. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_sequence_probe.py` and
`.codex/pillow_image_sequence_probe.output.json` records that `Iterator(image)`
returns the source image for `next()`, index `0`, and `for` iteration, raises
`StopIteration("end of sequence")` after the single frame, raises
`IndexError("end of sequence")` for nonzero/negative/string indices, and raises
the observed constructor arity and bad-input `AttributeError` messages.
`all_frames(image)` and `all_frames([images...])` return independent copied
frames, and `all_frames(image, func)` applies the callable to copied frames.
The AHK surface now mirrors those covered single-frame paths using the existing
`seek(0)` / `copy()` / `convert(...)` image lifecycle. Fresh AHK evidence
includes `.codex/pillow-image-sequence-red-report.txt` failing because
`stdlib.pillow` had no `ImageSequence` property,
`.codex/pillow-image-sequence-green-focused-report.txt` passing
`stdlib/tests/pillow.test.ahk` 64/64 before promotion sync, plus final module
and captured example gates after promotion sync.

The ImageMode follow-up adds Pillow's mode descriptor helper surface as
`stdlib.pillow.ImageMode.getmode(...)` and
`stdlib.pillow.ImageMode.ModeDescriptor(...)`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_image_mode_probe.py` and
`.codex/pillow_image_mode_probe.output.json` records the
`ModeDescriptor(mode, bands, basemode, basetype, typestr)` namedtuple fields,
tuple-like iteration and index access, `_asdict()`, `str`, `repr`, `getmode`
caching, covered `RGB` / `RGBA` / `L` / `LA` / `P` / `CMYK` / `I;16` mode
values, direct descriptor construction, and missing/extra/invalid argument
errors. The AHK surface now returns cached descriptor objects for covered modes,
with a callable `ModeDescriptor` factory that exposes `_fields` and returns
immutable tuple-like descriptor values. Fresh AHK evidence includes
`.codex/pillow-image-mode-red-report.txt` failing because `stdlib.pillow` had
no `ImageMode` property and `.codex/pillow-image-mode-green-focused-report.txt`
passing `stdlib/tests/pillow.test.ahk` 65/65 before promotion sync, plus final
module and captured example gates after promotion sync.

The ImagePalette follow-up adds Pillow's palette helper submodule surface as
`stdlib.pillow.ImagePalette.ImagePalette(...)`, `raw(...)`, `negative(...)`,
`wedge(...)`, `sepia(...)`, `make_linear_lut(...)`, and
`make_gamma_lut(...)`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_image_palette_probe.py` and
`.codex/pillow_image_palette_probe.output.json` records construction from mode
and byte sequences, `copy()` independence, `colors` mapping, `getdata()`,
`tobytes()` / `tostring()`, RGB and RGBA `getcolor(...)` allocation including
the RGBA default-alpha key with three-byte palette append behavior, raw palette
error paths, `negative` / `wedge` / `sepia` generated byte tables, linear and
gamma LUT helpers, and the covered missing/extra/invalid argument errors. The
AHK surface uses arrays of bytes as the public bytes representation and keeps
the existing image-instance palette storage separate from this helper object
surface. Fresh AHK evidence includes `.codex/pillow-image-palette-red-report.txt`
failing because `stdlib.pillow` had no `ImagePalette` property,
`.codex/pillow-image-palette-green-focused-report.txt` passing
`stdlib/tests/pillow.test.ahk` 66/66 after implementation, and
`.codex/pillow-image-palette-example-report.txt` passing the captured example
without warning/error output.

The ImageTransform follow-up adds Pillow's transform descriptor submodule
surface as `stdlib.pillow.ImageTransform.Transform(...)`,
`AffineTransform(...)`, `ExtentTransform(...)`, `QuadTransform(...)`,
`PerspectiveTransform(...)`, and `MeshTransform(...)`. Fresh local Python
3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_image_transform_probe.py` and
`.codex/pillow_image_transform_probe.output.json` records descriptor `.data`,
`.getdata()`, `.transform(size, image)`, method constants for affine/extent/
quad/perspective/mesh, transformed pixel rows, and covered missing/extra
argument plus missing `.method` errors. The AHK surface uses prefixed internal
descriptor classes and delegates descriptor transforms into the already-covered
`Image.transform(...)` implementation. Fresh AHK evidence includes
`.codex/pillow-image-transform-red-report.txt` failing because `stdlib.pillow`
had no `ImageTransform` property, `.codex/pillow-image-transform-green-focused-report.txt`
passing `stdlib/tests/pillow.test.ahk` 67/67 after implementation,
`.codex/pillow-image-transform-final-module-report-2.txt` passing the same
module gate 67/67 in a serial rerun, and
`.codex/pillow-image-transform-example-report.txt` passing the captured
example without warning/error output.

The ImagePath follow-up adds Pillow's coordinate path helper surface as
`stdlib.pillow.ImagePath.Path(...)`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_image_path_probe.py` and
`.codex/pillow_image_path_probe.output.json` records construction from flat
coordinates, coordinate pairs, integer counts, and existing paths; zero-based
indexing, negative indexing, slice reads, iteration, `tolist()` /
`tolist(True)`, `getbbox()`, `compact(...)`, affine `transform(...)` with and
without wrap, mutating `map(...)`, and covered bad-index / coordinate /
arity errors. The AHK surface uses prefixed internal classes and stores paths
as float coordinate pairs while exposing the public `stdlib.pillow.ImagePath`
module object. Fresh AHK evidence includes
`.codex/pillow-image-path-red-report.txt` failing because `stdlib.pillow` had
no `ImagePath` property, `.codex/pillow-image-path-green-focused-report.txt`
passing `stdlib/tests/pillow.test.ahk` 68/68 after implementation,
`.codex/pillow-image-path-final-module-report.txt` passing the same module
gate 68/68 in a serial rerun, and
`.codex/pillow-image-path-final-example-report.txt` passing the captured
example without warning/error output.

The ImageMath follow-up adds the first real Pillow expression helper surface as
`stdlib.pillow.ImageMath.unsafe_eval(...)`, `eval(...)`, and
`lambda_eval(...)`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagemath_probe.py` and
`.codex/pillow-imagemath-final-probe.output.json` records covered `L` image
arithmetic, scalar/image order, subtraction, multiplication, division,
`abs`, `min`, `max`, `equal`, `notequal`, `int(float(A))`, `convert(A, "L")`,
literal integers, image-name identity, lambda evaluation, deprecated
`ImageMath.eval(...)` delegation, and bad builtin / dunder-key / unsupported
RGB / missing-name errors. The AHK surface uses prefixed internal helpers,
memory-backed `I` / `F` image results for expression output, and a deliberately
bounded parser for the covered expression subset; full Python expression
grammar, deprecation-warning parity, and unprobed operator families remain
deferred. Fresh AHK evidence includes `.codex/pillow-imagemath-red-report.txt`
failing because `stdlib.pillow` had no `ImageMath` property,
`.codex/pillow-imagemath-green-focused-report.txt` passing after
implementation, `.codex/pillow-imagemath-final-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 69/69 at `TimeoutSeconds 90`, and
`.codex/pillow-imagemath-final-example-report.txt` passing the captured
example 1/1 without warning/error output.

The ImageFile follow-up adds the first real Pillow parser surface as
`stdlib.pillow.ImageFile.Parser()` plus the covered module constants
`MAXBLOCK`, `LOAD_TRUNCATED_IMAGES`, and `ERRORS`. Fresh local Python 3.10.11
plus Pillow 11.3.0 evidence from `.codex/pillow_imagefile_parser_probe.py` and
`.codex/pillow-imagefile-parser-final-probe.output.json` records parser initial
state, bytes-only `feed(...)`, PNG/BMP/JPEG byte parsing, `close()` returning
the parsed image, no-argument constructor errors, `reset()` reuse behavior,
and context-manager close semantics. The AHK surface uses the shared
`stdlib.io.BytesIO` object as the in-memory file-like bridge for accumulated
bytes and keeps unclaimed Pillow decoder internals bounded to the observed
parser subset. Fresh AHK evidence includes
`.codex/pillow-imagefile-parser-red-report.txt` failing because
`stdlib.pillow` had no `ImageFile` property,
`.codex/pillow-imagefile-parser-green-focused-report.txt` passing after
implementation, `.codex/pillow-imagefile-parser-final-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 70/70 at `TimeoutSeconds 90`, and
`.codex/pillow-imagefile-parser-final-example-report.txt` passing the captured
example 1/1 without warning/error output.

The next ImageFile follow-up extends that surface with Pillow's public base and
codec/stub helpers: `SAFEBLOCK`, `ImageFile.ImageFile(...)`, `PyCodec(...)`,
`PyCodecState()`, `PyDecoder(...)`, `PyEncoder(...)`, `StubHandler()`,
`StubImageFile(...)`, and `raise_oserror(...)`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_imagefile_surface_probe.py` and
`.codex/pillow_imagefile_surface_probe.output.json` records `SAFEBLOCK`,
`ERRORS`, `PyCodecState.extents()`, abstract-instantiation behavior for the
public base classes, `ImageFile.__init__()` / `PyCodec.__init__()` missing-arg
errors, and the deprecated `raise_oserror(-2)` translation to `OSError("broken
data stream when reading image file")`. Fresh AHK evidence includes
`.codex/pillow-imagefile-surface-red-report.txt` plus
`.codex/pillow-imagefile-surface-red.json` failing because
`stdlib.pillow.ImageFile` lacked `SAFEBLOCK`, focused green
`.codex/pillow-imagefile-surface-green-focused-report.txt` plus
`.codex/pillow-imagefile-surface-green-focused.json` passing 1/1 after the
minimal public surface implementation, related regressions
`.codex/pillow-imagefile-parser-related-report.txt`,
`.codex/pillow-bufr-related-report.txt`, `.codex/pillow-grib-related-report.txt`,
`.codex/pillow-hdf5-related-report.txt`, `.codex/pillow-msp-related-report.txt`,
and `.codex/pillow-wmf-related-report.txt` each passing 1/1, and fresh serial
module gate `.codex/pillow-imagefile-surface-module-gate-report.txt` plus
`.codex/pillow-imagefile-surface-module-gate.json` passing
`stdlib/tests/pillow.test.ahk` 175/175 at `TimeoutSeconds 90`.

The ImageFont follow-up adds the first real Pillow font helper surface as
`stdlib.pillow.ImageFont.load_default(...)`, `MAX_STRING_LENGTH`, and
`ImageFont.Layout` constants for the covered default-font path. Fresh local
Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagefont_probe.py` and
`.codex/pillow-imagefont-final-probe.output.json` records `load_default()`,
positive/zero/negative/string size behavior, `FreeTypeFont` default font
`getbbox(...)` / `getlength(...)` metrics for covered ASCII strings, and
`getmask(...)` `ImagingCore` mode/size/bbox/length metadata. The AHK surface
uses prefixed internal font and mask classes and deliberately bounds this slice
to default-font metrics; broader TrueType file loading, font search paths,
shaping, and text drawing are covered by later ordinary ImageDraw and ImageDraw2
text slices.
Fresh AHK evidence
includes `.codex/pillow-imagefont-red-report.txt` failing because
`stdlib.pillow` had no `ImageFont` property,
`.codex/pillow-imagefont-green-focused-report.txt` passing after
implementation, `.codex/pillow-imagefont-final-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 71/71 at `TimeoutSeconds 90`, and
`.codex/pillow-imagefont-final-example-report.txt` passing the captured example
1/1 without warning/error output.

The ImageFont base-class follow-up adds Pillow's public
`ImageFont.ImageFont()` base wrapper for the covered default constructor and
unloaded-font method behavior. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagefont_base_probe.py` and
`.codex/pillow-imagefont-base-probe.output.json` records the no-argument
signature, returned `ImageFont` type, empty instance dictionary, absent
`.font` / `.path` / `.size`, present `getmask(...)`, `getbbox(...)`, and
`getlength(...)` methods, constructor extra-argument error, missing-text
TypeErrors, `None` text length-check TypeErrors, and the default
`AttributeError("'ImageFont' object has no attribute 'font'")` for normal text
before a concrete font backend is loaded. The AHK surface exposes
`stdlib.pillow.ImageFont.ImageFont()` through a prefixed
`AhkStdlibPillowBaseImageFont` class and keeps loaded bitmap and FreeType font
metrics on their existing concrete classes. Font-core backed base rendering,
private `_load_pilfont*` helpers, and arbitrary attached `.font` backend
objects remain deferred until focused probes cover them. Focused red
`.codex/pillow-imagefont-base-red-report.txt` failed because the public base
class surface was absent; focused green
`.codex/pillow-imagefont-base-green-focused-report.txt` passed after
implementation. Fresh promotion gates include serial module
`.codex/pillow-imagefont-base-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 82/82 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-imagefont-base-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with README/example pollution assertions.

The ImageDraw2 follow-up adds the first real Pillow `ImageDraw2` surface as
`stdlib.pillow.ImageDraw2.Pen(...)`, `Brush(...)`, and `Draw(...)` for the
covered basic geometry path. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagedraw2_probe.py` and
`.codex/pillow-imagedraw2-final-probe.output.json` records Pen/Brush color and
width wrapping, `Draw(image).flush()` returning the image, line/rectangle/
ellipse/polygon pixel matrices for the covered small RGB images, and observed
constructor/coordinate error messages. The AHK surface wraps the existing
ImageDraw implementation where the observed semantics match and uses a bounded
local line/ellipse bridge where Pillow's tiny-shape pixels differ. Text,
arbitrary render kwargs, and path-related ImageDraw2 behavior remain unclaimed
until separate probes cover them. Fresh AHK evidence includes
`.codex/pillow-imagedraw2-red-report.txt` failing because `stdlib.pillow` had
no `ImageDraw2` property, `.codex/pillow-imagedraw2-green-focused-report.txt`
passing after implementation, `.codex/pillow-imagedraw2-final-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` at `TimeoutSeconds 90`, and
`.codex/pillow-imagedraw2-final-example-report.txt` passing the captured example
without warning/error output.

The ImageDraw2 arc/chord/pieslice follow-up extends that same surface with
`Draw.arc(...)`, `Draw.chord(...)`, and `Draw.pieslice(...)` for the covered
Pen/Brush geometry paths. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagedraw2_arc_probe.py` and
`.codex/pillow-imagedraw2-arc-final-probe.output.json` records the observed
small-image pixel matrices, confirms Pillow's `arc(...)` ignores Pen width in
this WCK wrapper path, captures RGB and RGBA target color conversion, and
records the probed missing-argument and bad-coordinate messages. The AHK
surface reuses the covered ImageDraw arc/chord/pieslice backend and normalizes
ImageDraw2 Pen/Brush colors to the target image mode at draw time without
changing the public `Pen.color` / `Brush.color` values. Fresh AHK evidence
includes `.codex/pillow-imagedraw2-arc-red-report.txt` failing because
`AhkStdlibPillowImageDraw2Draw` had no `arc` method,
`.codex/pillow-imagedraw2-arc-green-focused-report.txt` passing after
implementation, `.codex/pillow-imagedraw2-arc-final-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` at `TimeoutSeconds 90`, and
`.codex/pillow-imagedraw2-arc-final-example-report.txt` passing the captured
example without warning/error output.

The ImageDraw2 settransform/render follow-up extends the same WCK-style helper
surface with `Draw.settransform(offset)` and the covered direct
`Draw.render(...)` dispatch paths. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_imagedraw2_transform_probe.py` and
`.codex/pillow-imagedraw2-transform-final-probe.output.json` records
`settransform((1, 1))` storing `[1, 0, 1, 0, 1, 1]`, transformed
line/rectangle/polygon pixel matrices, direct `render("line", ...)` and
`render("rectangle", ...)` matrices, and the probed missing-argument,
unpack, unknown-op, and missing-arc-kwargs error messages. The AHK surface
reuses `ImagePath.Path(...).transform(...)` for the covered integer offset
path and keeps arbitrary render keyword forwarding unclaimed. Fresh AHK
evidence includes
`.codex/pillow-imagedraw2-transform-red-report.txt` failing because
`AhkStdlibPillowImageDraw2Draw` had no `settransform` method,
`.codex/pillow-imagedraw2-transform-green-focused-report.txt` passing after
implementation, `.codex/pillow-imagedraw2-transform-final-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` at `TimeoutSeconds 90`, and
`.codex/pillow-imagedraw2-transform-final-example-report.txt` passing the
captured example without warning/error output.

The ImageDraw2 text follow-up extends the WCK-style helper surface with
`ImageDraw2.Font(...)`, `Draw.text(...)`, `Draw.textbbox(...)`, and
`Draw.textlength(...)` for the covered local TrueType path. Fresh local Python
3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagedraw2_text_probe.py` and
`.codex/pillow-imagedraw2-text-final-probe.output.json` records
`Font("red", "C:\\Windows\\Fonts\\arial.ttf", 12)` color/font state,
`FreeTypeFont.getbbox("Hi")`, `FreeTypeFont.getlength("Hi")`,
`Draw.textbbox((1, 1), "Hi", font)`, `Draw.textlength("Hi", font)`,
`Draw.text(...)` returning `None` while writing visible pixels, and the probed
missing-argument, missing-resource, bad-color, `None` font, and transform/text
error messages. The AHK surface uses prefixed internal font helpers and a GDI+
text drawing backend for non-memory images with a bounded fallback path; wider
font discovery, shaping, and arbitrary TrueType pixel-perfect parity remain
unclaimed until further probes cover them. Fresh AHK evidence includes
`.codex/pillow-imagedraw2-text-red-report.txt` failing because
`ImageDraw2.Font` was missing, focused green
`.codex/pillow-imagedraw2-text-gdi-focused-report.txt` passing after
implementation, module gate `.codex/pillow-imagedraw2-text-gdi-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 75/75 at `TimeoutSeconds 90`, and
captured example gate `.codex/pillow-imagedraw2-text-gdi-example-report.txt`
passing 1/1 without warning/error output.

The ImageFont FreeTypeFont variant follow-up extends the covered TrueType font
object surface with `FreeTypeFont.getname()`, `getmetrics()`, and
`font_variant(...)` for the local Arial TrueType evidence path. Fresh local
Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagefont_variant_probe.py` and
`.codex/pillow-imagefont-variant-probe.output.json` records
`ImageFont.truetype("C:\\Windows\\Fonts\\arial.ttf", 12)` returning
`("Arial", "Regular")`, metrics `(11, 3)`, `getbbox("Hi") ==
(0, 2, 11, 11)`, `getlength("Hi") == 11.34375`, and distinct
`font_variant()` objects for same-size, size `18`, and explicit font+size `14`
variants with their probed metrics and text extents. The AHK surface now keeps
those paths behind the prefixed `AhkStdlibPillowFreeTypeFont` helper and uses
the same path/size validation errors observed by Pillow. Wider font discovery,
non-Arial family/style metadata, variable font axes, shaping, and arbitrary
TrueType metric parity remain unclaimed until dedicated probes cover them.
Fresh AHK evidence includes `.codex/pillow-imagefont-variant-red-report.txt`
failing because the font object lacked `getname`, focused green
`.codex/pillow-imagefont-variant-green-focused-report.txt` passing after
implementation, serial module gate
`.codex/pillow-imagefont-variant-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 76/76 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-imagefont-variant-example-report.txt` passing 1/1
without warning/error output and with README-probe pollution assertions.

The ImageFont TransposedFont follow-up extends the covered font helper surface
with `stdlib.pillow.ImageFont.TransposedFont(font, orientation=None)`. Fresh
local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagefont_transposed_probe.py` and the promotion rerun output
`.codex/pillow-imagefont-transposed-promotion-probe.output.json` records
default-font and local Arial TrueType wrapping, `.font` identity preservation,
`orientation`, `getbbox(...)`, `getlength(...)`, and `getmask(...)`
mode/size/bbox/length behavior for `None`, flip, and rotate orientations,
plus the covered missing-font, extra-argument, and bad-orientation errors. The
AHK surface keeps this behind prefixed internal font/mask helpers and reuses
the covered image transpose constants. Variable font axes, broad shaping, font
discovery beyond the local Arial evidence path, and pixel-perfect arbitrary
mask parity remain unclaimed until dedicated probes cover them. Earlier red
evidence `.codex/pillow-imagefont-transposed-red-report.txt` failed because
`TransposedFont` was missing; focused green
`.codex/pillow-imagefont-transposed-green-focused-report.txt` passed after
implementation. Fresh promotion gates include serial module
`.codex/pillow-imagefont-transposed-promotion-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 77/77 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-imagefont-transposed-promotion-example-report.txt`
passing `.codex/pillow_example_capture.test.ahk` 1/1 without warning/error
output and with README/example pollution assertions.

The ImageFont bitmap default follow-up adds Pillow's public
`ImageFont.load_default_imagefont()` helper surface for the covered built-in
bitmap font path. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagefont_load_default_imagefont_probe.py` and
`.codex/pillow-imagefont-load-default-imagefont-probe.output.json` records the
returned `ImageFont` object type, absence of `.path` / `.size`, fixed bitmap
font `getbbox(...)`, `getlength(...)`, and `getmask(...)` mode/size/bbox/len
behavior for `""`, `"A"`, `"abc"`, and `"Hello"`, plus the covered extra
argument and `None` text errors. The AHK surface exposes
`stdlib.pillow.ImageFont.load_default_imagefont()` and keeps the implementation
behind prefixed internal bitmap font/mask classes. Arbitrary glyph metric
matrices and pixel-perfect mask contents remain unclaimed until dedicated
probes cover them.
Fresh AHK evidence includes focused red
`.codex/pillow-imagefont-load-default-imagefont-red-report.txt` failing because
`load_default_imagefont` was missing, focused green
`.codex/pillow-imagefont-load-default-imagefont-green-focused-report.txt`
passing after implementation, serial module gate
`.codex/pillow-imagefont-load-default-imagefont-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 78/78 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-imagefont-load-default-imagefont-example-report.txt`
passing `.codex/pillow_example_capture.test.ahk` 1/1 without warning/error
output and with README/example pollution assertions.

The ImageFont bitmap loading follow-up adds Pillow's public
`ImageFont.load(filename)` and `ImageFont.load_path(filename)` surfaces for
the covered `.pil` bitmap font metrics path. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_imagefont_load_probe.py` and
`.codex/pillow-imagefont-load-probe.output.json` records a generated minimal
`.pil` / sibling `.pbm` font returning an `ImageFont` object with `.file`,
empty `.info`, `getbbox(...)`, `getlength(...)`, and `getmask(...)`
mode/size/bbox/len behavior for `""`, `"A"`, `"AB"`, and a missing glyph,
plus missing/extra argument and missing-file errors for both helpers. The AHK
surface exposes `stdlib.pillow.ImageFont.load(...)` and
`stdlib.pillow.ImageFont.load_path(...)` backed by prefixed internal bitmap
font/mask classes and a `.pil` metric parser. Covered `load_path(...)`
searches direct paths and the working directory; full Python `sys.path`
search behavior, bytes path parity, `.gif` / `.png` glyph backing files,
malformed-font edge-case matrices, and pixel-perfect glyph bitmap contents
remain deferred until focused probes cover them. Focused red
`.codex/pillow-imagefont-load-red-report.txt` failed because the public helper
surface was absent; focused green
`.codex/pillow-imagefont-load-green-focused-report.txt` passed after
implementation. Fresh promotion gates include serial module
`.codex/pillow-imagefont-load-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 81/81 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-imagefont-load-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with README/example pollution assertions.

The ImageFont FreeTypeFont constructor follow-up adds Pillow's public
`ImageFont.FreeTypeFont(font, size=10, index=0, encoding="",
layout_engine=None)` constructor surface for the covered local Arial TrueType
path. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_imagefont_freetypefont_constructor_probe.py` and the promotion
rerun `.codex/pillow-imagefont-freetypefont-constructor-fresh-probe.output.json`
records the public signature, default size `10`, local
`C:\Windows\Fonts\arial.ttf` constructor behavior, `getname()`,
`getmetrics()`, `getbbox("Hi")`, `getlength("Hi")`, `getmask("Hi")`
mode/size/bbox/length metadata, equivalence with `ImageFont.truetype(..., 12)`
for the covered size-12 path, and the covered missing-font, too-many-args,
missing-resource, zero-size, and string-size errors. The AHK surface exposes
`stdlib.pillow.ImageFont.FreeTypeFont(...)` and keeps the implementation behind
the prefixed `AhkStdlibPillowFreeTypeFont` helper. Wider font discovery,
non-Arial family/style metadata, variable font axes, shaping, arbitrary
font-file metric parity, and pixel-perfect mask contents remain unclaimed until
dedicated probes cover them. Earlier red evidence
`.codex/pillow-imagefont-freetypefont-constructor-red-report.txt` failed
because `FreeTypeFont` was missing; focused green
`.codex/pillow-imagefont-freetypefont-constructor-green-focused-report.txt`
passed after implementation. Fresh promotion gates include serial module
`.codex/pillow-imagefont-freetypefont-constructor-fresh-module-report.txt`
passing `stdlib/tests/pillow.test.ahk` 79/79 at `TimeoutSeconds 90`, and
captured example
`.codex/pillow-imagefont-freetypefont-constructor-fresh-example-report.txt`
passing `.codex/pillow_example_capture.test.ahk` 1/1 without warning/error
output and with README/example pollution assertions.

The ImageFont helper follow-up adds Pillow's public `ImageFont.is_path(...)`
and `ImageFont.DeferredError(...)` helper surface for the covered path
classification and deferred-exception behavior. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_imagefont_helpers_probe.py` and
`.codex/pillow-imagefont-helpers-probe.output.json` records `is_path(...)`
returning true for `str`, `bytes`, `pathlib.Path`, and custom
`os.PathLike`-style objects, false for `bytearray`, `BytesIO`, `None`, `int`,
and plain objects, plus the covered missing/extra argument errors. The same
probe records `DeferredError(ex)` and `DeferredError.new(ex)` preserving the
wrapped exception object and re-raising that same exception from arbitrary
attribute access. The AHK surface exposes `stdlib.pillow.ImageFont.is_path(...)`
and `stdlib.pillow.ImageFont.DeferredError(...)`; AHK coverage maps `str`,
`stdlib.pathlib.Path`, and objects with `__fspath` as path-like, while native
Python `bytes` path parity remains deferred until the stdlib has a distinct
bytes path object. Focused red `.codex/pillow-imagefont-helpers-red-report.txt`
failed because the helper surface was absent; focused green
`.codex/pillow-imagefont-helpers-green-focused-report.txt` passed after
implementation. Fresh promotion gates include serial module
`.codex/pillow-imagefont-helpers-module-report.txt` passing
`stdlib/tests/pillow.test.ahk` 80/80 at `TimeoutSeconds 90`, and captured
example `.codex/pillow-imagefont-helpers-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with README/example pollution assertions.

The Pillow BdfFontFile follow-up adds Pillow's public raster font-file
surfaces `stdlib.pillow.FontFile` and `stdlib.pillow.BdfFontFile` for the
covered BDF bitmap-font path. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_bdffontfile_probe.py` and
`.codex/pillow-bdffontfile-probe.output.json` records `FontFile.WIDTH`,
`FontFile.puti16(...)` big-endian signed 16-bit output, empty
`FontFile.FontFile()` state and empty-save error, `BdfFontFile.bdf_char(...)`
for a normal glyph, a zero-width glyph, an out-of-range encoded glyph, and EOF,
plus `BdfFontFile.BdfFontFile(...)` glyph population, `compile()` bitmap and
metrics, `save(...)` writing `.pil` metrics plus a PNG-backed `.pbm` glyph
file, and `ImageFont.load(...)` loading the saved font for bbox/length checks.
The AHK surface exposes `stdlib.pillow.FontFile.FontFile(...)`,
`stdlib.pillow.FontFile.puti16(...)`, `stdlib.pillow.BdfFontFile.bdf_char(...)`,
and `stdlib.pillow.BdfFontFile.BdfFontFile(...)`, backed by prefixed internal
classes and BDF hex-row decoding. This slice also adds the root `SyntaxError`
built-in style error because Pillow raises that type for invalid BDF headers.
Wider BDF property metadata, malformed BDF matrices beyond the covered header
and empty-font paths, full pixel-perfect bitmap font rendering, and non-BDF
font-file plugins remain deferred until focused probes cover them. Focused red
`.codex/pillow-bdffontfile-red-report.txt` failed because the public modules
were absent; focused green `.codex/pillow-bdffontfile-green-focused-report.txt`
passed after implementation. Fresh promotion gates include serial module
`.codex/pillow-bdffontfile-module-report.txt` plus
`.codex/pillow-bdffontfile-module.json` passing `stdlib/tests/pillow.test.ahk`
100/100 at `TimeoutSeconds 90`, and captured example
`.codex/pillow-bdffontfile-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The SunImagePlugin follow-up adds Pillow's Sun Raster image plugin surface as
`stdlib.pillow.SunImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_sunimageplugin_probe.py` and
`.codex/pillow_sunimageplugin_probe.output.json` records `_accept`,
`SunImageFile` format metadata, `.ras` open registration, raw 1/4/8/24/32-bit
file-like opens, palette type 1 RGB palette conversion, Sun RLE decoding, and
Pillow's bad magic/depth/file-type/palette/truncated-header plus explicit
unsupported save behavior. The AHK surface exposes direct construction,
registered `Image.open(..., ["SUN"])`, raw and RLE in-memory pixel loading, and
the covered SyntaxError/UnidentifiedImageError/KeyError paths. Save encoding,
non-type-1 palettes, and wider Sun Raster corpora remain deferred until focused
Python probes cover them. Fresh AHK evidence includes focused red
`.codex/pillow-sunimageplugin-red-report.txt` failing because
`stdlib.pillow.SunImagePlugin` was absent, focused green
`.codex/pillow-sunimageplugin-green-focused-report.txt` plus
`.codex/pillow-sunimageplugin-green-focused.json` passing 1/1 after
implementation, and captured example gate
`.codex/pillow-sun-tga-example-report.txt` plus
`.codex/pillow-sun-tga-example.json` passing `.codex/pillow_example_capture.test.ahk`
2/2 without warning/error output and with System.Text.RegularExpressions /
MatchEvaluator pollution assertions.

The TgaImagePlugin follow-up adds Pillow's Targa image plugin surface as
`stdlib.pillow.TgaImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_tgaimageplugin_probe.py` and
`.codex/pillow_tgaimageplugin_probe.output.json` records `MODES`, `SAVE`,
`TgaImageFile` format metadata, `.tga`/`.icb`/`.vda`/`.vst` and MIME
registration, raw and RLE file-like opens for covered modes, palette handling,
ID section and orientation metadata, exact file-like saves including footer and
RLE output, and Pillow's bad-header/bad-mode/bad-palette/unsupported-save-mode
errors. The AHK surface exposes direct construction, registered
`Image.open(..., ["TGA"])`, registered file-like `Image.save(..., "TGA")`, raw
and RLE decoding, ID/orientation metadata, palette handling, and covered writer
output. Broader Truevision edge cases, interleaved images, uncommon palette
depths, and native Direct2D/WIC acceleration remain deferred until focused
probes cover them. Fresh AHK evidence includes focused red
`.codex/pillow-tgaimageplugin-red-report.txt` failing because
`stdlib.pillow.TgaImagePlugin` was absent, focused green
`.codex/pillow-tgaimageplugin-green-focused-report.txt` plus
`.codex/pillow-tgaimageplugin-green-focused.json` passing 1/1 after
implementation, and captured example gate
`.codex/pillow-sun-tga-example-report.txt` plus
`.codex/pillow-sun-tga-example.json` passing `.codex/pillow_example_capture.test.ahk`
2/2 without warning/error output and with System.Text.RegularExpressions /
MatchEvaluator pollution assertions.

After both SunImagePlugin and TgaImagePlugin landed, the fresh serial
Pillow-filtered module gate `.codex/pillow-sun-tga-module-filter-report.txt`
plus `.codex/pillow-sun-tga-module-filter.json` passed 149/149 at
`TimeoutSeconds 90`, and the fresh captured example rerun
`.codex/pillow-sun-tga-example-rerun-report.txt` plus
`.codex/pillow-sun-tga-example-rerun.json` passed 2/2 without warning/error
output.

The TiffImagePlugin follow-up adds Pillow's TIFF plugin surface as
`stdlib.pillow.TiffImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_tiffimageplugin_probe.py` and
`.codex/pillow_tiffimageplugin_probe.output.json` records TIFF constants,
`PREFIXES`, `_accept`, `i16`/`i32`/`o8`, `COMPRESSION_INFO`,
`COMPRESSION_INFO_REV`, representative `OPEN_INFO` / `SAVE_INFO`, `TiffImageFile`
format metadata, `.tif`/`.tiff` and MIME registration, save/save_all registry
presence, direct and `Image.open(..., ["TIFF"])` file-like opens, L/RGB pixel
round-trips, baseline file-like saves, and covered bad-magic/constructor error
paths. The AHK surface exposes the plugin module, registers TIFF open/save/
save_all through the existing registry, routes `TiffImageFile` direct opens
through WIC-backed TIFF decoding with Pillow-style bad-header `SyntaxError`, and
uses the existing baseline L TIFF writer plus GDI-backed TIFF output for covered
save paths. Full `ImageFileDirectory_v1` / `ImageFileDirectory_v2`,
`AppendingTiffWriter`, multi-page TIFF save_all semantics, tiled/strip metadata
round-trips, compression variants beyond raw/GDI-supported output, and libtiff
integration remain deferred until focused probes cover them. Fresh AHK evidence
includes focused red `.codex/pillow-tiffimageplugin-red-report.txt` failing
because `stdlib.pillow.TiffImagePlugin` was absent, focused green
`.codex/pillow-tiffimageplugin-green-focused-report.txt` plus
`.codex/pillow-tiffimageplugin-green-focused.json` passing 1/1 after
implementation, captured example gate
`.codex/pillow-tiffimageplugin-example-report.txt` plus
`.codex/pillow-tiffimageplugin-example.json` passing 2/2 without warning/error
output, and serial Pillow-filtered module gate
`.codex/pillow-tiffimageplugin-module-filter-report.txt` plus
`.codex/pillow-tiffimageplugin-module-filter.json` passing 150/150 at
`TimeoutSeconds 90`.

The WalImageFile follow-up adds Pillow's Quake2 WAL texture reader surface as
`stdlib.pillow.WalImageFile`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_walimagefile_probe.py` and
`.codex/pillow_walimagefile_probe.output.json` records `WalImageFile` format
metadata, module `open(...)`, `i32`, the full 768-byte `quake2palette`, direct
file-like construction, P-mode pixel data, `name` / `next_name` metadata, the
absence of `Image.open` / extension / MIME / save registration, and covered
constructor/open/short-header/truncated-pixel errors. The AHK surface exposes
`WalImageFile`, `open(...)`, `i32(...)`, and the full Quake2 palette, parses the
WAL header and pixel payload directly into a P-mode image, and deliberately
keeps the module out of the global Image registry to match Pillow's documented
behavior. Broader Quake2 texture corpora, path-open edge cases beyond the
covered reader, and unusual malformed headers remain deferred until focused
probes cover them. Fresh AHK evidence includes focused red
`.codex/pillow-walimagefile-red-report.txt` failing because
`stdlib.pillow.WalImageFile` was absent, focused green
`.codex/pillow-walimagefile-green-focused-report.txt` plus
`.codex/pillow-walimagefile-green-focused.json` passing 1/1 after
implementation, captured example gate `.codex/pillow-walimagefile-example-report.txt`
plus `.codex/pillow-walimagefile-example.json` passing 2/2 without warning/error
output, and serial Pillow-filtered module gate
`.codex/pillow-walimagefile-module-filter-report.txt` plus
`.codex/pillow-walimagefile-module-filter.json` passing 151/151 at
`TimeoutSeconds 90`.

The WebPImagePlugin follow-up adds the first Pillow WebP plugin slice as
`stdlib.pillow.WebPImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_webpimageplugin_probe.py` and
`.codex/pillow_webpimageplugin_probe.output.json` records `SUPPORTED`, VP8
identifier mode mapping, `_accept(...)`, `WebPImageFile` format metadata,
open/save/save_all/extension/MIME registry entries, lossless single-frame RGB
and RGBA file-like round-trips, base animation facts, `_convert_frame(...)`,
and covered constructor/bad-magic/background-validation errors. The AHK
surface now exposes the plugin module, registers WEBP, recognizes RIFF/WEBP
`VP8 ` / `VP8X` / `VP8L` prefixes, uses the Windows WIC bridge for single-frame
RGB/RGBA direct and registered file-like opens, sets Pillow-compatible
single-frame `info`, `n_frames`, `is_animated`, `seek`, `tell`, and `load_seek`
state, parses `ANIM` / full-frame `ANMF` chunks for the covered lossless
animated stream, reconstructs frame substreams for WIC decode, preserves
animated `loop`, `background`, `timestamp`, `duration`, `n_frames`, and
`is_animated` behavior, and keeps `_convert_frame(...)` aligned for covered
modes. Complex animated blend/dispose composition, ICC/EXIF/XMP chunk
round-trips, and real WebP encode/save_all output remain deferred until focused
probes and a verified system/libwebp backend support them. Fresh AHK evidence
includes focused red
`.codex/pillow-webpimageplugin-red-report.txt` failing because
`stdlib.pillow.WebPImagePlugin` was absent, focused green
`.codex/pillow-webpimageplugin-green-focused-report.txt` plus
`.codex/pillow-webpimageplugin-green-focused.json` passing 1/1 after
single-frame implementation, focused animation red
`.codex/pillow-webpimageplugin-animation-red-report.txt` failing on animated
mode/frame behavior before the ANMF parser, focused animation green
`.codex/pillow-webpimageplugin-animation-green-focused-report.txt` plus
`.codex/pillow-webpimageplugin-animation-green-focused.json` passing 1/1 after
animation support, captured example gate
`.codex/pillow-webpimageplugin-example-report.txt` plus
`.codex/pillow-webpimageplugin-example.json` passing 2/2 without warning/error
output, and serial Pillow-filtered module gate
`.codex/pillow-webpimageplugin-module-filter-report.txt` plus
`.codex/pillow-webpimageplugin-module-filter.json` passing 154/154 at
`TimeoutSeconds 90`.

The WmfImagePlugin follow-up adds Pillow's Windows metafile stub plugin surface
as `stdlib.pillow.WmfImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_wmfimageplugin_probe.py` and
`.codex/pillow_wmfimageplugin_probe.output.json` records the default
`WmfHandler`, imported little-endian helpers `word`, `short`, and `_long`,
`_accept(...)`, `WmfStubImageFile` format metadata, WMF and EMF header parsing,
`.wmf` / `.emf` registry behavior, lack of MIME and SAVE_ALL registration,
custom handler `open` / `load` / `save` delegation, DPI-driven size updates, and
invalid-inch / unsupported-header / save-without-handler error paths. The AHK
surface exposes `WmfImagePlugin`, default and custom handler registration,
direct and registered file-like WMF/EMF header opens, custom handler-backed
load/save behavior, and the same registry surface while leaving real Windows
metafile rasterization to future backend work. Fresh AHK evidence includes
focused red `.codex/pillow-wmfimageplugin-red-report.txt` failing because
`stdlib.pillow.WmfImagePlugin` was absent, focused green
`.codex/pillow-wmfimageplugin-green-focused-report.txt` plus
`.codex/pillow-wmfimageplugin-green-focused.json` passing 1/1 after
implementation, captured example gate `.codex/pillow-wmfimageplugin-example-report.txt`
plus `.codex/pillow-wmfimageplugin-example.json` passing 2/2 without
warning/error output, and serial Pillow-filtered module gate
`.codex/pillow-wmfimageplugin-module-filter-report.txt` plus
`.codex/pillow-wmfimageplugin-module-filter.json` passing 155/155 at
`TimeoutSeconds 90`.

The XbmImagePlugin follow-up adds Pillow's X11 bitmap plugin surface as
`stdlib.pillow.XbmImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_xbmimageplugin_probe.py` and
`.codex/pillow_xbmimageplugin_probe.output.json` records whitespace-tolerant
`_accept(...)`, `XbmImageFile` format metadata, registered `XBM` open/save
handlers, `.xbm` extension and `image/xbm` MIME registration, direct and
registered file-like opens, header parsing, hotspot metadata, XBM tile offsets,
LSB bitmap byte order, mode `1` file-like saves with hotspot encoder options,
and covered bad-header, missing-height, truncated-data, unsupported-mode, and
constructor arity error paths. The AHK surface exposes the same module factory,
registry shape, direct and `Image.open(..., ["XBM"])` dispatch, mode `1`
pixel loading/saving, hotspot metadata, and Pillow-style errors for the probed
inputs. Fresh AHK evidence includes focused red
`.codex/pillow-xbmimageplugin-red-report.txt` failing because
`stdlib.pillow.XbmImagePlugin` was absent, focused green
`.codex/pillow-xbmimageplugin-green-focused-report.txt` plus
`.codex/pillow-xbmimageplugin-green-focused.json` passing 1/1 after
implementation, captured example gate
`.codex/pillow-xbmimageplugin-example-report.txt` plus
`.codex/pillow-xbmimageplugin-example.json` passing 2/2 without warning/error
output, and serial Pillow-filtered module gate
`.codex/pillow-xbmimageplugin-module-filter-report.txt` plus
`.codex/pillow-xbmimageplugin-module-filter.json` passing 157/157 at
`TimeoutSeconds 90`.

The XpmImagePlugin follow-up adds Pillow's X11 pixel-map plugin surface as
`stdlib.pillow.XpmImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_xpmimageplugin_probe.py` and
`.codex/pillow_xpmimageplugin_probe.output.json` records exact `_accept(...)`
prefix behavior, `XpmImageFile` format metadata, `XpmDecoder._pulls_fd`,
registered `XPM` open and `xpm` decoder handlers, `.xpm` extension and
`image/xpm` MIME registration, lack of save/save_all registration, P-mode
palette file-like opens with `info["transparency"]` byte keys, RGB opens for
the `palette_length > 256` branch, XPM tile offsets/decoder args, and covered
bad-magic, broken-header, unknown-color, missing-color-key, truncated-pixel,
and constructor arity error paths. The AHK surface exposes the same module
factory, decoder factory, registry shape, direct and `Image.open(..., ["XPM"])`
dispatch, lazy P/RGB pixel loading, palette and transparent-key metadata, and
Pillow-style errors for the probed inputs. Fresh AHK evidence includes focused
red `.codex/pillow-xpmimageplugin-red-report.txt` failing because
`stdlib.pillow.XpmImagePlugin` was absent, focused green
`.codex/pillow-xpmimageplugin-green-focused-report.txt` plus
`.codex/pillow-xpmimageplugin-green-focused.json` passing 1/1 after
implementation, captured example gate
`.codex/pillow-xpmimageplugin-example-report.txt` plus
`.codex/pillow-xpmimageplugin-example.json` passing 2/2 without warning/error
output, and serial Pillow-filtered module gate
`.codex/pillow-xpmimageplugin-module-filter-report.txt` plus
`.codex/pillow-xpmimageplugin-module-filter.json` passing 158/158 at
`TimeoutSeconds 90`.

The XVThumbImagePlugin follow-up adds Pillow's XV thumbnail plugin surface as
`stdlib.pillow.XVThumbImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_xvthumbimageplugin_probe.py` and
`.codex/pillow_xvthumbimageplugin_probe.output.json` records `_MAGIC`,
the 768-byte RGB332 palette, `_accept(...)`, `XVThumbImageFile` format
metadata, uppercase `XVTHUMB` open registration with no save, extension, or
MIME registration, comment and whitespace header parsing, P-mode raw tile
metadata, direct and registered file-like opens, lazy pixel loading, and the
covered bad-magic, EOF, invalid-size, truncated-pixel, and constructor error
paths. The AHK surface exposes the same module constants, factory, registry
shape, P-mode palette images, `Image.open(..., ["XVThumb"])` dispatch, and
Pillow-style errors for the covered sample headers. Broader unsupported save or
extension behavior is intentionally absent because Pillow 11.3.0 does not
register those paths. Fresh AHK evidence includes focused red
`.codex/pillow-xvthumbimageplugin-red-report.txt` failing because
`stdlib.pillow.XVThumbImagePlugin` was absent, focused green
`.codex/pillow-xvthumbimageplugin-green-focused-report.txt` plus
`.codex/pillow-xvthumbimageplugin-green-focused.json` passing 1/1 after
implementation, captured example gate
`.codex/pillow-xvthumbimageplugin-example-report.txt` plus
`.codex/pillow-xvthumbimageplugin-example.json` passing 2/2 without
warning/error output, and serial Pillow-filtered module gate
`.codex/pillow-xvthumbimageplugin-module-filter-report.txt` plus
`.codex/pillow-xvthumbimageplugin-module-filter.json` passing 156/156 at
`TimeoutSeconds 90`.

The PpmImagePlugin follow-up adds Pillow's portable-anymap image plugin surface
as `stdlib.pillow.PpmImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_ppmimageplugin_probe.py` and
`.codex/pillow_ppmimageplugin_probe.output.json` records `b_whitespace`,
`MODES`, `_accept(...)` behavior including the short `b"P"` `IndexError`,
registry entries for `.pbm`, `.pgm`, `.ppm`, `.pnm`, and `.pfm`, plain
P1/P2/P3 decoding, raw P4/P5/P6 decoding, 16-bit grayscale P5 decoding, PyP,
PyRGBA, P0CMYK, and PFM `F` decoding with `info["scale"]` and vertical float
row ordering. The AHK surface exposes direct `PpmImageFile(...)`,
registered `Image.open(..., ["PPM"])`, `PpmDecoder`, `PpmPlainDecoder`,
mode `1`/`L`/`I`/`RGB`/`RGBA`/`F` file-like saves, and the covered
constructor, header, maxval, plain-token, and unsupported-save errors. Broader
portable-arbitrary-map variants, exotic float scale/endianness combinations
beyond the probed PFM sample, and benchmark-backed WIC/Direct2D acceleration
remain deferred until focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-ppmimageplugin-red-report.txt` failing because
`stdlib.pillow.PpmImagePlugin` was absent, focused PFM red
`.codex/pillow-ppmimageplugin-pfm-red-report.txt` exposing the uncovered float
decode path, focused green `.codex/pillow-ppmimageplugin-pfm-green-3-report.txt`
plus `.codex/pillow-ppmimageplugin-pfm-green-3.json` passing after
implementation, trusted serial module gate
`.codex/pillow-ppmimageplugin-module-1-report.txt` plus
`.codex/pillow-ppmimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 143/143 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-ppmimageplugin-example-1-report.txt` plus
`.codex/pillow-ppmimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The GifImagePlugin follow-up adds the next Pillow plugin surface as
`stdlib.pillow.GifImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_gifimageplugin_probe.py` and
`.codex/pillow-gifimageplugin-probe.output.json` records `_accept(...)` for
GIF87a/GIF89a prefixes, `GifImageFile` metadata, `LoadingStrategy`,
`LOADING_STRATEGY`, `RAWMODE`, GIF open/save/save_all/extension/MIME registry
effects, single-frame P-mode GIF87a/GIF89a metadata, palette, tile, pixel
loading, comment/loop/duration/transparency metadata, `Image.open(...,
["GIF"])`, P-mode GIF file-like save/open round-trips, a focused two-frame
`save_all=True` / `append_images` path, and constructor plus bad-image error
behavior. The AHK surface exposes the public module metadata, registered GIF
open/save/save_all/MIME/extension behavior, lazy GIF tile loading through a
small LZW reader, a P-mode GIF writer for covered file-like save/open
round-trips, and the probed two-frame save_all path with per-frame duration,
loop metadata, `n_frames`, `is_animated`, `seek`/`tell`, and Pillow's
second-frame RGB palette expansion. Interlace, disposal composition,
transparency animation, local palette switching beyond the covered paths,
optimization, and benchmark-backed native acceleration remain deferred until
focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-gifimageplugin-red-report.txt` failing because
`stdlib.pillow.GifImagePlugin` was absent, focused green
`.codex/pillow-gifimageplugin-green-focused-report.txt` plus
`.codex/pillow-gifimageplugin-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-gifimageplugin-module-report.txt` plus
`.codex/pillow-gifimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 113/113 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gifimageplugin-example-report.txt` plus
`.codex/pillow-gifimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.
The multiframe follow-up is backed by fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_gif_multiframe_probe.py` and
`.codex/pillow_gif_multiframe_probe.output.json`, focused red
`.codex/pillow-gif-multiframe-red-report.txt` plus
`.codex/pillow-gif-multiframe-red.json` failing because the previous save_all
path treated the per-frame duration list as a scalar and still wrote a
single-frame stream, and focused green
`.codex/pillow-gif-multiframe-green-focused-report.txt` plus
`.codex/pillow-gif-multiframe-green-focused.json` passing 1/1 after the
reader/writer/seek update. Captured example gate
`.codex/pillow-gif-multiframe-example-report.txt` plus
`.codex/pillow-gif-multiframe-example.json` passed
`.codex/pillow_example_capture.test.ahk` 2/2, and the serial pillow module
gate `.codex/pillow-gif-multiframe-module-filter-report.txt` plus
`.codex/pillow-gif-multiframe-module-filter.json` passed
`stdlib/tests/pillow.test.ahk` 163/163 at `TimeoutSeconds 90`.

The GimpGradientFile follow-up adds Pillow's public GIMP gradient reader
surface as `stdlib.pillow.GimpGradientFile`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_gimpgradientfile_probe.py` and
`.codex/pillow-gimpgradientfile-probe.output.json` records `EPSILON`, the
`SEGMENTS` order, `linear`/`curved`/`sine`/sphere curve outputs, `.ggr`
parsing with and without a `Name:` line, multi-segment RGBA palette output,
and Python error behavior for missing gradient data, `entries=1`, bad magic,
HSV colour space, bad segment index, bad count, and constructor arity. The AHK
surface exposes `GradientFile()`, `GimpGradientFile(fp)`, the curve helpers,
and `getpalette(entries)` returning `[bytes, "RGBA"]` for the covered parser
path. HSV colour spaces and broader malformed-file diagnostics remain deferred
until focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-gimpgradientfile-red-report.txt` failing because
`stdlib.pillow.GimpGradientFile` was absent, focused green
`.codex/pillow-gimpgradientfile-green-focused-report.txt` plus
`.codex/pillow-gimpgradientfile-green-focused.json` passing after
implementation, and trusted serial module gate
`.codex/pillow-gimpgradientfile-module-report.txt` plus
`.codex/pillow-gimpgradientfile-module.json` passing
`stdlib/tests/pillow.test.ahk` 114/114 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gimpgradientfile-example-report.txt` plus
`.codex/pillow-gimpgradientfile-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The GimpPaletteFile follow-up adds Pillow's public GIMP `.gpl` palette reader
surface as `stdlib.pillow.GimpPaletteFile`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_gimppalettefile_probe.py` and
`.codex/pillow-gimppalettefile-probe.output.json` records `rawmode="RGB"`,
`GimpPaletteFile(fp)`, `frombytes(data)`, `getpalette()`, field/comment line
skipping, constructor-limited 256-color parsing, unlimited `frombytes` parsing,
long-line limit behavior, and Python error behavior for bad magic, bad entries,
bad integer tokens, out-of-range byte values, and arity errors. The AHK surface
exposes `GimpPaletteFile(fp)` and `frombytes(data)` with `getpalette()`
returning `[bytes, "RGB"]` for the covered parser path. The slice is focused on
RGB byte palette loading; broader malformed-file diagnostics remain deferred
until focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-gimppalettefile-red-report.txt` plus
`.codex/pillow-gimppalettefile-red.json` failing because
`stdlib.pillow.GimpPaletteFile` was absent, focused green
`.codex/pillow-gimppalettefile-green-focused-report.txt` plus
`.codex/pillow-gimppalettefile-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-gimppalettefile-module-report.txt` plus
`.codex/pillow-gimppalettefile-module.json` passing
`stdlib/tests/pillow.test.ahk` 115/115 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gimppalettefile-example-report.txt` plus
`.codex/pillow-gimppalettefile-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The BufrStubImagePlugin follow-up adds Pillow's BUFR stub adapter surface as
`stdlib.pillow.BufrStubImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_bufrstubimageplugin_probe.py` and
`.codex/pillow-bufrstubimageplugin-probe.output.json` records `_accept(...)`
for `BUFR` and `ZCZC` prefixes, `BufrStubImageFile` format metadata, registry
effects for open/save/`.bufr`, no-handler save failure, direct invalid-file
`SyntaxError`, handler `open(...)` callbacks seeing the stub `format="BUFR"`,
`mode="F"`, `size=(1, 1)`, and handler `save(...)` callbacks receiving the
image, file-like target, and filename. The AHK surface exposes
`register_handler(...)`, `_accept(...)`, `BufrStubImageFile`, registered
`Image.open(..., ["BUFR"])`, and registered `Image.save(..., "BUFR")` for the
covered stub-handler path. Real BUFR meteorological decoding remains delegated
to user-installed handlers and is not claimed by this slice. Fresh AHK evidence
includes `.codex/pillow-bufrstubimageplugin-red-report.txt` failing because
`stdlib.pillow.BufrStubImagePlugin` was absent, focused green
`.codex/pillow-bufrstubimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-bufrstubimageplugin-module-report.txt` plus
`.codex/pillow-bufrstubimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 102/102 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-bufrstubimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The GribStubImagePlugin follow-up adds Pillow's GRIB stub adapter surface as
`stdlib.pillow.GribStubImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_gribstubimageplugin_probe.py` and
`.codex/pillow-gribstubimageplugin-probe.output.json` records `_accept(...)`
for `GRIB` prefixes with byte 8 equal to `1`, rejection of wrong marker bytes
and bad magic, short `GRIB` `IndexError("index out of range")`,
`GribStubImageFile` format metadata, registry effects for open/save/`.grib`,
no-handler save failure, direct invalid-file `SyntaxError`, handler
`open(...)` callbacks seeing the stub `format="GRIB"`, `mode="F"`,
`size=(1, 1)`, and handler `save(...)` callbacks receiving the image,
file-like target, and filename. The AHK surface exposes `register_handler(...)`,
`_accept(...)`, `GribStubImageFile`, registered `Image.open(..., ["GRIB"])`,
and registered `Image.save(..., "GRIB")` for the covered stub-handler path.
Real GRIB meteorological decoding remains delegated to user-installed handlers
and is not claimed by this slice. Fresh AHK evidence includes
`.codex/pillow-gribstubimageplugin-red-report.txt` plus
`.codex/pillow-gribstubimageplugin-red.json` failing because
`stdlib.pillow.GribStubImagePlugin` was absent, focused green
`.codex/pillow-gribstubimageplugin-green-focused-report.txt` plus
`.codex/pillow-gribstubimageplugin-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-gribstubimageplugin-module-report.txt` plus
`.codex/pillow-gribstubimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 116/116 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gribstubimageplugin-example-report.txt` plus
`.codex/pillow-gribstubimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The Hdf5StubImagePlugin follow-up adds Pillow's HDF5 stub adapter surface as
`stdlib.pillow.Hdf5StubImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_hdf5stubimageplugin_probe.py` and
`.codex/pillow-hdf5stubimageplugin-probe.output.json` records `_accept(...)`
for the eight-byte HDF5 signature `89 48 44 46 0D 0A 1A 0A`, rejection of
short and malformed prefixes, `HDF5StubImageFile` format metadata, registry
effects for open/save/`.h5`/`.hdf`, no-handler save failure, direct invalid-file
`SyntaxError("Not an HDF file")`, handler `open(...)` callbacks seeing the stub
`format="HDF5"`, `mode="F"`, `size=(1, 1)`, and handler `save(...)` callbacks
receiving the image, file-like target, and filename. The AHK surface exposes
`register_handler(...)`, `_accept(...)`, `HDF5StubImageFile`, registered
`Image.open(..., ["HDF5"])`, and registered `Image.save(..., "HDF5")` for the
covered stub-handler path. Real HDF5 dataset decoding remains delegated to
user-installed handlers and is not claimed by this slice. Fresh AHK evidence
includes `.codex/pillow-hdf5stubimageplugin-red-report.txt` plus
`.codex/pillow-hdf5stubimageplugin-red.json` failing because
`stdlib.pillow.Hdf5StubImagePlugin` was absent, focused green
`.codex/pillow-hdf5stubimageplugin-green-focused-report.txt` plus
`.codex/pillow-hdf5stubimageplugin-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-hdf5stubimageplugin-module-report.txt` plus
`.codex/pillow-hdf5stubimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 117/117 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-hdf5stubimageplugin-example-report.txt` plus
`.codex/pillow-hdf5stubimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The IcnsImagePlugin follow-up adds Pillow's Mac OS icon container surface as
`stdlib.pillow.IcnsImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_icnsimageplugin_probe.py` and
`.codex/pillow-icnsimageplugin-probe.output.json` records `MAGIC`,
`HEADERSIZE`, `enable_jpeg2k`, `_accept(...)`, `nextheader(...)`, `IcnsFile`
block dictionaries, `itersizes()`, `bestsize()`, `dataforsize(...)`,
PNG-backed `getimage(...)`, `IcnsImageFile` metadata and lazy-size behavior,
registered `.icns`/MIME/open/save effects, ICNS save TOC layout, and key
constructor/header/unsupported-subimage errors. The AHK surface exposes
`IcnsFile`, `IcnsImageFile`, `nextheader(...)`, `_accept(...)`, registered
`Image.open(..., ["ICNS"])`, and registered `Image.save(..., "ICNS")` for the
covered PNG-backed ICNS path. Legacy 32-bit RGB/RLE resources, mask merging
beyond the covered PNG path, JPEG2000 icon resources, and benchmark-backed
native acceleration remain deferred and are not claimed by this slice. Fresh
AHK evidence includes `.codex/pillow-icnsimageplugin-red-report.txt` plus
`.codex/pillow-icnsimageplugin-red.json` failing because
`stdlib.pillow.IcnsImagePlugin` was absent, focused green
`.codex/pillow-icnsimageplugin-green-report.txt` plus
`.codex/pillow-icnsimageplugin-green.json` passing after implementation,
trusted serial module gate `.codex/pillow-icnsimageplugin-module-2.json`
passing `stdlib/tests/pillow.test.ahk` 118/118 at `TimeoutSeconds 90`, and
captured example gate `.codex/pillow-icnsimageplugin-example-report.txt` plus
`.codex/pillow-icnsimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The IcoImagePlugin follow-up adds Pillow's Windows icon container surface as
`stdlib.pillow.IcoImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_icoimageplugin_probe.py` and
`.codex/pillow-icoimageplugin-probe.output.json` records `_MAGIC`,
`IconHeader._fields`, `_accept(...)` for ICO/CUR/short/empty prefixes,
PNG-backed ICO save/open output, `append_images`, `bitmap_format="bmp"`,
`IcoFile` entry parsing/sorting, `sizes()`, `getentryindex(...)`,
`getimage(...)`, frame loading, `IcoImageFile` metadata, size switching and load
behavior, registry `.ico`/MIME/open/save effects, and key constructor/bad magic
errors. The AHK surface exposes `IconHeader`, `IcoFile`, `IcoImageFile`,
registered `Image.open(..., ["ICO"])`, and registered `Image.save(..., "ICO")`
for the covered PNG-backed and BMP-DIB-backed file-like ICO paths. Full AND-mask
recovery for lower-bit-depth DIB icons, every palette edge, and
benchmark-backed native acceleration remain deferred. Fresh AHK evidence
includes `.codex/pillow-icoimageplugin-red-report.txt` plus
`.codex/pillow-icoimageplugin-red.json` failing because
`stdlib.pillow.IcoImagePlugin` was absent, focused green
`.codex/pillow-icoimageplugin-green-report.txt` plus
`.codex/pillow-icoimageplugin-green.json` passing after implementation,
trusted serial module gate `.codex/pillow-icoimageplugin-module-report.txt`
plus `.codex/pillow-icoimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 119/119 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-icoimageplugin-example-report.txt` plus
`.codex/pillow-icoimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImImagePlugin follow-up adds Pillow's IFUNC IM image-memory format surface
as `stdlib.pillow.ImImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imimageplugin_probe.py` and
`.codex/pillow-imimageplugin-probe.output.json` records public constants,
`TAGS`/`OPEN`/`SAVE` mapping entries, `number(...)`, `.im` registry effects,
text-header parsing, comments, numeric size/frame/scale metadata, L/RGB/P and
LUT-backed file-like opens, `rawmode`, multi-frame `seek(...)`/`tell(...)`,
P-mode palette round-trips, IM save output layout, and key constructor/open/save
errors. The AHK surface exposes `ImImageFile`, `number(...)`, `TAGS`, `OPEN`,
`SAVE`, registered `Image.open(..., ["IM"])`, registered
`Image.save(..., "IM")`, frame lifecycle, palette metadata, and file-like IM
read/write for the covered L/RGB/P paths. Lower-level bit-decoder variants,
legacy LabEye transpose rawmodes, every integer/float rawmode combination, and
benchmark-backed native acceleration remain deferred. Fresh AHK evidence
includes `.codex/pillow-imimageplugin-red-report.txt` plus
`.codex/pillow-imimageplugin-red.json` failing because
`stdlib.pillow.ImImagePlugin` was absent, focused green
`.codex/pillow-imimageplugin-green-report.txt` plus
`.codex/pillow-imimageplugin-green.json` passing after implementation, trusted
serial module gate `.codex/pillow-imimageplugin-module-report.txt` plus
`.codex/pillow-imimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 120/120 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-imimageplugin-example-report.txt` plus
`.codex/pillow-imimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageCms follow-up adds Pillow's color-management module surface as
`stdlib.pillow.ImageCms`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagecms_probe.py` and
`.codex/pillow-imagecms-probe.output.json` records `DESCRIPTION`, `VERSION`,
`versions()` with its Pillow 12 deprecation warning, `Intent`/`Direction`/
`Flags` enum-like values, legacy `FLAGS` values including `GRIDPOINTS(...)`,
`PyCMSError`, built-in `sRGB`/`LAB`/`XYZ` profile creation, `ImageCmsProfile`
wrapping and file-like reopening from `tobytes()`, sRGB profile metadata,
`getProfileName`/`getProfileInfo`/description/copyright/manufacturer/model,
default intent and supported-intent checks, plus sRGB-to-sRGB
`buildTransform`, `applyTransform`, in-place application, and
`profileToProfile` identity behavior that attaches `icc_profile` bytes to the
output image. The AHK surface exposes `ImageCmsProfile`, `ImageCmsTransform`,
`createProfile(...)`, `getOpenProfile(...)`, `buildTransform(...)`,
`buildTransformFromOpenProfiles(...)`, `buildProofTransform(...)` error
surface, `applyTransform(...)`, `profileToProfile(...)`, profile metadata
helpers, `get_display_profile(...)`, `versions()`, `Intent`, `Direction`,
`Flags`, and legacy `FLAGS[...]` access. Arbitrary ICC file parsing, non-sRGB
color conversion, proof transforms, display-profile discovery, native
LittleCMS/WCS integration, and benchmark-backed acceleration remain deferred.
Because AutoHotkey object property names are case-insensitive and class/instance
objects reserve `Flags`, the implementation backs both public `Flags` and
legacy `FLAGS[...]` through one enum-like object with dictionary indexing for
legacy flag names. Fresh AHK evidence includes
`.codex/pillow-imagecms-red-report.txt` plus `.codex/pillow-imagecms-red.json`
failing because `stdlib.pillow.ImageCms` was absent, focused green
`.codex/pillow-imagecms-green-report.txt` plus
`.codex/pillow-imagecms-green.json` passing after implementation, trusted
serial module gate `.codex/pillow-imagecms-module-report.txt` plus
`.codex/pillow-imagecms-module.json` passing `stdlib/tests/pillow.test.ahk`
121/121 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imagecms-example-report.txt` plus
`.codex/pillow-imagecms-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageGrab follow-up adds Pillow's Windows screen/clipboard grabber surface
as `stdlib.pillow.ImageGrab`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagegrab_probe.py` and
`.codex/pillow-imagegrab-probe.output.json` records the public `grab(...)` and
`grabclipboard()` signatures, Windows `RGB` 1x1 screen capture return shape,
keyword-option capture behavior, current empty-clipboard behavior, and the
covered `bbox`, `xdisplay`, and arity error paths. The AHK surface exposes
`grab(...)` using GDI/GDI+ screen capture into an `RGB` image with direct bbox
capture for small regions, keyword options for `bbox`, `include_layered_windows`,
`all_screens`, `xdisplay`, and `window`, plus `grabclipboard()` for CF_HDROP
file lists, PNG clipboard data, DIB clipboard data, or `None`. Cross-platform
X11/macOS grabbers, deeper window-print edge cases, broader clipboard format
ordering, and benchmark-backed Direct2D/WIC capture acceleration remain
deferred. Fresh AHK evidence includes `.codex/pillow-imagegrab-red-report.txt`
plus `.codex/pillow-imagegrab-red.json` failing because
`stdlib.pillow.ImageGrab` was absent, focused green
`.codex/pillow-imagegrab-green-report.txt` plus
`.codex/pillow-imagegrab-green.json` passing after implementation, trusted
serial module gate `.codex/pillow-imagegrab-module-report.txt` plus
`.codex/pillow-imagegrab-module.json` passing `stdlib/tests/pillow.test.ahk`
122/122 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imagegrab-example-report.txt` plus
`.codex/pillow-imagegrab-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageMorph follow-up adds Pillow's binary morphology surface as
`stdlib.pillow.ImageMorph`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imagemorph_probe.py` and
`.codex/pillow-imagemorph-probe.output.json` records module constants,
`LutBuilder` default/known-pattern LUT construction, pattern permutation,
`MorphOp.apply`, `match`, `get_on_pixels`, `load_lut`, `save_lut`, `set_lut`,
and covered error paths for bad patterns, missing LUTs, wrong LUT file sizes,
and non-`L` images. The AHK surface exposes `LUT_SIZE`, `ROTATION_MATRIX`,
`MIRROR_MATRIX`, `LutBuilder`, and `MorphOp`, including the Pillow C extension's
inner-pixel morphology rule and zero boundary behavior for `L` images. Wider
Pillow morphology image corpus parity, non-list bytearray identity quirks beyond
the covered raw LUT object case, and backend acceleration remain deferred. Fresh
AHK evidence includes `.codex/pillow-imagemorph-red-report.txt` plus
`.codex/pillow-imagemorph-red.json` failing because `stdlib.pillow.ImageMorph`
was absent, focused green `.codex/pillow-imagemorph-green-focused-report.txt`
plus `.codex/pillow-imagemorph-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-imagemorph-module-report.txt` plus
`.codex/pillow-imagemorph-module.json` passing `stdlib/tests/pillow.test.ahk`
123/123 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imagemorph-example-report.txt` plus
`.codex/pillow-imagemorph-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageQt follow-up adds Pillow's Qt image bridge surface as
`stdlib.pillow.ImageQt`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_imageqt_probe.py` and
`.codex/pillow-imageqt-probe.output.json` records the local `PySide6` / `side6`
binding selection, `rgb(...)` packing, `align8to32(...)` scanline padding,
`_toqclass_helper(...)` data/format/color-table output for covered image modes,
`toqimage(...)`, `fromqimage(...)`, `toqpixmap(...)`, `fromqpixmap(...)`, path
inputs, and the missing-argument / unsupported-mode / non-QImage error paths.
The AHK surface exposes Qt-like wrapper objects for the covered bridge behavior
without requiring a live Qt GUI runtime. Native Qt object identity, direct
PySide/PyQt interop, and broader Qt application lifecycle fidelity remain
deferred. Fresh AHK evidence includes `.codex/pillow-imageqt-red-report.txt`
plus `.codex/pillow-imageqt-red.json` failing because `stdlib.pillow.ImageQt`
was absent, focused green `.codex/pillow-imageqt-green-focused-report.txt` plus
`.codex/pillow-imageqt-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-imageqt-module-report.txt` plus
`.codex/pillow-imageqt-module.json` passing `stdlib/tests/pillow.test.ahk`
124/124 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imageqt-example-report.txt` plus
`.codex/pillow-imageqt-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageShow follow-up adds Pillow's viewer registry and viewer base surface
as `stdlib.pillow.ImageShow`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_imageshow_probe.py` and
`.codex/pillow-imageshow-probe.output.json` records the local default
`WindowsViewer` / `IPythonViewer` registration, `register(...)` append/prepend
and class-instantiation behavior, `show(...)` stopping after the first truthy
viewer, `Viewer` base format/options/get_format/get_command/show_file errors,
covered mode conversion before `show_image(...)`, Windows command generation,
and Unix display command helpers with title quoting. The AHK surface exposes
the covered registry, base viewer, Windows/Mac/Unix/XDG/Display/Gm/Eog/XV and
IPython viewer objects, plus deterministic command construction without
launching external viewer processes during tests. Real OS viewer process
lifecycle, shell execution, IPython frontend rendering, and broader platform
availability detection remain deferred. Fresh AHK evidence includes
`.codex/pillow-imageshow-red-report.txt` plus
`.codex/pillow-imageshow-red.json` failing because
`stdlib.pillow.ImageShow` was absent, focused green
`.codex/pillow-imageshow-green-focused-report.txt` plus
`.codex/pillow-imageshow-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-imageshow-module-report.txt` plus
`.codex/pillow-imageshow-module.json` passing `stdlib/tests/pillow.test.ahk`
125/125 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imageshow-example-report.txt` plus
`.codex/pillow-imageshow-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageTk follow-up adds Pillow's Tk image bridge surface as
`stdlib.pillow.ImageTk`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_imagetk_probe.py` and
`.codex/pillow-imagetk-probe.output.json` records `PhotoImage`, `BitmapImage`,
`getimage(...)`, `_get_image_from_kw(...)`, `_pyimagingtkcall(...)`, generated
`pyimageN` names, image/file/data construction, paste replacement behavior,
bitmap mode validation, and the covered missing-image / missing-size /
non-photo error paths. The AHK surface exposes an in-memory Tk-compatible bridge
without requiring a live Tk interpreter or GUI window. Native Tk object
identity, Tcl command dispatch, and full Tk lifecycle fidelity remain deferred.
Fresh AHK evidence includes `.codex/pillow-imagetk-red-report.txt` plus
`.codex/pillow-imagetk-red.json` failing because `stdlib.pillow.ImageTk` was
absent, focused green `.codex/pillow-imagetk-green-focused-report.txt` plus
`.codex/pillow-imagetk-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-imagetk-module-report.txt` plus
`.codex/pillow-imagetk-module.json` passing `stdlib/tests/pillow.test.ahk`
126/126 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imagetk-example-report.txt` plus
`.codex/pillow-imagetk-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImageWin follow-up adds Pillow's Windows DIB display bridge surface as
`stdlib.pillow.ImageWin`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_imagewin_probe.py` and
`.codex/pillow-imagewin-probe.output.json` records public names, `HDC`/`HWND`
handle wrappers, `Dib` construction from modes and images, local backend mode
normalization (`RGBA`/`CMYK` to `RGB` and `P` rejected as `ValueError` on this
machine), BGR/gray display-memory `tobytes(...)` with 4-byte scanline padding,
`frombytes(...)`, boxed and full-image `paste(...)`, `draw(...)`,
`expose(...)`, `query_palette(...)`, and the covered handle / size / mode error
paths. The AHK surface exposes `HDC`, `HWND`, `Dib`, `Window`, and
`ImageWindow` wrappers without creating real OS windows during tests. Native
Windows DC blitting, real window message loops, palette realization, and
hardware-display side effects remain deferred. Fresh AHK evidence includes
`.codex/pillow-imagewin-red-report.txt` plus `.codex/pillow-imagewin-red.json`
failing because `stdlib.pillow.ImageWin` was absent, focused green
`.codex/pillow-imagewin-green-focused-report.txt` plus
`.codex/pillow-imagewin-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-imagewin-module-report.txt` plus
`.codex/pillow-imagewin-module.json` passing `stdlib/tests/pillow.test.ahk`
127/127 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-imagewin-example-report.txt` plus
`.codex/pillow-imagewin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The ImtImagePlugin follow-up adds Pillow's IM Tools grayscale image plugin
surface as `stdlib.pillow.ImtImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_imtimageplugin_probe.py` and
`.codex/pillow-imtimageplugin-probe.output.json` records the public names,
`field` pattern, `ImtImageFile` format metadata, direct constructor behavior,
`Image.open(..., ["IMT"])` registry behavior, the absence of an IMT extension
registration, `raw` tile metadata, L-mode pixel loading, and the covered
`SyntaxError`/`OSError` paths for non-text headers, unsupported `pixel n16`, and
truncated payloads. The AHK surface exposes `field`, `ImtImageFile`, registered
`Image.open(..., ["IMT"])`, no `.imt` extension, prefix accept filtering so
unrelated image opens fall through to other decoders, and path/file-like parsing
without relying on Python-only file methods. Fresh AHK evidence includes
`.codex/pillow-imtimageplugin-red-report.txt` plus
`.codex/pillow-imtimageplugin-red.json` failing because
`stdlib.pillow.ImtImagePlugin` was absent, focused green
`.codex/pillow-imtimageplugin-green-focused-report.txt` plus
`.codex/pillow-imtimageplugin-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-imtimageplugin-module-report.txt` plus
`.codex/pillow-imtimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 128/128 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-imtimageplugin-example-report.txt` plus
`.codex/pillow-imtimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions. The
example gate now includes the example file directly in the outer ahktest wrapper
instead of starting a nested AutoHotkey process, so warning/error output remains
captured by `tools\run-ahktest.ps1` without child-process popups.

The IptcImagePlugin follow-up adds Pillow's IPTC/NAA datastream surface as
`stdlib.pillow.IptcImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_iptcimageplugin_probe.py` and
`.codex/pillow-iptcimageplugin-probe.output.json` records `COMPRESSION`,
`_i`, `_i8`, `i16`, `i32`, deprecated `i`/`dump`/`PAD`, `IptcImageFile`
format metadata, `.iim` extension registration, duplicate IPTC metadata tag
aggregation, `getiptcinfo`, raw L pixel loading, direct construction,
`Image.open(..., ["IPTC"])`, and the covered bad magic, bad compression,
illegal field length, and missing-fp errors. The AHK surface exposes the same
covered helper surface, parses IPTC field headers with string keys for tuple
tags, preserves duplicate metadata as lists of byte arrays, uses `BytesIO` for
file-like fixtures, and registers an accept predicate so bad IPTC prefixes fall
through to `cannot identify image file` under `Image.open(...)` without a GUI
popup. JPEG-compressed IPTC tile decoding, TIFF/JPEG embedded IPTC extraction,
and broader malformed-field edge cases remain deferred until fresh probes cover
them. Fresh AHK evidence includes `.codex/pillow-iptcimageplugin-red-report.txt`
plus `.codex/pillow-iptcimageplugin-red.json` failing because
`stdlib.pillow.IptcImagePlugin` was absent, final focused green
`.codex/pillow-iptcimageplugin-final-focused-report.txt` plus
`.codex/pillow-iptcimageplugin-final-focused.json` passing 1/1 after implementation,
trusted serial module gate `.codex/pillow-iptcimageplugin-final-module-report.txt`
plus `.codex/pillow-iptcimageplugin-final-module.json` passing
`stdlib/tests/pillow.test.ahk` 129/129 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-iptcimageplugin-final-example-report.txt` plus
`.codex/pillow-iptcimageplugin-final-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The Jpeg2KImagePlugin follow-up adds Pillow's JPEG 2000 metadata plugin surface
as `stdlib.pillow.Jpeg2KImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_jpeg2kimageplugin_probe.py` and
`.codex/pillow-jpeg2kimageplugin-probe.output.json` records public
`BoxReader`, `Jpeg2KImageFile`, `_accept`, `_save`, JPEG2000 format metadata,
JP2 and J2K prefix acceptance, `.jp2`/`.j2k`/`.jpc`/`.jpf`/`.jpx`/`.j2c`
extension registration, MIME `image/jp2`, resolution-box DPI conversion,
JP2/JPX header metadata including custom mimetype and CMYK colr mapping, J2K
codestream size/mode/comment metadata, nested box reading, and covered bad magic,
invalid box, short-read, open fallback, and missing-fp errors. The AHK surface
parses synthetic JP2/J2K byte streams through `stdlib.io.BytesIO`, exposes
direct construction and `Image.open(..., ["JPEG2000"])`, preserves Pillow-shaped
tile descriptors, and keeps `_save` registered with Pillow's covered encoder
unavailable error. Full JPEG 2000 pixel codestream decoding/encoding, advanced
boxes, multi-tile image data, color management beyond the covered metadata, and
performance claims remain deferred until fresh probes and WIC/codec-backed
implementation evidence cover them. Fresh AHK evidence includes
`.codex/pillow-jpeg2kimageplugin-red-report.txt` plus
`.codex/pillow-jpeg2kimageplugin-red.json` failing because
`stdlib.pillow.Jpeg2KImagePlugin` was absent, final focused green
`.codex/pillow-jpeg2kimageplugin-final-focused-report.txt` plus
`.codex/pillow-jpeg2kimageplugin-final-focused.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-jpeg2kimageplugin-final-module-report.txt` plus
`.codex/pillow-jpeg2kimageplugin-final-module.json` passing
`stdlib/tests/pillow.test.ahk` 130/130 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-jpeg2kimageplugin-final-example-report.txt` plus
`.codex/pillow-jpeg2kimageplugin-final-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The JpegImagePlugin follow-up adds Pillow's JPEG metadata plugin surface as
`stdlib.pillow.JpegImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_jpegimageplugin_probe.py` and
`.codex/pillow-jpegimageplugin-probe.output.json` records public `APP`, `COM`,
`DQT`, `SOF`, `Skip`, `JpegImageFile`, `RAWMODE`, `MARKER`, `_accept`, `_save`,
`_save_cjpeg`, `get_sampling`, `jpeg_factory`, `i16`, `i32`, `o8`, `o16`,
`samplings`, and `zigzag_index`, plus JPEG registry effects, JFIF density/DPI,
SOF layer/sampling metadata, quantization table ordering, direct `BytesIO`
construction, and `Image.open(..., ["JPEG"])` behavior. The AHK surface parses
covered JPEG marker streams without invoking pixel decode for metadata-only
inputs, delegates covered file-like JPEG saves to the existing GDI+ output
bridge, and keeps command-line `cjpeg` save behavior explicitly unsupported.
Full JPEG encoder controls, EXIF/ICC/MP marker coverage, progressive and
restart-marker edge cases, rendered metadata-only scan decoding, full command
line `cjpeg` integration, and benchmark-backed native acceleration remain
deferred until fresh probes and backend evidence cover them. Fresh AHK evidence
includes `.codex/pillow-jpegimageplugin-red-report.txt` plus
`.codex/pillow-jpegimageplugin-red.json` failing because
`stdlib.pillow.JpegImagePlugin` was absent, final focused green
`.codex/pillow-jpegimageplugin-final-focused-report.txt` plus
`.codex/pillow-jpegimageplugin-final-focused.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-jpegimageplugin-final-module-report.txt` plus
`.codex/pillow-jpegimageplugin-final-module.json` passing
`stdlib/tests/pillow.test.ahk` 131/131 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-jpegimageplugin-final-example-report.txt` plus
`.codex/pillow-jpegimageplugin-final-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The McIdasImagePlugin follow-up adds Pillow's MCIDAS area-file metadata surface
as `stdlib.pillow.McIdasImagePlugin`. Fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_mcidasimageplugin_probe.py` and
`.codex/pillow-mcidasimageplugin-probe.output.json` records public
`McIdasImageFile`, `_accept`, MCIDAS format metadata, Image registry behavior
without default extension or MIME registration, big-endian area descriptor
parsing, 1-byte `L` pixel loads, 2-byte `I;16B` and 4-byte `I` raw tile
metadata, and Pillow's bad magic, unsupported bytes-per-pixel, missing-fp, and
extra-argument errors. The AHK surface mirrors those covered descriptor,
registry, direct `BytesIO`, and `Image.open(..., ["MCIDAS"])` paths while
leaving broader satellite-product semantics deferred until fresh probes cover
them. Fresh AHK evidence includes `.codex/pillow-mcidasimageplugin-red-report.txt`
plus `.codex/pillow-mcidasimageplugin-red.json` failing because
`stdlib.pillow.McIdasImagePlugin` was absent, final focused green
`.codex/pillow-mcidasimageplugin-final-focused-report.txt` plus
`.codex/pillow-mcidasimageplugin-final-focused.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-mcidasimageplugin-module-report.txt` plus
`.codex/pillow-mcidasimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 132/132 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-mcidasimageplugin-example-2-report.txt` plus
`.codex/pillow-mcidasimageplugin-example-2.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The MicImagePlugin follow-up adds Pillow's Microsoft Image Composer container
surface as `stdlib.pillow.MicImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_micimageplugin_probe.py` and
`.codex/pillow-micimageplugin-probe.output.json` records public
`MicImageFile`, `TiffImagePlugin`, `_accept`, the OLE magic prefix, `.mic`
extension registration, no MIME registration, constructor arity errors using
Pillow's `TiffImageFile.__init__` wording, invalid-OLE and no-image-entry
`SyntaxError` paths, fake-OLE `.ACI/Image` TIFF stream loading, close behavior,
and `Image.open(..., ["MIC"])` fallback to unidentified-image errors when the
registered factory rejects a candidate. The AHK surface mirrors the covered
OLE adapter shape with an injectable `olefile` module, routes `.ACI/Image`
streams through the existing TIFF byte-stream decoder, and intentionally leaves
real OLE directory parsing deferred until native OLE evidence covers it.
Fresh AHK evidence includes `.codex/pillow-micimageplugin-red-report.txt` plus
`.codex/pillow-micimageplugin-red.json` failing because
`stdlib.pillow.MicImagePlugin` was absent, focused green
`.codex/pillow-micimageplugin-green-focused-2-report.txt` plus
`.codex/pillow-micimageplugin-green-focused-2.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-micimageplugin-module-1-report.txt` plus
`.codex/pillow-micimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 133/133 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-micimageplugin-example-2-report.txt` plus
`.codex/pillow-micimageplugin-example-2.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The MpegImagePlugin follow-up adds Pillow's MPEG stream identifier surface as
`stdlib.pillow.MpegImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_mpegimageplugin_probe.py` and
`.codex/pillow-mpegimageplugin-probe.output.json` records public `BitStream`,
`MpegImageFile`, `_accept`, MPEG sequence-header magic, bit-level
peek/read/skip/next behavior, `.mpg`/`.mpeg` extension registration,
`video/mpeg` MIME registration, RGB mode and size metadata from 12-bit
width/height fields, empty tile metadata, Pillow's non-decoding
`load()` -> `OSError("cannot load this image")` behavior, and bad magic,
short stream, missing-fp, arity, and unidentified-image fallback errors. The
AHK surface mirrors the covered metadata-only parser and keeps actual MPEG
video decoding explicitly out of scope until fresh probes and a backend
evidence path cover it. Fresh AHK evidence includes
`.codex/pillow-mpegimageplugin-red-report.txt` plus
`.codex/pillow-mpegimageplugin-red.json` failing because
`stdlib.pillow.MpegImagePlugin` was absent, focused green
`.codex/pillow-mpegimageplugin-green-focused-3-report.txt` plus
`.codex/pillow-mpegimageplugin-green-focused-3.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-mpegimageplugin-module-report.txt` plus
`.codex/pillow-mpegimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 134/134 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-mpegimageplugin-example-report.txt` plus
`.codex/pillow-mpegimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The MpoImagePlugin follow-up adds Pillow's Multi-Picture Object surface as
`stdlib.pillow.MpoImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_mpoimageplugin_probe.py` and
`.codex/pillow-mpoimageplugin-probe.output.json` records `MpoImageFile`,
`_save`, `_save_all`, MPF APP2 metadata parsing, no standalone `MPO` open/id
registration, `.mpo` extension and `image/mpo` MIME registration, JPEG-factory
`Image.open(..., ["JPEG"])` promotion to `MPO`, `formats=["MPO"]` `KeyError`,
`adopt(...)` same-object promotion, `n_frames`/`is_animated`/`readonly`,
`seek(...)`/`tell(...)`, malformed MPO errors, and single-frame JPEG-style plus
multi-frame MPF file-like save behavior. The AHK surface mirrors the covered
container behavior while keeping per-frame JPEG decoding delegated to the
existing JPEG/WIC path. Fresh AHK evidence includes
`.codex/pillow-mpoimageplugin-red-report.txt` plus
`.codex/pillow-mpoimageplugin-red.json` failing because
`stdlib.pillow.MpoImagePlugin` was absent, final validate evidence
`.codex/pillow-mpoimageplugin-final-validate-report.txt` passing
`stdlib/pillow.ahk`, `stdlib/tests/pillow.test.ahk`,
`stdlib/examples/pillow.ahk`, and `.codex/pillow_example_capture.test.ahk`,
focused final gate `.codex/pillow-mpoimageplugin-final-focused-report.txt`
plus `.codex/pillow-mpoimageplugin-final-focused.json` passing 1/1,
trusted serial module gate `.codex/pillow-mpoimageplugin-final-module-report.txt`
plus `.codex/pillow-mpoimageplugin-final-module.json` passing
`stdlib/tests/pillow.test.ahk` 135/135 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-mpoimageplugin-final-example-report.txt` plus
`.codex/pillow-mpoimageplugin-final-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.
The save_all sequence follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_mpo_saveall_sequence_probe.py` and
`.codex/pillow_mpo_saveall_sequence_probe.output.json` confirming that an
already-open animated MPO source saved again with `save_all=True` expands its
own `ImageSequence` frames, returns `None`, writes an MPF-backed two-frame MPO,
reopens as `MPO` with `n_frames == 2`, keeps seek-out-of-range as
`EOFError("attempt to seek outside sequence")`, and leaves the source positioned
on frame 1 after iteration. The AHK `_save_all` path now expands the source and
each `append_images` sequence through the existing ImageSequence iterator before
building the MPF byte stream. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-saveall-sequence-red-report.txt` plus
`.codex/pillow-mpo-saveall-sequence-red.json` failing because the resaved stream
lacked `MPF`, focused green
`.codex/pillow-mpo-saveall-sequence-green-focused-report.txt` plus
`.codex/pillow-mpo-saveall-sequence-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-saveall-sequence-mpo-filter-report.txt` plus
`.codex/pillow-mpo-saveall-sequence-mpo-filter.json` passing 2/2, captured
example gate `.codex/pillow-mpo-saveall-sequence-example-report.txt` plus
`.codex/pillow-mpo-saveall-sequence-example.json` passing 2/2, and serial
pillow module gate `.codex/pillow-mpo-saveall-sequence-module-filter-report.txt`
plus `.codex/pillow-mpo-saveall-sequence-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 164/164 at `TimeoutSeconds 90`.

The seek type-rule follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_mpo_seek_type_probe.py` and
`.codex/pillow_mpo_seek_type_probe.output.json` confirming
`MpoImageFile.seek(...)` behavior for `"1"`, `1.2`, `None`, `[]`, `True`, and
`False`: string/`None`/list values fail in Python's `<` comparison with
type-specific `TypeError` messages, an in-range float fails during frame-offset
indexing with `TypeError("list indices must be integers or slices, not float")`,
and bool values are accepted as frame numbers. The AHK `seek(...)` path now
preserves those covered public errors while keeping ordinary EOF bounds errors
unchanged. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-seek-type-red-report.txt` plus
`.codex/pillow-mpo-seek-type-red.json` failing because `"1"` was coerced and no
exception was thrown, focused green
`.codex/pillow-mpo-seek-type-green-focused-report.txt` plus
`.codex/pillow-mpo-seek-type-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-seek-type-mpo-filter-report.txt` plus
`.codex/pillow-mpo-seek-type-mpo-filter.json` passing 3/3, captured example
gate `.codex/pillow-mpo-seek-type-example-report.txt` plus
`.codex/pillow-mpo-seek-type-example.json` passing 2/2, and serial pillow
module gate `.codex/pillow-mpo-seek-type-module-filter-report.txt` plus
`.codex/pillow-mpo-seek-type-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 165/165 at `TimeoutSeconds 90`.

The `_getmp()` follow-up uses fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_mpo_getmp_probe.py` and
`.codex/pillow_mpo_getmp_probe.output.json` confirming ordinary JPEG
`JpegImageFile._getmp()` returns `None`, MPO images opened through
`Image.open(..., formats=["JPEG"])` keep `info["mp"]`, `_getmp()` returns a
new MP dict rather than `im.mpinfo`, malformed raw MP TIFF data without
`0xB001` raises `SyntaxError("malformed MP Index (no number of images)")`, and
bound extra arguments raise Pillow's `JpegImageFile._getmp()` arity
`TypeError`. The AHK JPEG image class now exposes `_getmp()`, MPO adoption
keeps an `info["mp"]` clone, and the covered malformed raw MP data path raises
the probed `SyntaxError`. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-getmp-red-report.txt` plus
`.codex/pillow-mpo-getmp-red.json` failing because `info["mp"]` was absent,
focused green `.codex/pillow-mpo-getmp-green-focused-report.txt` plus
`.codex/pillow-mpo-getmp-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-getmp-mpo-filter-report.txt` plus
`.codex/pillow-mpo-getmp-mpo-filter.json` passing 4/4, captured example gate
`.codex/pillow-mpo-getmp-example-report.txt` plus
`.codex/pillow-mpo-getmp-example.json` passing 2/2, and serial pillow module
gate `.codex/pillow-mpo-getmp-module-filter-report.txt` plus
`.codex/pillow-mpo-getmp-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 166/166 at `TimeoutSeconds 90`.

The MP Entry Attribute follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_mpo_attribute_probe.py` and
`.codex/pillow_mpo_attribute_probe.output.json` confirming Pillow's bitfield
parsing for `DependentParentImageFlag`, `DependentChildImageFlag`,
`RepresentativeImageFlag`, `Reserved`, `ImageDataFormat`, mapped MP types such
as `Multi-Frame Image: (Multi-Angle)` and `Large Thumbnail (Full HD
Equivalent)`, unknown MP types, and malformed-MPO fallback behavior where an
unsupported non-JPEG image-data format emits `UserWarning("Image appears to be a
malformed MPO file, it will be interpreted as a base JPEG file")` and returns a
base JPEG object while retaining `info["mp"]`. The AHK MPO parser now mirrors
the covered attribute map, validates unsupported image-data formats during MPO
promotion, and lets the JPEG factory warn and return the base JPEG for that
covered malformed-MPO path. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-attribute-red-report.txt` plus
`.codex/pillow-mpo-attribute-red.json` failing because the first parsed flag was
false, focused green `.codex/pillow-mpo-attribute-green-focused-report.txt`
plus `.codex/pillow-mpo-attribute-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-attribute-mpo-filter-report.txt` plus
`.codex/pillow-mpo-attribute-mpo-filter.json` passing 5/5, captured example
gate `.codex/pillow-mpo-attribute-example-report.txt` plus
`.codex/pillow-mpo-attribute-example.json` passing 2/2, and serial pillow
module gate `.codex/pillow-mpo-attribute-module-filter-report.txt` plus
`.codex/pillow-mpo-attribute-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 167/167 at `TimeoutSeconds 90`.

The Ultra HDR APP1 follow-up uses fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_mpo_ultrahdr_probe.py` and
`.codex/pillow_mpo_ultrahdr_probe.output.json` confirming the JPEG factory's
special MPO handling: ordinary MPO bytes opened through
`Image.open(..., formats=["JPEG"])` promote to `MPO`; bytes with an APP1 payload
containing ` hdrgm:Version="` stay as a base `JPEG` object with no `n_frames`
while retaining `info["mp"]`; bytes with an APP1 payload lacking that HDRGM
marker still promote to `MPO`; and direct `MpoImagePlugin.MpoImageFile(...)`
still promotes the HDRGM-marked bytes to `MPO` with two frames. The AHK JPEG
factory now detects the covered Ultra HDR APP1 marker before MPO adoption when
called through the JPEG fallback path, while the direct MPO constructor keeps
using the non-fallback path. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-ultrahdr-red-report.txt` plus
`.codex/pillow-mpo-ultrahdr-red.json` failing because HDRGM-marked bytes still
promoted to `MPO`, focused green
`.codex/pillow-mpo-ultrahdr-green-focused-report.txt` plus
`.codex/pillow-mpo-ultrahdr-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-ultrahdr-mpo-filter-report.txt` plus
`.codex/pillow-mpo-ultrahdr-mpo-filter.json` passing 6/6, captured example gate
`.codex/pillow-mpo-ultrahdr-example-report.txt` plus
`.codex/pillow-mpo-ultrahdr-example.json` passing 2/2, and serial pillow module
gate `.codex/pillow-mpo-ultrahdr-module-filter-report.txt` plus
`.codex/pillow-mpo-ultrahdr-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 168/168 at `TimeoutSeconds 90`.

The MPO `load_seek(...)` follow-up uses fresh local Python 3.10.11 plus Pillow
11.3.0 evidence from `.codex/pillow_mpo_load_seek_probe.py` and
`.codex/pillow_mpo_load_seek_probe.output.json` confirming that direct
`MpoImagePlugin.MpoImageFile(...)` and JPEG-factory MPO images expose the
underlying file pointer through `fp.tell()`: `load_seek(pos)` returns `None` and
moves that pointer to `pos`, frame `seek(1)` moves it to the second-frame byte
offset, negative positions raise `ValueError("negative seek value -1")`, and
missing `pos` raises Pillow's bound-method `TypeError`. The AHK JPEG/MPO path
now keeps a file-like `fp` on opened JPEG images, carries it through MPO
adoption, moves it on frame `seek(...)`, and delegates MPO `load_seek(...)` to
that file-like object's `seek(...)`. Fresh AHK evidence includes focused red
`.codex/pillow-mpo-load-seek-red-report.txt` plus
`.codex/pillow-mpo-load-seek-red.json` failing because the MPO image lacked a
public `fp`, focused green `.codex/pillow-mpo-load-seek-green-focused-report.txt`
plus `.codex/pillow-mpo-load-seek-green-focused.json` passing 1/1, MPO filter
`.codex/pillow-mpo-load-seek-mpo-filter-report.txt` plus
`.codex/pillow-mpo-load-seek-mpo-filter.json` passing 7/7, captured example
gate `.codex/pillow-mpo-load-seek-example-report.txt` plus
`.codex/pillow-mpo-load-seek-example.json` passing 2/2, and serial pillow
module gate `.codex/pillow-mpo-load-seek-module-filter-report.txt` plus
`.codex/pillow-mpo-load-seek-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 169/169 at `TimeoutSeconds 90`.

The MspImagePlugin follow-up adds Pillow's Windows Paint MSP surface as
`stdlib.pillow.MspImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_mspimageplugin_probe.py` and
`.codex/pillow-mspimageplugin-probe.output.json` records `MspImageFile`,
`MspDecoder`, `_accept`, `_save`, DanM raw and LinS RLE signatures, `.msp`
extension/open/save/decoder registration, no MIME registration, mode `1`
row-padded byte behavior, raw/RLE file-like open summaries, zero-length RLE row
handling, MSP file-like save output, and bad magic/checksum/truncated row-map,
truncated row, corrupted row, unsupported save mode, and arity error paths.
The AHK surface mirrors those covered paths and updates the shared mode `1`
raw byte bridge to use Pillow-style row padding for non-byte-aligned widths.
Fresh AHK evidence includes `.codex/pillow-mspimageplugin-red-report.txt` plus
`.codex/pillow-mspimageplugin-red.json` failing because
`stdlib.pillow.MspImagePlugin` was absent, focused green
`.codex/pillow-mspimageplugin-green-5-report.txt` plus
`.codex/pillow-mspimageplugin-green-5.json` passing 1/1, trusted serial module
gate `.codex/pillow-mspimageplugin-module-1-report.txt` plus
`.codex/pillow-mspimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 136/136 at `TimeoutSeconds 90`, final validate
`.codex/pillow-mspimageplugin-validate-2-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-mspimageplugin-example-1-report.txt` plus
`.codex/pillow-mspimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PaletteFile follow-up adds Pillow's Teragon-style palette reader surface
as `stdlib.pillow.PaletteFile`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_palettefile_probe.py` and
`.codex/pillow_palettefile_probe.output.json` records `PaletteFile(fp)`,
default 256-entry grayscale RGB palette construction, comment-line skipping,
Python `bytes.split()` whitespace handling, two-field gray shorthand,
four-field RGB replacement, ignored out-of-range palette indexes, `_binary.o8`
wraparound for component values, `getpalette()` returning `(palette, "RGB")`,
and long-line, empty-line, invalid-int, bad field-count, constructor arity, and
`getpalette` arity error paths. The AHK implementation mirrors this parser as
an independent module with no `Image.open` or save registration. Fresh AHK
evidence includes `.codex/pillow-palettefile-red-report.txt` plus
`.codex/pillow-palettefile-red.json` failing because
`stdlib.pillow.PaletteFile` was absent, focused green
`.codex/pillow-palettefile-green-focused-report.txt` plus
`.codex/pillow-palettefile-green-focused.json` passing 1/1, captured example
gate `.codex/pillow-palettefile-example-report.txt` plus
`.codex/pillow-palettefile-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions, and
trusted serial module gate `.codex/pillow-palettefile-module-filter-report.txt`
plus `.codex/pillow-palettefile-module-filter.json` passing the Pillow-filtered
`stdlib/tests` gate 159/159 at `TimeoutSeconds 90`.

The PcfFontFile follow-up adds Pillow's portable compiled font reader surface
as `stdlib.pillow.PcfFontFile`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_pcffontfile_probe.py` and
`.codex/pillow_pcffontfile_probe.output.json` records the PCF constants,
`BYTES_PER_ROW`, `sz(...)`, compressed metrics, property string/int parsing,
bitmap row-padding and bit-order behavior for mode `1` glyphs, BDF encoding
mapping, inherited `FontFile.compile()` metric packing, and bad magic, wrong
bitmap count, constructor arity, and missing-null `sz` error paths. The AHK
implementation mirrors the covered bitmap-font reader and keeps PCF independent
from `Image.open` registration, matching Pillow's font-file module shape.
Fresh AHK evidence includes `.codex/pillow-pcffontfile-red-report.txt` plus
`.codex/pillow-pcffontfile-red.json` failing because
`stdlib.pillow.PcfFontFile` was absent, focused green
`.codex/pillow-pcffontfile-green-focused-report.txt` plus
`.codex/pillow-pcffontfile-green-focused.json` passing 1/1, and trusted serial
module gate `.codex/pillow-pcffontfile-module-filter-report.txt` plus
`.codex/pillow-pcffontfile-module-filter.json` passing the Pillow-filtered
`stdlib/tests/pillow.test.ahk` gate 159/159 at `TimeoutSeconds 90`. The promotion also updates
`stdlib/examples/pillow.ahk` and the captured example regression to exercise PCF
constants, helpers, glyph pixels, and compile output.

The PSDraw follow-up adds Pillow's PostScript drawing writer surface as
`stdlib.pillow.PSDraw`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_psdraw_probe.py` and
`.codex/pillow_psdraw_probe.output.json` records `PSDraw.PSDraw`
construction, file-like output, `EDROFF_PS`, `VDI_PS`, and `ERROR_PS` byte
constants, document lifecycle output, ISO font setup and reencode caching,
line, rectangle, and text PostScript operators, EPS image delegation, and
missing-coordinate, short-rectangle, non-string text, setfont-before-document,
bad-image, and constructor/order error paths. The AHK surface exposes
`stdlib.pillow.PSDraw`, the three PostScript constant byte strings, file-like
writer behavior, and covered EPS image output through the existing EPS save
bridge. Fresh AHK evidence includes `.codex/pillow-psdraw-red-report.txt` plus
`.codex/pillow-psdraw-red.json` failing because `stdlib.pillow.PSDraw` was
absent, focused green `.codex/pillow-psdraw-green-focused-report.txt` plus
`.codex/pillow-psdraw-green-focused.json` passing 1/1, trusted serial module
gate `.codex/pillow-psdraw-module-filter-report.txt` plus
`.codex/pillow-psdraw-module-filter.json` passing the Pillow-filtered
`stdlib/tests/pillow.test.ahk` gate 160/160 at `TimeoutSeconds 90`, and
captured example gate `.codex/pillow-psdraw-example-report.txt` plus
`.codex/pillow-psdraw-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output.

The TarIO follow-up adds Pillow's tar-subfile stream reader surface as
`stdlib.pillow.TarIO`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_tario_probe.py` and
`.codex/pillow_tario_probe.output.json` records public `TarIO.TarIO`
construction from a tar path and member name, 512-byte header scanning, member
names from the first 100 header bytes, octal file sizes from the tar size
field, data offsets, bounded reads through `ContainerIO`, `read`, `readline`,
`seek`, `tell`, `readable`, `writable`, `seekable`, `isatty`, `close`, empty
members, missing members, empty headers, truncated archives, missing tar files,
and constructor arity errors. The AHK surface exposes `stdlib.pillow.TarIO`
with a prefixed `AhkStdlibPillowTarIO` class, reuses the covered
`ContainerIO` region reader, and keeps the member stream independent from image
format registration. Fresh AHK evidence includes
`.codex/pillow-tario-red-report.txt` plus `.codex/pillow-tario-red.json`
failing because `stdlib.pillow.TarIO` was absent, focused green
`.codex/pillow-tario-green-focused-report.txt` plus
`.codex/pillow-tario-green-focused.json` passing 1/1, captured example gate
`.codex/pillow-tario-example-report.txt` plus
`.codex/pillow-tario-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions, and
trusted serial module gate `.codex/pillow-tario-module-filter-report.txt` plus
`.codex/pillow-tario-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 161/161 at `TimeoutSeconds 90`.

The PdfParser follow-up adds Pillow's low-level PDF helper surface as
`stdlib.pillow.PdfParser`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_pdfparser_probe.py` and
`.codex/pillow_pdfparser_probe.output.json` records public names,
`encode_text`, `decode_text`, `PdfFormatError`, `check_format_condition`,
`IndirectReference`, `IndirectObjectDef`, `PdfName`, `PdfArray`, `PdfDict`,
`PdfBinary`, `PdfStream`, `pdf_repr`, `XrefTable`, and minimal `PdfParser`
writer behavior. The AHK surface uses prefixed internal classes, exposes the
module at `stdlib.pillow.PdfParser`, and treats `stdlib.True` /
`stdlib.False` as Python bool values so ordinary AHK `1` and `0` remain PDF
numbers. Fresh AHK evidence includes `.codex/pillow-pdfparser-red-report.txt`
plus `.codex/pillow-pdfparser-red.json` failing because
`stdlib.pillow.PdfParser` was absent, focused green
`.codex/pillow-pdfparser-green-focused-report.txt` plus
`.codex/pillow-pdfparser-green-focused.json` passing 1/1, captured example
gate `.codex/pillow-pdfparser-example-report.txt` plus
`.codex/pillow-pdfparser-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions, and
trusted serial module gate `.codex/pillow-pdfparser-module-filter-report.txt`
plus `.codex/pillow-pdfparser-module-filter.json` passing
`stdlib/tests/pillow.test.ahk` 162/162 at `TimeoutSeconds 90`.

The report follow-up adds Pillow's `PIL.report` public entry point as
`stdlib.pillow.report`. Fresh local Python 3.10.11 plus Pillow 11.3.0 evidence
from `.codex/pillow_report_probe.py` and
`.codex/pillow_report_probe.output.json` records `public_names == ["pilinfo"]`,
`report.pilinfo is features.pilinfo`, import-time `features.pilinfo(false)`
stdout behavior in Python, support-summary output containing
`Pillow 11.3.0` and `--- TKINTER support ok`, and optional supported-format
output containing `JPEG image/jpeg`. The AHK surface exposes
`stdlib.pillow.report.pilinfo(...)` as a delegated alias of
`stdlib.pillow.features.pilinfo(...)`, while avoiding automatic stdout on
include/access so examples and tests stay quiet. Fresh AHK evidence includes
`.codex/pillow-report-red-report.txt` plus `.codex/pillow-report-red.json`
failing because `stdlib.pillow.report` was absent, focused green
`.codex/pillow-report-green-focused-report.txt` plus
`.codex/pillow-report-green-focused.json` passing 1/1, captured example gate
`.codex/pillow-report-example-report.txt` plus
`.codex/pillow-report-example.json` passing `.codex/pillow_example_capture.test.ahk`
2/2 without warning/error output and with System.Text.RegularExpressions /
MatchEvaluator pollution assertions, and trusted serial module gate
`.codex/pillow-report-module-filter-report.txt` plus
`.codex/pillow-report-module-filter.json` passing `stdlib/tests/pillow.test.ahk`
163/163 at `TimeoutSeconds 90`.

The PalmImagePlugin follow-up adds Pillow's output-only Palm pixmap save
surface as `stdlib.pillow.PalmImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_palmimageplugin_probe.py` and
`.codex/pillow-palmimageplugin-probe.output.json` records
`_Palm8BitColormapValues`, `build_prototype_image`,
`Palm8BitColormapImage`, `_FLAGS`, `_COMPRESSION_TYPES`, `_save`, uppercase
`PALM` save registration, `.palm` extension registration, `image/palm` MIME
registration, no open/id registration, mode `1` inverted row-padded Palm
file-like saves, `P` mode custom-colormap file-like saves, empty-palette `P`
save behavior, and current Pillow 11.3.0 `L`/invalid-mode/arity error paths.
The AHK implementation mirrors the covered output-only behavior and keeps the
Palm colormap generated from the same 256-entry ordering as Pillow. Fresh AHK
evidence includes `.codex/pillow-palmimageplugin-red-report.txt` plus
`.codex/pillow-palmimageplugin-red.json` failing because
`stdlib.pillow.PalmImagePlugin` was absent, focused green
`.codex/pillow-palmimageplugin-green-1-report.txt` plus
`.codex/pillow-palmimageplugin-green-1.json` passing 1/1, trusted serial module
gate `.codex/pillow-palmimageplugin-module-1-report.txt` plus
`.codex/pillow-palmimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 137/137 at `TimeoutSeconds 90`, final validate
`.codex/pillow-palmimageplugin-validate-2-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-palmimageplugin-example-1-report.txt` plus
`.codex/pillow-palmimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PcdImagePlugin follow-up adds Pillow's Kodak PhotoCD metadata loader
surface as `stdlib.pillow.PcdImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_pcdimageplugin_probe.py` and
`.codex/pillow-pcdimageplugin-probe.output.json` records `PcdImageFile`,
registered `.pcd` extension/open behavior with no accept function, `PCD` id
registration, RGB 768x512 metadata, `pcd` tile metadata at offset `96 * 2048`,
orientation post-rotate metadata for values 1 and 3, `load_end()` behavior for
the covered metadata-only path, no-pixel-data `load()` errors, and bad
magic/short file/arity/formats error paths. The AHK implementation mirrors the
covered metadata-only behavior and intentionally leaves real PhotoCD pixel
decoding to a future backend slice. Fresh AHK evidence includes
`.codex/pillow-pcdimageplugin-red-report.txt` plus
`.codex/pillow-pcdimageplugin-red.json` failing because
`stdlib.pillow.PcdImagePlugin` was absent, focused green
`.codex/pillow-pcdimageplugin-green-2-report.txt` plus
`.codex/pillow-pcdimageplugin-green-2.json` passing 1/1, trusted serial module
gate `.codex/pillow-pcdimageplugin-module-1-report.txt` plus
`.codex/pillow-pcdimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 138/138 at `TimeoutSeconds 90`, final validate
`.codex/pillow-pcdimageplugin-validate-1-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-pcdimageplugin-example-1-report.txt` plus
`.codex/pillow-pcdimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PcxImagePlugin follow-up adds Pillow's Paintbrush PCX plugin surface as
`stdlib.pillow.PcxImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_pcximageplugin_probe.py` and
`.codex/pillow-pcximageplugin-probe.output.json` records `PcxImageFile`,
`SAVE`, `_accept(...)`, imported binary helpers `i16`/`o8`/`o16`, `_save`,
registered `.pcx` extension/open/save/MIME behavior, `PCX` id registration,
1/L/P/RGB RLE file-like opens and saves, `dpi` metadata, `pcx` tile metadata,
P-mode palette handling, L-mode grayscale palette output, and bad
prefix/short accept/bad size/unknown mode/unsupported save mode/arity error
paths. The AHK implementation mirrors the covered file-like paths and keeps
native acceleration/deeper legacy PCX variants for later focused probes. Fresh
AHK evidence includes `.codex/pillow-pcximageplugin-red-report.txt` plus
`.codex/pillow-pcximageplugin-red.json` failing because
`stdlib.pillow.PcxImagePlugin` was absent, focused green
`.codex/pillow-pcximageplugin-green-1-report.txt` plus
`.codex/pillow-pcximageplugin-green-1.json` passing 1/1, trusted serial module
gate `.codex/pillow-pcximageplugin-module-1-report.txt` plus
`.codex/pillow-pcximageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 139/139 at `TimeoutSeconds 90`, final validate
`.codex/pillow-pcximageplugin-validate-1-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-pcximageplugin-example-1-report.txt` plus
`.codex/pillow-pcximageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PdfImagePlugin follow-up adds Pillow's output-only PDF plugin surface as
`stdlib.pillow.PdfImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_pdfimageplugin_probe.py` and
`.codex/pillow-pdfimageplugin-probe.output.json` records save/save_all
registration, `.pdf` extension and `application/pdf` MIME behavior, no
registered PDF open/id entry, RGB/L DCT PDF image streams, P-mode indexed
ASCIIHex streams, mode `1` CCITT metadata when local libtiff is available,
title/author metadata, dpi/resolution MediaBox calculation, multi-page
`append_images`, and unsupported-mode plus arity error paths. The AHK
implementation mirrors the covered file-like and path save behavior with a
small PDF writer that emits catalog/pages/page/content/image objects, xref,
trailer, and Info metadata while leaving deeper compression/backend
optimization for later WIC/GDI+/Direct2D work. Fresh AHK evidence includes
`.codex/pillow-pdfimageplugin-red-report.txt` plus
`.codex/pillow-pdfimageplugin-red.json` failing because
`stdlib.pillow.PdfImagePlugin` was absent, focused green
`.codex/pillow-pdfimageplugin-green-2-report.txt` plus
`.codex/pillow-pdfimageplugin-green-2.json` passing 1/1, trusted serial module
gate `.codex/pillow-pdfimageplugin-module-1-report.txt` plus
`.codex/pillow-pdfimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 140/140 at `TimeoutSeconds 90`, final validate
`.codex/pillow-pdfimageplugin-validate-1-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-pdfimageplugin-example-2-report.txt` plus
`.codex/pillow-pdfimageplugin-example-2.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PixarImagePlugin follow-up adds Pillow's open-only PIXAR raster plugin
surface as `stdlib.pillow.PixarImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_pixarimageplugin_probe.py` and
`.codex/pillow-pixarimageplugin-probe.output.json` records `_accept(...)`,
the imported little-endian `i16(...)` helper, `PixarImageFile` format metadata,
registered `.pxr` extension/open behavior, `PIXAR` id registration, absence of
save/save_all/MIME registration, direct constructor and
`Image.open(..., ["PIXAR"])` RGB raw file-like loads from offset 1024, tile
metadata, and bad magic/unknown channel-depth/arity error paths. The AHK
implementation mirrors the covered RGB dumped-raster path and keeps other
unimplemented historical PIXAR modes explicit through the same
`not identified by this driver` error. While validating the full Pillow module,
current clipboard evidence in `.codex/pillow-imagegrab-clipboard-formats.json`
showed a 10,300,360 byte `CF_DIB`; `ImageGrab.grabclipboard()` now avoids
turning oversized DIB clipboard payloads into AHK byte arrays during smoke
tests while preserving smaller DIB decode behavior. Fresh AHK evidence includes
`.codex/pillow-pixarimageplugin-red-report.txt` plus
`.codex/pillow-pixarimageplugin-red.json` failing because
`stdlib.pillow.PixarImagePlugin` was absent, focused green
`.codex/pillow-pixarimageplugin-green-1-report.txt` plus
`.codex/pillow-pixarimageplugin-green-1.json` passing 1/1, ImageGrab guard
green `.codex/pillow-imagegrab-large-dib-guard-green-report.txt` plus
`.codex/pillow-imagegrab-large-dib-guard-green.json` passing 1/1, trusted
serial module gate `.codex/pillow-pixarimageplugin-module-4-report.txt` plus
`.codex/pillow-pixarimageplugin-module-4.json` passing
`stdlib/tests/pillow.test.ahk` 141/141 at `TimeoutSeconds 90`, final validate
`.codex/pillow-pixarimageplugin-validate-1-report.txt` passing the Pillow
implementation/test/example/capture files, and captured example gate
`.codex/pillow-pixarimageplugin-example-1-report.txt` plus
`.codex/pillow-pixarimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PngImagePlugin follow-up adds Pillow's PNG plugin surface as
`stdlib.pillow.PngImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_pngimageplugin_probe.py` and
`.codex/pillow_pngimageplugin_probe.output.json` records `_MAGIC`, `_accept`,
`i16`/`i32`/`o8`/`o16`/`o32`, `_crc32`, `is_cid`, `PngInfo.add`,
`add_text`, `add_itxt`, `iTXt`, `putchunk`, `getchunks`, registry entries,
direct and `Image.open(..., ["PNG"])` metadata reads, and file-like PNG
metadata saves. The AHK implementation mirrors the covered RGB/RGBA/L
metadata path with a lightweight PNG writer for chunk ordering and stored zlib
blocks, while keeping the existing native save path for plain image output.
Fresh AHK evidence includes `.codex/pillow-pngimageplugin-red-report.txt` plus
`.codex/pillow-pngimageplugin-red.json` failing because
`stdlib.pillow.PngImagePlugin` was absent, focused green
`.codex/pillow-pngimageplugin-green-5-report.txt` plus
`.codex/pillow-pngimageplugin-green-5.json` passing 1/1, trusted serial module
gate `.codex/pillow-pngimageplugin-module-2-report.txt` plus
`.codex/pillow-pngimageplugin-module-2.json` passing
`stdlib/tests/pillow.test.ahk` 142/142 at `TimeoutSeconds 90`, captured
example gate `.codex/pillow-pngimageplugin-example-2-report.txt` plus
`.codex/pillow-pngimageplugin-example-2.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions, and
final validate `.codex/pillow-pngimageplugin-validate-1-report.txt` covering
the Pillow implementation/test/example/capture files.

The CurImagePlugin follow-up adds Pillow's Windows cursor plugin surface as
`stdlib.pillow.CurImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_curimageplugin_probe.py` and
`.codex/pillow-curimageplugin-probe.output.json` records `_accept(...)` for CUR
headers, rejection of ICO/short prefixes, `CurImageFile` format metadata,
registered `.cur` extension/open behavior, direct constructor type-arity
errors, bad-header `SyntaxError`, no-entry `SyntaxError`, DIB-backed file-like
CUR opening, and multi-entry cursor selection choosing the largest image. The
AHK surface exposes `_accept(...)`, `CurImageFile`, registered `Image.open(...,
["CUR"])`, and the covered DIB-backed RGB cursor decode path. PNG-in-CUR,
alpha/AND mask recovery, full ICO/CUR matrix coverage, and benchmark-backed
native acceleration remain deferred. Fresh AHK evidence includes
`.codex/pillow-curimageplugin-red-report.txt` failing because
`stdlib.pillow.CurImagePlugin` was absent, focused green
`.codex/pillow-curimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-curimageplugin-module-report.txt` plus
`.codex/pillow-curimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 103/103 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-curimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The DcxImagePlugin follow-up adds Pillow's Intel DCX container plugin surface as
`stdlib.pillow.DcxImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_dcximageplugin_probe.py` and
`.codex/pillow-dcximageplugin-probe.output.json` records `MAGIC=987654321`,
`_accept(...)` for DCX headers, rejection of PCX/short prefixes,
`DcxImageFile` format metadata, `_close_exclusive_fp_after_loading=False`,
registered `.dcx` extension/open behavior, direct constructor type-arity
errors, bad-header `SyntaxError`, seek-out-of-range `EOFError`, single-frame
open metadata, and same-size multi-frame RGB PCX payload seek/tell/pixel
behavior. The AHK surface exposes `MAGIC`, `_accept(...)`, `DcxImageFile`,
registered `Image.open(..., ["DCX"])`, `n_frames`, `is_animated`, and
`seek(...)`/`tell(...)` for the covered DCX container path with RGB PCX RLE
frames. Standalone `PcxImagePlugin`, 1-bit/L/P PCX modes, mixed-size DCX frame
reload quirks, palette metadata, compressed/legacy PCX variants, and native
acceleration remain deferred until focused probes cover them. Fresh AHK
evidence includes `.codex/pillow-dcximageplugin-red-report.txt` failing because
`stdlib.pillow.DcxImagePlugin` was absent, focused green
`.codex/pillow-dcximageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-dcximageplugin-module-report.txt` plus
`.codex/pillow-dcximageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 104/104 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-dcximageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The DdsImagePlugin follow-up adds Pillow's DirectDraw Surface plugin surface as
`stdlib.pillow.DdsImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_ddsimageplugin_probe.py` and
`.codex/pillow-ddsimageplugin-probe.output.json` records `DDS_MAGIC`,
`DDSD`/`DXGI_FORMAT`/`D3DFMT` public enum values/string/repr behavior,
`_accept(...)` for `DDS ` prefixes, `DdsImageFile` format metadata, registered
`.dds` extension/open/save/`dds_rgb` decoder behavior, RGB/RGBA/L/LA raw DDS
file-like save/open round-trips, and direct bad-header/type-arity/save-option
errors. The AHK surface exposes the constants, enum-like member objects, an AHK
`DDSD.combine(...)` helper for Python IntFlag-style combinations that cannot be
spelled with object `|` in AutoHotkey v2 syntax, `DdsImageFile`, registered
`Image.open(..., ["DDS"])`, and `Image.save(..., "DDS")` for the covered raw
DDS paths. Compressed BCn/DX10/BC7 decoding and encoding, palette-indexed DDS,
volume/cubemap/mipmap metadata, wider DDS matrix coverage, and
benchmark-backed WIC/Direct2D/GDI+ acceleration remain deferred until focused
probes cover them. Fresh AHK evidence includes
`.codex/pillow-ddsimageplugin-red-report.txt` failing because
`stdlib.pillow.DdsImagePlugin` was absent, focused green
`.codex/pillow-ddsimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-ddsimageplugin-module-report.txt` plus
`.codex/pillow-ddsimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 105/105 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-ddsimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The EpsImagePlugin follow-up adds Pillow's Encapsulated PostScript plugin
surface as `stdlib.pillow.EpsImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_epsimageplugin_probe.py` and
`.codex/pillow-epsimageplugin-probe.output.json` records `_accept(...)` for
`%!PS` and Mac binary EPS prefixes, `EpsImageFile` format metadata and
`mode_map`, registry effects for `.eps`/`.ps`/MIME/open/save, local
Ghostscript absence (`has_ghostscript() == False`), EPS header parsing for
direct, `(atend)` trailer, `ImageData`, and Mac-preview offset files, RGB/L
file-like EPS saves with Pillow's PostScript header and hex pixel payloads, and
direct bad-header/type-arity/save-mode/Ghostscript-load errors. The AHK surface
exposes `has_ghostscript`, `gs_binary`, `gs_windows_binary`, `_accept(...)`,
`EpsImageFile`, metadata-only `Image.open(..., ["EPS"])`/direct constructor
parsing, and `Image.save(..., "EPS")` for the covered RGB/L file-like save
paths. Actual Ghostscript raster rendering, installed-Ghostscript command
integration, CMYK save/load, PostScript transparency rendering, and broader EPS
variants remain deferred until focused probes run on an environment with the
required backend. Fresh AHK evidence includes
`.codex/pillow-epsimageplugin-red-report.txt` failing because
`stdlib.pillow.EpsImagePlugin` was absent, focused green
`.codex/pillow-epsimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-epsimageplugin-module-report.txt` plus
`.codex/pillow-epsimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 106/106 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-epsimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The FitsImagePlugin follow-up adds Pillow's FITS image plugin surface as
`stdlib.pillow.FitsImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_fitsimageplugin_probe.py` and
`.codex/pillow-fitsimageplugin-probe.output.json` records `_accept(...)` for
`SIMPLE` prefixes, `FitsImageFile` format metadata, registered `.fit`/`.fits`
extension/open behavior, registered `fits_gzip` decoder metadata, uncompressed
FITS header parsing for `BITPIX` 8/16/32/-32/-64, `NAXIS=1` size behavior,
compressed `BINTABLE`/`ZIMAGE`/`GZIP_1` tile metadata, and bad-header,
truncated, no-image-data, and constructor type-arity errors. The AHK surface
exposes `_accept(...)`, `FitsImageFile`, `Image.open(..., ["FITS"])`, raw
mode/size/tile metadata for the covered header cases, and FITS registry
entries. Actual raw FITS pixel decoding, `fits_gzip` decompression into pixel
rows, broader FITS extensions, WCS/header metadata APIs beyond Pillow's parsed
tile surface, and benchmark-backed native acceleration remain deferred until
focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-fitsimageplugin-red-report.txt` failing because
`stdlib.pillow.FitsImagePlugin` was absent, focused green
`.codex/pillow-fitsimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-fitsimageplugin-module-report.txt` plus
`.codex/pillow-fitsimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 107/107 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-fitsimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The FliImagePlugin follow-up adds Pillow's Autodesk FLI/FLC animation plugin
surface as `stdlib.pillow.FliImagePlugin`. Fresh local Python 3.10.11 plus
Pillow 11.3.0 evidence from `.codex/pillow_fliimageplugin_probe.py` and
`.codex/pillow-fliimageplugin-probe.output.json` records `_accept(...)` for
FLI/FLC magic values and allowed flags, `FliImageFile` format metadata,
`_close_exclusive_fp_after_loading=False`, registered `.fli`/`.flc` extension
and open behavior, FLI-vs-FLC duration handling, default grayscale palette,
palette chunks 4 and 11, prefix-chunk handling, single and animated frame
metadata, `seek(0)`/`tell()` behavior, frame tile metadata, and bad-header,
missing-frame, type-arity, and seek-out-of-range errors. The AHK surface
exposes `_accept(...)`, `FliImageFile`, `Image.open(..., ["FLI"])`,
`n_frames`, `is_animated`, `info["duration"]`, `palette`, `decodermaxblock`,
`tile`, `seek(...)`, and `tell()` for the covered metadata path. Actual FLI
pixel decoding, frame delta application, load-time decoder integration, wider
palette/subchunk variants, multi-frame rendered pixel verification, and
benchmark-backed native acceleration remain deferred until focused probes cover
them. Fresh AHK evidence includes `.codex/pillow-fliimageplugin-red-report.txt`
failing because `stdlib.pillow.FliImagePlugin` was absent, focused green
`.codex/pillow-fliimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-fliimageplugin-module-report.txt` plus
`.codex/pillow-fliimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 108/108 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-fliimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The FpxImagePlugin follow-up adds Pillow's FlashPix metadata plugin surface as
`stdlib.pillow.FpxImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_fpximageplugin_probe.py` and
`.codex/pillow-fpximageplugin-probe.output.json` records OLE magic
`_accept(...)`, `FpxImageFile` format metadata, registered `.fpx` extension and
open behavior, Pillow's public `MODES` mapping, fake-OLE `OleFileIO` metadata
parsing for RGB raw tiles, L raw tiles, RGBA fill tiles, JPEG/YCC tile-prefix
metadata, `maxid`, `stream`, `rawmode`, `tile`, `tile_prefix`, `jpeg_keys`,
and invalid OLE, bad root CLSID, invalid band count, unknown mode, subimage
mismatch, unknown compression, and constructor type-arity errors. The AHK
surface exposes `_accept(...)`, replaceable `olefile`, `MODES`,
`FpxImageFile`, `Image.open(..., ["FPX"])`, and the covered metadata-only
tile surface. Real compound-file OLE parsing, rendered FPX pixel decoding, JPEG
table integration at load time, broader FlashPix property sets, and
benchmark-backed native acceleration remain deferred until focused probes cover
them. Fresh AHK evidence includes `.codex/pillow-fpximageplugin-red-report.txt`
failing because `stdlib.pillow.FpxImagePlugin` was absent, focused green
`.codex/pillow-fpximageplugin-green-focused-report.txt` plus
`.codex/pillow-fpximageplugin-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-fpximageplugin-module-report.txt`
plus `.codex/pillow-fpximageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 109/109 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-fpximageplugin-example-report.txt` plus
`.codex/pillow-fpximageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The FtexImagePlugin follow-up adds Pillow's FTEX texture metadata and
uncompressed-image path as `stdlib.pillow.FtexImagePlugin`. Fresh local Python
3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_fteximageplugin_probe.py` and
`.codex/pillow-fteximageplugin-probe.output.json` records `_accept(...)` for
`FTEX` prefixes, the public `Format.DXT1` and `Format.UNCOMPRESSED` enum
surface, `FtexImageFile` format metadata, registered `.ftc`/`.ftu` extension
and open behavior, uncompressed RGB file-like direct and
`Image.open(..., ["FTEX"])` pixel loading, DXT1 `bcn` tile metadata, bad magic,
truncated header, unknown texture format, multi-format assertion, and
constructor type-arity errors. The AHK surface exposes `_accept(...)`,
`Format`, `FtexImageFile`, `Image.open(..., ["FTEX"])`, uncompressed RGB raw
tile metadata with lazy pixel loading, DXT1 `bcn` tile metadata, and FTEX
registry entries. Multi-format files, additional mipmap levels, rendered DXT1
BCN decoding, broader FTEX variants, and benchmark-backed native acceleration
remain deferred until focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-fteximageplugin-red-report.txt` failing because
`stdlib.pillow.FtexImagePlugin` was absent, focused green
`.codex/pillow-fteximageplugin-green-focused-report.txt` plus
`.codex/pillow-fteximageplugin-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-fteximageplugin-module-report.txt` plus
`.codex/pillow-fteximageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 110/110 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-fteximageplugin-example-report.txt` plus
`.codex/pillow-fteximageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The GbrImagePlugin follow-up adds Pillow's GIMP brush loader surface as
`stdlib.pillow.GbrImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_gbrimageplugin_probe.py` and
`.codex/pillow-gbrimageplugin-probe.output.json` records `_accept(...)` for
version 1 and version 2 `.gbr` headers, `GbrImageFile` format metadata,
registered `.gbr` extension/open behavior, version 2 grayscale brush
`spacing` and byte-comment metadata, version 1 RGBA byte-comment metadata, L
and RGBA pixel loading, `_data_size`, and bad header, unsupported version,
invalid size, unsupported color depth, bad magic, and constructor type-arity
errors. The AHK surface exposes `_accept(...)`, `GbrImageFile`,
`Image.open(..., ["GBR"])`, v1/v2 header parsing, L/RGBA in-memory pixels,
`info["comment"]`, v2 `info["spacing"]`, `_data_size`, and registry entries.
Unsupported Pillow-adjacent version 3 float brushes, decompression-bomb edge
coverage, and benchmark-backed native acceleration remain deferred until
focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-gbrimageplugin-red-report.txt` failing because
`stdlib.pillow.GbrImagePlugin` was absent, focused green
`.codex/pillow-gbrimageplugin-green-focused-report.txt` plus
`.codex/pillow-gbrimageplugin-green-focused.json` passing after
implementation, trusted serial module gate
`.codex/pillow-gbrimageplugin-module-report.txt` plus
`.codex/pillow-gbrimageplugin-module.json` passing
`stdlib/tests/pillow.test.ahk` 111/111 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gbrimageplugin-example-report.txt` plus
`.codex/pillow-gbrimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The GdImageFile follow-up adds Pillow's direct GD loader surface as
`stdlib.pillow.GdImageFile`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_gdimagefile_probe.py` and
`.codex/pillow-gdimagefile-probe.output.json` records the public
`GdImageFile` factory metadata, module-level `open(...)`, big-endian `i16(...)`
and `i32(...)` helpers, file-like and path opens, P-mode palette-index pixel
loading, `RGBX` raw palette metadata, `info["transparency"]` for indices below
256, true-color header offset handling, and the important Python behavior that
GD is not registered with `Image.open(...)` or `.gd` extensions. The AHK
surface exposes `GdImageFile.GdImageFile(...)`, `GdImageFile.open(...)`, lazy
raw-tile pixel loading, path and file-like inputs, and `Image.open(...,
["GD"])` raising `KeyError('GD')` instead of silently using the generic WIC
path. This slice also hardens the Pillow internal binary file reader against
BOM-like image magic such as GD's `FF FE` header by forcing raw reads from byte
zero. Compressed GD2 variants, GD save support, decompression-bomb edge
coverage, and benchmark-backed native acceleration remain deferred until
focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-gdimagefile-red-report.txt` failing because
`stdlib.pillow.GdImageFile` was absent, focused green
`.codex/pillow-gdimagefile-green-focused-report.txt` plus
`.codex/pillow-gdimagefile-green-focused.json` passing after implementation,
trusted serial module gate `.codex/pillow-gdimagefile-module-report.txt` plus
`.codex/pillow-gdimagefile-module.json` passing
`stdlib/tests/pillow.test.ahk` 112/112 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-gdimagefile-example-report.txt` plus
`.codex/pillow-gdimagefile-example.json` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The BlpImagePlugin follow-up adds the next Pillow plugin surface as
`stdlib.pillow.BlpImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_blpimageplugin_probe.py` and
`.codex/pillow-blpimageplugin-probe.output.json` records `Format`,
`Encoding`, and `AlphaEncoding` enum values/string/repr names, `_accept(...)`
for BLP1/BLP2 prefixes, `BLPFormatError` deriving from
`NotImplementedError`, `BlpImageFile` format metadata, `unpack_565(...)`,
`decode_dxt1(...)`, `decode_dxt3(...)`, and `decode_dxt5(...)` helper output
rows, registry effects, and Pillow-saved P-mode BLP2 RGBA, BLP1 RGBA, and BLP2
RGB file-like round-trips. The AHK surface exposes enum-like member objects,
the public BLP error class, the BLP image-file factory metadata, accept/565/DXT
helpers, and registered `Image.open(..., ["BLP"])` plus `Image.save(...,
"BLP")` for the covered uncompressed palette BLP paths. DXT-compressed file
decoding, JPEG-compressed BLP1, mipmap pyramids beyond the first image, and
benchmark-backed native acceleration remain deferred. Fresh AHK evidence
includes `.codex/pillow-blpimageplugin-red-report.txt` failing because
`stdlib.pillow.BlpImagePlugin` was absent, focused green
`.codex/pillow-blpimageplugin-green-focused-report.txt` passing after
implementation, trusted serial module gate
`.codex/pillow-blpimageplugin-module-report.txt` plus
`.codex/pillow-blpimageplugin-module.json` passing `stdlib/tests/pillow.test.ahk`
101/101 at `TimeoutSeconds 90`, and captured example gate
`.codex/pillow-blpimageplugin-example-report.txt` passing
`.codex/pillow_example_capture.test.ahk` 1/1 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The PsdImagePlugin follow-up adds Pillow's Photoshop PSD reader surface as
`stdlib.pillow.PsdImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_psdimageplugin_probe.py` and
`.codex/pillow_psdimageplugin_probe.output.json` records `MODES`, `i8`/`i16`/
`i32`/signed helper behavior, `_accept(...)`, `.psd` extension and MIME
registration, direct and `Image.open(..., ["PSD"])` L/RGB/RGBA/P/CMYK raw
file-like opens, P-mode palette conversion, CMYK inverted raw tile metadata,
ICC resource extraction, lazy layer metadata, `n_frames`, `is_animated`,
`seek`/`tell`, and bad magic/version/channel/mode/layer-block/constructor
error paths. The AHK surface exposes `PsdImageFile`, registered PSD opens,
resource parsing, palette/raw pixel loading, main-image absolute tile offsets,
and Pillow-compatible layer tile offsets relative to the copied layer-info
stream. PSD save support, RLE/PackBits rendered loading, adjustment/mask
blocks, PSB, and broader Photoshop resource coverage remain deferred until
focused probes cover them. Fresh AHK evidence includes
`.codex/pillow-psdimageplugin-red-report.txt` plus
`.codex/pillow-psdimageplugin-red.json` failing because
`stdlib.pillow.PsdImagePlugin` was absent, focused green
`.codex/pillow-psdimageplugin-green-2-report.txt` plus
`.codex/pillow-psdimageplugin-green-2.json` passing after implementation,
trusted serial module gate `.codex/pillow-psdimageplugin-module-1-report.txt`
plus `.codex/pillow-psdimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 144/144 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-psdimageplugin-example-1-report.txt` plus
`.codex/pillow-psdimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The QoiImagePlugin follow-up adds Pillow's Quite OK Image plugin surface as
`stdlib.pillow.QoiImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_qoiimageplugin_probe.py` and
`.codex/pillow_qoiimageplugin_probe.output.json` records `_accept(...)`,
`QoiImageFile` format metadata, `QoiDecoder._pulls_fd`,
`QoiEncoder._pushes_fd`, `_write_run()` and `_delta(...)` helper behavior,
registered open/save/decoder/encoder and `.qoi` extension behavior, no MIME
registration, direct and `Image.open(..., ["QOI"])` RGB/RGBA file-like opens,
exact QOI payload decoding for RGB/RGBA diff/luma/run/index/RGB/RGBA op paths,
RGB/RGBA file-like saves, `colorspace="sRGB"` header handling, and bad magic,
unsupported save mode, constructor arity, and `_save` arity errors. The AHK
surface exposes `QoiImageFile`, `QoiDecoder`, `QoiEncoder`, registered
`Image.open(..., ["QOI"])`, registered `Image.save(..., "QOI")`, memory-backed
decoded pixels, and exact covered encoder output. Broader fuzzing, malformed
stream truncation parity, large-image performance tuning, and native
SIMD/vector acceleration remain deferred until focused probes cover them.
Fresh AHK evidence includes `.codex/pillow-qoiimageplugin-red-report.txt` plus
`.codex/pillow-qoiimageplugin-red.json` failing because
`stdlib.pillow.QoiImagePlugin` was absent, focused green
`.codex/pillow-qoiimageplugin-green-3-report.txt` plus
`.codex/pillow-qoiimageplugin-green-3.json` passing after implementation,
trusted serial module gate `.codex/pillow-qoiimageplugin-module-1-report.txt`
plus `.codex/pillow-qoiimageplugin-module-1.json` passing
`stdlib/tests/pillow.test.ahk` 145/145 at `TimeoutSeconds 90`, and captured
example gate `.codex/pillow-qoiimageplugin-example-1-report.txt` plus
`.codex/pillow-qoiimageplugin-example-1.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The SgiImagePlugin follow-up adds Pillow's SGI image plugin surface as
`stdlib.pillow.SgiImagePlugin`. Fresh local Python 3.10.11 plus Pillow 11.3.0
evidence from `.codex/pillow_sgiimageplugin_probe.py` and
`.codex/pillow_sgiimageplugin_probe.output.json` records `MODES`,
`SgiImageFile` format metadata, `SGI16Decoder._pulls_fd`, `i16`/`o8`,
`_accept(...)`, `.bw`/`.rgb`/`.rgba`/`.sgi` extension registration, MIME
registration, registered open/save/decoder behavior, direct and
`Image.open(..., ["SGI"])` raw SGI file-like opens, RLE file-like opens,
16-bit SGI tile metadata and high-byte pixel loading, RGB/RGBA/L file-like
saves, `bpc=2` save output, and covered bad-magic/unsupported-mode/constructor
and `_save` arity errors. The AHK surface exposes `SgiImageFile`,
`SGI16Decoder`, registered `Image.open(..., ["SGI"])`, registered
`Image.save(..., "SGI")`, memory-backed raw/RLE decoded pixels, and covered
raw SGI writer output. Broader malformed RLE parity, full 16-bit precision
preservation, uncommon SGI dimensions, and native SIMD/vector acceleration
remain deferred until focused probes cover them. Fresh AHK evidence includes
focused red `.codex/pillow-sgiimageplugin-red-report.txt` failing because
`stdlib.pillow.SgiImagePlugin` was absent, focused green
`.codex/pillow-sgiimageplugin-green-focused-report.txt` plus
`.codex/pillow-sgiimageplugin-green-focused.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-sgiimageplugin-module-filter-report.txt` passing the
Pillow-filtered `stdlib/tests` gate 147/147 at `TimeoutSeconds 90`, validate gate
`.codex/pillow-sgiimageplugin-validate-report.txt` passing the implementation,
test, and example files, and captured example gate
`.codex/pillow-sgiimageplugin-example-report.txt` plus
`.codex/pillow-sgiimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

The SpiderImagePlugin follow-up adds Pillow's SPIDER electron-microscopy float
image plugin surface as `stdlib.pillow.SpiderImagePlugin`. Fresh local Python
3.10.11 plus Pillow 11.3.0 evidence from
`.codex/pillow_spiderimageplugin_probe.py` and
`.codex/pillow_spiderimageplugin_probe.output.json` records `iforms`,
`isInt`, `isSpiderHeader`, `isSpiderImage`, `makeSpiderHeader`,
`SpiderImageFile` format metadata, direct and
`Image.open(..., ["SPIDER"])` little/big-endian F-mode file-like opens, stack
`seek`/`tell`/`n_frames` behavior, `convert2byte`, file-like/path saves, dynamic
`.spi` registration after path saves, and covered bad-header/not-2D/bad-stack/
constructor/`_save` arity errors. The AHK surface exposes `SpiderImageFile`,
registered `Image.open(..., ["SPIDER"])`, registered `Image.save(...,
"SPIDER")`, memory-backed float pixels, stack frame switching, byte conversion,
and covered writer output. Broader malformed stack corpora, montage stdout
parity in `loadImageSeries`, `tkPhotoImage` integration, and native
SIMD/vector acceleration remain deferred until focused probes cover them. Fresh
AHK evidence includes focused red
`.codex/pillow-spiderimageplugin-red-report.txt` failing because
`stdlib.pillow.SpiderImagePlugin` was absent, focused green
`.codex/pillow-spiderimageplugin-green-focused-report.txt` plus
`.codex/pillow-spiderimageplugin-green-focused.json` passing 1/1 after
implementation, trusted serial module gate
`.codex/pillow-spiderimageplugin-module-filter-report.txt` passing the
Pillow-filtered `stdlib/tests` gate 148/148 at `TimeoutSeconds 90`, validate
gate `.codex/pillow-spiderimageplugin-validate-report.txt` passing the
implementation, test, example, and capture files, and captured example gate
`.codex/pillow-spiderimageplugin-example-report.txt` plus
`.codex/pillow-spiderimageplugin-example.json` passing
`.codex/pillow_example_capture.test.ahk` 2/2 without warning/error output and
with System.Text.RegularExpressions / MatchEvaluator pollution assertions.

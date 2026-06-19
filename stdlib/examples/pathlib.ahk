#Requires AutoHotkey v2.0

#Include <stdlib\pathlib>
#Include <stdlib\tempfile>

pathlib_example_path := stdlib.pathlib.Path("alpha", "beta.txt")
pathlib_example_name := pathlib_example_path.name
pathlib_example_parent := pathlib_example_path.parent
pathlib_example_stem := pathlib_example_path.stem
pathlib_example_suffix := pathlib_example_path.suffix
pathlib_example_parts := pathlib_example_path.parts
pathlib_example_zip_name := pathlib_example_path.with_suffix(".zip").name
pathlib_example_windows_parts := stdlib.pathlib.PureWindowsPath("C:\alpha\beta.txt").parts
pathlib_example_posix_name := stdlib.pathlib.PurePosixPath("/var/log/app.log").name

pathlib_example_root := stdlib.tempfile.mkdtemp("", "stdlib-pathlib-example-", stdlib.tempfile.gettempdir())
try {
    pathlib_example_dir := stdlib.pathlib.Path(pathlib_example_root, "data")
    pathlib_example_dir.mkdir()
    pathlib_example_file := stdlib.pathlib.Path(pathlib_example_root, "data", "sample.txt")
    pathlib_example_written := pathlib_example_file.write_text("hello", "UTF-8")
    pathlib_example_text := pathlib_example_file.read_text("UTF-8")
    pathlib_example_exists := pathlib_example_file.exists()
    pathlib_example_is_file := pathlib_example_file.is_file()

    pathlib_example_entries := []
    for entry in pathlib_example_dir.iterdir()
        pathlib_example_entries.Push(entry.name)

    pathlib_example_matches := []
    for entry in pathlib_example_dir.glob("*.txt")
        pathlib_example_matches.Push(entry.name)

    pathlib_example_recursive_matches := []
    for entry in stdlib.pathlib.Path(pathlib_example_root).rglob("*.txt")
        pathlib_example_recursive_matches.Push(entry.name)
} finally {
    if DirExist(pathlib_example_root)
        DirDelete pathlib_example_root, true
}

#Requires AutoHotkey v2.0

#Include <stdlib\tempfile>

tempfile_example_root := stdlib.tempfile.gettempdir()
tempfile_example_path := stdlib.tempfile.mkdtemp("", "example-", tempfile_example_root)
tempfile_example_directory := stdlib.tempfile.TemporaryDirectory("", "example-dir-", tempfile_example_root)
tempfile_example_directory.cleanup()

if DirExist(tempfile_example_path)
    DirDelete tempfile_example_path, true

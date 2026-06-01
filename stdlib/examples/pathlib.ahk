#Requires AutoHotkey v2.0

#Include <stdlib\pathlib>

pathlib_example_path := stdlib.pathlib.Path("alpha", "beta.txt")
pathlib_example_name := pathlib_example_path.name
pathlib_example_parent := pathlib_example_path.parent

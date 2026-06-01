#Requires AutoHotkey v2.0

#Include <stdlib\shutil>
#Include <stdlib\tempfile>
#Include <stdlib\pathlib>

shutil_example_root := stdlib.tempfile.mkdtemp("", "stdlib-shutil-example-", stdlib.tempfile.gettempdir())
shutil_example_source := stdlib.pathlib.Path(shutil_example_root, "source.txt")
shutil_example_target_dir := stdlib.pathlib.Path(shutil_example_root, "target")
shutil_example_target_dir.mkdir()
shutil_example_source.write_text("payload")
shutil_example_copied := stdlib.shutil.copy(shutil_example_source, shutil_example_target_dir)
shutil_example_moved_dir := stdlib.pathlib.Path(shutil_example_root, "moved")
shutil_example_moved_dir.mkdir()
shutil_example_moved := stdlib.shutil.move(shutil_example_source, shutil_example_moved_dir)
stdlib.shutil.rmtree(shutil_example_target_dir)
stdlib.shutil.rmtree(shutil_example_moved_dir)

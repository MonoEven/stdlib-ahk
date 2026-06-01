#Requires AutoHotkey v2.0

#Include <stdlib\io>

io_example_stream := stdlib.io.StringIO("alpha`nbeta")
io_example_prefix := io_example_stream.read(2)
io_example_line := io_example_stream.readline()
io_example_end := io_example_stream.seek(0, stdlib.io.SEEK_END)
io_example_written := io_example_stream.write("!")
io_example_text := io_example_stream.getvalue()

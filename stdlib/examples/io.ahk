#Requires AutoHotkey v2.0

#Include <stdlib\io>

io_example_stream := stdlib.io.StringIO("alpha`nbeta")
io_example_prefix := io_example_stream.read(2)
io_example_line := io_example_stream.readline()
io_example_end := io_example_stream.seek(0, stdlib.io.SEEK_END)
io_example_written := io_example_stream.write("!")
io_example_text := io_example_stream.getvalue()

io_example_bytes := stdlib.io.BytesIO([65, 66, 10, 67])
io_example_bytes_prefix := io_example_bytes.read(2)
io_example_bytes_line := io_example_bytes.readline()
io_example_bytes_end := io_example_bytes.seek(0, stdlib.io.SEEK_END)
io_example_bytes_written := io_example_bytes.write([255])
io_example_bytes_value := io_example_bytes.getvalue()
io_example_bytes_readable := io_example_bytes.readable()
io_example_bytes_writable := io_example_bytes.writable()
io_example_bytes_seekable := io_example_bytes.seekable()
io_example_bytes_flush := io_example_bytes.flush()

io_example_read1_stream := stdlib.io.BytesIO([97, 98, 99, 100])
io_example_read1_prefix := io_example_read1_stream.read1(2)
io_example_readinto_target := Buffer(3, 0)
io_example_readinto_count := io_example_read1_stream.readinto(io_example_readinto_target)
io_example_readinto1_target := Buffer(2, 0)
io_example_readinto1_count := io_example_read1_stream.readinto1(io_example_readinto1_target)

io_example_lines := stdlib.io.BytesIO()
io_example_lines.writelines([[65], [66, 67]])
io_example_lines_value := io_example_lines.getvalue()

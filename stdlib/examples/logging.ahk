#Requires AutoHotkey v2.0

#Include <stdlib\logging>
#Include <stdlib\io>

logging_example_buffer := stdlib.io.StringIO()
stdlib.logging._resetForTests()
stdlib.logging.basicConfig({ stream: logging_example_buffer, level: "WARN" })

logging_example_root := stdlib.logging.getLogger()
logging_example_named := stdlib.logging.getLogger("example")
logging_example_named.setLevel("FATAL")
stdlib.logging.debug("hidden debug")
logging_example_root.warning("root warning")
logging_example_named.info("named info")
logging_example_named.fatal("named fatal")
logging_example_text := logging_example_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_basicconfig_file_path := A_Temp "\stdlib-logging-basicconfig-example-" A_TickCount ".log"
FileAppend "old`n", logging_example_basicconfig_file_path, "UTF-8-RAW"
stdlib.logging.basicConfig({ filename: logging_example_basicconfig_file_path, filemode: "w", encoding: "UTF-8", level: "INFO", format: "%(message)s" })
stdlib.logging.info("basic file text")
logging_example_basicconfig_file_text := FileRead(logging_example_basicconfig_file_path, "UTF-8")
if FileExist(logging_example_basicconfig_file_path)
    FileDelete logging_example_basicconfig_file_path

stdlib.logging._resetForTests()
logging_example_basicconfig_conflict_error := ""
try {
    stdlib.logging.basicConfig({ filename: A_Temp "\stdlib-logging-basicconfig-conflict-example-" A_TickCount ".log", stream: stdlib.io.StringIO() })
} catch Error as err {
    logging_example_basicconfig_conflict_error := err.Message
}

stdlib.logging._resetForTests()
logging_example_force_first_buffer := stdlib.io.StringIO()
logging_example_force_second_buffer := stdlib.io.StringIO()
stdlib.logging.basicConfig({ stream: logging_example_force_first_buffer, level: "WARNING", format: "%(message)s" })
stdlib.logging.warning("old1")
stdlib.logging.basicConfig({ stream: logging_example_force_second_buffer, level: "INFO", format: "%(levelname)s:%(message)s", force: true })
stdlib.logging.info("new2")
logging_example_force_first_text := logging_example_force_first_buffer.getvalue()
logging_example_force_second_text := logging_example_force_second_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_handlers_buffer := stdlib.io.StringIO()
logging_example_handlers_handler := stdlib.logging.StreamHandler(logging_example_handlers_buffer)
stdlib.logging.basicConfig({ handlers: [logging_example_handlers_handler], level: "INFO" })
stdlib.logging.info("handlers hello")
logging_example_handlers_text := logging_example_handlers_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_handlers_custom_buffer := stdlib.io.StringIO()
logging_example_handlers_custom_handler := stdlib.logging.StreamHandler(logging_example_handlers_custom_buffer)
logging_example_handlers_custom_handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
stdlib.logging.basicConfig({ handlers: [logging_example_handlers_custom_handler], level: "INFO" })
stdlib.logging.info("handlers plain")
logging_example_handlers_custom_text := logging_example_handlers_custom_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_handlers_conflict_error := ""
try {
    stdlib.logging.basicConfig({ handlers: [stdlib.logging.StreamHandler(stdlib.io.StringIO())], stream: stdlib.io.StringIO() })
} catch Error as err {
    logging_example_handlers_conflict_error := err.Message
}

stdlib.logging._resetForTests()
logging_example_handlers_iterable_buffer := stdlib.io.StringIO()
logging_example_handlers_iterable_handler := stdlib.logging.StreamHandler(logging_example_handlers_iterable_buffer)
stdlib.logging.basicConfig({ handlers: StdlibLoggingExampleHandlersIterable([logging_example_handlers_iterable_handler]), level: "INFO" })
stdlib.logging.info("iterable hello")
logging_example_handlers_iterable_text := logging_example_handlers_iterable_buffer.getvalue()

logging_example_custom_buffer := stdlib.io.StringIO()
logging_example_custom_handler := stdlib.logging.StreamHandler(logging_example_custom_buffer)
logging_example_custom_handler.setLevel("ERROR")
logging_example_custom_handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
logging_example_custom_logger := stdlib.logging.getLogger("custom")
logging_example_custom_logger.setLevel("INFO")
logging_example_custom_logger.addHandler(logging_example_custom_handler)
logging_example_custom_logger.info("hidden info")
logging_example_custom_handler.setFormatter(stdlib.logging.Formatter("%(levelno)s:%(message)s"))
logging_example_custom_logger.error("custom text")
logging_example_custom_text := logging_example_custom_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_propagate_root_buffer := stdlib.io.StringIO()
logging_example_propagate_child_buffer := stdlib.io.StringIO()
logging_example_propagate_root := stdlib.logging.getLogger()
logging_example_propagate_root_handler := stdlib.logging.StreamHandler(logging_example_propagate_root_buffer)
logging_example_propagate_child_handler := stdlib.logging.StreamHandler(logging_example_propagate_child_buffer)
logging_example_propagate_root_handler.setFormatter(stdlib.logging.Formatter("%(name)s:%(message)s"))
logging_example_propagate_child_handler.setFormatter(stdlib.logging.Formatter("child:%(message)s"))
logging_example_propagate_root.addHandler(logging_example_propagate_root_handler)
logging_example_propagate_logger := stdlib.logging.getLogger("propagate")
logging_example_propagate_logger.setLevel("DEBUG")
logging_example_propagate_logger.addHandler(logging_example_propagate_child_handler)
logging_example_propagate_logger.warning("dup text")
logging_example_propagate_root_text := logging_example_propagate_root_buffer.getvalue()
logging_example_propagate_child_text := logging_example_propagate_child_buffer.getvalue()

stdlib.logging._resetForTests()
logging_example_propagate_root_buffer := stdlib.io.StringIO()
logging_example_propagate_root := stdlib.logging.getLogger()
logging_example_propagate_root_handler := stdlib.logging.StreamHandler(logging_example_propagate_root_buffer)
logging_example_propagate_root_handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
logging_example_propagate_root.addHandler(logging_example_propagate_root_handler)
logging_example_propagate_child_buffer := stdlib.io.StringIO()
logging_example_propagate_child_handler := stdlib.logging.StreamHandler(logging_example_propagate_child_buffer)
logging_example_propagate_child_handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
logging_example_propagate_logger := stdlib.logging.getLogger("propagate")
logging_example_propagate_logger.handlers := []
logging_example_propagate_logger.addHandler(logging_example_propagate_child_handler)
logging_example_propagate_logger.propagate := false
logging_example_propagate_logger.warning("local only")
logging_example_propagate_stopped_root_text := logging_example_propagate_root_buffer.getvalue()
logging_example_propagate_stopped_child_text := logging_example_propagate_child_buffer.getvalue()

logging_example_file_path := A_Temp "\stdlib-logging-example-" A_TickCount ".log"
logging_example_file_logger := stdlib.logging.getLogger("file")
logging_example_file_handler := stdlib.logging.FileHandler(logging_example_file_path, "w", "UTF-8")
logging_example_file_handler.setFormatter(stdlib.logging.Formatter("%(message)s"))
logging_example_file_logger.setLevel("INFO")
logging_example_file_logger.addHandler(logging_example_file_handler)
logging_example_file_logger.info("file text")
logging_example_file_text := FileRead(logging_example_file_path, "UTF-8")
logging_example_file_handler.close()
if FileExist(logging_example_file_path)
    FileDelete logging_example_file_path

class StdlibLoggingExampleHandlersIterable
{
    __New(values)
    {
        this.Values := values
    }

    __Enum(count)
    {
        return this.Values.__Enum(count)
    }
}

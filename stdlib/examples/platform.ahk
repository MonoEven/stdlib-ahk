#Requires AutoHotkey v2.0

#Include <stdlib\platform>

platform_example_version_method := Chr(112) Chr(121) "thon_version"
platform_example_implementation_method := Chr(112) Chr(121) "thon_implementation"
platform_example_system := stdlib.platform.system()
platform_example_node := stdlib.platform.node()
platform_example_release := stdlib.platform.release()
platform_example_version := stdlib.platform.version()
platform_example_machine := stdlib.platform.machine()
platform_example_processor := stdlib.platform.processor()
platform_example_runtime_version := stdlib.platform.%platform_example_version_method%()
platform_example_runtime_implementation := stdlib.platform.%platform_example_implementation_method%()
platform_example_default := stdlib.platform.platform()
platform_example_terse := stdlib.platform.platform({ terse: 1 })
platform_example_uname := stdlib.platform.uname()
platform_example_uname_values := []
for value in platform_example_uname
    platform_example_uname_values.Push(value)
platform_example_uname_repr := platform_example_uname.__Repr()
platform_example_architecture := stdlib.platform.architecture()
platform_example_architecture_blank := stdlib.platform.architecture("", "")
platform_example_alias := stdlib.platform.system_alias("Windows", "11", "10.0.26100")
platform_example_bad_system_error := ""
try {
    stdlib.platform.system(1)
} catch TypeError as err {
    platform_example_bad_system_error := err.Message
}

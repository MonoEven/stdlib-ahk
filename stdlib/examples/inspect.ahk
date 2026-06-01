#Requires AutoHotkey v2.0

#Include <stdlib\inspect>

inspect_example_lambda := (() => 1)
inspect_example_isfunction_free := stdlib.inspect.isfunction(inspect_example_free)
inspect_example_isfunction_lambda := stdlib.inspect.isfunction(inspect_example_lambda)
inspect_example_isfunction_builtin := stdlib.inspect.isfunction(StrLen)
inspect_example_isclass_class := stdlib.inspect.isclass(InspectExampleDemo)
inspect_example_isclass_instance := stdlib.inspect.isclass(InspectExampleDemo())

inspect_example_bad_arity_error := ""
try {
    stdlib.inspect.isfunction()
} catch TypeError as err {
    inspect_example_bad_arity_error := err.Message
}

class InspectExampleDemo
{
}

inspect_example_free(value := 0)
{
    return value
}

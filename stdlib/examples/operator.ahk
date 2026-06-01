#Requires AutoHotkey v2.0

#Include <stdlib\itertools>
#Include <stdlib\operator>

class OperatorExampleLengthHintValue
{
    __New(value)
    {
        this.Value := value
    }

    __LengthHint()
    {
        return this.Value
    }
}

class OperatorExampleLengthHintTypeError
{
    __LengthHint()
    {
        throw TypeError("bad hint", -1)
    }
}

operator_example_values := ["a", "b", "c"]
operator_example_sum := stdlib.operator.add(2, 3)
operator_example_text := stdlib.operator.add("a", "b")
operator_example_repeated := stdlib.operator.mul(["x", "y"], 2)
operator_example_first := stdlib.operator.getitem(operator_example_values, 0)
operator_example_pick := stdlib.operator.itemgetter(-1, 0).Call(operator_example_values)
operator_example_repeat_hint_values := stdlib.itertools.repeat("x", 3)
operator_example_repeat_hint_initial := stdlib.operator.length_hint(operator_example_repeat_hint_values)
operator_example_repeat_hint_first_two := []
for value in stdlib.itertools.islice(operator_example_repeat_hint_values, 2)
    operator_example_repeat_hint_first_two.Push(value)
operator_example_repeat_hint_after_two := stdlib.operator.length_hint(operator_example_repeat_hint_values)
operator_example_repeat_hint_unlimited := stdlib.operator.length_hint(stdlib.itertools.repeat("x"))
operator_example_repeat_hint_unlimited_default := stdlib.operator.length_hint(stdlib.itertools.repeat("x"), 9)
operator_example_default_hint_negative := stdlib.operator.length_hint({ value: 1 }, -1)
operator_example_default_hint_root_true := stdlib.operator.length_hint({ value: 1 }, stdlib.True)
operator_example_default_hint_root_false := stdlib.operator.length_hint({ value: 1 }, stdlib.False)
operator_example_default_hint_none_error := ""
try
    stdlib.operator.length_hint(operator_example_values, stdlib.None)
catch TypeError as err
    operator_example_default_hint_none_error := err.Message
operator_example_default_hint_tuple_error := ""
try
    stdlib.operator.length_hint(operator_example_values, stdlib.tuple())
catch TypeError as err
    operator_example_default_hint_tuple_error := err.Message
operator_example_default_hint_notimplemented_error := ""
try
    stdlib.operator.length_hint(operator_example_values, stdlib.NotImplemented)
catch TypeError as err
    operator_example_default_hint_notimplemented_error := err.Message
operator_example_provider_hint_root_true := stdlib.operator.length_hint(OperatorExampleLengthHintValue(stdlib.True), 9)
operator_example_provider_hint_notimplemented_default := stdlib.operator.length_hint(OperatorExampleLengthHintValue(stdlib.NotImplemented), 9)
operator_example_provider_hint_type_error_default := stdlib.operator.length_hint(OperatorExampleLengthHintTypeError(), 9)
operator_example_provider_hint_none_error := ""
try
    stdlib.operator.length_hint(OperatorExampleLengthHintValue(stdlib.None), 9)
catch TypeError as err
    operator_example_provider_hint_none_error := err.Message

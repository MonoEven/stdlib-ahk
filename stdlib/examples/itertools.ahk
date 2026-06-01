#Requires AutoHotkey v2.0

#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\itertools>
#Include <stdlib\operator>

class ItertoolsExampleCustomTimes
{
}

class ItertoolsExampleCustomIterableSource
{
}

class ItertoolsExampleTeeReenterSource
{
    __New()
    {
        this.First := true
        this.Peer := unset
    }

    __Enum(numberOfVars)
    {
        self := this

        return NextValue

        NextValue(&value)
        {
            first := self.First
            self.First := false
            if !first
                return false

            peerEnum := self.Peer.__Enum(1)
            return peerEnum(&value)
        }
    }
}

ItertoolsExampleFunctionTimes()
{
}

values := []
for value in stdlib.itertools.chain([1, 2], "ab")
    values.Push(value)
chain_repr := stdlib.itertools.chain([1, 2], "ab").__Repr()
chain_plain_iterable_values := []
for value in stdlib.itertools.chain(stdlib_itertools_example_plain_iterable_object("iterables", ["a", "b"]), "x")
    chain_plain_iterable_values.Push(value)
chain_callable_iterable_prop_error := ""
try
    for value in stdlib.itertools.chain(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1)) {
    }
catch TypeError as err
    chain_callable_iterable_prop_error := err.Message
chain_positional_callable_iterable_prop_error := ""
try
    for value in stdlib.itertools.chain("ab", stdlib_itertools_example_plain_callable_object("iterable", (*) => 1)) {
    }
catch TypeError as err
    chain_positional_callable_iterable_prop_error := err.Message

chain_from_iterable_values := []
for value in stdlib.itertools.chain.from_iterable([[1, 2], "ab"])
    chain_from_iterable_values.Push(value)
chain_from_iterable_repr := stdlib.itertools.chain.from_iterable([[1, 2], "ab"]).__Repr()
chain_from_iterable_callable_iterable_prop_error := ""
try
    for value in stdlib.itertools.chain.from_iterable(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1)) {
    }
catch TypeError as err
    chain_from_iterable_callable_iterable_prop_error := err.Message
chain_from_iterable_callable_positional_error := ""
try
    stdlib.itertools.chain.from_iterable("ab", stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    chain_from_iterable_callable_positional_error := err.Message
chain_from_iterable_keyword_error := ""
try
    stdlib.itertools.chain.from_iterable({ iterable: [[1]] })
catch TypeError as err
    chain_from_iterable_keyword_error := err.Message
chain_from_iterable_positional_keyword_error := ""
try
    stdlib.itertools.chain.from_iterable("ab", { iterable: [[1]] })
catch TypeError as err
    chain_from_iterable_positional_keyword_error := err.Message
chain_from_iterable_extra_keyword_error := ""
try
    stdlib.itertools.chain.from_iterable({ extra: 1, another: 2 })
catch TypeError as err
    chain_from_iterable_extra_keyword_error := err.Message
chain_keyword_error := ""
try
    for value in stdlib.itertools.chain({ iterables: [[1]] }) {
    }
catch TypeError as err
    chain_keyword_error := err.Message
chain_positional_keyword_error := ""
try
    for value in stdlib.itertools.chain("ab", { iterable: [[1]] }) {
    }
catch TypeError as err
    chain_positional_keyword_error := err.Message
chain_extra_keyword_error := ""
try
    for value in stdlib.itertools.chain({ extra: 1, another: 2 }) {
    }
catch TypeError as err
    chain_extra_keyword_error := err.Message
chain_duplicate_keyword_error := ""
try
    for value in stdlib.itertools.chain({ extra: 1 }, { extra: 2 }) {
    }
catch TypeError as err
    chain_duplicate_keyword_error := err.Message
chain_from_iterable_duplicate_keyword_error := ""
try
    stdlib.itertools.chain.from_iterable({ extra: 1 }, { extra: 2 })
catch TypeError as err
    chain_from_iterable_duplicate_keyword_error := err.Message
chain_from_iterable_late_keyword_error := ""
try
    stdlib.itertools.chain.from_iterable([["a"]], 2, { extra: 1 })
catch TypeError as err
    chain_from_iterable_late_keyword_error := err.Message

count_option_values := []
for value in stdlib.itertools.islice(stdlib.itertools.count({ start: 3, step: 2 }), 4)
    count_option_values.Push(value)
count_split_option_values := []
for value in stdlib.itertools.islice(stdlib.itertools.count({ start: 3 }, { step: 2 }), 4)
    count_split_option_values.Push(value)
count_split_reversed_option_values := []
for value in stdlib.itertools.islice(stdlib.itertools.count({ step: 2 }, { start: 3 }), 4)
    count_split_reversed_option_values.Push(value)
count_duplicate_start_three_arg_error := ""
try
    stdlib.itertools.count(1, 2, { start: 3 })
catch TypeError as err
    count_duplicate_start_three_arg_error := err.Message
count_options_only_invalid_keyword_error := ""
try
    stdlib.itertools.count({ extra: 3 })
catch TypeError as err
    count_options_only_invalid_keyword_error := err.Message
count_invalid_keyword_error := ""
try
    stdlib.itertools.count({ step: 2, extra: 3 })
catch TypeError as err
    count_invalid_keyword_error := err.Message
count_split_invalid_keyword_error := ""
try
    stdlib.itertools.count({ start: 1 }, { extra: 3 })
catch TypeError as err
    count_split_invalid_keyword_error := err.Message
count_too_many_keyword_error := ""
try
    stdlib.itertools.count({ start: 1, step: 2, extra: 3 })
catch TypeError as err
    count_too_many_keyword_error := err.Message
count_split_too_many_keyword_error := ""
try
    stdlib.itertools.count({ start: 1 }, { step: 2, extra: 3 })
catch TypeError as err
    count_split_too_many_keyword_error := err.Message
count_callable_start_prop_error := ""
try
    stdlib.itertools.count(stdlib_itertools_example_plain_callable_object("start", (*) => 1))
catch TypeError as err
    count_callable_start_prop_error := err.Message
count_callable_step_prop_error := ""
try
    stdlib.itertools.count(0, stdlib_itertools_example_plain_callable_object("step", (*) => 1))
catch TypeError as err
    count_callable_step_prop_error := err.Message
count_repr_values := stdlib.itertools.count(10, 2)
count_repr_initial := count_repr_values.__Repr()
count_repr_first_two := []
for value in stdlib.itertools.islice(count_repr_values, 2)
    count_repr_first_two.Push(value)
count_repr_after_two := count_repr_values.__Repr()

compressed := []
for value in stdlib.itertools.compress("ABCDEF", [1, 0, 1, 0, 1, 1])
    compressed.Push(value)
compressed_selectors_keyword := []
for value in stdlib.itertools.compress("ABC", { selectors: [1, 0, 1] })
    compressed_selectors_keyword.Push(value)
compressed_both_keywords := []
for value in stdlib.itertools.compress({ data: "ABC", selectors: [1, 0, 1] })
    compressed_both_keywords.Push(value)
compressed_data_iterable_keyword_like := []
for value in stdlib.itertools.compress(stdlib_itertools_example_plain_iterable_object("data", ["A", "B", "C"]), [1, 0, 1])
    compressed_data_iterable_keyword_like.Push(value)
compressed_selectors_iterable_keyword_like := []
for value in stdlib.itertools.compress("ABC", stdlib_itertools_example_plain_iterable_object("selectors", [1, 0, 1]))
    compressed_selectors_iterable_keyword_like.Push(value)
compressed_both_iterables_keyword_like := []
for value in stdlib.itertools.compress(stdlib_itertools_example_plain_iterable_object("data", ["A", "B", "C"]), stdlib_itertools_example_plain_iterable_object("selectors", [1, 0, 1]))
    compressed_both_iterables_keyword_like.Push(value)
compressed_callable_data_prop_error := ""
try {
    for value in stdlib.itertools.compress(stdlib_itertools_example_plain_callable_object("data", (*) => 1), [1])
        unset_capture := value
} catch TypeError as err {
    compressed_callable_data_prop_error := err.Message
}
compressed_callable_selectors_prop_error := ""
try {
    for value in stdlib.itertools.compress("ABC", stdlib_itertools_example_plain_callable_object("selectors", (*) => 1))
        unset_capture := value
} catch TypeError as err {
    compressed_callable_selectors_prop_error := err.Message
}
compressed_missing_data_keyword_error := ""
try {
    for value in stdlib.itertools.compress({ selectors: [1, 0, 1] })
        unset_capture := value
} catch TypeError as err {
    compressed_missing_data_keyword_error := err.Message
}
compressed_options_only_error := ""
try {
    for value in stdlib.itertools.compress({ extra: 1 })
        unset_capture := value
} catch TypeError as err {
    compressed_options_only_error := err.Message
}
compressed_missing_selectors_keyword_error := ""
try {
    for value in stdlib.itertools.compress({ data: "ABC" })
        unset_capture := value
} catch TypeError as err {
    compressed_missing_selectors_keyword_error := err.Message
}
compressed_missing_selectors_extra_keyword_error := ""
try {
    for value in stdlib.itertools.compress({ data: "ABC", extra: 1 })
        unset_capture := value
} catch TypeError as err {
    compressed_missing_selectors_extra_keyword_error := err.Message
}
compressed_positional_extra_keyword_error := ""
try {
    for value in stdlib.itertools.compress("ABC", { extra: 1 })
        unset_capture := value
} catch TypeError as err {
    compressed_positional_extra_keyword_error := err.Message
}
compressed_positional_data_keyword_error := ""
try {
    for value in stdlib.itertools.compress("ABC", { data: "XYZ" })
        unset_capture := value
} catch TypeError as err {
    compressed_positional_data_keyword_error := err.Message
}
compressed_duplicate_selectors_keyword_error := ""
try {
    for value in stdlib.itertools.compress("ABC", [1, 0, 1], { selectors: [1, 1, 1] })
        unset_capture := value
} catch TypeError as err {
    compressed_duplicate_selectors_keyword_error := err.Message
}
compressed_positional_selectors_extra_keyword_error := ""
try {
    for value in stdlib.itertools.compress("ABC", { selectors: [1, 0, 1], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    compressed_positional_selectors_extra_keyword_error := err.Message
}
compressed_positional_data_selectors_keyword_error := ""
try {
    for value in stdlib.itertools.compress("ABC", { data: "XYZ", selectors: [1, 0, 1] })
        unset_capture := value
} catch TypeError as err {
    compressed_positional_data_selectors_keyword_error := err.Message
}
compressed_extra_keyword_error := ""
try {
    for value in stdlib.itertools.compress({ data: "ABC", selectors: [1, 0, 1], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    compressed_extra_keyword_error := err.Message
}

compressed_stdlib_truthiness := []
for value in stdlib.itertools.compress("ABCDEFG", [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None])
    compressed_stdlib_truthiness.Push(value)

accumulated := []
for value in stdlib.itertools.accumulate([1, 2, 3, 4])
    accumulated.Push(value)
accumulated_repr := stdlib.itertools.accumulate([1, 2]).__Repr()

accumulated_initial := []
for value in stdlib.itertools.accumulate([1, 2], unset, 10)
    accumulated_initial.Push(value)

accumulated_iterable_keyword := []
for value in stdlib.itertools.accumulate({ iterable: [1, 2, 3] })
    accumulated_iterable_keyword.Push(value)

accumulated_func_keyword := []
for value in stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_itertools_example_mul })
    accumulated_func_keyword.Push(value)
accumulated_func_initial_keyword := []
for value in stdlib.itertools.accumulate([1, 2, 3], { func: stdlib_itertools_example_mul, initial: 10 })
    accumulated_func_initial_keyword.Push(value)
accumulated_missing_iterable_error := ""
try {
    stdlib.itertools.accumulate({ func: stdlib_itertools_example_mul })
} catch TypeError as err {
    accumulated_missing_iterable_error := err.Message
}
accumulated_extra_only_missing_iterable_error := ""
try {
    stdlib.itertools.accumulate({ extra: 1 })
} catch TypeError as err {
    accumulated_extra_only_missing_iterable_error := err.Message
}
accumulated_invalid_keyword_error := ""
try {
    stdlib.itertools.accumulate({ iterable: [1, 2], extra: 1 })
} catch TypeError as err {
    accumulated_invalid_keyword_error := err.Message
}
accumulated_extra_keyword_error := ""
try {
    stdlib.itertools.accumulate({ iterable: [1, 2], func: stdlib_itertools_example_mul, initial: 0, extra: 1 })
} catch TypeError as err {
    accumulated_extra_keyword_error := err.Message
}
accumulated_too_many_keyword_error := ""
try {
    stdlib.itertools.accumulate({ extra: 1, another: 2, third: 3, fourth: 4 })
} catch TypeError as err {
    accumulated_too_many_keyword_error := err.Message
}
accumulated_duplicate_func_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2, 3], stdlib_itertools_example_mul, { func: stdlib_itertools_example_mul })
        unset_capture := value
} catch TypeError as err {
    accumulated_duplicate_func_keyword_error := err.Message
}
accumulated_split_duplicate_func_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_example_mul }, { func: stdlib_itertools_example_mul })
        unset_capture := value
} catch TypeError as err {
    accumulated_split_duplicate_func_keyword_error := err.Message
}
accumulated_split_duplicate_initial_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { initial: 0 }, { initial: 1 })
        unset_capture := value
} catch TypeError as err {
    accumulated_split_duplicate_initial_keyword_error := err.Message
}
accumulated_split_duplicate_extra_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { extra: 1 }, { extra: 2 })
        unset_capture := value
} catch TypeError as err {
    accumulated_split_duplicate_extra_keyword_error := err.Message
}
accumulated_second_arg_invalid_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_example_mul, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    accumulated_second_arg_invalid_keyword_error := err.Message
}
accumulated_second_arg_initial_invalid_keyword_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { initial: 0, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    accumulated_second_arg_initial_invalid_keyword_error := err.Message
}
accumulated_second_arg_extra_arity_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { func: stdlib_itertools_example_mul, initial: 0, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    accumulated_second_arg_extra_arity_error := err.Message
}
accumulated_second_arg_iterable_func_initial_arity_error := ""
try {
    for value in stdlib.itertools.accumulate([1, 2], { iterable: [3, 4], func: stdlib_itertools_example_mul, initial: 0 })
        unset_capture := value
} catch TypeError as err {
    accumulated_second_arg_iterable_func_initial_arity_error := err.Message
}

accumulated_stdlib_operator_mul := []
for value in stdlib.itertools.accumulate([1, 2, 3], stdlib.operator.mul)
    accumulated_stdlib_operator_mul.Push(value)
accumulated_stdlib_operator_truth_initial_error := ""
try {
    truthInitialIterator := stdlib.itertools.accumulate([1, 2], stdlib.operator.truth, { initial: 10 }).__Enum(1)
    truthInitialValue := unset
    truthInitialIterator(&truthInitialValue)
    truthInitialIterator(&truthInitialValue)
} catch TypeError as err {
    accumulated_stdlib_operator_truth_initial_error := err.Message
}

accumulated_all_keywords := []
for value in stdlib.itertools.accumulate({ iterable: [1, 2, 3], func: stdlib_itertools_example_mul, initial: 10 })
    accumulated_all_keywords.Push(value)

accumulated_initial_option := []
for value in stdlib.itertools.accumulate([1, 2], { initial: 10 })
    accumulated_initial_option.Push(value)
accumulated_truth_initial_error := ""
try {
    truthIterator := stdlib.itertools.accumulate([1, 2], stdlib.operator.truth, { initial: 10 }).__Enum(1)
    truthFirst := unset
    truthIterator(&truthFirst)
    truthIterator(&truthFirst)
} catch TypeError as err {
    accumulated_truth_initial_error := err.Message
}
accumulated_callable_iterable_prop_error := ""
try {
    for value in stdlib.itertools.accumulate(stdlib_itertools_example_plain_callable_object("iterable", stdlib_itertools_example_mul))
        unset_capture := value
} catch TypeError as err {
    accumulated_callable_iterable_prop_error := err.Message
}
accumulated_callable_func_prop := []
for value in stdlib.itertools.accumulate([1, 2, 3], stdlib_itertools_example_plain_callable_object("func", stdlib_itertools_example_mul))
    accumulated_callable_func_prop.Push(value)
accumulated_callable_iterable_prop := []
for value in stdlib.itertools.accumulate([1, 2, 3], stdlib_itertools_example_plain_callable_object("iterable", stdlib_itertools_example_mul))
    accumulated_callable_iterable_prop.Push(value)
accumulated_callable_initial_value := stdlib_itertools_example_plain_callable_object("initial", stdlib_itertools_example_mul)
accumulated_callable_initial_empty := []
for value in stdlib.itertools.accumulate([], unset, accumulated_callable_initial_value)
    accumulated_callable_initial_empty.Push(value)
accumulated_callable_initial_empty_same := stdlib.operator.is_(accumulated_callable_initial_empty[1], accumulated_callable_initial_value)
accumulated_callable_initial_one := []
for value in stdlib.itertools.accumulate([1], (left, right) => left, accumulated_callable_initial_value)
    accumulated_callable_initial_one.Push(value)
accumulated_callable_initial_one_same_first := stdlib.operator.is_(accumulated_callable_initial_one[1], accumulated_callable_initial_value)
accumulated_callable_initial_one_same_second := stdlib.operator.is_(accumulated_callable_initial_one[2], accumulated_callable_initial_value)

cycled := []
for value in stdlib.itertools.islice(stdlib.itertools.cycle([1, 2]), 5)
    cycled.Push(value)
cycled_repr := stdlib.itertools.cycle([1, 2]).__Repr()
cycled_plain_iterable_values := []
for value in stdlib.itertools.islice(stdlib.itertools.cycle(stdlib_itertools_example_plain_iterable_object("iterable", [3, 4])), 5)
    cycled_plain_iterable_values.Push(value)
islice_repr := stdlib.itertools.islice([1, 2, 3], 2).__Repr()
cycle_callable_iterable_prop_error := ""
try
    stdlib.itertools.cycle(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    cycle_callable_iterable_prop_error := err.Message
cycle_callable_extra_prop_error := ""
try
    stdlib.itertools.cycle(stdlib_itertools_example_plain_callable_object("extra", (*) => 1))
catch TypeError as err
    cycle_callable_extra_prop_error := err.Message

itertools_example_cycle_int_noniterable_error := ""
try
    stdlib.itertools.cycle(42)
catch TypeError as err
    itertools_example_cycle_int_noniterable_error := err.Message
cycle_keyword_error := ""
try
    stdlib.itertools.cycle({ iterable: [1, 2] })
catch TypeError as err
    cycle_keyword_error := err.Message
cycle_extra_keyword_error := ""
try
    stdlib.itertools.cycle({ extra: 1, another: 2 })
catch TypeError as err
    cycle_extra_keyword_error := err.Message
cycle_duplicate_keyword_error := ""
try
    stdlib.itertools.cycle({ extra: 1 }, { extra: 2 })
catch TypeError as err
    cycle_duplicate_keyword_error := err.Message
cycle_late_keyword_error := ""
try
    stdlib.itertools.cycle([1, 2], 3, { extra: 1 })
catch TypeError as err
    cycle_late_keyword_error := err.Message
cycle_arity_zero_error := ""
try
    stdlib.itertools.cycle()
catch TypeError as err
    cycle_arity_zero_error := err.Message
cycle_arity_two_error := ""
try
    stdlib.itertools.cycle([1, 2], 3)
catch TypeError as err
    cycle_arity_two_error := err.Message

pairwise_pairs := []
for value in stdlib.itertools.pairwise([1, 2, 3, 4])
    pairwise_pairs.Push(stdlib_itertools_example_to_array(value))
pairwise_repr := stdlib.itertools.pairwise([1, 2]).__Repr()

itertools_example_pairwise_int_noniterable_error := ""
try
    stdlib.itertools.pairwise(42)
catch TypeError as err
    itertools_example_pairwise_int_noniterable_error := err.Message
pairwise_keyword_error := ""
try
    stdlib.itertools.pairwise({ iterable: [1, 2] })
catch TypeError as err
    pairwise_keyword_error := err.Message
pairwise_extra_keyword_error := ""
try
    stdlib.itertools.pairwise({ extra: 1, another: 2 })
catch TypeError as err
    pairwise_extra_keyword_error := err.Message
pairwise_callable_iterable_prop_error := ""
try
    stdlib.itertools.pairwise(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    pairwise_callable_iterable_prop_error := err.Message
pairwise_positional_callable_iterable_prop_error := ""
try
    stdlib.itertools.pairwise([1, 2], stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    pairwise_positional_callable_iterable_prop_error := err.Message

pairwise_duplicate_iterable_error := ""
try
    stdlib.itertools.pairwise([1, 2], { iterable: [3, 4] })
catch TypeError as err
    pairwise_duplicate_iterable_error := err.Message
pairwise_duplicate_keyword_error := ""
try
    stdlib.itertools.pairwise({ extra: 1 }, { extra: 2 })
catch TypeError as err
    pairwise_duplicate_keyword_error := err.Message
pairwise_late_keyword_error := ""
try
    stdlib.itertools.pairwise([1, 2], 3, { extra: 1 })
catch TypeError as err
    pairwise_late_keyword_error := err.Message
pairwise_none_extra_positional_error := ""
try
    stdlib.itertools.pairwise([1, 2], stdlib.None)
catch TypeError as err
    pairwise_none_extra_positional_error := err.Message

product_rows := []
for value in stdlib.itertools.product([1, 2], "ab")
    product_rows.Push(stdlib_itertools_example_to_array(value))
product_repr := stdlib.itertools.product([1], [2]).__Repr()

product_repeat_rows := []
for value in stdlib.itertools.product([1, 2], { repeat: 2 })
    product_repeat_rows.Push(stdlib_itertools_example_to_array(value))
product_plain_iterable_rows := []
for value in stdlib.itertools.product([1], stdlib_itertools_example_plain_iterable_object("repeat", [7, 8]))
    product_plain_iterable_rows.Push(stdlib_itertools_example_to_array(value))
product_callable_repeat_prop_error := ""
try
    for value in stdlib.itertools.product(stdlib_itertools_example_plain_callable_object("repeat", (*) => 1)) {
    }
catch TypeError as err
    product_callable_repeat_prop_error := err.Message
product_trailing_callable_repeat_prop_error := ""
try
    for value in stdlib.itertools.product([1], stdlib_itertools_example_plain_callable_object("repeat", (*) => 1)) {
    }
catch TypeError as err
    product_trailing_callable_repeat_prop_error := err.Message

product_duplicate_keyword_error := ""
try
    for value in stdlib.itertools.product([1, 2], { repeat: 2, iterables: "x" }) {
    }
catch TypeError as err
    product_duplicate_keyword_error := err.Message

product_invalid_keyword_error := ""
try
    stdlib.itertools.product({ iterables: "x" })
catch TypeError as err
    product_invalid_keyword_error := err.Message
product_extra_keyword_error := ""
try
    stdlib.itertools.product({ extra: 1 })
catch TypeError as err
    product_extra_keyword_error := err.Message
product_positional_extra_keyword_error := ""
try
    stdlib.itertools.product([1], { extra: 1 })
catch TypeError as err
    product_positional_extra_keyword_error := err.Message
product_split_keyword_error := ""
try
    for value in stdlib.itertools.product([1], { repeat: 2 }, { extra: 1 }) {
    }
catch TypeError as err
    product_split_keyword_error := err.Message
product_options_only_split_keyword_error := ""
try
    for value in stdlib.itertools.product({ repeat: 2 }, { extra: 1 }) {
    }
catch TypeError as err
    product_options_only_split_keyword_error := err.Message
product_duplicate_repeat_split_keyword_error := ""
try
    for value in stdlib.itertools.product([1], { repeat: 2 }, { repeat: 3 }) {
    }
catch TypeError as err
    product_duplicate_repeat_split_keyword_error := err.Message
product_duplicate_invalid_split_keyword_error := ""
try
    for value in stdlib.itertools.product([1], { extra: 1 }, { extra: 2 }) {
    }
catch TypeError as err
    product_duplicate_invalid_split_keyword_error := err.Message

zip_longest_rows := []
for value in stdlib.itertools.zip_longest([1, 2, 3], "ab")
    zip_longest_rows.Push(stdlib_itertools_example_to_array(value))
zip_longest_repr := stdlib.itertools.zip_longest([1], [2]).__Repr()

zip_longest_fill_rows := []
for value in stdlib.itertools.zip_longest([1, 2, 3], "ab", { fillvalue: "X" })
    zip_longest_fill_rows.Push(stdlib_itertools_example_to_array(value))
zip_longest_plain_iterable_rows := []
for value in stdlib.itertools.zip_longest([1], stdlib_itertools_example_plain_iterable_object("fillvalue", ["a", "b"]))
    zip_longest_plain_iterable_rows.Push(stdlib_itertools_example_to_array(value))
zip_longest_callable_fillvalue_prop_error := ""
try
    for value in stdlib.itertools.zip_longest(stdlib_itertools_example_plain_callable_object("fillvalue", (*) => 1)) {
    }
catch TypeError as err
    zip_longest_callable_fillvalue_prop_error := err.Message
zip_longest_trailing_callable_fillvalue_prop_error := ""
try
    for value in stdlib.itertools.zip_longest([1], stdlib_itertools_example_plain_callable_object("fillvalue", (*) => 1)) {
    }
catch TypeError as err
    zip_longest_trailing_callable_fillvalue_prop_error := err.Message

zip_longest_duplicate_keyword_error := ""
try
    for value in stdlib.itertools.zip_longest([1, 2], [3], { fillvalue: "X", iterables: "Y" }) {
    }
catch TypeError as err
    zip_longest_duplicate_keyword_error := err.Message

zip_longest_invalid_keyword_error := ""
try
    stdlib.itertools.zip_longest({ iterables: "x" })
catch TypeError as err
    zip_longest_invalid_keyword_error := err.Message
zip_longest_extra_keyword_error := ""
try
    stdlib.itertools.zip_longest({ extra: 1 })
catch TypeError as err
    zip_longest_extra_keyword_error := err.Message
zip_longest_positional_extra_keyword_error := ""
try
    stdlib.itertools.zip_longest([1], { extra: 1 })
catch TypeError as err
    zip_longest_positional_extra_keyword_error := err.Message
zip_longest_split_keyword_error := ""
try
    for value in stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { extra: 1 }) {
    }
catch TypeError as err
    zip_longest_split_keyword_error := err.Message
zip_longest_options_only_split_keyword_error := ""
try
    for value in stdlib.itertools.zip_longest({ fillvalue: "X" }, { extra: 1 }) {
    }
catch TypeError as err
    zip_longest_options_only_split_keyword_error := err.Message
zip_longest_duplicate_fillvalue_split_keyword_error := ""
try
    for value in stdlib.itertools.zip_longest([1], { fillvalue: "X" }, { fillvalue: "Y" }) {
    }
catch TypeError as err
    zip_longest_duplicate_fillvalue_split_keyword_error := err.Message
zip_longest_duplicate_invalid_split_keyword_error := ""
try
    for value in stdlib.itertools.zip_longest([1], { extra: 1 }, { extra: 2 }) {
    }
catch TypeError as err
    zip_longest_duplicate_invalid_split_keyword_error := err.Message

groupby_rows := []
for value in stdlib.itertools.groupby("aabb")
    groupby_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_repr_source := stdlib.itertools.groupby("a")
groupby_repr := groupby_repr_source.__Repr()
groupby_repr_enum := groupby_repr_source.__Enum(1)
groupby_repr_row := unset
if groupby_repr_enum(&groupby_repr_row)
    groupby_grouper_repr := stdlib_itertools_example_to_array(groupby_repr_row)[2].__Repr()

groupby_key_rows := []
for value in stdlib.itertools.groupby(["ab", "ac", "ba"], { key: stdlib_itertools_example_first_char })
    groupby_key_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_callable_key_prop_rows := []
for value in stdlib.itertools.groupby(["ab", "ac", "ba"], stdlib_itertools_example_plain_callable_object("key", stdlib_itertools_example_first_char))
    groupby_callable_key_prop_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_iterable_key_prop_error := ""
try {
    for value in stdlib.itertools.groupby(["ab", "ac"], stdlib_itertools_example_plain_iterable_object("key", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    groupby_iterable_key_prop_error := err.Message
}
groupby_iterable_iterable_prop_error := ""
try {
    for value in stdlib.itertools.groupby(["ab", "ac"], stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    groupby_iterable_iterable_prop_error := err.Message
}
groupby_split_key_iterable_rows := []
for value in stdlib.itertools.groupby({ key: stdlib_itertools_example_first_char }, { iterable: ["ab", "ac", "ba"] })
    groupby_split_key_iterable_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_callable_iterable_prop_error := ""
try {
    stdlib.itertools.groupby(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
} catch TypeError as err {
    groupby_callable_iterable_prop_error := err.Message
}
groupby_callable_key_prop_error := ""
try {
    stdlib.itertools.groupby(stdlib_itertools_example_plain_callable_object("key", (*) => 1))
} catch TypeError as err {
    groupby_callable_key_prop_error := err.Message
}
groupby_missing_iterable_error := ""
try {
    stdlib.itertools.groupby({ key: stdlib_itertools_example_first_char })
} catch TypeError as err {
    groupby_missing_iterable_error := err.Message
}
groupby_options_only_error := ""
try {
    stdlib.itertools.groupby({ extra: 1 })
} catch TypeError as err {
    groupby_options_only_error := err.Message
}
groupby_invalid_keyword_error := ""
try {
    stdlib.itertools.groupby({ iterable: "aab", extra: 1 })
} catch TypeError as err {
    groupby_invalid_keyword_error := err.Message
}
groupby_split_invalid_keyword_error := ""
try {
    stdlib.itertools.groupby({ extra: 1 }, { iterable: "aab" })
} catch TypeError as err {
    groupby_split_invalid_keyword_error := err.Message
}
groupby_positional_extra_keyword_error := ""
try {
    stdlib.itertools.groupby(["ab"], { extra: 1 })
} catch TypeError as err {
    groupby_positional_extra_keyword_error := err.Message
}
groupby_positional_iterable_keyword_error := ""
try {
    stdlib.itertools.groupby(["ab"], { iterable: "x" })
} catch TypeError as err {
    groupby_positional_iterable_keyword_error := err.Message
}
groupby_extra_keyword_error := ""
try {
    stdlib.itertools.groupby({ iterable: "aab", key: stdlib.None, extra: 1 })
} catch TypeError as err {
    groupby_extra_keyword_error := err.Message
}
groupby_split_missing_iterable_error := ""
try {
    stdlib.itertools.groupby({ key: stdlib_itertools_example_first_char }, { extra: 1 })
} catch TypeError as err {
    groupby_split_missing_iterable_error := err.Message
}
groupby_split_too_many_keyword_error := ""
try {
    stdlib.itertools.groupby({ key: stdlib_itertools_example_first_char }, { iterable: "aab", extra: 1 })
} catch TypeError as err {
    groupby_split_too_many_keyword_error := err.Message
}
groupby_positional_key_extra_keyword_error := ""
try {
    stdlib.itertools.groupby(["ab"], { key: stdlib_itertools_example_first_char, extra: 1 })
} catch TypeError as err {
    groupby_positional_key_extra_keyword_error := err.Message
}
groupby_duplicate_key_error := ""
try {
    stdlib.itertools.groupby(["ab", "ac"], stdlib_itertools_example_first_char, { key: stdlib_itertools_example_first_char })
} catch TypeError as err {
    groupby_duplicate_key_error := err.Message
}
groupby_split_duplicate_iterable_error := ""
try {
    stdlib.itertools.groupby({ iterable: "aab" }, { iterable: "bbc" })
} catch TypeError as err {
    groupby_split_duplicate_iterable_error := err.Message
}
groupby_three_way_duplicate_key_error := ""
try {
    stdlib.itertools.groupby({ iterable: ["ab", "ac"] }, { key: stdlib_itertools_example_first_char }, { key: stdlib.None })
} catch TypeError as err {
    groupby_three_way_duplicate_key_error := err.Message
}
groupby_three_way_duplicate_extra_error := ""
try {
    stdlib.itertools.groupby({ extra: 1 }, { extra: 2 }, { iterable: "aab" })
} catch TypeError as err {
    groupby_three_way_duplicate_extra_error := err.Message
}
groupby_positional_three_way_keyword_error := ""
try {
    stdlib.itertools.groupby("aab", { key: stdlib_itertools_example_first_char }, { extra: 1 })
} catch TypeError as err {
    groupby_positional_three_way_keyword_error := err.Message
}
groupby_iterable_keyword_rows := []
for value in stdlib.itertools.groupby({ iterable: "aab" })
    groupby_iterable_keyword_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_iterable_key_keyword_rows := []
for value in stdlib.itertools.groupby({ iterable: ["ab", "ac", "ba"], key: stdlib_itertools_example_first_char })
    groupby_iterable_key_keyword_rows.Push(stdlib_itertools_example_group_to_array(value))
groupby_stdlib_operator_truth_rows := []
for value in stdlib.itertools.groupby([0, 1, 0], stdlib.operator.truth)
    groupby_stdlib_operator_truth_rows.Push(stdlib_itertools_example_group_to_array(value))

combination_rows := []
for value in stdlib.itertools.combinations([1, 2, 3, 4], 2)
    combination_rows.Push(stdlib_itertools_example_to_array(value))

combination_r_keyword_rows := []
for value in stdlib.itertools.combinations([1, 2, 3], { r: 2 })
    combination_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

combination_split_keyword_rows := []
for value in stdlib.itertools.combinations({ iterable: [1, 2, 3] }, { r: 2 })
    combination_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

combination_reversed_split_keyword_rows := []
for value in stdlib.itertools.combinations({ r: 2 }, { iterable: [1, 2, 3] })
    combination_reversed_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

combination_missing_iterable_error := ""
try {
    for value in stdlib.itertools.combinations({ r: 2 })
        unset_capture := value
} catch TypeError as err {
    combination_missing_iterable_error := err.Message
}
combination_options_only_error := ""
try {
    for value in stdlib.itertools.combinations({ extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_options_only_error := err.Message
}
combination_options_only_count_error := ""
try {
    for value in stdlib.itertools.combinations({ extra: 1, another: 2, third: 3 })
        unset_capture := value
} catch TypeError as err {
    combination_options_only_count_error := err.Message
}
combination_iterable_only_error := ""
try {
    for value in stdlib.itertools.combinations({ iterable: [1, 2] })
        unset_capture := value
} catch TypeError as err {
    combination_iterable_only_error := err.Message
}
combination_missing_r_error := ""
try {
    for value in stdlib.itertools.combinations([1, 2, 3], { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    combination_missing_r_error := err.Message
}
combination_iterable_extra_missing_r_error := ""
try {
    for value in stdlib.itertools.combinations({ iterable: [1, 2], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_iterable_extra_missing_r_error := err.Message
}
combination_split_extra_missing_r_error := ""
try {
    for value in stdlib.itertools.combinations({ extra: 1 }, { iterable: [1, 2] })
        unset_capture := value
} catch TypeError as err {
    combination_split_extra_missing_r_error := err.Message
}
combination_iterable_count_error := ""
try {
    for value in stdlib.itertools.combinations({ iterable: [1], extra: 1, another: 2 })
        unset_capture := value
} catch TypeError as err {
    combination_iterable_count_error := err.Message
}
combination_r_extra_missing_iterable_error := ""
try {
    for value in stdlib.itertools.combinations({ r: 2, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_r_extra_missing_iterable_error := err.Message
}
combination_iterable_r_extra_error := ""
try {
    for value in stdlib.itertools.combinations({ iterable: [1, 2], r: 2, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_iterable_r_extra_error := err.Message
}
combination_split_keyword_count_error := ""
try {
    for value in stdlib.itertools.combinations({ r: 2 }, { iterable: [1, 2], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_split_keyword_count_error := err.Message
}
combination_positional_extra_only_error := ""
try {
    for value in stdlib.itertools.combinations([1, 2], { extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_positional_extra_only_error := err.Message
}
combination_positional_r_extra_error := ""
try {
    for value in stdlib.itertools.combinations([1, 2], { r: 1, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    combination_positional_r_extra_error := err.Message
}
combination_positional_r_extra_count_error := ""
try {
    for value in stdlib.itertools.combinations([1], { r: 2, extra: 1, another: 2 })
        unset_capture := value
} catch TypeError as err {
    combination_positional_r_extra_count_error := err.Message
}
combination_too_many_args_error := ""
try {
    for value in stdlib.itertools.combinations([1, 2, 3], 2, { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    combination_too_many_args_error := err.Message
}

combination_iterable_r_keyword_rows := []
for value in stdlib.itertools.combinations({ iterable: [1, 2, 3], r: 2 })
    combination_iterable_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

combination_root_true_rows := []
for value in stdlib.itertools.combinations([1, 2], stdlib.True)
    combination_root_true_rows.Push(stdlib_itertools_example_to_array(value))

combination_root_false_rows := []
for value in stdlib.itertools.combinations([1, 2], stdlib.False)
    combination_root_false_rows.Push(stdlib_itertools_example_to_array(value))
combination_callable_iterable_prop_error := ""
try {
    for value in stdlib.itertools.combinations(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1), 1)
        unset_capture := value
} catch TypeError as err {
    combination_callable_iterable_prop_error := err.Message
}
combination_callable_r_prop_error := ""
try {
    for value in stdlib.itertools.combinations("ab", stdlib_itertools_example_plain_callable_object("r", (*) => 1))
        unset_capture := value
} catch TypeError as err {
    combination_callable_r_prop_error := err.Message
}
combination_iterable_iterable_prop_rows := []
for value in stdlib.itertools.combinations(stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]), 1)
    combination_iterable_iterable_prop_rows.Push(stdlib_itertools_example_to_array(value))
combination_iterable_r_prop_rows := []
for value in stdlib.itertools.combinations(stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]), 1)
    combination_iterable_r_prop_rows.Push(stdlib_itertools_example_to_array(value))
combination_iterable_iterable_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations("ab", stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    combination_iterable_iterable_prop_r_error := err.Message
}
combination_iterable_r_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations("ab", stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    combination_iterable_r_prop_r_error := err.Message
}
combination_iterable_extra_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations("ab", stdlib_itertools_example_plain_iterable_object("extra", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    combination_iterable_extra_prop_r_error := err.Message
}

replacement_rows := []
for value in stdlib.itertools.combinations_with_replacement([1, 2, 3], 2)
    replacement_rows.Push(stdlib_itertools_example_to_array(value))

replacement_r_keyword_rows := []
for value in stdlib.itertools.combinations_with_replacement([1, 2, 3], { r: 2 })
    replacement_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

replacement_iterable_r_keyword_rows := []
for value in stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3], r: 2 })
    replacement_iterable_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

replacement_split_keyword_rows := []
for value in stdlib.itertools.combinations_with_replacement({ iterable: [1, 2, 3] }, { r: 2 })
    replacement_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

replacement_reversed_split_keyword_rows := []
for value in stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: [1, 2, 3] })
    replacement_reversed_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

replacement_missing_iterable_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ r: 2 })
        unset_capture := value
} catch TypeError as err {
    replacement_missing_iterable_error := err.Message
}
replacement_options_only_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ extra: 1 })
        unset_capture := value
} catch TypeError as err {
    replacement_options_only_error := err.Message
}
replacement_options_only_count_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ extra: 1, another: 2, third: 3 })
        unset_capture := value
} catch TypeError as err {
    replacement_options_only_count_error := err.Message
}
replacement_iterable_only_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ iterable: [1, 2] })
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_only_error := err.Message
}
replacement_missing_r_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement([1, 2, 3], { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    replacement_missing_r_error := err.Message
}
replacement_split_extra_missing_r_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ extra: 1 }, { iterable: [1, 2] })
        unset_capture := value
} catch TypeError as err {
    replacement_split_extra_missing_r_error := err.Message
}
replacement_iterable_count_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ iterable: [1], extra: 1, another: 2 })
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_count_error := err.Message
}
replacement_positional_extra_only_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement([1, 2], { extra: 1 })
        unset_capture := value
} catch TypeError as err {
    replacement_positional_extra_only_error := err.Message
}
replacement_iterable_r_extra_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ iterable: [1, 2], r: 2, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_r_extra_error := err.Message
}
replacement_split_keyword_count_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement({ r: 2 }, { iterable: [1, 2], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    replacement_split_keyword_count_error := err.Message
}
replacement_too_many_args_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement([1, 2, 3], 2, { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    replacement_too_many_args_error := err.Message
}
replacement_positional_r_extra_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement([1, 2], { r: 1, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    replacement_positional_r_extra_error := err.Message
}
replacement_positional_r_extra_count_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement([1], { r: 2, extra: 1, another: 2 })
        unset_capture := value
} catch TypeError as err {
    replacement_positional_r_extra_count_error := err.Message
}

permutation_positional_r_extra_error := ""
try {
    for value in stdlib.itertools.permutations([1, 2], { r: 1, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_positional_r_extra_error := err.Message
}

replacement_root_true_rows := []
for value in stdlib.itertools.combinations_with_replacement([1, 2], stdlib.True)
    replacement_root_true_rows.Push(stdlib_itertools_example_to_array(value))

replacement_root_false_rows := []
for value in stdlib.itertools.combinations_with_replacement([1, 2], stdlib.False)
    replacement_root_false_rows.Push(stdlib_itertools_example_to_array(value))
replacement_callable_iterable_prop_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1), 1)
        unset_capture := value
} catch TypeError as err {
    replacement_callable_iterable_prop_error := err.Message
}
replacement_callable_r_prop_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement("ab", stdlib_itertools_example_plain_callable_object("r", (*) => 1))
        unset_capture := value
} catch TypeError as err {
    replacement_callable_r_prop_error := err.Message
}
replacement_iterable_iterable_prop_rows := []
for value in stdlib.itertools.combinations_with_replacement(stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]), 1)
    replacement_iterable_iterable_prop_rows.Push(stdlib_itertools_example_to_array(value))
replacement_iterable_r_prop_rows := []
for value in stdlib.itertools.combinations_with_replacement(stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]), 1)
    replacement_iterable_r_prop_rows.Push(stdlib_itertools_example_to_array(value))
replacement_iterable_iterable_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement("ab", stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_iterable_prop_r_error := err.Message
}
replacement_iterable_r_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement("ab", stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_r_prop_r_error := err.Message
}
replacement_iterable_extra_prop_r_error := ""
try {
    for value in stdlib.itertools.combinations_with_replacement("ab", stdlib_itertools_example_plain_iterable_object("extra", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    replacement_iterable_extra_prop_r_error := err.Message
}

permutation_rows := []
for value in stdlib.itertools.permutations([1, 2, 3], 2)
    permutation_rows.Push(stdlib_itertools_example_to_array(value))

permutation_invalid_keyword_error := ""
try {
    for value in stdlib.itertools.permutations({ iterable: [1, 2], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_invalid_keyword_error := err.Message
}
permutation_options_only_error := ""
try {
    for value in stdlib.itertools.permutations({ extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_options_only_error := err.Message
}
permutation_options_only_count_error := ""
try {
    for value in stdlib.itertools.permutations({ extra: 1, another: 2, third: 3 })
        unset_capture := value
} catch TypeError as err {
    permutation_options_only_count_error := err.Message
}
permutation_r_extra_missing_iterable_error := ""
try {
    for value in stdlib.itertools.permutations({ r: 2, extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_r_extra_missing_iterable_error := err.Message
}

permutation_r_keyword_rows := []
for value in stdlib.itertools.permutations([1, 2, 3], { r: 2 })
    permutation_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

permutation_iterable_r_keyword_rows := []
for value in stdlib.itertools.permutations({ iterable: [1, 2, 3], r: 2 })
    permutation_iterable_r_keyword_rows.Push(stdlib_itertools_example_to_array(value))

permutation_split_keyword_rows := []
for value in stdlib.itertools.permutations({ iterable: [1, 2, 3] }, { r: 2 })
    permutation_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

permutation_reversed_split_keyword_rows := []
for value in stdlib.itertools.permutations({ r: 2 }, { iterable: [1, 2, 3] })
    permutation_reversed_split_keyword_rows.Push(stdlib_itertools_example_to_array(value))

permutation_missing_iterable_error := ""
try {
    for value in stdlib.itertools.permutations({ r: 2 })
        unset_capture := value
} catch TypeError as err {
    permutation_missing_iterable_error := err.Message
}
permutation_split_invalid_keyword_error := ""
try {
    for value in stdlib.itertools.permutations({ extra: 1 }, { iterable: [1, 2, 3] })
        unset_capture := value
} catch TypeError as err {
    permutation_split_invalid_keyword_error := err.Message
}
permutation_split_invalid_keyword_reversed_error := ""
try {
    for value in stdlib.itertools.permutations({ iterable: [1, 2, 3] }, { extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_split_invalid_keyword_reversed_error := err.Message
}
permutation_split_keyword_count_error := ""
try {
    for value in stdlib.itertools.permutations({ r: 2 }, { iterable: [1, 2, 3], extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_split_keyword_count_error := err.Message
}
permutation_duplicate_iterable_error := ""
try {
    for value in stdlib.itertools.permutations([1, 2, 3], { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    permutation_duplicate_iterable_error := err.Message
}
permutation_positional_extra_only_error := ""
try {
    for value in stdlib.itertools.permutations([1], { extra: 1 })
        unset_capture := value
} catch TypeError as err {
    permutation_positional_extra_only_error := err.Message
}
permutation_too_many_args_error := ""
try {
    for value in stdlib.itertools.permutations([1, 2, 3], 2, { iterable: [4, 5] })
        unset_capture := value
} catch TypeError as err {
    permutation_too_many_args_error := err.Message
}
permutation_positional_r_extra_count_error := ""
try {
    for value in stdlib.itertools.permutations([1], { r: 2, extra: 1, another: 2 })
        unset_capture := value
} catch TypeError as err {
    permutation_positional_r_extra_count_error := err.Message
}

permutation_root_true_rows := []
for value in stdlib.itertools.permutations([1, 2], stdlib.True)
    permutation_root_true_rows.Push(stdlib_itertools_example_to_array(value))

permutation_root_false_rows := []
for value in stdlib.itertools.permutations([1, 2], stdlib.False)
    permutation_root_false_rows.Push(stdlib_itertools_example_to_array(value))
permutation_callable_iterable_prop_error := ""
try {
    for value in stdlib.itertools.permutations(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1), 1)
        unset_capture := value
} catch TypeError as err {
    permutation_callable_iterable_prop_error := err.Message
}
permutation_callable_r_prop_error := ""
try {
    for value in stdlib.itertools.permutations("ab", stdlib_itertools_example_plain_callable_object("r", (*) => 1))
        unset_capture := value
} catch TypeError as err {
    permutation_callable_r_prop_error := err.Message
}
permutation_iterable_iterable_prop_rows := []
for value in stdlib.itertools.permutations(stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]), 1)
    permutation_iterable_iterable_prop_rows.Push(stdlib_itertools_example_to_array(value))
permutation_iterable_r_prop_rows := []
for value in stdlib.itertools.permutations(stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]), 1)
    permutation_iterable_r_prop_rows.Push(stdlib_itertools_example_to_array(value))
permutation_iterable_iterable_prop_r_error := ""
try {
    for value in stdlib.itertools.permutations("ab", stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    permutation_iterable_iterable_prop_r_error := err.Message
}
permutation_iterable_r_prop_r_error := ""
try {
    for value in stdlib.itertools.permutations("ab", stdlib_itertools_example_plain_iterable_object("r", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    permutation_iterable_r_prop_r_error := err.Message
}
permutation_iterable_extra_prop_r_error := ""
try {
    for value in stdlib.itertools.permutations("ab", stdlib_itertools_example_plain_iterable_object("extra", ["a", "b"]))
        unset_capture := value
} catch TypeError as err {
    permutation_iterable_extra_prop_r_error := err.Message
}

starmapped := []
for value in stdlib.itertools.starmap(stdlib_itertools_example_add, [[1, 2], [3, 4]])
    starmapped.Push(value)

starmapped_stdlib_operator_add := []
for value in stdlib.itertools.starmap(stdlib.operator.add, [[1, 2], [3, 4]])
    starmapped_stdlib_operator_add.Push(value)
starmapped_plain_callable := []
for value in stdlib.itertools.starmap(stdlib_itertools_example_plain_callable_object("function", stdlib_itertools_example_add), [[1, 2], [3, 4]])
    starmapped_plain_callable.Push(value)
starmapped_plain_iterable := []
for value in stdlib.itertools.starmap(stdlib_itertools_example_add, stdlib_itertools_example_plain_iterable_object("iterable", [[1, 2], [3, 4]]))
    starmapped_plain_iterable.Push(value)

itertools_example_starmap_noncallable_error := ""
try
    for value in stdlib.itertools.starmap(42, [[1, 2]])
        starmapped.Push(value)
catch TypeError as err
    itertools_example_starmap_noncallable_error := err.Message

itertools_example_starmap_noniterable_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, 42)
catch TypeError as err
    itertools_example_starmap_noniterable_error := err.Message
itertools_example_starmap_keyword_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, [[1, 2]], { iterable: [[3, 4]] })
catch TypeError as err
    itertools_example_starmap_keyword_error := err.Message
itertools_example_starmap_options_only_keyword_error := ""
try
    stdlib.itertools.starmap({ extra: 1, another: 2 })
catch TypeError as err
    itertools_example_starmap_options_only_keyword_error := err.Message
itertools_example_starmap_second_arg_keyword_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, { extra: 1 })
catch TypeError as err
    itertools_example_starmap_second_arg_keyword_error := err.Message
itertools_example_starmap_duplicate_keyword_error := ""
try
    stdlib.itertools.starmap({ extra: 1 }, { extra: 2 })
catch TypeError as err
    itertools_example_starmap_duplicate_keyword_error := err.Message
itertools_example_starmap_late_keyword_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, [[1, 2]], 3, { extra: 1 })
catch TypeError as err
    itertools_example_starmap_late_keyword_error := err.Message
itertools_example_starmap_callable_second_arg_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    itertools_example_starmap_callable_second_arg_error := err.Message
itertools_example_starmap_callable_third_arg_error := ""
try
    stdlib.itertools.starmap(stdlib_itertools_example_add, [[1, 2]], stdlib_itertools_example_plain_callable_object("function", (*) => 1))
catch TypeError as err
    itertools_example_starmap_callable_third_arg_error := err.Message

filterfalse_values := []
for value in stdlib.itertools.filterfalse(stdlib_itertools_example_less_than_three, [1, 2, 3, 1, 4])
    filterfalse_values.Push(value)

filterfalse_none_values := []
for value in stdlib.itertools.filterfalse(stdlib.None, [0, 1, "", "x", stdlib.None, [], [1]])
    filterfalse_none_values.Push(value)
filterfalse_stdlib_operator_truth := []
for value in stdlib.itertools.filterfalse(stdlib.operator.truth, [0, 1, 2])
    filterfalse_stdlib_operator_truth.Push(value)
filterfalse_plain_callable := []
for value in stdlib.itertools.filterfalse(stdlib_itertools_example_plain_callable_object("predicate", stdlib_itertools_example_less_than_three), [1, 2, 3, 1, 4])
    filterfalse_plain_callable.Push(value)
filterfalse_plain_iterable := []
for value in stdlib.itertools.filterfalse(stdlib_itertools_example_less_than_three, stdlib_itertools_example_plain_iterable_object("iterable", [1, 2, 3, 1, 4]))
    filterfalse_plain_iterable.Push(value)
filterfalse_keyword_error := ""
try
    stdlib.itertools.filterfalse(stdlib_itertools_example_truthiness_result, { iterable: [1] })
catch TypeError as err
    filterfalse_keyword_error := err.Message
filterfalse_extra_keyword_error := ""
try
    stdlib.itertools.filterfalse(stdlib_itertools_example_truthiness_result, { extra: 1 })
catch TypeError as err
    filterfalse_extra_keyword_error := err.Message
filterfalse_third_arg_keyword_error := ""
try
    stdlib.itertools.filterfalse(stdlib_itertools_example_truthiness_result, [1], { extra: 1 })
catch TypeError as err
    filterfalse_third_arg_keyword_error := err.Message
filterfalse_duplicate_keyword_error := ""
try
    stdlib.itertools.filterfalse({ extra: 1 }, { extra: 2 })
catch TypeError as err
    filterfalse_duplicate_keyword_error := err.Message
filterfalse_late_keyword_error := ""
try
    stdlib.itertools.filterfalse(stdlib_itertools_example_truthiness_result, [1], 3, { extra: 1 })
catch TypeError as err
    filterfalse_late_keyword_error := err.Message

dropwhile_values := []
for value in stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, [1, 2, 3, 1, 4])
    dropwhile_values.Push(value)
dropwhile_stdlib_operator_truth := []
for value in stdlib.itertools.dropwhile(stdlib.operator.truth, [0, 1, 2])
    dropwhile_stdlib_operator_truth.Push(value)
dropwhile_plain_callable := []
for value in stdlib.itertools.dropwhile(stdlib_itertools_example_plain_callable_object("predicate", stdlib_itertools_example_less_than_three), [1, 2, 3, 1])
    dropwhile_plain_callable.Push(value)
dropwhile_plain_iterable := []
for value in stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, stdlib_itertools_example_plain_iterable_object("iterable", [1, 2, 3, 1]))
    dropwhile_plain_iterable.Push(value)
dropwhile_keyword_error := ""
try
    stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, { iterable: [1] })
catch TypeError as err
    dropwhile_keyword_error := err.Message
dropwhile_extra_keyword_error := ""
try
    stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, { extra: 1 })
catch TypeError as err
    dropwhile_extra_keyword_error := err.Message
dropwhile_third_arg_keyword_error := ""
try
    stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, [1], { extra: 1 })
catch TypeError as err
    dropwhile_third_arg_keyword_error := err.Message
dropwhile_duplicate_keyword_error := ""
try
    stdlib.itertools.dropwhile({ extra: 1 }, { extra: 2 })
catch TypeError as err
    dropwhile_duplicate_keyword_error := err.Message
dropwhile_late_keyword_error := ""
try
    stdlib.itertools.dropwhile(stdlib_itertools_example_less_than_three, [1], 3, { extra: 1 })
catch TypeError as err
    dropwhile_late_keyword_error := err.Message

takewhile_stdlib_truthiness := []
for value in stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, [0, 1, 2, 3, 4, 5, 6])
    takewhile_stdlib_truthiness.Push(value)
takewhile_stdlib_operator_truth := []
for value in stdlib.itertools.takewhile(stdlib.operator.truth, [0, 1, 2])
    takewhile_stdlib_operator_truth.Push(value)
takewhile_plain_callable := []
for value in stdlib.itertools.takewhile(stdlib_itertools_example_plain_callable_object("predicate", stdlib_itertools_example_less_than_three), [1, 2, 3, 1])
    takewhile_plain_callable.Push(value)
takewhile_plain_iterable := []
for value in stdlib.itertools.takewhile(stdlib_itertools_example_less_than_three, stdlib_itertools_example_plain_iterable_object("iterable", [1, 2, 3, 1]))
    takewhile_plain_iterable.Push(value)
takewhile_keyword_error := ""
try
    stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, { iterable: [1] })
catch TypeError as err
    takewhile_keyword_error := err.Message
takewhile_extra_keyword_error := ""
try
    stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, { extra: 1 })
catch TypeError as err
    takewhile_extra_keyword_error := err.Message
takewhile_third_arg_keyword_error := ""
try
    stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, [1], { extra: 1 })
catch TypeError as err
    takewhile_third_arg_keyword_error := err.Message
takewhile_duplicate_keyword_error := ""
try
    stdlib.itertools.takewhile({ extra: 1 }, { extra: 2 })
catch TypeError as err
    takewhile_duplicate_keyword_error := err.Message
takewhile_late_keyword_error := ""
try
    stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, [1], 3, { extra: 1 })
catch TypeError as err
    takewhile_late_keyword_error := err.Message

itertools_example_takewhile_noncallable_error := ""
try
    for value in stdlib.itertools.takewhile(42, [1])
        takewhile_stdlib_truthiness.Push(value)
catch TypeError as err
    itertools_example_takewhile_noncallable_error := err.Message

itertools_example_takewhile_noniterable_error := ""
try
    stdlib.itertools.takewhile(stdlib_itertools_example_truthiness_result, 42)
catch TypeError as err
    itertools_example_takewhile_noniterable_error := err.Message

tee_copies := stdlib.itertools.tee([1, 2, 3], 2)
tee_copies_is_tuple := tee_copies is AhkStdlibTuple
tee_first := []
for value in stdlib.itertools.islice(tee_copies[1], 2)
    tee_first.Push(value)
tee_second := []
for value in tee_copies[2]
    tee_second.Push(value)
tee_first_rest := []
for value in tee_copies[1]
    tee_first_rest.Push(value)
tee_repr := tee_copies[1].__Repr()
tee_type := tee_copies[1].__class__
tee_from_iterable := []
for value in tee_type("def")
    tee_from_iterable.Push(value)
tee_ctor_source := stdlib.itertools.tee("abc")
tee_from_clone := []
for value in tee_type(tee_ctor_source[1])
    tee_from_clone.Push(value)
tee_ctor_source_first := []
for value in tee_ctor_source[1]
    tee_ctor_source_first.Push(value)
tee_ctor_source_second := []
for value in tee_ctor_source[2]
    tee_ctor_source_second.Push(value)
tee_root_true_copies := stdlib.itertools.tee([7, 8], stdlib.True)
tee_root_true := []
for value in tee_root_true_copies[1]
    tee_root_true.Push(value)
tee_plain_n_copies := stdlib.itertools.tee(stdlib_itertools_example_plain_iterable_object("n", ["a", "b"]))
tee_plain_n_first := []
for value in tee_plain_n_copies[1]
    tee_plain_n_first.Push(value)
tee_plain_n_second := []
for value in tee_plain_n_copies[2]
    tee_plain_n_second.Push(value)
tee_plain_iterable_prop_copies := stdlib.itertools.tee(stdlib_itertools_example_plain_iterable_object("iterable", ["a", "b"]))
tee_plain_iterable_prop_first := []
for value in tee_plain_iterable_prop_copies[1]
    tee_plain_iterable_prop_first.Push(value)
tee_plain_iterable_prop_second := []
for value in tee_plain_iterable_prop_copies[2]
    tee_plain_iterable_prop_second.Push(value)
tee_callable_n_prop_error := ""
try
    stdlib.itertools.tee(stdlib_itertools_example_plain_callable_object("n", (*) => 1))
catch TypeError as err
    tee_callable_n_prop_error := err.Message
tee_callable_iterable_prop_error := ""
try
    stdlib.itertools.tee(stdlib_itertools_example_plain_callable_object("iterable", (*) => 1))
catch TypeError as err
    tee_callable_iterable_prop_error := err.Message
tee_positional_callable_n_prop_error := ""
try
    stdlib.itertools.tee([1, 2], stdlib_itertools_example_plain_callable_object("n", (*) => 1))
catch TypeError as err
    tee_positional_callable_n_prop_error := err.Message
tee_third_callable_n_prop_error := ""
try
    stdlib.itertools.tee([1, 2], 2, stdlib_itertools_example_plain_callable_object("n", (*) => 1))
catch TypeError as err
    tee_third_callable_n_prop_error := err.Message
tee_root_false_copies := stdlib.itertools.tee(ItertoolsExampleCustomIterableSource(), stdlib.False)
tee_readonly_error := ""
try {
    tee_copies[1] := "x"
} catch TypeError as err {
    tee_readonly_error := err.Message
}
tee_reenter_error := ""
tee_reenter_source := ItertoolsExampleTeeReenterSource()
tee_reenter_copies := stdlib.itertools.tee(tee_reenter_source, 2)
tee_reenter_first := tee_reenter_copies[1]
tee_reenter_source.Peer := tee_reenter_copies[2]
try
    stdlib_itertools_example_next(tee_reenter_first)
catch RuntimeError as err
    tee_reenter_error := err.Message
tee_ctor_missing_error := ""
try
    tee_type()
catch TypeError as err
    tee_ctor_missing_error := err.Message
tee_ctor_noniterable_error := ""
try
    tee_type(10)
catch TypeError as err
    tee_ctor_noniterable_error := err.Message
tee_ctor_keyword_error := ""
try
    tee_type({ iterable: "def" })
catch TypeError as err
    tee_ctor_keyword_error := err.Message
tee_ctor_positional_keyword_error := ""
try
    tee_type("def", { iterable: "ghi" })
catch TypeError as err
    tee_ctor_positional_keyword_error := err.Message

counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(10, 2), 4)
    counted.Push(value)

root_true_zero_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.True, stdlib.False), 3)
    root_true_zero_step_counted.Push(value)

root_false_true_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.False, stdlib.True), 4)
    root_false_true_step_counted.Push(value)

decimal_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.decimal.Decimal("1.5")), 2)
    decimal_counted.Push(String(value))

decimal_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.decimal.Decimal("1.5"), stdlib.decimal.Decimal("0.5")), 3)
    decimal_step_counted.Push(String(value))

fraction_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.fractions.Fraction(1, 2)), 2)
    fraction_counted.Push(String(value))

fraction_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), stdlib.fractions.Fraction(1, 3)), 3)
    fraction_step_counted.Push(String(value))

float_fraction_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(1.5, stdlib.fractions.Fraction(1, 2)), 3)
    float_fraction_step_counted.Push(value)

fraction_float_step_counted := []
for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), 0.5), 3)
    fraction_float_step_counted.Push(Type(value) = "AhkStdlibFractionsFractionValue" ? String(value) : value)

unbounded_slice := []
for value in stdlib.itertools.islice([10, 11, 12, 13], 1, stdlib.None, 2)
    unbounded_slice.Push(value)

none_start_slice := []
for value in stdlib.itertools.islice([10, 11, 12, 13], stdlib.None, stdlib.None, 2)
    none_start_slice.Push(value)

root_true_stop_slice := []
for value in stdlib.itertools.islice([10, 11, 12], stdlib.True)
    root_true_stop_slice.Push(value)

root_false_true_slice := []
for value in stdlib.itertools.islice([10, 11, 12], stdlib.False, stdlib.True)
    root_false_true_slice.Push(value)

repeated := []
for value in stdlib.itertools.repeat("x", 3)
    repeated.Push(value)
repeat_repr_values := stdlib.itertools.repeat("x", 3)
repeat_repr_initial := repeat_repr_values.__Repr()
repeat_repr_first_two := []
for value in stdlib.itertools.islice(repeat_repr_values, 2)
    repeat_repr_first_two.Push(value)
repeat_repr_after_two := repeat_repr_values.__Repr()
repeat_repr_unlimited := stdlib.itertools.repeat("x").__Repr()
repeated_root_true := []
for value in stdlib.itertools.repeat("x", stdlib.True)
    repeated_root_true.Push(value)
repeated_root_false := []
for value in stdlib.itertools.repeat("x", stdlib.False)
    repeated_root_false.Push(value)
repeated_keyword_times := []
for value in stdlib.itertools.repeat("x", { times: 3 })
    repeated_keyword_times.Push(value)
repeated_keyword_both := []
for value in stdlib.itertools.repeat({ object: "x", times: 3 })
    repeated_keyword_both.Push(value)
repeated_split_keyword := []
for value in stdlib.itertools.repeat({ object: "x" }, { times: 3 })
    repeated_split_keyword.Push(value)
repeated_reversed_split_keyword := []
for value in stdlib.itertools.repeat({ times: 3 }, { object: "x" })
    repeated_reversed_split_keyword.Push(value)
repeated_keyword_object_only := []
for value in stdlib.itertools.islice(stdlib.itertools.repeat({ object: "x" }), 4)
    repeated_keyword_object_only.Push(value)
repeated_object_prop_value := []
for value in stdlib.itertools.islice(stdlib.itertools.repeat(stdlib_itertools_example_plain_iterable_object("object", ["A", "B"])), 2)
    repeated_object_prop_value.Push(stdlib_itertools_example_to_array(value))
repeated_times_prop_value := []
for value in stdlib.itertools.repeat(stdlib_itertools_example_plain_iterable_object("times", ["C", "D"]), 2)
    repeated_times_prop_value.Push(stdlib_itertools_example_to_array(value))
itertools_example_iterable_times_value_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib_itertools_example_plain_iterable_object("times", ["A", "B"]))
catch TypeError as err
    itertools_example_iterable_times_value_repeat_error := err.Message

itertools_example_callable_times_value_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib_itertools_example_plain_callable_object("times", (*) => 1))
catch TypeError as err
    itertools_example_callable_times_value_repeat_error := err.Message

itertools_example_invalid_stop_error := ""
try
    stdlib.itertools.islice([1, 2, 3], 1, 2.0)
catch ValueError as err
    itertools_example_invalid_stop_error := err.Message

itertools_example_none_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib.None)
catch TypeError as err
    itertools_example_none_repeat_error := err.Message

itertools_example_notimplemented_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib.NotImplemented)
catch TypeError as err
    itertools_example_notimplemented_repeat_error := err.Message

itertools_example_custom_repeat_error := ""
try
    stdlib.itertools.repeat("x", ItertoolsExampleCustomTimes())
catch TypeError as err
    itertools_example_custom_repeat_error := err.Message

itertools_example_list_repeat_error := ""
try
    stdlib.itertools.repeat("x", [])
catch TypeError as err
    itertools_example_list_repeat_error := err.Message

itertools_example_dict_repeat_error := ""
try
    stdlib.itertools.repeat("x", Map())
catch TypeError as err
    itertools_example_dict_repeat_error := err.Message

itertools_example_fraction_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib.fractions.Fraction(1, 1))
catch TypeError as err
    itertools_example_fraction_repeat_error := err.Message

itertools_example_decimal_repeat_error := ""
try
    stdlib.itertools.repeat("x", stdlib.decimal.Decimal("1"))
catch TypeError as err
    itertools_example_decimal_repeat_error := err.Message

itertools_example_function_repeat_error := ""
try
    stdlib.itertools.repeat("x", ItertoolsExampleFunctionTimes)
catch TypeError as err
    itertools_example_function_repeat_error := err.Message

itertools_example_missing_object_repeat_error := ""
try
    stdlib.itertools.repeat({ times: 3 })
catch TypeError as err
    itertools_example_missing_object_repeat_error := err.Message

itertools_example_options_only_missing_object_repeat_error := ""
try
    stdlib.itertools.repeat({ extra: 1 })
catch TypeError as err
    itertools_example_options_only_missing_object_repeat_error := err.Message

itertools_example_options_only_two_key_missing_object_repeat_error := ""
try
    stdlib.itertools.repeat({ extra: 1, another: 2 })
catch TypeError as err
    itertools_example_options_only_two_key_missing_object_repeat_error := err.Message

itertools_example_options_only_too_many_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ times: 3, extra: 1, another: 2 })
catch TypeError as err
    itertools_example_options_only_too_many_keyword_repeat_error := err.Message

itertools_example_invalid_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x", extra: 1 })
catch TypeError as err
    itertools_example_invalid_keyword_repeat_error := err.Message

itertools_example_split_invalid_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x" }, { extra: 1 })
catch TypeError as err
    itertools_example_split_invalid_keyword_repeat_error := err.Message

itertools_example_split_missing_object_repeat_error := ""
try
    stdlib.itertools.repeat({ times: 3 }, { extra: 1 })
catch TypeError as err
    itertools_example_split_missing_object_repeat_error := err.Message

itertools_example_split_too_many_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x" }, { times: 3, extra: 1 })
catch TypeError as err
    itertools_example_split_too_many_keyword_repeat_error := err.Message

itertools_example_split_duplicate_object_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x" }, { object: "y" })
catch TypeError as err
    itertools_example_split_duplicate_object_repeat_error := err.Message

itertools_example_split_duplicate_times_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x", times: 3 }, { times: 4 })
catch TypeError as err
    itertools_example_split_duplicate_times_repeat_error := err.Message

itertools_example_split_duplicate_invalid_repeat_error := ""
try
    stdlib.itertools.repeat({ extra: 1 }, { extra: 2 })
catch TypeError as err
    itertools_example_split_duplicate_invalid_repeat_error := err.Message

itertools_example_three_way_split_too_many_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x" }, { times: 3 }, { extra: 1 })
catch TypeError as err
    itertools_example_three_way_split_too_many_keyword_repeat_error := err.Message

itertools_example_three_way_split_duplicate_times_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x" }, { times: 3 }, { times: 4 })
catch TypeError as err
    itertools_example_three_way_split_duplicate_times_repeat_error := err.Message

itertools_example_positional_three_way_duplicate_times_repeat_error := ""
try
    stdlib.itertools.repeat("x", { times: 3 }, { times: 4 })
catch TypeError as err
    itertools_example_positional_three_way_duplicate_times_repeat_error := err.Message

itertools_example_positional_three_way_argument_count_repeat_error := ""
try
    stdlib.itertools.repeat("x", { times: 3 }, { another: 2 })
catch TypeError as err
    itertools_example_positional_three_way_argument_count_repeat_error := err.Message

itertools_example_duplicate_object_repeat_error := ""
try
    stdlib.itertools.repeat("x", { object: "y" })
catch TypeError as err
    itertools_example_duplicate_object_repeat_error := err.Message

itertools_example_too_many_keyword_repeat_error := ""
try
    stdlib.itertools.repeat({ object: "x", times: 3, extra: 1 })
catch TypeError as err
    itertools_example_too_many_keyword_repeat_error := err.Message

itertools_example_positional_invalid_keyword_repeat_error := ""
try
    stdlib.itertools.repeat("x", { extra: 1 })
catch TypeError as err
    itertools_example_positional_invalid_keyword_repeat_error := err.Message

itertools_example_negative_tee_error := ""
try
    stdlib.itertools.tee([1], -1)
catch ValueError as err
    itertools_example_negative_tee_error := err.Message

itertools_example_missing_tee_error := ""
try
    stdlib.itertools.tee()
catch TypeError as err
    itertools_example_missing_tee_error := err.Message

itertools_example_too_many_tee_error := ""
try
    stdlib.itertools.tee([1], 1, 2)
catch TypeError as err
    itertools_example_too_many_tee_error := err.Message

itertools_example_function_tee_count_error := ""
try
    stdlib.itertools.tee([1], ItertoolsExampleFunctionTimes)
catch TypeError as err
    itertools_example_function_tee_count_error := err.Message

itertools_example_tuple_tee_count_error := ""
try
    stdlib.itertools.tee([1], stdlib.tuple())
catch TypeError as err
    itertools_example_tuple_tee_count_error := err.Message

itertools_example_keyword_tee_error := ""
try
    stdlib.itertools.tee([1], { n: 3 })
catch TypeError as err
    itertools_example_keyword_tee_error := err.Message

itertools_example_keyword_tee_options_only_error := ""
try
    stdlib.itertools.tee({ n: 3 })
catch TypeError as err
    itertools_example_keyword_tee_options_only_error := err.Message

itertools_example_keyword_tee_iterable_error := ""
try
    stdlib.itertools.tee([1, 2], { iterable: [3, 4] })
catch TypeError as err
    itertools_example_keyword_tee_iterable_error := err.Message

itertools_example_keyword_tee_three_arg_error := ""
try
    stdlib.itertools.tee([1, 2], 2, { n: 3 })
catch TypeError as err
    itertools_example_keyword_tee_three_arg_error := err.Message
itertools_example_duplicate_keyword_tee_error := ""
try
    stdlib.itertools.tee({ extra: 1 }, { extra: 2 })
catch TypeError as err
    itertools_example_duplicate_keyword_tee_error := err.Message
itertools_example_duplicate_n_keyword_tee_error := ""
try
    stdlib.itertools.tee([1], { n: 2 }, { n: 3 })
catch TypeError as err
    itertools_example_duplicate_n_keyword_tee_error := err.Message
itertools_example_late_keyword_tee_error := ""
try
    stdlib.itertools.tee([1], 2, 3, { extra: 1 })
catch TypeError as err
    itertools_example_late_keyword_tee_error := err.Message

itertools_example_bool_tee_iterable_error := ""
try
    stdlib.itertools.tee(stdlib.True, 1)
catch TypeError as err
    itertools_example_bool_tee_iterable_error := err.Message

itertools_example_custom_tee_iterable_error := ""
try
    stdlib.itertools.tee(ItertoolsExampleCustomIterableSource(), 1)
catch TypeError as err
    itertools_example_custom_tee_iterable_error := err.Message

itertools_example_count_decimal_fraction_error := ""
try
    for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(1, 2)), 2)
        values.Push(String(value))
catch TypeError as err
    itertools_example_count_decimal_fraction_error := err.Message

itertools_example_count_fraction_decimal_error := ""
try
    for value in stdlib.itertools.islice(stdlib.itertools.count(stdlib.fractions.Fraction(1, 2), stdlib.decimal.Decimal("0.5")), 2)
        values.Push(String(value))
catch TypeError as err
    itertools_example_count_fraction_decimal_error := err.Message

itertools_example_chain_noniterable_error := ""
try
    for value in stdlib.itertools.chain(ItertoolsExampleCustomIterableSource())
        values.Push(value)
catch TypeError as err
    itertools_example_chain_noniterable_error := err.Message

itertools_example_chain_function_error := ""
try
    for value in stdlib.itertools.chain(ItertoolsExampleFunctionTimes)
        values.Push(value)
catch TypeError as err
    itertools_example_chain_function_error := err.Message

itertools_example_chain_fraction_error := ""
try
    for value in stdlib.itertools.chain(stdlib.fractions.Fraction(1, 1))
        values.Push(value)
catch TypeError as err
    itertools_example_chain_fraction_error := err.Message

itertools_example_chain_decimal_error := ""
try
    for value in stdlib.itertools.chain(stdlib.decimal.Decimal("1"))
        values.Push(value)
catch TypeError as err
    itertools_example_chain_decimal_error := err.Message

itertools_example_compress_noniterable_data_error := ""
try
    stdlib.itertools.compress(ItertoolsExampleCustomIterableSource(), [1])
catch TypeError as err
    itertools_example_compress_noniterable_data_error := err.Message

itertools_example_compress_noniterable_selectors_error := ""
try
    stdlib.itertools.compress([1, 2], ItertoolsExampleFunctionTimes)
catch TypeError as err
    itertools_example_compress_noniterable_selectors_error := err.Message

itertools_example_accumulate_noniterable_error := ""
try
    stdlib.itertools.accumulate(ItertoolsExampleCustomIterableSource())
catch TypeError as err
    itertools_example_accumulate_noniterable_error := err.Message

itertools_example_accumulate_noncallable_error := ""
try
    for value in stdlib.itertools.accumulate([1, 2], 42)
        values.Push(value)
catch TypeError as err
    itertools_example_accumulate_noncallable_error := err.Message

itertools_example_cycle_noniterable_error := ""
try
    for value in stdlib.itertools.cycle(ItertoolsExampleCustomIterableSource())
        values.Push(value)
catch TypeError as err
    itertools_example_cycle_noniterable_error := err.Message

itertools_example_cycle_function_error := ""
try
    for value in stdlib.itertools.cycle(ItertoolsExampleFunctionTimes)
        values.Push(value)
catch TypeError as err
    itertools_example_cycle_function_error := err.Message

itertools_example_cycle_fraction_error := ""
try
    for value in stdlib.itertools.cycle(stdlib.fractions.Fraction(1, 1))
        values.Push(value)
catch TypeError as err
    itertools_example_cycle_fraction_error := err.Message

itertools_example_cycle_decimal_error := ""
try
    for value in stdlib.itertools.cycle(stdlib.decimal.Decimal("1"))
        values.Push(value)
catch TypeError as err
    itertools_example_cycle_decimal_error := err.Message

itertools_example_islice_noniterable_error := ""
try
    stdlib.itertools.islice(ItertoolsExampleCustomIterableSource(), 2)
catch TypeError as err
    itertools_example_islice_noniterable_error := err.Message

itertools_example_islice_function_error := ""
try
    stdlib.itertools.islice(ItertoolsExampleFunctionTimes, 2)
catch TypeError as err
    itertools_example_islice_function_error := err.Message

itertools_example_islice_fraction_error := ""
try
    stdlib.itertools.islice(stdlib.fractions.Fraction(1, 1), 2)
catch TypeError as err
    itertools_example_islice_fraction_error := err.Message

itertools_example_islice_decimal_error := ""
try
    stdlib.itertools.islice(stdlib.decimal.Decimal("1"), 2)
catch TypeError as err
    itertools_example_islice_decimal_error := err.Message

itertools_example_keyword_islice_error := ""
try
    stdlib.itertools.islice([1, 2, 3], { stop: 2 })
catch TypeError as err
    itertools_example_keyword_islice_error := err.Message
itertools_example_duplicate_keyword_islice_error := ""
try
    stdlib.itertools.islice({ extra: 1 }, { extra: 2 })
catch TypeError as err
    itertools_example_duplicate_keyword_islice_error := err.Message
itertools_example_duplicate_stop_keyword_islice_error := ""
try
    stdlib.itertools.islice({ stop: 1 }, { stop: 2 })
catch TypeError as err
    itertools_example_duplicate_stop_keyword_islice_error := err.Message
itertools_example_late_keyword_islice_error := ""
try
    stdlib.itertools.islice([1, 2, 3], 1, 2, 3, { extra: 1 })
catch TypeError as err
    itertools_example_late_keyword_islice_error := err.Message
itertools_example_zero_arity_islice_error := ""
try
    stdlib.itertools.islice()
catch TypeError as err
    itertools_example_zero_arity_islice_error := err.Message
itertools_example_one_arity_islice_error := ""
try
    stdlib.itertools.islice([1, 2, 3])
catch TypeError as err
    itertools_example_one_arity_islice_error := err.Message
itertools_example_five_arity_islice_error := ""
try
    stdlib.itertools.islice([1, 2, 3], 1, 2, 3, 4)
catch TypeError as err
    itertools_example_five_arity_islice_error := err.Message

stdlib_itertools_example_to_array(iterable)
{
    result := []
    for value in iterable
        result.Push(value)
    return result
}

stdlib_itertools_example_group_to_array(row)
{
    values := stdlib_itertools_example_to_array(row)
    return [values[1], stdlib_itertools_example_to_array(values[2])]
}

stdlib_itertools_example_plain_iterable_object(propName, values)
{
    obj := { Values: values }
    obj.%propName% := "not a keyword"
    obj.DefineProp("__Enum", { Call: stdlib_itertools_example_plain_iterable_object_enum })
    return obj
}

stdlib_itertools_example_plain_callable_object(propName, callback)
{
    obj := { Callback: callback }
    obj.%propName% := "not a keyword"
    obj.DefineProp("Call", { Call: stdlib_itertools_example_plain_callable_object_call })
    return obj
}

stdlib_itertools_example_plain_iterable_object_enum(this, numberOfVars)
{
    index := 0
    values := this.Values
    return next_value

    next_value(&value)
    {
        index += 1
        if index > values.Length
            return false
        value := values[index]
        return true
    }
}

stdlib_itertools_example_plain_callable_object_call(this, args*)
{
    callback := this.Callback
    return callback(args*)
}

stdlib_itertools_example_add(a, b)
{
    return stdlib.operator.add(a, b)
}

stdlib_itertools_example_mul(a, b)
{
    return stdlib.operator.mul(a, b)
}

stdlib_itertools_example_next(iterable)
{
    iterator := iterable.__Enum(1)
    value := unset
    if !iterator(&value)
        throw StopIteration()
    return value
}

stdlib_itertools_example_less_than_three(value)
{
    return value < 3
}

stdlib_itertools_example_first_char(value)
{
    return SubStr(value, 1, 1)
}

stdlib_itertools_example_truthiness_result(value)
{
    values := [stdlib.True, stdlib.False, [], [1], Map(), Map("x", 1), stdlib.None]
    return values[value + 1]
}

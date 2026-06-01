#Requires AutoHotkey v2.0

#Include <stdlib\collections>
#Include <stdlib\operator>

class CollectionsExampleCustomSource
{
}

class CollectionsExampleCustomCount
{
}

class CollectionsExampleCounterSubclass extends AhkStdlibCollectionsCounter
{
}

class CollectionsExampleDictLike extends Map
{
}

CollectionsExampleFunctionCount()
{
}

collections_example_counter := stdlib.collections.Counter(["red", "blue", "red"])
collections_example_counter_class_same := stdlib.collections.Counter is AhkStdlibCollectionsCounter
collections_example_counter.update("blue")
collections_example_kwargs_counter := stdlib.collections.Counter("ab", { kwargs: Map("a", 2, "c", 3) })
collections_example_kwargs_update := stdlib.collections.Counter("a")
collections_example_kwargs_update.update({ kwargs: Map("a", 2, "b", 3) })
collections_example_kwargs_subtract := stdlib.collections.Counter("a")
collections_example_kwargs_subtract.subtract({ kwargs: Map("a", 2, "b", 3) })
collections_example_update_noniterable_error := ""
try {
    stdlib.collections.Counter().update(42)
} catch TypeError as err {
    collections_example_update_noniterable_error := err.Message
}
collections_example_update_too_many_error := ""
try {
    stdlib.collections.Counter().update(Map(), Map())
} catch TypeError as err {
    collections_example_update_too_many_error := err.Message
}
collections_example_subtract_noniterable_error := ""
try {
    stdlib.collections.Counter().subtract(42)
} catch TypeError as err {
    collections_example_subtract_noniterable_error := err.Message
}
collections_example_subtract_too_many_error := ""
try {
    stdlib.collections.Counter().subtract(Map(), Map())
} catch TypeError as err {
    collections_example_subtract_too_many_error := err.Message
}
collections_example_setdefault_existing := stdlib.collections.Counter("ab")
collections_example_setdefault_existing_value := collections_example_setdefault_existing.setdefault("a", 5)
collections_example_setdefault_missing_value := collections_example_setdefault_existing.setdefault("c", 5)
collections_example_setdefault_none := stdlib.collections.Counter()
collections_example_setdefault_none_value := collections_example_setdefault_none.setdefault("x")
collections_example_get_counter := stdlib.collections.Counter("ab")
collections_example_get_existing_value := collections_example_get_counter.get("a")
collections_example_get_missing_value := collections_example_get_counter.get("z")
collections_example_get_default_value := collections_example_get_counter.get("z", 7)
collections_example_get_too_few_error := ""
try {
    stdlib.collections.Counter().get()
} catch TypeError as err {
    collections_example_get_too_few_error := err.Message
}
collections_example_get_too_many_error := ""
try {
    stdlib.collections.Counter().get("a", 1, 2)
} catch TypeError as err {
    collections_example_get_too_many_error := err.Message
}
collections_example_setdefault_too_few_error := ""
try {
    stdlib.collections.Counter().setdefault()
} catch TypeError as err {
    collections_example_setdefault_too_few_error := err.Message
}
collections_example_setdefault_too_many_error := ""
try {
    stdlib.collections.Counter().setdefault("a", 1, 2)
} catch TypeError as err {
    collections_example_setdefault_too_many_error := err.Message
}
collections_example_pop_existing := stdlib.collections.Counter("ab")
collections_example_pop_existing_value := collections_example_pop_existing.pop("a")
collections_example_pop_default := stdlib.collections.Counter("ab")
collections_example_pop_default_value := collections_example_pop_default.pop("z", stdlib.None)
collections_example_pop_missing_error := ""
try {
    stdlib.collections.Counter().pop("z")
} catch Error as err {
    if err is stdlib.KeyError
        collections_example_pop_missing_error := err.Message
    else
        throw err
}
collections_example_pop_too_few_error := ""
try {
    stdlib.collections.Counter().pop()
} catch TypeError as err {
    collections_example_pop_too_few_error := err.Message
}
collections_example_pop_too_many_error := ""
try {
    stdlib.collections.Counter().pop("a", 1, 2)
} catch TypeError as err {
    collections_example_pop_too_many_error := err.Message
}
collections_example_popitem_counter := stdlib.collections.Counter("ab")
collections_example_popitem_first := collections_example_popitem_counter.popitem()
collections_example_popitem_second := collections_example_popitem_counter.popitem()
collections_example_popitem_readonly_error := ""
try {
    collections_example_popitem_first[1] := "x"
} catch TypeError as err {
    collections_example_popitem_readonly_error := err.Message
}
collections_example_popitem_empty_error := ""
try {
    collections_example_popitem_counter.popitem()
} catch Error as err {
    if err is stdlib.KeyError
        collections_example_popitem_empty_error := err.Message
    else
        throw err
}
collections_example_popitem_arity_error := ""
try {
    stdlib.collections.Counter().popitem(1)
} catch TypeError as err {
    collections_example_popitem_arity_error := err.Message
}
collections_example_copy_subclass := CollectionsExampleCounterSubclass("ab")
collections_example_copy_subclass_copy := collections_example_copy_subclass.copy()
collections_example_copy_subclass_is_same_type := collections_example_copy_subclass_copy is CollectionsExampleCounterSubclass
collections_example_copy_subclass_equal := stdlib.operator.eq(collections_example_copy_subclass_copy, collections_example_copy_subclass)
collections_example_copy_subclass_is_distinct := ObjPtr(collections_example_copy_subclass_copy) != ObjPtr(collections_example_copy_subclass)
collections_example_copy_subclass_copy["c"] := 5
collections_example_copy_subclass_original_c := collections_example_copy_subclass["c"]
collections_example_bool_count_eq_counter := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_ne_counter := stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_le_counter := stdlib.operator.le(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_ge_counter := stdlib.operator.ge(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_lt_counter := stdlib.operator.lt(stdlib.collections.Counter(Map("a", stdlib.False)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_gt_counter := stdlib.operator.gt(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 0)))
collections_example_bool_count_eq_map := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.True)), Map("a", 1))
collections_example_bool_count_ne_map := stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.True)), Map("a", 1))
collections_example_bool_count_pos := stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", -1)))
collections_example_bool_count_neg := stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", -1)))
collections_example_bool_count_add := stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.True)))
collections_example_bool_count_add_right_only := stdlib.operator.add(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)))
collections_example_bool_count_or := stdlib.operator.or_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.False)))
collections_example_bool_count_and_true_int := stdlib.operator.and_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", 1)))
collections_example_bool_count_and_int_true := stdlib.operator.and_(stdlib.collections.Counter(Map("a", 1)), stdlib.collections.Counter(Map("a", stdlib.True)))
collections_example_bool_count_sub := stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.False)))
collections_example_bool_count_sub_right_only := stdlib.operator.sub(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", stdlib.False, "b", stdlib.True)))
collections_example_bool_count_total := stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).total()
collections_example_bool_count_most_common := stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False)).most_common()
collections_example_fraction_decimal_eq_counter := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_fraction_decimal_ne_counter := stdlib.operator.ne(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_fraction_decimal_lt_counter := stdlib.operator.lt(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.75"))))
collections_example_fraction_decimal_le_counter := stdlib.operator.le(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_fraction_decimal_gt_counter := stdlib.operator.gt(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_fraction_decimal_ge_counter := stdlib.operator.ge(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_bool_count_update_from_true := stdlib.collections.Counter(Map("a", stdlib.True))
collections_example_bool_count_update_from_true.update(Map("a", 1))
collections_example_bool_count_update_from_int := stdlib.collections.Counter(Map("a", 1))
collections_example_bool_count_update_from_int.update(Map("a", stdlib.True))
collections_example_bool_count_subtract_from_true := stdlib.collections.Counter(Map("a", stdlib.True))
collections_example_bool_count_subtract_from_true.subtract(Map("a", 1))
collections_example_bool_count_subtract_from_int := stdlib.collections.Counter(Map("a", 1))
collections_example_bool_count_subtract_from_int.subtract(Map("a", stdlib.True))
collections_example_bool_fraction_pos := stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.fractions.Fraction(-1, 2))))
collections_example_bool_fraction_neg := stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.fractions.Fraction(-1, 2))))
collections_example_bool_decimal_pos := stdlib.operator.pos(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("-0.5"))))
collections_example_bool_decimal_neg := stdlib.operator.neg(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("-0.5"))))
collections_example_bool_fraction_add := stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))))
collections_example_bool_fraction_sub := stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))))
collections_example_bool_fraction_and := stdlib.operator.and_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))))
collections_example_bool_fraction_or := stdlib.operator.or_(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2))))
collections_example_bool_decimal_add := stdlib.operator.add(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_bool_decimal_sub := stdlib.operator.sub(stdlib.collections.Counter(Map("a", stdlib.True)), stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("0.5"))))
collections_example_bool_fraction_update := stdlib.collections.Counter(Map("a", stdlib.True))
collections_example_bool_fraction_update.update(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_fraction_bool_update := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_fraction_bool_update.update(Map("a", stdlib.True))
collections_example_bool_decimal_update := stdlib.collections.Counter(Map("a", stdlib.True))
collections_example_bool_decimal_update.update(Map("a", stdlib.decimal.Decimal("0.5")))
collections_example_decimal_bool_subtract := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
collections_example_decimal_bool_subtract.subtract(Map("a", stdlib.True))
collections_example_clear_counter := stdlib.collections.Counter("abca")
collections_example_clear_return := collections_example_clear_counter.Clear()
collections_example_clear_missing_get := collections_example_clear_counter.get("a")
collections_example_clear_missing_item := collections_example_clear_counter["a"]
collections_example_clear_counter.update("ba")
collections_example_clear_pairs := []
for key, value in collections_example_clear_counter
    collections_example_clear_pairs.Push([key, value])
collections_example_delitem_counter := stdlib.collections.Counter("ab")
stdlib.operator.delitem(collections_example_delitem_counter, "a")
collections_example_delitem_pairs := []
for key, value in collections_example_delitem_counter
    collections_example_delitem_pairs.Push([key, value])
collections_example_delitem_missing_error := ""
try {
    stdlib.operator.delitem(stdlib.collections.Counter("ab"), "z")
} catch Error as err {
    if err is stdlib.KeyError
        collections_example_delitem_missing_error := err.Message
    else
        throw err
}
collections_example_common := collections_example_counter.most_common(2)
collections_example_total := collections_example_counter.total()
collections_example_fromkeys_error_type := ""
collections_example_fromkeys_error := ""
try {
    stdlib.collections.Counter.fromkeys("ab")
} catch Error as err {
    collections_example_fromkeys_error_type := Type(err)
    collections_example_fromkeys_error := err.Message
}
collections_example_counter_repr := stdlib.collections.Counter("abb").__Repr()
collections_example_counter_unorderable_repr := stdlib.collections.Counter(Map("a", Map("x", 1), "b", Map("x", 2))).__Repr()
collections_example_elements := []
collections_example_elements_repr := collections_example_counter.elements().__Repr()
for value in collections_example_counter.elements()
    collections_example_elements.Push(value)
collections_example_single_use_elements := stdlib.collections.Counter("abb").elements()
collections_example_single_use_iterator := collections_example_single_use_elements.__Enum(1)
collections_example_single_use_first := unset
collections_example_single_use_rest := []
collections_example_single_use_again := []
collections_example_single_use_iterator(&collections_example_single_use_first)
for value in collections_example_single_use_elements
    collections_example_single_use_rest.Push(value)
for value in collections_example_single_use_elements
    collections_example_single_use_again.Push(value)
collections_example_bool_elements := []
for value in stdlib.collections.Counter(Map("a", stdlib.True, "b", stdlib.False, "c", 2)).elements()
    collections_example_bool_elements.Push(value)
collections_example_none_count_error := ""
try {
    for value in stdlib.collections.Counter(Map("a", stdlib.None)).elements()
        collections_example_elements.Push(value)
} catch TypeError as err {
    collections_example_none_count_error := err.Message
}

collections_example_mutation_error := ""
collections_example_mutating := stdlib.collections.Counter(Map("a", 2))
collections_example_mutating_elements := collections_example_mutating.elements()
collections_example_mutating_iterator := collections_example_mutating_elements.__Enum(1)
collections_example_mutating_first := unset
collections_example_mutating_iterator(&collections_example_mutating_first)
collections_example_mutating["b"] := 1
try {
    for value in collections_example_mutating_elements
        collections_example_elements.Push(value)
} catch Error as err {
    collections_example_mutation_error := err.Message
}

collections_example_key_mutation_error := ""
collections_example_rekey := stdlib.collections.Counter(Map("a", 2))
collections_example_rekey_elements := collections_example_rekey.elements()
collections_example_rekey_iterator := collections_example_rekey_elements.__Enum(1)
collections_example_rekey_first := unset
collections_example_rekey_iterator(&collections_example_rekey_first)
collections_example_rekey.Delete("a")
collections_example_rekey["b"] := 2
try {
    for value in collections_example_rekey_elements
        collections_example_elements.Push(value)
} catch Error as err {
    collections_example_key_mutation_error := err.Message
}

collections_example_readd_error := ""
collections_example_readd := stdlib.collections.Counter(Map("a", 2))
collections_example_readd_elements := collections_example_readd.elements()
collections_example_readd_iterator := collections_example_readd_elements.__Enum(1)
collections_example_readd_first := unset
collections_example_readd_iterator(&collections_example_readd_first)
collections_example_readd.Delete("a")
collections_example_readd["a"] := 2
try {
    for value in collections_example_readd_elements
        collections_example_elements.Push(value)
} catch Error as err {
    collections_example_readd_error := err.Message
}

collections_example_active_repeat := stdlib.collections.Counter(Map("a", 2, "b", 1))
collections_example_active_repeat_iterator := collections_example_active_repeat.elements().__Enum(1)
collections_example_active_repeat_first := unset
collections_example_active_repeat_rest := []
collections_example_active_repeat_value := unset
collections_example_active_repeat_iterator(&collections_example_active_repeat_first)
collections_example_active_repeat["a"] := 4
collections_example_active_repeat["b"] := 3
while collections_example_active_repeat_iterator(&collections_example_active_repeat_value)
    collections_example_active_repeat_rest.Push(collections_example_active_repeat_value)

collections_example_other := stdlib.collections.Counter(["red", "green", "green"])
collections_example_sum := stdlib.operator.add(collections_example_counter, collections_example_other)
collections_example_positive := stdlib.operator.pos(collections_example_sum)
collections_example_subset := stdlib.operator.le(collections_example_counter, collections_example_sum)
collections_example_fraction_float_update := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_fraction_float_update.update(Map("a", 0.5))
collections_example_float_fraction_subtract := stdlib.collections.Counter(Map("a", 2.0))
collections_example_float_fraction_subtract.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_right_only_fraction_subtract := stdlib.collections.Counter()
collections_example_right_only_fraction_subtract.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_eq_non_counter := stdlib.operator.eq(collections_example_counter, 42)
collections_example_ne_non_counter := stdlib.operator.ne(collections_example_counter, 42)
collections_example_fraction_float_lt := stdlib.operator.lt(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", 0.75)))
collections_example_decimal_float_ge := stdlib.operator.ge(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"))), stdlib.collections.Counter(Map("a", 1.5)))
collections_example_list_count_eq := stdlib.operator.eq(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", [1])))
collections_example_list_count_ne := stdlib.operator.ne(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", [2])))
collections_example_dict_count_eq_mapping := stdlib.operator.eq(stdlib.collections.Counter(Map("a", Map("x", 1))), Map("a", Map("x", 1)))
collections_example_dict_count_ne_mapping := stdlib.operator.ne(stdlib.collections.Counter(Map("a", Map("x", 1))), Map("a", Map("x", 2)))
collections_example_fraction_count_eq := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), stdlib.collections.Counter(Map("a", 0.5)))
collections_example_decimal_count_eq := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"))), stdlib.collections.Counter(Map("a", 1.5)))
collections_example_fraction_count_eq_mapping := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))), Map("a", 0.5))
collections_example_decimal_count_eq_mapping := stdlib.operator.eq(stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"))), Map("a", 1.5))
collections_example_mixed_eq := stdlib.operator.eq(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", 1)))
collections_example_mixed_lt_error := ""
try {
    stdlib.operator.lt(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_mixed_lt_error := err.Message
}
collections_example_mixed_pos_error := ""
try {
    stdlib.operator.pos(stdlib.collections.Counter(Map("a", "x")))
} catch TypeError as err {
    collections_example_mixed_pos_error := err.Message
}
collections_example_mixed_add_error := ""
try {
    stdlib.operator.add(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_mixed_add_error := err.Message
}

collections_example_mixed_add_filter_error := ""
try {
    stdlib.operator.add(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", "y")))
} catch TypeError as err {
    collections_example_mixed_add_filter_error := err.Message
}

collections_example_list_add_filter_error := ""
try {
    stdlib.operator.add(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", [2])))
} catch TypeError as err {
    collections_example_list_add_filter_error := err.Message
}

collections_example_right_only_list_add_error := ""
try {
    stdlib.operator.add(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", [1])))
} catch TypeError as err {
    collections_example_right_only_list_add_error := err.Message
}

collections_example_list_add_int_error := ""
try {
    stdlib.operator.add(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_list_add_int_error := err.Message
}

collections_example_right_only_list_or_error := ""
try {
    stdlib.operator.or_(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", [1])))
} catch TypeError as err {
    collections_example_right_only_list_or_error := err.Message
}

collections_example_same_list_and_error := ""
try {
    stdlib.operator.and_(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", [1])))
} catch TypeError as err {
    collections_example_same_list_and_error := err.Message
}

collections_example_same_list_or_error := ""
try {
    stdlib.operator.or_(stdlib.collections.Counter(Map("a", [1])), stdlib.collections.Counter(Map("a", [1])))
} catch TypeError as err {
    collections_example_same_list_or_error := err.Message
}

collections_example_same_string_and_error := ""
try {
    stdlib.operator.and_(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", "x")))
} catch TypeError as err {
    collections_example_same_string_and_error := err.Message
}

collections_example_same_string_or_error := ""
try {
    stdlib.operator.or_(stdlib.collections.Counter(Map("a", "x")), stdlib.collections.Counter(Map("a", "x")))
} catch TypeError as err {
    collections_example_same_string_or_error := err.Message
}

collections_example_right_only_list_and := stdlib.operator.and_(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", [1])))

collections_example_right_only_negative_sub := stdlib.operator.sub(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", -2)))
collections_example_right_only_list_sub_error := ""
try {
    stdlib.operator.sub(stdlib.collections.Counter(), stdlib.collections.Counter(Map("a", [1])))
} catch TypeError as err {
    collections_example_right_only_list_sub_error := err.Message
}

collections_example_left_plain_dict_add_counter_error := ""
try {
    stdlib.operator.add(Map("a", 1), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_plain_dict_add_counter_error := err.Message
}
collections_example_left_plain_dict_sub_counter_error := ""
try {
    stdlib.operator.sub(Map("a", 1), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_plain_dict_sub_counter_error := err.Message
}
collections_example_left_plain_dict_and_counter_error := ""
try {
    stdlib.operator.and_(Map("a", 1), stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_plain_dict_and_counter_error := err.Message
}
collections_example_left_dict_subclass := CollectionsExampleDictLike()
collections_example_left_dict_subclass["a"] := 1
collections_example_left_dict_subclass_add_counter_error := ""
try {
    stdlib.operator.add(collections_example_left_dict_subclass, stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_dict_subclass_add_counter_error := err.Message
}
collections_example_left_dict_subclass_sub_counter_error := ""
try {
    stdlib.operator.sub(collections_example_left_dict_subclass, stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_dict_subclass_sub_counter_error := err.Message
}
collections_example_left_dict_subclass_and_counter_error := ""
try {
    stdlib.operator.and_(collections_example_left_dict_subclass, stdlib.collections.Counter(Map("a", 1)))
} catch TypeError as err {
    collections_example_left_dict_subclass_and_counter_error := err.Message
}

collections_example_custom_source_error := ""
try {
    stdlib.collections.Counter(CollectionsExampleCustomSource())
} catch TypeError as err {
    collections_example_custom_source_error := err.Message
}

collections_example_custom_count_error := ""
try {
    for value in stdlib.collections.Counter(Map("a", CollectionsExampleCustomCount())).elements()
        collections_example_elements.Push(value)
} catch TypeError as err {
    collections_example_custom_count_error := err.Message
}

collections_example_function_count_error := ""
try {
    for value in stdlib.collections.Counter(Map("a", CollectionsExampleFunctionCount)).elements()
        collections_example_elements.Push(value)
} catch TypeError as err {
    collections_example_function_count_error := err.Message
}

collections_example_update_mapping_string := stdlib.collections.Counter(Map("a", "x"))
collections_example_update_mapping_list := stdlib.collections.Counter(Map("a", [1]))
collections_example_update_mapping_fraction := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_update_mapping_decimal := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
collections_example_update_mapping_string.update(Map("a", "y"))
collections_example_update_mapping_list.update(Map("a", [2]))
collections_example_update_mapping_fraction.update(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_update_mapping_decimal.update(Map("a", stdlib.decimal.Decimal("0.5")))

collections_example_subtract_mapping_string_error := ""
try {
    stdlib.collections.Counter(Map("a", "x")).subtract(Map("a", "y"))
} catch TypeError as err {
    collections_example_subtract_mapping_string_error := err.Message
}

collections_example_subtract_mapping_fraction := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2)))
collections_example_subtract_mapping_decimal := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5")))
collections_example_subtract_mapping_fraction.subtract(Map("a", stdlib.fractions.Fraction(1, 2)))
collections_example_subtract_mapping_decimal.subtract(Map("a", stdlib.decimal.Decimal("0.5")))

collections_example_subtract_mapping_right_only_string_error := ""
try {
    stdlib.collections.Counter().subtract(Map("a", "y"))
} catch TypeError as err {
    collections_example_subtract_mapping_right_only_string_error := err.Message
}

collections_example_total_string_error := ""
try {
    stdlib.collections.Counter(Map("a", "x")).total()
} catch TypeError as err {
    collections_example_total_string_error := err.Message
}
collections_example_total_fraction := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2))).total()
collections_example_total_decimal := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"))).total()
collections_example_total_fraction_int_mix := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", 1)).total()
collections_example_total_decimal_int_mix := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", 1)).total()
collections_example_total_fraction_float_mix := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", 0.5)).total()
collections_example_total_fraction_pair := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", stdlib.fractions.Fraction(3, 2))).total()
collections_example_total_decimal_pair := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("2.5"))).total()
collections_example_total_fraction_decimal_mix_error := ""
try {
    stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.decimal.Decimal("2.5"))).total()
} catch TypeError as err {
    collections_example_total_fraction_decimal_mix_error := err.Message
}
collections_example_total_decimal_float_mix_error := ""
try {
    stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", 0.5)).total()
} catch TypeError as err {
    collections_example_total_decimal_float_mix_error := err.Message
}

collections_example_most_common_string := stdlib.collections.Counter(Map("a", "x", "b", "y")).most_common()
collections_example_most_common_list := stdlib.collections.Counter(Map("a", [1], "b", [2])).most_common()
collections_example_most_common_fraction := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(1, 2), "b", stdlib.fractions.Fraction(3, 2))).most_common()
collections_example_most_common_decimal := stdlib.collections.Counter(Map("a", stdlib.decimal.Decimal("1.5"), "b", stdlib.decimal.Decimal("2.5"))).most_common()
collections_example_most_common_fraction_decimal_mix := stdlib.collections.Counter(Map("a", stdlib.fractions.Fraction(3, 2), "b", stdlib.decimal.Decimal("2.5"))).most_common()
collections_example_most_common_int_decimal_mix := stdlib.collections.Counter(Map("a", 1, "b", stdlib.decimal.Decimal("2.5"))).most_common()
collections_example_most_common_float_fraction_mix := stdlib.collections.Counter(Map("a", 2.5, "b", stdlib.fractions.Fraction(3, 2))).most_common()
collections_example_most_common_function_error := ""
try {
    stdlib.collections.Counter(Map("a", CollectionsExampleFunctionCount, "b", CollectionsExampleFunctionCount)).most_common()
} catch TypeError as err {
    collections_example_most_common_function_error := err.Message
}
collections_example_most_common_none_limit := stdlib.collections.Counter("abb").most_common(stdlib.None)
collections_example_most_common_root_true_limit := stdlib.collections.Counter("abb").most_common(stdlib.True)
collections_example_most_common_root_false_limit := stdlib.collections.Counter("abb").most_common(stdlib.False)
collections_example_most_common_fraction_one_limit := stdlib.collections.Counter("abb").most_common(stdlib.fractions.Fraction(1, 1))
collections_example_most_common_decimal_one_limit := stdlib.collections.Counter("abb").most_common(stdlib.decimal.Decimal("1"))
collections_example_most_common_float_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(1.5)
} catch TypeError as err {
    collections_example_most_common_float_limit_error := err.Message
}
collections_example_most_common_float_two_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(2.0)
} catch TypeError as err {
    collections_example_most_common_float_two_limit_error := err.Message
}
collections_example_most_common_object_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common({})
} catch TypeError as err {
    collections_example_most_common_object_limit_error := err.Message
}
collections_example_most_common_fraction_zero_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(stdlib.fractions.Fraction(0, 1))
} catch TypeError as err {
    collections_example_most_common_fraction_zero_limit_error := err.Message
}
collections_example_most_common_fraction_two_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(stdlib.fractions.Fraction(2, 1))
} catch TypeError as err {
    collections_example_most_common_fraction_two_limit_error := err.Message
}
collections_example_most_common_decimal_zero_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(stdlib.decimal.Decimal("0"))
} catch TypeError as err {
    collections_example_most_common_decimal_zero_limit_error := err.Message
}
collections_example_most_common_decimal_two_limit_error := ""
try {
    stdlib.collections.Counter("abb").most_common(stdlib.decimal.Decimal("2"))
} catch TypeError as err {
    collections_example_most_common_decimal_two_limit_error := err.Message
}

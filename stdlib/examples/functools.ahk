#Requires AutoHotkey v2.0

#Include <stdlib\base>
#Include <stdlib\functools>

class FunctoolsExampleBoundValue
{
}

functools_example_sum := stdlib.functools.reduce(functools_example_add, [1, 2, 3, 4])
functools_example_reduce_non_callable_error := ""
try {
    stdlib.functools.reduce(42, [1, 2])
} catch TypeError as err {
    functools_example_reduce_non_callable_error := err.Message
}
functools_example_reduce_tuple_non_callable_error := ""
try {
    stdlib.functools.reduce(stdlib.tuple(), [1, 2])
} catch TypeError as err {
    functools_example_reduce_tuple_non_callable_error := err.Message
}
functools_example_reduce_bool_non_callable_error := ""
try {
    stdlib.functools.reduce(stdlib.True, [1, 2])
} catch TypeError as err {
    functools_example_reduce_bool_non_callable_error := err.Message
}
functools_example_reduce_non_iterable_error := ""
try {
    stdlib.functools.reduce(functools_example_add, 42)
} catch TypeError as err {
    functools_example_reduce_non_iterable_error := err.Message
}
functools_example_add_two := stdlib.functools.partial(functools_example_add, 2)
functools_example_five := functools_example_add_two.Call(3)
functools_example_partial_module := functools_example_add_two.__module
functools_example_partial_doc := functools_example_add_two.__doc
functools_example_partial_dict := functools_example_add_two.__dict
functools_example_partial_dict_same_identity := functools_example_add_two.__dict == functools_example_add_two.__dict
functools_example_add_two.__module := "custom_module"
functools_example_add_two.__doc := "custom doc"
functools_example_partial_assigned_dict_module := functools_example_add_two.__dict["__module"]
functools_example_partial_assigned_dict_doc := functools_example_add_two.__dict["__doc"]
functools_example_replacement_dict := Map("x", 1)
functools_example_add_two.__dict := functools_example_replacement_dict
functools_example_partial_assigned_module := functools_example_add_two.__module
functools_example_partial_assigned_doc := functools_example_add_two.__doc
functools_example_partial_assigned_dict_same_identity := functools_example_add_two.__dict == functools_example_replacement_dict
functools_example_partial_bad_dict_int_error := ""
try {
    functools_example_add_two.__dict := 5
} catch TypeError as err {
    functools_example_partial_bad_dict_int_error := err.Message
}
functools_example_partial_bad_dict_list_error := ""
try {
    functools_example_add_two.__dict := []
} catch TypeError as err {
    functools_example_partial_bad_dict_list_error := err.Message
}
functools_example_partial_bad_dict_none_error := ""
try {
    functools_example_add_two.__dict := stdlib.None
} catch TypeError as err {
    functools_example_partial_bad_dict_none_error := err.Message
}
functools_example_add_two.__module := "delete_module"
functools_example_add_two.__doc := "delete doc"
functools_example_partial_delete_module_error := ""
functools_example_partial_deleted_module := stdlib.base.delattr(functools_example_add_two, "__module")
try {
    stdlib.base.delattr(functools_example_add_two, "__module")
} catch Error as err {
    if err is stdlib.AttributeError
        functools_example_partial_delete_module_error := err.Message
}
functools_example_partial_delete_doc_error := ""
functools_example_partial_deleted_doc := stdlib.base.delattr(functools_example_add_two, "__doc")
try {
    stdlib.base.delattr(functools_example_add_two, "__doc")
} catch Error as err {
    if err is stdlib.AttributeError
        functools_example_partial_delete_doc_error := err.Message
}
functools_example_partial_module_after_delete := functools_example_add_two.__module
functools_example_partial_doc_after_delete := functools_example_add_two.__doc
functools_example_partial_delete_dict_error := ""
try {
    stdlib.base.delattr(functools_example_add_two, "__dict")
} catch TypeError as err {
    functools_example_partial_delete_dict_error := err.Message
}
functools_example_add_two.custom := 42
functools_example_partial_custom := functools_example_add_two.custom
functools_example_partial_dict_has_custom := functools_example_add_two.__dict.Has("custom")
functools_example_partial_dict_custom := functools_example_add_two.__dict["custom"]
functools_example_partial_removed_custom := stdlib.base.delattr(functools_example_add_two, "custom")
functools_example_partial_dict_has_custom_after_delete := functools_example_add_two.__dict.Has("custom")
functools_example_partial_custom_after_delete_error := ""
try {
    functools_example_add_two.custom
} catch Error as err {
    if err is stdlib.AttributeError
        functools_example_partial_custom_after_delete_error := err.Message
}
functools_example_partial_delete_custom_again_error := ""
try {
    stdlib.base.delattr(functools_example_add_two, "custom")
} catch Error as err {
    if err is stdlib.AttributeError
        functools_example_partial_delete_custom_again_error := err.Message
}
functools_example_partial_missing_callable_error := ""
try {
    stdlib.functools.partial()
} catch TypeError as err {
    functools_example_partial_missing_callable_error := err.Message
}
functools_example_partial_non_callable_error := ""
try {
    stdlib.functools.partial(42)
} catch TypeError as err {
    functools_example_partial_non_callable_error := err.Message
}
functools_example_partial_object_non_callable_error := ""
try {
    stdlib.functools.partial({})
} catch TypeError as err {
    functools_example_partial_object_non_callable_error := err.Message
}
functools_example_bound_args := functools_example_add_two.args
functools_example_bound_args_same_identity := functools_example_add_two.args == functools_example_add_two.args
functools_example_wrapped_add_two := stdlib.functools.partial(functools_example_add_two)
functools_example_wrapped_args_same_identity := functools_example_wrapped_add_two.args == functools_example_add_two.args
functools_example_add_two_three := stdlib.functools.partial(functools_example_add_two, 3)
functools_example_nested_func := functools_example_add_two_three.func
functools_example_nested_args := functools_example_add_two_three.args
functools_example_tuple_partial_repr := stdlib.functools.partial(functools_example_identity, functools_example_add_two.args).__Repr()
functools_example_function_partial_repr := stdlib.functools.partial(functools_example_identity, functools_example_identity).__Repr()
functools_example_partial_repr := functools_example_add_two.__Repr()
functools_example_nested_partial_repr := functools_example_add_two_three.__Repr()
functools_example_escaped_partial_repr := stdlib.functools.partial(functools_example_identity, "a\b").__Repr()
functools_example_quoted_partial_repr := stdlib.functools.partial(functools_example_identity, "a'b").__Repr()
functools_example_literal_partial_repr := stdlib.functools.partial(functools_example_identity, [1, "x"], Map("alpha", 1, "beta", stdlib.None), stdlib.None).__Repr()
functools_example_bool_partial_repr := stdlib.functools.partial(functools_example_identity, stdlib.True, stdlib.False).__Repr()
functools_example_object_partial_repr := stdlib.functools.partial(functools_example_identity, FunctoolsExampleBoundValue()).__Repr()
functools_example_stateful_partial := stdlib.functools.partial(functools_example_add, 2)
functools_example_partial_reduce := functools_example_stateful_partial.__reduce()
functools_example_partial_reduce_state := functools_example_partial_reduce[3]
functools_example_metadata_stateful_partial := stdlib.functools.partial(functools_example_add_three, 1)
functools_example_metadata_stateful_partial.__module := 5
functools_example_metadata_stateful_partial.__doc := 6
functools_example_metadata_partial_reduce := functools_example_metadata_stateful_partial.__reduce()
functools_example_metadata_partial_reduce_state := functools_example_metadata_partial_reduce[3]
functools_example_metadata_stateful_partial.__setstate(stdlib.tuple([functools_example_add_three, stdlib.tuple([1]), Map("c", 5), Map("__module", 7, "__doc", 8, "x", 9)]))
functools_example_metadata_partial_after_setstate_module := functools_example_metadata_stateful_partial.__module
functools_example_metadata_partial_after_setstate_doc := functools_example_metadata_stateful_partial.__doc
functools_example_metadata_partial_after_setstate_x := functools_example_metadata_stateful_partial.x
functools_example_stateful_partial.__setstate(stdlib.tuple([functools_example_add, stdlib.tuple([2]), Map("b", 5), stdlib.None]))
functools_example_partial_after_setstate_args := functools_example_stateful_partial.args
functools_example_partial_after_setstate_keyword_b := functools_example_stateful_partial.keywords["b"]
functools_example_partial_after_setstate_call := functools_example_stateful_partial.Call()
functools_example_stateful_partial.__setstate(stdlib.tuple([functools_example_add, stdlib.tuple([2]), Map("b", 5), []]))
functools_example_partial_after_list_dict_state_type := Type(functools_example_stateful_partial.__dict)
functools_example_partial_after_list_dict_state_call := functools_example_stateful_partial.Call()
functools_example_stateful_partial.__setstate(stdlib.tuple([functools_example_add, stdlib.tuple([2]), Map("b", 5), stdlib.tuple()]))
functools_example_partial_after_tuple_dict_state_type := Type(functools_example_stateful_partial.__dict)
functools_example_partial_after_tuple_dict_state_call := functools_example_stateful_partial.Call()
functools_example_stateful_partial.__setstate(stdlib.tuple([functools_example_add, stdlib.tuple([2]), stdlib.None, stdlib.None]))
functools_example_partial_after_none_keywords_type := Type(functools_example_stateful_partial.keywords)
functools_example_partial_after_none_keywords_count := functools_example_stateful_partial.keywords.Count
functools_example_partial_after_none_dict_type := Type(functools_example_stateful_partial.__dict)
functools_example_partial_after_none_dict_count := functools_example_stateful_partial.__dict.Count
functools_example_partial_after_none_keywords_call := functools_example_stateful_partial.Call(5)
functools_example_stateful_partial.__setstate(stdlib.tuple([functools_example_add, stdlib.tuple([2]), stdlib.None, 5]))
functools_example_partial_after_scalar_dict_state_type := Type(functools_example_stateful_partial.__dict)
functools_example_partial_after_scalar_dict_state_value := functools_example_stateful_partial.__dict
functools_example_partial_after_scalar_dict_state_call := functools_example_stateful_partial.Call(5)
functools_example_partial_module_after_scalar_dict_state_error := ""
try {
    functools_example_partial_stateful_module_after_scalar := functools_example_stateful_partial.__module
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_module_after_scalar_dict_state_error := err.Message
}
functools_example_partial_doc_after_scalar_dict_state_error := ""
try {
    functools_example_partial_stateful_doc_after_scalar := functools_example_stateful_partial.__doc
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_doc_after_scalar_dict_state_error := err.Message
}
functools_example_partial_set_custom_after_scalar_state_error := ""
try {
    functools_example_stateful_partial.custom := 42
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_set_custom_after_scalar_state_error := err.Message
}
functools_example_partial_get_custom_after_scalar_state_error := ""
try {
    functools_example_partial_get_custom_after_scalar_state_error := functools_example_stateful_partial.custom
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_get_custom_after_scalar_state_error := err.Message
}
functools_example_partial_delete_custom_after_scalar_state_error := ""
try {
    functools_example_stateful_partial.DeleteProp("custom")
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_delete_custom_after_scalar_state_error := err.Message
}
functools_example_partial_reduce_after_scalar_state_error := ""
try {
    functools_example_stateful_partial.__reduce()
} catch Error as err {
    if err is stdlib.SystemError
        functools_example_partial_reduce_after_scalar_state_error := err.Message
}
functools_example_partial_setstate_arity_error := ""
try {
    functools_example_stateful_partial.__setstate()
} catch TypeError as err {
    functools_example_partial_setstate_arity_error := err.Message
}
functools_example_partial_setstate_invalid_error := ""
try {
    functools_example_stateful_partial.__setstate(42)
} catch TypeError as err {
    functools_example_partial_setstate_invalid_error := err.Message
}
functools_example_keyword_partial := stdlib.functools.partial(functools_example_add_three, 1)
functools_example_keyword_partial.keywords["c"] := 5
functools_example_keyword_call := functools_example_keyword_partial.Call(2)
functools_example_keyword_partial_repr := functools_example_keyword_partial.__Repr()
functools_example_keyword_literal_partial := stdlib.functools.partial(functools_example_identity)
functools_example_keyword_literal_partial.keywords["alpha"] := Map("x", 1)
functools_example_keyword_literal_partial_repr := functools_example_keyword_literal_partial.__Repr()
functools_example_nested_args_mutation_error := ""
try {
    functools_example_nested_args[1] := 99
} catch TypeError as err {
    functools_example_nested_args_mutation_error := err.Message
}
functools_example_nested_args_after_local_mutation := functools_example_add_two_three.args

functools_example_add(a, b)
{
    return a + b
}

functools_example_identity(value)
{
    return value
}

functools_example_add_three(a, b, c)
{
    return a + b + c
}

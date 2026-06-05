#Requires AutoHotkey v2.0

#Include <stdlib\abc>

abc_example_identity := stdlib.abc.abstractmethod((value) => value)
abc_example_identity_has_flag := abc_example_identity.__isabstractmethod__
abc_example_identity_result := abc_example_identity.Call(7)

class abc_example_virtual_foreign
{
}

abc_example_register_return := stdlib.abc.ABC.register(abc_example_virtual_foreign)
abc_example_virtual_isabstract := stdlib.abc.isabstract(abc_example_virtual_foreign)
abc_example_virtual_isinstance := stdlib.abc.isinstance(abc_example_virtual_foreign(), stdlib.abc.ABC)
abc_example_cache_token_after_register := stdlib.abc.get_cache_token()
abc_example_duplicate_register_return := stdlib.abc.ABC.register(abc_example_virtual_foreign)
abc_example_cache_token_after_duplicate := stdlib.abc.get_cache_token()
abc_example_self_register_return := stdlib.abc.ABC.register(stdlib.abc.ABC)

abc_example_bad_arity_error := ""
try {
    stdlib.abc.abstractmethod()
} catch TypeError as err {
    abc_example_bad_arity_error := err.Message
}

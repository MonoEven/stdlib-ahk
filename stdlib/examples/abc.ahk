#Requires AutoHotkey v2.0

#Include <stdlib\abc>

abc_example_identity := stdlib.abc.abstractmethod((value) => value)
abc_example_identity_has_flag := abc_example_identity.__isabstractmethod__
abc_example_identity_result := abc_example_identity.Call(7)

class abc_example_virtual_foreign
{
}

abc_example_virtual_base_before := abc_example_virtual_foreign.Prototype.Base
abc_example_register_return := stdlib.abc.ABC.register(abc_example_virtual_foreign)
abc_example_virtual_isabstract := stdlib.abc.isabstract(abc_example_virtual_foreign)
abc_example_virtual_issubclass := stdlib.abc.issubclass(abc_example_virtual_foreign, stdlib.abc.ABC)
abc_example_virtual_isinstance := stdlib.abc.isinstance(abc_example_virtual_foreign(), stdlib.abc.ABC)
abc_example_virtual_base_unchanged := ObjPtr(abc_example_virtual_base_before) = ObjPtr(abc_example_virtual_foreign.Prototype.Base)
abc_example_cache_token_after_register := stdlib.abc.get_cache_token()
abc_example_duplicate_register_return := stdlib.abc.ABC.register(abc_example_virtual_foreign)
abc_example_cache_token_after_duplicate := stdlib.abc.get_cache_token()
abc_example_self_register_return := stdlib.abc.ABC.register(stdlib.abc.ABC)
abc_example_abcmeta_is_abc := stdlib.abc.ABCMeta = stdlib.abc.ABC

abc_example_static := stdlib.abc.abstractstaticmethod((value) => value + 1)
abc_example_static_has_flag := abc_example_static.__isabstractmethod__
abc_example_static_func_has_flag := abc_example_static.__func__.__isabstractmethod__
abc_example_static_result := abc_example_static.Call(4)

abc_example_class := stdlib.abc.abstractclassmethod((cls, value) => value + 2)
abc_example_class_has_flag := abc_example_class.__isabstractmethod__
abc_example_class_result := abc_example_class.Call(stdlib.abc.ABC, 4)

abc_example_property := stdlib.abc.abstractproperty((self) => "title")
abc_example_property_has_flag := abc_example_property.__isabstractmethod__

abc_example_bad_arity_error := ""
try {
    stdlib.abc.abstractmethod()
} catch TypeError as err {
    abc_example_bad_arity_error := err.Message
}

class abc_example_dynamic_abstract
{
    static AhkStdlibAbstractMethods := Map()
}

abc_example_update_before := stdlib.abc.isabstract(abc_example_dynamic_abstract)
abc_example_dynamic_abstract.Prototype.need := stdlib.abc.abstractmethod((self) => stdlib.None)
abc_example_update_stale := stdlib.abc.isabstract(abc_example_dynamic_abstract)
abc_example_update_return := stdlib.abc.update_abstractmethods(abc_example_dynamic_abstract)
abc_example_update_after := stdlib.abc.isabstract(abc_example_dynamic_abstract)

class abc_example_update_base
{
    static AhkStdlibAbstractMethods := Map()
}

class abc_example_update_concrete extends abc_example_update_base
{
    static AhkStdlibAbstractMethods := Map()
}

class abc_example_update_leaf extends abc_example_update_base
{
    static AhkStdlibAbstractMethods := Map()
}

class abc_example_update_reabstract extends abc_example_update_base
{
    static AhkStdlibAbstractMethods := Map()
}

abc_example_update_base.Prototype.need := stdlib.abc.abstractmethod((self) => "base")
abc_example_update_concrete.Prototype.need := (self) => "concrete"
abc_example_update_reabstract.Prototype.need := stdlib.abc.abstractmethod((self) => "again")
stdlib.abc.update_abstractmethods(abc_example_update_base)
stdlib.abc.update_abstractmethods(abc_example_update_concrete)
stdlib.abc.update_abstractmethods(abc_example_update_leaf)
stdlib.abc.update_abstractmethods(abc_example_update_reabstract)
abc_example_update_base_isabstract := stdlib.abc.isabstract(abc_example_update_base)
abc_example_update_concrete_isabstract := stdlib.abc.isabstract(abc_example_update_concrete)
abc_example_update_leaf_isabstract := stdlib.abc.isabstract(abc_example_update_leaf)
abc_example_update_reabstract_isabstract := stdlib.abc.isabstract(abc_example_update_reabstract)

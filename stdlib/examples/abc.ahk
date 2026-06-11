#Requires AutoHotkey v2.0

#Include <stdlib\abc>

abc_example_identity := stdlib.abc.abstractmethod((value) => value)
abc_example_identity_has_flag := abc_example_identity.__isabstractmethod
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
abc_example_static_has_flag := abc_example_static.__isabstractmethod
abc_example_static_func_has_flag := abc_example_static.__func.__isabstractmethod
abc_example_static_result := abc_example_static.Call(4)

abc_example_class := stdlib.abc.abstractclassmethod((cls, value) => value + 2)
abc_example_class_has_flag := abc_example_class.__isabstractmethod
abc_example_class_result := abc_example_class.Call(stdlib.abc.ABC, 4)

abc_example_property := stdlib.abc.abstractproperty((self) => "title")
abc_example_property_has_flag := abc_example_property.__isabstractmethod
abc_example_property_value := abc_example_property.Get(stdlib.None)

abc_example_empty_property := stdlib.abc.abstractproperty()
abc_example_empty_property_has_flag := abc_example_empty_property.__isabstractmethod
abc_example_empty_property_fget_is_none := ObjPtr(abc_example_empty_property.fget) = ObjPtr(stdlib.None)

class abc_example_property_target
{
    __New()
    {
        this.value := "draft"
        this.deleted := false
    }
}

abc_example_property_events := []
abc_example_rw_property := stdlib.abc.abstractproperty(
    (self) => self.value,
    (self, value) => (self.value := value, abc_example_property_events.Push(["set", value])),
    (self) => (self.deleted := true, abc_example_property_events.Push(["delete"])),
    "doc text"
)
abc_example_property_target_instance := abc_example_property_target()
abc_example_rw_property_initial := abc_example_rw_property.Get(abc_example_property_target_instance)
abc_example_rw_property_set_return := abc_example_rw_property.Set(abc_example_property_target_instance, "published")
abc_example_rw_property_after_set := abc_example_property_target_instance.value
abc_example_rw_property_delete_return := abc_example_rw_property.Delete(abc_example_property_target_instance)
abc_example_rw_property_deleted := abc_example_property_target_instance.deleted

abc_example_bad_arity_error := ""
try {
    stdlib.abc.abstractmethod()
} catch TypeError as err {
    abc_example_bad_arity_error := err.Message
}

abc_example_abstractmethod_noncallable_error := ""
try {
    stdlib.abc.abstractmethod(1)
} catch AttributeError as err {
    abc_example_abstractmethod_noncallable_error := err.Message
}

abc_example_staticmethod_bad_arity_error := ""
try {
    stdlib.abc.abstractstaticmethod()
} catch TypeError as err {
    abc_example_staticmethod_bad_arity_error := err.Message
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

class abc_example_hook_base extends AhkStdlibAbcBase
{
    static __subclasshook(subclass)
    {
        if subclass = abc_example_hook_structural
            return true
        return stdlib.NotImplemented
    }
}

class abc_example_hook_structural
{
}

class abc_example_hook_plain
{
}

class abc_example_hook_concrete extends abc_example_hook_base
{
}

abc_example_hook_issubclass := stdlib.abc.issubclass(abc_example_hook_structural, abc_example_hook_base)
abc_example_hook_isinstance := stdlib.abc.isinstance(abc_example_hook_structural(), abc_example_hook_base)
abc_example_hook_plain_issubclass := stdlib.abc.issubclass(abc_example_hook_plain, abc_example_hook_base)
abc_example_hook_concrete_issubclass := stdlib.abc.issubclass(abc_example_hook_concrete, abc_example_hook_base)

class abc_example_register_cycle_base extends AhkStdlibAbcBase
{
}

class abc_example_register_cycle_child extends abc_example_register_cycle_base
{
}

abc_example_register_cycle_error := ""
try {
    abc_example_register_cycle_child.register(abc_example_register_cycle_base)
} catch RuntimeError as err {
    abc_example_register_cycle_error := err.Message
}

class abc_example_transitive_root extends AhkStdlibAbcBase
{
}

class abc_example_transitive_mid extends AhkStdlibAbcBase
{
}

class abc_example_transitive_leaf
{
}

class abc_example_transitive_real_leaf extends abc_example_transitive_leaf
{
}

abc_example_transitive_token_before := stdlib.abc.get_cache_token()
abc_example_transitive_root_register_mid := abc_example_transitive_root.register(abc_example_transitive_mid)
abc_example_transitive_token_after_root := stdlib.abc.get_cache_token()
abc_example_transitive_mid_register_leaf := abc_example_transitive_mid.register(abc_example_transitive_leaf)
abc_example_transitive_token_after_mid := stdlib.abc.get_cache_token()
abc_example_transitive_mid_is_root := stdlib.abc.issubclass(abc_example_transitive_mid, abc_example_transitive_root)
abc_example_transitive_leaf_is_mid := stdlib.abc.issubclass(abc_example_transitive_leaf, abc_example_transitive_mid)
abc_example_transitive_leaf_is_root := stdlib.abc.issubclass(abc_example_transitive_leaf, abc_example_transitive_root)
abc_example_transitive_leaf_instance_is_root := stdlib.abc.isinstance(abc_example_transitive_leaf(), abc_example_transitive_root)
abc_example_transitive_real_leaf_is_root := stdlib.abc.issubclass(abc_example_transitive_real_leaf, abc_example_transitive_root)
abc_example_transitive_real_leaf_instance_is_root := stdlib.abc.isinstance(abc_example_transitive_real_leaf(), abc_example_transitive_root)

class abc_example_instantiation_base extends AhkStdlibAbcBase
{
    static AhkStdlibAbstractMethods := Map("need", true)
}

abc_example_instantiation_base.Prototype.need := stdlib.abc.abstractmethod((self) => "base")

class abc_example_instantiation_concrete extends abc_example_instantiation_base
{
    static AhkStdlibAbstractMethods := Map()

    need()
    {
        return "concrete"
    }
}

class abc_example_instantiation_dynamic extends AhkStdlibAbcBase
{
    static AhkStdlibAbstractMethods := Map()
}

abc_example_instantiation_base_isabstract := stdlib.abc.isabstract(abc_example_instantiation_base)
abc_example_instantiation_base_error := ""
try {
    abc_example_instantiation_base()
} catch TypeError as err {
    abc_example_instantiation_base_error := err.Message
}
abc_example_instantiation_concrete_isabstract := stdlib.abc.isabstract(abc_example_instantiation_concrete)
abc_example_instantiation_concrete_value := abc_example_instantiation_concrete().need()
abc_example_instantiation_dynamic_before := stdlib.abc.isabstract(abc_example_instantiation_dynamic)
abc_example_instantiation_dynamic.Prototype.need := stdlib.abc.abstractmethod((self) => "dynamic")
abc_example_instantiation_dynamic_stale := stdlib.abc.isabstract(abc_example_instantiation_dynamic)
stdlib.abc.update_abstractmethods(abc_example_instantiation_dynamic)
abc_example_instantiation_dynamic_after := stdlib.abc.isabstract(abc_example_instantiation_dynamic)
abc_example_instantiation_dynamic_error := ""
try {
    abc_example_instantiation_dynamic()
} catch TypeError as err {
    abc_example_instantiation_dynamic_error := err.Message
}

class abc_example_decorator_root extends AhkStdlibAbcBase
{
}

class abc_example_decorator_target
{
}

abc_example_decorator_token_before := stdlib.abc.get_cache_token()
abc_example_decorator_registered := stdlib.decorate(abc_example_decorator_target, (cls) => abc_example_decorator_root.register(cls))
abc_example_decorator_token_after := stdlib.abc.get_cache_token()
abc_example_decorator_returned_target := abc_example_decorator_registered = abc_example_decorator_target
abc_example_decorator_issubclass := stdlib.abc.issubclass(abc_example_decorator_target, abc_example_decorator_root)
abc_example_decorator_isinstance := stdlib.abc.isinstance(abc_example_decorator_target(), abc_example_decorator_root)

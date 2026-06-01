#Requires AutoHotkey v2.0

#Include <stdlib\base>

class BaseExampleSubject
{
    __New()
    {
        this.name := "kept"
    }
}

base_example_value := BaseExampleSubject()
stdlib.base.checkType(BaseExampleSubject, base_example_value)
stdlib.base.delattr(base_example_value, "name")

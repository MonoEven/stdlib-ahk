#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\base>

class StdlibCoreBaseTestSubject
{
    __New()
    {
        this.name := "kept"
    }
}

class StdlibCoreBaseTest
{
    static TestCheckTypeAcceptsExpectedInstances()
    {
        value := StdlibCoreBaseTestSubject()

        stdlib.base.checkType(StdlibCoreBaseTestSubject, value)

        AhkTest.AssertTrue(value is StdlibCoreBaseTestSubject)
    }

    static TestCheckTypeRejectsWrongType()
    {
        AhkTest.AssertThrows(TypeError, (*) => stdlib.base.checkType(StdlibCoreBaseTestSubject, {}))
    }

    static TestCheckTypeRejectsUnsetValues()
    {
        AhkTest.AssertThrows(UnsetError, (*) => stdlib.base.checkType(StdlibCoreBaseTestSubject))
    }

    static TestDelAttrDeletesOwnPropertiesLikePython()
    {
        value := StdlibCoreBaseTestSubject()

        stdlib.base.delattr(value, "name")

        AhkTest.AssertFalse(HasProp(value, "name"))
        AhkTest.RaisesMatch(PropertyError, "name", (*) => stdlib.base.delattr(value, "name"))
        AhkTest.RaisesMatch(TypeError, "attribute name must be string, not 'int'", (*) => stdlib.base.delattr(value, 1))
        AhkTest.RaisesMatch(PropertyError, "'int' object has no attribute 'name'", (*) => stdlib.base.delattr(1, "name"))
    }
}

AhkTest.Collect(StdlibCoreBaseTest)

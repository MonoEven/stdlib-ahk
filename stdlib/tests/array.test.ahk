#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\array>

class StdlibArrayTest
{
    static TestArrayTypecodesAndConstructorMatchLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3])

        AhkTest.AssertEqual("bBuhHiIlLqQfd", stdlib.array.typecodes)
        AhkTest.AssertEqual("array('i')", stdlib.array.array("i").__Repr())
        AhkTest.AssertEqual("array('i', [1, 2, 3])", values.__Repr())
        AhkTest.AssertEqual("i", values.typecode)
        AhkTest.AssertEqual(4, values.itemsize)
        AhkTest.AssertEqual([1, 2, 3], values.tolist())
    }

    static TestArraySupportsAppendExtendIndexIterationAndBufferInfoLikeLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3])
        iterated := []
        bufferInfo := values.buffer_info()

        AhkTest.AssertEqual("", values.append(4))
        AhkTest.AssertEqual("", values.extend([5, 6]))
        AhkTest.AssertEqual(2, values[1])
        values[1] := 20

        for value in values
            iterated.Push(value)

        AhkTest.AssertTrue(Type(bufferInfo) = "AhkStdlibTuple")
        AhkTest.AssertEqual(2, bufferInfo.Length)
        AhkTest.AssertTrue(bufferInfo[1] is Integer)
        AhkTest.AssertTrue(bufferInfo[1] != 0)
        AhkTest.AssertEqual(3, bufferInfo[2])
        AhkTest.AssertEqual([1, 20, 3, 4, 5, 6], values.tolist())
        AhkTest.AssertEqual([1, 20, 3, 4, 5, 6], iterated)
    }

    static TestArraySequenceMutationMethodsMatchLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 2, 3])

        AhkTest.AssertEqual(2, values.count(2))
        AhkTest.AssertEqual(0, values.count(9))
        AhkTest.AssertEqual(0, values.count("x"))
        AhkTest.AssertEqual(1, values.index(2))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => values.index(9))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => values.index("x"))

        AhkTest.AssertEqual(stdlib.None, values.remove(2))
        AhkTest.AssertEqual([1, 2, 3], values.tolist())
        AhkTest.RaisesMatch(ValueError, "^array\.remove\(x\): x not in array$", (*) => values.remove(9))
        AhkTest.RaisesMatch(ValueError, "^array\.remove\(x\): x not in array$", (*) => values.remove("x"))

        AhkTest.AssertEqual(3, values.pop())
        AhkTest.AssertEqual([1, 2], values.tolist())
        AhkTest.AssertEqual(1, values.pop(0))
        AhkTest.AssertEqual([2], values.tolist())
        AhkTest.AssertEqual("", values.extend([4, 5, 6]))
        AhkTest.AssertEqual(5, values.pop(-2))
        AhkTest.AssertEqual([2, 4, 6], values.tolist())
        AhkTest.AssertEqual(stdlib.None, values.reverse())
        AhkTest.AssertEqual([6, 4, 2], values.tolist())

        AhkTest.RaisesMatch(IndexError, "^pop from empty array$", (*) => stdlib.array.array("i").pop())
        AhkTest.RaisesMatch(IndexError, "^pop index out of range$", (*) => stdlib.array.array("i", [1]).pop(2))
        AhkTest.RaisesMatch(IndexError, "^pop index out of range$", (*) => stdlib.array.array("i", [1]).pop(-2))
        AhkTest.RaisesMatch(TypeError, "^'float' object cannot be interpreted as an integer$", (*) => stdlib.array.array("i", [1]).pop(0.5))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.array.array("i", [1]).pop("0"))
        AhkTest.RaisesMatch(TypeError, "^array\.count\(\) takes exactly one argument \(2 given\)$", (*) => stdlib.array.array("i", [1]).count(1, 0))
        AhkTest.RaisesMatch(TypeError, "^array\.reverse\(\) takes no arguments \(1 given\)$", (*) => stdlib.array.array("i", [1]).reverse(1))
    }

    static TestArrayRejectsObservedLocal310InvalidArguments()
    {
        AhkTest.RaisesMatch(ValueError, "bad typecode \(must be b, B, u, h, H, i, I, l, L, q, Q, f or d\)", (*) => stdlib.array.array("z"))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.array.array("i", 1))
        AhkTest.RaisesMatch(TypeError, "'str' object cannot be interpreted as an integer", (*) => stdlib.array.array("i").append("x"))
        AhkTest.RaisesMatch(TypeError, "'int' object is not iterable", (*) => stdlib.array.array("i").extend(1))
        AhkTest.RaisesMatch(IndexError, "array index out of range", (*) => stdlib.array.array("i")[-1])
        AhkTest.RaisesMatch(IndexError, "array index out of range", (*) => stdlib.array.array("i")[0])
    }
}

AhkTest.Test("array typecodes and constructor match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayTypecodesAndConstructorMatchLocal310())
AhkTest.Test("array supports append extend index iteration and buffer_info like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySupportsAppendExtendIndexIterationAndBufferInfoLikeLocal310())
AhkTest.Test("array sequence mutation methods match local 3.10 baseline", (*) => StdlibArrayTest.TestArraySequenceMutationMethodsMatchLocal310())
AhkTest.Test("array rejects observed local 3.10 invalid arguments", (*) => StdlibArrayTest.TestArrayRejectsObservedLocal310InvalidArguments())

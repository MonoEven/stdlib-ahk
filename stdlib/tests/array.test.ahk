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
AhkTest.Test("array rejects observed local 3.10 invalid arguments", (*) => StdlibArrayTest.TestArrayRejectsObservedLocal310InvalidArguments())

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\array>
#Include <stdlib\operator>

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

    static TestArrayFunctionSurfaceBinaryUnicodeAndFileMethods()
    {
        AhkTest.AssertSame(stdlib.array.array, stdlib.array.ArrayType)

        values := stdlib.array.array("i", [1, 2, 3])
        AhkTest.AssertSame(stdlib.None, values.insert(1, 9))
        AhkTest.AssertEqual([1, 9, 2, 3], values.tolist())
        AhkTest.AssertSame(stdlib.None, values.insert(-99, 7))
        AhkTest.AssertSame(stdlib.None, values.insert(99, 8))
        AhkTest.AssertEqual([7, 1, 9, 2, 3, 8], values.tolist())

        bytesSource := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, bytesSource.fromlist([2, 3]))
        AhkTest.AssertEqual([1, 2, 3], bytesSource.tolist())
        rawBytes := bytesSource.tobytes()
        AhkTest.AssertEqual("010000000200000003000000", StdlibArrayTest.BufferHex(rawBytes))
        bytesCopy := stdlib.array.array("i")
        AhkTest.AssertSame(stdlib.None, bytesCopy.frombytes(rawBytes))
        AhkTest.AssertEqual([1, 2, 3], bytesCopy.tolist())
        AhkTest.RaisesMatch(ValueError, "^bytes length not a multiple of item size$", (*) => stdlib.array.array("i").frombytes(Buffer(1, 0)))

        swapped := stdlib.array.array("H", [0x0102, 0x0304])
        AhkTest.AssertSame(stdlib.None, swapped.byteswap())
        AhkTest.AssertEqual([513, 1027], swapped.tolist())
        AhkTest.AssertEqual("01020304", StdlibArrayTest.BufferHex(swapped.tobytes()))

        unicodeValues := stdlib.array.array("u", "Az")
        AhkTest.AssertEqual(["A", "z"], unicodeValues.tolist())
        AhkTest.AssertEqual("Az", unicodeValues.tounicode())
        AhkTest.AssertSame(stdlib.None, unicodeValues.fromunicode("!"))
        AhkTest.AssertEqual(["A", "z", "!"], unicodeValues.tolist())
        AhkTest.RaisesMatch(ValueError, "^fromunicode\(\) may only be called on unicode type arrays$", (*) => stdlib.array.array("i").fromunicode("x"))
        AhkTest.RaisesMatch(ValueError, "^tounicode\(\) may only be called on unicode type arrays$", (*) => stdlib.array.array("i", [1]).tounicode())

        tempPath := A_Temp "\stdlib-array-file-" A_TickCount "-" Random(100000, 999999) ".bin"
        try {
            fileValues := stdlib.array.array("H", [1, 258])
            AhkTest.AssertSame(stdlib.None, fileValues.tofile(tempPath))
            AhkTest.AssertEqual("01000201", StdlibArrayTest.BufferHex(FileRead(tempPath, "RAW")))
            loaded := stdlib.array.array("H")
            AhkTest.AssertSame(stdlib.None, loaded.fromfile(tempPath, 2))
            AhkTest.AssertEqual([1, 258], loaded.tolist())
        } finally {
            if FileExist(tempPath)
                FileDelete tempPath
        }
    }

    static TestArraySequenceDunderOperationsMatchLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3])
        sameTypeSameValues := stdlib.array.array("i", [1, 2, 3])
        otherTypeSameValues := stdlib.array.array("h", [1, 2, 3])

        AhkTest.AssertEqual(3, values.__Len)
        AhkTest.AssertTrue(stdlib.operator.truth(values))
        AhkTest.AssertFalse(stdlib.operator.truth(stdlib.array.array("i")))
        AhkTest.AssertTrue(stdlib.operator.contains(values, 2))
        AhkTest.AssertFalse(stdlib.operator.contains(values, 9))
        AhkTest.AssertTrue(stdlib.operator.eq(values, sameTypeSameValues))
        AhkTest.AssertTrue(stdlib.operator.eq(values, otherTypeSameValues))
        AhkTest.AssertTrue(stdlib.operator.ne(values, stdlib.array.array("i", [1, 2, 4])))

        added := stdlib.operator.add(values, stdlib.array.array("i", [4, 5]))
        AhkTest.AssertEqual("i", added.typecode)
        AhkTest.AssertEqual([1, 2, 3, 4, 5], added.tolist())
        AhkTest.RaisesMatch(TypeError, "^bad argument type for built-in operation$", (*) => stdlib.operator.add(values, stdlib.array.array("h", [4])))

        multiplied := stdlib.operator.mul(values, 2)
        reverseMultiplied := stdlib.operator.mul(2, values)
        zeroMultiplied := stdlib.operator.mul(values, 0)
        negativeMultiplied := stdlib.operator.mul(values, -1)
        AhkTest.AssertEqual("i", multiplied.typecode)
        AhkTest.AssertEqual([1, 2, 3, 1, 2, 3], multiplied.tolist())
        AhkTest.AssertEqual([1, 2, 3, 1, 2, 3], reverseMultiplied.tolist())
        AhkTest.AssertEqual([], zeroMultiplied.tolist())
        AhkTest.AssertEqual([], negativeMultiplied.tolist())
    }

    static BufferHex(bytes)
    {
        text := ""
        loop bytes.Size
            text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return text
    }
}

AhkTest.Test("array typecodes and constructor match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayTypecodesAndConstructorMatchLocal310())
AhkTest.Test("array supports append extend index iteration and buffer_info like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySupportsAppendExtendIndexIterationAndBufferInfoLikeLocal310())
AhkTest.Test("array sequence mutation methods match local 3.10 baseline", (*) => StdlibArrayTest.TestArraySequenceMutationMethodsMatchLocal310())
AhkTest.Test("array rejects observed local 3.10 invalid arguments", (*) => StdlibArrayTest.TestArrayRejectsObservedLocal310InvalidArguments())
AhkTest.Test("array function surface covers binary unicode and file methods", (*) => StdlibArrayTest.TestArrayFunctionSurfaceBinaryUnicodeAndFileMethods())
AhkTest.Test("array sequence dunder operations match local 3.10 baseline", (*) => StdlibArrayTest.TestArraySequenceDunderOperationsMatchLocal310())

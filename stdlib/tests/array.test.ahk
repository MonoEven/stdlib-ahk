#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\array>
#Include <stdlib\copy>
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

        AhkTest.AssertSame(stdlib.None, values.append(4))
        AhkTest.AssertSame(stdlib.None, values.extend([5, 6]))
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
        AhkTest.AssertSame(stdlib.None, values.extend([4, 5, 6]))
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

    static TestArrayIndexAcceptsStartAndStopLikeLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3, 2, 4])

        AhkTest.AssertEqual(1, values.index(2))
        AhkTest.AssertEqual(3, values.index(2, 2))
        AhkTest.AssertEqual(3, values.index(2, 2, 4))
        AhkTest.AssertEqual(3, values.index(2, -2))
        AhkTest.AssertEqual(1, values.index(2, -4, -1))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => values.index(2, 5))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => values.index(2, 2, 3))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => values.index(9, 0, 5))
        AhkTest.RaisesMatch(TypeError, "^slice indices must be integers or have an __index__ method$", (*) => values.index(2, 0.5))
        AhkTest.RaisesMatch(TypeError, "^slice indices must be integers or have an __index__ method$", (*) => values.index(2, 0, "4"))
        AhkTest.RaisesMatch(TypeError, "^index expected at least 1 argument, got 0$", (*) => values.index())
        AhkTest.RaisesMatch(TypeError, "^index expected at most 3 arguments, got 4$", (*) => values.index(2, 0, 4, 5))
    }

    static TestArrayExtendAndFromlistInputRulesMatchLocal310()
    {
        extendSame := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, extendSame.extend(stdlib.array.array("i", [2, 3])))
        AhkTest.AssertEqual([1, 2, 3], extendSame.tolist())

        extendList := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, extendList.extend([2, 3]))
        AhkTest.AssertEqual([1, 2, 3], extendList.tolist())

        fromlistList := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, fromlistList.fromlist([2, 3]))
        AhkTest.AssertEqual([1, 2, 3], fromlistList.tolist())

        AhkTest.RaisesMatch(TypeError, "^can only extend with array of same kind$", (*) => stdlib.array.array("i", [1]).extend(stdlib.array.array("h", [2])))
        AhkTest.RaisesMatch(TypeError, "^'int' object is not iterable$", (*) => stdlib.array.array("i").extend(1))
        AhkTest.RaisesMatch(TypeError, "^arg must be list$", (*) => stdlib.array.array("i").fromlist(stdlib.tuple([1, 2])))
        AhkTest.RaisesMatch(TypeError, "^arg must be list$", (*) => stdlib.array.array("i").fromlist(stdlib.array.array("i", [1])))
    }

    static TestArrayAppendAndExtendReturnNoneLikeLocal310()
    {
        appended := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, appended.append(2))
        AhkTest.AssertEqual([1, 2], appended.tolist())

        extendedList := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, extendedList.extend([2, 3]))
        AhkTest.AssertEqual([1, 2, 3], extendedList.tolist())

        extendedArray := stdlib.array.array("i", [1])
        AhkTest.AssertSame(stdlib.None, extendedArray.extend(stdlib.array.array("i", [2, 3])))
        AhkTest.AssertEqual([1, 2, 3], extendedArray.tolist())

        extendedUnicode := stdlib.array.array("u", "A")
        AhkTest.AssertSame(stdlib.None, extendedUnicode.extend("z"))
        AhkTest.AssertEqual(["A", "z"], extendedUnicode.tolist())
        AhkTest.AssertEqual("array('u', 'Az')", extendedUnicode.__Repr())
    }

    static TestArrayStringInitializerRulesMatchLocal310()
    {
        unicodeValues := stdlib.array.array("u", "Az")
        AhkTest.AssertEqual(["A", "z"], unicodeValues.tolist())
        AhkTest.AssertSame(stdlib.None, unicodeValues.extend("!"))
        AhkTest.AssertEqual(["A", "z", "!"], unicodeValues.tolist())

        unicodeFromList := stdlib.array.array("u")
        AhkTest.AssertSame(stdlib.None, unicodeFromList.fromlist(["A", "z"]))
        AhkTest.AssertEqual(["A", "z"], unicodeFromList.tolist())

        AhkTest.RaisesMatch(TypeError, "^cannot use a str to initialize an array with typecode 'i'$", (*) => stdlib.array.array("i", "12"))
        AhkTest.RaisesMatch(TypeError, "^cannot use a str to initialize an array with typecode 'b'$", (*) => stdlib.array.array("b", "ab"))
        AhkTest.RaisesMatch(TypeError, "^'str' object cannot be interpreted as an integer$", (*) => stdlib.array.array("i", [1]).extend("12"))
        AhkTest.RaisesMatch(TypeError, "^arg must be list$", (*) => stdlib.array.array("u").fromlist("Az"))
    }

    static TestArrayBytesInitializerUsesRawBytesLikeLocal310()
    {
        intBytes := Buffer(8, 0)
        NumPut("Int", 1, intBytes, 0)
        NumPut("Int", 2, intBytes, 4)
        intValues := stdlib.array.array("i", intBytes)
        AhkTest.AssertEqual([1, 2], intValues.tolist())
        AhkTest.AssertEqual("array('i', [1, 2])", intValues.__Repr())

        oneIntBytes := Buffer(4, 0)
        NumPut("Int", 1, oneIntBytes, 0)
        byteArrayValues := stdlib.array.array("i", oneIntBytes)
        AhkTest.AssertEqual([1], byteArrayValues.tolist())

        unicodeBytes := Buffer(4, 0)
        NumPut("UShort", Ord("A"), unicodeBytes, 0)
        NumPut("UShort", Ord("Z"), unicodeBytes, 2)
        unicodeValues := stdlib.array.array("u", unicodeBytes)
        AhkTest.AssertEqual(["A", "Z"], unicodeValues.tolist())
        AhkTest.AssertEqual("array('u', 'AZ')", unicodeValues.__Repr())

        AhkTest.RaisesMatch(ValueError, "^bytes length not a multiple of item size$", (*) => stdlib.array.array("i", Buffer(1, 0x5A)))
    }

    static TestArrayExtendBufferIteratesBytesLikeLocal310()
    {
        intBytes := Buffer(2, 0)
        NumPut("UChar", 1, intBytes, 0)
        NumPut("UChar", 2, intBytes, 1)
        intValues := stdlib.array.array("i", [9])
        AhkTest.AssertSame(stdlib.None, intValues.extend(intBytes))
        AhkTest.AssertEqual([9, 1, 2], intValues.tolist())
        AhkTest.AssertEqual("array('i', [9, 1, 2])", intValues.__Repr())

        unsignedBytes := Buffer(2, 0)
        NumPut("UChar", 1, unsignedBytes, 0)
        NumPut("UChar", 255, unsignedBytes, 1)
        unsignedValues := stdlib.array.array("B", [9])
        AhkTest.AssertSame(stdlib.None, unsignedValues.extend(unsignedBytes))
        AhkTest.AssertEqual([9, 1, 255], unsignedValues.tolist())

        rawInitializerBytes := Buffer(4, 0)
        NumPut("Int", 1, rawInitializerBytes, 0)
        AhkTest.AssertEqual([1], stdlib.array.array("i", rawInitializerBytes).tolist())

        unicodeValues := stdlib.array.array("u", "A")
        AhkTest.RaisesMatch(TypeError, "^array item must be unicode character$", (*) => unicodeValues.extend(Buffer(1, 0x5A)))
        AhkTest.AssertEqual(["A"], unicodeValues.tolist())
    }

    static TestArrayUnicodeReprMatchesLocal310()
    {
        AhkTest.AssertEqual("array('u')", stdlib.array.array("u").__Repr())
        AhkTest.AssertEqual("array('u', 'Az')", stdlib.array.array("u", "Az").__Repr())
        AhkTest.AssertEqual("array('u', `"A'B`")", stdlib.array.array("u", "A'B").__Repr())
        AhkTest.AssertEqual("array('u', 'A`"B')", stdlib.array.array("u", "A`"B").__Repr())
        AhkTest.AssertEqual("array('u', 'A\\B')", stdlib.array.array("u", "A\B").__Repr())
        AhkTest.AssertEqual("array('u', 'A\nB')", stdlib.array.array("u", "A`nB").__Repr())
        AhkTest.AssertEqual("array('u', 'A\tB')", stdlib.array.array("u", "A`tB").__Repr())
        AhkTest.AssertEqual("array('u', 'A\x0bB')", stdlib.array.array("u", "A" Chr(11) "B").__Repr())
    }

    static TestArrayNumericTypecodesAcceptRootBoolValuesLikeLocal310()
    {
        for typecode in ["b", "B", "h", "H", "i", "I", "l", "L", "q", "Q"] {
            constructed := stdlib.array.array(typecode, [stdlib.True, stdlib.False])
            AhkTest.AssertEqual([1, 0], constructed.tolist())
            AhkTest.AssertEqual("array('" typecode "', [1, 0])", constructed.__Repr())

            appended := stdlib.array.array(typecode)
            AhkTest.AssertSame(stdlib.None, appended.append(stdlib.True))
            AhkTest.AssertSame(stdlib.None, appended.append(stdlib.False))
            AhkTest.AssertEqual([1, 0], appended.tolist())
        }

        for typecode in ["f", "d"] {
            constructed := stdlib.array.array(typecode, [stdlib.True, stdlib.False])
            AhkTest.AssertEqual([1.0, 0.0], constructed.tolist())
            AhkTest.AssertEqual("array('" typecode "', [1.0, 0.0])", constructed.__Repr())

            appended := stdlib.array.array(typecode)
            AhkTest.AssertSame(stdlib.None, appended.append(stdlib.True))
            AhkTest.AssertSame(stdlib.None, appended.append(stdlib.False))
            AhkTest.AssertEqual([1.0, 0.0], appended.tolist())
        }

        AhkTest.RaisesMatch(TypeError, "^array item must be unicode character$", (*) => stdlib.array.array("u", [stdlib.True]))
        AhkTest.RaisesMatch(TypeError, "^array item must be unicode character$", (*) => stdlib.array.array("u").append(stdlib.False))
    }

    static TestArrayRootBoolIndexesAndCountsMatchLocal310()
    {
        values := stdlib.array.array("i", [10, 20, 30])
        AhkTest.AssertEqual(20, values[stdlib.True])
        AhkTest.AssertEqual(10, values[stdlib.False])

        setTrue := stdlib.array.array("i", [10, 20, 30])
        StdlibArrayTest.SetItem(setTrue, stdlib.True, 99)
        AhkTest.AssertEqual([10, 99, 30], setTrue.tolist())

        setFalse := stdlib.array.array("i", [10, 20, 30])
        StdlibArrayTest.SetItem(setFalse, stdlib.False, 99)
        AhkTest.AssertEqual([99, 20, 30], setFalse.tolist())

        deleteTrue := stdlib.array.array("i", [10, 20, 30])
        AhkTest.AssertSame(stdlib.None, deleteTrue.Delete(stdlib.True))
        AhkTest.AssertEqual([10, 30], deleteTrue.tolist())

        deleteFalse := stdlib.array.array("i", [10, 20, 30])
        AhkTest.AssertSame(stdlib.None, deleteFalse.Delete(stdlib.False))
        AhkTest.AssertEqual([20, 30], deleteFalse.tolist())

        AhkTest.AssertEqual(20, stdlib.array.array("i", [10, 20, 30]).pop(stdlib.True))
        AhkTest.AssertEqual(10, stdlib.array.array("i", [10, 20, 30]).pop(stdlib.False))

        insertTrue := stdlib.array.array("i", [10, 20, 30])
        AhkTest.AssertSame(stdlib.None, insertTrue.insert(stdlib.True, 99))
        AhkTest.AssertEqual([10, 99, 20, 30], insertTrue.tolist())

        insertFalse := stdlib.array.array("i", [10, 20, 30])
        AhkTest.AssertSame(stdlib.None, insertFalse.insert(stdlib.False, 99))
        AhkTest.AssertEqual([99, 10, 20, 30], insertFalse.tolist())

        AhkTest.AssertEqual(2, stdlib.array.array("i", [10, 20, 10, 20]).index(10, stdlib.True))
        AhkTest.AssertEqual(0, stdlib.array.array("i", [10, 20, 10, 20]).index(10, stdlib.False))

        AhkTest.AssertEqual([7, 8], stdlib.operator.mul(stdlib.array.array("i", [7, 8]), stdlib.True).tolist())
        AhkTest.AssertEqual([], stdlib.operator.mul(stdlib.array.array("i", [7, 8]), stdlib.False).tolist())
    }

    static TestArrayRootBoolSearchAndRemoveMatchLocal310()
    {
        AhkTest.AssertEqual(2, stdlib.array.array("i", [0, 1, 1, 2]).count(stdlib.True))
        AhkTest.AssertEqual(2, stdlib.array.array("i", [0, 1, 0, 2]).count(stdlib.False))
        AhkTest.AssertEqual(2, stdlib.array.array("i", [0, 2, 1, 1]).index(stdlib.True))
        AhkTest.AssertEqual(2, stdlib.array.array("i", [1, 2, 0, 0]).index(stdlib.False))

        removeTrue := stdlib.array.array("i", [0, 1, 2, 1])
        AhkTest.AssertSame(stdlib.None, removeTrue.remove(stdlib.True))
        AhkTest.AssertEqual([0, 2, 1], removeTrue.tolist())

        removeFalse := stdlib.array.array("i", [0, 1, 0, 2])
        AhkTest.AssertSame(stdlib.None, removeFalse.remove(stdlib.False))
        AhkTest.AssertEqual([1, 0, 2], removeFalse.tolist())

        AhkTest.AssertEqual(1, stdlib.array.array("d", [0.0, 1.0, 1.5]).count(stdlib.True))
        AhkTest.AssertEqual(1, stdlib.array.array("d", [1.0, 0.0, 2.0]).index(stdlib.False))
        removeFloatTrue := stdlib.array.array("d", [1.0, 2.0])
        AhkTest.AssertSame(stdlib.None, removeFloatTrue.remove(stdlib.True))
        AhkTest.AssertEqual([2.0], removeFloatTrue.tolist())

        AhkTest.AssertTrue(stdlib.operator.contains(stdlib.array.array("i", [0, 1, 2]), stdlib.True))
        AhkTest.AssertTrue(stdlib.operator.contains(stdlib.array.array("i", [1, 0, 2]), stdlib.False))

        unicodeValues := stdlib.array.array("u", Chr(1) Chr(0))
        AhkTest.AssertEqual(0, unicodeValues.count(stdlib.True))
        AhkTest.AssertFalse(stdlib.operator.contains(stdlib.array.array("u", Chr(0)), stdlib.False))
        AhkTest.RaisesMatch(ValueError, "^array\.index\(x\): x not in array$", (*) => unicodeValues.index(stdlib.True))
    }

    static TestArrayIntegerTypecodesRejectOutOfRangeValuesLikeLocal310()
    {
        AhkTest.AssertEqual([-128, 127], stdlib.array.array("b", [-128, 127]).tolist())
        AhkTest.AssertEqual([0, 255], stdlib.array.array("B", [0, 255]).tolist())
        AhkTest.AssertEqual([-32768, 32767], stdlib.array.array("h", [-32768, 32767]).tolist())
        AhkTest.AssertEqual([0, 65535], stdlib.array.array("H", [0, 65535]).tolist())
        AhkTest.AssertEqual([-2147483648, 2147483647], stdlib.array.array("i", [-2147483648, 2147483647]).tolist())
        AhkTest.AssertEqual([0, 4294967295], stdlib.array.array("I", [0, 4294967295]).tolist())

        AhkTest.RaisesMatch(Error, "^signed char is less than minimum$", (*) => stdlib.array.array("b", [-129]))
        AhkTest.RaisesMatch(Error, "^signed char is greater than maximum$", (*) => stdlib.array.array("b", [128]))
        AhkTest.RaisesMatch(Error, "^unsigned byte integer is less than minimum$", (*) => stdlib.array.array("B", [-1]))
        AhkTest.RaisesMatch(Error, "^unsigned byte integer is greater than maximum$", (*) => stdlib.array.array("B", [256]))
        AhkTest.RaisesMatch(Error, "^signed short integer is less than minimum$", (*) => stdlib.array.array("h", [-32769]))
        AhkTest.RaisesMatch(Error, "^signed short integer is greater than maximum$", (*) => stdlib.array.array("h", [32768]))
        AhkTest.RaisesMatch(Error, "^unsigned short is less than minimum$", (*) => stdlib.array.array("H", [-1]))
        AhkTest.RaisesMatch(Error, "^unsigned short is greater than maximum$", (*) => stdlib.array.array("H", [65536]))
        AhkTest.RaisesMatch(Error, "^Python int too large to convert to C long$", (*) => stdlib.array.array("i", [2147483648]))
        AhkTest.RaisesMatch(Error, "^can't convert negative value to unsigned int$", (*) => stdlib.array.array("I", [-1]))
        AhkTest.RaisesMatch(Error, "^Python int too large to convert to C unsigned long$", (*) => stdlib.array.array("I", [4294967296]))
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

    static TestArrayReadonlyAttributesAndFromfileEofMatchLocal310()
    {
        values := stdlib.array.array("i", [1, 2])
        AhkTest.RaisesMatch(stdlib.AttributeError, "^attribute 'typecode' of 'array\.array' objects is not writable$", (*) => StdlibArrayTest.SetTypecode(values, "h"))
        AhkTest.RaisesMatch(stdlib.AttributeError, "^attribute 'itemsize' of 'array\.array' objects is not writable$", (*) => StdlibArrayTest.SetItemsize(values, 8))
        AhkTest.AssertEqual("i", values.typecode)
        AhkTest.AssertEqual(4, values.itemsize)

        oneItemPath := A_Temp "\stdlib-array-fromfile-one-" A_TickCount "-" Random(100000, 999999) ".bin"
        byteRemainderPath := A_Temp "\stdlib-array-fromfile-byte-" A_TickCount "-" Random(100000, 999999) ".bin"
        try {
            StdlibArrayTest.WriteIntBytes(oneItemPath, [1])
            partial := stdlib.array.array("i", [99])
            try {
                partial.fromfile(oneItemPath, 2)
                AhkTest.Fail("fromfile should raise EOFError when fewer items are available")
            } catch Error as err {
                AhkTest.AssertTrue(err is stdlib.EOFError)
                AhkTest.AssertEqual("read() didn't return enough bytes", err.Message)
            }
            AhkTest.AssertEqual([99, 1], partial.tolist())

            StdlibArrayTest.WriteIntBytes(byteRemainderPath, [1], Buffer(1, 0x5A))
            invalid := stdlib.array.array("i", [99])
            AhkTest.RaisesMatch(ValueError, "^bytes length not a multiple of item size$", (*) => invalid.fromfile(byteRemainderPath, 2))
            AhkTest.AssertEqual([99], invalid.tolist())
        } finally {
            if FileExist(oneItemPath)
                FileDelete oneItemPath
            if FileExist(byteRemainderPath)
                FileDelete byteRemainderPath
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

    static TestArrayInplaceSpecialMethodsMatchLocal310()
    {
        iaddValues := stdlib.array.array("i", [1, 2])
        iaddResult := iaddValues.__iadd(stdlib.array.array("i", [3, 4]))
        AhkTest.AssertTrue(iaddResult == iaddValues)
        AhkTest.AssertEqual([1, 2, 3, 4], iaddValues.tolist())
        AhkTest.AssertEqual("array('i', [1, 2, 3, 4])", iaddValues.__Repr())
        AhkTest.RaisesMatch(TypeError, "^can only extend with array of same kind$", (*) => stdlib.array.array("i", [1]).__iadd(stdlib.array.array("h", [2])))
        AhkTest.RaisesMatch(TypeError, "^can only extend array with array \(not `"list`"\)$", (*) => stdlib.array.array("i", [1]).__iadd([2]))

        imulValues := stdlib.array.array("i", [1, 2])
        imulResult := imulValues.__imul(3)
        AhkTest.AssertTrue(imulResult == imulValues)
        AhkTest.AssertEqual([1, 2, 1, 2, 1, 2], imulValues.tolist())
        AhkTest.AssertEqual("array('i', [1, 2, 1, 2, 1, 2])", imulValues.__Repr())

        zeroValues := stdlib.array.array("i", [1, 2])
        zeroResult := zeroValues.__imul(0)
        AhkTest.AssertTrue(zeroResult == zeroValues)
        AhkTest.AssertEqual([], zeroValues.tolist())
        AhkTest.AssertEqual("array('i')", zeroValues.__Repr())

        trueValues := stdlib.array.array("i", [1, 2])
        AhkTest.AssertTrue(trueValues.__imul(stdlib.True) == trueValues)
        AhkTest.AssertEqual([1, 2], trueValues.tolist())
        falseValues := stdlib.array.array("i", [1, 2])
        AhkTest.AssertTrue(falseValues.__imul(stdlib.False) == falseValues)
        AhkTest.AssertEqual([], falseValues.tolist())
        AhkTest.RaisesMatch(TypeError, "^'float' object cannot be interpreted as an integer$", (*) => stdlib.array.array("i", [1]).__imul(1.5))

        rmulSource := stdlib.array.array("i", [1, 2])
        rmulResult := rmulSource.__rmul(2)
        AhkTest.AssertTrue(rmulResult != rmulSource)
        AhkTest.AssertEqual([1, 2], rmulSource.tolist())
        AhkTest.AssertEqual([1, 2, 1, 2], rmulResult.tolist())
        AhkTest.AssertEqual("array('i', [1, 2, 1, 2])", rmulResult.__Repr())
    }

    static TestArrayCopyAndDeepcopyProduceIndependentArraysLikeLocal310()
    {
        source := stdlib.array.array("i", [1, 2, 3])
        shallow := stdlib.copy.copy(source)
        deep := stdlib.copy.deepcopy(source)

        AhkTest.AssertTrue(shallow !== source)
        AhkTest.AssertTrue(deep !== source)
        AhkTest.AssertEqual("i", shallow.typecode)
        AhkTest.AssertEqual("i", deep.typecode)
        AhkTest.AssertEqual(4, shallow.itemsize)
        AhkTest.AssertEqual(4, deep.itemsize)

        shallow[0] := 10
        AhkTest.AssertSame(stdlib.None, deep.append(4))

        AhkTest.AssertEqual([1, 2, 3], source.tolist())
        AhkTest.AssertEqual([10, 2, 3], shallow.tolist())
        AhkTest.AssertEqual([1, 2, 3, 4], deep.tolist())

        sameTypecode := stdlib.array.array("i", [7, 8])
        sameTypecodeDeep := stdlib.copy.deepcopy(sameTypecode)
        sameTypecodeDeep[1] := 80
        AhkTest.AssertEqual([7, 8], sameTypecode.tolist())
        AhkTest.AssertEqual([7, 80], sameTypecodeDeep.tolist())
    }

    static TestArraySliceGetSetAndDeleteUseStdlibSliceLikeLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3, 4, 5])
        AhkTest.AssertEqual([2, 3, 4], values[stdlib.slice(1, 4)].tolist())
        AhkTest.AssertEqual([1, 3, 5], values[stdlib.slice(stdlib.None, stdlib.None, 2)].tolist())
        AhkTest.AssertEqual([5, 4, 3, 2, 1], values[stdlib.slice(stdlib.None, stdlib.None, -1)].tolist())
        AhkTest.AssertEqual([2, 3, 4], values[stdlib.slice(-4, -1)].tolist())

        simple := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(simple, stdlib.slice(1, 3), stdlib.array.array("i", [20, 30]))
        AhkTest.AssertEqual([1, 20, 30, 4], simple.tolist())

        resized := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(resized, stdlib.slice(1, 3), stdlib.array.array("i", [20, 30, 40]))
        AhkTest.AssertEqual([1, 20, 30, 40, 4], resized.tolist())

        stepped := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(stepped, stdlib.slice(stdlib.None, stdlib.None, 2), stdlib.array.array("i", [9, 8]))
        AhkTest.AssertEqual([9, 2, 8, 4], stepped.tolist())

        deleted := stdlib.array.array("i", [1, 2, 3, 4, 5])
        AhkTest.AssertSame(stdlib.None, deleted.Delete(stdlib.slice(1, 4)))
        AhkTest.AssertEqual([1, 5], deleted.tolist())

        deletedStep := stdlib.array.array("i", [1, 2, 3, 4, 5])
        AhkTest.AssertSame(stdlib.None, deletedStep.Delete(stdlib.slice(stdlib.None, stdlib.None, 2)))
        AhkTest.AssertEqual([2, 4], deletedStep.tolist())

        AhkTest.RaisesMatch(TypeError, "^bad argument type for built-in operation$", (*) => StdlibArrayTest.AssignSlice(stdlib.array.array("i", [1, 2]), stdlib.slice(0, 1), stdlib.array.array("h", [9])))
        AhkTest.RaisesMatch(TypeError, "^can only assign array \(not `"list`"\) to array slice$", (*) => StdlibArrayTest.AssignSlice(stdlib.array.array("i", [1, 2]), stdlib.slice(0, 1), [9]))
        AhkTest.RaisesMatch(ValueError, "^attempt to assign array of size 1 to extended slice of size 2$", (*) => StdlibArrayTest.AssignSlice(stdlib.array.array("i", [1, 2, 3, 4]), stdlib.slice(stdlib.None, stdlib.None, 2), stdlib.array.array("i", [9])))
        AhkTest.RaisesMatch(ValueError, "^slice step cannot be zero$", (*) => stdlib.array.array("i", [1, 2, 3])[stdlib.slice(stdlib.None, stdlib.None, 0)])
    }

    static TestArraySliceWorksThroughOperatorItemHelpersLikeLocal310()
    {
        values := stdlib.array.array("i", [1, 2, 3, 4, 5])
        AhkTest.AssertEqual([2, 3, 4], stdlib.operator.getitem(values, stdlib.slice(1, 4)).tolist())

        setitemTarget := stdlib.array.array("i", [1, 2, 3, 4])
        stdlib.operator.setitem(setitemTarget, stdlib.slice(1, 3), stdlib.array.array("i", [20, 30, 40]))
        AhkTest.AssertEqual([1, 20, 30, 40, 4], setitemTarget.tolist())

        delitemTarget := stdlib.array.array("i", [1, 2, 3, 4, 5])
        stdlib.operator.delitem(delitemTarget, stdlib.slice(stdlib.None, stdlib.None, 2))
        AhkTest.AssertEqual([2, 4], delitemTarget.tolist())
    }

    static TestArraySliceAssignmentUsesRhsSnapshotLikeLocal310()
    {
        reverseSelf := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(reverseSelf, stdlib.slice(stdlib.None, stdlib.None, -1), reverseSelf)
        AhkTest.AssertEqual([4, 3, 2, 1], reverseSelf.tolist())
        AhkTest.AssertEqual("array('i', [4, 3, 2, 1])", reverseSelf.__Repr())

        contiguousSelf := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(contiguousSelf, stdlib.slice(1, 3), contiguousSelf)
        AhkTest.AssertEqual([1, 1, 2, 3, 4, 4], contiguousSelf.tolist())

        steppedFromSliceCopy := stdlib.array.array("i", [1, 2, 3, 4])
        StdlibArrayTest.AssignSlice(steppedFromSliceCopy, stdlib.slice(stdlib.None, stdlib.None, 2), steppedFromSliceCopy[stdlib.slice(stdlib.None, 2)])
        AhkTest.AssertEqual([1, 2, 2, 4], steppedFromSliceCopy.tolist())
    }

    static BufferHex(bytes)
    {
        text := ""
        loop bytes.Size
            text .= Format("{:02x}", NumGet(bytes, A_Index - 1, "UChar"))
        return text
    }

    static AssignSlice(values, sliceObject, replacement)
    {
        values[sliceObject] := replacement
        return stdlib.None
    }

    static SetItem(values, index, value)
    {
        values[index] := value
        return stdlib.None
    }

    static SetTypecode(values, typecode)
    {
        values.typecode := typecode
        return stdlib.None
    }

    static SetItemsize(values, itemsize)
    {
        values.itemsize := itemsize
        return stdlib.None
    }

    static WriteIntBytes(path, integers, suffix := unset)
    {
        size := integers.Length * 4
        if IsSet(suffix)
            size += suffix.Size
        bytes := Buffer(size, 0)
        offset := 0
        for value in integers {
            NumPut("Int", value, bytes, offset)
            offset += 4
        }
        if IsSet(suffix) && suffix.Size > 0 {
            DllCall("RtlMoveMemory", "Ptr", bytes.Ptr + offset, "Ptr", suffix.Ptr, "UPtr", suffix.Size)
        }
        file := FileOpen(path, "w")
        try {
            file.RawWrite(bytes, bytes.Size)
        } finally {
            file.Close()
        }
    }
}

AhkTest.Test("array typecodes and constructor match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayTypecodesAndConstructorMatchLocal310())
AhkTest.Test("array supports append extend index iteration and buffer_info like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySupportsAppendExtendIndexIterationAndBufferInfoLikeLocal310())
AhkTest.Test("array sequence mutation methods match local 3.10 baseline", (*) => StdlibArrayTest.TestArraySequenceMutationMethodsMatchLocal310())
AhkTest.Test("array index accepts start and stop like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayIndexAcceptsStartAndStopLikeLocal310())
AhkTest.Test("array extend and fromlist input rules match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayExtendAndFromlistInputRulesMatchLocal310())
AhkTest.Test("array append and extend return None like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayAppendAndExtendReturnNoneLikeLocal310())
AhkTest.Test("array string initializer rules match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayStringInitializerRulesMatchLocal310())
AhkTest.Test("array bytes initializer uses raw bytes like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayBytesInitializerUsesRawBytesLikeLocal310())
AhkTest.Test("array extend Buffer iterates bytes like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayExtendBufferIteratesBytesLikeLocal310())
AhkTest.Test("array unicode repr matches local 3.10 baseline", (*) => StdlibArrayTest.TestArrayUnicodeReprMatchesLocal310())
AhkTest.Test("array numeric typecodes accept root bool values like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayNumericTypecodesAcceptRootBoolValuesLikeLocal310())
AhkTest.Test("array root bool indexes and counts match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayRootBoolIndexesAndCountsMatchLocal310())
AhkTest.Test("array root bool search and remove match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayRootBoolSearchAndRemoveMatchLocal310())
AhkTest.Test("array integer typecodes reject out of range values like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayIntegerTypecodesRejectOutOfRangeValuesLikeLocal310())
AhkTest.Test("array rejects observed local 3.10 invalid arguments", (*) => StdlibArrayTest.TestArrayRejectsObservedLocal310InvalidArguments())
AhkTest.Test("array function surface covers binary unicode and file methods", (*) => StdlibArrayTest.TestArrayFunctionSurfaceBinaryUnicodeAndFileMethods())
AhkTest.Test("array readonly attributes and fromfile EOF match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayReadonlyAttributesAndFromfileEofMatchLocal310())
AhkTest.Test("array sequence dunder operations match local 3.10 baseline", (*) => StdlibArrayTest.TestArraySequenceDunderOperationsMatchLocal310())
AhkTest.Test("array inplace special methods match local 3.10 baseline", (*) => StdlibArrayTest.TestArrayInplaceSpecialMethodsMatchLocal310())
AhkTest.Test("array copy and deepcopy produce independent arrays like local 3.10 baseline", (*) => StdlibArrayTest.TestArrayCopyAndDeepcopyProduceIndependentArraysLikeLocal310())
AhkTest.Test("array slice get set and delete use stdlib.slice like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySliceGetSetAndDeleteUseStdlibSliceLikeLocal310())
AhkTest.Test("array slice works through operator item helpers like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySliceWorksThroughOperatorItemHelpersLikeLocal310())
AhkTest.Test("array slice assignment uses RHS snapshot like local 3.10 baseline", (*) => StdlibArrayTest.TestArraySliceAssignmentUsesRhsSnapshotLikeLocal310())

#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\array>
#Include <stdlib\bisect>

class StdlibCollectionsBisectTest
{
    static TestBisectReturnsPythonStyleZeroBasedInsertionPoints()
    {
        cases := [
            { Values: [1, 2, 2, 3], Needle: 2, Left: 1, Right: 3 },
            { Values: [1, 2, 2, 3], Needle: 0, Left: 0, Right: 0 },
            { Values: [1, 2, 2, 3], Needle: 4, Left: 4, Right: 4 },
            { Values: [1, 2, 2, 3], Needle: 2, Lo: 1, Hi: 3, Left: 1, Right: 3 },
        ]

        for row in cases {
            if row.HasOwnProp("Hi") {
                AhkTest.AssertEqual(row.Left, stdlib.bisect.bisect_left(row.Values, row.Needle, row.Lo, row.Hi))
                AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect_right(row.Values, row.Needle, row.Lo, row.Hi))
                AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect(row.Values, row.Needle, row.Lo, row.Hi))
            } else {
                AhkTest.AssertEqual(row.Left, stdlib.bisect.bisect_left(row.Values, row.Needle))
                AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect_right(row.Values, row.Needle))
                AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect(row.Values, row.Needle))
            }
        }
    }

    static TestInsortMutatesArraysUsingPythonOrdering()
    {
        values := [1, 3, 4]
        stdlib.bisect.insort_left(values, 2)
        AhkTest.AssertEqual([1, 2, 3, 4], values)

        leftDupes := [1, 2, 2, 3]
        stdlib.bisect.insort_left(leftDupes, 2)
        AhkTest.AssertEqual([1, 2, 2, 2, 3], leftDupes)

        rightDupes := [1, 2, 2, 3]
        stdlib.bisect.insort_right(rightDupes, 2)
        AhkTest.AssertEqual([1, 2, 2, 2, 3], rightDupes)
    }

    static TestKeyFunctionMatchesPython310Bisect()
    {
        key := (record) => record["size"]
        records := [
            Map("name", "a", "size", 1),
            Map("name", "cc", "size", 2),
            Map("name", "bbb", "size", 3),
        ]

        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left(records, 2, 0, stdlib.None, key))
        AhkTest.AssertEqual(2, stdlib.bisect.bisect_right(records, 2, 0, stdlib.None, key))

        leftRecords := records.Clone()
        stdlib.bisect.insort_left(leftRecords, Map("name", "dd", "size", 2), 0, stdlib.None, key)
        AhkTest.AssertEqual("dd", leftRecords[2]["name"])
        AhkTest.AssertEqual("cc", leftRecords[3]["name"])

        rightRecords := records.Clone()
        stdlib.bisect.insort_right(rightRecords, Map("name", "ee", "size", 2), 0, stdlib.None, key)
        AhkTest.AssertEqual("cc", rightRecords[2]["name"])
        AhkTest.AssertEqual("ee", rightRecords[3]["name"])

        aliasRecords := [1, 3]
        stdlib.bisect.insort(aliasRecords, 2)
        AhkTest.AssertEqual([1, 2, 3], aliasRecords)
    }

    static TestBoundsFollowPythonBisectBehavior()
    {
        AhkTest.RaisesMatch(ValueError, "lo must be non-negative", (*) => stdlib.bisect.bisect_left([1], 1, -1))
        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left([1], 1, 1, 0))
        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left([1, 2, 3], 2, 0, stdlib.None))
        AhkTest.AssertEqual(2, stdlib.bisect.bisect_right([1, 2, 3], 2, 0, stdlib.None))
        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left([1, 2, 3], 2, 0, -1))
        AhkTest.AssertEqual(2, stdlib.bisect.bisect_right([1, 2, 3], 2, 0, -1))
        AhkTest.AssertEqual(0, stdlib.bisect.bisect_left([1, 2, 3], 2, 0, -2))
        AhkTest.AssertEqual(0, stdlib.bisect.bisect_right([1, 2, 3], 2, 0, -2))
    }

    static TestSignatureBoundsAndKeyErrorsMatchLocal310()
    {
        AhkTest.RaisesMatch(IndexError, "^list index out of range$", (*) => stdlib.bisect.bisect_left([1, 2, 3], 2, 0, 99))
        AhkTest.RaisesMatch(TypeError, "^bisect_left\(\) missing required argument 'a' \(pos 1\)$", (*) => stdlib.bisect.bisect_left())
        AhkTest.RaisesMatch(TypeError, "^bisect_left\(\) missing required argument 'x' \(pos 2\)$", (*) => stdlib.bisect.bisect_left([1]))
        AhkTest.RaisesMatch(TypeError, "^bisect_left\(\) takes at most 5 arguments \(6 given\)$", (*) => stdlib.bisect.bisect_left([1], 1, 0, stdlib.None, stdlib.None, "extra"))
        AhkTest.RaisesMatch(TypeError, "^'NoneType' object cannot be interpreted as an integer$", (*) => stdlib.bisect.bisect_left([1], 1, stdlib.None))
        AhkTest.RaisesMatch(TypeError, "^'int' object is not callable$", (*) => stdlib.bisect.bisect_left([1], 1, 0, stdlib.None, 1))

        values := [1, 2, 2, 3]
        AhkTest.AssertEqual(stdlib.None, stdlib.bisect.insort_right(values, 2, 0, stdlib.None))
        AhkTest.AssertEqual([1, 2, 2, 2, 3], values)
        AhkTest.RaisesMatch(TypeError, "^insort_right\(\) takes at most 5 arguments \(6 given\)$", (*) => stdlib.bisect.insort_right([1, 2, 2, 3], 2, 0, stdlib.None, stdlib.None, "extra"))
    }

    static TestSequenceProtocolAndInsertTargetsMatchLocal310()
    {
        arrayValues := stdlib.array.array("i", [1, 2, 2, 3])
        arrayInsert := stdlib.array.array("i", [1, 3])

        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left(arrayValues, 2))
        AhkTest.AssertEqual(3, stdlib.bisect.bisect_right(arrayValues, 2))
        AhkTest.AssertSame(stdlib.None, stdlib.bisect.insort_left(arrayInsert, 2))
        AhkTest.AssertEqual([1, 2, 3], arrayInsert.tolist())

        sequenceLeft := StdlibBisectProtocolSequence([1, 2, 2, 3])
        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left(sequenceLeft, 2))
        AhkTest.AssertEqual([["len"], ["getitem", 2], ["getitem", 1], ["getitem", 0]], sequenceLeft.Events)

        sequenceRight := StdlibBisectProtocolSequence([1, 2, 2, 3])
        AhkTest.AssertEqual(3, stdlib.bisect.bisect_right(sequenceRight, 2))
        AhkTest.AssertEqual([["len"], ["getitem", 2], ["getitem", 3]], sequenceRight.Events)

        insertLeft := StdlibBisectInsertProtocolSequence([1, 2, 2, 3])
        AhkTest.AssertSame(stdlib.None, stdlib.bisect.insort_left(insertLeft, 2))
        AhkTest.AssertEqual([1, 2, 2, 2, 3], insertLeft.Values)
        AhkTest.AssertEqual([["len"], ["getitem", 2], ["getitem", 1], ["getitem", 0], ["insert", 1, 2]], insertLeft.Events)

        insertRight := StdlibBisectInsertProtocolSequence([1, 2, 2, 3])
        AhkTest.AssertSame(stdlib.None, stdlib.bisect.insort_right(insertRight, 2))
        AhkTest.AssertEqual([1, 2, 2, 2, 3], insertRight.Values)
        AhkTest.AssertEqual([["len"], ["getitem", 2], ["getitem", 3], ["insert", 3, 2]], insertRight.Events)

        AhkTest.RaisesMatch(stdlib.AttributeError, "^'StdlibBisectProtocolSequence' object has no attribute 'insert'$", (*) => stdlib.bisect.insort_left(StdlibBisectProtocolSequence([1, 3]), 2))
    }
}

class StdlibBisectProtocolSequence
{
    __New(values)
    {
        this.Values := values.Clone()
        this.Events := []
    }

    __Len
    {
        get {
            this.Events.Push(["len"])
            return this.Values.Length
        }
    }

    __Item[index]
    {
        get {
            this.Events.Push(["getitem", index])
            return this.Values[index + 1]
        }
    }
}

class StdlibBisectInsertProtocolSequence extends StdlibBisectProtocolSequence
{
    insert(index, value)
    {
        this.Events.Push(["insert", index, value])
        this.Values.InsertAt(index + 1, value)
        return stdlib.None
    }
}

AhkTest.Collect(StdlibCollectionsBisectTest)

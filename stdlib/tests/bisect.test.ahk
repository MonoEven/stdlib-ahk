#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
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
            lo := row.HasOwnProp("Lo") ? row.Lo : 0
            hi := row.HasOwnProp("Hi") ? row.Hi : ""

            AhkTest.AssertEqual(row.Left, stdlib.bisect.bisect_left(row.Values, row.Needle, lo, hi))
            AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect_right(row.Values, row.Needle, lo, hi))
            AhkTest.AssertEqual(row.Right, stdlib.bisect.bisect(row.Values, row.Needle, lo, hi))
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

        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left(records, 2, 0, "", key))
        AhkTest.AssertEqual(2, stdlib.bisect.bisect_right(records, 2, 0, "", key))

        leftRecords := records.Clone()
        stdlib.bisect.insort_left(leftRecords, Map("name", "dd", "size", 2), 0, "", key)
        AhkTest.AssertEqual("dd", leftRecords[2]["name"])
        AhkTest.AssertEqual("cc", leftRecords[3]["name"])

        rightRecords := records.Clone()
        stdlib.bisect.insort_right(rightRecords, Map("name", "ee", "size", 2), 0, "", key)
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
        AhkTest.AssertEqual(1, stdlib.bisect.bisect_left([1, 2, 3], 2, 0, -1))
        AhkTest.AssertEqual(2, stdlib.bisect.bisect_right([1, 2, 3], 2, 0, -1))
        AhkTest.AssertEqual(0, stdlib.bisect.bisect_left([1, 2, 3], 2, 0, -2))
        AhkTest.AssertEqual(0, stdlib.bisect.bisect_right([1, 2, 3], 2, 0, -2))
    }
}

AhkTest.Collect(StdlibCollectionsBisectTest)

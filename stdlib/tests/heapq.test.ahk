#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\heapq>

class StdlibHeapqTest
{
    static TestHeappushAndHeappopMaintainMinHeap()
    {
        heap := []

        stdlib.heapq.heappush(heap, 3)
        stdlib.heapq.heappush(heap, 1)
        stdlib.heapq.heappush(heap, 2)

        AhkTest.AssertEqual(1, heap[1])
        AhkTest.AssertEqual(1, stdlib.heapq.heappop(heap))
        AhkTest.AssertEqual(2, stdlib.heapq.heappop(heap))
        AhkTest.AssertEqual(3, stdlib.heapq.heappop(heap))
        AhkTest.AssertEqual(0, heap.Length)
    }

    static TestHeapifyTransformsArrayInPlace()
    {
        values := [5, 1, 3, 1]

        stdlib.heapq.heapify(values)

        AhkTest.AssertEqual(1, values[1])
        AhkTest.AssertEqual([1, 1, 3, 5], [
            stdlib.heapq.heappop(values),
            stdlib.heapq.heappop(values),
            stdlib.heapq.heappop(values),
            stdlib.heapq.heappop(values)
        ])
    }

    static TestEmptyHeapOperationsFollowPythonErrors()
    {
        AhkTest.RaisesMatch(IndexError, "index out of range", (*) => stdlib.heapq.heappop([]))
        AhkTest.RaisesMatch(IndexError, "index out of range", (*) => stdlib.heapq.heapreplace([], 1))
    }

    static TestHeapreplaceReturnsPreviousSmallestEvenWhenNewItemIsSmaller()
    {
        heap := [2, 5, 9]

        returned := stdlib.heapq.heapreplace(heap, 1)

        AhkTest.AssertEqual(2, returned)
        AhkTest.AssertEqual([1, 5, 9], [
            stdlib.heapq.heappop(heap),
            stdlib.heapq.heappop(heap),
            stdlib.heapq.heappop(heap)
        ])
    }

    static TestHeappushpopMatchesPythonFastPath()
    {
        empty := []
        AhkTest.AssertEqual(5, stdlib.heapq.heappushpop(empty, 5))
        AhkTest.AssertEqual([], empty)

        smaller := [2, 4]
        AhkTest.AssertEqual(1, stdlib.heapq.heappushpop(smaller, 1))
        AhkTest.AssertEqual([2, 4], smaller)

        larger := [2, 4]
        AhkTest.AssertEqual(2, stdlib.heapq.heappushpop(larger, 3))
        AhkTest.AssertEqual([3, 4], [
            stdlib.heapq.heappop(larger),
            stdlib.heapq.heappop(larger)
        ])
    }

    static TestHeapFunctionsRequireAhkArraysAsPythonLists()
    {
        AhkTest.RaisesMatch(TypeError, "heappush\(\) argument 1 must be list", (*) => stdlib.heapq.heappush(Map(), 1))
        AhkTest.RaisesMatch(TypeError, "heapify\(\) argument must be list", (*) => stdlib.heapq.heapify(Map()))
    }

    static TestNlargestAndNsmallestFollowPython()
    {
        AhkTest.AssertEqual([42, 37, 23], stdlib.heapq.nlargest(3, [1, 23, 12, 42, 37, 4]))
        AhkTest.AssertEqual([-4, 1, 2], stdlib.heapq.nsmallest(3, [1, 23, -4, 2, 42]))
        AhkTest.AssertEqual([], stdlib.heapq.nlargest(0, [1, 2, 3]))
        AhkTest.AssertEqual([3, 2, 1], stdlib.heapq.nlargest(5, [3, 1, 2]))
    }

    static TestNlargestWithKeyFollowsPython()
    {
        words := ["a", "bbb", "cc", "dddd"]
        lengthKey := (w) => StrLen(w)

        AhkTest.AssertEqual(["dddd", "bbb"], stdlib.heapq.nlargest(2, words, lengthKey))
        AhkTest.AssertEqual(["a", "cc"], stdlib.heapq.nsmallest(2, words, lengthKey))
    }

    static TestMergeCombinesSortedInputs()
    {
        AhkTest.AssertEqual([1, 2, 3, 4, 5, 6, 7, 8, 9], stdlib.heapq.merge([1, 4, 7], [2, 5, 8], [3, 6, 9]))
        AhkTest.AssertEqual([8, 7, 5, 4, 2, 1], stdlib.heapq.merge([8, 4, 2], [7, 5, 1], { reverse: true }))
    }
}

AhkTest.Collect(StdlibHeapqTest)

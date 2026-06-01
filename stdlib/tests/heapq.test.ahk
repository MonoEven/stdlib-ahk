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
}

AhkTest.Collect(StdlibHeapqTest)

#Requires AutoHotkey v2.0

#Include <stdlib\heapq>

heapq_example_values := []
stdlib.heapq.heappush(heapq_example_values, 3)
stdlib.heapq.heappush(heapq_example_values, 1)
stdlib.heapq.heappush(heapq_example_values, 2)
heapq_example_smallest := stdlib.heapq.heappop(heapq_example_values)

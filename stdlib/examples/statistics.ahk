#Requires AutoHotkey v2.0

#Include <stdlib\statistics>

statistics_example_values := [1, 2, 3, 4, 5]
statistics_example_mean := stdlib.statistics.mean(statistics_example_values)
statistics_example_median := stdlib.statistics.median(statistics_example_values)
statistics_example_stdev := stdlib.statistics.stdev(statistics_example_values)

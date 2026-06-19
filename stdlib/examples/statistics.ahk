#Requires AutoHotkey v2.0

#Include <stdlib\statistics>

statistics_example_values := [1, 2, 3, 4, 5]
statistics_example_mean := stdlib.statistics.mean(statistics_example_values)
statistics_example_median := stdlib.statistics.median(statistics_example_values)
statistics_example_stdev := stdlib.statistics.stdev(statistics_example_values)
statistics_example_grouped_median := stdlib.statistics.median_grouped([1, 2, 2, 3], 1)
statistics_example_covariance := stdlib.statistics.covariance([1, 2, 3], [1, 2, 3])
statistics_example_correlation := stdlib.statistics.correlation([1, 2, 3, 4], [2, 4, 6, 8])
statistics_example_regression := stdlib.statistics.linear_regression([1, 2, 3], [2, 4, 6])
statistics_example_normal := stdlib.statistics.NormalDist.from_samples(statistics_example_values)
statistics_example_normal_mean := statistics_example_normal.mean
statistics_example_normal_cdf := stdlib.statistics.NormalDist(0, 1).cdf(1)

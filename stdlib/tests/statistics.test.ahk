#Requires AutoHotkey v2.0

#Include <stdlib\ahktest>
#Include <stdlib\statistics>

class StdlibMathStatisticsTest
{
    static TestMeansAndMediansFollowPythonStatistics()
    {
        AhkTest.AssertEqual(2.5, stdlib.statistics.mean([1, 2, 4, 3]))
        AhkTest.AssertEqual(2.5, stdlib.statistics.fmean([1, 2, 4, 3]))
        AhkTest.AssertEqual(2, stdlib.statistics.median([3, 1, 2]))
        AhkTest.AssertEqual(2.5, stdlib.statistics.median([4, 1, 2, 3]))
        AhkTest.AssertEqual(2, stdlib.statistics.median_low([4, 1, 2, 3]))
        AhkTest.AssertEqual(3, stdlib.statistics.median_high([4, 1, 2, 3]))
    }

    static TestMediansDoNotMutateInput()
    {
        values := [4, 1, 2, 3]

        AhkTest.AssertEqual(2.5, stdlib.statistics.median(values))

        AhkTest.AssertEqual([4, 1, 2, 3], values)
    }

    static TestModeAndMultimodeFollowFirstEncounterOrder()
    {
        AhkTest.AssertEqual("a", stdlib.statistics.mode(["a", "b", "a", "c", "b"]))
        AhkTest.AssertEqual(["a", "b"], stdlib.statistics.multimode(["a", "b", "a", "c", "b"]))
        AhkTest.AssertEqual(1, stdlib.statistics.mode([1, 1, 2, 2]))
        AhkTest.AssertEqual([1, 2], stdlib.statistics.multimode([1, 1, 2, 2]))
        AhkTest.AssertEqual([], stdlib.statistics.multimode([]))
    }

    static TestVarianceAndStandardDeviationFollowPythonStatistics()
    {
        values := [1, 2, 3, 4, 5]

        AhkTest.AssertEqual(2, stdlib.statistics.pvariance(values))
        AhkTest.AssertEqual(2.5, stdlib.statistics.variance(values))
        AhkTest.AssertApprox(1.4142135623730951, stdlib.statistics.pstdev(values))
        AhkTest.AssertApprox(1.5811388300841898, stdlib.statistics.stdev(values))
    }

    static TestVarianceFunctionsAcceptKnownMean()
    {
        values := [1, 2, 3]

        AhkTest.AssertApprox(0.6666666666666666, stdlib.statistics.pvariance(values, 2))
        AhkTest.AssertEqual(1, stdlib.statistics.variance(values, 2))
        AhkTest.AssertApprox(0.816496580927726, stdlib.statistics.pstdev(values, 2))
        AhkTest.AssertEqual(1.0, stdlib.statistics.stdev(values, 2))
        AhkTest.AssertApprox(9604.666666666666, stdlib.statistics.pvariance(values, 100))
        AhkTest.AssertEqual(14407, stdlib.statistics.variance(values, 100))
    }

    static TestStatisticsAcceptsEnumerableData()
    {
        AhkTest.AssertEqual(2, stdlib.statistics.mean(StdlibMathStatisticsEnumerable([1, 2, 3])))
        AhkTest.AssertEqual(2.0, stdlib.statistics.fmean(StdlibMathStatisticsEnumerable([1, 2, 3])))
        AhkTest.AssertEqual(2.5, stdlib.statistics.median(StdlibMathStatisticsEnumerable([4, 1, 2, 3])))
        AhkTest.AssertEqual(2, stdlib.statistics.median_low(StdlibMathStatisticsEnumerable([4, 1, 2, 3])))
        AhkTest.AssertEqual(3, stdlib.statistics.median_high(StdlibMathStatisticsEnumerable([4, 1, 2, 3])))
        AhkTest.AssertEqual("a", stdlib.statistics.mode(StdlibMathStatisticsEnumerable(["a", "b", "a", "b"])))
        AhkTest.AssertEqual(["a", "b"], stdlib.statistics.multimode(StdlibMathStatisticsEnumerable(["a", "b", "a", "b"])))
        AhkTest.AssertApprox(0.6666666666666666, stdlib.statistics.pvariance(StdlibMathStatisticsEnumerable([1, 2, 3])))
        AhkTest.AssertEqual(1, stdlib.statistics.variance(StdlibMathStatisticsEnumerable([1, 2, 3])))
        AhkTest.AssertApprox(0.816496580927726, stdlib.statistics.pstdev(StdlibMathStatisticsEnumerable([1, 2, 3])))
        AhkTest.AssertEqual(1.0, stdlib.statistics.stdev(StdlibMathStatisticsEnumerable([1, 2, 3])))
    }

    static TestNonIterableDataRaisesTypeError()
    {
        AhkTest.RaisesMatch(TypeError, "'Integer' object is not iterable", (*) => stdlib.statistics.mean(42))
    }

    static TestEmptyAndSingletonErrorsUseStatisticsError()
    {
        errorType := stdlib.statistics.StatisticsError

        AhkTest.RaisesMatch(errorType, "mean requires at least one data point", (*) => stdlib.statistics.mean([]))
        AhkTest.RaisesMatch(errorType, "fmean requires at least one data point", (*) => stdlib.statistics.fmean([]))
        AhkTest.RaisesMatch(errorType, "no median for empty data", (*) => stdlib.statistics.median([]))
        AhkTest.RaisesMatch(errorType, "no median for empty data", (*) => stdlib.statistics.median_low([]))
        AhkTest.RaisesMatch(errorType, "no median for empty data", (*) => stdlib.statistics.median_high([]))
        AhkTest.RaisesMatch(errorType, "no mode for empty data", (*) => stdlib.statistics.mode([]))
        AhkTest.RaisesMatch(errorType, "pvariance requires at least one data point", (*) => stdlib.statistics.pvariance([]))
        AhkTest.RaisesMatch(errorType, "variance requires at least two data points", (*) => stdlib.statistics.variance([1]))
        AhkTest.RaisesMatch(errorType, "variance requires at least two data points", (*) => stdlib.statistics.stdev([1]))
    }

    static TestGeometricMeanFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(4.0, stdlib.statistics.geometric_mean([2, 8]))
        AhkTest.AssertApprox(36.0, stdlib.statistics.geometric_mean([54, 24]))
        AhkTest.RaisesMatch(stdlib.statistics.StatisticsError, "geometric_mean requires positive numbers", (*) => stdlib.statistics.geometric_mean([1, 0, 4]))
    }

    static TestHarmonicMeanFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(3.0, stdlib.statistics.harmonic_mean([2, 3, 6]))
        AhkTest.AssertApprox(65.88235294117646, stdlib.statistics.harmonic_mean([40, 60, 80], [5, 30, 35]))
        AhkTest.AssertEqual(0, stdlib.statistics.harmonic_mean([2, 0, 4]))
    }

    static TestQuantilesFollowsPythonStatistics()
    {
        AhkTest.AssertEqual([2.75, 5.5, 8.25], stdlib.statistics.quantiles([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]))
        AhkTest.AssertEqual([2.0, 3.0, 4.0], stdlib.statistics.quantiles([1, 2, 3, 4, 5], { method: "inclusive" }))
    }

    static TestQuickSortMatchesPythonOrderingForLargeInput()
    {
        values := []
        loop 500
            values.Push(Mod(A_Index * 137, 500))
        AhkTest.AssertEqual(0, stdlib.statistics.median([0]))
        AhkTest.AssertApprox(249.5, stdlib.statistics.median(values))
    }

    static TestMedianGroupedFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(4.166666666666667, stdlib.statistics.median_grouped([1, 2, 2, 3, 4, 4, 4, 5, 5, 5, 5, 5]))
        AhkTest.AssertApprox(52.5, stdlib.statistics.median_grouped([52, 52, 53, 54]))
        AhkTest.AssertApprox(3.5, stdlib.statistics.median_grouped([1, 3, 3, 5, 7], 2))
        AhkTest.AssertEqual(5, stdlib.statistics.median_grouped([5]))
    }

    static TestCovarianceFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(1.0, stdlib.statistics.covariance([1, 2, 3], [1, 2, 3]))
        AhkTest.AssertApprox(0.75, stdlib.statistics.covariance([1, 2, 3, 4, 5, 6, 7, 8, 9], [1, 2, 3, 1, 2, 3, 1, 2, 3]))
    }

    static TestCorrelationFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(1.0, stdlib.statistics.correlation([1, 2, 3, 4], [2, 4, 6, 8]))
        AhkTest.AssertApprox(-0.7426106572325056, stdlib.statistics.correlation([1, 2, 3, 4, 5], [10, 9, 2.5, 6, 4]))
    }

    static TestLinearRegressionFollowsPythonStatistics()
    {
        result := stdlib.statistics.linear_regression([1, 2, 3], [2, 4, 6])
        AhkTest.AssertApprox(2.0, result[1])
        AhkTest.AssertApprox(0.0, result[2])

        result2 := stdlib.statistics.linear_regression([1, 2, 3, 4, 5], [2, 1, 4, 3, 5])
        AhkTest.AssertApprox(0.8, result2[1])
        AhkTest.AssertApprox(0.5999999999999996, result2[2])
    }

    static TestStatisticsPairwiseErrors()
    {
        errorType := stdlib.statistics.StatisticsError

        AhkTest.RaisesMatch(errorType, "covariance requires that both inputs have same number of data points", (*) => stdlib.statistics.covariance([1, 2, 3], [1, 2]))
        AhkTest.RaisesMatch(errorType, "covariance requires at least two data points", (*) => stdlib.statistics.covariance([1], [1]))
        AhkTest.RaisesMatch(errorType, "correlation requires that both inputs have same number of data points", (*) => stdlib.statistics.correlation([1, 2, 3], [1, 2]))
        AhkTest.RaisesMatch(errorType, "correlation requires at least two data points", (*) => stdlib.statistics.correlation([1], [1]))
        AhkTest.RaisesMatch(errorType, "at least one of the inputs is constant", (*) => stdlib.statistics.correlation([1, 2, 3], [5, 5, 5]))
        AhkTest.RaisesMatch(errorType, "linear regression requires at least two data points", (*) => stdlib.statistics.linear_regression([1], [1]))
        AhkTest.RaisesMatch(errorType, "x is constant", (*) => stdlib.statistics.linear_regression([5, 5, 5], [1, 2, 3]))
    }

    static TestNormalDistPropertiesFollowPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist(2, 3)
        AhkTest.AssertEqual(2.0, nd.mean)
        AhkTest.AssertEqual(2.0, nd.median)
        AhkTest.AssertEqual(2.0, nd.mode)
        AhkTest.AssertEqual(3.0, nd.stdev)
        AhkTest.AssertEqual(9.0, nd.variance)

        std := stdlib.statistics.NormalDist()
        AhkTest.AssertEqual(0.0, std.mean)
        AhkTest.AssertEqual(1.0, std.stdev)
    }

    static TestNormalDistRejectsNegativeSigma()
    {
        AhkTest.RaisesMatch(stdlib.statistics.StatisticsError, "sigma must be non-negative", (*) => stdlib.statistics.NormalDist(0, -1))
    }

    static TestNormalDistCdfFollowsPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist(0, 1)
        AhkTest.AssertApprox(0.5, nd.cdf(0))
        AhkTest.AssertApprox(0.9750021048517796, nd.cdf(1.96))
        AhkTest.AssertApprox(0.8413447460685428, stdlib.statistics.NormalDist(2, 3).cdf(5))
    }

    static TestNormalDistPdfFollowsPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist(0, 1)
        AhkTest.AssertApprox(0.3989422804014327, nd.pdf(0))
        AhkTest.AssertApprox(0.1329807601338109, stdlib.statistics.NormalDist(2, 3).pdf(2))
    }

    static TestNormalDistInvCdfFollowsPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist(0, 1)
        AhkTest.AssertApprox(1.9599639845400536, nd.inv_cdf(0.975))
        AhkTest.AssertApprox(-0.6744897501960817, nd.inv_cdf(0.25))
        AhkTest.AssertApprox(5.844654696633802, stdlib.statistics.NormalDist(2, 3).inv_cdf(0.9))
        ; round trip cdf(inv_cdf(p)) == p
        AhkTest.AssertApprox(0.123, nd.cdf(nd.inv_cdf(0.123)))
        ; deep tail exercises the r > 5 branch
        AhkTest.AssertApprox(-7.034483825301132, nd.inv_cdf(1e-12), { rel: 1e-6 })
    }

    static TestNormalDistInvCdfRejectsOutOfRange()
    {
        nd := stdlib.statistics.NormalDist(0, 1)
        AhkTest.RaisesMatch(stdlib.statistics.StatisticsError, "p must be in the range", (*) => nd.inv_cdf(0))
        AhkTest.RaisesMatch(stdlib.statistics.StatisticsError, "p must be in the range", (*) => nd.inv_cdf(1))
    }

    static TestNormalDistQuantilesFollowPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist(0, 1)
        q := nd.quantiles()
        AhkTest.AssertEqual(3, q.Length)
        AhkTest.AssertApprox(-0.6744897501960817, q[1])
        AhkTest.AssertApprox(0.0, q[2])
        AhkTest.AssertApprox(0.6744897501960817, q[3])

        q2 := stdlib.statistics.NormalDist(2, 3).quantiles()
        AhkTest.AssertApprox(-0.023469250588245227, q2[1])
        AhkTest.AssertApprox(2.0, q2[2])
        AhkTest.AssertApprox(4.023469250588246, q2[3])
    }

    static TestNormalDistZscoreFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(1.5, stdlib.statistics.NormalDist(0, 1).zscore(1.5))
        AhkTest.AssertApprox(2.0, stdlib.statistics.NormalDist(2, 3).zscore(8))
    }

    static TestNormalDistOverlapFollowsPythonStatistics()
    {
        AhkTest.AssertApprox(0.6170750774519739, stdlib.statistics.NormalDist(0, 1).overlap(stdlib.statistics.NormalDist(1, 1)))
        AhkTest.AssertApprox(0.6773254311652313, stdlib.statistics.NormalDist(0, 1).overlap(stdlib.statistics.NormalDist(0, 2)))
        AhkTest.RaisesMatch(TypeError, "Expected another NormalDist instance", (*) => stdlib.statistics.NormalDist(0, 1).overlap(5))
    }

    static TestNormalDistFromSamplesFollowsPythonStatistics()
    {
        nd := stdlib.statistics.NormalDist.from_samples([1, 2, 3, 4, 5])
        AhkTest.AssertApprox(3.0, nd.mean)
        AhkTest.AssertApprox(1.5811388300841898, nd.stdev)
    }

    static TestNormalDistArithmeticFollowsPythonStatistics()
    {
        a := stdlib.statistics.NormalDist(1, 2)

        scaled := a.scale(3)
        AhkTest.AssertEqual(3.0, scaled.mean)
        AhkTest.AssertEqual(6.0, scaled.stdev)

        translated := a.translate(5)
        AhkTest.AssertEqual(6.0, translated.mean)
        AhkTest.AssertEqual(2.0, translated.stdev)

        added := a.add(5)
        AhkTest.AssertEqual(6.0, added.mean)
        AhkTest.AssertEqual(2.0, added.stdev)

        subbed := a.subtract(1)
        AhkTest.AssertEqual(0.0, subbed.mean)
        AhkTest.AssertEqual(2.0, subbed.stdev)

        divided := stdlib.statistics.NormalDist(6, 4).divide(2)
        AhkTest.AssertEqual(3.0, divided.mean)
        AhkTest.AssertEqual(2.0, divided.stdev)

        sumND := stdlib.statistics.NormalDist(1, 3).add(stdlib.statistics.NormalDist(2, 4))
        AhkTest.AssertApprox(3.0, sumND.mean)
        AhkTest.AssertApprox(5.0, sumND.stdev)

        diffND := stdlib.statistics.NormalDist(5, 3).subtract(stdlib.statistics.NormalDist(2, 4))
        AhkTest.AssertApprox(3.0, diffND.mean)
        AhkTest.AssertApprox(5.0, diffND.stdev)

        negated := a.negate()
        AhkTest.AssertEqual(-1.0, negated.mean)
        AhkTest.AssertEqual(2.0, negated.stdev)
    }

    static TestNormalDistEqualsFollowsPythonStatistics()
    {
        AhkTest.AssertTrue(stdlib.statistics.NormalDist(1, 2).equals(stdlib.statistics.NormalDist(1, 2)))
        AhkTest.AssertFalse(stdlib.statistics.NormalDist(1, 2).equals(stdlib.statistics.NormalDist(1, 3)))
        AhkTest.AssertFalse(stdlib.statistics.NormalDist(1, 2).equals(5))
    }

    static TestNormalDistSamplesAreDeterministicWithSeed()
    {
        nd := stdlib.statistics.NormalDist(10, 2)
        first := nd.samples(50, 42)
        second := nd.samples(50, 42)
        AhkTest.AssertEqual(50, first.Length)
        AhkTest.AssertEqual(first, second)
        ; sample mean lands near the configured mean
        total := 0.0
        for value in first
            total += value
        AhkTest.AssertApprox(10.0, total / first.Length, { abs: 1.0 })
    }
}

class StdlibMathStatisticsEnumerable
{
    __New(values)
    {
        this.Values := values
    }

    __Enum(numberOfVars)
    {
        return this.Values.__Enum(numberOfVars)
    }
}

AhkTest.Collect(StdlibMathStatisticsTest)

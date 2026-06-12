#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibStatisticsError extends ValueError
{
}

class AhkStdlibMathStatistics
{
    static StatisticsError := AhkStdlibStatisticsError

    static mean(data)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("mean requires at least one data point", -1)
        return AhkStdlibStatisticsSum(values) / values.Length
    }

    static fmean(data)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("fmean requires at least one data point", -1)
        return AhkStdlibStatisticsSum(values) / values.Length
    }

    static median(data)
    {
        values := AhkStdlibStatisticsSorted(data)
        length := values.Length
        if Mod(length, 2)
            return values[(length + 1) // 2]
        return (values[length // 2] + values[length // 2 + 1]) / 2
    }

    static median_low(data)
    {
        values := AhkStdlibStatisticsSorted(data)
        return values[(values.Length + 1) // 2]
    }

    static median_high(data)
    {
        values := AhkStdlibStatisticsSorted(data)
        return values[values.Length // 2 + 1]
    }

    static mode(data)
    {
        values := this.multimode(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("no mode for empty data", -1)
        return values[1]
    }

    static multimode(data)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            return []

        counts := Map()
        order := []
        for value in values {
            if !counts.Has(value) {
                counts[value] := 0
                order.Push(value)
            }
            counts[value] += 1
        }

        maxCount := 0
        for value in order {
            if counts[value] > maxCount
                maxCount := counts[value]
        }

        modes := []
        for value in order {
            if counts[value] = maxCount
                modes.Push(value)
        }
        return modes
    }

    static pvariance(data, mu := unset)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("pvariance requires at least one data point", -1)

        avg := IsSet(mu) ? mu : this.fmean(values)
        total := 0
        for value in values
            total += (value - avg) ** 2
        return total / values.Length
    }

    static variance(data, xbar := unset)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length < 2
            throw AhkStdlibStatisticsError("variance requires at least two data points", -1)

        avg := IsSet(xbar) ? xbar : this.fmean(values)
        total := 0
        for value in values
            total += (value - avg) ** 2
        return total / (values.Length - 1)
    }

    static pstdev(data, mu := unset)
    {
        if IsSet(mu)
            return Sqrt(this.pvariance(data, mu))
        return Sqrt(this.pvariance(data))
    }

    static stdev(data, xbar := unset)
    {
        if IsSet(xbar)
            return Sqrt(this.variance(data, xbar))
        return Sqrt(this.variance(data))
    }

    static geometric_mean(data)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("geometric_mean requires a non-empty dataset", -1)
        total := 0.0
        for value in values {
            if value <= 0
                throw AhkStdlibStatisticsError("geometric_mean requires positive numbers", -1)
            total += DllCall("ucrtbase\log", "Double", value + 0.0, "Cdecl Double")
        }
        return DllCall("ucrtbase\exp", "Double", total / values.Length, "Cdecl Double")
    }

    static harmonic_mean(data, weights := unset)
    {
        values := AhkStdlibStatisticsList(data)
        if values.Length = 0
            throw AhkStdlibStatisticsError("harmonic_mean requires at least one data point", -1)

        if IsSet(weights) {
            weightValues := AhkStdlibStatisticsList(weights)
            if weightValues.Length != values.Length
                throw AhkStdlibStatisticsError("Number of weights does not match data size", -1)
        } else {
            weightValues := []
            loop values.Length
                weightValues.Push(1)
        }

        sumWeights := 0
        sumRatios := 0.0
        for index, value in values {
            weight := weightValues[index]
            if value < 0
                throw AhkStdlibStatisticsError("harmonic mean does not support negative values", -1)
            if value = 0
                return 0
            sumWeights += weight
            sumRatios += weight / value
        }
        if sumRatios = 0
            throw AhkStdlibStatisticsError("Weights sum to zero", -1)
        return sumWeights / sumRatios
    }

    static quantiles(data, options := unset)
    {
        values := AhkStdlibStatisticsSorted(data)
        if values.Length < 2
            throw AhkStdlibStatisticsError("must have at least two data points", -1)

        n := 4
        method := "exclusive"
        if IsSet(options) {
            if HasProp(options, "n")
                n := options.n
            if HasProp(options, "method")
                method := options.method
        }
        if !(n is Integer) || n < 1
            throw AhkStdlibStatisticsError("n must be at least 1", -1)

        ld := values.Length
        result := []
        if method = "inclusive" {
            m := ld - 1
            loop n - 1 {
                i := A_Index
                j := (i * m) // n
                delta := (i * m) - (j * n)
                interpolated := (values[j + 1] * (n - delta) + values[j + 2] * delta) / n
                result.Push(interpolated)
            }
            return result
        }
        if method = "exclusive" {
            m := ld + 1
            loop n - 1 {
                i := A_Index
                j := (i * m) // n
                if j < 1
                    j := 1
                else if j > ld - 1
                    j := ld - 1
                delta := (i * m) - (j * n)
                interpolated := (values[j] * (n - delta) + values[j + 1] * delta) / n
                result.Push(interpolated)
            }
            return result
        }
        throw ValueError("Unknown method: '" method "'", -1)
    }
}

stdlib.statistics := AhkStdlibMathStatistics

AhkStdlibStatisticsList(data)
{
    if data is Array
        return data.Clone()
    if IsObject(data) && HasMethod(data, "__Enum") {
        values := []
        for value in data
            values.Push(value)
        return values
    }
    throw TypeError("'" Type(data) "' object is not iterable", -1)
}

AhkStdlibStatisticsSum(values)
{
    total := 0
    for value in values
        total += value
    return total
}

AhkStdlibStatisticsSorted(data)
{
    values := AhkStdlibStatisticsList(data)
    if values.Length = 0
        throw AhkStdlibStatisticsError("no median for empty data", -1)

    AhkStdlibStatisticsQuickSort(values, 1, values.Length)
    return values
}

AhkStdlibStatisticsQuickSort(arr, lo, hi)
{
    while lo < hi {
        pivot := arr[(lo + hi) // 2]
        i := lo
        j := hi
        while i <= j {
            while arr[i] < pivot
                i += 1
            while arr[j] > pivot
                j -= 1
            if i <= j {
                temp := arr[i]
                arr[i] := arr[j]
                arr[j] := temp
                i += 1
                j -= 1
            }
        }
        if (j - lo) < (hi - i) {
            AhkStdlibStatisticsQuickSort(arr, lo, j)
            lo := i
        } else {
            AhkStdlibStatisticsQuickSort(arr, i, hi)
            hi := j
        }
    }
}

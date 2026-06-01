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

    loop values.Length {
        left := A_Index
        loop values.Length - left {
            right := left + A_Index
            if values[left] > values[right] {
                temp := values[left]
                values[left] := values[right]
                values[right] := temp
            }
        }
    }
    return values
}

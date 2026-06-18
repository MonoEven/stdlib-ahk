#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibStatisticsError extends ValueError
{
}

; Public facade for NormalDist. Calling stdlib.statistics.NormalDist(mu, sigma)
; goes through obj.prop(args), which injects the module class as an implicit
; first argument; static Call absorbs it as thisClass. from_samples stays a
; static so stdlib.statistics.NormalDist.from_samples(...) keeps working.
class AhkStdlibNormalDistClass
{
    static Call(thisClass, mu := 0.0, sigma := 1.0)
    {
        return AhkStdlibNormalDist(mu, sigma)
    }

    static from_samples(data)
    {
        return AhkStdlibNormalDist.from_samples(data)
    }
}

class AhkStdlibNormalDist
{
    __New(mu := 0.0, sigma := 1.0)
    {
        if sigma < 0.0
            throw AhkStdlibStatisticsError("sigma must be non-negative", -1)
        this.AhkStdlibMu := mu + 0.0
        this.AhkStdlibSigma := sigma + 0.0
    }

    static from_samples(data)
    {
        values := AhkStdlibStatisticsList(data)
        xbar := AhkStdlibMathStatistics.fmean(values)
        return AhkStdlibNormalDist(xbar, AhkStdlibMathStatistics.stdev(values, xbar))
    }

    mean => this.AhkStdlibMu
    median => this.AhkStdlibMu
    mode => this.AhkStdlibMu
    stdev => this.AhkStdlibSigma
    variance => this.AhkStdlibSigma ** 2.0

    pdf(x)
    {
        sigma := this.AhkStdlibSigma
        variance := sigma ** 2.0
        if !variance
            throw AhkStdlibStatisticsError("pdf() not defined when sigma is zero", -1)
        tau := 2.0 * AhkStdlibStatisticsPi()
        return DllCall("ucrtbase\exp", "Double", (x - this.AhkStdlibMu) ** 2.0 / (-2.0 * variance), "Cdecl Double") / Sqrt(tau * variance)
    }

    cdf(x)
    {
        sigma := this.AhkStdlibSigma
        if !sigma
            throw AhkStdlibStatisticsError("cdf() not defined when sigma is zero", -1)
        return 0.5 * (1.0 + AhkStdlibStatisticsErf((x - this.AhkStdlibMu) / (sigma * Sqrt(2.0))))
    }

    inv_cdf(p)
    {
        if p <= 0.0 || p >= 1.0
            throw AhkStdlibStatisticsError("p must be in the range 0.0 < p < 1.0", -1)
        if this.AhkStdlibSigma <= 0.0
            throw AhkStdlibStatisticsError("cdf() not defined when sigma at or below zero", -1)
        return AhkStdlibStatisticsNormalInvCdf(p, this.AhkStdlibMu, this.AhkStdlibSigma)
    }

    quantiles(n := 4)
    {
        result := []
        loop n - 1
            result.Push(this.inv_cdf(A_Index / n))
        return result
    }

    overlap(other)
    {
        if !(other is AhkStdlibNormalDist)
            throw TypeError("Expected another NormalDist instance", -1)
        X := this
        Y := other
        ; sort to assure commutativity: compare (sigma, mu) tuples
        if (Y.AhkStdlibSigma < X.AhkStdlibSigma)
            || (Y.AhkStdlibSigma = X.AhkStdlibSigma && Y.AhkStdlibMu < X.AhkStdlibMu) {
            X := other
            Y := this
        }
        xVar := X.variance
        yVar := Y.variance
        if !xVar || !yVar
            throw AhkStdlibStatisticsError("overlap() not defined when sigma is zero", -1)
        dv := yVar - xVar
        dm := Abs(Y.AhkStdlibMu - X.AhkStdlibMu)
        if !dv
            return 1.0 - AhkStdlibStatisticsErf(dm / (2.0 * X.AhkStdlibSigma * Sqrt(2.0)))
        a := X.AhkStdlibMu * yVar - Y.AhkStdlibMu * xVar
        b := X.AhkStdlibSigma * Y.AhkStdlibSigma * Sqrt(dm ** 2.0 + dv * DllCall("ucrtbase\log", "Double", yVar / xVar, "Cdecl Double"))
        x1 := (a + b) / dv
        x2 := (a - b) / dv
        return 1.0 - (Abs(Y.cdf(x1) - X.cdf(x1)) + Abs(Y.cdf(x2) - X.cdf(x2)))
    }

    zscore(x)
    {
        if !this.AhkStdlibSigma
            throw AhkStdlibStatisticsError("zscore() not defined when sigma is zero", -1)
        return (x - this.AhkStdlibMu) / this.AhkStdlibSigma
    }

    samples(n, seed := unset)
    {
        ; AHK v2's Random() has no seed argument; when a seed is supplied we
        ; draw deterministic uniforms from a small LCG so output is repeatable.
        state := IsSet(seed) ? (seed & 0xFFFFFFFF) : 0
        result := []
        loop n {
            if IsSet(seed) {
                state := Mod(state * 1103515245 + 12345, 2147483648)
                u := (state + 0.5) / 2147483648.0
            } else {
                u := Random(0.0, 1.0)
            }
            if u <= 0.0
                u := 2.2250738585072014e-308
            else if u >= 1.0
                u := 1.0 - 1.1102230246251565e-16
            result.Push(AhkStdlibStatisticsNormalInvCdf(u, this.AhkStdlibMu, this.AhkStdlibSigma))
        }
        return result
    }

    ; Arithmetic. AHK v2 cannot cleanly overload '/', so these are methods.
    ; translate/scale operate on a constant; add/subtract also accept a NormalDist.
    translate(c) => AhkStdlibNormalDist(this.AhkStdlibMu + c, this.AhkStdlibSigma)
    scale(c) => AhkStdlibNormalDist(this.AhkStdlibMu * c, this.AhkStdlibSigma * Abs(c))

    add(other)
    {
        if other is AhkStdlibNormalDist
            return AhkStdlibNormalDist(this.AhkStdlibMu + other.AhkStdlibMu, Sqrt(this.AhkStdlibSigma ** 2.0 + other.AhkStdlibSigma ** 2.0))
        return AhkStdlibNormalDist(this.AhkStdlibMu + other, this.AhkStdlibSigma)
    }

    subtract(other)
    {
        if other is AhkStdlibNormalDist
            return AhkStdlibNormalDist(this.AhkStdlibMu - other.AhkStdlibMu, Sqrt(this.AhkStdlibSigma ** 2.0 + other.AhkStdlibSigma ** 2.0))
        return AhkStdlibNormalDist(this.AhkStdlibMu - other, this.AhkStdlibSigma)
    }

    multiply(c) => AhkStdlibNormalDist(this.AhkStdlibMu * c, this.AhkStdlibSigma * Abs(c))
    divide(c) => AhkStdlibNormalDist(this.AhkStdlibMu / c, this.AhkStdlibSigma / Abs(c))
    negate() => AhkStdlibNormalDist(-this.AhkStdlibMu, this.AhkStdlibSigma)

    equals(other)
    {
        if !(other is AhkStdlibNormalDist)
            return false
        return this.AhkStdlibMu = other.AhkStdlibMu && this.AhkStdlibSigma = other.AhkStdlibSigma
    }
}

class AhkStdlibMathStatistics
{
    static StatisticsError := AhkStdlibStatisticsError
    static NormalDist := AhkStdlibNormalDistClass

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

    static median_grouped(data, interval := 1)
    {
        values := AhkStdlibStatisticsSorted(data)
        n := values.Length
        if n = 1
            return values[1]

        x := values[n // 2 + 1]
        L := x - interval / 2

        l1 := 0
        f := 0
        for value in values {
            if value < x
                l1 += 1
            else if value = x
                f += 1
        }
        cf := l1
        return L + interval * (n / 2 - cf) / f
    }

    static covariance(x, y)
    {
        xs := AhkStdlibStatisticsList(x)
        ys := AhkStdlibStatisticsList(y)
        n := xs.Length
        if ys.Length != n
            throw AhkStdlibStatisticsError("covariance requires that both inputs have same number of data points", -1)
        if n < 2
            throw AhkStdlibStatisticsError("covariance requires at least two data points", -1)

        xbar := AhkStdlibStatisticsSum(xs) / n
        ybar := AhkStdlibStatisticsSum(ys) / n
        sxy := 0.0
        for index, xi in xs
            sxy += (xi - xbar) * (ys[index] - ybar)
        return sxy / (n - 1)
    }

    static correlation(x, y)
    {
        xs := AhkStdlibStatisticsList(x)
        ys := AhkStdlibStatisticsList(y)
        n := xs.Length
        if ys.Length != n
            throw AhkStdlibStatisticsError("correlation requires that both inputs have same number of data points", -1)
        if n < 2
            throw AhkStdlibStatisticsError("correlation requires at least two data points", -1)

        xbar := AhkStdlibStatisticsSum(xs) / n
        ybar := AhkStdlibStatisticsSum(ys) / n
        sxy := 0.0
        sxx := 0.0
        syy := 0.0
        for index, xi in xs {
            yi := ys[index]
            sxy += (xi - xbar) * (yi - ybar)
            sxx += (xi - xbar) ** 2.0
            syy += (yi - ybar) ** 2.0
        }
        denom := Sqrt(sxx * syy)
        if denom = 0
            throw AhkStdlibStatisticsError("at least one of the inputs is constant", -1)
        return sxy / denom
    }

    static linear_regression(x, y)
    {
        xs := AhkStdlibStatisticsList(x)
        ys := AhkStdlibStatisticsList(y)
        n := xs.Length
        if ys.Length != n
            throw AhkStdlibStatisticsError("linear regression requires that both inputs have same number of data points", -1)
        if n < 2
            throw AhkStdlibStatisticsError("linear regression requires at least two data points", -1)

        xbar := AhkStdlibStatisticsSum(xs) / n
        ybar := AhkStdlibStatisticsSum(ys) / n
        sxy := 0.0
        sxx := 0.0
        for index, xi in xs {
            sxy += (xi - xbar) * (ys[index] - ybar)
            sxx += (xi - xbar) ** 2.0
        }
        if sxx = 0
            throw AhkStdlibStatisticsError("x is constant", -1)
        slope := sxy / sxx
        intercept := ybar - slope * xbar
        return stdlib.tuple([slope, intercept])
    }
}

stdlib.statistics := AhkStdlibMathStatistics

AhkStdlibStatisticsList(data)
{
    return AhkStdlibToArray(data)
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

AhkStdlibStatisticsPi()
{
    return 3.141592653589793
}

AhkStdlibStatisticsErf(x)
{
    return DllCall("ucrtbase\erf", "Double", x + 0.0, "Cdecl Double")
}

AhkStdlibStatisticsNormalInvCdf(p, mu, sigma)
{
    ; Wichura, M.J. (1988). "Algorithm AS241: The Percentage Points of the
    ; Normal Distribution". Matches CPython statistics._normal_dist_inv_cdf.
    q := p - 0.5
    if Abs(q) <= 0.425 {
        r := 0.180625 - q * q
        num := (((((((2.5090809287301226727e+3 * r
                    + 3.3430575583588128105e+4) * r
                    + 6.7265770927008700853e+4) * r
                    + 4.5921953931549871457e+4) * r
                    + 1.3731693765509461125e+4) * r
                    + 1.9715909503065514427e+3) * r
                    + 1.3314166789178437745e+2) * r
                    + 3.3871328727963666080e+0) * q
        den := (((((((5.2264952788528545610e+3 * r
                    + 2.8729085735721942674e+4) * r
                    + 3.9307895800092710610e+4) * r
                    + 2.1213794301586595867e+4) * r
                    + 5.3941960214247511077e+3) * r
                    + 6.8718700749205790830e+2) * r
                    + 4.2313330701600911252e+1) * r
                    + 1.0)
        x := num / den
        return mu + (x * sigma)
    }
    r := q <= 0.0 ? p : 1.0 - p
    r := Sqrt(-DllCall("ucrtbase\log", "Double", r, "Cdecl Double"))
    if r <= 5.0 {
        r := r - 1.6
        num := (((((((7.7454501427834140764e-4 * r
                    + 2.2723844989269184583e-2) * r
                    + 2.4178072517745061177e-1) * r
                    + 1.2704582524523683826e+0) * r
                    + 3.6478483247632046050e+0) * r
                    + 5.7694972214606914055e+0) * r
                    + 4.6303378461565452959e+0) * r
                    + 1.4234371107496835773e+0)
        den := (((((((1.0507500716444168432e-9 * r
                    + 5.4759380849953449460e-4) * r
                    + 1.5198666563616457196e-2) * r
                    + 1.4810397642748007459e-1) * r
                    + 6.8976733498510000455e-1) * r
                    + 1.6763848301838038494e+0) * r
                    + 2.0531916266377588219e+0) * r
                    + 1.0)
    } else {
        r := r - 5.0
        num := (((((((2.0103343992922881327e-7 * r
                    + 2.7115555687434875782e-5) * r
                    + 1.2426609473880784386e-3) * r
                    + 2.6532189526576123093e-2) * r
                    + 2.9656057182850489123e-1) * r
                    + 1.7848265399172913358e+0) * r
                    + 5.4637849111641143699e+0) * r
                    + 6.6579046435011037772e+0)
        den := (((((((2.0442631033899397856e-15 * r
                    + 1.4215117583164458887e-7) * r
                    + 1.8463183175100546818e-5) * r
                    + 7.8686913114561325100e-4) * r
                    + 1.4875361290850614852e-2) * r
                    + 1.3692988092273580531e-1) * r
                    + 5.9983220655588793769e-1) * r
                    + 1.0)
    }
    x := num / den
    if q < 0.0
        x := -x
    return mu + (x * sigma)
}

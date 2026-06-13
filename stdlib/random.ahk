#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibRandom
{
    static seed(a := unset) => AhkStdlibRandomDefault.seed(a?)
    ; NOTE: AHK identifiers are case-insensitive, so the Python names random.random()
    ; and random.Random(seed) collide on the same member. We dispatch on the argument:
    ; no argument -> next float from the default generator; a seed -> a new Random instance.
    static random(seed := unset) => IsSet(seed) ? AhkStdlibRandomMt19937(seed) : AhkStdlibRandomDefault.random()
    static getrandbits(k) => AhkStdlibRandomDefault.getrandbits(k)
    static uniform(a, b) => AhkStdlibRandomDefault.uniform(a, b)
    static randrange(start, stop := unset, step := 1) => AhkStdlibRandomDefault.randrange(start, stop?, step)
    static randint(a, b) => AhkStdlibRandomDefault.randint(a, b)
    static choice(sequence) => AhkStdlibRandomDefault.choice(sequence)
    static choices(population, weights := unset, cum_weights := unset, k := 1) => AhkStdlibRandomDefault.choices(population, weights?, cum_weights?, k)
    static sample(population, k, counts := unset) => AhkStdlibRandomDefault.sample(population, k, counts?)
    static shuffle(sequence) => AhkStdlibRandomDefault.shuffle(sequence)
    static randbytes(n) => AhkStdlibRandomDefault.randbytes(n)
    static getstate() => AhkStdlibRandomDefault.getstate()
    static setstate(state) => AhkStdlibRandomDefault.setstate(state)
    static gauss(mu, sigma) => AhkStdlibRandomDefault.gauss(mu, sigma)
    static normalvariate(mu, sigma) => AhkStdlibRandomDefault.normalvariate(mu, sigma)
    static lognormvariate(mu, sigma) => AhkStdlibRandomDefault.lognormvariate(mu, sigma)
    static expovariate(lambd) => AhkStdlibRandomDefault.expovariate(lambd)
    static triangular(low := 0.0, high := 1.0, mode := unset) => AhkStdlibRandomDefault.triangular(low, high, mode?)
    static paretovariate(alpha) => AhkStdlibRandomDefault.paretovariate(alpha)
    static weibullvariate(alpha, beta) => AhkStdlibRandomDefault.weibullvariate(alpha, beta)
    static vonmisesvariate(mu, kappa) => AhkStdlibRandomDefault.vonmisesvariate(mu, kappa)
    static gammavariate(alpha, beta) => AhkStdlibRandomDefault.gammavariate(alpha, beta)
    static betavariate(alpha, beta) => AhkStdlibRandomDefault.betavariate(alpha, beta)
}

class AhkStdlibRandomMt19937
{
    static N := 624
    static M := 397
    static MatrixA := 0x9908B0DF
    static UpperMask := 0x80000000
    static LowerMask := 0x7FFFFFFF

    __New(seed := unset)
    {
        this.State := []
        this.Index := AhkStdlibRandomMt19937.N + 1
        this.HasGaussNext := false
        this.GaussNext := 0.0
        if IsSet(seed)
            this.seed(seed)
        else
            this.seed(5489)
    }

    seed(a := unset)
    {
        if !IsSet(a)
            a := A_TickCount

        key := AhkStdlibRandomSeedKey(a)
        this.AhkStdlibInitByArray(key)
        this.HasGaussNext := false
    }

    random()
    {
        a := this.AhkStdlibGenUInt32() >>> 5
        b := this.AhkStdlibGenUInt32() >>> 6
        return ((a * 67108864.0) + b) / 9007199254740992.0
    }

    getrandbits(k)
    {
        if !(k is Integer)
            throw TypeError("'" Type(k) "' object cannot be interpreted as an integer", -1)
        if k < 0
            throw ValueError("number of bits must be non-negative", -1)
        if k = 0
            return 0

        words := Ceil(k / 32)
        result := 0
        loop words {
            value := this.AhkStdlibGenUInt32()
            if A_Index = words {
                excess := (32 * words) - k
                if excess > 0
                    value := value >>> excess
            }
            result := (result << 32) | value
        }
        return result
    }

    randrange(start, stop := unset, step := 1)
    {
        AhkStdlibRandomRequireRangeInteger(start, IsSet(stop) ? "start" : "arg 1")
        AhkStdlibRandomRequireRangeInteger(step, "step")

        if !IsSet(stop) {
            stop := start
            start := 0
        } else {
            AhkStdlibRandomRequireRangeInteger(stop, "stop")
        }

        if step = 0
            throw ValueError("zero step for randrange()", -1)

        width := stop - start
        if step = 1 {
            if width > 0
                return start + this.AhkStdlibRandBelow(width)
            throw ValueError("empty range for randrange()", -1)
        }

        if step > 0
            count := (width + step - 1) // step
        else
            count := (width + step + 1) // step
        if count <= 0
            throw ValueError("empty range for randrange()", -1)

        return start + (step * this.AhkStdlibRandBelow(count))
    }

    randint(a, b)
    {
        return this.randrange(a, b + 1)
    }

    choice(sequence)
    {
        if sequence is Map
            throw stdlib.KeyError(0, -1)

        values := AhkStdlibRandomChoiceValues(sequence)
        if values.Length = 0
            throw IndexError(AhkStdlibRandomSequenceIndexMessage(sequence), -1)
        return values[this.AhkStdlibRandBelow(values.Length) + 1]
    }

    choices(population, weights := unset, cum_weights := unset, k := 1)
    {
        populationValues := AhkStdlibRandomSequenceValues(population)
        size := populationValues.Length
        if size = 0
            throw IndexError(AhkStdlibRandomSequenceIndexMessage(population), -1)
        if AhkStdlibIsBool(k)
            k := k.Value ? 1 : 0
        if !(k is Integer)
            throw TypeError("'" Type(k) "' object cannot be interpreted as an integer", -1)

        hasWeights := IsSet(weights)
        hasCumWeights := IsSet(cum_weights)
        if hasWeights && hasCumWeights
            throw TypeError("Cannot specify both weights and cumulative weights", -1)

        result := []
        if !hasWeights && !hasCumWeights {
            loop Max(k, 0)
                result.Push(populationValues[Floor(this.random() * size) + 1])
            return result
        }

        cumulative := hasCumWeights ? AhkStdlibRandomSequenceValues(cum_weights) : AhkStdlibRandomAccumulateWeights(weights)
        if cumulative.Length != size
            throw ValueError("The number of weights does not match the population", -1)

        total := cumulative[cumulative.Length] + 0.0
        if total <= 0.0
            throw ValueError("Total of weights must be greater than zero", -1)

        loop Max(k, 0) {
            needle := this.random() * total
            index := AhkStdlibRandomBisectRight(cumulative, needle)
            result.Push(populationValues[index])
        }
        return result
    }

    sample(population, k, counts := unset)
    {
        if !(population is Array || population is String)
            throw TypeError("Population must be a sequence.  For dicts or sets, use sorted(d).", -1)
        if AhkStdlibIsBool(k)
            k := k.Value ? 1 : 0
        if !(k is Integer)
            throw TypeError("'" Type(k) "' object cannot be interpreted as an integer", -1)

        baseValues := []
        if population is Array {
            for value in population
                baseValues.Push(value)
        } else {
            loop StrLen(population)
                baseValues.Push(SubStr(population, A_Index, 1))
        }

        if IsSet(counts) {
            countValues := AhkStdlibRandomSequenceValues(counts)
            if countValues.Length != baseValues.Length
                throw ValueError("The number of counts does not match the population", -1)

            cumulative := []
            total := 0
            for c in countValues {
                if !(c is Integer)
                    throw TypeError("'" Type(c) "' object cannot be interpreted as an integer", -1)
                total += c
                cumulative.Push(total)
            }
            if total < 0
                throw ValueError("total number of items in counts must be greater than or equal to zero", -1)

            indices := this.sample(AhkStdlibRandomRangeArray(total), k)
            result := []
            for idx in indices {
                pos := AhkStdlibRandomBisectRight(cumulative, idx)
                result.Push(baseValues[pos])
            }
            return result
        }

        size := baseValues.Length
        if k < 0 || k > size
            throw ValueError("Sample larger than population or is negative", -1)

        pool := []
        for value in baseValues
            pool.Push(value)

        result := []
        loop k {
            index := this.AhkStdlibRandBelow(pool.Length) + 1
            result.Push(pool[index])
            pool[index] := pool[pool.Length]
            pool.Pop()
        }
        return result
    }

    shuffle(sequence)
    {
        if !(sequence is Array)
            throw TypeError("'" AhkStdlibPythonTypeName(sequence) "' object does not support item assignment", -1)

        index := sequence.Length
        while index > 1 {
            swapIndex := this.AhkStdlibRandBelow(index) + 1
            temp := sequence[index]
            sequence[index] := sequence[swapIndex]
            sequence[swapIndex] := temp
            index -= 1
        }
    }

    uniform(a, b)
    {
        return a + ((b - a) * this.random())
    }

    randbytes(n)
    {
        if AhkStdlibIsBool(n)
            n := n.Value ? 1 : 0
        if !(n is Integer)
            throw TypeError("'" AhkStdlibPythonTypeName(n) "' object cannot be interpreted as an integer", -1)
        if n < 0
            throw ValueError("number of bits must be non-negative", -1)

        bytes := Buffer(n, 0)
        loop n
            NumPut("UChar", this.getrandbits(8), bytes, A_Index - 1)
        return bytes
    }

    getstate()
    {
        words := []
        loop AhkStdlibRandomMt19937.N
            words.Push(this.State[A_Index])
        words.Push(this.Index)
        internal := stdlib.tuple(words)
        gaussNext := this.HasGaussNext ? this.GaussNext : stdlib.None
        return stdlib.tuple([3, internal, gaussNext])
    }

    setstate(state)
    {
        if !(state is Array)
            throw TypeError("state vector is the wrong type", -1)
        if state.Length != 3
            throw ValueError("state vector is the wrong size", -1)

        version := state[1]
        if version != 3
            throw ValueError("state with version " version " passed to Random.setstate() of version 3", -1)

        internal := state[2]
        if !(internal is Array)
            throw TypeError("state vector is the wrong type", -1)
        if internal.Length != AhkStdlibRandomMt19937.N + 1
            throw ValueError("state vector is the wrong size", -1)

        newState := []
        newState.Length := AhkStdlibRandomMt19937.N
        loop AhkStdlibRandomMt19937.N
            newState[A_Index] := AhkStdlibRandomUInt32(Integer(internal[A_Index]))
        this.State := newState
        this.Index := Integer(internal[AhkStdlibRandomMt19937.N + 1])

        gaussNext := state[3]
        if AhkStdlibIsNone(gaussNext) {
            this.HasGaussNext := false
            this.GaussNext := 0.0
        } else {
            this.HasGaussNext := true
            this.GaussNext := gaussNext + 0.0
        }
    }

    gauss(mu, sigma)
    {
        z := this.HasGaussNext ? this.GaussNext : ""
        this.HasGaussNext := false
        if z = "" {
            x2pi := this.random() * AhkStdlibRandomTwoPi()
            g2rad := Sqrt(-2.0 * Ln(1.0 - this.random()))
            z := Cos(x2pi) * g2rad
            this.GaussNext := Sin(x2pi) * g2rad
            this.HasGaussNext := true
        }
        return mu + (z * sigma)
    }

    normalvariate(mu, sigma)
    {
        nvMagic := 4.0 * Exp(-0.5) / Sqrt(2.0)
        loop {
            u1 := this.random()
            u2 := 1.0 - this.random()
            z := nvMagic * (u1 - 0.5) / u2
            zz := z * z / 4.0
            if zz <= -Ln(u2)
                break
        }
        return mu + (z * sigma)
    }

    lognormvariate(mu, sigma)
    {
        return Exp(this.normalvariate(mu, sigma))
    }

    expovariate(lambd)
    {
        return -Ln(1.0 - this.random()) / lambd
    }

    triangular(low := 0.0, high := 1.0, mode := unset)
    {
        u := this.random()
        if high = low
            return low
        c := !IsSet(mode) || AhkStdlibIsNone(mode) ? 0.5 : (mode - low) / (high - low)
        if u > c {
            u := 1.0 - u
            c := 1.0 - c
            temp := low
            low := high
            high := temp
        }
        return low + ((high - low) * Sqrt(u * c))
    }

    paretovariate(alpha)
    {
        u := 1.0 - this.random()
        return u ** (-1.0 / alpha)
    }

    weibullvariate(alpha, beta)
    {
        u := 1.0 - this.random()
        return alpha * (-Ln(u)) ** (1.0 / beta)
    }

    vonmisesvariate(mu, kappa)
    {
        twopi := AhkStdlibRandomTwoPi()
        if kappa <= 0.000001
            return twopi * this.random()

        s := 0.5 / kappa
        r := s + Sqrt(1.0 + (s * s))
        loop {
            u1 := this.random()
            z := Cos(AhkStdlibMathPi() * u1)
            d := z / (r + z)
            u2 := this.random()
            if u2 < 1.0 - (d * d) || u2 <= (1.0 - d) * Exp(d)
                break
        }
        q := 1.0 / r
        f := (q + z) / (1.0 + (q * z))
        u3 := this.random()
        if u3 > 0.5
            theta := AhkStdlibRandomFloorMod(mu + ACos(f), twopi)
        else
            theta := AhkStdlibRandomFloorMod(mu - ACos(f), twopi)
        return theta
    }

    gammavariate(alpha, beta)
    {
        if alpha <= 0.0 || beta <= 0.0
            throw ValueError("gammavariate: alpha and beta must be > 0.0", -1)

        if alpha > 1.0 {
            ainv := Sqrt((2.0 * alpha) - 1.0)
            bbb := alpha - Ln(4.0)
            ccc := alpha + ainv
            sgMagic := 1.0 + Ln(4.5)
            loop {
                u1 := this.random()
                if !(0.0000001 < u1 && u1 < 0.9999999)
                    continue
                u2 := 1.0 - this.random()
                v := Ln(u1 / (1.0 - u1)) / ainv
                x := alpha * Exp(v)
                z := u1 * u1 * u2
                r := bbb + (ccc * v) - x
                if (r + sgMagic - (4.5 * z)) >= 0.0 || r >= Ln(z)
                    return x * beta
            }
        } else if alpha = 1.0 {
            u := this.random()
            while u <= 0.0000001
                u := this.random()
            return -Ln(u) * beta
        } else {
            eConst := AhkStdlibMathE()
            loop {
                u := this.random()
                b := (eConst + alpha) / eConst
                p := b * u
                if p <= 1.0
                    x := p ** (1.0 / alpha)
                else
                    x := -Ln((b - p) / alpha)
                u1 := this.random()
                if p > 1.0 {
                    if u1 <= x ** (alpha - 1.0)
                        break
                } else if u1 <= Exp(-x)
                    break
            }
            return x * beta
        }
    }

    betavariate(alpha, beta)
    {
        y := this.gammavariate(alpha, 1.0)
        if y
            return y / (y + this.gammavariate(beta, 1.0))
        return 0.0
    }

    AhkStdlibRandBelow(n)
    {
        if !n
            return 0

        bits := AhkStdlibRandomBitLength(n)
        value := this.getrandbits(bits)
        while value >= n
            value := this.getrandbits(bits)
        return value
    }

    AhkStdlibInitGenRand(seed)
    {
        this.State := []
        this.State.Length := AhkStdlibRandomMt19937.N
        this.State[1] := AhkStdlibRandomUInt32(seed)

        loop AhkStdlibRandomMt19937.N - 1 {
            index := A_Index + 1
            previous := this.State[index - 1]
            this.State[index] := AhkStdlibRandomUInt32((1812433253 * (previous ^ (previous >>> 30))) + (index - 1))
        }

        this.Index := AhkStdlibRandomMt19937.N
    }

    AhkStdlibInitByArray(key)
    {
        this.AhkStdlibInitGenRand(19650218)
        i := 2
        j := 1
        keyLength := key.Length
        loops := Max(AhkStdlibRandomMt19937.N, keyLength)

        loop loops {
            previous := this.State[i - 1]
            value := (this.State[i] ^ ((previous ^ (previous >>> 30)) * 1664525)) + key[j] + (j - 1)
            this.State[i] := AhkStdlibRandomUInt32(value)
            i += 1
            j += 1
            if i > AhkStdlibRandomMt19937.N {
                this.State[1] := this.State[AhkStdlibRandomMt19937.N]
                i := 2
            }
            if j > keyLength
                j := 1
        }

        loop AhkStdlibRandomMt19937.N - 1 {
            previous := this.State[i - 1]
            value := (this.State[i] ^ ((previous ^ (previous >>> 30)) * 1566083941)) - (i - 1)
            this.State[i] := AhkStdlibRandomUInt32(value)
            i += 1
            if i > AhkStdlibRandomMt19937.N {
                this.State[1] := this.State[AhkStdlibRandomMt19937.N]
                i := 2
            }
        }

        this.State[1] := AhkStdlibRandomMt19937.UpperMask
        this.Index := AhkStdlibRandomMt19937.N
    }

    AhkStdlibGenUInt32()
    {
        if this.Index >= AhkStdlibRandomMt19937.N
            this.AhkStdlibTwist()

        value := this.State[this.Index + 1]
        this.Index += 1

        value := value ^ (value >>> 11)
        value := value ^ ((value << 7) & 0x9D2C5680)
        value := value ^ ((value << 15) & 0xEFC60000)
        value := value ^ (value >>> 18)
        return AhkStdlibRandomUInt32(value)
    }

    AhkStdlibTwist()
    {
        mag01 := [0, AhkStdlibRandomMt19937.MatrixA]

        loop AhkStdlibRandomMt19937.N - AhkStdlibRandomMt19937.M {
            index := A_Index
            y := (this.State[index] & AhkStdlibRandomMt19937.UpperMask) | (this.State[index + 1] & AhkStdlibRandomMt19937.LowerMask)
            this.State[index] := AhkStdlibRandomUInt32(this.State[index + AhkStdlibRandomMt19937.M] ^ (y >>> 1) ^ mag01[(y & 1) + 1])
        }

        start := AhkStdlibRandomMt19937.N - AhkStdlibRandomMt19937.M + 1
        loop AhkStdlibRandomMt19937.M - 1 {
            index := start + A_Index - 1
            y := (this.State[index] & AhkStdlibRandomMt19937.UpperMask) | (this.State[index + 1] & AhkStdlibRandomMt19937.LowerMask)
            this.State[index] := AhkStdlibRandomUInt32(this.State[index + (AhkStdlibRandomMt19937.M - AhkStdlibRandomMt19937.N)] ^ (y >>> 1) ^ mag01[(y & 1) + 1])
        }

        y := (this.State[AhkStdlibRandomMt19937.N] & AhkStdlibRandomMt19937.UpperMask) | (this.State[1] & AhkStdlibRandomMt19937.LowerMask)
        this.State[AhkStdlibRandomMt19937.N] := AhkStdlibRandomUInt32(this.State[AhkStdlibRandomMt19937.M] ^ (y >>> 1) ^ mag01[(y & 1) + 1])
        this.Index := 0
    }
}

AhkStdlibRandomDefault := AhkStdlibRandomMt19937(5489)
stdlib.random := AhkStdlibRandom

AhkStdlibRandomSeedKey(value)
{
    if value is Integer
        return [AhkStdlibRandomUInt32(value)]
    if value is Float && value = Integer(value)
        return [AhkStdlibRandomUInt32(Integer(value))]

    throw TypeError("The only supported seed types are int and integer-valued float", -1)
}

AhkStdlibRandomUInt32(value)
{
    return value & 0xFFFFFFFF
}

AhkStdlibRandomBitLength(value)
{
    if value <= 0
        return 0

    bits := 0
    while value > 0 {
        bits += 1
        value := value >>> 1
    }
    return bits
}

AhkStdlibRandomRequireRangeInteger(value, name)
{
    if value is Integer
        return

    if value is Float && value = Integer(value)
        return

    throw ValueError("non-integer " name " for randrange()", -1)
}

AhkStdlibRandomSequenceValues(sequence)
{
    result := []
    if sequence is Array {
        for value in sequence
            result.Push(value)
        return result
    }

    if sequence is String {
        loop StrLen(sequence)
            result.Push(SubStr(sequence, A_Index, 1))
        return result
    }

    if HasProp(sequence, "__Len") && HasProp(sequence, "__Item") {
        length := sequence.__Len
        loop length
            result.Push(sequence[A_Index])
        return result
    }

    throw TypeError("'" Type(sequence) "' object is not a sequence", -1)
}

AhkStdlibRandomChoiceValues(sequence)
{
    if sequence is Array || sequence is String
        return AhkStdlibRandomSequenceValues(sequence)

    if HasProp(sequence, "__Len") && HasProp(sequence, "__Item")
        return AhkStdlibRandomSequenceValues(sequence)

    throw TypeError("'" Type(sequence) "' object is not subscriptable", -1)
}

AhkStdlibRandomSequenceIndexMessage(sequence)
{
    if sequence is String
        return "string index out of range"
    return "list index out of range"
}

AhkStdlibRandomAccumulateWeights(weights)
{
    cumulative := []
    total := 0
    for weight in AhkStdlibRandomSequenceValues(weights) {
        total += weight
        cumulative.Push(total)
    }
    return cumulative
}

AhkStdlibRandomBisectRight(values, needle)
{
    low := 1
    high := values.Length
    while low <= high {
        mid := (low + high) // 2
        if needle < values[mid]
            high := mid - 1
        else
            low := mid + 1
    }
    return low
}

AhkStdlibRandomTwoPi()
{
    return 6.283185307179586
}

AhkStdlibMathPi()
{
    return 3.141592653589793
}

AhkStdlibMathE()
{
    return 2.718281828459045
}

AhkStdlibRandomFloorMod(x, y)
{
    return x - (y * Floor(x / y))
}

AhkStdlibRandomRangeArray(n)
{
    result := []
    result.Length := n
    loop n
        result[A_Index] := A_Index - 1
    return result
}

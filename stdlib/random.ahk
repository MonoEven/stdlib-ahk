#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibRandom
{
    static seed(a := unset) => AhkStdlibRandomDefault.seed(a?)
    static random() => AhkStdlibRandomDefault.random()
    static getrandbits(k) => AhkStdlibRandomDefault.getrandbits(k)
    static uniform(a, b) => AhkStdlibRandomDefault.uniform(a, b)
    static randrange(start, stop := unset, step := 1) => AhkStdlibRandomDefault.randrange(start, stop?, step)
    static randint(a, b) => AhkStdlibRandomDefault.randint(a, b)
    static choice(sequence) => AhkStdlibRandomDefault.choice(sequence)
    static choices(population, weights := unset, cum_weights := unset, k := 1) => AhkStdlibRandomDefault.choices(population, weights?, cum_weights?, k)
    static sample(population, k) => AhkStdlibRandomDefault.sample(population, k)
    static shuffle(sequence) => AhkStdlibRandomDefault.shuffle(sequence)
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

    sample(population, k)
    {
        if !(population is Array || population is String)
            throw TypeError("Population must be a sequence.  For dicts or sets, use sorted(d).", -1)
        if AhkStdlibIsBool(k)
            k := k.Value ? 1 : 0
        if !(k is Integer)
            throw TypeError("'" Type(k) "' object cannot be interpreted as an integer", -1)

        size := population is Array ? population.Length : StrLen(population)
        if k < 0 || k > size
            throw ValueError("Sample larger than population or is negative", -1)

        pool := []
        if population is Array {
            for value in population
                pool.Push(value)
        } else {
            loop StrLen(population)
                pool.Push(SubStr(population, A_Index, 1))
        }

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

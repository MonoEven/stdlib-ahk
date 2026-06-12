#Requires AutoHotkey v2.0

#Include <stdlib\init>

class AhkStdlibCollections
{
    static Counter
    {
        get => AhkStdlibCollectionsCounter
    }

    static Counter(args*)
    {
        return AhkStdlibCollectionsCounter(args*)
    }

    static deque
    {
        get => AhkStdlibCollectionsDeque
    }

    static deque(args*)
    {
        return AhkStdlibCollectionsDeque(args*)
    }

    static defaultdict
    {
        get => AhkStdlibCollectionsDefaultDict
    }

    static defaultdict(args*)
    {
        return AhkStdlibCollectionsDefaultDict(args*)
    }

    static OrderedDict
    {
        get => AhkStdlibCollectionsOrderedDict
    }

    static OrderedDict(args*)
    {
        return AhkStdlibCollectionsOrderedDict(args*)
    }

    static ChainMap
    {
        get => AhkStdlibCollectionsChainMap
    }

    static ChainMap(args*)
    {
        return AhkStdlibCollectionsChainMap(args*)
    }

    static namedtuple(typename, field_names, options?)
    {
        return AhkStdlibCollectionsNamedTupleType(typename, field_names, options?)
    }

    static UserDict
    {
        get => AhkStdlibCollectionsUserDict
    }

    static UserDict(args*)
    {
        return AhkStdlibCollectionsUserDict(args*)
    }

    static UserList
    {
        get => AhkStdlibCollectionsUserList
    }

    static UserList(args*)
    {
        return AhkStdlibCollectionsUserList(args*)
    }

    static UserString
    {
        get => AhkStdlibCollectionsUserString
    }

    static UserString(args*)
    {
        return AhkStdlibCollectionsUserString(args*)
    }
}

class AhkStdlibCollectionsCounter extends Map
{
    static fromkeys(args*)
    {
        if args.Length < 1
            throw TypeError("Counter.fromkeys() missing 1 required positional argument: 'iterable'", -1)
        if args.Length > 2
            throw TypeError("Counter.fromkeys() takes from 2 to 3 positional arguments but " args.Length + 1 " were given", -1)
        throw NotImplementedError("Counter.fromkeys() is undefined.  Use Counter(iterable) instead.", -1)
    }

    __New(args*)
    {
        this.Default := 0
        this.AhkStdlibOrder := []
        this.AhkStdlibKeyMutationVersion := 0
        this.update(args*)
    }

    __Item[key]
    {
        get {
            return super.Get(key, 0)
        }
        set {
            this.AhkStdlibRememberKey(key)
            return super[key] := value
        }
    }

    update(args*)
    {
        if args.Length = 0
            return
        if args.Length > 1 && !AhkStdlibCollectionsIsKwargsOptions(args[2])
            throw TypeError("Counter.update() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length > 2
            throw TypeError("Counter.update() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

        hasSource := true
        source := args[1]
        kwargs := unset
        if args.Length = 1 && AhkStdlibCollectionsIsKwargsOptions(source) {
            kwargs := source.kwargs
            hasSource := false
        } else if args.Length = 2 {
            options := args[2]
            if !AhkStdlibCollectionsIsKwargsOptions(options)
                throw TypeError("Counter.update expected kwargs options object", -1)
            kwargs := options.kwargs
        }

        if hasSource
            AhkStdlibCollectionsCounterUpdateSource(this, source)
        if IsSet(kwargs)
            AhkStdlibCollectionsCounterUpdateMapping(this, kwargs)
    }

    subtract(args*)
    {
        if args.Length = 0
            return
        if args.Length > 1 && !AhkStdlibCollectionsIsKwargsOptions(args[2])
            throw TypeError("Counter.subtract() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)
        if args.Length > 2
            throw TypeError("Counter.subtract() takes from 1 to 2 positional arguments but " args.Length + 1 " were given", -1)

        hasSource := true
        source := args[1]
        kwargs := unset
        if args.Length = 1 && AhkStdlibCollectionsIsKwargsOptions(source) {
            kwargs := source.kwargs
            hasSource := false
        } else if args.Length = 2 {
            options := args[2]
            if !AhkStdlibCollectionsIsKwargsOptions(options)
                throw TypeError("Counter.subtract expected kwargs options object", -1)
            kwargs := options.kwargs
        }

        if hasSource
            AhkStdlibCollectionsCounterSubtractSource(this, source)
        if IsSet(kwargs)
            AhkStdlibCollectionsCounterSubtractMapping(this, kwargs)
    }

    total()
    {
        total := 0
        for key in this.AhkStdlibOrder {
            if this.Has(key)
                total := AhkStdlibCollectionsCounterTotalCount(total, this[key])
        }
        return total
    }

    elements()
    {
        return AhkStdlibCollectionsCounterElements(this)
    }

    most_common(limit := unset)
    {
        pairs := []
        for key in this.AhkStdlibOrder {
            if this.Has(key)
                pairs.Push([key, this[key]])
        }

        ; Stable descending sort by count (Python's most_common preserves
        ; first-seen order for equal counts via heapq/sorted stability).
        pairs := AhkStdlibCollectionsCounterSortByCount(pairs)

        if IsSet(limit) {
            if limit == stdlib.None
                return pairs
            limit := AhkStdlibCollectionsCounterNormalizeMostCommonLimit(limit, pairs.Length)
            if limit < pairs.Length {
                result := []
                loop Max(limit, 0)
                    result.Push(pairs[A_Index])
                return result
            }
        }

        return pairs
    }

    copy()
    {
        copied := this.Clone()
        copied.base := this.base
        copied.AhkStdlibOrder := this.AhkStdlibOrder.Clone()
        return copied
    }

    get(args*)
    {
        if args.Length < 1
            throw TypeError("get expected at least 1 argument, got 0", -1)
        if args.Length > 2
            throw TypeError("get expected at most 2 arguments, got " args.Length, -1)

        key := args[1]
        if this.Has(key)
            return this[key]
        return args.Length = 2 ? args[2] : stdlib.None
    }

    setdefault(args*)
    {
        if args.Length < 1
            throw TypeError("setdefault expected at least 1 argument, got 0", -1)
        if args.Length > 2
            throw TypeError("setdefault expected at most 2 arguments, got " args.Length, -1)

        key := args[1]
        if this.Has(key)
            return this[key]

        defaultValue := args.Length = 2 ? args[2] : stdlib.None
        this[key] := defaultValue
        return defaultValue
    }

    pop(args*)
    {
        if args.Length < 1
            throw TypeError("pop expected at least 1 argument, got 0", -1)
        if args.Length > 2
            throw TypeError("pop expected at most 2 arguments, got " args.Length, -1)

        key := args[1]
        if this.Has(key) {
            value := super.Get(key)
            this.Delete(key)
            return value
        }

        if args.Length = 2
            return args[2]
        throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
    }

    popitem(args*)
    {
        if args.Length > 0
            throw TypeError("dict.popitem() takes no arguments (" args.Length " given)", -1)

        key := unset
        loop this.AhkStdlibOrder.Length {
            candidate := this.AhkStdlibOrder[this.AhkStdlibOrder.Length - A_Index + 1]
            if this.Has(candidate) {
                key := candidate
                break
            }
        }

        if !IsSet(key)
            throw KeyError("'popitem(): dictionary is empty'", -1)

        value := super.Get(key)
        this.Delete(key)
        return stdlib.tuple([key, value])
    }

    __Enum(numberOfVars)
    {
        self := this
        index := 1

        if numberOfVars = 1
            return NextKey
        return NextPair

        NextKey(&key)
        {
            while index <= self.AhkStdlibOrder.Length {
                candidate := self.AhkStdlibOrder[index]
                index += 1
                if self.Has(candidate) {
                    key := candidate
                    return true
                }
            }
            return false
        }

        NextPair(&key, &value)
        {
            while index <= self.AhkStdlibOrder.Length {
                candidate := self.AhkStdlibOrder[index]
                index += 1
                if self.Has(candidate) {
                    key := candidate
                    value := self[candidate]
                    return true
                }
            }
            return false
        }
    }

    __Repr()
    {
        if this.Count = 0
            return "Counter()"

        try {
            pairs := this.most_common()
        } catch TypeError {
            pairs := []
            for key in this.AhkStdlibOrder {
                if this.Has(key)
                    pairs.Push([key, this[key]])
            }
        }
        parts := []
        for pair in pairs
            parts.Push(AhkStdlibCollectionsCounterValueRepr(pair[1]) ": " AhkStdlibCollectionsCounterValueRepr(pair[2]))
        return "Counter({" AhkStdlibCollectionsJoin(parts, ", ") "})"
    }

    AhkStdlibCounterAdd(other)
    {
        return AhkStdlibCollectionsCounterBinary(this, other, "add")
    }

    AhkStdlibCounterSub(other)
    {
        return AhkStdlibCollectionsCounterBinary(this, other, "sub")
    }

    AhkStdlibCounterAnd(other)
    {
        return AhkStdlibCollectionsCounterBinary(this, other, "and")
    }

    AhkStdlibCounterOr(other)
    {
        if other is Map && !(other is AhkStdlibCollectionsCounter)
            return AhkStdlibCollectionsCounterMapUnion(this, other)
        return AhkStdlibCollectionsCounterBinary(this, other, "or")
    }

    AhkStdlibCounterPos()
    {
        return AhkStdlibCollectionsCounterUnary(this, "pos")
    }

    AhkStdlibCounterNeg()
    {
        return AhkStdlibCollectionsCounterUnary(this, "neg")
    }

    AhkStdlibCounterCompare(operation, other)
    {
        return AhkStdlibCollectionsCounterCompare(this, other, operation)
    }

    Delete(key)
    {
        if !this.Has(key)
            throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
        super.Delete(key)
        this.AhkStdlibForgetKey(key)
    }

    Clear()
    {
        if this.Count > 0
            this.AhkStdlibKeyMutationVersion += 1
        super.Clear()
        this.AhkStdlibOrder := []
        return stdlib.None
    }

    AhkStdlibRememberKey(key)
    {
        if this.Has(key)
            return
        this.AhkStdlibOrder.Push(key)
        this.AhkStdlibKeyMutationVersion += 1
    }

    AhkStdlibForgetKey(key)
    {
        nextOrder := []
        for item in this.AhkStdlibOrder {
            if item != key
                nextOrder.Push(item)
        }
        this.AhkStdlibOrder := nextOrder
        this.AhkStdlibKeyMutationVersion += 1
    }
}

class AhkStdlibCollectionsDeque
{
    __New(iterable := unset, maxlen := unset)
    {
        this.AhkStdlibItems := []
        this.maxlen := IsSet(maxlen) && !AhkStdlibIsNone(maxlen) ? maxlen : stdlib.None
        if IsSet(iterable) && !AhkStdlibIsNone(iterable) {
            for value in AhkStdlibCollectionsIterableItems(iterable)
                this.append(value)
        }
    }

    Length
    {
        get => this.AhkStdlibItems.Length
    }

    __Item[index]
    {
        get => this.AhkStdlibItems[AhkStdlibCollectionsSequenceIndex(this.AhkStdlibItems.Length, index)]
        set => this.AhkStdlibItems[AhkStdlibCollectionsSequenceIndex(this.AhkStdlibItems.Length, index)] := value
    }

    append(value)
    {
        if this.AhkStdlibMaxlenIsZero()
            return
        while this.AhkStdlibHasMaxlen() && this.AhkStdlibItems.Length >= this.maxlen
            this.AhkStdlibItems.RemoveAt(1)
        this.AhkStdlibItems.Push(value)
    }

    appendleft(value)
    {
        if this.AhkStdlibMaxlenIsZero()
            return
        while this.AhkStdlibHasMaxlen() && this.AhkStdlibItems.Length >= this.maxlen
            this.AhkStdlibItems.Pop()
        this.AhkStdlibItems.InsertAt(1, value)
    }

    extend(iterable)
    {
        for value in AhkStdlibCollectionsIterableItems(iterable)
            this.append(value)
    }

    extendleft(iterable)
    {
        for value in AhkStdlibCollectionsIterableItems(iterable)
            this.appendleft(value)
    }

    pop()
    {
        if this.AhkStdlibItems.Length = 0
            throw IndexError("pop from an empty deque", -1)
        return this.AhkStdlibItems.Pop()
    }

    popleft()
    {
        if this.AhkStdlibItems.Length = 0
            throw IndexError("pop from an empty deque", -1)
        return this.AhkStdlibItems.RemoveAt(1)
    }

    rotate(n := 1)
    {
        length := this.AhkStdlibItems.Length
        if length = 0
            return
        while n > 0 {
            this.AhkStdlibItems.InsertAt(1, this.AhkStdlibItems.Pop())
            n -= 1
        }
        while n < 0 {
            this.AhkStdlibItems.Push(this.AhkStdlibItems.RemoveAt(1))
            n += 1
        }
    }

    clear()
    {
        this.AhkStdlibItems := []
    }

    __Enum(numberOfVars)
    {
        return this.AhkStdlibItems.__Enum(numberOfVars)
    }

    AhkStdlibHasMaxlen()
    {
        return !AhkStdlibIsNone(this.maxlen)
    }

    AhkStdlibMaxlenIsZero()
    {
        return this.AhkStdlibHasMaxlen() && this.maxlen = 0
    }
}

class AhkStdlibCollectionsOrderedMapBase
{
    __New(source := unset)
    {
        this.AhkStdlibStorage := Map()
        this.AhkStdlibOrder := []
        if IsSet(source) && !AhkStdlibIsNone(source)
            this.update(source)
    }

    Count
    {
        get => this.AhkStdlibStorage.Count
    }

    __Item[key]
    {
        get => this.AhkStdlibGet(key)
        set => this.AhkStdlibSet(key, value)
    }

    Has(key)
    {
        return this.AhkStdlibStorage.Has(key)
    }

    get(key, defaultValue := unset)
    {
        if this.Has(key)
            return this[key]
        return IsSet(defaultValue) ? defaultValue : stdlib.None
    }

    update(source)
    {
        for pair in AhkStdlibCollectionsMappingPairs(source)
            this.AhkStdlibSet(pair[1], pair[2])
    }

    items()
    {
        return AhkStdlibCollectionsMappingPairs(this)
    }

    Delete(key)
    {
        if !this.AhkStdlibStorage.Has(key)
            throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
        this.AhkStdlibStorage.Delete(key)
        this.AhkStdlibForgetKey(key)
    }

    Clear()
    {
        this.AhkStdlibStorage.Clear()
        this.AhkStdlibOrder := []
    }

    __Enum(numberOfVars)
    {
        self := this
        index := 1
        if numberOfVars = 1
            return NextKey
        return NextPair

        NextKey(&key)
        {
            while index <= self.AhkStdlibOrder.Length {
                candidate := self.AhkStdlibOrder[index]
                index += 1
                if self.AhkStdlibStorage.Has(candidate) {
                    key := candidate
                    return true
                }
            }
            return false
        }

        NextPair(&key, &value)
        {
            while index <= self.AhkStdlibOrder.Length {
                candidate := self.AhkStdlibOrder[index]
                index += 1
                if self.AhkStdlibStorage.Has(candidate) {
                    key := candidate
                    value := self.AhkStdlibStorage[candidate]
                    return true
                }
            }
            return false
        }
    }

    AhkStdlibGet(key)
    {
        return this.AhkStdlibStorage[key]
    }

    AhkStdlibSet(key, value)
    {
        if !this.AhkStdlibStorage.Has(key)
            this.AhkStdlibOrder.Push(key)
        this.AhkStdlibStorage[key] := value
        return value
    }

    AhkStdlibForgetKey(key)
    {
        nextOrder := []
        for item in this.AhkStdlibOrder {
            if item != key
                nextOrder.Push(item)
        }
        this.AhkStdlibOrder := nextOrder
    }
}

class AhkStdlibCollectionsDefaultDict extends AhkStdlibCollectionsOrderedMapBase
{
    __New(default_factory := unset, source := unset)
    {
        this.default_factory := IsSet(default_factory) ? default_factory : stdlib.None
        super.__New(source?)
    }

    AhkStdlibGet(key)
    {
        if this.AhkStdlibStorage.Has(key)
            return this.AhkStdlibStorage[key]
        if AhkStdlibIsNone(this.default_factory)
            throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
        value := this.default_factory.Call()
        this.AhkStdlibSet(key, value)
        return value
    }
}

class AhkStdlibCollectionsOrderedDict extends AhkStdlibCollectionsOrderedMapBase
{
    move_to_end(key, last := true)
    {
        if !this.AhkStdlibStorage.Has(key)
            throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
        value := this.AhkStdlibStorage[key]
        this.AhkStdlibForgetKey(key)
        if last
            this.AhkStdlibOrder.Push(key)
        else
            this.AhkStdlibOrder.InsertAt(1, key)
        this.AhkStdlibStorage[key] := value
    }

    popitem(last := true)
    {
        if this.AhkStdlibOrder.Length = 0
            throw KeyError("'dictionary is empty'", -1)
        index := last ? this.AhkStdlibOrder.Length : 1
        key := this.AhkStdlibOrder[index]
        value := this.AhkStdlibStorage[key]
        this.AhkStdlibOrder.RemoveAt(index)
        this.AhkStdlibStorage.Delete(key)
        return stdlib.tuple([key, value])
    }
}

class AhkStdlibCollectionsChainMap
{
    __New(maps*)
    {
        this.maps := []
        if maps.Length = 0 {
            this.maps.Push(Map())
            return
        }
        for mapping in maps
            this.maps.Push(mapping)
    }

    __Item[key]
    {
        get {
            for mapping in this.maps {
                if AhkStdlibCollectionsMappingHas(mapping, key)
                    return AhkStdlibCollectionsMappingGet(mapping, key)
            }
            throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
        }
        set {
            AhkStdlibCollectionsMappingSet(this.maps[1], key, value)
            return value
        }
    }

    new_child(mapping := unset)
    {
        childMaps := [IsSet(mapping) ? mapping : Map()]
        for existing in this.maps
            childMaps.Push(existing)
        return AhkStdlibCollectionsChainMap(childMaps*)
    }

    __Enum(numberOfVars)
    {
        keys := []
        seen := Map()
        for mapping in this.maps {
            for key, value in AhkStdlibCollectionsMappingPairs(mapping) {
                if !seen.Has(key) {
                    seen[key] := true
                    keys.Push(key)
                }
            }
        }
        index := 1
        self := this
        if numberOfVars = 1
            return NextKey
        return NextPair

        NextKey(&key)
        {
            if index > keys.Length
                return false
            key := keys[index]
            index += 1
            return true
        }

        NextPair(&key, &value)
        {
            if index > keys.Length
                return false
            key := keys[index]
            value := self[key]
            index += 1
            return true
        }
    }
}

class AhkStdlibCollectionsNamedTupleType
{
    __New(typename, fieldNames, options := unset)
    {
        this.__name := typename
        this._fields := AhkStdlibCollectionsNamedTupleFields(fieldNames)
        this.AhkStdlibFieldIndex := Map()
        for index, field in this._fields
            this.AhkStdlibFieldIndex[field] := index
    }

    Call(values*)
    {
        if values.Length != this._fields.Length
            throw TypeError(this.__name ".__new__() expected " this._fields.Length " argument(s), got " values.Length, -1)
        return AhkStdlibCollectionsNamedTupleValue(this, values)
    }

    _make(iterable)
    {
        values := AhkStdlibCollectionsIterableItems(iterable)
        return this.Call(values*)
    }
}

class AhkStdlibCollectionsNamedTupleValue extends AhkStdlibTuple
{
    __New(tupleType, values)
    {
        this.AhkStdlibNamedTupleType := tupleType
        super.__New(values)
    }

    __Get(name, params)
    {
        if this.AhkStdlibNamedTupleType.AhkStdlibFieldIndex.Has(name)
            return this[this.AhkStdlibNamedTupleType.AhkStdlibFieldIndex[name]]
        throw AttributeError("'" this.AhkStdlibNamedTupleType.__name "' object has no attribute '" name "'", -1)
    }

    _asdict()
    {
        result := AhkStdlibCollectionsOrderedDict()
        for index, field in this.AhkStdlibNamedTupleType._fields
            result[field] := this[index]
        return result
    }

    _replace(options := unset)
    {
        values := []
        for value in this
            values.Push(value)
        replacements := AhkStdlibCollectionsKwargsFromOptions(options)
        for field, value in replacements {
            if !this.AhkStdlibNamedTupleType.AhkStdlibFieldIndex.Has(field)
                throw ValueError("Got unexpected field names: " field, -1)
            values[this.AhkStdlibNamedTupleType.AhkStdlibFieldIndex[field]] := value
        }
        return AhkStdlibCollectionsNamedTupleValue(this.AhkStdlibNamedTupleType, values)
    }
}

class AhkStdlibCollectionsUserDict extends AhkStdlibCollectionsOrderedMapBase
{
    __New(source := unset)
    {
        super.__New(source?)
        this.data := this.AhkStdlibStorage
    }
}

class AhkStdlibCollectionsUserList
{
    __New(initlist := unset)
    {
        this.data := []
        if IsSet(initlist) && !AhkStdlibIsNone(initlist) {
            for value in AhkStdlibCollectionsIterableItems(initlist)
                this.data.Push(value)
        }
    }

    Length
    {
        get => this.data.Length
    }

    __Item[index]
    {
        get => this.data[AhkStdlibCollectionsSequenceIndex(this.data.Length, index)]
        set => this.data[AhkStdlibCollectionsSequenceIndex(this.data.Length, index)] := value
    }

    append(value)
    {
        this.data.Push(value)
    }

    __Enum(numberOfVars)
    {
        return this.data.__Enum(numberOfVars)
    }
}

class AhkStdlibCollectionsUserString
{
    __New(seq := "")
    {
        this.data := String(seq)
    }

    ToString()
    {
        return this.data
    }

    upper()
    {
        return AhkStdlibCollectionsUserString(StrUpper(this.data))
    }
}

AhkStdlibCollectionsCounterNormalizeMostCommonLimit(limit, pairCount)
{
    if AhkStdlibIsBool(limit)
        return limit.Value ? 1 : 0
    if limit is Integer
        return limit
    if limit is Float {
        if limit = 1
            return 1
        if limit >= pairCount
            throw TypeError("slice indices must be integers or None or have an __index__ method", -1)
        throw TypeError("'" AhkStdlibCollectionsCounterTypeName(limit) "' object cannot be interpreted as an integer", -1)
    }
    if Type(limit) = "AhkStdlibFractionsFractionValue" {
        if limit.denominator = 1 && limit.numerator = 1
            return 1
        if limit.denominator = 1 && limit.numerator >= pairCount
            throw TypeError("slice indices must be integers or None or have an __index__ method", -1)
        throw TypeError("'" AhkStdlibCollectionsCounterTypeName(limit) "' object cannot be interpreted as an integer", -1)
    }
    if Type(limit) = "AhkStdlibDecimalValue" {
        normalized := limit.normalize()
        if normalized.exponent >= 0 {
            integerText := normalized.ToString()
            if integerText = "1"
                return 1
            if Integer(integerText) >= pairCount
                throw TypeError("slice indices must be integers or None or have an __index__ method", -1)
        }
        throw TypeError("'" AhkStdlibCollectionsCounterTypeName(limit) "' object cannot be interpreted as an integer", -1)
    }
    if limit is String
        throw TypeError(AhkStdlibCollectionsCounterCountComparisonError(">=", limit, 0), -1)
    if IsObject(limit)
        throw TypeError(AhkStdlibCollectionsCounterCountComparisonError(">=", limit, 0), -1)
    throw TypeError("'" AhkStdlibCollectionsCounterTypeName(limit) "' object cannot be interpreted as an integer", -1)
}

class AhkStdlibCollectionsCounterElements
{
    __New(counter)
    {
        this.Counter := counter
        this.ExpectedCount := counter.Count
        this.ExpectedOrder := AhkStdlibCollectionsCopyOrder(counter.AhkStdlibOrder)
        this.ExpectedKeyMutationVersion := counter.AhkStdlibKeyMutationVersion
        this.KeyIndex := 1
        this.EmittedForKey := 0
        this.HasActiveCount := false
        this.ActiveCount := 0
    }

    __Repr()
    {
        return "<itertools.chain object at 0x" Format("{:X}", ObjPtr(this)) ">"
    }

    __Enum(numberOfVars)
    {
        counter := this.Counter
        return ObjBindMethod(this, "AhkStdlibNext")
    }

    AhkStdlibNext(&value)
    {
        counter := this.Counter
        if counter.Count != this.ExpectedCount
            throw Error("dictionary changed size during iteration", -1)
        if counter.AhkStdlibKeyMutationVersion != this.ExpectedKeyMutationVersion
            throw Error("dictionary keys changed during iteration", -1)
        if !AhkStdlibCollectionsOrderEquals(counter.AhkStdlibOrder, this.ExpectedOrder)
            throw Error("dictionary keys changed during iteration", -1)

        while this.KeyIndex <= counter.AhkStdlibOrder.Length {
            key := counter.AhkStdlibOrder[this.KeyIndex]
            if !counter.Has(key) {
                this.KeyIndex += 1
                this.EmittedForKey := 0
                this.HasActiveCount := false
                continue
            }

            if !this.HasActiveCount {
                count := counter[key]
                if AhkStdlibIsBool(count)
                    count := count.Value ? 1 : 0
                if Type(count) != "Integer"
                    throw TypeError("'" AhkStdlibCollectionsCounterTypeName(count) "' object cannot be interpreted as an integer", -1)
                this.ActiveCount := count
                this.HasActiveCount := true
            }

            if this.ActiveCount <= 0 || this.EmittedForKey >= this.ActiveCount {
                this.KeyIndex += 1
                this.EmittedForKey := 0
                this.HasActiveCount := false
                continue
            }

            this.EmittedForKey += 1
            value := key
            return true
        }

        return false
    }
}

stdlib.collections := AhkStdlibCollections

AhkStdlibCollectionsIsMapping(source)
{
    return source is Map || source is AhkStdlibCollectionsCounter
}

AhkStdlibCollectionsMappingItems(source)
{
    result := []
    if source is Map || source is AhkStdlibCollectionsCounter {
        for key, value in source
            result.Push([key, value])
        return result
    }

    if source is Object {
        for key, value in source.OwnProps()
            result.Push([key, value])
        return result
    }

    throw TypeError("source must be an iterable or mapping", -1)
}

AhkStdlibCollectionsIsKwargsOptions(value)
{
    return Type(value) = "Object" && HasProp(value, "kwargs")
}

AhkStdlibCollectionsCounterUpdateSource(counter, source)
{
    if AhkStdlibCollectionsIsMapping(source) {
        AhkStdlibCollectionsCounterUpdateMapping(counter, source)
        return
    }

    for value in AhkStdlibCollectionsIterableItems(source)
        counter[value] := counter[value] + 1
}

AhkStdlibCollectionsCounterUpdateMapping(counter, source)
{
    for pair in AhkStdlibCollectionsMappingItems(source) {
        key := pair[1]
        count := pair[2]
        if counter.Has(key)
            counter[key] := AhkStdlibCollectionsCounterUpdateCount(count, counter[key])
        else
            counter[key] := count
    }
}

AhkStdlibCollectionsCounterSubtractSource(counter, source)
{
    if AhkStdlibCollectionsIsMapping(source) {
        AhkStdlibCollectionsCounterSubtractMapping(counter, source)
        return
    }

    for value in AhkStdlibCollectionsIterableItems(source)
        counter[value] := counter[value] - 1
}

AhkStdlibCollectionsCounterSubtractMapping(counter, source)
{
    for pair in AhkStdlibCollectionsMappingItems(source) {
        key := pair[1]
        count := pair[2]
        if counter.Has(key)
            counter[key] := AhkStdlibCollectionsCounterSubtractCount(counter[key], count)
        else
            counter[key] := AhkStdlibCollectionsCounterRightOnlySubtractCount(count)
    }
}

AhkStdlibCollectionsCounterMapUnion(left, right)
{
    result := Map()

    for pair in AhkStdlibCollectionsMappingItems(left)
        result[pair[1]] := pair[2]
    for pair in AhkStdlibCollectionsMappingItems(right) {
        key := pair[1]
        value := pair[2]
        if result.Has(key)
            result[key] := value
        else
            result[key] := value
    }

    return result
}

AhkStdlibCollectionsCounterBinary(left, right, operation)
{
    AhkStdlibCollectionsRequireCounterOperand(right, operation)
    result := AhkStdlibCollectionsCounter()

    for key in left.AhkStdlibOrder {
        if !left.Has(key)
            continue
        AhkStdlibCollectionsCounterSetIfPositive(result, key, AhkStdlibCollectionsCounterBinaryCount(left, right, key, operation), operation)
    }

    for key in right.AhkStdlibOrder {
        if !right.Has(key) || left.Has(key)
            continue
        if operation = "and"
            continue
        if operation = "add" || operation = "or" {
            AhkStdlibCollectionsCounterSetIfPositive(result, key, right[key], operation)
            continue
        }
        if operation = "sub" {
            rightCount := right[key]
            comparisonCount := AhkStdlibCollectionsCounterBoolAsInt(rightCount)
            try {
                if comparisonCount < 0 {
                    AhkStdlibCollectionsCounterSetIfPositive(result, key, AhkStdlibCollectionsCounterRightOnlySubtractCount(rightCount), operation)
                    continue
                }
                continue
            } catch TypeError {
                throw TypeError(AhkStdlibCollectionsCounterUnaryBinaryTypeError("and", rightCount, 0), -1)
            }
            continue
        }
        AhkStdlibCollectionsCounterSetIfPositive(result, key, AhkStdlibCollectionsCounterBinaryCount(left, right, key, operation), operation)
    }

    return result
}

AhkStdlibCollectionsCounterBinaryCount(left, right, key, operation)
{
    originalLeftCount := left[key]
    originalRightCount := right[key]
    leftCount := originalLeftCount
    rightCount := originalRightCount
    AhkStdlibCollectionsCounterNormalizeBoolArithmeticPair(&leftCount, &rightCount)

    switch operation {
        case "add":
            return AhkStdlibCollectionsCounterAddLikePython(originalLeftCount, originalRightCount)
        case "sub":
            return AhkStdlibCollectionsCounterSubtractLikePython(originalLeftCount, originalRightCount)
        case "and":
            comparison := AhkStdlibCollectionsCounterMostCommonCompare(leftCount, rightCount)
            return comparison < 0 ? originalLeftCount : originalRightCount
        case "or":
            comparison := AhkStdlibCollectionsCounterMostCommonCompare(leftCount, rightCount)
            return comparison < 0 ? originalRightCount : originalLeftCount
    }

    throw ValueError("unknown Counter operation", -1)
}

AhkStdlibCollectionsCounterUnary(counter, operation)
{
    result := AhkStdlibCollectionsCounter()
    for key in counter.AhkStdlibOrder {
        if !counter.Has(key)
            continue
        originalCount := counter[key]
        try {
            count := operation = "neg" ? AhkStdlibCollectionsCounterRightOnlySubtractCount(originalCount) : originalCount
        } catch TypeError {
            throw TypeError(AhkStdlibCollectionsCounterUnaryTypeError(operation, originalCount), -1)
        }
        AhkStdlibCollectionsCounterSetIfPositive(result, key, count, operation)
    }
    return result
}

AhkStdlibCollectionsCounterSetIfPositive(counter, key, count, operation := "")
{
    comparisonCount := AhkStdlibCollectionsCounterBoolAsInt(count)
    try {
        if AhkStdlibCollectionsCounterIsPositiveCount(comparisonCount)
            counter[key] := count
    } catch TypeError {
        if operation = "add" || operation = "or"
            throw TypeError(AhkStdlibCollectionsCounterUnaryTypeError("pos", count), -1)
        if operation = "pos" || operation = "neg"
            throw TypeError(AhkStdlibCollectionsCounterUnaryTypeError(operation, count), -1)
        if operation = "and"
            throw TypeError(AhkStdlibCollectionsCounterUnaryTypeError("pos", count), -1)
        throw
    }
}

AhkStdlibCollectionsCounterCompare(left, right, operation)
{
    if !(right is AhkStdlibCollectionsCounter) {
        if right is Map && (operation = "eq" || operation = "ne") {
            equal := AhkStdlibCollectionsCounterEqualsMap(left, right)
            return operation = "eq" ? equal : !equal
        }
        if operation = "eq"
            return false
        if operation = "ne"
            return true
        throw TypeError(AhkStdlibCollectionsCounterComparisonError(operation, left, right), -1)
    }

    equal := true
    lessOrEqual := true
    greaterOrEqual := true

    for key in left.AhkStdlibOrder {
        if left.Has(key)
            AhkStdlibCollectionsCounterCompareCounts(operation, left[key], right[key], &equal, &lessOrEqual, &greaterOrEqual)
    }

    for key in right.AhkStdlibOrder {
        if right.Has(key) && !left.Has(key)
            AhkStdlibCollectionsCounterCompareCounts(operation, left[key], right[key], &equal, &lessOrEqual, &greaterOrEqual)
    }

    switch operation {
        case "eq":
            return equal
        case "ne":
            return !equal
        case "le":
            return lessOrEqual
        case "lt":
            return lessOrEqual && !equal
        case "ge":
            return greaterOrEqual
        case "gt":
            return greaterOrEqual && !equal
    }

    throw ValueError("unknown Counter comparison", -1)
}

AhkStdlibCollectionsCounterCompareCounts(operation, leftCount, rightCount, &equal, &lessOrEqual, &greaterOrEqual)
{
    if !AhkStdlibCollectionsCounterValueEquals(leftCount, rightCount)
        equal := false
    if operation = "eq" || operation = "ne"
        return
    try {
        comparison := AhkStdlibCollectionsCounterMostCommonCompare(leftCount, rightCount)
        if comparison > 0
            lessOrEqual := false
        if comparison < 0
            greaterOrEqual := false
    } catch TypeError {
        throw TypeError(AhkStdlibCollectionsCounterCountComparisonError(AhkStdlibCollectionsCounterCountCompareSymbol(operation), leftCount, rightCount), -1)
    }
}

AhkStdlibCollectionsCounterMostCommonComesFirst(leftCount, rightCount)
{
    comparison := AhkStdlibCollectionsCounterMostCommonCompare(leftCount, rightCount)
    return comparison > 0
}

; Stable descending-by-count sort. Python's Counter.most_common preserves the
; insertion order of equal-count elements, so a stable merge sort is required
; (the previous bubble sort was stable but O(n^2)).
AhkStdlibCollectionsCounterSortByCount(pairs)
{
    n := pairs.Length
    if n < 2
        return pairs
    buffer := []
    buffer.Length := n
    width := 1
    while width < n {
        i := 1
        while i <= n {
            left := i
            mid := Min(i + width, n + 1)
            right := Min(i + 2 * width, n + 1)
            AhkStdlibCollectionsCounterMerge(pairs, buffer, left, mid, right)
            i += 2 * width
        }
        width *= 2
    }
    return pairs
}

AhkStdlibCollectionsCounterMerge(pairs, buffer, left, mid, right)
{
    i := left
    j := mid
    k := left
    while i < mid && j < right {
        ; Stable: take from the left run unless the right run strictly precedes.
        if AhkStdlibCollectionsCounterMostCommonComesFirst(pairs[j][2], pairs[i][2])
            buffer[k++] := pairs[j++]
        else
            buffer[k++] := pairs[i++]
    }
    while i < mid
        buffer[k++] := pairs[i++]
    while j < right
        buffer[k++] := pairs[j++]
    p := left
    while p < right {
        pairs[p] := buffer[p]
        p++
    }
}

AhkStdlibCollectionsCounterValueRepr(value)
{
    if AhkStdlibIsNone(value)
        return "None"
    if AhkStdlibIsBool(value)
        return value.Value ? "True" : "False"
    if HasMethod(value, "__Repr")
        return value.__Repr()
    if HasMethod(value, "Call")
        return "<function " AhkStdlibCollectionsCallableDisplayName(value) " at 0x" Format("{:X}", ObjPtr(value)) ">"
    if value is String
        return AhkStdlibCollectionsStringRepr(value)
    if value is AhkStdlibTuple
        return AhkStdlibCollectionsTupleRepr(value)
    if value is Array
        return AhkStdlibCollectionsArrayRepr(value)
    if value is Map
        return AhkStdlibCollectionsMapRepr(value)
    if IsObject(value)
        return "<" Type(value) " object at 0x" Format("{:X}", ObjPtr(value)) ">"
    return String(value)
}

AhkStdlibCollectionsCallableDisplayName(callback)
{
    if HasProp(callback, "Name")
        return callback.Name
    return Type(callback)
}

AhkStdlibCollectionsStringRepr(value)
{
    escaped := StrReplace(value, "\", "\\")
    escaped := StrReplace(escaped, "`n", "\n")
    escaped := StrReplace(escaped, "`r", "\r")
    escaped := StrReplace(escaped, "`t", "\t")
    escaped := StrReplace(escaped, "'", "\'")
    if InStr(escaped, "\'") && !InStr(escaped, '"')
        return '"' StrReplace(escaped, "\'", "'") '"'
    return "'" escaped "'"
}

AhkStdlibCollectionsArrayRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibCollectionsCounterValueRepr(value))
    return "[" AhkStdlibCollectionsJoin(parts, ", ") "]"
}

AhkStdlibCollectionsTupleRepr(values)
{
    parts := []
    for value in values
        parts.Push(AhkStdlibCollectionsCounterValueRepr(value))
    if parts.Length = 1
        return "(" parts[1] ",)"
    return "(" AhkStdlibCollectionsJoin(parts, ", ") ")"
}

AhkStdlibCollectionsMapRepr(mapping)
{
    parts := []
    for key, value in mapping
        parts.Push(AhkStdlibCollectionsCounterValueRepr(key) ": " AhkStdlibCollectionsCounterValueRepr(value))
    return "{" AhkStdlibCollectionsJoin(parts, ", ") "}"
}

AhkStdlibCollectionsJoin(values, separator)
{
    text := ""
    for index, value in values {
        if index > 1
            text .= separator
        text .= value
    }
    return text
}

AhkStdlibCollectionsCounterMostCommonCompare(leftCount, rightCount)
{
    AhkStdlibCollectionsCounterNormalizeBoolOrderPair(&leftCount, &rightCount)

    if !IsObject(leftCount) && !IsObject(rightCount) {
        if leftCount is Number && rightCount is Number
            return leftCount = rightCount ? 0 : (leftCount > rightCount ? 1 : -1)
        if leftCount is String && rightCount is String
            return StrCompare(leftCount, rightCount)
        throw TypeError(AhkStdlibCollectionsCounterCountComparisonError("<", leftCount, rightCount), -1)
    }

    if leftCount is Array && rightCount is Array {
        if AhkStdlibCollectionsCounterValueEquals(leftCount, rightCount)
            return 0
        sharedLength := Min(leftCount.Length, rightCount.Length)
        loop sharedLength {
            itemComparison := AhkStdlibCollectionsCounterMostCommonCompare(leftCount[A_Index], rightCount[A_Index])
            if itemComparison != 0
                return itemComparison
        }
        if leftCount.Length = rightCount.Length
            return 0
        return leftCount.Length > rightCount.Length ? 1 : -1
    }

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" && Type(rightCount) = "AhkStdlibFractionsFractionValue"
        return leftCount.__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibDecimalValue" && Type(rightCount) = "AhkStdlibDecimalValue"
        return leftCount.__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" && rightCount is Integer
        return leftCount.__Compare(rightCount, "lt")

    if leftCount is Integer && Type(rightCount) = "AhkStdlibFractionsFractionValue"
        return stdlib.fractions.Fraction(leftCount, 1).__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" && rightCount is Float
        return leftCount.__Compare(stdlib.fractions.Fraction.from_float(rightCount), "lt")

    if leftCount is Float && Type(rightCount) = "AhkStdlibFractionsFractionValue"
        return stdlib.fractions.Fraction.from_float(leftCount).__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibDecimalValue" && rightCount is Integer
        return leftCount.__Compare(rightCount, "lt")

    if leftCount is Integer && Type(rightCount) = "AhkStdlibDecimalValue"
        return stdlib.decimal.Decimal(leftCount).__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibDecimalValue" && rightCount is Float
        return leftCount.__Compare(stdlib.decimal.Decimal(String(rightCount)), "lt")

    if leftCount is Float && Type(rightCount) = "AhkStdlibDecimalValue"
        return stdlib.decimal.Decimal(String(leftCount)).__Compare(rightCount, "lt")

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" && Type(rightCount) = "AhkStdlibDecimalValue"
        return rightCount.__Compare(leftCount, "lt") * -1

    if Type(leftCount) = "AhkStdlibDecimalValue" && Type(rightCount) = "AhkStdlibFractionsFractionValue"
        return leftCount.__Compare(rightCount, "lt")

    throw TypeError(AhkStdlibCollectionsCounterCountComparisonError("<", leftCount, rightCount), -1)
}

AhkStdlibCollectionsCounterEqualsMap(counter, mapping)
{
    if counter.Count != mapping.Count
        return false

    for key, value in counter {
        if !mapping.Has(key) || !AhkStdlibCollectionsCounterValueEquals(mapping[key], value)
            return false
    }

    return true
}

AhkStdlibCollectionsCounterValueEquals(left, right)
{
    left := AhkStdlibCollectionsCounterBoolAsInt(left)
    right := AhkStdlibCollectionsCounterBoolAsInt(right)

    if Type(left) = "AhkStdlibFractionsFractionValue" && right is Integer
        return left.__Compare(right, "eq") = 0
    if left is Integer && Type(right) = "AhkStdlibFractionsFractionValue"
        return stdlib.fractions.Fraction(left, 1).__Compare(right, "eq") = 0
    if Type(left) = "AhkStdlibFractionsFractionValue" && right is Float
        return left.__Compare(stdlib.fractions.Fraction.from_float(right), "eq") = 0
    if left is Float && Type(right) = "AhkStdlibFractionsFractionValue"
        return stdlib.fractions.Fraction.from_float(left).__Compare(right, "eq") = 0

    if Type(left) = "AhkStdlibDecimalValue" && right is Integer
        return left.__Compare(right, "eq") = 0
    if left is Integer && Type(right) = "AhkStdlibDecimalValue"
        return stdlib.decimal.Decimal(left).__Compare(right, "eq") = 0
    if Type(left) = "AhkStdlibDecimalValue" && right is Float
        return left.__Compare(stdlib.decimal.Decimal(String(right)), "eq") = 0
    if left is Float && Type(right) = "AhkStdlibDecimalValue"
        return stdlib.decimal.Decimal(String(left)).__Compare(right, "eq") = 0

    if Type(left) = "AhkStdlibFractionsFractionValue" && Type(right) = "AhkStdlibDecimalValue"
        return right.__Compare(left, "eq") = 0
    if Type(left) = "AhkStdlibDecimalValue" && Type(right) = "AhkStdlibFractionsFractionValue"
        return left.__Compare(right, "eq") = 0

    if IsObject(left) || IsObject(right) {
        if !IsObject(left) || !IsObject(right)
            return false

        if left is Array && right is Array {
            if left.Length != right.Length
                return false
            loop left.Length {
                if !AhkStdlibCollectionsCounterValueEquals(left[A_Index], right[A_Index])
                    return false
            }
            return true
        }

        if left is Map && right is Map {
            if left.Count != right.Count
                return false
            for key, leftValue in left {
                if !right.Has(key)
                    return false
                if !AhkStdlibCollectionsCounterValueEquals(leftValue, right[key])
                    return false
            }
            return true
        }

        return left == right
    }

    return left == right
}

AhkStdlibCollectionsCounterBoolAsInt(value)
{
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    return value
}

AhkStdlibCollectionsCounterNormalizeBoolArithmeticPair(&left, &right)
{
    if AhkStdlibIsBool(left) && AhkStdlibCollectionsCounterIsArithmeticNumericLike(right)
        left := AhkStdlibCollectionsCounterBoolAsInt(left)
    if AhkStdlibIsBool(right) && AhkStdlibCollectionsCounterIsArithmeticNumericLike(left)
        right := AhkStdlibCollectionsCounterBoolAsInt(right)
}

AhkStdlibCollectionsCounterNormalizeBoolOrderPair(&left, &right)
{
    if AhkStdlibIsBool(left) && AhkStdlibCollectionsCounterIsOrderNumericLike(right)
        left := AhkStdlibCollectionsCounterBoolAsInt(left)
    if AhkStdlibIsBool(right) && AhkStdlibCollectionsCounterIsOrderNumericLike(left)
        right := AhkStdlibCollectionsCounterBoolAsInt(right)
}

AhkStdlibCollectionsCounterIsArithmeticNumericLike(value)
{
    return AhkStdlibIsBool(value)
        || value is Integer
        || value is Float
        || Type(value) = "AhkStdlibFractionsFractionValue"
        || Type(value) = "AhkStdlibDecimalValue"
}

AhkStdlibCollectionsCounterIsOrderNumericLike(value)
{
    return AhkStdlibCollectionsCounterIsArithmeticNumericLike(value)
}

AhkStdlibCollectionsCounterIsPositiveCount(count)
{
    if Type(count) = "AhkStdlibFractionsFractionValue"
        return count.__Compare(0, "lt") > 0
    if Type(count) = "AhkStdlibDecimalValue"
        return count.__Compare(0, "lt") > 0
    return count > 0
}

AhkStdlibCollectionsRequireCounterOperand(value, operation)
{
    if value is AhkStdlibCollectionsCounter
        return

    symbol := AhkStdlibCollectionsCounterOperationSymbol(operation)
    throw TypeError("unsupported operand type(s) for " symbol ": 'Counter' and '" AhkStdlibCollectionsCounterOperandTypeName(value) "'", -1)
}

AhkStdlibCollectionsCounterComparisonError(operation, left, right)
{
    symbol := AhkStdlibCollectionsCounterOperationSymbol(operation)
    return "'" symbol "' not supported between instances of '" AhkStdlibCollectionsCounterComparisonTypeName(left) "' and '" AhkStdlibCollectionsCounterComparisonTypeName(right) "'"
}

AhkStdlibCollectionsCounterOperationSymbol(operation)
{
    switch operation {
        case "add":
            return "+"
        case "sub":
            return "-"
        case "and":
            return "&"
        case "or":
            return "|"
        case "lt":
            return "<"
        case "le":
            return "<="
        case "gt":
            return ">"
        case "ge":
            return ">="
        case "eq":
            return "=="
        case "ne":
            return "!="
    }
    return operation
}

AhkStdlibCollectionsCounterTypeName(value)
{
    typeName := Type(value)
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsBool(value)
        return "bool"
    if value is AhkStdlibCollectionsCounter
        return "Counter"
    if Type(value) = "AhkStdlibFractionsFractionValue"
        return "Fraction"
    if Type(value) = "AhkStdlibDecimalValue"
        return "decimal.Decimal"
    if value is Map
        return "dict"
    if value is Array
        return "list"
    if value is String
        return "str"
    if value is Integer
        return "int"
    if value is Float
        return "float"
    if typeName = "Func" || typeName = "BoundFunc"
        return "function"
    if IsObject(value) && typeName != "Object"
        return AhkStdlibCollectionsLeafTypeName(typeName)
    if IsObject(value)
        return "object"
    return typeName
}

AhkStdlibCollectionsCounterComparisonTypeName(value)
{
    if value is AhkStdlibCollectionsCounter
        return "Counter"
    if value is Map && Type(value) != "Map"
        return AhkStdlibCollectionsLeafTypeName(Type(value))
    return AhkStdlibCollectionsCounterTypeName(value)
}

AhkStdlibCollectionsCounterOperandTypeName(value)
{
    if value is Map && Type(value) != "Map"
        return AhkStdlibCollectionsLeafTypeName(Type(value))
    return AhkStdlibCollectionsCounterTypeName(value)
}

AhkStdlibCollectionsLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}

AhkStdlibCollectionsCounterCountComparisonError(symbol, left, right)
{
    return "'" symbol "' not supported between instances of '" AhkStdlibCollectionsCounterTypeName(left) "' and '" AhkStdlibCollectionsCounterTypeName(right) "'"
}

AhkStdlibCollectionsCounterCountCompareSymbol(operation)
{
    if operation = "gt" || operation = "ge"
        return ">="
    return "<="
}

AhkStdlibCollectionsCounterUnaryTypeError(operation, value)
{
    if operation = "neg"
        return "'<' not supported between instances of '" AhkStdlibCollectionsCounterTypeName(value) "' and 'int'"
    return "'>' not supported between instances of '" AhkStdlibCollectionsCounterTypeName(value) "' and 'int'"
}

AhkStdlibCollectionsCounterUnaryBinaryTypeError(operation, left, right)
{
    if operation = "and" || operation = "or"
        return "'<' not supported between instances of '" AhkStdlibCollectionsCounterTypeName(left) "' and '" AhkStdlibCollectionsCounterTypeName(right) "'"
    return AhkStdlibCollectionsCounterBinaryOperatorTypeError(operation, left, right)
}

AhkStdlibCollectionsCounterBinaryOperatorTypeError(operation, left, right)
{
    symbol := AhkStdlibCollectionsCounterOperationSymbol(operation)
    return "unsupported operand type(s) for " symbol ": '" AhkStdlibCollectionsCounterTypeName(left) "' and '" AhkStdlibCollectionsCounterTypeName(right) "'"
}

AhkStdlibCollectionsCounterUpdateCount(newCount, existingCount)
{
    return AhkStdlibCollectionsCounterAddLikePython(newCount, existingCount)
}

AhkStdlibCollectionsCounterSubtractCount(existingCount, newCount)
{
    return AhkStdlibCollectionsCounterSubtractLikePython(existingCount, newCount)
}

AhkStdlibCollectionsCounterRightOnlySubtractCount(count)
{
    count := AhkStdlibCollectionsCounterBoolAsInt(count)
    if Type(count) = "AhkStdlibFractionsFractionValue"
        return count.__Neg()
    if Type(count) = "AhkStdlibDecimalValue"
        return stdlib.decimal.Decimal(0).__Sub(count)
    try {
        return 0 - count
    } catch TypeError {
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("sub", 0, count), -1)
    }
}

AhkStdlibCollectionsCounterTotalCount(total, count)
{
    total := AhkStdlibCollectionsCounterBoolAsInt(total)
    count := AhkStdlibCollectionsCounterBoolAsInt(count)

    if Type(count) = "AhkStdlibFractionsFractionValue" {
        if total is Integer
            return count.__Add(total)
        if total is Float
            return total + count.to_float()
        if Type(total) = "AhkStdlibFractionsFractionValue"
            return total.__Add(count)
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", total, count), -1)
    }
    if Type(count) = "AhkStdlibDecimalValue" {
        if total is Integer
            return count.__Add(total)
        if Type(total) = "AhkStdlibDecimalValue"
            return total.__Add(count)
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", total, count), -1)
    }
    if count is Integer {
        if Type(total) = "AhkStdlibFractionsFractionValue"
            return total.__Add(count)
        if Type(total) = "AhkStdlibDecimalValue"
            return total.__Add(count)
    }
    if count is Float {
        if Type(total) = "AhkStdlibFractionsFractionValue"
            return total.to_float() + count
        if Type(total) = "AhkStdlibDecimalValue"
            throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", total, count), -1)
    }

    try {
        return total + count
    } catch TypeError {
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", total, count), -1)
    }
}

AhkStdlibCollectionsCounterAddLikePython(leftCount, rightCount)
{
    originalLeftCount := leftCount
    originalRightCount := rightCount
    AhkStdlibCollectionsCounterNormalizeBoolArithmeticPair(&leftCount, &rightCount)

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return leftCount.__Add(rightCount)
        if rightCount is Integer
            return leftCount.__Add(rightCount)
        if rightCount is Float
            return leftCount.to_float() + rightCount
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", originalLeftCount, originalRightCount), -1)
    }
    if leftCount is Integer {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return stdlib.fractions.Fraction(leftCount, 1).__Add(rightCount)
        if Type(rightCount) = "AhkStdlibDecimalValue"
            return stdlib.decimal.Decimal(leftCount).__Add(rightCount)
    }
    if leftCount is Float {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return leftCount + rightCount.to_float()
        if Type(rightCount) = "AhkStdlibDecimalValue"
            throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", originalLeftCount, originalRightCount), -1)
    }
    if Type(leftCount) = "AhkStdlibDecimalValue" {
        if Type(rightCount) = "AhkStdlibDecimalValue"
            return leftCount.__Add(rightCount)
        if rightCount is Integer
            return leftCount.__Add(rightCount)
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", originalLeftCount, originalRightCount), -1)
    }

    try {
        return leftCount + rightCount
    } catch TypeError {
        if originalLeftCount is String {
            if originalRightCount is String
                return originalLeftCount . originalRightCount
            throw TypeError('can only concatenate str (not "' AhkStdlibCollectionsCounterTypeName(originalRightCount) '") to str', -1)
        }
        if originalLeftCount is Array && originalRightCount is Array {
            result := originalLeftCount.Clone()
            result.Push(originalRightCount*)
            return result
        }
        if originalLeftCount is Array
            throw TypeError('can only concatenate list (not "' AhkStdlibCollectionsCounterTypeName(originalRightCount) '") to list', -1)
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("add", originalLeftCount, originalRightCount), -1)
    }
}

AhkStdlibCollectionsCounterSubtractLikePython(leftCount, rightCount)
{
    originalLeftCount := leftCount
    originalRightCount := rightCount
    AhkStdlibCollectionsCounterNormalizeBoolArithmeticPair(&leftCount, &rightCount)

    if Type(leftCount) = "AhkStdlibFractionsFractionValue" {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return leftCount.__Sub(rightCount)
        if rightCount is Integer
            return leftCount.__Sub(rightCount)
        if rightCount is Float
            return leftCount.to_float() - rightCount
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("sub", originalLeftCount, originalRightCount), -1)
    }
    if leftCount is Integer {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return stdlib.fractions.Fraction(leftCount, 1).__Sub(rightCount)
        if Type(rightCount) = "AhkStdlibDecimalValue"
            return stdlib.decimal.Decimal(leftCount).__Sub(rightCount)
    }
    if leftCount is Float {
        if Type(rightCount) = "AhkStdlibFractionsFractionValue"
            return leftCount - rightCount.to_float()
        if Type(rightCount) = "AhkStdlibDecimalValue"
            throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("sub", originalLeftCount, originalRightCount), -1)
    }
    if Type(leftCount) = "AhkStdlibDecimalValue" {
        if Type(rightCount) = "AhkStdlibDecimalValue"
            return leftCount.__Sub(rightCount)
        if rightCount is Integer
            return leftCount.__Sub(rightCount)
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("sub", originalLeftCount, originalRightCount), -1)
    }

    try {
        return leftCount - rightCount
    } catch TypeError {
        throw TypeError(AhkStdlibCollectionsCounterBinaryOperatorTypeError("sub", originalLeftCount, originalRightCount), -1)
    }
}

AhkStdlibCollectionsIterableItems(source)
{
    result := []

    if source is String {
        loop StrLen(source)
            result.Push(SubStr(source, A_Index, 1))
        return result
    }

    if source is Array {
        for value in source
            result.Push(value)
        return result
    }

    if IsObject(source) && HasMethod(source, "__Enum") {
        for value in source
            result.Push(value)
        return result
    }

    throw TypeError("'" AhkStdlibCollectionsCounterTypeName(source) "' object is not iterable", -1)
}

AhkStdlibCollectionsCopyOrder(order)
{
    copy := []
    for key in order
        copy.Push(key)
    return copy
}

AhkStdlibCollectionsOrderEquals(left, right)
{
    if left.Length != right.Length
        return false

    loop left.Length {
        if left[A_Index] != right[A_Index]
            return false
    }

    return true
}

AhkStdlibCollectionsSequenceIndex(length, index)
{
    if !(index is Integer)
        throw TypeError("sequence index must be an integer", -1)
    actual := index >= 0 ? index + 1 : length + index + 1
    if actual < 1 || actual > length
        throw IndexError("list index out of range", -1)
    return actual
}

AhkStdlibCollectionsMappingPairs(source)
{
    result := []

    if source is Map || source is AhkStdlibCollectionsCounter || source is AhkStdlibCollectionsOrderedMapBase {
        for key, value in source
            result.Push([key, value])
        return result
    }

    if source is Array || source is AhkStdlibTuple {
        for item in source
            result.Push(AhkStdlibCollectionsPairFromItem(item))
        return result
    }

    if Type(source) = "Object" {
        for key, value in source.OwnProps()
            result.Push([key, value])
        return result
    }

    if IsObject(source) && HasMethod(source, "__Enum") {
        for item in source
            result.Push(AhkStdlibCollectionsPairFromItem(item))
        return result
    }

    throw TypeError("'" AhkStdlibCollectionsCounterTypeName(source) "' object is not iterable", -1)
}

AhkStdlibCollectionsPairFromItem(item)
{
    if item is Array || item is AhkStdlibTuple {
        if item.Length < 2
            throw ValueError("dictionary update sequence element has length " item.Length "; 2 is required", -1)
        return [item[1], item[2]]
    }

    if IsObject(item) && HasMethod(item, "__Enum") {
        values := []
        for value in item
            values.Push(value)
        if values.Length < 2
            throw ValueError("dictionary update sequence element has length " values.Length "; 2 is required", -1)
        return [values[1], values[2]]
    }

    throw TypeError("cannot convert dictionary update sequence element to a sequence", -1)
}

AhkStdlibCollectionsMappingHas(mapping, key)
{
    if mapping is Map || mapping is AhkStdlibCollectionsCounter || mapping is AhkStdlibCollectionsOrderedMapBase
        return mapping.Has(key)
    if Type(mapping) = "Object"
        return mapping.HasOwnProp(key)
    return false
}

AhkStdlibCollectionsMappingGet(mapping, key)
{
    if mapping is Map || mapping is AhkStdlibCollectionsCounter || mapping is AhkStdlibCollectionsOrderedMapBase
        return mapping[key]
    if Type(mapping) = "Object" && mapping.HasOwnProp(key)
        return mapping.%key%
    throw KeyError(AhkStdlibCollectionsCounterValueRepr(key), -1)
}

AhkStdlibCollectionsMappingSet(mapping, key, value)
{
    if mapping is Map || mapping is AhkStdlibCollectionsCounter || mapping is AhkStdlibCollectionsOrderedMapBase {
        mapping[key] := value
        return value
    }
    if Type(mapping) = "Object" {
        mapping.%key% := value
        return value
    }
    throw TypeError("'" AhkStdlibCollectionsCounterTypeName(mapping) "' object does not support item assignment", -1)
}

AhkStdlibCollectionsNamedTupleFields(fieldNames)
{
    fields := []
    if fieldNames is String {
        normalized := StrReplace(fieldNames, ",", " ")
        for field in StrSplit(normalized, " ") {
            if field != ""
                fields.Push(field)
        }
        return fields
    }

    for field in AhkStdlibCollectionsIterableItems(fieldNames)
        fields.Push(field)
    return fields
}

AhkStdlibCollectionsKwargsFromOptions(options := unset)
{
    result := Map()
    if !IsSet(options) || AhkStdlibIsNone(options)
        return result
    if AhkStdlibCollectionsIsKwargsOptions(options)
        return options.kwargs
    if options is Map
        return options
    if Type(options) = "Object" {
        for key, value in options.OwnProps()
            result[key] := value
        return result
    }
    throw TypeError("expected keyword options object", -1)
}

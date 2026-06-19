#Requires AutoHotkey v2.0

#Include <stdlib\init>
#Include <stdlib\collections>
#Include <stdlib\cmath>

class AhkStdlibOperator
{
    static lt(a, b) => AhkStdlibOperatorCompare("lt", a, b)
    static le(a, b) => AhkStdlibOperatorCompare("le", a, b)
    static eq(a, b) => AhkStdlibOperatorCompare("eq", a, b)
    static ne(a, b) => AhkStdlibOperatorCompare("ne", a, b)
    static ge(a, b) => AhkStdlibOperatorCompare("ge", a, b)
    static gt(a, b) => AhkStdlibOperatorCompare("gt", a, b)

    static truth(a) => AhkStdlibOperatorTruth(a)
    static not_(a) => !AhkStdlibOperatorTruth(a)
    static is_(a, b) => !(a !== b)
    static is_not(a, b) => a !== b

    static add(a, b) => AhkStdlibOperatorAdd(a, b)
    static sub(a, b) => AhkStdlibOperatorSub(a, b)
    static mul(a, b) => AhkStdlibOperatorMul(a, b)
    static truediv(a, b) => AhkStdlibOperatorTrueDiv(a, b)
    static floordiv(a, b) => AhkStdlibOperatorFloorDiv(a, b)
    static mod(a, b) => AhkStdlibOperatorMod(a, b)
    static and_(a, b) => AhkStdlibOperatorAnd(a, b)
    static or_(a, b) => AhkStdlibOperatorOr(a, b)
    static neg(a) => AhkStdlibOperatorNeg(a)
    static pos(a) => AhkStdlibOperatorPos(a)
    static abs(a) => AhkStdlibOperatorAbs(a)
    static pow(a, b) => AhkStdlibOperatorPow(a, b)
    static lshift(a, b) => AhkStdlibOperatorLshift(a, b)
    static rshift(a, b) => AhkStdlibOperatorRshift(a, b)
    static xor(a, b) => AhkStdlibOperatorXor(a, b)
    static inv(a) => AhkStdlibOperatorInvert(a)
    static invert(a) => AhkStdlibOperatorInvert(a)
    static concat(a, b) => AhkStdlibOperatorConcat(a, b)
    static index(a) => AhkStdlibOperatorIndex(a)
    static matmul(a, b) => AhkStdlibOperatorMatmul(a, b)

    ; In-place operators. CPython's operator.iadd etc. call the __i*__ hook when
    ; present and otherwise fall back to the binary op. For our mutable sequence
    ; (Array) iadd/imul/iconcat mutate in place and return the same object,
    ; matching list semantics; scalar forms just return the binary result.
    static iadd(a, b) => AhkStdlibOperatorIAdd(a, b)
    static isub(a, b) => AhkStdlibOperatorSub(a, b)
    static imul(a, b) => AhkStdlibOperatorIMul(a, b)
    static itruediv(a, b) => AhkStdlibOperatorTrueDiv(a, b)
    static ifloordiv(a, b) => AhkStdlibOperatorFloorDiv(a, b)
    static imod(a, b) => AhkStdlibOperatorMod(a, b)
    static ipow(a, b) => AhkStdlibOperatorPow(a, b)
    static imatmul(a, b) => AhkStdlibOperatorIMatmul(a, b)
    static ilshift(a, b) => AhkStdlibOperatorLshift(a, b)
    static irshift(a, b) => AhkStdlibOperatorRshift(a, b)
    static iand(a, b) => AhkStdlibOperatorAnd(a, b)
    static ior(a, b) => AhkStdlibOperatorOr(a, b)
    static ixor(a, b) => AhkStdlibOperatorXor(a, b)
    static iconcat(a, b) => AhkStdlibOperatorIConcat(a, b)

    static contains(a, b) => AhkStdlibOperatorContains(a, b)
    static countOf(a, b) => AhkStdlibOperatorCountOf(a, b)
    static indexOf(a, b) => AhkStdlibOperatorIndexOf(a, b)
    static getitem(a, b) => AhkStdlibOperatorGetItem(a, b)
    static setitem(a, b, c) => AhkStdlibOperatorSetItem(a, b, c)
    static delitem(a, b) => AhkStdlibOperatorDelItem(a, b)
    static length_hint(obj, default := 0) => AhkStdlibOperatorLengthHint(obj, default)

    static itemgetter(item, items*)
    {
        return AhkStdlibOperatorItemGetter(item, items*)
    }

    static attrgetter(attr, attrs*)
    {
        return AhkStdlibOperatorAttrGetter(attr, attrs*)
    }

    static methodcaller(name, args*)
    {
        return AhkStdlibOperatorMethodCaller(name, args*)
    }
}

class AhkStdlibOperatorItemGetter
{
    __New(item, items*)
    {
        this.Items := [item]
        for value in items
            this.Items.Push(value)
    }

    Call(obj)
    {
        if this.Items.Length = 1
            return AhkStdlibOperatorGetItem(obj, this.Items[1])

        result := []
        for item in this.Items
            result.Push(AhkStdlibOperatorGetItem(obj, item))
        return result
    }
}

class AhkStdlibOperatorAttrGetter
{
    __New(attr, attrs*)
    {
        if !(attr is String)
            throw TypeError("attribute name must be a string", -1)

        this.Attrs := [attr]
        for value in attrs {
            if !(value is String)
                throw TypeError("attribute name must be a string", -1)
            this.Attrs.Push(value)
        }
    }

    Call(obj)
    {
        if this.Attrs.Length = 1
            return AhkStdlibOperatorGetAttrPath(obj, this.Attrs[1])

        result := []
        for attr in this.Attrs
            result.Push(AhkStdlibOperatorGetAttrPath(obj, attr))
        return result
    }
}

class AhkStdlibOperatorMethodCaller
{
    __New(name, args*)
    {
        if !(name is String)
            throw TypeError("method name must be a string", -1)
        this.Name := name
        this.Args := args
    }

    Call(obj)
    {
        method := ObjBindMethod(obj, this.Name)
        return method.Call(this.Args*)
    }
}

stdlib.operator := AhkStdlibOperator

AhkStdlibOperatorCompare(operation, left, right)
{
    if left is AhkStdlibCollectionsCounter
        return left.AhkStdlibCounterCompare(operation, right)
    if right is AhkStdlibCollectionsCounter
        return right.AhkStdlibCounterCompare(AhkStdlibOperatorReverseComparison(operation), left)
    if AhkStdlibOperatorIsDecimal(left)
        return AhkStdlibOperatorObjectCompare(operation, left, right)
    if AhkStdlibOperatorIsDecimal(right) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, right, left)
        return AhkStdlibOperatorObjectCompare(AhkStdlibOperatorReverseComparison(operation), right, left)
    }
    if AhkStdlibOperatorIsFraction(left)
        return AhkStdlibOperatorObjectCompare(operation, left, right)
    if AhkStdlibOperatorIsFraction(right) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, right, left)
        return AhkStdlibOperatorObjectCompare(AhkStdlibOperatorReverseComparison(operation), right, left)
    }
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right) {
        if !AhkStdlibOperatorComparableCrossTypeEqual(operation)
            throw TypeError("'" AhkStdlibOperatorComparisonSymbol(operation) "' not supported between instances of '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        complexValue := AhkStdlibOperatorIsComplex(left) ? left : right
        return AhkStdlibOperatorObjectEqNe(operation, complexValue, AhkStdlibOperatorIsComplex(left) ? right : left)
    }
    if AhkStdlibOperatorIsDateTimeComparable(left) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, left, right)
        return AhkStdlibOperatorObjectCompare(operation, left, right)
    }
    if AhkStdlibOperatorIsDateTimeComparable(right) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, right, left)
        return AhkStdlibOperatorObjectCompare(AhkStdlibOperatorReverseComparison(operation), right, left)
    }
    if AhkStdlibOperatorIsDate(left)
        return left.__Compare(right, operation)
    if AhkStdlibOperatorIsDate(right) {
        result := right.__Compare(left, AhkStdlibOperatorReverseComparison(operation))
        if result = ""
            throw TypeError(AhkStdlibOperatorComparisonError(operation, left, right), -1)
        return result
    }
    if AhkStdlibOperatorIsTimedelta(left)
        return left.__Compare(right, operation)
    if AhkStdlibOperatorIsTimedelta(right) {
        result := right.__Compare(left, AhkStdlibOperatorReverseComparison(operation))
        if result = ""
            throw TypeError(AhkStdlibOperatorComparisonError(operation, left, right), -1)
        return result
    }
    if AhkStdlibOperatorIsArrayValue(left) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, left, right)
        return AhkStdlibOperatorObjectCompare(operation, left, right)
    }
    if AhkStdlibOperatorIsArrayValue(right) {
        if AhkStdlibOperatorComparableCrossTypeEqual(operation)
            return AhkStdlibOperatorObjectEqNe(operation, right, left)
        return AhkStdlibOperatorObjectCompare(AhkStdlibOperatorReverseComparison(operation), right, left)
    }

    switch operation {
        case "lt":
            return left < right
        case "le":
            return left <= right
        case "eq":
            return left == right
        case "ne":
            return left != right
        case "ge":
            return left >= right
        case "gt":
            return left > right
    }

    throw ValueError("unknown operator comparison", -1)
}

AhkStdlibOperatorObjectCompare(operation, left, right)
{
    result := left.__Compare(right, operation)
    if result = ""
        throw TypeError(AhkStdlibOperatorComparisonError(operation, left, right), -1)

    switch operation {
        case "lt":
            return result < 0
        case "le":
            return result <= 0
        case "eq":
            return result = 0
        case "ne":
            return result != 0
        case "ge":
            return result >= 0
        case "gt":
            return result > 0
    }

    throw ValueError("unknown operator comparison", -1)
}

AhkStdlibOperatorObjectEqNe(operation, left, right)
{
    result := left.__Compare(right, operation)
    if result = ""
        return operation = "eq" ? false : true
    return operation = "eq" ? (result = 0) : (result != 0)
}

AhkStdlibOperatorReverseComparison(operation)
{
    switch operation {
        case "lt":
            return "gt"
        case "le":
            return "ge"
        case "gt":
            return "lt"
        case "ge":
            return "le"
    }
    return operation
}

AhkStdlibOperatorComparableCrossTypeEqual(operation)
{
    return operation = "eq" || operation = "ne"
}

AhkStdlibOperatorComparisonError(operation, left, right)
{
    symbol := AhkStdlibOperatorComparisonSymbol(operation)
    return "'" symbol "' not supported between instances of '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'"
}

AhkStdlibOperatorComparisonSymbol(operation)
{
    switch operation {
        case "lt":
            return "<"
        case "le":
            return "<="
        case "eq":
            return "=="
        case "ne":
            return "!="
        case "ge":
            return ">="
        case "gt":
            return ">"
    }
    return operation
}

AhkStdlibOperatorTruth(value)
{
    if AhkStdlibOperatorIsDecimal(value)
        return value.digits != "0"
    if AhkStdlibOperatorIsFraction(value)
        return value.numerator != 0
    if AhkStdlibOperatorIsArrayValue(value)
        return value.__Len > 0
    if value is Array
        return value.Length > 0
    if value is Map
        return value.Count > 0
    if value is String
        return value != ""
    return !!value
}

AhkStdlibOperatorFloorDiv(a, b)
{
    if AhkStdlibOperatorIsDecimal(a) {
        result := a.__FloorDiv(b)
        if result = ""
            throw TypeError("unsupported operand type(s) for //: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(b) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(b) {
        if a is Integer
            return stdlib.decimal.Decimal(a).__FloorDiv(b)
        throw TypeError("unsupported operand type(s) for //: '" AhkStdlibOperatorPythonTypeName(a) "' and 'decimal.Decimal'", -1)
    }
    quotient := a // b
    remainder := Mod(a, b)
    if remainder != 0 && ((remainder > 0 && b < 0) || (remainder < 0 && b > 0))
        quotient -= 1
    return quotient
}

AhkStdlibOperatorMod(a, b)
{
    if AhkStdlibOperatorIsDecimal(a) {
        result := a.__Mod(b)
        if result = ""
            throw TypeError("unsupported operand type(s) for %: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(b) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(b) {
        if a is Integer
            return stdlib.decimal.Decimal(a).__Mod(b)
        throw TypeError("unsupported operand type(s) for %: '" AhkStdlibOperatorPythonTypeName(a) "' and 'decimal.Decimal'", -1)
    }
    return a - (b * AhkStdlibOperatorFloorDiv(a, b))
}

AhkStdlibOperatorTrueDiv(left, right)
{
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right)
        return AhkStdlibOperatorComplexBinary("/", left, right)
    if AhkStdlibOperatorIsDecimal(left) {
        result := left.__Div(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for /: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(right) {
        if left is Integer
            return stdlib.decimal.Decimal(left).__Div(right)
        throw TypeError("unsupported operand type(s) for /: '" AhkStdlibOperatorPythonTypeName(left) "' and 'decimal.Decimal'", -1)
    }
    if AhkStdlibOperatorIsFraction(left) {
        if right is Float
            return left.to_float() / right
        result := left.__Div(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for /: 'Fraction' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(right) {
        if left is Integer
            return stdlib.fractions.Fraction(left, 1).__Div(right)
        if left is Float
            return left / right.to_float()
        throw TypeError("unsupported operand type(s) for /: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Fraction'", -1)
    }
    return left / right
}

AhkStdlibOperatorAdd(left, right)
{
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right)
        return AhkStdlibOperatorComplexBinary("+", left, right)
    if left is AhkStdlibCollectionsCounter
        return left.AhkStdlibCounterAdd(right)
    if right is AhkStdlibCollectionsCounter
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Counter'", -1)
    if AhkStdlibOperatorIsDecimal(left) {
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(right) {
        result := right.__Add(left)
        if result = ""
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'decimal.Decimal'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(left) {
        if right is Float
            return left.to_float() + right
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'Fraction' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(right) {
        if left is Float
            return left + right.to_float()
        result := right.__Add(left)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Fraction'", -1)
        return result
    }
    if AhkStdlibOperatorIsDateTime(left) {
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'datetime.datetime' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDateTime(right)
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.datetime'", -1)
    if AhkStdlibOperatorIsDate(left) {
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'datetime.date' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDate(right)
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.date'", -1)
    if AhkStdlibOperatorIsTimedelta(left) {
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'datetime.timedelta' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsTimedelta(right)
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.timedelta'", -1)
    if AhkStdlibOperatorIsArrayValue(left) {
        result := left.__Add(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for +: 'array.array' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsArrayValue(right)
        throw TypeError("unsupported operand type(s) for +: '" AhkStdlibOperatorPythonTypeName(left) "' and 'array.array'", -1)

    if left is String {
        if right is String
            return left . right
        throw TypeError("can only concatenate str (not '" Type(right) "') to str", -1)
    }
    if right is String
        throw TypeError("unsupported operand type(s) for +: '" Type(left) "' and 'str'", -1)

    if left is Array {
        if right is Array
            return AhkStdlibOperatorArrayConcat(left, right)
        throw TypeError("can only concatenate list (not '" Type(right) "') to list", -1)
    }
    if right is Array
        throw TypeError("unsupported operand type(s) for +: '" Type(left) "' and 'list'", -1)

    return left + right
}

AhkStdlibOperatorSub(left, right)
{
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right)
        return AhkStdlibOperatorComplexBinary("-", left, right)
    if left is AhkStdlibCollectionsCounter
        return left.AhkStdlibCounterSub(right)
    if right is AhkStdlibCollectionsCounter
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Counter'", -1)
    if AhkStdlibOperatorIsDecimal(left) {
        result := left.__Sub(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for -: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(right) {
        if left is Integer
            return stdlib.decimal.Decimal(left).__Sub(right)
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'decimal.Decimal'", -1)
    }
    if AhkStdlibOperatorIsFraction(left) {
        if right is Float
            return left.to_float() - right
        result := left.__Sub(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for -: 'Fraction' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(right) {
        if left is Integer
            return stdlib.fractions.Fraction(left, 1).__Sub(right)
        if left is Float
            return left - right.to_float()
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Fraction'", -1)
    }
    if AhkStdlibOperatorIsDateTime(left) {
        result := left.__Sub(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for -: 'datetime.datetime' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDateTime(right)
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.datetime'", -1)
    if AhkStdlibOperatorIsDate(left) {
        result := left.__Sub(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for -: 'datetime.date' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDate(right)
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.date'", -1)
    if AhkStdlibOperatorIsTimedelta(left) {
        result := left.__Sub(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for -: 'datetime.timedelta' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsTimedelta(right)
        throw TypeError("unsupported operand type(s) for -: '" AhkStdlibOperatorPythonTypeName(left) "' and 'datetime.timedelta'", -1)
    return left - right
}

AhkStdlibOperatorAnd(left, right)
{
    if left is AhkStdlibCollectionsCounter
        return left.AhkStdlibCounterAnd(right)
    if right is AhkStdlibCollectionsCounter
        throw TypeError("unsupported operand type(s) for &: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Counter'", -1)
    return left & right
}

AhkStdlibOperatorOr(left, right)
{
    if left is AhkStdlibCollectionsCounter
        return left.AhkStdlibCounterOr(right)
    if left is Map && right is AhkStdlibCollectionsCounter
        return AhkStdlibCollectionsCounterMapUnion(left, right)
    if right is AhkStdlibCollectionsCounter
        throw TypeError("unsupported operand type(s) for |: '" Type(left) "' and 'Counter'", -1)
    return left | right
}

AhkStdlibOperatorPow(left, right)
{
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right)
        return AhkStdlibOperatorComplexBinary("**", left, right)
    if !(left is Number) || !(right is Number)
        throw TypeError("unsupported operand type(s) for ** or pow(): '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
    return left ** right
}

AhkStdlibOperatorLshift(left, right)
{
    if !(left is Integer) || !(right is Integer)
        throw TypeError("unsupported operand type(s) for <<: '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
    if right < 0
        throw ValueError("negative shift count", -1)
    return left << right
}

AhkStdlibOperatorRshift(left, right)
{
    if !(left is Integer) || !(right is Integer)
        throw TypeError("unsupported operand type(s) for >>: '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
    if right < 0
        throw ValueError("negative shift count", -1)
    return left >> right
}

AhkStdlibOperatorXor(left, right)
{
    if !(left is Integer) || !(right is Integer)
        throw TypeError("unsupported operand type(s) for ^: '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
    return left ^ right
}

AhkStdlibOperatorInvert(value)
{
    if !(value is Integer)
        throw TypeError("bad operand type for unary ~: '" AhkStdlibOperatorPythonTypeName(value) "'", -1)
    return ~value
}

AhkStdlibOperatorConcat(left, right)
{
    if left is String && right is String
        return left right
    if left is Array && right is Array {
        result := []
        for value in left
            result.Push(value)
        for value in right
            result.Push(value)
        return result
    }
    throw TypeError("'" AhkStdlibOperatorPythonTypeName(left) "' object can't be concatenated", -1)
}

; matmul has no AHK operator, but CPython's operator.matmul is a plain function
; that dispatches to the left operand's __matmul__ (then the right operand's
; reflected __rmatmul__) and otherwise raises "unsupported operand type(s) for @".
; Objects opt in by exposing a __Matmul / __Rmatmul method.
AhkStdlibOperatorMatmul(left, right)
{
    if IsObject(left) && HasMethod(left, "__Matmul") {
        result := left.__Matmul(right)
        if !AhkStdlibIsNotImplemented(result)
            return result
    }
    if IsObject(right) && HasMethod(right, "__Rmatmul") {
        result := right.__Rmatmul(left)
        if !AhkStdlibIsNotImplemented(result)
            return result
    }
    throw TypeError("unsupported operand type(s) for @: '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
}

AhkStdlibOperatorIMatmul(left, right)
{
    if IsObject(left) && HasMethod(left, "__Imatmul") {
        result := left.__Imatmul(right)
        if !AhkStdlibIsNotImplemented(result)
            return result
    }
    if IsObject(left) && HasMethod(left, "__Matmul") {
        result := left.__Matmul(right)
        if !AhkStdlibIsNotImplemented(result)
            return result
    }
    throw TypeError("unsupported operand type(s) for @=: '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
}

; In-place add/concat on a list extends it in place and returns the same object
; (CPython list.__iadd__). The right operand must be iterable, like += in Python.
AhkStdlibOperatorIAdd(left, right)
{
    if left is Array {
        AhkStdlibOperatorExtendInPlace(left, right)
        return left
    }
    return AhkStdlibOperatorAdd(left, right)
}

AhkStdlibOperatorIConcat(left, right)
{
    if left is Array {
        if !(right is Array)
            throw TypeError("can only concatenate list (not '" AhkStdlibOperatorPythonTypeName(right) "') to list", -1)
        AhkStdlibOperatorExtendInPlace(left, right)
        return left
    }
    return AhkStdlibOperatorConcat(left, right)
}

; In-place multiply on a list repeats it in place and returns the same object
; (CPython list.__imul__). Scalars/strings fall through to the binary product.
AhkStdlibOperatorIMul(left, right)
{
    if left is Array {
        if !(right is Integer)
            throw TypeError("can't multiply sequence by non-int of type '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        original := []
        for value in left
            original.Push(value)
        ; Reduce to empty for count <= 0, else append (count-1) more copies.
        if right <= 1 {
            if right <= 0
                left.Length := 0
            return left
        }
        Loop right - 1 {
            for value in original
                left.Push(value)
        }
        return left
    }
    return AhkStdlibOperatorMul(left, right)
}

AhkStdlibOperatorExtendInPlace(target, source)
{
    if source is Array {
        for value in source
            target.Push(value)
        return
    }
    if source is String {
        Loop Parse, source
            target.Push(A_LoopField)
        return
    }
    if IsObject(source) && HasMethod(source, "__Enum") {
        for value in source
            target.Push(value)
        return
    }
    throw TypeError("'" AhkStdlibOperatorPythonTypeName(source) "' object is not iterable", -1)
}

AhkStdlibOperatorIndex(value)
{
    if value is Integer
        return value
    if AhkStdlibIsBool(value)
        return value.Value ? 1 : 0
    throw TypeError("'" AhkStdlibOperatorPythonTypeName(value) "' object cannot be interpreted as an integer", -1)
}

AhkStdlibOperatorNeg(value)
{
    if value is AhkStdlibCollectionsCounter
        return value.AhkStdlibCounterNeg()
    if AhkStdlibOperatorIsDecimal(value)
        return value.__Neg()
    if AhkStdlibOperatorIsFraction(value)
        return value.__Neg()
    if AhkStdlibOperatorIsComplex(value)
        return value.__Neg()
    if AhkStdlibOperatorIsTimedelta(value)
        return value.__Neg()
    return -value
}

AhkStdlibOperatorPos(value)
{
    if value is AhkStdlibCollectionsCounter
        return value.AhkStdlibCounterPos()
    if AhkStdlibOperatorIsDecimal(value)
        return value.__Pos()
    if AhkStdlibOperatorIsFraction(value)
        return value.__Pos()
    if AhkStdlibOperatorIsComplex(value)
        return value.__Pos()
    if AhkStdlibOperatorIsTimedelta(value)
        return value.__Pos()
    return +value
}

AhkStdlibOperatorAbs(value)
{
    if AhkStdlibOperatorIsDecimal(value)
        return value.sign ? value.__Neg() : value.__Pos()
    if AhkStdlibOperatorIsFraction(value)
        return value.numerator < 0 ? value.__Neg() : value.__Pos()
    if AhkStdlibOperatorIsComplex(value)
        return AhkStdlibComplexHypot(value.real, value.imag)
    return Abs(value)
}

AhkStdlibOperatorMul(left, right)
{
    if AhkStdlibOperatorIsComplex(left) || AhkStdlibOperatorIsComplex(right)
        return AhkStdlibOperatorComplexBinary("*", left, right)
    if AhkStdlibOperatorIsArrayValue(left) {
        result := left.__Mul(right)
        if result = ""
            throw TypeError("can't multiply sequence by non-int of type '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsArrayValue(right) {
        result := right.__Mul(left)
        if result = ""
            throw TypeError("can't multiply sequence by non-int of type '" AhkStdlibOperatorPythonTypeName(left) "'", -1)
        return result
    }
    if left is String || left is Array {
        if !(right is Integer)
            throw TypeError("can't multiply sequence by non-int of type '" Type(right) "'", -1)
        return AhkStdlibOperatorRepeatSequence(left, right)
    }
    if right is String || right is Array {
        if !(left is Integer)
            throw TypeError("can't multiply sequence by non-int of type '" Type(left) "'", -1)
        return AhkStdlibOperatorRepeatSequence(right, left)
    }
    if AhkStdlibOperatorIsTimedelta(left) {
        result := left.__Mul(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: 'timedelta' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsTimedelta(right) {
        result := right.__Mul(left)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: '" AhkStdlibOperatorPythonTypeName(left) "' and 'timedelta'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(left) {
        result := left.__Mul(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: 'decimal.Decimal' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsDecimal(right) {
        result := right.__Mul(left)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: '" AhkStdlibOperatorPythonTypeName(left) "' and 'decimal.Decimal'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(left) {
        if right is Float
            return left.to_float() * right
        result := left.__Mul(right)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: 'Fraction' and '" AhkStdlibOperatorPythonTypeName(right) "'", -1)
        return result
    }
    if AhkStdlibOperatorIsFraction(right) {
        if left is Float
            return left * right.to_float()
        result := right.__Mul(left)
        if result = ""
            throw TypeError("unsupported operand type(s) for *: '" AhkStdlibOperatorPythonTypeName(left) "' and 'Fraction'", -1)
        return result
    }

    return left * right
}

AhkStdlibOperatorArrayConcat(left, right)
{
    result := []
    for value in left
        result.Push(value)
    for value in right
        result.Push(value)
    return result
}

AhkStdlibOperatorRepeatSequence(value, count)
{
    if count <= 0 {
        if value is String
            return ""
        return []
    }

    if value is String {
        result := ""
        Loop count
            result .= value
        return result
    }

    result := []
    Loop count {
        for item in value
            result.Push(item)
    }
    return result
}

AhkStdlibOperatorContains(container, needle)
{
    if AhkStdlibOperatorIsArrayValue(container)
        return container.__Contains(needle)

    if container is Array {
        for value in container {
            if AhkStdlibOperatorSameOrEqual(value, needle)
                return true
        }
        return false
    }

    if container is Map
        return container.Has(needle)

    if container is String
        return InStr(container, needle) != 0

    throw TypeError("argument of type '" Type(container) "' is not iterable", -1)
}

AhkStdlibOperatorCountOf(container, needle)
{
    count := 0
    if AhkStdlibOperatorIsArrayValue(container)
        return container.count(needle)

    if container is Array {
        for value in container {
            if AhkStdlibOperatorSameOrEqual(value, needle)
                count += 1
        }
        return count
    }

    if container is Map {
        for key, value in container {
            if AhkStdlibOperatorSameOrEqual(key, needle)
                count += 1
        }
        return count
    }

    if container is String {
        Loop Parse, container {
            if AhkStdlibOperatorSameOrEqual(A_LoopField, needle)
                count += 1
        }
        return count
    }

    throw TypeError("argument of type '" Type(container) "' is not iterable", -1)
}

AhkStdlibOperatorIndexOf(container, needle)
{
    if AhkStdlibOperatorIsArrayValue(container)
        return container.index(needle)

    if container is Array {
        for index, value in container {
            if AhkStdlibOperatorSameOrEqual(value, needle)
                return index - 1
        }
        throw ValueError("sequence.index(x): x not in sequence", -1)
    }

    if container is Map {
        position := 0
        for key, value in container {
            if AhkStdlibOperatorSameOrEqual(key, needle)
                return position
            position += 1
        }
        throw ValueError("sequence.index(x): x not in sequence", -1)
    }

    if container is String {
        Loop Parse, container {
            if AhkStdlibOperatorSameOrEqual(A_LoopField, needle)
                return A_Index - 1
        }
        throw ValueError("sequence.index(x): x not in sequence", -1)
    }

    throw TypeError("argument of type '" Type(container) "' is not iterable", -1)
}

AhkStdlibOperatorGetItem(container, key)
{
    if container is Array
        return container[AhkStdlibOperatorArrayIndex(container, key)]
    if container is Map
        return container[key]
    if container is String {
        index := AhkStdlibOperatorStringIndex(container, key)
        return SubStr(container, index, 1)
    }
    return container[key]
}

AhkStdlibOperatorSetItem(container, key, value)
{
    if container is Array {
        container[AhkStdlibOperatorArrayIndex(container, key)] := value
        return
    }
    if container is Map {
        container[key] := value
        return
    }
    container[key] := value
}

AhkStdlibOperatorDelItem(container, key)
{
    if container is Array {
        container.RemoveAt(AhkStdlibOperatorArrayIndex(container, key))
        return
    }
    if container is Map {
        container.Delete(key)
        return
    }
    if IsObject(container) && HasMethod(container, "Delete") {
        container.Delete(key)
        return
    }
    container.DeleteProp(key)
}

AhkStdlibOperatorLengthHint(obj, default := 0)
{
    if AhkStdlibIsBool(default)
        default := default.Value ? 1 : 0
    if !(default is Integer)
        throw TypeError("'" AhkStdlibOperatorPythonTypeName(default) "' object cannot be interpreted as an integer", -1)

    if obj is Array
        return obj.Length
    if obj is Map
        return obj.Count
    if obj is String
        return StrLen(obj)
    if IsObject(obj) && HasProp(obj, "Length")
        return obj.Length
    if IsObject(obj) && HasProp(obj, "Count")
        return obj.Count
    if IsObject(obj) && HasMethod(obj, "__LengthHint") {
        try
            hint := obj.__LengthHint()
        catch TypeError
            return default
        if AhkStdlibIsNotImplemented(hint)
            return default
        if AhkStdlibIsBool(hint)
            hint := hint.Value ? 1 : 0
        if !(hint is Integer)
            throw TypeError("__length_hint__ must be an integer, not " AhkStdlibOperatorPythonTypeName(hint), -1)
        if hint < 0
            throw ValueError("__length_hint__() should return >= 0", -1)
        return hint
    }
    return default
}

AhkStdlibOperatorArrayIndex(array, index)
{
    if !(index is Integer)
        throw TypeError("array indices must be integers", -1)
    if index >= 0
        return index + 1
    return index
}

AhkStdlibOperatorStringIndex(value, index)
{
    if !(index is Integer)
        throw TypeError("string indices must be integers", -1)
    length := StrLen(value)
    actual := index >= 0 ? index + 1 : length + index + 1
    if actual < 1 || actual > length
        throw IndexError("string index out of range", -1)
    return actual
}

AhkStdlibOperatorGetAttrPath(obj, attr)
{
    current := obj
    parts := StrSplit(attr, ".")
    for name in parts
        current := current.%name%
    return current
}

AhkStdlibOperatorSameOrEqual(left, right)
{
    return !(left !== right) || left == right
}

AhkStdlibOperatorPythonTypeName(value)
{
    typeName := Type(value)
    if AhkStdlibIsNone(value)
        return "NoneType"
    if AhkStdlibIsNotImplemented(value)
        return "NotImplementedType"
    if AhkStdlibIsBool(value)
        return "bool"
    if AhkStdlibOperatorIsDecimal(value)
        return "decimal.Decimal"
    if AhkStdlibOperatorIsFraction(value)
        return "Fraction"
    if AhkStdlibOperatorIsComplex(value)
        return "complex"
    if AhkStdlibOperatorIsDateTime(value)
        return "datetime.datetime"
    if AhkStdlibOperatorIsTime(value)
        return "datetime.time"
    if AhkStdlibOperatorIsDate(value)
        return "datetime.date"
    if AhkStdlibOperatorIsTimedelta(value)
        return "datetime.timedelta"
    if AhkStdlibOperatorIsArrayValue(value)
        return "array.array"
    if value is String
        return "str"
    if value is Integer
        return "int"
    if value is Float
        return "float"
    if value is AhkStdlibTuple
        return "tuple"
    if value is Array
        return "list"
    if value is Map && typeName != "Map"
        return AhkStdlibOperatorLeafTypeName(typeName)
    if value is Map
        return "dict"
    return typeName
}

AhkStdlibOperatorLeafTypeName(typeName)
{
    dot := InStr(typeName, ".", false, -1)
    if dot
        return SubStr(typeName, dot + 1)
    return typeName
}

AhkStdlibOperatorIsTimedelta(value)
{
    return Type(value) = "AhkStdlibDateTimeTimedelta"
}

AhkStdlibOperatorIsFraction(value)
{
    return Type(value) = "AhkStdlibFractionsFractionValue"
}

AhkStdlibOperatorIsComplex(value)
{
    return Type(value) = "AhkStdlibComplexValue"
}

; Complex arithmetic dispatch. The complex value class lives in cmath.ahk; its
; metamethods coerce a real operand, so we only need to surface the right
; metamethod and translate a "" result (non-numeric operand) into the standard
; "unsupported operand" TypeError. Operands may appear on either side.
AhkStdlibOperatorComplexBinary(symbol, left, right)
{
    if AhkStdlibOperatorIsComplex(left) {
        result := AhkStdlibOperatorComplexApply(symbol, left, right)
        if result = ""
            throw TypeError(AhkStdlibOperatorComplexError(symbol, left, right), -1)
        return result
    }

    ; left is a real number, right is complex: promote left to complex.
    if !(left is Number) && !AhkStdlibIsBool(left)
        throw TypeError(AhkStdlibOperatorComplexError(symbol, left, right), -1)
    promoted := AhkStdlibComplexCoerce(left)
    result := AhkStdlibOperatorComplexApply(symbol, promoted, right)
    if result = ""
        throw TypeError(AhkStdlibOperatorComplexError(symbol, left, right), -1)
    return result
}

AhkStdlibOperatorComplexApply(symbol, complexLeft, right)
{
    switch symbol {
        case "+":
            return complexLeft.__Add(right)
        case "-":
            return complexLeft.__Sub(right)
        case "*":
            return complexLeft.__Mul(right)
        case "/":
            return complexLeft.__Div(right)
        case "**":
            return complexLeft.__Pow(right)
    }
    throw ValueError("unknown complex operator", -1)
}

AhkStdlibOperatorComplexError(symbol, left, right)
{
    return "unsupported operand type(s) for " symbol ": '" AhkStdlibOperatorPythonTypeName(left) "' and '" AhkStdlibOperatorPythonTypeName(right) "'"
}

AhkStdlibOperatorIsDecimal(value)
{
    return Type(value) = "AhkStdlibDecimalValue"
}

AhkStdlibOperatorIsDateTime(value)
{
    return Type(value) = "AhkStdlibDateTimeDateTimeValue"
}

AhkStdlibOperatorIsDate(value)
{
    return Type(value) = "AhkStdlibDateTimeDateValue"
}

AhkStdlibOperatorIsTime(value)
{
    return Type(value) = "AhkStdlibDateTimeTimeValue"
}

AhkStdlibOperatorIsArrayValue(value)
{
    return Type(value) = "AhkStdlibArrayValue"
}

AhkStdlibOperatorIsDateTimeComparable(value)
{
    return AhkStdlibOperatorIsDateTime(value) || AhkStdlibOperatorIsDate(value) || AhkStdlibOperatorIsTime(value) || AhkStdlibOperatorIsTimedelta(value)
}

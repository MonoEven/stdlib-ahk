#Requires AutoHotkey v2.0

#Include <stdlib\decimal>
#Include <stdlib\fractions>
#Include <stdlib\operator>

decimal_example_value := stdlib.decimal.Decimal("1.25")
decimal_example_sum := stdlib.operator.add(decimal_example_value, stdlib.decimal.Decimal("2.5"))
decimal_example_plus_int := stdlib.operator.add(decimal_example_value, 1)
decimal_example_div := stdlib.operator.truediv(decimal_example_value, stdlib.decimal.Decimal("2"))
decimal_example_repeating_div := stdlib.operator.truediv(stdlib.decimal.Decimal("1"), stdlib.decimal.Decimal("3"))
decimal_example_floor_div := stdlib.operator.floordiv(stdlib.decimal.Decimal("7.5"), stdlib.decimal.Decimal("2"))
decimal_example_mod := stdlib.operator.mod(stdlib.decimal.Decimal("7.5"), stdlib.decimal.Decimal("2"))
decimal_example_abs := stdlib.operator.abs(stdlib.decimal.Decimal("-1.25"))
decimal_example_normalized := stdlib.decimal.Decimal("500.000").normalize()
decimal_example_fraction_eq := stdlib.operator.eq(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(3, 2))
decimal_example_fraction_lt := stdlib.operator.lt(stdlib.decimal.Decimal("1.5"), stdlib.fractions.Fraction(2, 1))
decimal_example_rounding := stdlib.decimal.ROUND_HALF_EVEN
decimal_example_default_context := stdlib.decimal.getcontext()
decimal_example_custom_context := stdlib.decimal.Context({ prec: 7, rounding: stdlib.decimal.ROUND_DOWN })
decimal_example_context_manager := stdlib.decimal.localcontext(decimal_example_custom_context)
decimal_example_entered_context := decimal_example_context_manager.__enter__()
decimal_example_entered_context.prec := 11
decimal_example_context_prec_inside := stdlib.decimal.getcontext().prec
decimal_example_context_manager.__exit__(stdlib.None, stdlib.None, stdlib.None)
decimal_example_context_prec_after := stdlib.decimal.getcontext().prec
decimal_example_signal := stdlib.decimal.DivisionByZero()

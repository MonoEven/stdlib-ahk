#Requires AutoHotkey v2.0

#Include <stdlib\fractions>
#Include <stdlib\operator>

fractions_example_half := stdlib.fractions.Fraction(2, 4)
fractions_example_sum := stdlib.operator.add(stdlib.fractions.Fraction(1, 2), stdlib.fractions.Fraction(1, 3))
fractions_example_plus_int := stdlib.operator.add(fractions_example_half, 1)
fractions_example_plus_float := stdlib.operator.add(fractions_example_half, 0.5)
fractions_example_float_plus := stdlib.operator.add(0.5, fractions_example_half)
fractions_example_mul_float := stdlib.operator.mul(fractions_example_half, 0.5)
fractions_example_abs := stdlib.operator.abs(stdlib.fractions.Fraction(-1, 2))
fractions_example_from_float := stdlib.fractions.Fraction.from_float(0.5)
fractions_example_ratio := fractions_example_half.as_integer_ratio()
fractions_example_pi_limit := stdlib.fractions.Fraction("3.1415926535").limit_denominator(10)

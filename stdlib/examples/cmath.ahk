#Requires AutoHotkey v2.0

#Include <stdlib\cmath>
#Include <stdlib\operator>

; complex construction and the operator surface (this build does not dispatch
; native +/*/** to metamethods, so arithmetic goes through stdlib.operator,
; matching fractions/decimal).
cmath_example_z := stdlib.complex(1, 2)
cmath_example_from_string := stdlib.complex("3-4j")
cmath_example_sum := stdlib.operator.add(cmath_example_z, stdlib.complex(3, 4))
cmath_example_product := stdlib.operator.mul(cmath_example_z, stdlib.complex(3, 4))
cmath_example_quotient := stdlib.operator.truediv(cmath_example_z, stdlib.complex(3, 4))
cmath_example_power := stdlib.operator.pow(cmath_example_z, 2)
cmath_example_magnitude := stdlib.operator.abs(stdlib.complex(3, 4))
cmath_example_conjugate := stdlib.complex(3, 4).conjugate()
cmath_example_repr := String(cmath_example_z)

; cmath module functions mirror Python's complex-valued math.
cmath_example_sqrt := stdlib.cmath.sqrt(-1)
cmath_example_exp := stdlib.cmath.exp(stdlib.complex(1, 2))
cmath_example_log := stdlib.cmath.log(stdlib.complex(1, 1))
cmath_example_phase := stdlib.cmath.phase(stdlib.complex(1, 1))
cmath_example_polar := stdlib.cmath.polar(stdlib.complex(1, 1))
cmath_example_rect := stdlib.cmath.rect(1.4142135623730951, 0.7853981633974483)
cmath_example_isclose := stdlib.cmath.isclose(stdlib.complex(1, 1), stdlib.complex(1, 1.0000000001))
cmath_example_pi := stdlib.cmath.pi

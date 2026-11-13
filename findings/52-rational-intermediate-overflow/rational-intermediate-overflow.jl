# Rational{T} arithmetic throws OverflowError from intermediate products even when the exact
# result is representable in Rational{T}; this reaches isapprox and x^0.
T = Int8
throws(f) = (try f(); false catch err; err isa OverflowError end)
x, y = T(83) // T(6), T(-94) // T(3)
@assert big(x) + big(y) == -35 // 2 && throws(() -> x + y)          # -35//2 fits in Int8
a, b = T(-57) // T(94), T(33) // T(103)
@assert fld(big(a), big(b)) == -2 && throws(() -> fld(a, b))
@assert div(big(a), big(b)) == -1 && throws(() -> div(a, b))
@assert throws(() -> isapprox(a, b))                                  # a comparison that throws
c, d = T(41) // T(59), T(89) // T(56)
@assert rem(big(c), big(d)) == 41 // 59 && throws(() -> rem(c, d))     # the result is c itself
z = T(-104) // T(121)
p = 0                                                                 # a run-time exponent
@assert z^0 == 1 // 1 && throws(() -> z^p)                            # literal 0 is fine, run-time 0 is not
q = 2
@assert big(z)^2 == 10816 // 14641 && throws(() -> z^q)               # does not fit: OverflowError is correct
println("REPRODUCED")

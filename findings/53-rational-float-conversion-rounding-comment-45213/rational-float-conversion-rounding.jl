# T(x::Rational{Int64}) converts numerator and denominator to Float64 and divides, so for
# denominators above 2^53 the result is not correctly rounded; Float32 adds a second rounding.
exact(T, x) = T(big(x))
x = 1 // 1317624576693539401
@assert Float32(x) !== exact(Float32, x)            # 7.5894147f-19 vs 7.589415f-19
@assert Float32(Float64(x)) === exact(Float32, x)    # the Float64 route happens to be right here
y = 1 // 9007199254740993                             # denominator 2^53 + 1
@assert Float64(y) !== exact(Float64, y)
z = 4503599627370499 // 1317624576693539401
@assert Float64(z) !== exact(Float64, z)
@assert Float64(1 // 3) === exact(Float64, 1 // 3)    # small denominators are fine
println("REPRODUCED")

# rationalize(T, x; tol=0) mishandles x == typemin(T), which is exactly representable:
# Julia 1.13.3 returns -1//0, the nightly returns typemin(T) + 1.
r8 = rationalize(Int8, -128.0; tol = 0)
@assert r8 == -1 // 0 || r8 == -127 // 1
@assert r8 != -128 // 1
r64 = rationalize(Int, -2.0^63; tol = 0)
@assert r64 == -1 // 0 || r64 == (-9223372036854775807) // 1
@assert r64 != typemin(Int) // 1
@assert rationalize(Int8, 127.0; tol = 0) == 127 // 1      # typemax is handled
@assert rationalize(Int8, -127.0; tol = 0) == -127 // 1
println("REPRODUCED")

# rationalize(T, x; tol=0) must return the exact rational of x, but for subnormal inputs the
# continued-fraction loop overflows (1/x is Inf) and the result is wrong; on the nightly the
# BigInt version throws (MethodError on typemax(BigInt) after InexactError BigInt(Inf)).
wrong(T, x) = (r = try rationalize(T, x; tol = 0) catch err; return true end; r != big(x))
x16 = Float16(6.0e-8)                       # subnormal: 1 // 16777216
@assert wrong(BigInt, x16)
@assert rationalize(Int, x16; tol = 0) == 0 // 1                 # wrong: exact is 1//16777216
@assert rationalize(Int, Float16(0.1); tol = 0) == 819 // 8192   # normal: exact
@assert wrong(BigInt, Float32(1.0e-40))     # subnormal Float32
@assert wrong(BigInt, 5.0e-324)             # smallest subnormal Float64
@assert !wrong(BigInt, 1.0e-300)            # normal Float64: exact
println("REPRODUCED")

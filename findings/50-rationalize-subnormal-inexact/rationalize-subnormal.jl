# rationalize(T, x; tol=0) must return the exact rational of x ("the result will differ from x by
# no more than tol"), but it is inexact for small inputs: for Float64 below about 1e-16 (unless x
# is a power of two), for the smallest subnormals of every float type, and for Float16 subnormals.
# On the nightly the BigInt version throws for subnormal Float16 (typemax(BigInt) after BigInt(Inf)).
wrong(x) = (r = try rationalize(BigInt, x; tol = 0) catch err; return true end; r != big(x))
@assert !wrong(0.1) && !wrong(1.0e-10) && !wrong(2.0^-60) && !wrong(2.0^-1022)
@assert wrong(1.0e-17) && wrong(1.0e-30) && wrong(1.0e-300)
@assert wrong(2.0^-1074) && wrong(5.0e-324)                 # Float64 subnormals
@assert wrong(Float32(2.0)^-149) && wrong(Float32(1.0e-40))  # Float32 subnormals
@assert wrong(Float16(6.0e-8)) && wrong(Float16(2.0)^-20)    # Float16 subnormals
@assert rationalize(Int, Float16(6.0e-8); tol = 0) == 0 // 1  # exact is 1//16777216
@assert rationalize(Int, Float16(0.1); tol = 0) == 819 // 8192
println("REPRODUCED")

# mod(i, r::AbstractUnitRange) computes i - first(r) in the input type, which overflows for
# typemin (signed) and wraps for an unsigned i below first(r); the result is then wrong.
@assert mod(typemin(Int), 1:3) == 2           # exact: mod(typemin(Int) - 1, 3) + 1 == 1
@assert mod(big(typemin(Int)) - 1, 3) + 1 == 1
@assert mod(typemin(Int8), Int8(1):Int8(3)) == 2   # exact 1
@assert mod(UInt(0), UInt(1):UInt(3)) == 1    # exact 3
@assert mod(UInt8(0), UInt8(1):UInt8(3)) == 1 # exact 3
@assert mod(typemax(Int), -3:-1) == -3        # exact -2
@assert mod(0, 1:3) == 3 && mod(-1, 1:3) == 2 # no overflow: correct
println("REPRODUCED")

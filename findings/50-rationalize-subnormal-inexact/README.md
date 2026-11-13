# 50: `rationalize(T, x; tol=0)` is wrong for subnormal inputs, and throws for `BigInt` on the nightly

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`rationalize(T, x; tol=0)` returns a wrong rational for subnormal floating-point inputs (and `rationalize(BigInt, …)` throws on the nightly)

# Body

```julia-repl
julia> x = Float16(6.0e-8); big(x)        # subnormal, exactly 1//16777216
5.9604644775390625e-08

julia> rationalize(Int, x; tol=0)
0//1

julia> rationalize(BigInt, x; tol=0)       # Julia 1.13.3
0//1

julia> rationalize(BigInt, x; tol=0)       # nightly 1.15.0-DEV.720
ERROR: MethodError: no method matching typemax(::Type{BigInt})
...
caused by: InexactError: BigInt(Inf)

julia> rationalize(BigInt, Float32(1.0e-40); tol=0) == big(Float32(1.0e-40))
false

julia> rationalize(BigInt, 5.0e-324; tol=0) == big(5.0e-324)
false

julia> rationalize(Int, Float16(0.1); tol=0)   # normal input: exact
819//8192
```

With `tol = 0` the documented result is the exact rational value of `x`
(`rationalize(Int, 0.1; tol=0)` gives `3602879701896397//36028797018963968`).
The continued-fraction loop in `rationalize(::Type{T}, x::AbstractFloat,
tol)` works in the type of `x`; for a subnormal input the reciprocal of the
remainder overflows to `Inf` and the loop terminates early with a truncated
expansion. On the nightly the `BigInt` method then converts that `Inf` and
fails in a branch that calls `typemax(BigInt)`.

Reproduces for `Float16`, `Float32` and `Float64` subnormals on Julia 1.13.3
and nightly 1.15.0-DEV.720. Found by an exhaustive probe of all `Float16`
values against `BigFloat`. Related closed reports: #38637 (`rationalize` on
Float16 wrong on PPC), #9897 (stack overflow in `rationalize(Float16)`).
Searches for `rationalize subnormal` and `rationalize wrong zero tol` found
no open issue (2026-11-14).

Assisted-by: AI

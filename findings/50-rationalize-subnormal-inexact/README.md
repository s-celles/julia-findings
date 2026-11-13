# 50: `rationalize(T, x; tol=0)` is not exact for small inputs (below about 1e-16 for `Float64`, and subnormals), and throws for `BigInt` on the nightly

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`rationalize(T, x; tol=0)` is not exact for small floating-point inputs (below about 1e-16 for `Float64`, and all subnormals), and `rationalize(BigInt, …)` throws on the nightly

# Body

The docstring promises that "the result will differ from `x` by no more than
`tol`", so `tol = 0` must return the exact rational value of `x`. It does for
`0.1`, `1e-10`, every power of two down to `2^-1022`, and large values, but
not for small non-dyadic inputs or for subnormals:

```julia-repl
julia> rationalize(BigInt, 1.0e-10; tol=0) == big(1.0e-10)
true

julia> rationalize(BigInt, 1.0e-17; tol=0) == big(1.0e-17)
false

julia> rationalize(BigInt, 5.0e-324; tol=0) == big(5.0e-324)   # smallest Float64 subnormal
false

julia> rationalize(BigInt, Float32(1.0e-40); tol=0) == big(Float32(1.0e-40))
false

julia> x = Float16(6.0e-8); big(x)         # exactly 1//16777216
5.9604644775390625e-08

julia> rationalize(Int, x; tol=0)
0//1

julia> rationalize(BigInt, x; tol=0)       # nightly 1.15.0-DEV.720
ERROR: MethodError: no method matching typemax(::Type{BigInt})
...
caused by: InexactError: BigInt(Inf)
```

The continued-fraction loop in `rationalize(::Type{T}, x::AbstractFloat, tol)`
works in the type of `x`: the first partial quotient is `0` and the next
reciprocal is `1/x`, which for `|x| < 2^-53` cannot be represented with its
fractional part, so the remaining expansion is computed from a rounded
remainder (and from `Inf` for the smallest subnormals). On the nightly the
`BigInt` method then converts that `Inf` and fails in a branch that calls
`typemax(BigInt)`.

Either the loop should run in a wider type (`BigFloat` for `tol = 0`), or
the docstring should state the precision limit.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Found by an exhaustive
probe of all `Float16` values against `BigFloat`, then extended by hand to
`Float32` and `Float64`. Related closed reports: #38637 (`rationalize` on
Float16 wrong on PPC), #9897 (stack overflow in `rationalize(Float16)`).
Searches for `rationalize subnormal` and `rationalize wrong zero tol` found no
open issue (2026-11-14).

Assisted-by: AI

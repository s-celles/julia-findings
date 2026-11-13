# 51: `rationalize(T, x)` returns `-1//0` (1.13) or `typemin(T) + 1` (nightly) for `x == typemin(T)`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`rationalize(T, x)` returns `-1//0` on Julia 1.13 and `(typemin(T) + 1)//1` on the nightly for `x == typemin(T)`, which is exactly representable

# Body

```julia-repl
julia> rationalize(Int8, -128.0; tol=0)      # Julia 1.13.3
-1//0

julia> rationalize(Int8, -128.0; tol=0)      # nightly 1.15.0-DEV.720
-127//1

julia> rationalize(Int, -2.0^63; tol=0)      # 1.13.3: -1//0; nightly: -9223372036854775807//1

julia> rationalize(Int8, -127.0; tol=0), rationalize(Int8, 127.0; tol=0)
(-127//1, 127//1)
```

`-128//1` is a valid `Rational{Int8}`; the overflow guard in
`rationalize(::Type{T}, x::AbstractFloat, tol)` treats the magnitude of
`typemin(T)` as out of range (the 1.13 code compares `abs` against
`typemax(T)`, the nightly clamps to `typemax` before negating). `-1//0` is
the documented result only for values that do not fit, and `-127//1` is
simply wrong. The default-tolerance form `rationalize(Int8, -128.0)` gives the
same results.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Found by a probe of
`Rational{Int8}` values against `Rational{BigInt}`. Searches for `rationalize
typemin` and `rationalize negative overflow 1//0` found no matching issue
(2026-11-14); entry 50 is the related small-input inexactness.

Assisted-by: AI

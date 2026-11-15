# 63: Comment on JuliaStats/Statistics.jl#136: `quantile` with a `Rational` probability is silently inexact (float defaults for `alpha`/`beta`), and a `Rational` `alpha` with `p = 0` or `1` throws `InexactError`

- Kind: comment for `JuliaStats/Statistics.jl#136`
- Status: not posted

# Body

The overflow reported here has a quieter sibling: with a `Rational`
probability the result is a `Rational` that is not the documented value,
because the default `alpha = beta = 1.0` are `Float64` and are converted into
the exact arithmetic (`1 - alpha - beta` carries a power-of-two denominator):

```julia-repl
julia> using Statistics

julia> quantile([1, 2, 3, 4], 1//3)
27021597764222977//13510798882111488          # documented value: 2

julia> quantile([1, 2, 3, 4], 1//3; alpha = 1//1, beta = 1//1)
2//1

julia> quantile([1, 2, 3, 4], 0; alpha = 1//2, beta = 1//2)
ERROR: InexactError: Int64(1//2)              # expected 1 (Def. 5 at p = 0)
```

Making the defaults integers (`alpha = 1, beta = alpha`), or converting
`alpha` and `beta` to the type of `p` before computing `m = alpha + p*(1 -
alpha - beta)`, would give exact results for rational probabilities and
avoid both the inexact denominators and the overflow of this issue. The
`InexactError` comes from the same mixed-type arithmetic when `j = floor(n*p
+ m)` is converted with a rational `m`. Statistics 1.11.5 on Julia 1.13.3 and
nightly 1.15.0-DEV.720.

Found by a probe comparing vector statistics with exact `Rational{BigInt}`
references (`experiments/phase4/statistics_contracts.jl`). Reproducer:
`quantile_rational_probability_inexact.jl` (prints REPRODUCED when a value
differs from the documented formula).

Assisted-by: AI

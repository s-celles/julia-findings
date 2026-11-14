# 58: Printf `%g` chooses fixed or exponential style from the value rounded to P+1 digits, so `@sprintf("%.1g", 9.5)` prints `10`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Body

`%g` with precision `P` must use the style of `%e` when the exponent `X` of
the value rounded to `P` significant digits satisfies `X < -4` or `X >= P`,
and the style of `%f` otherwise (C11 7.21.6.1, which `@printf` points to).
Printf decides from the exponent of the value rounded to `P + 1` digits, so
when rounding to `P` digits carries into the next decade the style is wrong,
and in the first case the output has `P + 1` significant digits:

```julia-repl
julia> using Printf

julia> @sprintf("%.1g", 9.5), @sprintf("%.2g", 99.5), @sprintf("%g", 999999.5)
("10", "100", "1000000")           # C: "1e+01", "1e+02", "1e+06"

julia> @sprintf("%.2g", 9.95e-5), @sprintf("%g", 9.9999995e-5)
("1e-04", "1e-04")                 # C: "0.0001", "0.0001"

julia> @sprintf("%#.2g", 99.5)
"100."                             # C: "1.e+02"
```

Same on Julia 1.13.3 and nightly 1.15.0-DEV.720. Cause: in
`stdlib/Printf/src/Printf.jl` the `'g'` branch computes the exponent with
`Ryu.writeexp(buf, pos, x, prec)`, which rounds to `prec + 1` significant
digits; `Ryu.writeexp(buf, pos, x, prec - 1)` gives the exponent C uses.

Found by comparing `Printf.format` with glibc `snprintf` on random
specifications; the same divergence is recorded independently in the
MilesCranmer/julia-in-lean bug corpus (`printf-general-style-rounding`).
Reproducer: `g_style_exponent_after_rounding.jl` (prints REPRODUCED when
Printf and the C library disagree).

Assisted-by: AI

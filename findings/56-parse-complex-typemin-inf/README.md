# 56: `parse(Complex{T}, s)` cannot read `typemin(T)` parts or the `Inf*im` form that `string` produces

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`parse(Complex{T}, s)` cannot read a `typemin(T)` part (`OverflowError`) nor the `"Inf*im"` form that `string` writes, so `parse(Complex{T}, string(z))` fails for those values

# Body

```julia-repl
julia> z = Complex{Int8}(-128, -128); string(z)
"-128 - 128im"

julia> parse(Complex{Int8}, string(z))
ERROR: OverflowError: overflow parsing " 128"

julia> parse(Int8, "-128")                          # the real parser handles typemin
-128

julia> parse(Complex{Int}, "0 - 9223372036854775808im")
ERROR: OverflowError: overflow parsing " 9223372036854775808"

julia> w = 0.0 + Inf*im; string(w)
"0.0 + Inf*im"

julia> parse(Complex{Float64}, string(w))
ERROR: ArgumentError: cannot parse " Inf*" as Float64

julia> parse(Complex{Float64}, "Inf + 1.0im")        # a real Inf is fine
Inf + 1.0im
```

`tryparse_internal(::Type{Complex{T}}, …)` splits the string at the `+`/`-`
sign between the parts and parses the imaginary magnitude separately before
applying the sign, so a part equal to `typemin(T)` overflows although it is
representable; `parse(T, "-128")` itself handles the sign and succeeds. For an
infinite or NaN imaginary part, `show` writes `Inf*im` / `NaN*im` (with the
`*` that makes the text valid Julia), but the parser expects the imaginary
unit to follow the number directly. Either the printer or the parser should
accept the other's form so that `parse(Complex{T}, string(z))` round-trips.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Found by a probe of
complex text round trips. Searches for `parse Complex typemin overflow` and
`parse Complex Inf im` found no matching issue (2026-11-14).

Assisted-by: AI

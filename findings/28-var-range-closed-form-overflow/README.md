# 28: `var(::AbstractRange)` overflows in the closed form: negative variance for narrow integer ranges and for long `Int64` ranges

- Kind: issue for `JuliaStats/Statistics.jl#219`
- Status: posted ([JuliaStats/Statistics.jl#219](https://github.com/JuliaStats/Statistics.jl/issues/219))

# Title

`var(::AbstractRange)` overflows in the closed form: negative variance for narrow integer ranges and for long `Int64` ranges

# Body

```julia-repl
julia> using Statistics

julia> r = Int8(-1):Int8(126):Int8(127);

julia> var(r), var(collect(r))
(-7934.0, 7938.0)

julia> std(r)
ERROR: DomainError with -7934.0:
sqrt was called with a negative real argument ...

julia> var(1:3_000_000_000)
-2.3244573453682586e18      # exact: 7.5e17
```

`varm(v::AbstractRange, m; corrected)` uses the closed form
`abs2(s) * (l + 1) * l / 12` with `s = step(v)` and `l = length(v)`.
`abs2(s)` is evaluated in the element type, so `abs2(Int8(126))` wraps, and
`(l + 1) * l` is an `Int` product that overflows once the length exceeds
about `3.04e9`. The same two problems exist in `range_varm` (`abs2(f)`,
`abs2(s)`, `l * (2 * l - 1)`), which is used when a `mean` is supplied.

This is the `var` counterpart of #120, where `mean` of integer ranges was
computed in the element type; converting `s`, `f` and `l` to `float` first,
as `mean(::AbstractRange)` now does, would fix both.

Reproduces for `Int8`, `UInt8`, `Int16` and `Int64` ranges on Statistics
1.11.5 (the registry version, also bundled with Julia nightly 1.15.0-DEV.720).
The Statistics 1.11.2 bundled with Julia 1.13.3 has no `varm(::AbstractRange)`
method: there `var(1:3_000_000_000)` is correct, but `var(Int8(-1):Int8(126):Int8(127))`
returns `2.0` through the generic path (`abs2` of the centered `Int8` values
wraps), so narrow integer ranges were already wrong before the closed form.
Searches for `var range`, `var overflow`, `std range` and `varm range` found
no matching issue or PR (2026-11-13).

Assisted-by: AI

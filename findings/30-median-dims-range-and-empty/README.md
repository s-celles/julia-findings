# 30: `median(r; dims=1)` on a range throws `CanonicalIndexError`; `median`, `cor` and `cov` of empty ranges return values instead of throwing

- Kind: issue for `JuliaStats/Statistics.jl#221`
- Status: posted ([JuliaStats/Statistics.jl#221](https://github.com/JuliaStats/Statistics.jl/issues/221))

# Title

`median(r; dims=1)` on a range throws `CanonicalIndexError`; `median`, `cor` and `cov` of empty ranges return values instead of throwing

# Body

```julia-repl
julia> using Statistics

julia> median([1, 2, 3]; dims=1)
1-element Vector{Float64}:
 2.0

julia> median(1:3; dims=1)
ERROR: CanonicalIndexError: setindex! not defined for UnitRange{Int64}

julia> median(1:0)
NaN

julia> median(Int[])
ERROR: ArgumentError: median of an empty array is undefined, Int64[]

julia> cor(1:0, 1:0), cov(1:0, 1:0)
(1.0, -0.0)

julia> cor(Int[], Int[])
ERROR: ArgumentError: correlation only defined for non-empty vectors

julia> v = Int[]; cor(v, v)
1.0
```

`cor(x, y)` and `cov(x, y)` short-circuit on `x === y` before the empty
check, and two equal ranges are `===` (they are immutable), so `cor(1:0,
1:0)` is `1.0`; the same happens for a `Vector` passed twice.

`_median(v::AbstractArray, dims) = mapslices(median!, v, dims = dims)`
applies the in-place `median!` to views of `v`; for a range the view is
immutable and the partial sort fails. `median(r::AbstractRange{<:Real}) =
mean(r)` has no empty check, so it returns `NaN` where the array method
throws `ArgumentError`. Both differ from `median(collect(r); dims=1)` and
`median(collect(r))`.

Collecting the slices before `median!` (or using `median(view)` which
copies) fixes the first; `isempty(r) && throw(ArgumentError(...))` the
second.

Reproduces for every range type on Statistics 1.11.2 (bundled with Julia
1.13.3) and 1.11.5 (registry, bundled with nightly 1.15.0-DEV.720). Searches for `median range`, `median dims range`,
`median empty range NaN`, `correlation empty vector`, `covariance empty`, and
`CanonicalIndexError median` found no matching issue or PR (2026-11-13).

Assisted-by: AI

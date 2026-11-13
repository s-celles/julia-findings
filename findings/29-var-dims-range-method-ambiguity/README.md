# 29: `var(r; dims=1)` on a range throws a `MethodError` (ambiguous `varm` keyword call)

- Kind: issue for `JuliaStats/Statistics.jl#220`
- Status: posted ([JuliaStats/Statistics.jl#220](https://github.com/JuliaStats/Statistics.jl/issues/220))

# Title

`var(r; dims=1)` on a range throws a `MethodError` (ambiguous `varm` keyword call)

# Body

```julia-repl
julia> using Statistics

julia> var([1, 2, 3]; dims=1)
1-element Vector{Float64}:
 1.0

julia> var(1:3; dims=1)
ERROR: MethodError: kwcall(::@NamedTuple{corrected::Bool, dims::Int64}, ::typeof(varm), ::UnitRange{Int64}, ::Vector{Float64}) is ambiguous.

Candidates:
  kwcall(::NamedTuple, ::typeof(varm), v::AbstractRange, m; corrected::Bool)
  kwcall(::NamedTuple, ::typeof(varm), A::AbstractArray, m::AbstractArray; corrected::Bool, dims)
```

`_var(A::AbstractArray, corrected, mean, dims)` computes `mean(A; dims)` (a
`Vector`) and then calls `varm(A, mean; corrected, dims)`. For a range both
`varm(::AbstractRange, m; corrected)` and `varm(::AbstractArray,
::AbstractArray; corrected, dims)` apply and neither is more specific. `std`
and `var` with `dims` fail the same way for every range type (`UnitRange`,
`StepRange`, `StepRangeLen`, `LinRange`), while `mean(r; dims=1)` works.

Restricting the range method to `m::Number` (its closed form only makes
sense for a scalar mean) would remove the ambiguity.

Reproduces on Statistics 1.11.5 (registry, and bundled with Julia nightly
1.15.0-DEV.720). It is a regression: the Statistics 1.11.2 bundled with Julia
1.13.3 has no range-specific `varm` and returns `[1.0]`. Searches for `varm
ambiguous`, `var dims range` and `ambiguous` found no matching issue or PR
(2026-11-13).

Assisted-by: AI

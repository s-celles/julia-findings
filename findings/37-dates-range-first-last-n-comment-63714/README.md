# 37: Comment on JuliaLang/julia#63714: This PR also fixes a small but user-visible consequence of the current

- Kind: comment for `JuliaLang/julia#63714`
- Status: not posted

This PR also fixes a small but user-visible consequence of the current
`checked_length(::StepRange{<:TimeType})` implementation: `first(r, n)` and
`last(r, n)` currently fail even for tiny Date/DateTime ranges.

```julia-repl
julia> using Dates

julia> r = Date(2020, 1, 1):Day(1):Date(2020, 1, 2);

julia> length(r)
2

julia> Base.checked_length(r)
ERROR: MethodError: no method matching checked_sub(::Date, ::Date)

julia> first(r, 2)
ERROR: MethodError: no method matching checked_sub(::Date, ::Date)

julia> last(r, 2)
ERROR: MethodError: no method matching checked_sub(::Date, ::Date)
```

The generic `first(v::AbstractVector, n)` and `last(v::AbstractVector, n)`
methods call `checked_length(v)`. The new `valuerange`-based
`checked_length` in this PR appears to make both operations work again. It
would be useful to add direct tests for `first(r, 2)` and `last(r, 2)` so this
effect is covered independently of the extreme-range tests.

This reproduces on Julia 1.13.3 and official nightly 1.15.0-DEV.720 (commit
31cf85936ac). Searches for `first range Date checked_sub`, `first(r, n) Date
range`, `checked_sub Date first`, and `last Date StepRange` found no separate
issue or PR (2026-11-13).

Assisted-by: AI

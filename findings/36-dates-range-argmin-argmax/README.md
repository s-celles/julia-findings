# 36: `argmin` and `argmax` fail on Date/DateTime ranges by comparing a `Period` step with integer zero

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`argmin` and `argmax` fail on Date/DateTime ranges by comparing a `Period` step with integer zero

# Body

```julia-repl
julia> using Dates

julia> r = Date(2020, 1, 1):Day(1):Date(2020, 1, 2);

julia> argmin(r)
ERROR: MethodError: no method matching isless(::Int64, ::Day)

julia> argmax(r)
ERROR: MethodError: no method matching isless(::Int64, ::Day)

julia> argmin(collect(r)), argmax(collect(r))
(1, 2)
```

The `argmin(r::AbstractRange)` and `argmax(r::AbstractRange)` specializations
both branch on `step(r) > 0`. Here `step(r)` is `Day(1)`, so the comparison
dispatches to `isless(::Int64, ::Day)` and fails. Comparing against
`zero(step(r))` instead works for this range. The same problem occurs for
`DateTime` ranges and for other `Period` step types.

Reproduces on Julia 1.13.3 and official nightly 1.15.0-DEV.720 (commit
31cf85936ac). Searches for `argmin Date range`, `argmax StepRange Period`,
`isless Day range`, `isless Int64 Day`, `argmin Period`, and corresponding
PRs found no matching report (2026-11-13).

Assisted-by: AI

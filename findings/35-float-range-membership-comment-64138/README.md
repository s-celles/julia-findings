# 35: Comment on JuliaLang/julia#64138: The model-versus-elements gap also affects membership and breaks the

- Kind: comment for `JuliaLang/julia#64138`
- Status: not posted

The model-versus-elements gap also affects membership and breaks the
reflexivity of `issubset`:

```julia-repl
julia> r = range(Float16(-32752); step=Float16(10), length=2);

julia> collect(r)
2-element Vector{Float16}:
 -3.275e4
 -3.274e4

julia> map(x -> x in r, collect(r))
2-element Vector{Bool}:
 1
 0

julia> issubset(r, r), issubset(collect(r), collect(r))
(false, true)
```

The second value is produced by iteration but the range membership
calculation does not recognize it. Consequently a collection is not reported
as a subset of itself. This is the membership counterpart of the
`unique`/`allunique` discrepancy in this issue, rather than an independent
report.

This reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches for
`issubset range Float16`, `issubset AbstractRange`, `range membership own
elements`, `StepRangeLen membership`, and `issubset floating range` found no
more specific issue or PR (2026-11-13). The local julia-in-lean corpus has
integer range membership and subset properties but no floating-range case.

Assisted-by: AI

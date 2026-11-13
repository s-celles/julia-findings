# 08: Comment on JuliaLang/julia#54364: There are value-level `map`/broadcast inconsistencies in the range-preserving

- Kind: comment for `JuliaLang/julia#54364`
- Status: not posted

There are value-level `map`/broadcast inconsistencies in the range-preserving
broadcast specializations. A one-element `StepRangeLen{Float16}` is enough:

```julia
r = range(Float16(0.1); step=Float16(0.1), length=1)
x = Float16(0.1)

collect(r .- x)                 # Float16[2.444e-5]
map(y -> y - x, r)              # Float16[0.0]
collect(r) .- x                 # Float16[0.0]

collect(r ./ Float16(0))        # Float16[NaN]
collect(r) ./ Float16(0)        # Float16[Inf]
```

`first(r) == x`, so the elementwise results are zero and positive infinity.
The optimized `StepRangeLen` broadcast methods appear to operate on the
range's higher-precision internal reference rather than its yielded `Float16`
element.

The generic `AbstractRange` division specialization also has a more severe
mixed-signedness case:

```julia
r = UInt64(1):UInt64(2)

r ./ Int16(-2)             # InexactError: UInt64(1.8446744073709552e19)
r / Int16(-2)              # same
collect(r) ./ Int16(-2)    # [-0.5, -1.0]
map(x -> x / Int16(-2), r) # [-0.5, -1.0]
```

`broadcasted(/, r::AbstractRange, x::Number)` constructs a new range from
`first(r)/x` and `step(r)/x`. Here its inferred construction tries to convert
the negative result back through `UInt64`, before any element can be returned.

Both examples reproduce on Julia 1.13.3 and nightly 1.15.0-DEV.720. The local
corpus case `broadcastcov-steprangelen-div-elementwise` covers a one-ulp
Float64 division difference in the `StepRangeLen` specialization, but not the
`UInt64` exception above. Searches for `range division negative integer
InexactError`, `unsigned range division negative`, `AbstractRange division
InexactError`, `broadcast division UInt64 range`, and `range / scalar
InexactError` found no more specific issue or PR (2026-11-13).

This seems related to this issue's map/broadcast inconsistency, but it changes
numeric values, not only the result type or representation.

Found with a differential range/broadcast probe in Concolic.jl.

Assisted-by: AI

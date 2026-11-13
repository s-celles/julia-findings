# 49: `mod(i, r::AbstractUnitRange)` overflows in `i - first(r)` and returns a wrong element for `typemin` and for unsigned `i` below the range

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`mod(i, r::AbstractUnitRange)` overflows in `i - first(r)` and returns the wrong element for `typemin` inputs and for unsigned `i` below the range

# Body

```julia-repl
julia> mod(typemin(Int), 1:3)        # exact: mod(typemin(Int) - 1, 3) + 1 == 1
2

julia> mod(UInt(0), UInt(1):UInt(3)) # exact: 3
1

julia> mod(UInt8(0), UInt8(1):UInt8(3))
0x01

julia> mod(typemax(Int), -3:-1)      # exact: -2
-3

julia> mod(0, 1:3), mod(-1, 1:3)     # no overflow: correct
(3, 2)
```

`mod(i::Integer, r::AbstractUnitRange{<:Integer}) = mod(i - first(r),
length(r)) + first(r)` (`base/range.jl`). The subtraction is done in the
input type: for `typemin` it wraps to `typemax`, and for an unsigned `i`
smaller than `first(r)` it wraps to a large value, so the subsequent `mod`
by the length lands on another element of the range. The results are
always inside `r`, which makes the error easy to miss. The `OneTo` method
(`mod1(i, last(r))`) does not have the problem.

Computing `mod(i, length(r)) - mod(first(r), length(r))` modulo the length,
or doing the subtraction in a widened type, would fix it.

Found by an exhaustive probe of fixed-width integer arithmetic against
`BigInt`. Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches
for `mod range overflow typemin`, `mod UnitRange overflow` and `mod integer
range overflow typemin wrap` found no matching issue or PR (2026-11-14).

Assisted-by: AI

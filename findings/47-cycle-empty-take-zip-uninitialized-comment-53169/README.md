# 47: Comment on JuliaLang/julia#53169: `take`, `zip` and tuple/String inputs are further ways to read uninitialized memory from `Iterators.cycle` of an empty collection

- Kind: comment for `JuliaLang/julia#53169`
- Status: not posted

# Body

Same root cause as `first(Iterators.cycle(Int[]), 5)` above (`IsInfinite`
for an empty cycle, so the `length` of a `Take` or a `zip` is trusted and the
output array is allocated but never filled), reached through other entry
points, on Julia 1.13.3 and nightly 1.15.0-DEV.720:

```julia-repl
julia> collect(Iterators.take(Iterators.cycle(Int[]), 2))
2-element Vector{Int64}:
 0
 0

julia> collect(zip(Iterators.cycle(Int[]), 1:2))
2-element Vector{Tuple{Int64, Int64}}:
 (941288, 139922838874048)
 (139922784001840, 139922853126384)

julia> collect(Iterators.take(Iterators.cycle(()), 2))
2-element Vector{Union{}}:
 #undef
 #undef

julia> collect(Iterators.take(Iterators.cycle(""), 2))
2-element Vector{Char}:
 '\x00\x00\x00\x0e': Malformed UTF-8 (category Ma: Malformed, bad data)
 '\0': ASCII/Unicode U+0000 (category Cc: Other, control)
```

The `zip` case leaks whatever the freed memory held, and the `Tuple{}` case
produces a `Vector{Union{}}` with unassigned slots, which no other Base
function can create. `collect(Iterators.cycle(Int[], 2))`, the counted form,
is correct (`Int64[]`), so checking `isempty` in `_min_length` for
`IsInfinite` iterators (as suggested above) would fix all of these at once.

Found by a differential probe comparing `Base.Iterators` on ranges, tuples,
strings and sets with the same expressions on the collected vectors.

Assisted-by: AI

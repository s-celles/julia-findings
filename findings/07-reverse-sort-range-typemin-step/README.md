# 07: `reverse` and `sort` can drop elements of an integer range whose step is `typemin`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

> Deduplication review (2026-11-13): this exactly duplicates corpus cases
> `ranges-operations-reverse-typemin` and `range-sort-typemin-step`. Retained
> for reference, not as a new finding. The range contract probe (same day)
> found the same `typemin` step through `Iterators.reverse` and `foldr`:
> `collect(Iterators.reverse(Int64(-9223372036854775807):typemin(Int64):1))`
> returns `[-9223372036854775806]` and `foldr(-, …)` returns that value, for
> a range whose `collect` is empty.

# Title

`reverse` and `sort` can drop elements of an integer range whose step is `typemin`

# Body

```julia-repl
julia> r = Int8(0):Int8(-128):Int8(-128);

julia> collect(r)
2-element Vector{Int8}:
    0
 -128

julia> collect(reverse(r))
0-element Vector{Int8}

julia> reverse(collect(r))
2-element Vector{Int8}:
 -128
    0

julia> collect(sort(r))
0-element Vector{Int8}

julia> sort(collect(r))
2-element Vector{Int8}:
 -128
    0
```

The range has two elements. Reversing it requires a positive step of 128, which
cannot be represented as `Int8`; the range-specialized operation wraps the
step and constructs an empty range. `sort` on a descending range reaches the
same failure. This also reproduces on the official nightly
`1.15.0-DEV.405b27cae9` (2026-11-07).

This is already covered by the corpus cases named above. Searches
for `reverse StepRange typemin`, `sort StepRange typemin`,
`reverse range negative step overflow` and `StepRange step typemin` returned no
matching issue.

Found with Concolic.jl by comparing range operations with operations on their
collected elements.

Assisted-by: AI

# 38: `reverse` and `sort` change the elements of Date ranges with Month/Year steps at calendar boundaries

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`reverse` and `sort` change the elements of Date ranges with Month/Year steps at calendar boundaries

# Body

```julia-repl
julia> using Dates

julia> r = Date(2020, 1, 31):Month(1):Date(2020, 2, 29);

julia> collect(r)
2-element Vector{Date}:
 2020-01-31
 2020-02-29

julia> collect(reverse(r))
2-element Vector{Date}:
 2020-02-29
 2020-01-29

julia> reverse(collect(r))
2-element Vector{Date}:
 2020-02-29
 2020-01-31
```

The same happens across a leap-day Year step:

```julia-repl
julia> y = Date(2020, 2, 29):Year(1):Date(2021, 2, 28);

julia> collect(reverse(y))
2-element Vector{Date}:
 2021-02-28
 2020-02-28

julia> reverse(collect(y))
2-element Vector{Date}:
 2021-02-28
 2020-02-29
```

Since `sort(::AbstractRange)` reverses a descending range, it inherits the
same problem:

```julia-repl
julia> d = Date(2020, 3, 31):Month(-1):Date(2020, 2, 29);

julia> collect(sort(d))
2-element Vector{Date}:
 2020-02-29
 2020-03-29

julia> sort(collect(d))
2-element Vector{Date}:
 2020-02-29
 2020-03-31
```

`_reverse(r::OrdinalRange, ::Colon)` constructs
`last(r):negate(step(r)):first(r)`. That is valid for affine steps, but
calendar Month/Year addition clamps at month boundaries and is not invertible.

#64598 and #63714 fix Month/Year ranges that pass their stop. With that fix,
the first reversed range should stop after `2020-02-29` rather than yielding
the wrong `2020-01-29`; it would still lose the original first element. So
reversal of irregular calendar ranges needs a separate fallback or
representation.

Reproduces on Julia 1.13.3 and official nightly 1.15.0-DEV.720 (commit
31cf85936ac). Searches for `reverse Date Month range`, `reverse date range
month end`, `reverse Date range leap year`, and `reverse Month(1) Date` found
no matching issue or PR (2026-11-13).

Assisted-by: AI

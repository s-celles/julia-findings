# 06: `findfirst` and `findlast` can return `-1` for an element in a signed integer range

- Kind: issue for `JuliaLang/julia`
- Status: not posted

> Deduplication review (2026-11-13): this is the known corpus family
> `ranges-operations-findfirst-overflow`. Retained for the release/nightly
> comparison, not as a new finding.

# Title

`findfirst` and `findlast` can return `-1` for an element in a signed integer range

# Body

```julia-repl
julia> r = Int8(-128):Int8(64):Int8(0);

julia> findfirst(==(Int8(0)), r)
-1

julia> findfirst(==(Int8(0)), collect(r))
3

julia> findlast(==(Int8(0)), r)
-1

julia> findlast(==(Int8(0)), collect(r))
3
```

The range contains `Int8[-128, -64, 0]`, so both searches should return index
3. The same behavior appeared on Julia 1.13.0 for all signed integer widths
tested. It does not reproduce on the official nightly
`1.15.0-DEV.405b27cae9` (2026-11-07), where both calls return 3. No matching
issue or pull request was found in the searches listed in `findings/README.md`;
this draft records a release regression that appears already fixed on master.

Found with Concolic.jl by comparing range searches with searches over the
collected elements.

Assisted-by: AI

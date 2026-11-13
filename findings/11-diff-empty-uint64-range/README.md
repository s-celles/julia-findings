# 11: `diff` throws on an empty `UInt64` range while the collected vector succeeds

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`diff` throws on an empty `UInt64` range while the collected vector succeeds

# Body

On x86_64 Linux:

```julia-repl
julia> r = UInt64(1):UInt64(0);

julia> isempty(r)
true

julia> diff(r)
ERROR: InexactError: convert(Int64, 0xffffffffffffffff)

julia> diff(collect(r))
0-element Vector{UInt64}
```

The same error occurs for the empty step range
`UInt64(1):UInt64(2):UInt64(0)`. Both cases were verified on Julia 1.13.3
(commit `67ac47b9cd855e02134d41d5428ac9f2a73f2694`) and official nightly
1.15.0-DEV.688 (commit `0f1b85161a005f1aa82cbffa33ecc046273b6f7a`).

The range-specialized method in `base/multidimensional.jl` iterates over
`firstindex(r):lastindex(r)-1`. For this empty range, `lastindex(r)` is
`UInt64(0)`, and subtracting one wraps to `typemax(UInt64)`. Constructing the
comprehension result then fails while converting its size to `Int`. An empty
result would agree with `diff` on the corresponding vector.

Deduplication on 2026-11-13 found no matching entry in the `julia-in-lean`
corpus at commit `de862b56ffbf2dd2ea210b82b3c235b0550624ec`, and no matching
JuliaLang/julia issue or PR with the queries recorded in `findings/README.md`.
Closed issues [#36116](https://github.com/JuliaLang/julia/issues/36116) and
[#41336](https://github.com/JuliaLang/julia/issues/41336) describe different
range `diff` failures.

Found with Concolic.jl by comparing range operations with operations on their
mathematical element vectors; minimized and checked on stock Julia.

Assisted-by: AI

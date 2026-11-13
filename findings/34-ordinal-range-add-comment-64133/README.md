# 34: Comment on JuliaLang/julia#64133: Range-to-range addition reaches the same invalid small-integer

- Kind: comment for `JuliaLang/julia#64133`
- Status: posted ([JuliaLang/julia#64133](https://github.com/JuliaLang/julia/issues/64133#issuecomment-6854594414))

Range-to-range addition reaches the same invalid small-integer
`StepRangeLen`, without using broadcasted scalar multiplication:

```julia-repl
julia> r = UInt8(127):UInt8(128);

julia> collect(r) + collect(r)
2-element Vector{UInt8}:
 0xfe
 0x00

julia> s = r + r;

julia> typeof(s)
StepRangeLen{UInt8, UInt8, UInt8, Int64}

julia> collect(s)
ERROR: InexactError: trunc(UInt8, 256)
```

The range method builds the result from the first-element sum, step sum and
length. `StepRangeLen` then computes the second element as the exact integer
`256` and converts it to `UInt8`, rather than applying wrapping `UInt8`
addition element by element.

This reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. It is an exact
rediscovery of the `rangescov-ordinal-add-small-int` corpus case, so it should
not be filed as an independent issue. Read-only issue and PR searches for
`range addition InexactError StepRangeLen`, `StepRangeLen addition overflow`,
and `trunc(UInt8) StepRangeLen` found no direct report; #64133 is the matching
root-cause family.

Assisted-by: AI

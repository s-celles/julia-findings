# 48: `rem(x, y, RoundNearest)` throws `DivideError` when the quotient overflows although the remainder is representable, and wraps for unsigned types

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`rem(x, y, RoundNearest)` throws `DivideError` when the quotient overflows although the remainder is representable, and returns a wrapped negative remainder for unsigned types

# Body

```julia-repl
julia> rem(typemin(Int), -1)
0

julia> rem(typemin(Int), -1, RoundNearest)
ERROR: DivideError: integer division error

julia> rem(2, 3, RoundNearest)
-1

julia> rem(UInt(2), UInt(3), RoundNearest)
0xffffffffffffffff

julia> rem(UInt8(2), UInt8(3), RoundNearest)
0xff
```

The generic fallback is `rem(x, y, r::RoundingMode) = x - y * div(x, y, r)`.
For `typemin(T)` and `-1` the quotient `div(x, y, RoundNearest)` overflows
and throws, although the remainder is `0` and `rem(x, y)` (round toward
zero) returns it; the exact result is representable but unreachable. For
unsigned types the nearest-rounding remainder is negative half of the time,
and the subtraction wraps silently instead of throwing or being rejected,
giving `typemax` where the mathematical value is `-1`. `div(UInt8(2),
UInt8(3), RoundNearest)` is `0x01`, consistent with that, so the wrap is in
the final subtraction.

Found by an exhaustive probe of fixed-width integer arithmetic against
`BigInt` on all 8-bit pairs and edge values of the wider types. Reproduces on
Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches for `rem RoundNearest
DivideError`, `rem RoundNearest unsigned` and `rem RoundNearest overflow`
found no matching issue or PR (2026-11-14).

Assisted-by: AI

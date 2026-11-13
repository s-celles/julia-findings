# 04: Comment on JuliaLang/julia: A further consequence of the generic two-argument `checked_*` methods calling

- Kind: comment for `JuliaLang/julia`
- Status: not posted

# Comment on #54485

A further consequence of the generic two-argument `checked_*` methods calling
`promote(x, y)`: with a negative signed argument and an unsigned one, they throw
`InexactError` from the promotion even when the exact result is representable,
whereas the unchecked operators work:

```julia
julia> Base.Checked.checked_add(UInt8(200), Int8(-1))   # 199 fits in UInt8
ERROR: InexactError: convert(UInt8, -1)

julia> UInt8(200) + Int8(-1)
0xc7

julia> Base.Checked.checked_rem(Int8(-128), UInt8(1))
ERROR: InexactError: convert(UInt8, -128)

julia> rem(Int8(-128), UInt8(1))
0
```

The same applies to `checked_sub`, `checked_mul`, `checked_div`, `checked_fld`,
`checked_mod`, `checked_cld`, and also to `mod1` and `fld1` (e.g.
`mod1(Int8(-128), UInt8(1))` throws while `mod(Int8(-128), UInt8(1)) == 0x00`).
An `InexactError` from a checked operation whose mathematical result fits the
result type is surprising: the caller asked for an overflow check, not for a
conversion check of the operands.

Reproduced on Julia 1.13.0 and master (1.15.0-DEV.581, commit 7959b61a8f2).
Found with Concolic.jl, a concolic testing prototype, by comparing each
function with the same function evaluated on wider integers (101 type/function
combinations in a sweep over {Int8, UInt8, Int16, UInt16, Int64, UInt64}).

Assisted-by: AI

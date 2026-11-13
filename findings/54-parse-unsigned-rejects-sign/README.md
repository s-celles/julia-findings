# 54: `parse(::Type{<:Unsigned}, "+5")` rejects the sign with "invalid base 10 digit '+'", while signed and `BigInt` parsing accept it

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`parse(T, "+5")` for an unsigned `T` throws "invalid base 10 digit '+'", while `parse(Int8, "+5")` and `parse(BigInt, "+5")` accept the sign

# Body

```julia-repl
julia> parse(Int8, "+5"), parse(BigInt, "+5"), parse(Int8, "-0x5")
(5, 5, -5)

julia> parse(UInt8, "+5")
ERROR: ArgumentError: invalid base 10 digit '+' in "+5"

julia> parse(UInt, "+10"; base=16)
ERROR: ArgumentError: invalid base 16 digit '+' in "+10"

julia> parse(UInt8, "-0")          # the value is representable
ERROR: ArgumentError: invalid base 10 digit '-' in "-0"

julia> tryparse(UInt8, "+5")
```

`tryparse_internal` calls `parseint_preamble(T <: Signed, …)`, which consumes
an optional sign only when the target type is signed, so for unsigned types
the sign character reaches the digit loop and is reported as an invalid
digit. Whether unsigned targets should accept `+` (and `-0`) is a design
question, but the current behaviour is inconsistent with the signed and
`BigInt` methods, undocumented in `parse`'s docstring, and the error message
is misleading: `'+'` is a sign, not a digit. Accepting an explicit `+`
(and perhaps `-` only when the resulting value is zero), or saying "sign not
allowed for unsigned types", would both be clearer.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Found by an exhaustive
text round-trip probe over 8-bit and 16-bit integers in every base. Searches
for `parse unsigned plus sign`, `parse UInt leading +` and `parse Unsigned
sign invalid digit` found no matching issue (2026-11-14).

Assisted-by: AI

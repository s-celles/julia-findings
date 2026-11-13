# 05: Comment on JuliaLang/julia#64133: I found related integer cases for `.+` and `.-` on ranges, in both operand

- Kind: comment for `JuliaLang/julia#64133`
- Status: posted ([JuliaLang/julia#64133](https://github.com/JuliaLang/julia/issues/64133#issuecomment-6819095568), 2026-11-12)

> Deduplication review (2026-11-13): the UnitRange addition/subtraction failure
> is already in the `julia-in-lean` corpus as `ranges-broadcast-add-length`.
> Retain this as a follow-up covering additional operand orders and types;
> do not count the underlying family as new.

I found related integer cases for `.+` and `.-` on ranges, in both operand
orders. These methods rebuild a range instead of evaluating each element.
Fixed-width overflow in shifted endpoints or in the negated step can make the
result empty or throw even though elementwise broadcasting returns values.

```julia-repl
julia> r = Int8(0):Int8(1):Int8(1);

julia> collect(r .+ Int8(127))
0-element Vector{Int8}

julia> collect(r) .+ Int8(127)
2-element Vector{Int8}:
  127
 -128

julia> r = UInt64(127):UInt64(1):UInt64(128);

julia> collect(r .- UInt8(128))
0-element Vector{UInt64}

julia> collect(r) .- UInt8(128)
2-element Vector{UInt64}:
 0xffffffffffffffff
 0x0000000000000000

julia> r = Int8(-128):Int8(1):Int8(-127);

julia> collect(Int8(-1) .+ r)
0-element Vector{Int8}

julia> Int8(-1) .+ collect(r)
2-element Vector{Int8}:
  127
 -128

julia> collect(Int8(0) .- r)
0-element Vector{Int8}

julia> Int8(0) .- collect(r)
2-element Vector{Int8}:
 -128
  127

julia> r = UInt8(0):UInt8(255):UInt8(255);

julia> collect(UInt8(0) .- r)
ERROR: InexactError: convert(Int8, 0xff)

julia> UInt8(0) .- collect(r)
2-element Vector{UInt8}:
 0x00
 0x01
```

Reproduced on Julia 1.13.0 and the official nightly `1.15.0-DEV.676`
(commit `bc488cb7924c8395f1a77fd3560dce05dfb5aef3`, 2026-11-12). The related
issue reports `.*`; these examples exercise the separate
`.+` and `.-` range broadcast methods in `base/broadcast.jl`. The unsigned
scalar-left subtraction also hits the range method's step-negation path and
throws instead of producing the two wrapped elements.

Found with Concolic.jl by comparing range broadcasting with broadcasting over
the collected elements.

Assisted-by: AI

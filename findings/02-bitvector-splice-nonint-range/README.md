# 02: `splice!(::BitVector, r)` only accepts `AbstractUnitRange{Int}`, while `splice!(::Vector, r)` accepts any integer range

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`splice!(::BitVector, r)` only accepts `AbstractUnitRange{Int}`, while `splice!(::Vector, r)` accepts any integer range

# Body

```julia
julia> v = Bool[1, 0, 1, 1]; b = BitVector(v);

julia> splice!(copy(v), Int8(2):Int8(3))
2-element Vector{Bool}:
 0
 1

julia> splice!(copy(b), Int8(2):Int8(3))
ERROR: MethodError: no method matching splice!(::BitVector, ::UnitRange{Int8})

julia> splice!(copy(b), Int32(2):Int32(3), [true])    # same with a replacement
ERROR: MethodError: no method matching splice!(::BitVector, ::UnitRange{Int32}, ::Vector{Bool})

julia> deleteat!(copy(b), Int8(2):Int8(3))            # deleteat! accepts it
2-element BitVector:
 1
 1
```

Expected: the same results as for `Vector{Bool}`.

Cause (Julia 1.13.0, `base/bitarray.jl`): the methods are declared as
`splice!(B::BitVector, r::Union{AbstractUnitRange{Int}, Integer}, ins...)`
(lines 1079 and 1123), whereas `splice!(a::Vector, r::AbstractUnitRange{<:Integer})`
(`base/array.jl`) and `deleteat!(::BitVector, ...)` accept any integer element
type.

Possible fix: widen the signature to `AbstractUnitRange{<:Integer}` and
convert with `Int(first(r)):Int(last(r))`, as the `Vector` method does.

Reproduced on Julia 1.10, 1.12, 1.13.0 and master (1.15.0-DEV.581, commit 7959b61a8f2, 2026-11-07). Related but different: #64148
(empty `Int` ranges rejected by `deleteat!`/`splice!` on `BitVector`).

Found with Concolic.jl, a concolic testing prototype, by comparing BitVector
operations with the same operations on `Vector{Bool}`.

Assisted-by: AI

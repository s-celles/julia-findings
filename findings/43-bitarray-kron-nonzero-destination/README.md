# 43: `kron!` for `BitVector` and `BitMatrix` leaves stale true bits in zero result blocks

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1878](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1878))

# Title

`kron!` for `BitVector` and `BitMatrix` leaves stale true bits in zero result blocks

# Body

```julia-repl
julia> using LinearAlgebra

julia> only(kron!(trues(1), falses(1), trues(1)))
true

julia> only(kron!(Bool[true], Bool[false], Bool[true]))
false

julia> only(kron!(trues(1, 1), falses(1, 1), trues(1, 1)))
true

julia> only(kron!(Bool[true;;], Bool[false;;], Bool[true;;]))
false
```

The first argument is a separate, correctly sized preallocated destination.
`kron!` should overwrite it with the Kronecker product, which is false in
both examples, independently of the destination's previous contents.

In `src/bitarray.jl`, `kron!(R::BitVector, a::BitVector, b::BitVector)` only
copies `b` when `a[j]` is true. The `BitMatrix` specialization similarly only
assigns a result block inside `if a[i,j]`. Neither method clears result blocks
for false entries of `a`, so old true bits survive. The allocating `kron`
methods initialize `R` with `falses`, which hides the defect on those paths.

This reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official nightly
Julia 1.15.0-DEV.720 / LinearAlgebra 1.14.0.

Searches in the local catalogue and in both `JuliaLang/julia` and
`JuliaLang/LinearAlgebra.jl` for `BitArray kron!`, `BitVector kron!`,
`BitMatrix kron!`, `kron! destination BitArray`, `kron BitArray`, `kron
BitMatrix`, `kron! destination`, `Kronecker BitArray`, and the broad
individual terms `kron!` and `kron` found no direct issue or pull request
(2026-11-13).

Assisted-by: AI

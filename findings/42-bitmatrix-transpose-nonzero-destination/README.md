# 42: `transpose!(::BitMatrix, ::BitMatrix)` leaves old true bits in a nonzero destination

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

`transpose!(::BitMatrix, ::BitMatrix)` leaves old true bits in a nonzero destination

# Body

```julia-repl
julia> using LinearAlgebra

julia> only(transpose!(BitMatrix([true;;]), BitMatrix([false;;])))
true

julia> only(transpose!(Bool[true;;], Bool[false;;]))
false
```

The source and destination are separate matrices of the required transposed
sizes, so this is not the unsupported overlapping-memory case. `transpose!`
should overwrite the destination, independently of its previous contents.
Instead, any destination bit that is already true can remain true when the
corresponding transposed source bit is false.

In `src/bitarray.jl`, `put_8x8_chunk` is explicitly documented as assuming
that its destination is filled with zeros, and writes each packed block with
`|=`. The public `transpose!(C::BitMatrix, B::BitMatrix)` method at line 241
calls it without clearing `C`. The `copy(::Transpose{Bool,BitMatrix})` and
`copy(::Adjoint{Bool,BitMatrix})` callers allocate with `falses`, which hides
the problem on those paths, but a caller-supplied preallocated destination
has no such guarantee.

This reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official nightly
Julia 1.15.0-DEV.720 / LinearAlgebra 1.14.0.

Searches in the local catalogue and in both `JuliaLang/julia` and
`JuliaLang/LinearAlgebra.jl` for `BitMatrix transpose!`, `transpose!
BitArray`, `transpose! BitMatrix destination`, `BitMatrix transpose`,
`BitArray transpose`, `transpose! destination`, and `put_8x8_chunk` found no
direct issue or pull request (2026-11-13). The broad LinearAlgebra search
returned JuliaLang/LinearAlgebra.jl#408, a general transpose design discussion
that does not report this packed-destination overwrite bug.

Assisted-by: AI

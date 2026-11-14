# 41: `triu` and `tril` reject valid diagonal offsets for `BitMatrix`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1876](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1876))

# Title

`triu` and `tril` reject valid diagonal offsets for `BitMatrix`

# Body

```julia-repl
julia> using LinearAlgebra

julia> A = Bool[1 0];

julia> triu(A, -1)
1×2 Matrix{Bool}:
 1  0

julia> triu(BitMatrix(A), -1)
ERROR: ArgumentError: the requested diagonal, -1, must be at least0 and at most 3 in an 1-by-2 matrix

julia> B = reshape(Bool[1, 0], 2, 1);

julia> tril(B, 1)
2×1 Matrix{Bool}:
 1
 0

julia> tril(BitMatrix(B), 1)
ERROR: ArgumentError: the requested diagonal, 1, must be at least -3 and at most 0 in an 2-by-1 matrix
```

Both offsets are valid and simply select the whole matrix. The result should
not depend on whether the same Boolean matrix is packed as a `BitMatrix`.
More generally, dense `triu` and `tril` accept any integer offset: offsets
beyond the represented diagonals naturally produce either the whole matrix or
an all-zero matrix.

The specialized methods in `src/bitarray.jl` impose extra bounds before doing
the chunk copies. `triu(B::BitMatrix, k)` at line 45 rejects
`k < -size(B, 1) + 1`, while `tril(B::BitMatrix, k)` at line 61 rejects
`k > size(B, 2) - 1`. Those checks exclude the redundant but valid offsets
that select the whole matrix. They also reject still more distant offsets on
the opposite side even though those have a well-defined all-zero result.

This reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official nightly
Julia 1.15.0-DEV.720 / LinearAlgebra 1.14.0.

Searches in both `JuliaLang/julia` and `JuliaLang/LinearAlgebra.jl` for
`BitMatrix triu tril`, `"requested diagonal" BitMatrix`, `BitArray triangular
diagonal`, `BitMatrix diagonal ArgumentError`, `triu BitArray`, `tril
BitArray`, and the broader individual terms `triu`, `tril`, and `BitMatrix`
found no direct issue or pull request (2026-11-13). JuliaLang/julia#29711 is a
distinct old wrong-result bug in dense `triu!` for a rectangular matrix.
JuliaLang/LinearAlgebra.jl#508 concerns empty matrices, and does not cover
these nonempty `BitMatrix` inputs.

Assisted-by: AI

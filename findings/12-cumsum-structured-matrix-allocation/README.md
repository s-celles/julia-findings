# 12: `cumsum` tries to store non-structured results in structured matrix wrappers

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

`cumsum` tries to store non-structured results in structured matrix wrappers

# Body

On x86_64 Linux:

```julia-repl
julia> using LinearAlgebra

julia> A = Diagonal(Int8[1, 0]);

julia> cumsum(A; dims=1)
ERROR: ArgumentError: cannot set off-diagonal entry (2, 1) to a nonzero value (1)

julia> cumsum(Matrix(A); dims=1)
2×2 Matrix{Int64}:
 1  0
 1  0
```

The generic `cumsum` implementation allocates its output with
`similar(A, _accumulate_promote_op(add_sum, A))`. For structured matrices,
that preserves the `Diagonal` (or other structured) wrapper even though a
cumulative sum generally does not preserve the structure. `cumsum!` then
fails when it writes a mathematically valid nonzero outside the stored band.

A bounded differential sweep found the same root cause for 132
operation/type/structure signatures: both dimensions, all of `Bool`, `Int8`,
`UInt8`, `Int16`, `Int64` and `UInt64`, and 11 affected structured wrappers
per dimension. For example, direction-dependent failures also occur for
`Bidiagonal`, `Tridiagonal`, `SymTridiagonal`, `Symmetric`, `Hermitian`, and
triangular wrappers.

The minimal example reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and
official nightly Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0. Issue #271
discusses the broader ambiguity of `similar` for structured matrices, but I
found no issue or PR specifically covering `cumsum` with the searches
`cumsum structured matrix`, `cumsum Diagonal`, `_accumulate! Diagonal`, and
`cannot set off-diagonal entry cumsum` in JuliaLang/julia and
JuliaLang/LinearAlgebra.jl.

Assisted-by: AI

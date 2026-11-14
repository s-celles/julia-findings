# 09: Comment on JuliaSparse/SparseArrays.jl: In current SparseArrays, `diff` on sparse Boolean arrays either throws or

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: posted ([JuliaSparse/SparseArrays.jl#1175](https://github.com/JuliaSparse/SparseArrays.jl/issues/1175))

# `diff` on sparse Bool arrays does not promote its result to Int

In current SparseArrays, `diff` on sparse Boolean arrays either throws or
returns Boolean values, while dense `diff` returns `Int` as required by Julia's
arithmetic promotion for `Bool`.

```julia
using SparseArrays

diff(Bool[true, false])                  # [-1]::Vector{Int}
diff(sparsevec(Bool[true, false]))       # InexactError: Bool(-1)

diff(Bool[false, true])                  # [1]::Vector{Int}
diff(sparsevec(Bool[false, true]))       # SparseVector{Bool}: [1] = true

A = Bool[1 0; 0 1]
diff(A; dims=1)                          # [-1 1]::Matrix{Int}
diff(sparse(A); dims=1)                  # InexactError: Bool(-1)
diff(A; dims=2)                          # [-1; 1]::Matrix{Int}
diff(sparse(A); dims=2)                  # InexactError: Bool(-1)
```

This reproduces on Julia 1.15.0-DEV.688 with SparseArrays 1.14.0. Julia
1.13.0 with SparseArrays 1.13.0 returns integer results for the vector cases
and the matrix cases above. In the current implementation,
`_sparse_diff1_column!` writes `-val` into a buffer with the original element
type, and the sparse `diff` entry points allocate that buffer as `Vector{Tv}`.

An exhaustive small Boolean probe covered 2,355 sparse vector and matrix
inputs; every sparse result differed from dense `diff` by result element type,
value, or exception. The `Bool` arithmetic promotion rule is documented in
Julia's manual. Searches on 2026-11-12 for `diff Bool`, `SparseVector diff
Boolean`, and PRs for `diff Bool` in JuliaSparse/SparseArrays.jl returned no
matches.

Found with a differential SparseArrays probe in Concolic.jl.

Assisted-by: AI

# 77: `det` and `logabsdet` of a square `Rational` sparse matrix lose exactness (routed through UMFPACK/`Float64`); `Rational{BigInt}` throws

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: posted ([JuliaSparse/SparseArrays.jl#1184](https://github.com/JuliaSparse/SparseArrays.jl/issues/1184))

# Body

`det` and `logabsdet` of a `SparseMatrixCSC` with `Rational` elements go through the sparse LU
(UMFPACK, `Float64`), so they silently lose exactness where the dense `Matrix` path is exact:

```julia-repl
julia> using SparseArrays, LinearAlgebra

julia> A = Rational{Int}[2 1 0 0; 1 3 1 0; 0 1 4 1; 0 0 1 2]; S = sparse(A);

julia> det(S)            # sparse: Float64, inexact
30.999999999999996

julia> det(Matrix(S))    # dense: exact
31//1

julia> logabsdet(S)[2]   # sparse sign is Float64
1.0

julia> logabsdet(Matrix(S))[2]   # dense sign is Rational
1//1
```

With `Rational{BigInt}` the sparse path throws instead of returning the exact value:

```julia-repl
julia> B = Rational{BigInt}[2 1 0; 1 3 1; 0 1 4]; SB = sparse(B);

julia> det(SB)
ERROR: ArgumentError: matrix type SparseMatrixCSC{BigFloat, Int64} not supported.

julia> det(Matrix(SB))
18//1
```

Mechanism: `det(::SparseMatrixCSC)` / `logabsdet` factorize with the sparse `lu` (UMFPACK), which
supports only `Float64`/`ComplexF64`; for an exact element type the input is converted to
`float(eltype)` — `Rational{Int}` -> `Float64` (inexact, wrong value and wrong type) and
`Rational{BigInt}` -> `BigFloat` (unsupported -> `ArgumentError`). The dense generic `det`/`logabsdet`
stay exact. This is the `det`/`logabsdet` face of the sparse `\` Rational inexactness in
JuliaSparse/SparseArrays.jl#1179 (catalogue entry 70): same root (sparse factorization limited to BLAS
floats), distinct operation.

Versions checked: reproduced on SparseArrays with Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly
1.15.0-DEV.833 (SparseArrays 1.14.0). Note that on the same nightly the sparse `\` of entry 70 /
JuliaSparse/SparseArrays.jl#1179 is now exact (`S \ b` returns `Rational{Int}[7//31, 17//31, 4//31, 60//31]`),
so `det`/`logabsdet` are the remaining exact-arithmetic gap on master.

Deduplication searches (2026-11-18): in this catalogue, the Rational-sparse mechanism is entry 70 (the
`\` solve). Upstream `JuliaSparse/SparseArrays.jl` searches for `det rational`, `logabsdet`,
`det sparse exact` and `not supported UMFPACK` found no issue covering `det`/`logabsdet` of an
exact-type sparse matrix; dense/structured analogues exist in this catalogue (entry 65 `det` of
`Symmetric`/`Hermitian{Rational}` -> `Float64`), none for `SparseMatrixCSC`.

Found by a differential sparse-vs-dense probe (`det`/`logabsdet` of structured/sparse matrices against
the dense oracle). Reproducer: `sparse_rational_det_logabsdet_inexact.jl` (asserts the inexact sparse
result, the exact dense result, and the `Rational{BigInt}` throw; prints `REPRODUCED`).

Assisted-by: AI

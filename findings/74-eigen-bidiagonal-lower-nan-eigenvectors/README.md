# 74: `eigen` of a lower `Bidiagonal` returns `NaN` eigenvectors (eigenvalues correct); an integer upper `Bidiagonal` throws `InexactError`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1900](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1900))

# Body

`eigen(::Bidiagonal)` with `uplo = :L` computes the eigenvalues correctly but fills the eigenvectors
with `NaN`, where the dense path is clean:

```julia-repl
julia> using LinearAlgebra

julia> B = Bidiagonal([1.0, 2.0, 3.0], [0.0, 1.0], :L); E = eigen(B);

julia> E.values
3-element Vector{Float64}:
 1.0
 2.0
 3.0

julia> any(isnan, E.vectors), any(isnan, eigen(Matrix(B)).vectors)
(true, false)

julia> eigen(Bidiagonal([1, 2], [1], :U))
ERROR: InexactError: ...
```

Mechanism: the `:L` branch of `eigvecs(::Bidiagonal)` uses the loop bounds of the `:U` branch, so the
back-substitution reads outside the valid range and produces `NaN`; the integer `:U` case allocates the
eigenvector matrix in the input integer type and fails with `InexactError` when a non-integer
component is stored. Related symptoms seen on the same path: `eigen` of a `Bidiagonal{Complex{Rational}}`
identity with `:L` raises `DivideError`, and an `Eigen{Rational{BigInt}}` whose "exact" vectors do not
satisfy `A*V == V*Λ`.

Versions checked: reproduced on LinearAlgebra with Julia 1.10.11, 1.11.9, 1.12.6 and 1.13.3
(long-standing).

Deduplication searches (2026-11-17): in this catalogue, `eigen Bidiagonal` and `eigvecs` match
nothing. Upstream, `eigen Bidiagonal NaN eigenvectors`, `eigvecs Bidiagonal` and
`Bidiagonal eigen InexactError` surface only unrelated items (#1809 LAPACK Inf/NaN script, #17 the
original eigensolver implementation, #310 size checks).

Found by a differential factorization-contract probe (`eigen` of structured vs dense, exact and
float). Reproducer: `n3_eigen_bidiagonal_lower_nan_eigenvectors.jl` (prints `REPRODUCED`).

Assisted-by: AI

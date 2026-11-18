# 90: `isposdef` of a `Symmetric`/`Hermitian` matrix containing `NaN` returns `true` (LAPACK `potrf` does not flag a `NaN` pivot), where the dense, `Diagonal` and generic paths return `false`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

```julia-repl
julia> using LinearAlgebra

julia> isposdef(Hermitian([NaN;;]))
true

julia> isposdef([NaN;;]), isposdef(Diagonal([NaN]))
(false, false)

julia> isposdef(Symmetric([1.0 0.0; 0.0 NaN]))
true

julia> isposdef(Hermitian([1.0 NaN; NaN 4.0]))     # also Float32, ComplexF64, Hermitian(sparse)
true

julia> isposdef(Hermitian(BigFloat[NaN;;]))       # the generic path detects it
false

julia> cholesky(Hermitian([NaN;;])).U              # check=true, no exception either
1×1 UpperTriangular{Float64, Matrix{Float64}}:
 NaN
```

Mechanism: `isposdef(A::Hermitian)` is `isposdef(cholesky(A; check=false))`, i.e. `C.info == 0`. For
BLAS element types the factorization is LAPACK `potrf`, whose pivot test (`ajj <= 0`) is false for
`NaN`, so `info` stays `0` and the factor silently contains `NaN`. The generic `_chol!(::AbstractMatrix)`
(`src/cholesky.jl`) returns `info != 0` for a `NaN` pivot, hence the `BigFloat` answer; `Diagonal` and
the plain `Matrix` path answer `false`. The result is inconsistent across element types and wrappers,
and `isposdef` — a predicate often used to decide whether a factorization is safe — answers `true` for
a matrix that is not positive definite.

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.834
(LinearAlgebra 1.14.0) — long-standing.

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `isposdef NaN`,
`cholesky NaN`, `NaN positive`, `potrf`; `JuliaLang/julia` for `isposdef nan`, `cholesky nan info`,
`potrf nan`, `PosDefException NaN` — nothing; #1081 and #1802 (NaN propagation in `det`/`logdet`) do not
mention `isposdef` or `cholesky`. This catalogue: entry 23 is the empty-banded `BoundsError` (#1874),
unrelated.

Found by a metamorphic predicate-agreement probe (`isposdef(W)` vs `isposdef(Matrix(W))`). Reproducer:
`isposdef_hermitian_nan_true.jl` (prints `REPRODUCED`).

Assisted-by: AI

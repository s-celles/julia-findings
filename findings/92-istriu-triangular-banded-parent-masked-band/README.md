# 92: `istriu`/`istril` of an `UpperTriangular`/`LowerTriangular` wrapping a banded matrix examine the band the wrapper masks (`istriu(UpperTriangular(Tridiagonal([1],[0,0],[0])), 1)` is `false` on an all-zero matrix) — regression in LinearAlgebra 1.12

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1924](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1924))

# Body

```julia-repl
julia> using LinearAlgebra

julia> U = UpperTriangular(Tridiagonal([1], [0, 0], [0])); Matrix(U)   # the sub-diagonal 1 is masked
2×2 Matrix{Int64}:
 0  0
 0  0

julia> istriu(Matrix(U), 1)
true

julia> istriu(U, 1)                                      # reads the masked sub-diagonal
false

julia> istriu(UpperTriangular(Bidiagonal([0, 0], [1], :L)), 1)
false

julia> istril(LowerTriangular(Tridiagonal([0], [0, 0], [1])), -1)
false

julia> istriu(UpperTriangular(Matrix(Tridiagonal([1], [0, 0], [0]))), 1)   # Matrix parent: fine
true
```

Mechanism (`src/triangular.jl`, `istriu(A::UpperTriangular, k)` and the `istril` counterpart): for an
offset beyond the diagonal the predicate is forwarded to the parent (`istriu(parent(U), k)`), a
delegation introduced by JuliaLang/LinearAlgebra.jl#1265 ("`istril`/`istriu` for opposite
triangularity"). With a `Tridiagonal`/`Bidiagonal` parent the banded predicate then inspects the
parent's own sub-diagonal, which the triangular wrapper never exposes.

Versions checked: correct on Julia 1.10.11 and 1.11.9; wrong on 1.12.6, 1.13.3 and nightly
1.15.0-DEV.834 (LinearAlgebra 1.14.0) — a regression in LinearAlgebra 1.12, consistent with #1265
(merged 2025-04-06).

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `istriu
UpperTriangular Tridiagonal`, `istriu banded parent`, `istriu UpperTriangular Tridiagonal parent` — only
#200 and #610 (closed, 2017/2019, unrelated block-diagonal predicates) and PR #1265 (the cause).

Found by a metamorphic predicate-agreement probe. Reproducer:
`istriu_triangular_banded_parent_masked_band.jl` (prints `REPRODUCED`).

Assisted-by: AI

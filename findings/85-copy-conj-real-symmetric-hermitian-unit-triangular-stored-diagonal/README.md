# 85: `copy`, `conj` and `real` of a `Symmetric`/`Hermitian` wrapping a unit-triangular matrix use the parent's stored diagonal — wrong values, and an uninitialized diagonal for `copy` (regression since LinearAlgebra 1.11)

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

A `UnitLowerTriangular`/`UnitUpperTriangular` ignores the diagonal stored in its parent. Wrapping one
in a `Symmetric` or `Hermitian` and applying `conj`, `real` or `copy` returns a matrix built from that
ignored stored diagonal instead of the unit diagonal:

```julia-repl
julia> using LinearAlgebra

julia> U = UnitLowerTriangular([5 0; 2 7]); H = Hermitian(U, :L); Matrix(H)   # unit diagonal
2×2 Matrix{Int64}:
 1  2
 2  1

julia> conj(H)                      # the stored 5 and 7 reappear
2×2 Hermitian{Int64, Matrix{Int64}}:
 5  2
 2  7

julia> H == conj(H)
false

julia> copy(H)                      # diagonal read from an UNINITIALIZED buffer (varies run to run)
2×2 Hermitian{Int64, Matrix{Int64}}:
 136772461941936  2
               2  57

julia> real(Hermitian(UnitLowerTriangular(Diagonal(ComplexF64[-0.5, 0.5])), :L))   # expected I
2×2 Hermitian{Float64, Matrix{Float64}}:
 -0.5  0.0
  0.0  0.5
```

The same happens for `Symmetric`, for `copy(H')`/`copy(transpose(H))`, and for a `copy` of a
`Symmetric(UnitUpperTriangular(...))` with `Float64` elements (`copy(S) == S` is `false`).

Mechanism (`src/symmetric.jl`): `copy`, `real`, `imag` and `conj` of a `HermOrSym` are implemented as
`Symmetric(parentof_applytri(f, A), …)` with `parentof_applytri(f, args...) = applytri(_parent_tri∘f,
args...)`: `f` is applied to the `UnitLowerTriangular`, and `_parent_tri` then strips the unit wrapper
and exposes the raw parent, whose diagonal the wrapper never meant to expose. For `conj`/`real` that
diagonal is the arbitrary stored value; for `copy` it is uninitialized, because since
JuliaLang/LinearAlgebra.jl#1350 ("Fix copy for partly initialized unit triangular") the unit-triangular
`_copy!` deliberately skips the diagonal (`src/triangular.jl`), so the copied parent's diagonal is
never written.

Versions checked: correct on Julia 1.10.11; wrong on 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.834
(LinearAlgebra 1.14.0), and on the current LinearAlgebra.jl master loaded into the nightly — a
regression since LinearAlgebra 1.11.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `copy Hermitian
unit triangular`, `copytrito unit triangular`, `copy Symmetric uninitialized`, `Hermitian
UnitLowerTriangular`, `Symmetric UnitUpperTriangular copy`, `parentof_applytri` (only #1243,
type stability), `conj Hermitian unit triangular`, `conj Symmetric UnitLowerTriangular`, `real
Hermitian UnitLowerTriangular`, `applytri unit`; this catalogue `copy Symmetric`, `Hermitian`. No match.

Found by a differential probe of nested wrappers against the dense oracle. Reproducer:
`copy_conj_real_symmetric_unit_triangular.jl` (prints `REPRODUCED`).

Assisted-by: AI

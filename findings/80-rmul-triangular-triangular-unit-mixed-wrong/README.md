# 80: `rmul!(C, A)` with two triangular matrices returns silently wrong values for unit-triangular and mixed combinations (the destination is used as the left factor while being overwritten)

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

In-place right multiplication of one triangular matrix by another gives a wrong result, without any
error, whenever a unit-triangular type or a mixed lower/upper pair is involved:

```julia-repl
julia> using LinearAlgebra

julia> C = UnitUpperTriangular([1 2 3; 0 1 4; 0 0 1]); A = UpperTriangular([1 -1 2; 0 1 5; 0 0 1]);

julia> Matrix(C) * Matrix(A)
3×3 Matrix{Int64}:
 1  1  15
 0  1   9
 0  0   1

julia> rmul!(C, A)                        # wrong: (1,3) is 10 instead of 15
3×3 UnitUpperTriangular{Int64, Matrix{Int64}}:
 1  1  10
 ⋅  1   9
 ⋅  ⋅   1

julia> C = UnitUpperTriangular(Float64[1 2 3; 0 1 4; 0 0 1]); A = UnitUpperTriangular(Float64[1 -1 2; 0 1 5; 0 0 1]);

julia> rmul!(C, A)                        # wrong: should be [1 1 15; 0 1 9; 0 0 1]
3×3 UnitUpperTriangular{Float64, Matrix{Float64}}:
 1.0  -2.0  -1.0
  ⋅    1.0  10.0
  ⋅     ⋅    1.0

julia> L = LowerTriangular([0 0 0; -2 2 0; 0 -2 0]); U = UnitUpperTriangular(Int8[1 2 -1; 0 1 1; 0 0 1]);

julia> rmul!(L, U)                        # true product is not triangular; lmul! would throw, rmul! returns garbage
3×3 LowerTriangular{Int64, Matrix{Int64}}:
  0   ⋅   ⋅
 -2  -2   ⋅
  0  -2  -2
```

`lmul!` is correct in every case, and `rmul!(::UpperTriangular, ::UpperTriangular)` /
`rmul!(::LowerTriangular, ::LowerTriangular)` are correct. An exhaustive enumeration at n = 4 (Int and
Float64, plain and `transpose`d second factor) gives the wrong result for `rmul!(UnitUpper, UnitUpper)`,
`rmul!(UnitLower, UnitLower)` (Float64), `rmul!(Lower, Upper)`, `rmul!(UnitUpper, transpose(UnitLower))`,
`rmul!(Lower, transpose(Lower))` and `rmul!(UnitLower, transpose(UnitUpper))`.

Mechanism (`src/triangular.jl`): `rmul!(A::AbstractMatrix, B::UpperOrLowerTriangular) = _trimul!(A, A, B)`.
When `A` is itself triangular this reaches either `_trimul!(C, A::UpperOrLowerTriangular,
B::UpperOrLowerTriangular)`, which uses the first argument — the destination being overwritten — as the
left triangular factor (`generic_trimatmul!(C, uplo(A), …, A.data, B)`, whose loops are alias-safe only
for `C === B`, not `C === A`), or the "preserve triangular structure" methods that call
`_trimul!(parent(C), A, B)`; for BLAS floats this becomes `trmm!(…, A.data, copy!(C, B))` with
`C === A.data`, so `A` is overwritten by `B` before the product is formed. The four overloads
`rmul!(A::UpperTriangular, B::UpperTriangular) = UpperTriangular(rmul!(triu!(A.data), B))` etc. added by
JuliaLang/julia#47107 ("we don't keep track of left- and right-multiplication in tritrimul!") fix exactly
this, but were never written for the `Unit*` wrappers nor for mixed lower/upper structures. The open
JuliaLang/LinearAlgebra.jl#1854 adds `check_inplace_aliasing` only when the two *arguments* share memory;
here they do not, so it would not catch this.

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.833
(LinearAlgebra 1.14.0) — long-standing and still present on master.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `rmul!
UnitUpperTriangular`, `rmul! triangular wrong result`, `unit triangular in-place multiplication`, `rmul!
LowerTriangular UpperTriangular`, `in-place triangular product aliasing wrong`, `_trimul! in-place`,
`tritrimul`; `JuliaLang/julia` `rmul! UnitUpperTriangular`; this catalogue (`rmul!`, `trimul`). Nearest
but distinct: #1600 (closed, `rmul!(UnitUpper, Diagonal)`), #636 (closed, performance), PR #1854 (open,
shared-memory arguments only).

Found by a differential probe of in-place multiply kernels against the dense product. Reproducer:
`rmul_triangular_unit_mixed_wrong.jl` (prints `REPRODUCED`).

Assisted-by: AI

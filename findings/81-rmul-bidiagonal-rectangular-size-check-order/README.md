# 81: `rmul!(B::AbstractMatrix, A::Bidiagonal)` throws `DimensionMismatch` for a valid rectangular `B` (the size check has its arguments reversed)

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1908](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1908)); fix proposed by a maintainer in [JuliaLang/LinearAlgebra.jl#1912](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1912) (open, 2026-11-18)

# Body

`rmul!(B, A)` computes `B .= B * A`, but with a `Bidiagonal` `A` it rejects any non-square `B` even
though the product is well defined:

```julia-repl
julia> using LinearAlgebra

julia> A = Bidiagonal([1.0, 2, 3, 4], [1.0, 1, 1], :U); C = ones(3, 4);

julia> size(C * A)
(3, 4)

julia> rmul!(C, A)
ERROR: DimensionMismatch: tried to multiply a matrix of size (4, 4) with a matrix of size (3, 4)

julia> rmul!(ones(3, 4), Diagonal([1.0, 2, 3, 4])) |> size      # Diagonal: fine
(3, 4)

julia> lmul!(A, ones(4, 3)) |> size                             # lmul!: fine
(4, 3)
```

The same happens for every element type, for `:U` and `:L`, and for `Adjoint`/`Transpose` of a
`Bidiagonal`.

Mechanism (`src/bidiag.jl`): `rmul!(B::AbstractMatrix, A::Bidiagonal)` calls
`matmul_size_check(size(A), size(B))`, i.e. it validates the shape of `A * B` while the method computes
`B * A` (the comment on the method says `B .= B * A`). The neighbouring `rmul!(B::Bidiagonal, D::Diagonal)`
passes the sizes in the right order. The reversed check has been there since the method was introduced
(JuliaLang/julia#55052, 2024-07, then `_muldiag_size_check`), and PR #1152 and the open #1854 touch the
function without changing the order.

Versions checked: reproduced on Julia 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.833 (LinearAlgebra
1.14.0). On Julia 1.10.11 the `rmul!(::AbstractMatrix, ::Bidiagonal)` method does not exist
(`MethodError`), so the reversed check has been there since the method was introduced in LinearAlgebra
1.11; the current `matmul_size_check(size(A), size(B))` line (`src/bidiag.jl:539`) comes from
JuliaLang/LinearAlgebra.jl#1152, which kept the order.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `rmul! Bidiagonal`,
`matmul_size_check`, `rmul! DimensionMismatch`, `Bidiagonal DimensionMismatch`; `JuliaLang/julia`
`rmul! Bidiagonal`. No match.

Found by a differential probe of in-place multiply kernels (`rmul!` vs `*`). Reproducer:
`rmul_bidiagonal_rectangular_dimensionmismatch.jl` (prints `REPRODUCED`).

Assisted-by: AI

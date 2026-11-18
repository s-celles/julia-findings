# 93: the `isdiag` fast path of the dense matrix functions writes into `similar(A)` and throws for a `UnitUpperTriangular`, a complex `Symmetric` or a `SymTridiagonal` (`sin(UnitUpperTriangular([1.0 0; 0 1]))` throws `ArgumentError`) — regression in LinearAlgebra 1.12

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: to post

# Body

```julia-repl
julia> using LinearAlgebra

julia> U = UnitUpperTriangular([1.0 0; 0 1]);

julia> sin(Matrix(U))
2×2 Matrix{Float64}:
 0.841471  0.0
 0.0       0.841471

julia> sin(U)
ERROR: ArgumentError: cannot set index (1, 1) on the diagonal of a UnitUpperTriangular matrix to a non-unit value (0.8414709848078965)

julia> sin(UnitUpperTriangular([1.0 1; 0 1]))          # non-zero strict part: the Schur path, fine
2×2 Matrix{Float64}:
 0.841471  0.540302
 0.0       0.841471

julia> S = Symmetric([1.0+0im 0; 0 2]);              # complex Symmetric: not the Hermitian dispatch

julia> sin(S)
ERROR: ArgumentError: Cannot set a non-diagonal index in a symmetric matrix

julia> SymTridiagonal([1.0+0im, 2], [0.0+0im])^(1/3)
ERROR: ArgumentError: cannot set off-diagonal entry (1, 2) to a nonzero value (0.0 + 0.0im)
```

The same happens for `cos`, `tan`, `acosh`, … of the unit-triangular matrix and for `log`, `sqrt`,
`^0.5`, … of the complex `Symmetric`; `Hermitian` is unaffected (own eigen-based methods).

Mechanism (`src/dense.jl`):

```julia
function applydiagonal(f, A)
    dinv = f(Diagonal(A))
    copyto!(similar(A, eltype(dinv)), dinv)
end
```

Every dense matrix function (`sin`, `cos`, `tan`, `sinh`, `cosh`, `tanh`, `asin`, `acos`, `atan`,
`asinh`, `acosh`, `atanh`, `log`, `sqrt`, `cbrt`, `^`, `inv`) starts with `isdiag(A) &&
return applydiagonal(f, A)`. `similar(A, T)` keeps the wrapper: for a `UnitUpperTriangular`/
`UnitLowerTriangular` the diagonal cannot be assigned, for a `Symmetric` (complex, so outside the
`RealHermSymComplexHerm` dispatch) `setindex!` refuses every off-diagonal index, even for a zero, and a
`SymTridiagonal` refuses the off-diagonal zeros as well. The pre-1.12 code went through the Schur
decomposition and returned a `Matrix` for these inputs. Introduced by JuliaLang/julia#56483 ("Check
`isdiag` in dense trig functions", LinearAlgebra 1.12).

Versions checked: correct on Julia 1.10.13 and 1.11.9; wrong on 1.12.7, 1.13.3 and nightly
1.15.0-DEV.834 (LinearAlgebra 1.14.0). On nightly, `Symmetric([1.0+0im 0; 0 2])^(1/3)` fails the same
way (fine on 1.13.3: it now reaches the `AbstractMatrix` method after the conversion added by #1800).

A possible fix: allocate the destination with the `dims` form, `similar(A, eltype(dinv), size(A))`,
which falls back to an `Array` for every wrapper, as the Schur path does; this would, however, change
the (post-1.12) `UpperTriangular{Float64}` return type of `sin(UpperTriangular([1.0 0; 0 2]))` back to
a `Matrix`, so the choice of container is left to the maintainers.

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `applydiagonal`,
`UnitUpperTriangular sin`, `cannot set index on the diagonal`, `Cannot set a non-diagonal index` —
only #772/#773/#646 (closed, broadcast-related) and PR #1224 (unrelated); `JuliaLang/julia` for
`applydiagonal` — only the originating PR #56483.

Found by a structured-versus-dense differential probe over the matrix functions. Reproducer:
`applydiagonal_similar_wrapper_throws.jl` (prints `REPRODUCED`).

Assisted-by: AI

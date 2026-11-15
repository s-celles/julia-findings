# 65: Comment on JuliaLang/LinearAlgebra.jl#1871: `det` of a `Symmetric`/`Hermitian` matrix with `Rational` elements returns an inexact `Float64`

- Kind: comment for `JuliaLang/LinearAlgebra.jl#1871`
- Status: the referenced fix (JuliaLang/LinearAlgebra.jl#1871 closed by [PR #1882](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1882), 2026-11-15) resolves the TYPE inconsistency by making the Hermitian/Symmetric factorization always FLOAT — but this is a regression for exact rational linear algebra: `Symmetric{Rational}` solves, `inv` and `det` now return `Float` instead of the exact `Rational` they returned before (e.g. `Symmetric(Rational{Int}[2 1; 1 2]) \ [1,1]` was `[1//3, 1//3]`, becomes `[0.333…37, 0.333…33]`). See `regression_1882_symmetric_rational_exactness.jl`. The exact-arithmetic use case is broken rather than fixed; a fallback keeping exact `lu` for non-float eltypes would preserve it.

# Body

The `Rational` case of the same path loses exactness instead of changing
width: `det` on a symmetric wrapper with `Rational{Int64}` elements goes
through the Bunch-Kaufman factorization in floating point and returns a
`Float64`, while `inv`, `\` on the same wrapper and `det` on the dense matrix
stay exact:

```julia-repl
julia> using LinearAlgebra

julia> S = Symmetric(Rational{Int64}[1 2; 2 3]);

julia> det(S), det(Matrix(S))
(-1.0, -1//1)

julia> eltype(inv(S)), eltype(S \ Rational{Int64}[1, 2])
(Rational{Int64}, Rational{Int64})

julia> B = Symmetric(Rational{Int64}[1 1//3; 1//3 1//10^9]);

julia> det(B), det(Matrix(B))
(-0.1111111101111111, -999999991//9000000000)
```

The same holds for `Hermitian`, on LinearAlgebra 1.13.0 (Julia 1.13.3) and
1.14.0 (nightly 1.15.0-DEV.720). Using the generic `lu`-based determinant
(as the dense path does) when the element type is not a floating-point
type would keep the result exact, consistently with the integer case
discussed here.

Found by a probe comparing solves and determinants between pairs of
structured matrix kinds with exact element types against the dense
`Rational{BigInt}` computation (`experiments/phase4/structured_solve_contracts.jl`).
Reproducer: `det_symmetric_rational_float.jl` (prints REPRODUCED when the
determinant is not a `Rational`).

Assisted-by: AI

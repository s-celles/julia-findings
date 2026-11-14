# 60: `det` of `Tridiagonal` and `SymTridiagonal` matrices with narrow integer elements returns a value that is neither exact nor wrapped

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

For `Int8` (and other narrow integer) elements, `det(::Tridiagonal)` and
`det(::SymTridiagonal)` return a silently wrong integer. The three-term
recurrence multiplies pairs of elements in the element type, where the
products wrap, and accumulates the results in `Int`, so the final value is
neither the exact determinant nor the exact value wrapped in `Int8`:

```julia-repl
julia> using LinearAlgebra

julia> A = Int8[-14 1 14 6; 1 -6 -1 7; 14 -1 4 -14; 6 7 -14 4];

julia> T = Tridiagonal(diag(A, -1), diag(A), diag(A, 1));

julia> det(T), det(Matrix(T))
(6364, -14884.0)                  # exact: -14884

julia> S = SymTridiagonal(Int8[100, 100, 100], Int8[50, 50]);

julia> det(S), det(Matrix(S))
(32, 499999.99999999994)          # exact: 500000

julia> det(Diagonal(Int8[100, 100]))
10000                             # exact, widened to Int
```

The dense `Matrix{Int8}` path returns the exact value as a `Float64`, and
`Diagonal{Int8}` returns the exact `Int`; the `Int16` and `Int64`
tridiagonal cases are exact here. Same on Julia 1.13.3 and nightly
1.15.0-DEV.720 (LinearAlgebra 1.13.0 and the bundled nightly version).
Promoting the elements to `Int` (or to the dense path's float type) before
the recurrence, as `Diagonal` effectively does, would make the structured and
dense determinants agree.

Related: JuliaLang/LinearAlgebra.jl#824 (integer determinants are computed in
floating point by design) and JuliaLang/LinearAlgebra.jl#1867 (`tr` wrapping
depending on storage).

Found by a probe comparing `Rational{Int}` and integer matrices against the
exact `Rational{BigInt}` computation
(`experiments/phase4/linalg_exact_contracts.jl`). Reproducer:
`det_tridiagonal_narrow_int.jl` (prints REPRODUCED when a structured
determinant differs from the exact value).

Assisted-by: AI

# 70: `\` on a sparse matrix with `Rational` elements returns Float64 results converted to `Rational` (silently inexact) or throws `InexactError`

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: posted ([JuliaSparse/SparseArrays.jl#1179](https://github.com/JuliaSparse/SparseArrays.jl/issues/1179)); on nightly 1.15.0-DEV.833 the sparse `\` is exact again (fixed on master, issue still open as of 2026-11-18)

# Body

For a square sparse matrix with `Rational{Int64}` elements that is neither
triangular nor symmetric, `\` factorizes in `Float64` (UMFPACK) and converts
the solution back to the element type, so the result has the exact type but
float-derived values:

```julia-repl
julia> using LinearAlgebra, SparseArrays

julia> S = sparse(Rational{Int64}[2 1 0; 0 3 1; 1 0 4]); b = Rational{Int64}[1, 2, 3];

julia> S \ b
3-element Vector{Rational{Int64}}:
 1261007895663739//4503599627370496
  990791918021509//2251799813685248
 1531223873305969//2251799813685248

julia> Matrix(S) \ b
3-element Vector{Rational{Int64}}:
  7//25
 11//25
 17//25

julia> sparse(Rational{Int64}[1 1 0; 0 1 1; 1 0 10^9]) \ Rational{Int64}[1, 1, 1]
3-element Vector{Rational{Int64}}:
          9007199//9007199254740992
 9007199245733793//9007199254740992
          9007199//9007199254740992
```

and when a floating-point entry has no `Rational{Int64}` representation the
conversion throws (`InexactError: Rational(-4.04e-17)` for a 4x4 matrix
divided by itself). The symmetric sparse case takes the Bunch-Kaufman branch
and is exact, the dense solve is exact, and `lu(S)` honestly returns an
`UmfpackLU{Float64}`; it is the `Rational`-typed result of `\` that hides the
conversion. Returning the `Float64` solution (as `Matrix{Int} \ b` does for
integers), or using the dense exact path for exact element types, would be
consistent. Same on SparseArrays 1.13.0 (Julia 1.13.3) and 1.14.0 (nightly
1.15.0-DEV.720); JuliaSparse/SparseArrays.jl#921 discussed the integer case
of the same dispatch.

Found while scanning SparseArrays operations on non-BLAS element types for
the catalogue's probes. Reproducer: `sparse_rational_solve_inexact.jl`
(prints REPRODUCED when the sparse solution differs from the dense one).

Assisted-by: AI

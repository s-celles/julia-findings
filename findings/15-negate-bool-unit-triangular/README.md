# 15: Negating a Boolean unit triangular matrix throws `InexactError`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1868](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1868))

# Title

Negating a Boolean unit triangular matrix throws `InexactError`

# Body

```julia-repl
julia> using LinearAlgebra

julia> A = UnitUpperTriangular(Bool[1 1; 0 1]);

julia> -A
ERROR: InexactError: Bool(-1)

julia> -Matrix(A)
2×2 Matrix{Int64}:
 -1  -1
  0  -1
```

The methods for `-(::UnitUpperTriangular)` and
`-(::UnitLowerTriangular)` allocate `Anew = similar(A.data)`, preserving
`Bool`, and then store negated entries including the implicit unit diagonal.
In contrast, unary negation of a Boolean dense matrix promotes to `Int`, as do
the non-unit triangular wrappers.

Both upper and lower variants reproduce on Julia 1.13.3 / LinearAlgebra
1.13.0 and official nightly Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0. The
same implementation remains in the current source checked during triage.
Searches for `UnitUpperTriangular Bool`, `triangular negation`, `Bool
InexactError`, and `UnitUpperTriangular negation` found no matching issue or
PR.

Assisted-by: AI

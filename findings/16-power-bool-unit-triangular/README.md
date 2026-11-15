# 16: Integer powers of Boolean unit triangular matrices fail during conversion

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: fixed upstream — JuliaLang/LinearAlgebra.jl#1869 closed by [PR #1881](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1881) (2026-11-15)

# Title

Integer powers of Boolean unit triangular matrices fail during conversion

# Body

```julia-repl
julia> using LinearAlgebra

julia> A = UnitUpperTriangular(Bool[1 1; 0 1]);

julia> A * A
2×2 UnitUpperTriangular{Int64, Matrix{Int64}}:
 1  2
 ⋅  1

julia> A^2
ERROR: MethodError: Cannot `convert` an object of type
  UnitUpperTriangular{Bool, Matrix{Bool}} to an object of type
  UnitUpperTriangular{Int64, Matrix{Int64}}

julia> Matrix(A)^2
2×2 Matrix{Int64}:
 1  2
 0  1
```

`power_by_squaring` first computes `A*A`, whose element type is correctly
promoted to `Int64`, then tries to convert the original Boolean wrapper to the
concrete type of that product. There is no conversion from
`UnitUpperTriangular{Bool, Matrix{Bool}}` to the concrete promoted wrapper.
The same failure affects `UnitLowerTriangular` and, unexpectedly, exponents 0
and 1 as well as 2 and larger.

The sweep found upper and lower variants for `A^2`; a minimized follow-up
checked exponents 0 through 5. The behavior reproduces on Julia 1.13.3 /
LinearAlgebra 1.13.0 and official nightly Julia 1.15.0-DEV.688 /
LinearAlgebra 1.14.0. Searches for `UnitUpperTriangular power_by_squaring`,
`UnitUpperTriangular power`, `Bool power`, and `triangular Bool` found no
matching issue or PR.

Assisted-by: AI

# 22: Unit triangular integer `\` returns the integer element type and throws `InexactError` on overflow

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

Unit triangular integer `\` returns the integer element type and throws `InexactError` on overflow

# Body

```julia-repl
julia> using LinearAlgebra

julia> U = UnitLowerTriangular(Int8[1 0; -128 1]); b = Int8[1, 0];

julia> Matrix(U) \ b
2-element Vector{Float64}:
   1.0
 128.0

julia> U \ b
ERROR: InexactError: Int8(128.0)

julia> UnitUpperTriangular(Int8[1 1; 0 1]) \ Int8[0, 1]
2-element Vector{Int8}:
 -1
  1
```

`\(::Union{UnitLowerTriangular, UnitUpperTriangular}, ::AbstractVector)`
picks the result element type with `_inner_type_promotion(\, Int8, Int8)`,
which for two integer types is `promote_op(matprod, Int8, Int8) == Int8`
(there is no division by the unit diagonal), and allocates the result with it.
The generic `generic_trimatdiv!` kernel then computes
`oneunit(T) \ B[i] - _ustrip(A[i, m]) * Cm`, where `Int8(1) \ Int8(-128)` is
the `Float64` `-128.0`; storing the floating-point result back into the `Int8`
array fails as soon as a value leaves the `Int8` range. Non-unit triangular
matrices and the dense path return `Float64`. The same applies to
`UnitUpperTriangular`, to `UInt8` (`InexactError: UInt8(-1.0)`), and to the
`\` and `/` methods with two unit triangular arguments, which return
`UnitUpperTriangular{Int8}`.

Returning `Float64` like `lu` would avoid both the type difference and the
overflow error.

Reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 /
LinearAlgebra 1.14.0. Searches for `UnitLowerTriangular integer` and
`triangular solve integer overflow` found no matching issue or PR (2026-11-13).

Assisted-by: AI

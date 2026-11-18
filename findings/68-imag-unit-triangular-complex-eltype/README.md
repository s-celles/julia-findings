# 68: `imag` of a `UnitLowerTriangular`/`UnitUpperTriangular` matrix with complex elements keeps a complex element type

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1897](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1897))

# Body

`imag` of every structured wrapper and of a dense matrix returns a matrix
with the real element type, except the unit triangular wrappers:

```julia-repl
julia> using LinearAlgebra

julia> A = Complex{Rational{Int64}}[1 0; -3+1im 1];

julia> eltype(imag(UnitLowerTriangular(A))), eltype(imag(LowerTriangular(A))), eltype(imag(A))
(Complex{Rational{Int64}}, Rational{Int64}, Rational{Int64})

julia> imag(UnitLowerTriangular(ComplexF64.(A)))
2×2 LowerTriangular{ComplexF64, Matrix{ComplexF64}}:
 0.0+0.0im      ⋅
 1.0+0.0im  0.0+0.0im
```

The values are right (zero imaginary parts), but the result is complex where
the user expects a real matrix, so for example `imag(U) isa AbstractMatrix{<:Real}`
is `false` and downstream code that stores or compares real parts gets a
complex array. `real` of the same wrappers returns the real element type (as a
`UnitLowerTriangular` wrapping a `LowerTriangular`, which works but is an
unusual nesting). Same on LinearAlgebra 1.13.0 (Julia 1.13.3) and 1.14.0
(nightly 1.15.0-DEV.720).

Found by a probe of structured matrix kinds with complex exact element types
(`experiments/phase4/complex_structured_contracts.jl`), which checks the
element type of every result against the dense path. Reproducer:
`imag_unit_triangular_complex_eltype.jl` (prints REPRODUCED when `imag`
keeps a complex element type).

Assisted-by: AI

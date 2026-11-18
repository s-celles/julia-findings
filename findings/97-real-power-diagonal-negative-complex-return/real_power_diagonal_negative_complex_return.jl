# A^p for a real diagonal dense matrix with a negative entry and an integer-valued Float exponent
# returns a ComplexF64 matrix (with zero imaginary parts), whereas the non-diagonal matrix, the
# Diagonal wrapper and Julia 1.12 return Float64. The isdiag fast path of ^(A::AbstractMatrix, p::Real)
# promotes negative entries to complex (LinearAlgebra.jl#1360) without the "return real(retmat) when
# the result is real" convention that the general path applies. Prints REPRODUCED.
using LinearAlgebra
A = [-1.0 0; 0 2]
@assert A^2 == [1.0 0; 0 4] && eltype(A^2) == Float64              # integer exponent: Float64
@assert eltype([-1.0 1; 0 2]^2.0) == Float64                       # non-diagonal: Float64
@assert eltype(Diagonal([-1.0, 2])^2.0) == Float64                 # Diagonal wrapper: Float64
@assert eltype(Symmetric(A)^2.0) == Float64                        # Symmetric wrapper: Float64
R = A^2.0
@assert R == [1.0 0; 0 4]                                          # values are right
@assert eltype(R) == ComplexF64                                    # WRONG: ComplexF64 (Julia 1.12: Float64)
@assert eltype(A^3.0) == ComplexF64 && eltype(A^-1.0) == ComplexF64
@assert eltype(A^0.5) <: Complex                                   # genuinely complex: fine
println("[-1.0 0; 0 2]^2.0 is a Matrix{ComplexF64}; [-1.0 1; 0 2]^2.0 and Diagonal([-1.0, 2])^2.0 are Float64")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

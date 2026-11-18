# Matrix(F) / AbstractMatrix(F::BunchKaufman) reconstructs a complex SYMMETRIC matrix wrongly:
# the accessor conjugates (adjoint) where a complex-symmetric factorization needs transpose, so
# Matrix(bunchkaufman(Symmetric(A))) != A. The factorization itself is sound (F \ b, inv(F), det(F)
# are correct); only the reconstruction is wrong. Hermitian input reconstructs correctly (control).
# Related: JuliaLang/LinearAlgebra.jl#903 (adjoint of a complex-symmetric BunchKaufman threw).
# Prints REPRODUCED.
using LinearAlgebra
A = Symmetric([1 im; im 2])
F = bunchkaufman(A)
R = Matrix(F)
@assert R != Matrix(A)                                        # reconstruction WRONG
@assert isapprox(ComplexF64.(F \ [1, 1]), Matrix(A) \ [1, 1]) # solve correct
@assert isapprox(ComplexF64(det(F)), det(Matrix(A)))          # det correct
H = Hermitian([1 im; -im 2]); @assert Matrix(bunchkaufman(H)) == Matrix(H)  # control OK
println("A = ", Matrix(A), "   Matrix(bunchkaufman(A)) = ", R)
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

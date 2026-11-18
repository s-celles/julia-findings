# Right division by a singular UpperTriangular with a BLAS element type returns NaN/Inf silently:
# B / U goes through the BlasFloat generic_mattridiv! path, which calls BLAS.trsm! without checking
# the triangular diagonal, whereas U \ b (trtrs!/generic path), the generic Rational path and the
# dense path all raise SingularException (LAPACKException on Julia 1.10). Related: JuliaLang/LinearAlgebra.jl#1665 (generic path and
# check=false). Prints REPRODUCED.
using LinearAlgebra
U = UpperTriangular([1.0 2.0; 0.0 0.0]); B = [1.0 2.0]      # U singular (zero diagonal)
x = B / U
@assert any(v -> isnan(v) || isinf(v), x)                                  # silent NaN/Inf
@assert (try U \ [1.0, 2.0]; false catch err; err isa Union{LinearAlgebra.SingularException, LinearAlgebra.LAPACKException} end)   # ldiv raises (LAPACKException on 1.10)
@assert (try B / Matrix(U); false catch err; err isa Union{LinearAlgebra.SingularException, LinearAlgebra.LAPACKException} end)     # dense raises
Ur = UpperTriangular(Rational{Int}[1 2; 0 0])
@assert (try Rational{Int}[1 2] / Ur; false catch err; err isa LinearAlgebra.SingularException end)  # generic raises
println("B / U = ", x, "   (U \\ b, dense, Rational all raise SingularException)")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

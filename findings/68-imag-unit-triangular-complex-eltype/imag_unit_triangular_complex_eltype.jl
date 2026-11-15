# imag of a UnitLowerTriangular or UnitUpperTriangular matrix with complex elements returns a
# LowerTriangular/UpperTriangular matrix whose element type is still Complex (values have zero
# imaginary parts), while imag of every other wrapper and of the dense matrix returns the real
# element type. real of the unit wrappers is fine but nests a unit wrapper around a triangular one.
# Prints REPRODUCED when imag keeps a complex element type.
using LinearAlgebra
A = Complex{Rational{Int64}}[1 0; -3+1im 1]
for (name, W) in (("UnitLowerTriangular", UnitLowerTriangular(A)), ("UnitUpperTriangular", UnitUpperTriangular(permutedims(A))), ("LowerTriangular", LowerTriangular(A)), ("Diagonal", Diagonal(A)), ("Matrix", A))
    println(rpad(name, 20), " eltype(imag) = ", rpad(string(eltype(imag(W))), 26), " eltype(real) = ", eltype(real(W)))
end
bad = eltype(imag(UnitLowerTriangular(A))) <: Complex || eltype(imag(UnitLowerTriangular(ComplexF64.(A)))) <: Complex
println(bad ? "REPRODUCED on " : "AGREE on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

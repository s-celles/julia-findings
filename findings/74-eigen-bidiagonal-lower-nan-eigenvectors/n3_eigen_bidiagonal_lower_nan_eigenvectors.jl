# eigen of a lower Bidiagonal (:L) returns NaN eigenvectors while the eigenvalues are correct and the
# dense path is fine; the :L branch of eigvecs(::Bidiagonal) uses wrong loop bounds. An integer upper
# Bidiagonal throws InexactError from eigen. Prints REPRODUCED.
using LinearAlgebra
B = Bidiagonal([1.0, 2.0, 3.0], [0.0, 1.0], :L)
E = eigen(B)
@assert E.values == [1.0, 2.0, 3.0]                 # eigenvalues correct
@assert any(isnan, E.vectors)                       # eigenvectors contain NaN
@assert !any(isnan, eigen(Matrix(B)).vectors)       # dense is clean
inexact = try eigen(Bidiagonal([1, 2], [1], :U)); false catch err; err isa InexactError end
@assert inexact                                     # integer :U throws InexactError
println("eigvals=", E.values, "  NaN in vectors=", any(isnan, E.vectors), "  int :U InexactError=", inexact)
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

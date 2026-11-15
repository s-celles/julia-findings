# ldiv!(A::Tridiagonal, B) overwrites A with its LU factors (it is implemented as ldiv!(lu!(A), B)),
# while ldiv! on Diagonal, Bidiagonal, SymTridiagonal and the triangular wrappers leaves A intact and
# the docstring only lists "structured matrix types ... already in factored form" as permitted. The
# solution written to B is correct; the surprise is the silently modified left argument. Prints
# REPRODUCED when A is modified.
using LinearAlgebra
A = Tridiagonal([-1.5], [-1.5, 1.8333333333333335], [-1.0]); A0 = copy(A)
C = [2.25 0.0; -1.25 0.0]
ldiv!(A, C)
println("solution correct: ", C ≈ Matrix(A0) \ [2.25 0.0; -1.25 0.0])
println("A before: ", A0); println("A after:  ", A)
others = [("SymTridiagonal", SymTridiagonal([2.0, 3.0], [1.0])), ("Bidiagonal", Bidiagonal([2.0, 3.0], [1.0], :U)), ("Diagonal", Diagonal([2.0, 3.0])), ("UpperTriangular", UpperTriangular([2.0 1.0; 0.0 3.0]))]
for (name, M) in others
    M0 = copy(M); ldiv!(M, [1.0 2.0; 3.0 4.0]); println(rpad(name, 16), " kept: ", M == M0)
end
println(A == A0 ? "AGREE on " : "REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

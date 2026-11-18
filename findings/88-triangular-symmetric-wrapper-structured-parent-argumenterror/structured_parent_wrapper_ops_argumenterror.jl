# Arithmetic, triu and svdvals on triangular/symmetric wrappers whose parent is itself structured
# (SymTridiagonal, Bidiagonal, Hermitian...) throw "cannot set off-diagonal entry": the result is
# allocated with similar(parent) and then written outside the parent's structure. The same operations
# work with a Matrix parent and on the dense matrix. Some cases are regressions (2*UnitUpperTriangular(
# SymTridiagonal) worked on 1.11, triu(UpperTriangular(SymTridiagonal)) worked on 1.10). Prints REPRODUCED.
using LinearAlgebra
S = SymTridiagonal([1, 1, 1], [2, 3])
ops = (("2 * UnitUpperTriangular(S)",        () -> 2 * UnitUpperTriangular(S)),
       ("triu(UpperTriangular(S))",          () -> triu(UpperTriangular(S))),
       ("svdvals(UpperTriangular(S))",       () -> svdvals(UpperTriangular(S))),
       ("Symmetric(UpperTriangular)^2",      () -> (T = Symmetric(UpperTriangular([1 2; 0 3])); T * T)),
       ("UpperTriangular(Hermitian) + I",    () -> UpperTriangular(Hermitian([1 2; 2 1])) + I))
for (lbl, f) in ops
    @assert (try f(); false catch err; err isa ArgumentError end)   # structured parent: throws
end
@assert 2 * UnitUpperTriangular(Matrix(S)) == 2 * Matrix(UnitUpperTriangular(S))   # Matrix parent: fine
@assert triu(UpperTriangular(Matrix(S))) == triu(Matrix(UpperTriangular(S)))
println("2 * UnitUpperTriangular(SymTridiagonal(...)) throws ArgumentError; with a Matrix parent it works")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

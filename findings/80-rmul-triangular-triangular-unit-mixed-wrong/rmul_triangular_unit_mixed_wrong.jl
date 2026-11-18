# rmul!(C, A) with C and A both triangular returns silently WRONG values for the unit-triangular and
# mixed (lower x upper) combinations: rmul!(A, B) = _trimul!(A, A, B) uses the destination as the left
# factor while it is being overwritten. The four rmul!(Upper,Upper)/(Lower,Lower)... overloads that avoid
# this (julia#47107) were never written for Unit* types nor for mixed structures. lmul! is always correct.
# Prints REPRODUCED.
using LinearAlgebra
C = UnitUpperTriangular([1 2 3; 0 1 4; 0 0 1]); A = UpperTriangular([1 -1 2; 0 1 5; 0 0 1])
expected = Matrix(C) * Matrix(A)
@assert Matrix(rmul!(copy(C), A)) != expected                         # UnitUpper * Upper: WRONG
@assert Matrix(lmul!(A, copy(C))) == Matrix(A) * Matrix(C)            # lmul!: correct (control)
Cu = UpperTriangular([1 2 3; 0 1 4; 0 0 1])
@assert Matrix(rmul!(copy(Cu), A)) == Matrix(Cu) * Matrix(A)          # Upper * Upper: correct (control)
C2 = UnitUpperTriangular(Float64[1 2 3; 0 1 4; 0 0 1]); A2 = UnitUpperTriangular(Float64[1 -1 2; 0 1 5; 0 0 1])
@assert Matrix(rmul!(copy(C2), A2)) != Matrix(C2) * Matrix(A2)        # UnitUpper * UnitUpper (Float64): WRONG
L = LowerTriangular([0 0 0; -2 2 0; 0 -2 0]); U = UnitUpperTriangular(Int8[1 2 -1; 0 1 1; 0 0 1])
r = Matrix(rmul!(copy(L), U))                                         # Lower * UnitUpper: no error, WRONG
@assert r != Matrix(L) * Matrix(U)
println("rmul!(UnitUpper, Upper) = ", Matrix(rmul!(copy(C), A)), "  expected ", expected)
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

# istriu/istril/isbanded of an EMPTY UnitUpperTriangular/UnitLowerTriangular return false for offsets
# beyond the diagonal, where the dense (vacuously true) answer is true: the unit-triangular predicates
# assume a non-empty unit diagonal (istril(::UnitLowerTriangular, k) = k >= 0, etc.). Correct on
# Julia 1.10/1.11, wrong since 1.12 (partially) and 1.13. Prints REPRODUCED.
using LinearAlgebra
E = zeros(0, 0)
@assert istriu(E, 1) && istril(E, -1) && LinearAlgebra.isbanded(E, 1, 2)   # dense: vacuously true
@assert !istriu(UnitLowerTriangular(E), 1)       # WRONG
@assert !istril(UnitLowerTriangular(E), -1)      # WRONG
@assert !istriu(UnitUpperTriangular(E), 1)       # WRONG
@assert !istril(UnitUpperTriangular(E), -1)      # WRONG
@assert !LinearAlgebra.isbanded(UnitLowerTriangular(E), 1, 2)   # WRONG
@assert istriu(UpperTriangular(E), 1) && istril(LowerTriangular(E), -1)   # non-unit triangular: fine
println("istriu(UnitLowerTriangular(zeros(0,0)), 1) = false; istriu(zeros(0,0), 1) = true")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

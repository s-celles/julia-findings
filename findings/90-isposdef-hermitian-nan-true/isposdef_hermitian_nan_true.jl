# isposdef of a Symmetric/Hermitian matrix containing NaN returns true: isposdef(A::Hermitian) is
# isposdef(cholesky(A; check=false)), i.e. info == 0, and LAPACK potrf does not flag a NaN pivot (the
# test `ajj <= 0` is false for NaN), so info stays 0 and even cholesky(...; check=true) returns a NaN
# factor without an exception. The dense isposdef (uses the generic path for a plain Matrix), Diagonal, and
# the generic BigFloat path all return false. Prints REPRODUCED.
using LinearAlgebra
@assert isposdef(Hermitian([NaN;;]))                      # WRONG: true
@assert !isposdef([NaN;;]) && !isposdef(Diagonal([NaN]))  # dense / Diagonal: false
@assert isposdef(Symmetric([1.0 0.0; 0.0 NaN]))           # WRONG
@assert isposdef(Hermitian([1.0 NaN; NaN 4.0]))           # WRONG
@assert isposdef(Hermitian(Float32[NaN;;]))               # WRONG (Float32 too)
@assert !isposdef(Hermitian(BigFloat[NaN;;]))             # generic _chol! path: correct
F = cholesky(Hermitian([NaN;;]))                          # check=true, no exception
@assert isnan(F.U[1, 1])
println("isposdef(Hermitian([NaN;;])) = ", isposdef(Hermitian([NaN;;])), "   isposdef([NaN;;]) = ", isposdef([NaN;;]))
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

# UpperHessenberg \ b on a singular matrix returns NaN silently, and UpperHessenberg{Rational} \ b
# throws MethodError(givensAlgorithm), while inv(H), lu(H) \ b and the dense path raise
# SingularException / solve exactly. Regression from LinearAlgebra 1.12 to 1.13: #1322 added `\`
# methods for UpperHessenberg that route to the optimized RQ ldiv! (BlasFloat-only, no singularity
# test) instead of the former generic fallback. Prints REPRODUCED (on the regressed versions).
using LinearAlgebra
H = UpperHessenberg([1.0 2.0; 0.0 0.0])                        # singular
x = H \ [1.0, 2.0]
@assert any(isnan, x)                                            # silent NaN
@assert (try inv(H); false catch err; err isa LinearAlgebra.SingularException end)
@assert (try lu(H) \ [1.0, 2.0]; false catch err; err isa LinearAlgebra.SingularException end)
@assert (try Matrix(H) \ [1.0, 2.0]; false catch err; err isa LinearAlgebra.SingularException end)
Hr = UpperHessenberg(Rational{Int}[1 2; 1 3])                   # non-singular, exact
@assert (try Hr \ Rational{Int}[1, 2]; false catch err; err isa MethodError end)   # MethodError(givensAlgorithm)
@assert Matrix(Hr) \ Rational{Int}[1, 2] == Rational{Int}[-1, 1]                   # dense solves exactly
println("H \\ b singular = ", x, "   Hr{Rational} \\ b -> MethodError (dense gives [-1, 1])")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

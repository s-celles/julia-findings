# The isdiag fast path of the dense matrix functions (applydiagonal, src/dense.jl) copies f(Diagonal(A))
# into similar(A, T). For a UnitUpperTriangular/UnitLowerTriangular, a complex Symmetric or a
# SymTridiagonal that container cannot be written to, so sin/cos/tan/acosh/... of a diagonal matrix held
# in one of these wrappers throw ArgumentError while the dense matrix (and the non-diagonal case) works.
# Introduced by JuliaLang/julia#56483 (LinearAlgebra 1.12). Prints REPRODUCED.
using LinearAlgebra
function throws(f)
    try
        f(); return false
    catch e
        e isa ArgumentError || rethrow()
        return true
    end
end
U = UnitUpperTriangular([1.0 0; 0 1])
@assert sin(Matrix(U)) ≈ [sin(1.0) 0; 0 sin(1.0)]                  # dense: fine
@assert sin(UnitUpperTriangular([1.0 1; 0 1])) isa AbstractMatrix  # non-diagonal strict part: fine
@assert throws(() -> sin(U))                                       # WRONG: "cannot set index (1, 1) on the diagonal"
@assert throws(() -> cos(U))
@assert throws(() -> tan(UnitLowerTriangular([1.0;;])))
@assert throws(() -> acosh(U))
S = Symmetric([1.0+0im 0; 0 2])                                    # complex Symmetric is not Hermitian-dispatched
@assert sin(Matrix(S)) ≈ [sin(1.0) 0; 0 sin(2.0)]
@assert throws(() -> sin(S))                                       # WRONG: "Cannot set a non-diagonal index"
@assert throws(() -> log(S))
@assert throws(() -> sqrt(S))
@assert throws(() -> S^0.5)
@assert throws(() -> SymTridiagonal([1.0+0im, 2], [0.0+0im])^(1/3))   # WRONG: "cannot set off-diagonal entry"
@assert sin(Hermitian([1.0+0im 0; 0 2])) isa AbstractMatrix        # Hermitian has its own path: fine
println("sin(UnitUpperTriangular([1.0 0; 0 1])) and sin(Symmetric([1.0+0im 0; 0 2])) throw ArgumentError (dense: fine)")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

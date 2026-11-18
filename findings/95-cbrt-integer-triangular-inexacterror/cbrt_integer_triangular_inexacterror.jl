# cbrt of an UpperTriangular/LowerTriangular with an integer (or rational) element type keeps the
# element type of the input: cbrt(A::UpperTriangular{T}) = UpperTriangular(_cbrt_quasi_triu!(Matrix{T}(A)))
# (src/triangular.jl). The in-place algorithm then throws InexactError (or OverflowError for Rational),
# or silently returns an integer matrix when every root happens to be exact. The dense, Diagonal and
# Symmetric methods all return Float64. Prints REPRODUCED.
using LinearAlgebra
function throws(T, f)
    try
        f(); return false
    catch e
        e isa T || rethrow()
        return true
    end
end
A = [2 1; 0 3]
@assert eltype(cbrt(A)) == Float64                                 # dense: Float64
@assert eltype(cbrt(Diagonal([2, 3]))) == Float64                  # Diagonal: Float64
@assert eltype(cbrt(Symmetric([2 1; 1 3]))) == Float64             # Symmetric: Float64
@assert cbrt(UpperTriangular(float(A))) ≈ cbrt(A)                  # Float64 triangular: fine
@assert throws(InexactError, () -> cbrt(UpperTriangular(A)))       # WRONG: InexactError: Int64(1.2599...)
@assert throws(InexactError, () -> cbrt(UpperTriangular([2 0; 0 3])))
@assert throws(InexactError, () -> cbrt(LowerTriangular([2 0; 1 3])))
@assert throws(OverflowError, () -> cbrt(UpperTriangular([2//1 1; 0 3])))
@assert cbrt(UpperTriangular([8 0; 0 27])) == [2 0; 0 3] && eltype(cbrt(UpperTriangular([8 0; 0 27]))) == Int   # exact roots: Int result
println("cbrt(UpperTriangular([2 1; 0 3])) throws InexactError; cbrt([2 1; 0 3]) is Float64")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

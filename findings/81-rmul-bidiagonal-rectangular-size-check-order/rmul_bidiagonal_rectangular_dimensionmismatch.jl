# rmul!(B::AbstractMatrix, A::Bidiagonal) rejects a valid rectangular B with DimensionMismatch: the size
# check in bidiag.jl is matmul_size_check(size(A), size(B)), i.e. it validates A*B while the method
# computes B*A. B*A, lmul!(A, B'), and rmul! with a Diagonal or triangular A all work. Prints REPRODUCED.
using LinearAlgebra
A = Bidiagonal([1.0, 2, 3, 4], [1.0, 1, 1], :U); C = ones(3, 4)
@assert size(C * A) == (3, 4)                                            # the product is valid
@assert (try rmul!(copy(C), A); false catch err; err isa DimensionMismatch end)   # rmul! rejects it
@assert size(rmul!(ones(3, 4), Diagonal([1.0, 2, 3, 4]))) == (3, 4)     # Diagonal: fine (control)
@assert size(rmul!(ones(3, 4), UpperTriangular(Matrix(A)))) == (3, 4)   # triangular: fine (control)
@assert size(lmul!(A, ones(4, 3))) == (4, 3)                             # lmul!: fine (control)
println("rmul!(ones(3,4), Bidiagonal 4x4) throws DimensionMismatch although ones(3,4) * A is (3,4)")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

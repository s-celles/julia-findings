# istriu/istril of an Upper/LowerTriangular whose parent is a banded matrix examine the band that the
# wrapper masks: istriu(UpperTriangular(Tridiagonal([1],[0,0],[0])), 1) is false although the wrapped
# matrix is entirely zero. The predicates forward to the parent for offsets beyond the diagonal (since
# JuliaLang/LinearAlgebra.jl#1265), and the parent's masked sub-diagonal is still read. A Matrix parent is
# not affected. Prints REPRODUCED.
using LinearAlgebra
U = UpperTriangular(Tridiagonal([1], [0, 0], [0]))
@assert Matrix(U) == zeros(Int, 2, 2)                     # the sub-diagonal 1 is masked by the wrapper
@assert istriu(Matrix(U), 1)                              # dense: true
@assert !istriu(U, 1)                                     # WRONG: reads the masked band
B = UpperTriangular(Bidiagonal([0, 0], [1], :L))
@assert istriu(Matrix(B), 1) && !istriu(B, 1)             # WRONG
L = LowerTriangular(Tridiagonal([0], [0, 0], [1]))
@assert istril(Matrix(L), -1) && !istril(L, -1)           # WRONG
@assert istriu(UpperTriangular(Matrix(Tridiagonal([1], [0, 0], [0]))), 1)   # Matrix parent: correct
println("istriu(UpperTriangular(Tridiagonal([1],[0,0],[0])), 1) = false on an all-zero wrapped matrix")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

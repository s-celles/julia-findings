# triu/tril of a complex Hermitian keep the imaginary part of the stored diagonal, although the Hermitian
# wrapper itself exposes a real diagonal (getindex takes real(...) on the diagonal; triu/tril operate on
# A.data without doing so). Prints REPRODUCED.
using LinearAlgebra
H = Hermitian(ComplexF64[1+2im 3; 0 4-1im], :U)
@assert Matrix(H) == ComplexF64[1 3; 3 4]                          # diagonal is real
@assert triu(Matrix(H))[1, 1] == 1 && tril(Matrix(H))[2, 2] == 4   # dense: real diagonal
@assert Matrix(triu(H)) != triu(Matrix(H))                         # structured: WRONG
@assert triu(H)[1, 1] == 1 + 2im && triu(H)[2, 2] == 4 - 1im       # imaginary parts kept
@assert Matrix(tril(H)) != tril(Matrix(H))
T = Hermitian(Tridiagonal(ComplexF64[0], ComplexF64[3+1im, 0], ComplexF64[-1]), :L)
@assert triu(T)[1, 1] != real(triu(T)[1, 1])                       # also with a Tridiagonal parent
println("triu(Hermitian([1+2im 3; 0 4-1im])) diag = ", [triu(H)[1,1], triu(H)[2,2]], "  expected [1, 4]")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

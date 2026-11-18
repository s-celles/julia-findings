# triu/tril on Diagonal, Bidiagonal, Tridiagonal and SymTridiagonal reject valid diagonal offsets: the
# bounds check is asymmetric (triu! requires -n+1 <= k <= n+1, tril! requires -n-1 <= k <= n-1), while
# the dense triu/tril accept any offset. Sibling of JuliaLang/LinearAlgebra.jl#1876 (BitMatrix, different
# code). Prints REPRODUCED.
using LinearAlgebra
@assert size(triu([1.0;;], -1)) == (1, 1) && size(tril([1.0;;], 1)) == (1, 1)   # dense: any offset
cases = ((triu, Diagonal([1.0]), -1), (tril, Diagonal([1.0]), 1), (triu, Diagonal([1.0, 2, 3]), -3),
         (triu, SymTridiagonal([1.0], Float64[]), -1), (triu, Bidiagonal([1.0], Float64[], :U), -1),
         (triu, Tridiagonal(Float64[], [1.0], Float64[]), -1))
for (f, A, k) in cases
    @assert (try f(A, k); false catch err; err isa ArgumentError end)   # structured: rejects
    @assert size(f(Matrix(A), k)) == size(A)                            # dense: accepts
end
@assert triu(Diagonal([1.0, 2, 3]), 4) isa Diagonal                     # ... but k = 4 (> n) is accepted
println("triu(Diagonal([1.0]), -1) throws ArgumentError; triu([1.0;;], -1) works")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

# A broadcast over three or more structured matrices silently drops entries: the two-argument fallback
# BroadcastStyle(::StructuredMatrixStyle, ::StructuredMatrixStyle) = DefaultArrayStyle{2}() is not
# "sticky", so a third structured argument re-imposes its own structure and the result is allocated in
# that structure (entries outside it are lost). The two-argument broadcast is correct. Related but
# distinct from JuliaLang/LinearAlgebra.jl#1755 (dense arguments absorbed by fzero). Prints REPRODUCED.
using LinearAlgebra
B = Bidiagonal([1.0, 2, 3], [4.0, 5], :U); U = UpperTriangular([1.0 2 3; 0 4 5; 0 0 6])
@assert Matrix(B .+ U) == Matrix(B) .+ Matrix(U)                         # 2-arg: correct (control)
r = B .+ U .+ B
@assert r isa Bidiagonal                                                 # structure wrongly kept
@assert Matrix(r) != Matrix(B) .+ Matrix(U) .+ Matrix(B)                 # entry (1,3) of U dropped
T = Tridiagonal([1.0, 2], [3.0, 4, 5], [6.0, 7])
@assert Matrix(T .+ U .+ T) != Matrix(T) .+ Matrix(U) .+ Matrix(T)       # Tridiagonal result, WRONG
println("B .+ U .+ B = ", Matrix(r), "  expected ", Matrix(B) .+ Matrix(U) .+ Matrix(B))
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

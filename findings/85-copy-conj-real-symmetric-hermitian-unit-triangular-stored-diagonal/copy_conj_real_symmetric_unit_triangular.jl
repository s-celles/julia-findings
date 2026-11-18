# copy, conj and real of a Symmetric/Hermitian wrapping a unit-triangular matrix use the parent's STORED
# diagonal, which the unit-triangular wrapper is supposed to ignore: conj/real return the stored values
# (wrong), and copy returns a diagonal taken from an uninitialized buffer (the unit-triangular copy skips
# the diagonal since JuliaLang/LinearAlgebra.jl#1350). parentof_applytri strips the unit wrapper. Correct
# on Julia 1.10, wrong since 1.11. Prints REPRODUCED.
using LinearAlgebra
U = UnitLowerTriangular([5 0; 2 7]); H = Hermitian(U, :L)
@assert Matrix(H) == [1 2; 2 1]                                   # the unit diagonal is 1
@assert Matrix(conj(H)) == [5 2; 2 7]                             # conj: stored diagonal, WRONG
@assert Matrix(conj(Symmetric(U, :L))) == [5 2; 2 7]
R = real(Hermitian(UnitLowerTriangular(Diagonal(ComplexF64[-0.5, 0.5])), :L))
@assert Matrix(R) == [-0.5 0; 0 0.5]                              # real: stored diagonal, WRONG (expected I)
c = copy(H)
@assert !(parent(c) isa UnitLowerTriangular)                       # copy drops the unit wrapper ...
@assert c != H                                                    # ... and its diagonal is not the unit diagonal
S = Symmetric(UnitUpperTriangular([1.0 2; 0 1])); @assert copy(S) != S
M = Symmetric([1 2; 2 1]); @assert copy(M) == M && conj(M) == M   # plain Matrix parent: fine (control)
println("conj(Hermitian(UnitLower([5 0;2 7]))) = ", Matrix(conj(H)), "  expected [1 2; 2 1]")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

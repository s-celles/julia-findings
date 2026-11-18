# Broadcasting or copyto! into a banded destination that aliases its source gives WRONG values: the
# structured copyto! methods write the bands (d, du, dl) one after the other without unaliasing the
# source, and transpose/adjoint of a Tridiagonal shares the band vectors. The dense destination is
# correct. Prints REPRODUCED.
using LinearAlgebra
T = Tridiagonal([1, 2], [3, 4, 5], [6, 7]); expected = Matrix(T')
T .= T'
@assert Matrix(T) != expected                                            # T .= T' : WRONG
T = Tridiagonal([1, 2], [3, 4, 5], [6, 7]); copyto!(T, T')
@assert Matrix(T) != expected                                            # copyto!(T, T') : WRONG
D = Diagonal([1, 2, 3]); D .= Diagonal(view(D.diag, 3:-1:1))
@assert D.diag != [3, 2, 1]                                              # reversed-view self-assignment : WRONG
M = Matrix(Tridiagonal([1, 2], [3, 4, 5], [6, 7])); M .= M'
@assert M == expected                                                    # dense destination : correct (control)
println("T .= T' gave ", Matrix(Tridiagonal([1, 2], [3, 4, 5], [6, 7]) |> t -> (t .= t'; t)), "  expected ", expected)
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

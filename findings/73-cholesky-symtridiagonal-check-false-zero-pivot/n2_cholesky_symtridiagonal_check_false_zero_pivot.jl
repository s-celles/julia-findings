# cholesky(S::SymTridiagonal; check=false) throws ZeroPivotException on a zero diagonal pivot
# instead of returning a factorization with issuccess == false, as the dense path does; as a
# consequence isposdef(::SymTridiagonal) throws instead of returning false. Root: _chol!(::Bidiagonal)
# throws unconditionally on iszero(dv[i]) (JuliaLang/LinearAlgebra.jl#1880 fixed only the empty n==0
# case of the same function). Prints REPRODUCED.
using LinearAlgebra
S = SymTridiagonal([1.0, 0.0, 0.0], [0.0, 1.0])
threw = try cholesky(S; check=false); false catch err; err isa LinearAlgebra.ZeroPivotException end
@assert threw                                                     # structured throws despite check=false
@assert !issuccess(cholesky(Matrix(S); check=false))              # dense: issuccess == false, no throw
P = SymTridiagonal([0.0, 1.0], [1.0])
isposdef_threw = try isposdef(P); false catch err; err isa LinearAlgebra.ZeroPivotException end
@assert isposdef_threw                                            # isposdef throws
@assert isposdef(Matrix(P)) == false                              # dense returns false
println("cholesky(S;check=false) threw=", threw, "  isposdef(P) threw=", isposdef_threw, "  dense isposdef=", isposdef(Matrix(P)))
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

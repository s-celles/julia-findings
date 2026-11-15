# det of a Symmetric or Hermitian matrix with Rational elements returns a Float64, while inv and \
# on the same wrapper and det on the dense matrix stay exact Rational. The Bunch-Kaufman path used
# for symmetric determinants converts to floating point, so an exact type silently loses exactness
# (and large rationals lose precision). Sibling of JuliaLang/LinearAlgebra.jl#1871, where Symmetric
# integer matrices give BigFloat/Rational{BigInt}. Prints REPRODUCED when det is not a Rational.
using LinearAlgebra
S = Symmetric(Rational{Int64}[1 2; 2 3])
H = Hermitian(Rational{Int64}[1 2; 2 3])
big = Symmetric(Rational{Int64}[1 1//3; 1//3 1//10^9])
println("det(Symmetric{Rational})  = ", repr(det(S)), " :: ", typeof(det(S)), "   dense: ", repr(det(Matrix(S))), " :: ", typeof(det(Matrix(S))))
println("det(Hermitian{Rational})  = ", repr(det(H)), " :: ", typeof(det(H)))
println("inv(S) eltype             = ", eltype(inv(S)), "   S \\ b eltype = ", eltype(S \ Rational{Int64}[1, 2]))
println("det(big) = ", repr(det(big)), "   exact dense = ", repr(det(Matrix(big))), "   equal: ", det(big) == det(Matrix(big)))
ok = det(S) isa Rational && det(H) isa Rational && det(big) == det(Matrix(big))
println(ok ? "AGREE on " : "REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

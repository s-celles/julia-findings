# Symmetric integer matrices go through the generic Bunch-Kaufman factorization, which
# promotes to Rational{BigInt}; det, logabsdet and \ then return BigFloat / Rational{BigInt}
# where the dense and Diagonal paths return Float64.
using LinearAlgebra

S = Symmetric(Int8[1 2; 2 3])
b = Int8[1, 2]

@assert typeof(det(S)) === BigFloat
@assert typeof(det(Matrix(S))) === Float64
@assert typeof(logabsdet(S)) === Tuple{BigFloat, Rational{BigInt}}
@assert typeof(S \ b) === Vector{Rational{BigInt}}
@assert typeof(Matrix(S) \ b) === Vector{Float64}
# Matrix right-hand sides use LU and give Float64, unlike vector right-hand sides.
@assert eltype(S \ Int8[1 0; 0 1]) === Float64
@assert eltype(inv(S)) === Float64
@assert typeof(factorize(S)) <: BunchKaufman{Rational{BigInt}}
println("REPRODUCED")

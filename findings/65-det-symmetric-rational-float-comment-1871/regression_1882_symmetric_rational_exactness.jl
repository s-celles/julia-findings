# Regression check for JuliaLang/LinearAlgebra.jl PR #1882 (closed #1871).
# The PR makes _factorize(::HermOrSym{T}) convert A to float(T) before factorizing, so Symmetric /
# Hermitian solves, inv and det over Rational become FLOAT instead of exact Rational. This fixes the
# type-inconsistency of #1871 but REGRESSES exact rational linear algebra. This script shows, on the
# CURRENT release (pre-#1882), the exact result, and what #1882 produces (simulated by converting to
# float(T) and using lu, exactly as the PR does). Prints REGRESSION when the PR result is no longer
# exact/Rational.
using LinearAlgebra
println("current: ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))
S = Symmetric(Rational{Int}[2 1; 1 2]); b = Rational{Int}[1, 1]
cur = S \ b
# PR #1882 behaviour: A2 = convert(AbstractMatrix{float(T)}, A); lu(A2) \ float.(b)
A2 = convert(AbstractMatrix{float(Rational{Int})}, S)
pr = lu(Matrix(A2)) \ float.(b)
println("current  S \\ b = ", cur, " :: ", typeof(cur))
println("PR #1882 S \\ b = ", pr, " :: ", typeof(pr))
# well-conditioned exact answer is [1//3, 1//3]; the PR result is float and its two entries differ
regressed = !(cur isa Vector{<:Rational}) || (pr isa Vector{<:AbstractFloat} && pr[1] != pr[2])
# Hilbert, ill-conditioned: exact stays exact, float loses precision
n = 9
H = Symmetric(Rational{BigInt}[1//(i+j-1) for i in 1:n, j in 1:n])
bb = Rational{BigInt}[sum(H[i,:]) for i in 1:n]
xe = H \ bb
Hf = convert(AbstractMatrix{float(Rational{BigInt})}, H)
xf = lu(Matrix(Hf)) \ float.(bb)
println("Hilbert($n) exact err = ", maximum(abs.(xe .- 1)), " ; PR float err = ", Float64(maximum(abs.(xf .- 1))))
println((regressed || maximum(abs.(xf .- 1)) > 0) ? "REGRESSION (exactness lost) on " : "ok on ", VERSION)

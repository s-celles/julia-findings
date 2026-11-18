# det and logabsdet of a square sparse matrix with Rational elements go through the sparse LU
# (UMFPACK, Float64), so they lose exactness: det returns a Float64 (not the exact Rational) and
# logabsdet returns a Float64 sign, where the dense Matrix path is exact. For Rational{BigInt} the
# sparse path throws ArgumentError ("matrix type SparseMatrixCSC{BigFloat,...} not supported") where
# the dense path returns the exact value. Same root as the sparse Rational `\` inexactness
# (JuliaSparse/SparseArrays.jl#1179 / catalogue entry 70), on the det/logabsdet operations.
# Prints REPRODUCED.
using SparseArrays, LinearAlgebra

A = Rational{Int}[2 1 0 0; 1 3 1 0; 0 1 4 1; 0 0 1 2]; S = sparse(A)
ds = det(S); dd = det(Matrix(S))
@assert dd == 31//1 && dd isa Rational{Int}          # dense: exact
@assert ds isa Float64 && ds != dd                   # sparse: Float64, inexact (30.999...96)

sign_s = logabsdet(S)[2]; sign_d = logabsdet(Matrix(S))[2]
@assert sign_d isa Rational{Int}                      # dense sign is Rational
@assert sign_s isa Float64                            # sparse sign is Float64

B = Rational{BigInt}[2 1 0; 1 3 1; 0 1 4]; SB = sparse(B)
@assert det(Matrix(SB)) == 18//1                      # dense: exact
threw = try det(SB); false catch err; err isa ArgumentError end
@assert threw                                         # sparse: ArgumentError (BigFloat unsupported)

println("det(sparse Rational{Int}) = ", ds, " :: ", typeof(ds), "   dense = ", dd, " :: ", typeof(dd))
println("det(sparse Rational{BigInt}) throws ArgumentError = ", threw, "   dense = 18//1")
println("REPRODUCED on ", VERSION, " SparseArrays ", pkgversion(SparseArrays))

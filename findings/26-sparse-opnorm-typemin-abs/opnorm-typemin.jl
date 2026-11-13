# Sparse opnorm(A, 1) and opnorm(A, Inf) take abs in the integer element type, which wraps on typemin.
using SparseArrays, LinearAlgebra

A = sparse(Int8[1 -128; 1 0])
@assert opnorm(A, 1) == 2.0
@assert opnorm(Matrix(A), 1) == 128.0
@assert opnorm(A, Inf) == 1.0
@assert opnorm(Matrix(A), Inf) == 129.0
B = sparse([typemin(Int) 0 -2; 0 0 0; -2 0 0])
@assert opnorm(B, 1) == 2.0
@assert opnorm(Matrix(B), 1) == 9.223372036854776e18
println("REPRODUCED")

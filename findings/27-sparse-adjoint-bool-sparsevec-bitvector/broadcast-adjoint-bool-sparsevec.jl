# Broadcasting a sparse matrix with the adjoint of a SparseVector{Bool} fails to build the result.
using SparseArrays

S = sparse(Bool[true false; true true])
x = sparsevec(Bool[true, false])
@assert Matrix(S) .* Vector(x)' == Bool[1 0; 1 0]
@assert S .* Vector(x)' == Bool[1 0; 1 0]
got = try
    S .* x'
catch err
    err
end
@assert got isa MethodError
println("REPRODUCED")

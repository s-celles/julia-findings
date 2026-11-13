# BitMatrix-specific triu/tril methods reject valid offsets accepted for Matrix{Bool}.
using LinearAlgebra

A = Bool[1 0]
@assert triu(A, -1) == A
triu_error = try
    triu(BitMatrix(A), -1)
catch err
    err
end
@assert triu_error isa ArgumentError

B = reshape(Bool[1, 0], 2, 1)
@assert tril(B, 1) == B
tril_error = try
    tril(BitMatrix(B), 1)
catch err
    err
end
@assert tril_error isa ArgumentError

println("REPRODUCED")

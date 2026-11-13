# The strided-matrix muladd allocates its result in promote_type(Bool, Bool, Bool) == Bool.
using LinearAlgebra

B = Bool[true true; true true]
@assert B * B + B == [3 3; 3 3]
@assert muladd(UpperTriangular(B), B, B) == [3 3; 2 2]
got = try
    muladd(B, B, B)
catch err
    err
end
@assert got isa InexactError
println("REPRODUCED")

# Unit triangular integer `\` keeps the integer element type and fails on overflow.
using LinearAlgebra

U = UnitLowerTriangular(Int8[1 0; -128 1])
b = Int8[1, 0]
@assert Matrix(U) \ b == [1.0, 128.0]
got = try
    U \ b
catch err
    err
end
@assert got isa InexactError
@assert UnitUpperTriangular(Int8[1 1; 0 1]) \ Int8[0, 1] == Int8[-1, 1]
@assert eltype(UnitUpperTriangular(Int8[1 1; 0 1]) \ Int8[0, 1]) === Int8
println("REPRODUCED")

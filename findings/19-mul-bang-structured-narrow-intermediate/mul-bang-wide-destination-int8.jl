# Structured mul! computes products in the narrow input type before storing into a wider
# destination; the dense path accumulates in the destination type.
using LinearAlgebra

D = Diagonal(Int8[127, 1])
B = Int8[2 0; 0 1]
got = mul!(zeros(Int, 2, 2), D, B)
reference = mul!(zeros(Int, 2, 2), Matrix(D), B)

@assert got == [-2 0; 0 1]
@assert reference == [254 0; 0 1]

# With a narrow destination and a scalar, the two paths disagree on wrap versus InexactError.
x = Int8[2, 1]
got_narrow = mul!(similar(x), D, x, 2, 0)
reference_narrow = try
    mul!(similar(x), Matrix(D), x, 2, 0)
catch err
    err
end
@assert got_narrow == Int8[-4, 2]
@assert reference_narrow isa InexactError

# The same happens for the unit triangular matrix-vector kernel.
U = UnitLowerTriangular(UInt8[1 0; 1 1])
y = UInt8[254, 2]
@assert mul!(zeros(Int, 2), U, y) == [254, 0]
@assert mul!(zeros(Int, 2), Matrix(U), y) == [254, 256]
println("REPRODUCED")

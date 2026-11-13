using LinearAlgebra

A = Bidiagonal(Int8[127, 127], Int8[127], :U)
got = sum(A; dims = 1)
reference = sum(Matrix(A); dims = 1)

@assert got == Int8[127 -2]
@assert reference == [127 254]
println("REPRODUCED")


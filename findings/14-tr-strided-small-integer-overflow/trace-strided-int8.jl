using LinearAlgebra

A = Int8[127 127; 0 127]
got = tr(A)
reference = sum(diag(A))

@assert got == Int8(-2)
@assert reference == 254
println("REPRODUCED")


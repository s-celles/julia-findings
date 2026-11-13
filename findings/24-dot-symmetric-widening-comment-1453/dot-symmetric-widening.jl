# dot(::Symmetric, ::Symmetric) widens narrow integers; the generic dot wraps.
using LinearAlgebra

A = Symmetric(Int8[-1 1; 2 127], :U)
B = Symmetric(Int8[127 -1; 126 0], :U)
@assert dot(A, B) === -129
@assert dot(Matrix(A), Matrix(B)) === Int8(127)
@assert dot(UInt8[254, 2], UInt8[1, 2]) === 0x02
println("REPRODUCED")

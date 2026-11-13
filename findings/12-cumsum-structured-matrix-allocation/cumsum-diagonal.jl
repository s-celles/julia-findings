using LinearAlgebra

A = Diagonal(Int8[1, 0])
err = try
    cumsum(A; dims = 1)
    nothing
catch caught
    caught
end

@assert err isa ArgumentError
@assert cumsum(Matrix(A); dims = 1) == [1 0; 1 0]
println("REPRODUCED")


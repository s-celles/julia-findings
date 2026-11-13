using LinearAlgebra

A = SymTridiagonal(Int8[], Int8[])
err = try
    tr(A)
    nothing
catch caught
    caught
end

@assert err isa ArgumentError
@assert tr(Matrix(A)) == 0
println("REPRODUCED")

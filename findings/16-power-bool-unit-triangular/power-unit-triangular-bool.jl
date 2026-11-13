using LinearAlgebra

for A in (
    UnitUpperTriangular(Bool[true true; false true]),
    UnitLowerTriangular(Bool[true false; true true]),
)
    @assert eltype(A * A) === Int64
    for exponent in 0:2
        err = try
            A^exponent
            nothing
        catch caught
            caught
        end
        @assert err isa MethodError
        @assert Matrix(A)^exponent isa Matrix{Int64}
    end
end
println("REPRODUCED")


using LinearAlgebra

for A in (
    UnitUpperTriangular(Bool[true true; false true]),
    UnitLowerTriangular(Bool[true false; true true]),
)
    err = try
        -A
        nothing
    catch caught
        caught
    end
    @assert err isa InexactError
    @assert -Matrix(A) == [-1 -Int(A[1, 2]); -Int(A[2, 1]) -1]
end
println("REPRODUCED")


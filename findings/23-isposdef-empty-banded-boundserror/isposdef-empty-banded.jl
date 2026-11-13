# isposdef of empty banded matrices throws BoundsError; dense and Diagonal return true.
using LinearAlgebra

@assert isposdef(zeros(0, 0))
@assert isposdef(Diagonal(Float64[]))
for A in (SymTridiagonal(Float64[], Float64[]), Tridiagonal(Float64[], Float64[], Float64[]),
          Bidiagonal(Float64[], Float64[], :U), Bidiagonal(Int8[], Int8[], :L))
    got = try
        isposdef(A)
    catch err
        err
    end
    @assert got isa BoundsError
end
println("REPRODUCED")

# sum/prod (and reduce with no explicit init) of an EMPTY Adjoint/Transpose wrapper throws, where the
# materialized empty array and every other lazy wrapper (view/reshape/PermutedDimsArray) return the
# neutral element zero(T)/one(T). Adjoint/Transpose are AbstractArrays and should reduce an empty
# typed array to the neutral element like the dense path. Prints REPRODUCED.
using LinearAlgebra
A = Matrix{Float64}(undef, 1, 0)                       # 1x0 empty
@assert sum(collect(A')) === 0.0                       # dense empty: neutral element
@assert prod(collect(A')) === 1.0
@assert sum(view(A, :, :)) === 0.0                     # view empty: neutral element (control)
sum_threw  = try sum(A');  false catch err; err isa Union{ArgumentError,MethodError} end
prod_threw = try prod(A'); false catch err; err isa Union{ArgumentError,MethodError} end
@assert sum_threw                                      # Adjoint empty: THROWS
@assert prod_threw
# transpose of a wide empty behaves the same
@assert (try sum(transpose(A)); false catch; true end)
println("sum(empty A') threw=", sum_threw, "  prod threw=", prod_threw, "  (dense/view give 0.0/1.0)")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

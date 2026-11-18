# cond of an all-zero integer Diagonal throws InexactError: Int64(Inf). cond(A, 2) returns
# oftype(real(maxv), Inf) when the largest singular value is zero; svdvals(::Diagonal{Int}) keeps the
# integer element type (dense svdvals returns Float64), so the conversion of Inf fails. The dense matrix
# returns Inf, and so does the Diagonal as soon as one entry is non-zero. Prints REPRODUCED.
using LinearAlgebra
function inexact(f)
    try
        f(); return false
    catch e
        e isa InexactError || rethrow()
        return true
    end
end
@assert cond(zeros(Int, 2, 2)) == Inf                              # dense: Inf
@assert cond(Diagonal([0, 2])) == Inf                              # one non-zero entry: Inf
@assert cond(Diagonal([0.0, 0.0])) == Inf                          # Float64: Inf
@assert cond(Diagonal([0, 0]), 1) == Inf                           # p = 1: Inf
@assert svdvals(Diagonal([0, 0])) == [0, 0] && eltype(svdvals(Diagonal([0, 0]))) == Int
@assert inexact(() -> cond(Diagonal([0, 0])))                      # WRONG: InexactError: Int64(Inf)
@assert inexact(() -> cond(Diagonal(Int8[0])))
println("cond(Diagonal([0, 0])) throws InexactError: Int64(Inf); cond(zeros(Int, 2, 2)) is Inf")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

# svdvals(Diagonal) takes abs in the integer element type, which wraps on typemin.
using LinearAlgebra

D = Diagonal(Int8[-128])
@assert svdvals(D) == Int8[-128]
@assert rank(D) == 0
@assert rank(Matrix(D)) == 1
@assert rank(Diagonal(Int16[-32768])) == 0
println("REPRODUCED")

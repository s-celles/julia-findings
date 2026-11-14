# det of Tridiagonal and SymTridiagonal matrices with narrow integer elements returns an Int64 that
# is neither the exact determinant nor its two's complement wrap in the element type: the
# three-term recurrence multiplies the Int8 elements (which wraps) and accumulates in Int. The same
# matrix as a dense Matrix{Int8} gives the exact value as a Float64, and Diagonal{Int8} gives the
# exact Int. Prints REPRODUCED when a structured determinant is wrong.
using LinearAlgebra
A = Int8[-14 1 14 6; 1 -6 -1 7; 14 -1 4 -14; 6 7 -14 4]
T = Tridiagonal(diag(A, -1), diag(A), diag(A, 1))
S = SymTridiagonal(Int8[100, 100, 100], Int8[50, 50])
exact_T = det(Tridiagonal(big.(diag(A, -1)), big.(diag(A)), big.(diag(A, 1))))
exact_S = det(SymTridiagonal(big.([100, 100, 100]), big.([50, 50])))
println("det(Tridiagonal{Int8})    = ", det(T), " (", typeof(det(T)), ")  exact ", exact_T, "  dense ", det(Matrix(T)))
println("det(SymTridiagonal{Int8}) = ", det(S), " (", typeof(det(S)), ")  exact ", exact_S, "  dense ", det(Matrix(S)))
println("det(Diagonal{Int8})       = ", det(Diagonal(Int8[100, 100])), "  exact 10000")
wrong = det(T) != exact_T || det(S) != exact_S
println(wrong ? "REPRODUCED on " : "AGREE on ", VERSION)

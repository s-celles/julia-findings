# `\` on a square sparse matrix with Rational elements that is neither triangular nor symmetric goes
# through UMFPACK in Float64 and converts the floating-point solution back to Rational{Int64}: the
# result has the exact type but float-derived values (denominators that are powers of two), and a
# tiny float that does not fit Rational{Int64} raises InexactError. The dense solve and the symmetric
# sparse path (Bunch-Kaufman) are exact. Prints REPRODUCED when the sparse solution is not exact.
using LinearAlgebra, SparseArrays
S = sparse(Rational{Int64}[2 1 0; 0 3 1; 1 0 4])
b = Rational{Int64}[1, 2, 3]
sparse_x = S \ b
dense_x = Matrix(S) \ b
println("sparse(S) \\ b = ", sparse_x)
println("Matrix(S) \\ b = ", dense_x)
println("symmetric sparse (Bunch-Kaufman path) exact: ", sparse(Rational{Int64}[2 1; 1 3]) \ Rational{Int64}[1, 1] == Matrix(Rational{Int64}[2 1; 1 3]) \ Rational{Int64}[1, 1])
big = sparse(Rational{Int64}[1 1 0; 0 1 1; 1 0 10^9])
r = try
    repr(big \ Rational{Int64}[1, 1, 1])
catch err
    "ERROR: " * first(sprint(showerror, err), 60)
end
println("entries near 1e-9: ", r)
println(sparse_x == dense_x ? "AGREE on " : "REPRODUCED on ", VERSION, " SparseArrays ", pkgversion(SparseArrays))

# isequal between a sparse matrix and the lazy adjoint/transpose of a sparse matrix is wrong on the
# current nightly (SparseArrays 1.14.0, after JuliaSparse/SparseArrays.jl#985): (1) a complex zero sparse
# matrix is isequal to its adjoint although the adjoint's implicit zero is conj(0) = 0.0-0.0im (the dense
# isequal is false) — and the hashes differ, violating the isequal/hash contract; (2) a real sparse
# adjoint is NOT isequal to the equal complex sparse matrix (dense: true), because the comparison
# conjugates both sides. Correct on Julia 1.10-1.13. Prints REPRODUCED on the regressed versions.
using SparseArrays, LinearAlgebra
Z = spzeros(ComplexF64, 2, 2)
@assert !isequal(Matrix(Z), Matrix(Z'))        # dense: 0.0+0.0im vs 0.0-0.0im are not isequal
@assert isequal(Z, Z')                         # sparse lazy adjoint: true (WRONG)
@assert hash(Z) != hash(Z')                    # ... with different hashes: isequal => hash contract violated
@assert isequal(spzeros(2, 2), Z')             # also real-zero vs complex-zero adjoint (WRONG)
A = sparse([1], [1], [1]); B = sparse([1], [1], [1.0 + 0.0im])
@assert isequal(Matrix(A'), Matrix(B))         # dense: true
@assert !isequal(A', B)                        # sparse: false (WRONG)
println("isequal(spzeros(ComplexF64,2,2), its adjoint) = true with hash(Z) != hash(Z'); isequal(A', B) real/complex = false")
println("REPRODUCED on ", VERSION, " SparseArrays ", pkgversion(SparseArrays))

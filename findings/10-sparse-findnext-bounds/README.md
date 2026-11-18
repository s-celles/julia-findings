# 10: Comment on JuliaSparse/SparseArrays.jl: The optimized search methods for sparse vectors can return a match when the

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: fixed upstream — JuliaSparse/SparseArrays.jl#1176 closed by [PR #1182](https://github.com/JuliaSparse/SparseArrays.jl/pull/1182) (2026-11-18)

# Sparse `findnext` and `findprev` accept invalid starting indices

The optimized search methods for sparse vectors can return a match when the
starting index lies outside the vector on the side where Base's generic array
method raises `BoundsError`.

```julia
using SparseArrays

dense = [0, 1]
sparse = sparsevec(dense)

findnext(!iszero, dense, 0)  # BoundsError
findnext(!iszero, sparse, 0) # 2

findprev(!iszero, dense, 3)  # BoundsError
findprev(!iszero, sparse, 3) # 2

dense_matrix = reshape([0, 1], 2, 1)
sparse_matrix = sparse(dense_matrix)
findnext(!iszero, dense_matrix, CartesianIndex(0, 1))  # BoundsError
findnext(!iszero, sparse_matrix, CartesianIndex(0, 1)) # CartesianIndex(2, 1)
findprev(!iszero, dense_matrix, CartesianIndex(3, 1))  # BoundsError
findprev(!iszero, sparse_matrix, CartesianIndex(3, 1)) # CartesianIndex(2, 1)
```

The results agree when the starting index is within `1:2`. The discrepancy is
present when the sparse vector has implicit zeros and the optimized method
searches its stored indices directly. Base's documented `findnext` and
`findprev` methods operate from the supplied index and use array indexing;
for these two starts the corresponding dense call raises `BoundsError`.

Reproduced on Julia 1.15.0-DEV.688 / SparseArrays 1.14.0 for sparse vectors
and matrices. On Julia 1.13.0, both sparse and dense calls raise `BoundsError`.
SparseArrays PR #969 added the fast search path for sparse views; it is
related, but its description and tests do not cover this bounds behavior.
Current `main` has the same direct `searchsortedfirst` / `searchsortedlast`
implementation. Searches on
2026-11-12 for `findnext BoundsError`, `findprev out of bounds` and
`findnext bounds` in JuliaSparse/SparseArrays.jl found no matching issue or
PR.

Found with a differential SparseArrays probe in Concolic.jl.

Assisted-by: AI

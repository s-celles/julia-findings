# 89: `isequal` between a sparse matrix and a lazy sparse adjoint/transpose is wrong on the nightly (implicit zero conjugated, real vs complex), and `isequal` is true while the hashes differ — regression after SparseArrays.jl#985

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: posted ([JuliaSparse/SparseArrays.jl#1185](https://github.com/JuliaSparse/SparseArrays.jl/issues/1185))

# Body

On the current nightly (SparseArrays 1.14.0), `isequal` involving a lazy `Adjoint`/`Transpose` of a
sparse matrix disagrees with the dense answer in both directions, and in one case breaks the
`isequal ⟹ hash` contract:

```julia-repl
julia> using SparseArrays, LinearAlgebra

julia> Z = spzeros(ComplexF64, 2, 2);

julia> isequal(Matrix(Z), Matrix(Z'))     # dense: the adjoint's zeros are 0.0-0.0im, not isequal to 0.0+0.0im
false

julia> isequal(Z, Z')                      # nightly: true   (1.10–1.13: false)
true

julia> hash(Z) == hash(Z')                 # isequal is true but the hashes differ: contract violated
false

julia> isequal(spzeros(2, 2), Z')          # nightly: true   (dense: false)
true

julia> A = sparse([1], [1], [1]); B = sparse([1], [1], [1.0 + 0.0im]);

julia> isequal(Matrix(A'), Matrix(B))
true

julia> isequal(A', B)                      # nightly: false  (dense: true; same for Bool, Int8, Rational)
false
```

Mechanism (nightly `src/sparsematrix.jl` and `src/sparsevector.jl`, the `_iseq` family introduced by
JuliaSparse/SparseArrays.jl#985 "Compare the implicit zeros in `==` and `isequal` of sparse arrays"):
`_iseq(eq, A, B::AdjOrTrans)` calls `_implicit_zeros(eq, A, first(_peel(B)))` on the *unconjugated*
root, so the implicit zero of `S'` is taken as `0.0+0.0im` while it is `conj(0) = 0.0-0.0im`; the
shortcut `Ta === Tb ⟹ zeq = true` never compares the zeros at all. Separately,
`isequal(A::Adjoint{<:sparse}, B::sparse) = isequal(A', B')` conjugates both sides, which is not valid
for real vs complex (`isequal(1, 1.0+0.0im)` is true but `isequal(1, 1.0-0.0im)` is false) — the comment
in `_iseq_dense` acknowledges exactly this trap for the dense comparison, but not for the
sparse–sparse path.

Versions checked: correct on Julia 1.10.11, 1.11.9, 1.12.6 and 1.13.3; wrong on nightly 1.15.0-DEV.834
(SparseArrays 1.14.0) — a regression in unreleased code (#985 was merged on 2026-10-04).

Deduplication searches (2026-11-19): the complete issue and PR lists of `JuliaSparse/SparseArrays.jl`
(1–1184) filtered on `isequal`, `hash`, `equal`, `zero`, `adjoint`: only #985 (the cause), #905 (open,
"Decide how to handle -0.0", about storage semantics, not this code), #768 (added `isequal` for
adjoint/transpose of sparse, 2024) and #1024 (lazy-adjoint `==`), none reporting this; the
MilesCranmer/julia-in-lean corpus has nothing on sparse equality.

Found by a metamorphic equality/hash-law probe across wrappers. Reproducer:
`sparse_isequal_adjoint_implicit_zero_regression.jl` (prints `REPRODUCED` on the regressed nightly;
its assertions fail on 1.10–1.13, where the behaviour is correct).

Assisted-by: AI

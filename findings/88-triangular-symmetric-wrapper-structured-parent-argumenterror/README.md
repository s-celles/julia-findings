# 88: scaling, `triu`, `svdvals`, products and `± I` on triangular/symmetric wrappers of a structured parent throw "cannot set off-diagonal entry" (regressions in LinearAlgebra 1.11 and 1.12)

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

When a triangular or symmetric wrapper's parent is itself a structured matrix, several operations that
work with a `Matrix` parent (and on the dense matrix) throw:

```julia-repl
julia> using LinearAlgebra

julia> S = SymTridiagonal([1, 1, 1], [2, 3]);

julia> 2 * UnitUpperTriangular(S)
ERROR: ArgumentError: cannot set off-diagonal entry (1, 2) to a nonzero value (2)

julia> triu(UpperTriangular(S))
ERROR: ArgumentError: cannot set off-diagonal entry ...

julia> svdvals(UpperTriangular(S))
ERROR: ArgumentError: ...

julia> T = Symmetric(UpperTriangular([1 2; 0 3])); T * T
ERROR: ArgumentError: ...

julia> UpperTriangular(Hermitian([1 2; 2 1])) + I
ERROR: ArgumentError: ...

julia> 2 * UnitUpperTriangular(Matrix(S)), triu(UpperTriangular(Matrix(S)))   # Matrix parent: fine
```

Also `Hermitian(UnitLowerTriangular([1 0; 2 1]), :L)^2` and `Symmetric(Bidiagonal([1, 2], [3], :L), :L)^2`.
(`Symmetric(Tridiagonal(...)) * ...` works, and the `B - B'` case of #1099 is fixed; `± I` is not.)

Mechanism: the output is allocated with `similar(parent)` — i.e. in the parent's structure — and then
filled by code that writes outside that structure: `triu!(::UnitUpperTriangular)` writes `A.data[i]`,
`_triscale!` writes `A.data[i, j]` (`src/triangular.jl`), and the symmetric products write the full
block. A `SymTridiagonal`/`Bidiagonal`/`Hermitian` parent then rejects the write. Related but distinct
from JuliaLang/LinearAlgebra.jl#1865 (`cumsum` into structured wrappers) and from the closed #1099
(`B - B'` only).

Versions checked: all five cases throw on Julia 1.12.6, 1.13.3 and nightly 1.15.0-DEV.834 (LinearAlgebra
1.14.0) and on the current LinearAlgebra.jl master; on 1.10.11 and 1.11.9 some of them still worked —
`2 * UnitUpperTriangular(SymTridiagonal(...))` worked up to 1.11 (regression in 1.12) and
`triu(UpperTriangular(SymTridiagonal(...)))` worked on 1.10 (regression in 1.11); `svdvals` fails on
every version.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `"cannot set
off-diagonal entry"` (#1865 `cumsum`, #1099 closed `B - B'`, #1090, #515), `UnitUpperTriangular
SymTridiagonal scalar`, `triu UnitUpperTriangular structured parent`, `Symmetric UpperTriangular product
ArgumentError`, `Symmetric Bidiagonal multiplication`, `UniformScaling triangular Hermitian`. No match.

Found by a differential probe of nested wrappers against the dense oracle. Reproducer:
`structured_parent_wrapper_ops_argumenterror.jl` (prints `REPRODUCED` on the affected versions).

Assisted-by: AI

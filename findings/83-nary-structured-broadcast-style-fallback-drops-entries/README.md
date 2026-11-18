# 83: a broadcast over three or more structured matrices silently drops entries (`B .+ U .+ B` returns a `Bidiagonal`): the two-argument `DefaultArrayStyle{2}` fallback is not sticky

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1910](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1910))

# Body

A broadcast over two structured matrices of incompatible structure correctly materialises a dense
result, but adding a third structured argument makes the result take the structure of that argument,
and the entries outside it are lost without any error:

```julia-repl
julia> using LinearAlgebra

julia> B = Bidiagonal([1.0, 2, 3], [4.0, 5], :U); U = UpperTriangular([1.0 2 3; 0 4 5; 0 0 6]);

julia> B .+ U                          # two arguments: dense, correct
3×3 Matrix{Float64}:
 2.0  6.0  3.0
 0.0  6.0  10.0
 0.0  0.0  9.0

julia> B .+ U .+ B                     # three arguments: a Bidiagonal — the (1,3) entry of U is gone
3×3 Bidiagonal{Float64, Vector{Float64}}:
 3.0  10.0    ⋅
  ⋅    8.0  15.0
  ⋅     ⋅   12.0

julia> Matrix(B) .+ Matrix(U) .+ Matrix(B)
3×3 Matrix{Float64}:
 3.0  10.0   3.0
 0.0   8.0  15.0
 0.0   0.0  12.0

julia> T = Tridiagonal([1.0, 2], [3.0, 4, 5], [6.0, 7]); T .+ U .+ T   # Tridiagonal, wrong
julia> ifelse.(B .== 0, U, B)                                           # Bidiagonal, wrong
julia> (+).(Diagonal([1.0, 2, 3]), U, T)                               # Diagonal, wrong
```

An enumeration over 12 wrappers of `a .+ b .+ a` gives a wrong result for 28 of 144 triples on
LinearAlgebra 1.13.0 and for **44 of 144 on the nightly**: JuliaLang/LinearAlgebra.jl#1607 added
broadcast styles for `Symmetric`/`Hermitian`, which creates new fallback pairs (`U .+ Symmetric .+ U`
now returns a wrong `UpperTriangular`; `SymTridiagonal .+ U .+ SymTridiagonal` threw an `ArgumentError`
on 1.13 and now silently returns a wrong `Tridiagonal`).

Mechanism (`src/structuredbroadcast.jl`): `BroadcastStyle(::StructuredMatrixStyle,
::StructuredMatrixStyle) = DefaultArrayStyle{2}()` for incompatible structures. Base resolves any
`AbstractArrayStyle` as winning over a `DefaultArrayStyle`, so the third structured argument re-imposes
its own `StructuredMatrixStyle`; `fzero` then sees only structured arguments, concludes the operation is
zero-preserving, and allocates the result in that structure. Returning the sticky
`StructuredMatrixStyle{Matrix}()` (already used a few lines above for the dense-compatible cases) would
fix it. This is the remaining part of JuliaLang/julia#33397 (PR 33506 only handled `Lower × Upper`) and
of JuliaLang/LinearAlgebra.jl#707 (`Bidiagonal` `:U × :L`). It is related to, but distinct from, the open
JuliaLang/LinearAlgebra.jl#1755, where *dense* arguments are absorbed by `fzero`; the fix proposed there
(#1722) does not change the style resolution and leaves this case wrong.

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.833
(LinearAlgebra 1.14.0, where more triples are affected) — long-standing and still present on master.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` and `JuliaLang/julia` issues and PRs
for `gives Diagonal`, `33397`, `DefaultArrayStyle`, `StructuredMatrixStyle{Matrix}`, `drops entries`,
`three argument broadcast`, `ifelse broadcast`, `nested broadcast structured`. #1755 / #1722 are the
nearest and are distinct (see above).

Found by a differential probe of structured broadcasting against the dense result. Reproducer:
`nary_structured_broadcast_drops_entries.jl` (prints `REPRODUCED`).

Assisted-by: AI

# 82: broadcasting or `copyto!` into a banded matrix that aliases its source gives wrong values (`T .= T'`, `copyto!(T, T')`, `D .= Diagonal(view(D.diag, end:-1:1))`)

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1909](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1909))

# Body

In-place assignment into a `Tridiagonal`, `Bidiagonal`, `SymTridiagonal` or `Diagonal` whose source
shares memory with the destination silently produces wrong values, where the same operation on a dense
`Matrix` is correct:

```julia-repl
julia> using LinearAlgebra

julia> T = Tridiagonal([1, 2], [3, 4, 5], [6, 7]);

julia> Matrix(T')
3×3 Matrix{Int64}:
 3  1  0
 6  4  2
 0  7  5

julia> T .= T'                         # wrong: the sub-diagonal was overwritten before being read
3×3 Tridiagonal{Int64, Vector{Int64}}:
 3  1  ⋅
 1  4  2
 ⋅  2  5

julia> T = Tridiagonal([1, 2], [3, 4, 5], [6, 7]); copyto!(T, T')   # also wrong
3×3 Tridiagonal{Int64, Vector{Int64}}:
 3  6  ⋅
 6  4  7
 ⋅  7  5

julia> D = Diagonal([1, 2, 3]); D .= Diagonal(view(D.diag, 3:-1:1)); D.diag   # expected [3, 2, 1]
3-element Vector{Int64}:
 3
 2
 3

julia> M = Matrix(Tridiagonal([1, 2], [3, 4, 5], [6, 7])); M .= M'; M == Matrix(Tridiagonal([1, 2], [3, 4, 5], [6, 7])')
true
```

`T .+= T'`, `T .= (T .+ T') ./ 2` (an in-place symmetrisation) and `broadcast!(identity, T, T')` are wrong
in the same way; `map!` is correct.

Mechanism: `transpose`/`adjoint` of a `Tridiagonal` share the band vectors with the parent.
`copyto!(dest::Tridiagonal, bc::Broadcasted{StructuredMatrixStyle})` (`src/structuredbroadcast.jl`)
writes `d`, then `du`, then `dl` without `Broadcast.preprocess`/`Base.unalias`, and
`_copyto_banded!(::Tridiagonal, ::Tridiagonal)` (`src/tridiag.jl`) copies `dl`, `d`, `du` one after the
other, also without unaliasing. JuliaLang/LinearAlgebra.jl#1844 (merged 2026-11-05) defined `dataids`
and `unaliascopy` for the banded types, which makes `Base.mightalias(T, T')` true, but the banded
`copyto!` methods never call `unalias`, so the result is unchanged (verified on a nightly that includes
#1844; the dense destination path, which does unalias, is correct).

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.833
(LinearAlgebra 1.14.0, which includes #1844) — long-standing and still present on master.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `alias`,
`aliasing`, `unalias`, `dataids`, `copyto! Tridiagonal`, `broadcast! aliasing`, `in-place transpose`;
`JuliaLang/julia` `Tridiagonal broadcast alias`. Only #1844 is related, and it does not cover banded
destinations.

Found by a differential probe of structured broadcasting against the dense result. Reproducer:
`banded_destination_broadcast_aliasing.jl` (prints `REPRODUCED`).

Assisted-by: AI

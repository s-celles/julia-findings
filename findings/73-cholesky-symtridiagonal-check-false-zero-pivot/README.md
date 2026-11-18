# 73: `cholesky(::SymTridiagonal; check=false)` throws `ZeroPivotException` on a zero diagonal pivot, so `isposdef(::SymTridiagonal)` throws instead of returning `false` — regression in LinearAlgebra 1.13

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

With `check=false`, `cholesky` is documented to return a factorization whose `issuccess` is `false`
rather than throwing. The banded path breaks this contract on a zero diagonal pivot, and `isposdef`
(which calls `cholesky(…; check=false)`) therefore throws instead of answering `false`:

```julia-repl
julia> using LinearAlgebra

julia> S = SymTridiagonal([1.0, 0.0, 0.0], [0.0, 1.0]);

julia> issuccess(cholesky(Matrix(S); check=false))      # dense: honours check=false
false

julia> cholesky(S; check=false)
ERROR: ZeroPivotException: factorization encountered one or more zero pivots. ...

julia> isposdef(SymTridiagonal([0.0, 1.0], [1.0]))
ERROR: ZeroPivotException: ...

julia> isposdef(Matrix(SymTridiagonal([0.0, 1.0], [1.0])))
false
```

Mechanism: `_chol!(A::Bidiagonal, ::Type{T})` (`src/bidiag.jl:1494`) — which `cholesky` of
`SymTridiagonal`/`Tridiagonal` and of `Symmetric`/`Hermitian{<:BiTriSym}` go through, for every
element type — contains `iszero(dv[i]) && throw(ZeroPivotException(i))`, an unconditional throw
that ignores `check`. The sub-block path in the same function correctly propagates `info != 0`
instead, which is why the pull request's own `check=false` tests (which exercise that path) pass.
The function was introduced by JuliaLang/LinearAlgebra.jl#1409 ("Add bidiagonal cholesky version",
merged 2025-08-12, in the 1.13 line). JuliaLang/LinearAlgebra.jl#1880 (merged 2026-11-14) later fixed
only the empty `n == 0` `BoundsError` of this function (catalogue entry 23 / upstream #1874) and did
not touch the zero-pivot throw.

Scope (confirmed independently by a second, pivot-adversarial probe): the throw fires whenever a
leading diagonal element `dv[i]`, `i < n`, is exactly zero, for `SymTridiagonal`, `Tridiagonal` and
`Symmetric`/`Hermitian{<:BiTriSym}`, with any element type (`Int`, `Rational`, `Float64` all throw).
A plain `Bidiagonal` input is NOT affected (`isposdef` returns `false`, `check=false` gives
`issuccess == false`), so the throw is reached on the tridiagonal-to-bidiagonal path.

Versions checked: **regression** — on LinearAlgebra 1.11.0 (Julia 1.11.9) and 1.12.0 (Julia 1.12.6)
`cholesky(S; check=false)` returns `issuccess == false` and `isposdef` returns `false`; on 1.13.0
(Julia 1.13.3) both throw. Backport candidate.

Deduplication searches (2026-11-17): in this catalogue, `isposdef` and `cholesky SymTridiagonal`
match only entry 23 (empty banded `BoundsError`). Upstream, `isposdef SymTridiagonal throws`,
`isposdef ZeroPivotException` and `cholesky check=false ZeroPivotException Bidiagonal` surface only
JuliaLang/LinearAlgebra.jl#1874/#1880 (the empty case); no issue covers the non-empty zero-pivot
`check=false` contract.

Found by a differential factorization-contract probe (exception/`issuccess` consistency of
`cholesky(…; check=false)` between structured and dense). Reproducer:
`n2_cholesky_symtridiagonal_check_false_zero_pivot.jl` (prints `REPRODUCED`).

Assisted-by: AI

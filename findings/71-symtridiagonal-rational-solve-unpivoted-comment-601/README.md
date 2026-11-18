# 71: Comment on JuliaLang/LinearAlgebra.jl#601: `\` and `inv` of a `SymTridiagonal` with `Rational` elements use an unpivoted factorization, throwing on an invertible matrix and returning `1//0` on a singular one

- Kind: comment for `JuliaLang/LinearAlgebra.jl#601`
- Status: posted (comment on [JuliaLang/LinearAlgebra.jl#601](https://github.com/JuliaLang/LinearAlgebra.jl/issues/601#issuecomment-6972835673))

# Body

`\` and `inv` of a `SymTridiagonal` dispatch to its `LDLᵀ` factorization
(`ldlt`), which does not pivot. A zero diagonal pivot therefore breaks the
structured path while the dense `Matrix` path, which uses pivoted `lu`, stays
correct. With `Rational` elements this produces two wrong outcomes:

On an **invertible** matrix the structured solve and `inv` throw
`ZeroPivotException`:

```julia-repl
julia> using LinearAlgebra

julia> S = SymTridiagonal(Rational{Int}[0, 0], Rational{Int}[1]); Matrix(S)
2×2 Matrix{Rational{Int64}}:
 0//1  1//1
 1//1  0//1

julia> det(S)            # invertible
-1//1

julia> Matrix(S) \ Rational{Int}[1, 1]
2-element Vector{Rational{Int64}}:
 1//1
 1//1

julia> S \ Rational{Int}[1, 1]
ERROR: ZeroPivotException: factorization encountered one or more zero pivots. ...

julia> inv(S)
ERROR: ZeroPivotException: ...
```

On a **singular** matrix the dense path raises `SingularException`, but the
structured path divides by the zero pivot in exact arithmetic and returns
`1//0` (rational infinities) instead of raising:

```julia-repl
julia> S2 = SymTridiagonal(Rational{Int}[-3, -2, 1], Rational{Int}[-3, 1]); det(S2)
0//1

julia> Matrix(S2) \ Rational{Int}[1, 0, 1]
ERROR: SingularException(2)

julia> S2 \ Rational{Int}[1, 0, 1]
3-element Vector{Rational{Int64}}:
  1//0
 -1//0
  1//0
```

Mechanism: `A::SymTridiagonal \ b` and `inv(A)` go through
`ldlt(A)` / `ldlt!` (`LinearAlgebra/src/ldlt.jl`), an unpivoted `LDLᵀ`. `ldlt!`
raises `ZeroPivotException` as soon as a computed diagonal pivot `d` is zero,
which happens for the invertible `[0 1; 1 0]` because its first pivot is `0`
even though the matrix is non-singular (a symmetric indefinite matrix needs
2×2 pivoting, which `SymTridiagonal` does not do). When the factorization does
run to completion over `Rational`, a zero pivot yields `d = 1//0` and the
solve propagates `x//0` instead of detecting the singularity. The dense
`Matrix{Rational}` path factorizes with pivoted `lu`, which solves the
invertible case exactly and raises `SingularException` on the singular one.

This is the exact-arithmetic / `Rational` face of the long-standing
JuliaLang/LinearAlgebra.jl#601, where `inv(SymTridiagonal([1.,0.,0.],[0.,1.]))`
returns all-`NaN` in floating point. The rational cases make the two failure
modes crisp: a hard error on an invertible matrix, and a silent `1//0` on a
singular one.

Versions checked: reproduced on LinearAlgebra with Julia 1.10.11, 1.11.9,
1.12.6 and 1.13.3 (long-standing across all current release lines).

Deduplication searches (2026-11-17): in this catalogue, `SymTridiagonal`
matches only entry 60 (`det` narrow integer), entry 23 (`isposdef` empty) and
entry 17 (empty-trace) — none cover `\`/`inv`. On the upstream tracker,
`SymTridiagonal ZeroPivotException`, `SymTridiagonal singular solve` and
`SymTridiagonal rational` surface JuliaLang/LinearAlgebra.jl#601 (the float
`inv` case, open since 2019), of which this is the same root cause; no separate
issue covers the rational `\`/`inv` behaviour.

Found by a differential structured-vs-dense probe (solve/inv of structured
matrices compared against the dense oracle). Reproducer:
`symtridiagonal_rational_solve_pivot.jl` (asserts both failure modes and the
correct dense results; prints `REPRODUCED`).

Assisted-by: AI

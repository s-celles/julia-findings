# 96: `cond` of an all-zero integer `Diagonal` throws `InexactError: Int64(Inf)` (`cond(Diagonal([0, 0]))`), while the dense matrix, a `Float64` `Diagonal` and a `Diagonal` with one non-zero entry return `Inf`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not filed as an issue (trivial one-line fix, per the LinearAlgebra.jl#1912 guidance); fix proposed in [JuliaLang/LinearAlgebra.jl#1929](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1929) (open, 2026-11-19)

# Body

```julia-repl
julia> using LinearAlgebra

julia> cond(zeros(Int, 2, 2))
Inf

julia> cond(Diagonal([0, 2]))
Inf

julia> cond(Diagonal([0, 0]))
ERROR: InexactError: Int64(Inf)

julia> cond(Diagonal([0, 0]), 1)
Inf
```

Mechanism (`src/dense.jl`, `cond(A::AbstractMatrix, p::Real=2)`):

```julia
        v = svdvals(A)
        maxv = maximum(v)
        return iszero(maxv) ? oftype(real(maxv), Inf) : maxv / minimum(v)
```

`svdvals(::Diagonal{<:Number})` is `sort!(abs.(D.diag), rev=true)` and keeps the integer element
type (the dense `svdvals` returns a floating-point vector), so `oftype(0, Inf)` fails; the non-zero
branch divides and therefore returns a `Float64`. Introduced with the singular-matrix handling of
JuliaLang/julia#33548. Fix: take the type of the division, `oftype(real(maxv) / one(real(maxv)),
Inf)`, which keeps the current `1//0` for a rational `Diagonal`.

Versions checked: Julia 1.10.13, 1.11.9, 1.12.7, 1.13.3 and nightly 1.15.0-DEV.834 (LinearAlgebra
1.14.0).

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `cond Diagonal`,
`cond InexactError`, `cond zero` — only #664 (closed, 2019: `cond(A, 1)` of a singular matrix, the
origin of the `iszero(maxv)` branch) and #1875 (this catalogue, `svdvals` of an integer `Diagonal`
wrapping on `typemin`).

Found by a structured-versus-dense differential probe. Reproducer:
`cond_zero_integer_diagonal_inexacterror.jl` (prints `REPRODUCED`).

Assisted-by: AI

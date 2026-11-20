# 97: `A^p` for a real diagonal dense matrix with a negative entry and an integer-valued `Float64` exponent returns a `ComplexF64` matrix (`[-1.0 0; 0 2]^2.0`), while the non-diagonal matrix, `Diagonal` and Julia 1.12 return `Float64` — regression in LinearAlgebra 1.13

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not filed as an issue (trivial one-line fix, per the LinearAlgebra.jl#1912 guidance); fixed upstream by [JuliaLang/LinearAlgebra.jl#1930](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1930) (merged 2026-11-19)

# Body

```julia-repl
julia> using LinearAlgebra

julia> [-1.0 0; 0 2]^2.0
2×2 Matrix{ComplexF64}:
 1.0-0.0im  0.0+0.0im
 0.0+0.0im  4.0+0.0im

julia> [-1.0 1; 0 2]^2.0                               # non-diagonal: Float64
2×2 Matrix{Float64}:
 1.0  1.0
 0.0  4.0

julia> Diagonal([-1.0, 2])^2.0
2×2 Diagonal{Float64, Vector{Float64}}:
 1.0   ⋅
  ⋅   4.0

julia> [-1.0 0; 0 2]^-1.0
2×2 Matrix{ComplexF64}:
 -1.0-0.0im  0.0+0.0im
  0.0+0.0im  0.5-0.0im
```

Mechanism (`src/dense.jl`, `^(A::AbstractMatrix{T}, p::Real)`):

```julia
    if isdiag(A)
        if T <: Real && any(<(0), diagview(A))
            return applydiagonal(x -> complex(x)^p, A)
```

The diagonal fast path promotes negative entries to complex so that fractional powers work (the
pre-1.13 code threw `DomainError` on `[-1.0 0; 0 2]^0.5`), but it returns the complex container even
when the result is real. The general path converts back (`schurpow`: `if eltype(A) <: Real &&
isreal(retmat) return real(retmat)`), and integer-valued exponents of a non-diagonal matrix never
leave the real numbers (`isinteger(p) && return integerpow(A, p)`). Introduced by
JuliaLang/LinearAlgebra.jl#1360 ("type stability of matrix functions", LinearAlgebra 1.13). Fix:
apply the same `isreal` check to the diagonal result.

Versions checked: `Float64` on Julia 1.12.7 (and 1.10.13/1.11.9); `ComplexF64` on 1.13.3 and nightly
1.15.0-DEV.834 (LinearAlgebra 1.14.0).

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `matrix power
diagonal complex`, `applydiagonal`, `^ negative diagonal` — only PR #1360 (the cause).

Found by a structured-versus-dense differential probe over the matrix functions. Reproducer:
`real_power_diagonal_negative_complex_return.jl` (prints `REPRODUCED`).

Assisted-by: AI

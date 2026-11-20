# 94: `acos`/`asin`/`acosh`/`atanh` of a real diagonal dense matrix with entries outside the real domain throw `DomainError` instead of returning the complex principal value (`acosh([0.5 0; 0 2.0])` throws, `acosh([0.5 1; 0 2.0])` does not) — regression in LinearAlgebra 1.12

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1926](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1926)); fixed upstream by [JuliaLang/LinearAlgebra.jl#1938](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1938) (merged 2026-11-20)

# Body

```julia-repl
julia> using LinearAlgebra

julia> acosh([0.5 1; 0 2.0])                          # non-diagonal: complex principal value
2×2 Matrix{ComplexF64}:
 -5.55112e-17+1.0472im  0.877972-0.698132im
          0.0+0.0im      1.31696+0.0im

julia> acosh(Symmetric([0.5 0; 0 2.0]))               # Symmetric path: complex principal value
2×2 Symmetric{ComplexF64, Matrix{ComplexF64}}:
 0.0+1.0472im      0.0+0.0im
 0.0+0.0im     1.31696+0.0im

julia> acosh([0.5 0; 0 2.0])                          # diagonal: DomainError
ERROR: DomainError with 0.5:
acosh(x) is only defined for x ≥ 1.

julia> asin([2.0 0; 0 2.0])
ERROR: DomainError with 2.0:
asin(x) is not defined for |x| > 1.

julia> acos([2.0;;])
ERROR: DomainError with 2.0:
acos(x) not defined for |x| > 1

julia> atanh([2.0;;])                                 # same for atanh (all versions)
ERROR: DomainError with 2.0:
atanh(x) is only defined for |x| ≤ 1.

julia> sqrt([-1.0 0; 0 2.0])                          # the square root/logarithm fast path promotes
2×2 Matrix{ComplexF64}:
 0.0+1.0im      0.0+0.0im
 0.0+0.0im  1.41421+0.0im
```

Mechanism (`src/dense.jl`): since JuliaLang/julia#56483 ("Check `isdiag` in dense trig functions",
LinearAlgebra 1.12) each inverse trigonometric/hyperbolic matrix function starts with

```julia
    if isdiag(A)
        return applydiagonal(acosh, A)
```

which applies the real scalar function to the diagonal. The `sqrt`, `log` and `^` fast paths check
for negative entries and use `sqrt ∘ complex` (resp. `log ∘ complex`, `complex(x)^p`) when needed; the
`acos`/`asin`/`acosh`/`atanh` fast paths have no such domain check, so a diagonal matrix whose entries
lie outside the real domain throws, whereas the non-diagonal case (Schur{Complex} path) and the
`Hermitian`/`Symmetric` methods (which promote since LinearAlgebra 1.13) return the complex principal
value, and Julia 1.10/1.11 returned it for these very inputs.

Versions checked: `acos`/`asin`/`acosh` of the diagonal inputs return the complex result on Julia
1.10.13 and 1.11.9 and throw on 1.12.7, 1.13.3 and nightly 1.15.0-DEV.834 (LinearAlgebra 1.14.0).
`atanh([2.0;;])` throws on every version, while `atanh(Symmetric([2.0;;]))` returns the complex
principal value since 1.13 (`DomainError` on 1.12).

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `acosh
DomainError`, `asin matrix diagonal`, `applydiagonal` — none relevant; #1156/#1203/#1352 handled the
negative-entry promotion of `sqrt`/`log`/`cbrt`/`^` only.

Found by a structured-versus-dense differential probe over the matrix functions. Reproducer:
`inverse_trig_diagonal_domainerror.jl` (prints `REPRODUCED`).

Assisted-by: AI

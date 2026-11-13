# 23: `isposdef` of an empty `Bidiagonal`, `Tridiagonal` or `SymTridiagonal` throws `BoundsError`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

`isposdef` of an empty `Bidiagonal`, `Tridiagonal` or `SymTridiagonal` throws `BoundsError`

# Body

```julia-repl
julia> using LinearAlgebra

julia> isposdef(zeros(0, 0))
true

julia> isposdef(Diagonal(Float64[]))
true

julia> isposdef(SymTridiagonal(Float64[], Float64[]))
ERROR: BoundsError: attempt to access 0-element Vector{Float64} at index [0]

julia> isposdef(Bidiagonal(Float64[], Float64[], :U))
ERROR: BoundsError: attempt to access 0-element Vector{Float64} at index [0]
```

The generic `isposdef(A::AbstractMatrix)` goes through
`cholesky(Hermitian(A); check=false)`, which for banded matrices ends in the
`SymTridiagonal` `ldlt` kernel; that kernel indexes the last diagonal element
without handling `n == 0`. `Tridiagonal` fails the same way. The dense and
`Diagonal` paths return `true` for the empty matrix.

Reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 /
LinearAlgebra 1.14.0. Searches for `isposdef empty` found no matching issue or
PR (2026-11-13). Related empty-matrix reports: #1707 (`tr` of an empty
`Diagonal`, fixed), #508 (`tril`/`triu` offsets on empty band matrices).

Assisted-by: AI

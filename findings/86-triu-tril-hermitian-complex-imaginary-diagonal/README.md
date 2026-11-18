# 86: `triu` and `tril` of a complex `Hermitian` keep the imaginary part of the stored diagonal, which the wrapper itself exposes as real

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

A `Hermitian` exposes a real diagonal (`getindex` takes `real(...)` on the diagonal), but `triu`/`tril`
of a complex `Hermitian` operate on the stored data and keep the imaginary parts:

```julia-repl
julia> using LinearAlgebra

julia> H = Hermitian(ComplexF64[1+2im 3; 0 4-1im], :U); Matrix(H)
2×2 Matrix{ComplexF64}:
 1.0+0.0im  3.0+0.0im
 3.0-0.0im  4.0+0.0im

julia> triu(H)                       # diagonal 1+2im, 4-1im instead of 1, 4
2×2 Matrix{ComplexF64}:
 1.0+2.0im  3.0+0.0im
 0.0+0.0im  4.0-1.0im

julia> triu(Matrix(H))
2×2 Matrix{ComplexF64}:
 1.0+0.0im  3.0+0.0im
 0.0+0.0im  4.0+0.0im

julia> tril(H)
2×2 Matrix{ComplexF64}:
 1.0-2.0im  0.0+0.0im
 3.0+0.0im  4.0+1.0im
```

The same holds with `Tridiagonal`, `Diagonal`, `SubArray` and `Adjoint` parents (e.g.
`triu(Hermitian(Tridiagonal(...), :L))` returns a `Tridiagonal` whose diagonal keeps the imaginary
part). A side effect of the same code: for `Bool` elements `triu(H, -1)` returns an `Int64` matrix (the
"sum of two triangles" branch).

Mechanism (`src/symmetric.jl`, `triu`/`tril(A::Hermitian, k)`): the methods build the result from
`A.data` / `copy(A.data')` without taking the real part of the diagonal, whereas `getindex` does. The
open JuliaLang/LinearAlgebra.jl#1318 (out-of-place `triu`/`tril`) does not touch this.

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.834
(LinearAlgebra 1.14.0), and on the current LinearAlgebra.jl master — long-standing.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `triu Hermitian
imaginary diagonal`, `triu Hermitian`, `tril Hermitian`, `Hermitian imaginary diagonal` (#765, closed,
is `cholesky`), `Hermitian diagonal real part ignored`; this catalogue `Hermitian triu`. No match.

Found by a differential probe of nested wrappers against the dense oracle. Reproducer:
`triu_tril_hermitian_complex_imaginary_diagonal.jl` (prints `REPRODUCED`).

Assisted-by: AI

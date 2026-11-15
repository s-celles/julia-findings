# 66: `ldiv!(A::Tridiagonal, B)` silently overwrites `A` with its LU factors; the `ldiv!` docstring does not say so

- Kind: issue for `JuliaLang/LinearAlgebra.jl` (documentation)
- Status: not posted

# Body

`ldiv!(A, B)` with a `Tridiagonal` left argument is implemented as
`ldiv!(lu!(A), B)` (JuliaLang/julia#50535), so `A` is destroyed while `B`
receives the correct solution. Every other structured kind accepted by
`ldiv!` (`Diagonal`, `Bidiagonal`, `SymTridiagonal`, the triangular
wrappers) leaves `A` intact, and the docstring only says that "certain
structured matrix types, such as `Diagonal` and `UpperTriangular`, are
permitted, as these are already in factored form":

```julia-repl
julia> using LinearAlgebra

julia> A = Tridiagonal([-1.5], [-1.5, 1.8333333333333335], [-1.0]); A0 = copy(A);

julia> C = [2.25 0.0; -1.25 0.0]; ldiv!(A, C) ≈ Matrix(A0) \ [2.25 0.0; -1.25 0.0]
true

julia> A
2×2 Tridiagonal{Float64, Vector{Float64}}:
 -1.5  -1.0
 -1.5   2.83333          # A0[2, 2] was 1.83333

julia> S = SymTridiagonal([2.0, 3.0], [1.0]); S0 = copy(S); ldiv!(S, [1.0 2.0; 3.0 4.0]); S == S0
true
```

The pull request that added the method notes that it "needs to overwrite the
tridiagonal matrix", so this is intended; a sentence in the `ldiv!`
docstring (and perhaps in the `Tridiagonal` documentation) would spare users
who reuse `A` after the solve, as a differential probe of this catalogue
did. LinearAlgebra 1.13.0 (Julia 1.13.3) and 1.14.0 (nightly
1.15.0-DEV.720).

Found by `experiments/phase4/structured_solve_contracts.jl`, which reuses
the left matrix across contracts. Reproducer:
`ldiv_tridiagonal_overwrites_matrix.jl` (prints REPRODUCED when `A` is
modified).

Assisted-by: AI

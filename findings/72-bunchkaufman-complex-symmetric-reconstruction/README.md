# 72: `Matrix(F::BunchKaufman)` reconstructs a complex *symmetric* matrix wrongly — `AbstractMatrix(::BunchKaufman)` uses the adjoint where the symmetric case needs the transpose

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

`Matrix(bunchkaufman(A))` (via `AbstractMatrix(::BunchKaufman)`) returns the wrong matrix when `A`
is complex **symmetric** (not Hermitian). The factorization itself is sound: `F \ b`, `inv(F)` and
`det(F)` all agree with the dense path. Only the reconstruction is wrong:

```julia-repl
julia> using LinearAlgebra

julia> A = Symmetric([1 im; im 2]); F = bunchkaufman(A);

julia> Matrix(F)                     # should equal A
2×2 Matrix{Complex{Rational{BigInt}}}:
 2//1+0//1*im   0//1+1//1*im
 0//1-1//1*im   2//1+0//1*im

julia> Matrix(A)
2×2 Matrix{Complex{Int64}}:
 1+0im  0+1im
 0+1im  2+0im

julia> isapprox(ComplexF64.(F \ [1, 1]), Matrix(A) \ [1, 1])   # the solve is correct
true

julia> Matrix(bunchkaufman(Hermitian([1 im; -im 2]))) == [1 im; -im 2]   # Hermitian: correct
true
```

Mechanism: `src/bunchkaufman.jl:240`,
`AbstractMatrix(B::BunchKaufman) = B.uplo == 'U' ? B.P'B.U*B.D*B.U'B.P : B.P'B.L*B.D*B.L'B.P`,
conjugates the factor (`B.U'`, `B.L'`). That is the Hermitian reconstruction `P'UDU^H P`; a complex
symmetric Bunch-Kaufman factorization is `P'UDU^T P` and needs `transpose(B.U)`. The same accessor is
reached for `Rational`/generic and for LAPACK `ComplexF64`/`ComplexF32` inputs, both `uplo` values, rook
or not. The method was added by JuliaLang/LinearAlgebra.jl#1466 ("Overload array constructors for
BunchKaufman"); before it (LinearAlgebra 1.11) `Matrix(::BunchKaufman)` was a `MethodError`.

Versions checked: wrong on LinearAlgebra 1.12.0 (Julia 1.12.6) and 1.13.0 (Julia 1.13.3); `MethodError`
(no accessor) on 1.11.9 and 1.10.11.

Deduplication searches (2026-11-17): in this catalogue, `bunchkaufman` matches entries 20 and 67
(result types / `MethodError` in `generic_adr1!`), neither about reconstruction. Upstream,
`bunchkaufman complex symmetric` and `BunchKaufman transpose adjoint Symmetric` surface
JuliaLang/LinearAlgebra.jl#903 (closed 2025-05): `adjoint(::BunchKaufman)` *threw* "adjoint not
implemented for complex symmetric matrices" — a thrown error, not a silently wrong reconstruction; no
issue covers `Matrix(F) != A`.

Found by a differential factorization-contract probe (exact reconstruction `Matrix(F) == A` on
structured and dense exact-type matrices). Reproducer:
`n1_bunchkaufman_complex_symmetric_reconstruction.jl` (asserts the wrong reconstruction, the correct
solve/det, and the Hermitian control; prints `REPRODUCED`).

Assisted-by: AI

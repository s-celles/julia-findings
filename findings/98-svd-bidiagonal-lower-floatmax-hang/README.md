# 98: `svd` of a lower `Bidiagonal` with finite entries never returns on x86_64 (`svd(Bidiagonal([1.0, floatmax(), 3.0], [2.0, floatmax()], :L))` loops forever in LAPACK `dbdsqr`), while the upper form, the dense matrix, `svdvals`, Julia 1.10 and aarch64 return — the finite input bypasses the Inf/NaN checks of #1798

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1927](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1927)); fix proposed in [JuliaLang/LinearAlgebra.jl#1937](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1937) (open, 2026-11-20)

# Body

```julia-repl
julia> using LinearAlgebra

julia> fm = floatmax(Float64); dv = [1.0, fm, 3.0]; ev = [2.0, fm];

julia> svd(Bidiagonal(dv, ev, :U)).S                 # upper form: returns
3-element Vector{Float64}:
 Inf
   2.6157846278341124
   0.8109690381184441

julia> svd(Matrix(Bidiagonal(dv, ev, :L))).S         # dense: returns
3-element Vector{Float64}:
 0.0
 0.0
 0.0

julia> svdvals(Bidiagonal(dv, ev, :L))               # lower form, values only: returns
3-element Vector{Float64}:
 Inf
   0.0
   0.0

julia> svd(Bidiagonal(dv, ev, :L))                   # never returns
^C  (not interruptible: the loop is inside LAPACK)
```

The singular values are in the overflow regime (the matrix norm exceeds `floatmax`), so garbage
results are expected; the problem is the hang on a finite input, which is not interruptible with
Ctrl-C and which the checks added by #1798 ("Check for Infs and NaNs before LAPACK's SVD routines") do
not catch, because every entry is finite. `Float32` behaves the same with `floatmax(Float32)`; the
2×2 cases, a single `floatmax` entry, `floatmax()/2` or `1e308` all return.

Mechanism: `svd!(::Bidiagonal)` calls `LAPACK.bdsdc!(uplo, 'I', dv, ev)` (`src/bidiag.jl`). For a
lower bidiagonal, `dbdsdc` → `dlasdq` first rotates the matrix to upper bidiagonal form; with
`dv[2] = ev[2] = floatmax` the rotation overflows to `Inf`/`NaN`, and `dbdsqr` then loops forever
because its convergence threshold becomes `NaN` — the mechanism described in
Reference-LAPACK/lapack#1409 ("xBDSQR loops forever when xGESDD is given a matrix containing Inf
(THRESH becomes NaN)"), reached here from finite data. The backtrace at the kill point is
`dbdsqr_64_ ← dlasdq_64_ ← dbdsdc_64_ ← bdsdc! (lapack.jl) ← svd! (bidiag.jl)`. Without singular
vectors (`'N'`, i.e. `svdvals`) `dbdsdc` takes the `dlasq1` path and returns `NaN`s instead.

Versions checked (x86_64): returns on Julia 1.10.13 (OpenBLAS 0.3.23, LAPACK 3.11.0) with
`S = [Inf, 2.236, 1.225]`; hangs on 1.11.9 (OpenBLAS 0.3.27), 1.12.7 (0.3.29), 1.13.3 and nightly
1.15.0-DEV.834 (LinearAlgebra 1.14.0, OpenBLAS 0.3.30), all LAPACK 3.12.0, on an Intel host (`Haswell`
kernels) and an AMD host (`Zen` kernels) alike. On aarch64, the very same Julia 1.13.3 / OpenBLAS 0.3.30 /
LAPACK 3.12.0 (`neoversen1` kernels) returns in 30 ms with `S = [Inf, 2.236, 1.225]`, as 1.10 does on
x86_64 — so the loop depends on the optimized x86_64 kernels used during the rotation (the reference
Fortran being identical), and the finite-input case reaches the state described in LAPACK #1409 only
there. Reference-LAPACK/lapack#1390 (merged 2026-09-07, "Let an exact zero always split the matrix in
xBDSQR so that an Inf cannot hang it") targets the same loop and is not in any shipped OpenBLAS yet.

Possible mitigations on the Julia side, for the maintainers to judge: compute the SVD of a lower
`Bidiagonal` through its transpose (`svd(B')` swaps `U` and `V`), which takes the upper path that
returns; or extend the #1798 pre-check to the norm of the input.

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `svd Bidiagonal
hang`, `bdsdc`, `dbdsqr`, `svd hangs`, `Bidiagonal floatmax` — only #1798 (Inf/NaN guard), #1809
(script checking LAPACK behaviour on Inf/NaN), #1817 (`svd(::Bidiagonal)` keyword arguments);
`Reference-LAPACK/lapack` — #1409 (open, Inf input), PR #1390 (merged), #1392 (NaN input);
`OpenMathLib/OpenBLAS` `svd hang`, `bdsqr` — only #1490 (closed, 2018, unrelated).

Found by a structured-versus-dense differential probe over the matrix functions (timeout triage).
Reproducer: `svd_bidiagonal_lower_floatmax_hang.jl` (runs the hanging call in a child process killed
after 60 s; prints `REPRODUCED`).

Assisted-by: AI

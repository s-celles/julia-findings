# 69: `sylvester` and `lyap` overflow the stack for `Float16`, `ComplexF16`, `BigFloat` and `Rational{BigInt}` matrices

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: fixed on nightly — reported independently by a maintainer as [JuliaLang/LinearAlgebra.jl#1884](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1884) and fixed by [JuliaLang/LinearAlgebra.jl#1887](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1887) (merged 2026-11-16); `sylvester`/`lyap` now throw `ArgumentError` instead of overflowing the stack

# Body

The generic methods promote their arguments to `float(eltype)` and call
themselves again, but only `BlasFloat` element types have a terminal
method, so any element type whose float type is not a BLAS type recurses
until the stack overflows:

```julia-repl
julia> using LinearAlgebra

julia> A = Float16[3 1; 0 2];

julia> lyap(A, A)
ERROR: StackOverflowError:

julia> sylvester(A, A, A)
ERROR: StackOverflowError:

julia> lyap(BigFloat[3 1; 0 2], BigFloat[3 1; 0 2])
ERROR: StackOverflowError:
```

The same happens for `ComplexF16`, `Complex{BigFloat}` and
`Rational{BigInt}` (whose float type is `BigFloat`); `Float32`, `Float64`,
`Int` and `Rational{Int}` (promoted to `Float64`) work. In
`src/dense.jl`:

```julia
function sylvester(A::AbstractMatrix, B::AbstractMatrix, C::AbstractMatrix)
    T = promote_type(float(eltype(A)), float(eltype(B)), float(eltype(C)))
    return sylvester(copy_similar(A, T), copy_similar(B, T), copy_similar(C, T))
end
```

and likewise for `lyap`. A guard that throws a `MethodError` (or an
`ArgumentError` naming the unsupported element type) when `T` is not a
`BlasFloat`, or a generic fallback (for example through `schur` on
`Float16` promoted to `Float32`, as `eigvals` does), would avoid the crash.
Same on LinearAlgebra 1.13.0 (Julia 1.13.3) and 1.14.0 (nightly
1.15.0-DEV.720).

Found while scanning LinearAlgebra functions on non-BLAS element types for
the catalogue's probes. Reproducer: `sylvester_lyap_stack_overflow.jl`
(prints REPRODUCED when a `StackOverflowError` is raised).

Assisted-by: AI

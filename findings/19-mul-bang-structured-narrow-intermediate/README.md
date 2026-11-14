# 19: `mul!` into a wider destination: structured matrices wrap in the input type, dense matrices accumulate in the destination type

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1870](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1870))

# Title

`mul!` into a wider destination: structured matrices wrap in the input type, dense matrices accumulate in the destination type

# Body

```julia-repl
julia> using LinearAlgebra

julia> D = Diagonal(Int8[127, 1]); B = Int8[2 0; 0 1];

julia> mul!(zeros(Int, 2, 2), D, B)
2×2 Matrix{Int64}:
 -2  0
  0  1

julia> mul!(zeros(Int, 2, 2), Matrix(D), B)
2×2 Matrix{Int64}:
 254  0
   0  1
```

The dense `generic_matmatmul!` path promotes each product to the element type
of `C` before accumulating, so `127 * 2` is computed as `254`. The structured
kernels (`Diagonal`, `Bidiagonal`, `Tridiagonal`, `SymTridiagonal`, the four
triangular wrappers, and their matrix-vector variants) multiply in the input
element type and only then store into `C`, so the same product wraps to `-2`.

The two paths also disagree when the destination is narrow and a scalar is
involved:

```julia-repl
julia> x = Int8[2, 1];

julia> mul!(similar(x), D, x, 2, 0)
2-element Vector{Int8}:
 -4
  2

julia> mul!(similar(x), Matrix(D), x, 2, 0)
ERROR: InexactError: trunc(Int8, 508)
```

and for `UInt64` inputs into an `Int` destination, where the dense path throws
`InexactError: convert(Int64, 0xfffffffffffffffe)` while the structured path
returns a wrapped value.

The same probe on SparseArrays shows the third convention: `mul!(y, A::SparseMatrixCSC, x, 1, 1)` with
an `Int8` destination throws `InexactError: trunc(Int8, 256)` where the dense
path wraps to `Int8[1, 2]`. The dense three-argument matrix-vector `mul!` itself changed between
1.13.3 (wraps, `[-1, 1]`) and the nightly (accumulates in the destination, `[255, 1]`), so
the structured kernels are now the odd ones out.

I do not think either behavior is documented. A user who passes a wider `C`
presumably wants the wider accumulation; at least the two paths should agree.

Observed on a differential sweep of all structured wrappers: 28 wrapper-pair
groups for `mul!(C, A, B)` and 8 for `mul!(y, A, x)` with `Int8`, `UInt8`
and `Int16` inputs give different values, and 27 more groups with `UInt64`
inputs or the five-argument form differ on wrap versus `InexactError`. Reproduces on Julia 1.13.3 /
LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 / LinearAlgebra 1.14.0.
Searches for `mul! overflow`, `mul! Int8`, `mul! wider destination promote`
and `mul! overflow structured` found no matching issue or PR (2026-11-13).

Assisted-by: AI

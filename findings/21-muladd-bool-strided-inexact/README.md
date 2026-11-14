# 21: `muladd` on `Matrix{Bool}` throws `InexactError` where `A*B + C` and the structured methods return `Int`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1872](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1872))

# Title

`muladd` on `Matrix{Bool}` throws `InexactError` where `A*B + C` and the structured methods return `Int`

# Body

```julia-repl
julia> using LinearAlgebra

julia> B = Bool[true true; true true];

julia> B * B + B
2×2 Matrix{Int64}:
 3  3
 3  3

julia> muladd(UpperTriangular(B), B, B)
2×2 Matrix{Int64}:
 3  3
 2  2

julia> muladd(B, B, B)
ERROR: InexactError: Bool(3)
```

The strided-matrix `muladd` method computes
`T = promote_type(eltype(A), eltype(B), eltype(z))`, which is `Bool` here,
allocates `C = similar(A, T, ...)`, and then calls `mul!(C, A, B, true, true)`;
the first sum of two `true*true` products cannot be stored in a `Bool`. The
generic `AbstractMatrix` method computes `A * y` first and broadcasts `+ z`,
which gives `Int`. For every other integer type the difference is invisible
because `Int8*Int8 + Int8` stays `Int8`; `Bool` is the only `Number` whose
products promote.

Reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 /
LinearAlgebra 1.14.0. Searches for `muladd Bool` found no matching issue or PR
(2026-11-13).

Assisted-by: AI

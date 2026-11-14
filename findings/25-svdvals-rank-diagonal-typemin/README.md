# 25: `svdvals` of an integer `Diagonal` wraps on `typemin`, so `rank(Diagonal(Int8[-128])) == 0`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1875](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1875))

# Title

`svdvals` of an integer `Diagonal` wraps on `typemin`, so `rank(Diagonal(Int8[-128])) == 0`

# Body

```julia-repl
julia> using LinearAlgebra

julia> D = Diagonal(Int8[-128]);

julia> svdvals(D)
1-element Vector{Int8}:
 -128

julia> rank(D), rank(Matrix(D))
(0, 1)
```

`svdvals(D::Diagonal{<:Number})` is `sort!(abs.(D.diag), rev = true)`; for a
signed integer element type `abs(typemin(T))` wraps to `typemin(T)`, so a
singular value comes out negative and `rank`, which counts singular values
above a tolerance, misses it. `svd(D)` uses the same `abs.(d)`. The dense path
converts to floating point first and returns the correct value. The same
happens for `Int16` (`-32768`) and `Int64`.

Converting to `float` before taking the absolute value, as the dense
`svdvals` does, would fix both methods.

Reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 /
LinearAlgebra 1.14.0. Searches for `rank Diagonal` and `svdvals Diagonal`
found no matching issue or PR (2026-11-13).

Assisted-by: AI

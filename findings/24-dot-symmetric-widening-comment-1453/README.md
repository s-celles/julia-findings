# 24: Comment on JuliaLang/LinearAlgebra.jl#1453: A related inconsistency, in case the docstring is updated as suggested above

- Kind: comment for `JuliaLang/LinearAlgebra.jl#1453`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1453 (comment)](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1453#issuecomment-6873818448))

A related inconsistency, in case the docstring is updated as suggested above:
the specialized `dot(::Symmetric, ::Symmetric)` and `dot(::Hermitian,
::Hermitian)` methods accumulate in the widened type, while the generic method
on the materialized matrices wraps in the element type.

```julia-repl
julia> using LinearAlgebra

julia> A = Symmetric(Int8[-1 1; 2 127], :U); B = Symmetric(Int8[127 -1; 126 0], :U);

julia> dot(A, B)
-129

julia> dot(Matrix(A), Matrix(B))
127

julia> dot(UInt8[254, 2], UInt8[1, 2])      # generic method, wraps
0x02
```

The `Symmetric` method starts from `zero(dot(first(A), first(B)))` and adds
`2 * dot(...)` terms, so an `Int8` input gives an `Int` result (`-129`); the
generic method gives `Int8(127)` after wrapping. Observed for `Int8`, `UInt8`
and `Int16`, on Julia 1.13.3 and nightly 1.15.0-DEV.720.

Assisted-by: AI

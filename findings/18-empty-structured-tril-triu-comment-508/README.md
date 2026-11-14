# 18: Comment on JuliaLang/LinearAlgebra.jl#508: The dense `0×0` examples are fixed, but the corresponding structured matrix

- Kind: comment for `JuliaLang/LinearAlgebra.jl#508`
- Status: posted ([JuliaLang/LinearAlgebra.jl#508 (comment)](https://github.com/JuliaLang/LinearAlgebra.jl/issues/508#issuecomment-6873818251))

The dense `0×0` examples are fixed, but the corresponding structured matrix
methods still reject the main diagonal:

```julia-repl
julia> using LinearAlgebra

julia> tril(zeros(Int8, 0, 0), 0)
0×0 Matrix{Int8}

julia> tril(Diagonal(Int8[]), 0)
ERROR: ArgumentError: the requested diagonal, 0, must be at least -1 and at most -1 in an 0-by-0 matrix

julia> triu(Diagonal(Int8[]), 0)
ERROR: ArgumentError: the requested diagonal, 0, must be at least 1 and at most 1 in an 0-by-0 matrix
```

The same behavior remains for `Bidiagonal`, `Tridiagonal`, and
`SymTridiagonal`. It reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and
official nightly Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0.

A bounded sweep produced 240 operation/type/structure signatures in this
family: eight accepted-offset discrepancies across five wrappers and six
integer/Boolean types. They all reduce to the existing empty-matrix diagonal
bounds issue rather than independent bugs.

Assisted-by: AI

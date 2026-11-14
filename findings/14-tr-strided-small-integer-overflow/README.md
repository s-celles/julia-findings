# 14: `tr` silently wraps narrow integers depending on matrix storage

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1867](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1867))

# Title

`tr` silently wraps narrow integers depending on matrix storage

# Body

```julia-repl
julia> using LinearAlgebra

julia> A = Int8[127 127; 0 127];

julia> tr(A)
-2

julia> sum(diag(A))
254

julia> tr(Bidiagonal(Int8[127, 127], Int8[127], :U))
254
```

The `tr(::StridedMatrix{T})` specialization uses `reduce(+, ...)`, which
accumulates in `Int8` here. The generic `tr(A)` uses `sum(diag(A))`, and the
`Bidiagonal` and `Tridiagonal` specializations also use `sum`, so those paths
apply the normal small-integer widening. The same mathematical matrix can
therefore return either `-2::Int8` or `254::Int64` solely because of its
storage type.

The differential sweep exposed nine signatures across `Int8`, `UInt8`, and
`Int16` with upper/lower `Bidiagonal` and `Tridiagonal` matrices. The minimal
dense example reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official
nightly Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0.

Searches for `trace Int8 overflow`, `trace widening`, `tr promotion`,
`tr(A::StridedMatrix`, and `reduce(+, (A[i]` found no matching issue or PR.

Assisted-by: AI

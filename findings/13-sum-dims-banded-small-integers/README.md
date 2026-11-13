# 13: `sum(...; dims)` silently overflows narrow integers for banded matrices

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

`sum(...; dims)` silently overflows narrow integers for banded matrices

# Body

```julia-repl
julia> using LinearAlgebra

julia> A = Bidiagonal(Int8[127, 127], Int8[127], :U);

julia> sum(A; dims=1)
1×2 Matrix{Int8}:
 127  -2

julia> sum(Matrix(A); dims=1)
1×2 Matrix{Int64}:
 127  254
```

The specialized `_sum` methods for `Bidiagonal`, `Tridiagonal`, and
`SymTridiagonal` call `reducedim_initarray(A, dims, zero(eltype(A)))`. This
keeps `Int8`, `UInt8`, or `Int16` as the result element type and bypasses the
usual `add_sum` widening used by `sum` on dense arrays. The per-band additions
then silently wrap before or while being stored in the narrow result.

The sweep observed 24 signatures: dimensions 1 and 2, the three narrow types,
and all four banded wrappers above (`Bidiagonal` contributes both `:U` and
`:L`). Equal small values can hide the discrepancy, but the returned type is
still narrow; edge values expose the wrong result.

The example reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official
nightly Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0. Searches for `sum dims
Bidiagonal overflow`, `sum Int8 structured`, `reduction promotion
Bidiagonal`, and `add_sum Bidiagonal` found no matching issue or PR.

Assisted-by: AI

# 27: `SparseMatrixCSC(x')` for a `SparseVector{Bool}` fails (`BitVector` as `nzval`), which breaks broadcasting with `x'`

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: fixed upstream — JuliaSparse/SparseArrays.jl#1178 closed by [PR #1181](https://github.com/JuliaSparse/SparseArrays.jl/pull/1181) (2026-11-18)

# Title

`SparseMatrixCSC(x')` for a `SparseVector{Bool}` fails (`BitVector` as `nzval`), which breaks broadcasting with `x'`

# Body

```julia-repl
julia> using SparseArrays

julia> S = sparse(Bool[true false; true true]); x = sparsevec(Bool[true, false]);

julia> S .* Vector(x)'
2×2 SparseMatrixCSC{Bool, Int64} with 2 stored entries:
 1  ⋅
 1  ⋅

julia> S .* x'
ERROR: MethodError: no method matching SparseMatrixCSC(::Int64, ::Int64, ::Vector{Int64}, ::Vector{Int64}, ::BitVector)

julia> SparseMatrixCSC(x')
ERROR: MethodError: no method matching SparseMatrixCSC(::Int64, ::Int64, ::Vector{Int64}, ::Vector{Int64}, ::BitVector)
```

`_sparsem(::Union{Transpose, Adjoint}{<:Any, <:SparseVector})` in
`sparseconvert.jl` builds the stored values with `nzval = fadj.(nonzeros(B))`.
Broadcasting a `Bool`-valued function over a `Vector{Bool}` returns a
`BitVector`, and the `SparseMatrixCSC(m, n, colptr, rowval, nzval::Vector)`
constructor has no method for it. Every path that sparsifies the adjoint or
transpose of a Boolean sparse vector hits this, including the
`PromoteToSparse` broadcast style used by `S .* x'`. The same expression with
a dense `Vector(x)'` or with any non-`Bool` element type works.

`map(fadj, nonzeros(B))` or `Vector(fadj.(nonzeros(B)))` would keep a
`Vector{Bool}`.

Reproduces on Julia 1.13.3 / SparseArrays 1.13.0 and nightly 1.15.0-DEV.720 /
SparseArrays 1.14.0. Searches for `broadcast BitVector` and `SparseVector Bool
adjoint broadcast` in JuliaSparse/SparseArrays.jl found no matching issue or
PR (2026-11-13).

Assisted-by: AI

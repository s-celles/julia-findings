# 26: `opnorm(A, 1)` / `opnorm(A, Inf)` on integer sparse matrices take `abs` before widening, so `typemin` entries are lost

- Kind: issue for `JuliaSparse/SparseArrays.jl`
- Status: fixed upstream — JuliaSparse/SparseArrays.jl#1177 closed by [PR #1180](https://github.com/JuliaSparse/SparseArrays.jl/pull/1180) (2026-11-18)

# Title

`opnorm(A, 1)` / `opnorm(A, Inf)` on integer sparse matrices take `abs` before widening, so `typemin` entries are lost

# Body

```julia-repl
julia> using SparseArrays, LinearAlgebra

julia> A = sparse(Int8[1 -128; 1 0]);

julia> opnorm(A, 1), opnorm(Matrix(A), 1)
(2.0, 128.0)

julia> opnorm(A, Inf), opnorm(Matrix(A), Inf)
(1.0, 129.0)

julia> B = sparse([typemin(Int) 0 -2; 0 0 0; -2 0 0]);

julia> opnorm(B, 1), opnorm(Matrix(B), 1)
(2.0, 9.223372036854776e18)
```

`opnorm(::AbstractSparseMatrixCSC, p)` accumulates the column (or row) sums
in a `Float64` `colSum`, but adds `abs(getnzval(A)[i])`, which is evaluated in
the element type first: `abs(Int8(-128)) == -128`, and `abs(typemin(Int))
== typemin(Int)`. The negative term then lowers the sum instead of raising
it, and the wrong column can win the maximum. The dense `opnorm` converts to
floating point before taking absolute values. `norm(A, 1)` and
`norm(A, Inf)` on the same sparse matrices are correct.

`abs(float(x))` (or `float(abs(x))` guarded for signed integers) in the two
accumulation loops would fix it.

Reproduces for `Int8`, `Int16` and `Int64` on Julia 1.13.3 / SparseArrays
1.13.0 and nightly 1.15.0-DEV.720 / SparseArrays 1.14.0. Searches for
`opnorm typemin`, `opnorm overflow` and `opnorm abs integer` in
JuliaSparse/SparseArrays.jl found no matching issue or PR (2026-11-13).

Assisted-by: AI

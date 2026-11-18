# 79: `transpose(v) \ b` and `v' \ b` with a length-1 vector throw `MethodError: istriu(::Vector, ::Int)` instead of solving the 1×1 system

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

Solving with a 1×1 covector on the left — `transpose(v) \ b` or `v' \ b` where `v` is a length-1
`Vector` — throws a `MethodError` instead of returning the solution, while the dense 1×1 `Matrix`
solves and the 1×n covector (n ≥ 2) works:

```julia-repl
julia> using LinearAlgebra

julia> v = [3.0];

julia> Matrix(transpose(v)) \ ones(1)       # dense 1×1: correct
1-element Vector{Float64}:
 0.3333333333333333

julia> transpose([1.0, 2.0]) \ ones(1)      # 1×2 covector: works
2-element Vector{Float64}:
 0.19999999999999998
 0.39999999999999997

julia> transpose(v) \ ones(1)
ERROR: MethodError: no method matching istriu(::Vector{Float64}, ::Int64)

julia> v' \ ones(1)
ERROR: MethodError: no method matching istriu(::Vector{Float64}, ::Int64)
```

Mechanism: the square generic `\` (`generic.jl`, `\(::AbstractMatrix, ::AbstractVecOrMat)`) first
tests the left-hand side for triangularity with `istriu`/`istril` to pick a fast path. For a
`Transpose`/`Adjoint` of a `Vector` those predicates forward to the parent `Vector`
(`triangular.jl`), and `istriu(::Vector, ::Int)` has no method, so the 1×1 case throws before any
solve. For n ≥ 2 the wrapper is not square, the triangular check is skipped, and the least-squares
path works. Triggered for `Float64` and `ComplexF64`.

Versions checked: reproduced on LinearAlgebra with Julia 1.10.11, 1.11.9, 1.12.6 and 1.13.3
(long-standing).

Deduplication searches (2026-11-18): in this catalogue, `transpose vector solve istriu` matches nothing.
Upstream `JuliaLang/LinearAlgebra.jl`, `istriu Vector backslash transpose covector`, `ldiv Transpose
vector 1x1 istriu` and `solve adjoint vector` found no issue.

Found by a differential view-vs-materialized probe (`\` on lazy wrappers against the dense oracle).
Reproducer: `transpose_vector_1x1_solve_istriu.jl` (prints `REPRODUCED`).

Assisted-by: AI

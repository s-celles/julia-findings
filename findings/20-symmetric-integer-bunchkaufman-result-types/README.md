# 20: `Symmetric`/`Hermitian` integer matrices: `\`, `det` and `logabsdet` return `Rational{BigInt}` / `BigFloat`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Title

`Symmetric`/`Hermitian` integer matrices: `\`, `det` and `logabsdet` return `Rational{BigInt}` / `BigFloat`

# Body

```julia-repl
julia> using LinearAlgebra

julia> S = Symmetric(Int8[1 2; 2 3]); b = Int8[1, 2];

julia> S \ b
2-element Vector{Rational{BigInt}}:
 1
 0

julia> Matrix(S) \ b
2-element Vector{Float64}:
 1.0
 0.0

julia> typeof(det(S)), typeof(det(Matrix(S)))
(BigFloat, Float64)

julia> logabsdet(S)
(0.0, 1//1)   # Tuple{BigFloat, Rational{BigInt}}

julia> typeof(factorize(S))
BunchKaufman{Rational{BigInt}, Matrix{Rational{BigInt}}, Vector{Int64}}
```

`_factorize(A::HermOrSym)` decides between `bunchkaufman` and `lu` with
`TT = typeof(sqrt(oneunit(T)))`; for any integer `T` this is `Float64`, which
is a `BlasFloat`, so it calls `bunchkaufman(A)`. The generic Bunch-Kaufman
implementation promotes integer input to `Rational{BigInt}` ("to avoid
overflow problems"), and that type then leaks into `\` with a vector
right-hand side, `det` and `logabsdet`. The same matrix with a matrix
right-hand side goes through `lu` and gives `Float64`, as do `inv` and the
dense path, so the result type depends on the shape of the right-hand side.

Exact arithmetic also means these calls succeed where the floating-point
paths report a singular matrix, for example
`Symmetric(UInt64[typemax(UInt64) 1; 1 1]) \ UInt64[1, 0]` returns
`Rational{BigInt}[1//18446744073709551614, -1//18446744073709551614]`.

On Julia 1.13.3 / SparseArrays 1.13.0 the same type leaks through the sparse
solver: `sparse(Bool[1 1; 1 0]) \ sparsevec(Bool[0, 0])` returns
`Rational{BigInt}[0, 0]` (the symmetric sparse matrix is routed to the
`Symmetric` path); the nightly returns `Float64` there.

If `Rational{BigInt}` is intended for integer input, it would help to say so
in the `bunchkaufman` docstring; otherwise `_factorize` should probably promote
integer matrices to `float` first, as `lu` does.

Reproduces for `Bool`, `Int8`, `UInt8`, `Int16`, `Int64` and `UInt64` on Julia
1.13.3 / LinearAlgebra 1.13.0 and nightly 1.15.0-DEV.720 / LinearAlgebra
1.14.0. Searches for `Symmetric Rational BigInt`, `bunchkaufman Rational`,
`generic bunchkaufman`, `Symmetric det BigFloat` and `Symmetric integer solve`
found no matching issue or PR (2026-11-13).

Assisted-by: AI

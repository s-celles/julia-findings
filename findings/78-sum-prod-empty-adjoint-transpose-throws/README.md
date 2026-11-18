# 78: `sum` and `prod` of an empty `Adjoint`/`Transpose` throw, where the materialized empty array and every other lazy wrapper return the neutral element

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

Reducing an empty `Adjoint` or `Transpose` wrapper with `sum`/`prod` (no explicit `init`) throws,
while the materialized empty array and the other lazy wrappers (`view`, `reshape`,
`PermutedDimsArray`) return the neutral element `zero(T)`/`one(T)`:

```julia-repl
julia> using LinearAlgebra

julia> A = Matrix{Float64}(undef, 1, 0);   # 1×0, empty

julia> sum(collect(A')), prod(collect(A'))   # dense empty: neutral elements
(0.0, 1.0)

julia> sum(view(A, :, :))                    # view of the empty matrix: fine
0.0

julia> sum(A')
ERROR: ArgumentError: reducing over an empty collection is not allowed; consider supplying `init` ...

julia> prod(A')
ERROR: ArgumentError: reducing over an empty collection is not allowed; ...
```

The same happens for `transpose(A)` and for every element type with a `zero`/`one` (`Bool`, `Int`,
`Int8`, `Rational`, `Float64`, `ComplexF64`). `Adjoint`/`Transpose` are `AbstractArray`s with a
typed, empty shape, so the documented empty-reduction behaviour (`sum` of an empty typed array is
`zero(T)`) applies to them as it does to `Matrix` and to the other wrappers.

Mechanism: the `mapreduce` path for `Adjoint`/`Transpose` does not reach the `AbstractArray`
specialization that supplies the empty-case initial value (`mapreduce_empty` / `reduce_empty`), and
falls through to the generic iterator reduction, which refuses an empty collection. On Julia 1.10 the
failure surfaces as a `MethodError` instead of the `ArgumentError`.

Versions checked: reproduced on LinearAlgebra with Julia 1.10.11, 1.11.9, 1.12.6 and 1.13.3
(long-standing).

Deduplication searches (2026-11-18): in this catalogue, `empty adjoint sum reduce` and `empty`
match only unrelated empty-input entries (`diff`, `isposdef`, `median`). Upstream
`JuliaLang/LinearAlgebra.jl` and `JuliaLang/julia`, `sum empty adjoint transpose reduce`,
`mapreduce empty adjoint` and `reducing empty collection` found no issue covering the wrappers.

Found by a differential view-vs-materialized probe (`f(V)` against `f(collect(V))` for lazy wrappers).
Reproducer: `sum_prod_empty_adjoint_transpose.jl` (prints `REPRODUCED`).

Assisted-by: AI

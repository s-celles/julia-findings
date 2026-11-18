# 76: `UpperHessenberg \ b` on a singular matrix returns `NaN` silently, and `UpperHessenberg{Rational} \ b` throws `MethodError(givensAlgorithm)` — regression in LinearAlgebra 1.13

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1902](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1902)); on v1.14 the Rational solve works but inexactly (-4503599627370495//4503599627370496 instead of -1), per maintainer comment

# Body

Since LinearAlgebra 1.13, `\` on an `UpperHessenberg` no longer detects singularity and no longer
works for exact element types, while `inv`, `lu(H) \ b` and the dense path behave correctly:

```julia-repl
julia> using LinearAlgebra

julia> H = UpperHessenberg([1.0 2.0; 0.0 0.0]);   # singular

julia> H \ [1.0, 2.0]                              # 1.13: silent NaN  (1.12: SingularException)
2-element Vector{Float64}:
 NaN
 NaN

julia> inv(H)
ERROR: SingularException(2)

julia> lu(H) \ [1.0, 2.0]
ERROR: SingularException(2)

julia> Hr = UpperHessenberg(Rational{Int}[1 2; 1 3]);   # non-singular, exact

julia> Hr \ Rational{Int}[1, 2]                    # 1.13: MethodError  (1.12: [-1, 1])
ERROR: MethodError: no method matching givensAlgorithm(::Rational{Int64}, ::Rational{Int64})

julia> Matrix(Hr) \ Rational{Int}[1, 2]
2-element Vector{Rational{Int64}}:
 -1
  1
```

Mechanism: JuliaLang/LinearAlgebra.jl#1322 ("add missing methods for division of Hessenberg
matrices", merged 2025-05-04, in the 1.13 line) added `\` and `/` methods for `UpperHessenberg` that
route to the optimized RQ-based `ldiv!`/`rdiv!` kernels. Those kernels do not test the pivot
(`ρ == 0` / `u[1] == 0`) that the previous generic fallback caught, so a singular matrix yields `NaN`
instead of `SingularException`; and they rely on `givensAlgorithm`, which exists only for BLAS float
types, so an exact `Rational` matrix that the generic fallback used to solve now throws `MethodError`.
`logabsdet` of a `Rational` `UpperHessenberg` fails the same way.

Versions checked: **regression** — on LinearAlgebra 1.12.0 (Julia 1.12.6) `H \ b` raises
`SingularException` and `Hr{Rational} \ b` returns `[-1, 1]`; on 1.13.0 (Julia 1.13.3) the former
returns `NaN` and the latter throws `MethodError`. Backport candidate.

Deduplication searches (2026-11-17): in this catalogue, `UpperHessenberg` and `givensAlgorithm`
match nothing. Upstream, `UpperHessenberg singular`, `UpperHessenberg Rational MethodError
givensAlgorithm` and `UpperHessenberg ldiv NaN` match nothing.

Found by a differential pivot-adversarial probe (structured `\` against the dense oracle on
singular and exact-type matrices). Reproducer:
`p3_upperhessenberg_singular_silent_nan_rational_methoderror.jl` (prints `REPRODUCED` on the
regressed versions).

Assisted-by: AI

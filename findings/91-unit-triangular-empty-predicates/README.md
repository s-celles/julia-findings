# 91: `istriu`, `istril` and `isbanded` of an empty `UnitUpperTriangular`/`UnitLowerTriangular` return `false` for offsets beyond the diagonal, where the dense answer is (vacuously) `true` — regression in LinearAlgebra 1.13

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

```julia-repl
julia> using LinearAlgebra

julia> E = zeros(0, 0);

julia> istriu(E, 1), istril(E, -1), LinearAlgebra.isbanded(E, 1, 2)      # dense: vacuously true
(true, true, true)

julia> istriu(UnitLowerTriangular(E), 1), istril(UnitLowerTriangular(E), -1)
(false, false)

julia> istriu(UnitUpperTriangular(E), 1), istril(UnitUpperTriangular(E), -1)
(false, false)

julia> LinearAlgebra.isbanded(UnitLowerTriangular(E), 1, 2)
false

julia> istriu(UpperTriangular(E), 1), istril(LowerTriangular(E), -1)     # non-unit wrappers: fine
(true, true)
```

Mechanism (`src/triangular.jl`): the unit-triangular predicates are closed forms that assume a
non-empty unit diagonal — `istril(::UnitLowerTriangular, k) = k >= 0`,
`istriu(::UnitUpperTriangular, k) = k <= 0`, and `k > 0 ? false : …` in the mixed cases — so an empty
matrix, which has no diagonal at all, is reported as *not* upper/lower triangular beyond the diagonal.

Versions checked: `istriu(UnitLowerTriangular(zeros(0, 0)), 1)` is `true` on Julia 1.10.11, 1.11.9 and
1.12.6 and `false` on 1.13.3 and nightly 1.15.0-DEV.834 (LinearAlgebra 1.14.0) — a regression in
LinearAlgebra 1.13 (the probing run observed some of the other predicates already wrong on 1.12.6).

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `istriu empty`,
`UnitLowerTriangular empty`, `empty triangular`, `0x0 triangular` — nothing; this catalogue's entry 18
(#508) concerns `triu`/`tril` of empty matrices, not the predicates.

Found by a metamorphic predicate-agreement probe. Reproducer: `unit_triangular_empty_predicates.jl`
(prints `REPRODUCED`).

Assisted-by: AI

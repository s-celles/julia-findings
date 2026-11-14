# 57: Comment on JuliaLang/julia#64442: `symdiff!(::BitSet, itr)` still depends on duplicate multiplicity on Julia 1.13.3 (backport candidate)

- Kind: comment for `JuliaLang/julia#64442`
- Status: not posted

# Body

On the released Julia 1.13.3 the mismatch fixed by this pull request
(reported in JuliaLang/julia#64145) is still present: `symdiff!` on a
`BitSet` toggles every element of the iterable, while `Set` and `Vector`
treat the iterable as a set of distinct values.

```julia-repl
julia> symdiff!(BitSet([1]), [0, 0])
BitSet([1])

julia> symdiff!(Set([1]), [0, 0])
Set([1, 0])

julia> symdiff([1], [0, 0])
2-element Vector{Int64}:
 1
 0
```

On nightly 1.15.0-DEV.720 the three agree (`BitSet([0, 1])`). The pull
request carries no backport label; since `BitSet` is the only container
that still disagrees on the current stable release, it seems worth a backport
to 1.13 (and 1.12 if it applies there).

Found by a probe of `BitSet` against `Set{Int}` on random integer lists
(`experiments/phase4/collection_contracts.jl`).

Assisted-by: AI

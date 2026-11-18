# 87: `triu` and `tril` of `Diagonal`, `Bidiagonal`, `Tridiagonal` and `SymTridiagonal` reject valid diagonal offsets (asymmetric bounds), where the dense methods accept any offset

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

```julia-repl
julia> using LinearAlgebra

julia> triu([1.0;;], -1), tril([1.0;;], 1)            # dense: any offset is fine
([1.0;;], [1.0;;])

julia> triu(Diagonal([1.0]), -1)
ERROR: ArgumentError: the requested diagonal, -1, must be at least 0 and at most 2 in an 1-by-1 matrix

julia> tril(Diagonal([1.0]), 1)
ERROR: ArgumentError: ...

julia> triu(Diagonal([1.0, 2, 3]), -3)                 # rejected ...
ERROR: ArgumentError: ...

julia> triu(Diagonal([1.0, 2, 3]), 4)                  # ... while k = 4 > n is accepted
3×3 Diagonal{Float64, Vector{Float64}}

julia> triu(SymTridiagonal([1.0], Float64[]), -1); triu(Bidiagonal([1.0], Float64[], :U), -1); triu(Tridiagonal(Float64[], [1.0], Float64[]), -1)
ERROR: ArgumentError: ...   (all three)
```

Mechanism: the banded `triu!`/`tril!` implementations check the offset with asymmetric bounds —
`triu!` requires `-n+1 ≤ k ≤ n+1` and `tril!` requires `-n-1 ≤ k ≤ n-1` (`src/diagonal.jl`, and the same
pattern in `src/bidiag.jl` and `src/tridiag.jl`) — while any offset is meaningful (an offset beyond the
band simply yields a zero or an unchanged matrix), as the dense `triu`/`tril` and the 1×1 dense case
show. This is the banded sibling of the open JuliaLang/LinearAlgebra.jl#1876 (`BitMatrix`, different
code in `bitarray.jl`).

Versions checked: reproduced on Julia 1.10.11, 1.11.9, 1.12.6, 1.13.3 and nightly 1.15.0-DEV.834
(LinearAlgebra 1.14.0) — long-standing.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `triu Diagonal
requested diagonal`, `"must be at least"`, `"requested diagonal"`, `triu 1x1`, `tril Diagonal offset`
— only #1876 (`BitMatrix`) and #874 (length of `ev`). No match for the banded types.

Found by a differential probe of nested wrappers against the dense oracle. Reproducer:
`triu_tril_banded_reject_valid_offsets.jl` (prints `REPRODUCED`).

Assisted-by: AI

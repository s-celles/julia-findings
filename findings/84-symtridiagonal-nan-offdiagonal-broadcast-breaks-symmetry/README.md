# 84: a `SymTridiagonal` with a `NaN` off-diagonal entry cannot be broadcast at all (`S .* 2` throws "broadcasted assignment breaks symmetry")

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not posted

# Body

Any broadcast whose result is a `SymTridiagonal` fails when an off-diagonal entry is `NaN`, although
the matrix is perfectly symmetric and every non-broadcast operation works:

```julia-repl
julia> using LinearAlgebra

julia> S = SymTridiagonal([1.0, 2.0, 3.0], [NaN, 5.0]);

julia> S .* 2
ERROR: ArgumentError: broadcasted assignment breaks symmetry between locations (1, 2) and (2, 1)

julia> S .+ 0; identity.(S); abs.(S); S .*= 2; S .= S     # all throw the same way

julia> S * 2, rmul!(copy(S), 2), copy(S)                   # fine

julia> Matrix(S) .* 2                                       # fine
```

`SymTridiagonal([true, true], [true]) .* NaN` fails the same way (`false * NaN == 0.0`, so the structure
is kept), and on the nightly `S .* Diagonal(...)` / `S .+ Diagonal(...)` also throw because their result
is now a `SymTridiagonal`. `Symmetric` and `Hermitian` are not affected.

Mechanism (`src/structuredbroadcast.jl`, `copyto!(dest::SymTridiagonal, bc)`): the symmetry check
compares the two mirrored values with `==` (`v == transpose(bc[BandIndex(-1, i)])`), and `NaN == NaN` is
`false`, so a symmetric `NaN` is reported as a broken symmetry. Using `isequal`, or skipping the check
when the operation is known to preserve symmetry, would fix it.

Versions checked: **regression since LinearAlgebra 1.12** — on Julia 1.10.11 and 1.11.9 `S .* 2` returned
a dense `Matrix` (no symmetry check runs), so it worked; on 1.12.6, 1.13.3 and nightly 1.15.0-DEV.833
(LinearAlgebra 1.14.0) the result is a `SymTridiagonal` and the symmetry check — present since
JuliaLang/julia#31678 (2019) and written with `==` — rejects the `NaN`.

Deduplication searches (2026-11-18): `JuliaLang/LinearAlgebra.jl` issues and PRs for `breaks symmetry`,
`broadcast symmetry`, `SymTridiagonal NaN`, `SymTridiagonal broadcast`, `NaN broadcast`,
`broadcast ArgumentError SymTridiagonal`. No match.

Found by a differential probe of structured broadcasting against the dense result. Reproducer:
`symtridiagonal_nan_broadcast_breaks_symmetry.jl` (prints `REPRODUCED`).

Assisted-by: AI

# 75: Right division by a singular `UpperTriangular{<:BlasFloat}` returns `NaN`/`Inf` silently, where `U \ b`, the generic path and the dense path raise `SingularException`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: posted ([JuliaLang/LinearAlgebra.jl#1901](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1901))

# Body

`B / U` with `U` a singular `UpperTriangular` of BLAS element type returns a silent `NaN`/`Inf`
result; every neighbouring path raises:

```julia-repl
julia> using LinearAlgebra

julia> U = UpperTriangular([1.0 2.0; 0.0 0.0]); B = [1.0 2.0];

julia> B / U                                   # silent
1×2 Matrix{Float64}:
 1.0  NaN

julia> U \ [1.0, 2.0]
ERROR: SingularException(2)

julia> B / Matrix(U)
ERROR: SingularException(2)

julia> Rational{Int}[1 2] / UpperTriangular(Rational{Int}[1 2; 0 0])
ERROR: SingularException(2)
```

The same holds for `rdiv!` and for `B / transpose(U)`; `b' / U` (a row-vector adjoint) raises like
the left division.

Mechanism: the BLAS-type right-division path, `generic_mattridiv!` for `BlasFloat`, calls
`BLAS.trsm!` directly, and `trsm` never inspects the triangular diagonal; the left-division path uses
`trtrs!` / the generic kernel, both of which check for a zero diagonal and throw
`SingularException`. So the singularity check depends on which side you divide from. Related:
JuliaLang/LinearAlgebra.jl#1665 (open) discusses the generic triangular kernel and `check = false`,
where the maintainer's stated expectation is a consistent singularity contract across these kernels.

Versions checked: reproduced on LinearAlgebra with Julia 1.10.11, 1.11.9, 1.12.6 and 1.13.3
(long-standing). On 1.10.11 the left division raises `LAPACKException` rather than
`SingularException`; the right division is silently `NaN` on every version.

Deduplication searches (2026-11-17): in this catalogue, `UpperTriangular singular` and
`rdiv triangular` match nothing. Upstream, `rdiv UpperTriangular singular SingularException` and
`trsm singular triangular NaN` match nothing; `#1665` is the related-but-distinct `check = false`
discussion on the generic kernel.

Found by a differential pivot-adversarial probe (structured right division against the dense
oracle on matrices with a zero diagonal). Reproducer:
`p2_rdiv_uppertriangular_blasfloat_singular_silent_nan.jl` (prints `REPRODUCED`).

Assisted-by: AI

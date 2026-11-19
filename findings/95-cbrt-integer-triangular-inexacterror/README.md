# 95: `cbrt` of an integer `UpperTriangular`/`LowerTriangular` keeps the integer element type and throws `InexactError` (`cbrt(UpperTriangular([2 1; 0 3]))`), while the dense, `Diagonal` and `Symmetric` methods return `Float64`

- Kind: issue for `JuliaLang/LinearAlgebra.jl`
- Status: not filed as an issue (trivial one-line fix, per the LinearAlgebra.jl#1912 guidance); fix proposed in [JuliaLang/LinearAlgebra.jl#1928](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1928) (open, 2026-11-19)

# Body

```julia-repl
julia> using LinearAlgebra

julia> cbrt([2 1; 0 3])
2×2 Matrix{Float64}:
 1.25992  0.182329
 0.0      1.44225

julia> cbrt(UpperTriangular([2 1; 0 3]))
ERROR: InexactError: Int64(1.2599210498948732)

julia> cbrt(UpperTriangular([2 0; 0 3]))
ERROR: InexactError: Int64(1.2599210498948732)

julia> cbrt(UpperTriangular([2//1 1; 0 3]))
ERROR: OverflowError: 5674179970822795 * 5674179970822795 overflowed for type Int64

julia> cbrt(UpperTriangular([8 0; 0 27]))               # exact roots: silently an integer matrix
2×2 UpperTriangular{Int64, Matrix{Int64}}:
 2  0
 ⋅  3

julia> cbrt(Diagonal([2, 3]))
2×2 Diagonal{Float64, Vector{Float64}}:
 1.25992   ⋅
  ⋅       1.44225
```

Mechanism (`src/triangular.jl`):

```julia
cbrt(A::UpperTriangular{T}) where {T<:Real} = UpperTriangular(_cbrt_quasi_triu!(Matrix{T}(A)))
cbrt(A::LowerTriangular{T}) where {T<:Real} = LowerTriangular(_cbrt_quasi_triu!(Matrix{T}(A'))')
```

The working copy keeps the input element type, and the in-place algorithm stores non-integer roots
into it. The dense method goes through `schur`, which promotes to a floating-point type, and
`cbrt(::Diagonal)` broadcasts the scalar `cbrt`. Present since the matrix `cbrt` was added
(JuliaLang/julia#50661, Julia 1.11). Fix: build the copy as `Matrix{float(T)}(A)`.

Versions checked: Julia 1.11.9, 1.12.7, 1.13.3 and nightly 1.15.0-DEV.834 (LinearAlgebra 1.14.0);
1.10 has no matrix `cbrt`.

Deduplication searches (2026-11-19): `JuliaLang/LinearAlgebra.jl` issues and PRs for `cbrt
UpperTriangular`, `cbrt InexactError`, `cbrt integer` — none.

Found by a structured-versus-dense differential probe over the matrix functions. Reproducer:
`cbrt_integer_triangular_inexacterror.jl` (prints `REPRODUCED`).

Assisted-by: AI

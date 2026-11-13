# 17: Comment on JuliaLang/LinearAlgebra.jl#1707: The `Diagonal` fix appears to leave the same empty-trace problem in

- Kind: comment for `JuliaLang/LinearAlgebra.jl#1707`
- Status: not posted

The `Diagonal` fix appears to leave the same empty-trace problem in
`SymTridiagonal`:

```julia-repl
julia> using LinearAlgebra

julia> A = SymTridiagonal(Int8[], Int8[]);

julia> tr(A)
ERROR: ArgumentError: reducing over an empty collection is not allowed; consider supplying `init` to the reducer

julia> tr(Matrix(A))
0
```

This reproduces on Julia 1.13.3 / LinearAlgebra 1.13.0 and official nightly
Julia 1.15.0-DEV.688 / LinearAlgebra 1.14.0. On the nightly,
`tr(Diagonal(Int8[])) == 0`, so the original `Diagonal` case is fixed. The
remaining method is currently `tr(S::SymTridiagonal) = sum(symmetric, S.dv)`,
whose mapped reduction has no identity for an empty vector.

A bounded matrix differential sweep found the same symptom for all six tested
element types (`Bool`, `Int8`, `UInt8`, `Int16`, `Int64`, and `UInt64`).

Assisted-by: AI

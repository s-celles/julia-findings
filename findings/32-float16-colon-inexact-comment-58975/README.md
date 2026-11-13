# 32: Comment on JuliaLang/julia#58975: The three-argument colon path has a related `Float16` length failure

- Kind: comment for `JuliaLang/julia#58975`
- Status: posted ([JuliaLang/julia#58975](https://github.com/JuliaLang/julia/issues/58975#issuecomment-6854593316))

The three-argument colon path has a related `Float16` length failure:

```julia-repl
julia> Float16(-1):Float16(6e-8):Float16(1)
ERROR: InexactError: Int64(Inf16)
Stacktrace:
 [1] Int64(x::Float16)
 ...
 [6] (::Colon)(start::Float16, step::Float16, stop::Float16)
   @ Base twiceprecision.jl:430

julia> length(Float32(-1):Float32(6e-8):Float32(1))
33333335
```

Here `Colon` computes `(stop - start) / step` in `Float16`; the quotient
overflows to `Inf16` even though the intended length (about `3.3e7`) fits in
`Int`. The issue's original `range(start=..., stop=..., length=...)` example
goes through `_linspace`, so this is a second constructor path with the same
user-visible failure class.

This reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. The narrower query
`Float16 range InexactError Inf` found #49422, but the broader query
`floating-point range InexactError` found this issue and establishes it as the
right place for the follow-up.

Assisted-by: AI

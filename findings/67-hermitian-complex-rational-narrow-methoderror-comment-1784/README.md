# 67: Comment on JuliaLang/LinearAlgebra.jl#1784: on LinearAlgebra 1.13.0 `det`, `\` and `bunchkaufman` of a `Hermitian{Complex{Rational{Int16}}}` throw `MethodError` in `generic_adr1!` (backport candidate)

- Kind: comment for `JuliaLang/LinearAlgebra.jl#1784`
- Status: posted ([comment on JuliaLang/LinearAlgebra.jl#1784](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1784#issuecomment-7032050223), backport request for 1.13, 2026-11-20)

# Body

On the released LinearAlgebra 1.13.0 (Julia 1.13.3) the generic
Bunch-Kaufman kernel replaced by this pull request fails for narrow complex
rationals: the rank-1 update receives a `Rational{Int64}` scalar with a
`Complex{Rational{Int16}}` (or `Int32`) storage view and no method matches.

```julia-repl
julia> using LinearAlgebra

julia> H = Hermitian(Complex{Rational{Int16}}[6 1//2-1//2im; 1//2+1//2im 3]);

julia> det(H)
ERROR: MethodError: no method matching generic_adr1!(::Char, ::Rational{Int64}, ::SubArray{Complex{Rational{Int16}}, 1, ...}, ...)

julia> H \ Complex{Rational{Int16}}[1, 2]
ERROR: MethodError: no method matching generic_adr1!(...)

julia> det(Matrix(H)), det(Hermitian(Complex{Rational{Int64}}.(Matrix(H))))
(35//2 + 0//1*im, 17.500000000000004)
```

`Complex{Rational{Int64}}` and real `Rational{Int16}` work. On nightly
1.15.0-DEV.720 (LinearAlgebra 1.14.0, after this pull request) the three
calls return `17.5`, the exact rational solution and a factorization. Since
the current stable release throws a `MethodError` for a documented operation
on a supported element type, a backport of the kernel change (or of a
promotion of the scalar) to 1.13 seems worthwhile.

Found by a probe of structured matrix kinds with complex exact element types
against the dense `Complex{Rational{BigInt}}` computation
(`experiments/phase4/complex_structured_contracts.jl`). Reproducer:
`hermitian_complex_rational_narrow_methoderror.jl` (prints REPRODUCED on
1.13.3 and AGREE on nightly).

Assisted-by: AI

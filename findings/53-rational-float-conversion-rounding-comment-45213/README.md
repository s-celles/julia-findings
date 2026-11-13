# 53: Comment on JuliaLang/julia#45213: `Float32(::Rational{Int64})` and `Float64(::Rational{Int64})` inherit the inexact `Int/Int` division

- Kind: comment for `JuliaLang/julia#45213`
- Status: not posted

# Body

Concrete consequences for `Rational` conversions, found by comparing
`Rational{Int64}` with `Rational{BigInt}` on Julia 1.13.3 and nightly
1.15.0-DEV.720. `T(x::Rational{S})` computes
`convert(T, convert(P, x.num) / convert(P, x.den))` with `P =
promote_type(T, S)`, so for `Int64` both operands become `Float64` first and
the quotient is rounded twice:

```julia-repl
julia> x = 1 // 1317624576693539401;

julia> Float32(x), Float32(big(x))
(7.5894147f-19, 7.589415f-19)

julia> y = 1 // 9007199254740993;       # denominator 2^53 + 1

julia> Float64(y) === Float64(big(y))
false

julia> z = 4503599627370499 // 1317624576693539401;

julia> Float64(z) === Float64(big(z))
false

julia> Float64(1 // 3) === Float64(big(1 // 3))
true
```

In a sample of 40 `Int64` rationals with denominators above `2^40`, 4 of the
`Float32` conversions and, in a smaller set, 4 of the `Float64` conversions
differed from the correctly rounded value. `Float16` conversions were correct
on every `Rational{Int8}` value and on these samples (they go through
`Float32`, which has enough spare bits). A correctly rounded `Int64 / Int64`
(the subject of this issue) would fix the `Rational` conversions as well; so
would converting through `BigFloat` when the denominator exceeds the
significand.

Assisted-by: AI

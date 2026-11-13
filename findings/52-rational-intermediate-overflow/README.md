# 52: `Rational{T}` arithmetic throws `OverflowError` from intermediate products when the exact result fits, including `isapprox` and `x^p` with a run-time `p == 0`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`Rational{T}` arithmetic throws `OverflowError` from intermediate products when the exact result is representable, including `isapprox`, `rem`/`mod`, `fld`/`div`, and `x^p` with a run-time `p == 0`

# Body

```julia-repl
julia> x, y = Int8(83)//Int8(6), Int8(-94)//Int8(3);

julia> big(x) + big(y)
-35//2

julia> x + y
ERROR: OverflowError: -94 * 2 overflowed for type Int8

julia> a, b = Int8(-57)//Int8(94), Int8(33)//Int8(103);

julia> fld(big(a), big(b)), div(big(a), big(b))
(-2, -1)

julia> fld(a, b)
ERROR: OverflowError: -19 * 103 overflowed for type Int8

julia> isapprox(a, b)
ERROR: OverflowError: -57 * 103 overflowed for type Int8

julia> c, d = Int8(41)//Int8(59), Int8(89)//Int8(56);

julia> rem(c, d)              # exact result is c itself
ERROR: OverflowError: 41 * 56 overflowed for type Int8

julia> z = Int8(-104)//Int8(121); p = 0;

julia> z^0, z^p
ERROR: OverflowError: -104 * -104 overflowed for type Int
```

Rational arithmetic on fixed-width integers is checked, which is good, but
the checks fire on intermediate products (`x.num * y.den`, cross
multiplication in comparisons, `x * x` in `power_by_squaring`) even when the
reduced result fits in `Rational{T}`. The consequences are that a comparison
(`isapprox`, and `<`/`==` go through the same cross products) can throw, that
`rem`/`mod` throw when the answer is the first operand, and that `x^p`
throws for a run-time `p == 0` although the literal `x^0` returns `1//1`.

Reducing by the gcd before multiplying (as `+` partly does), or computing the
cross products in `widen(T)`, would make these representable results
reachable.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Found by a probe of
`Rational{Int8}` pairs against `Rational{BigInt}`. Searches for `Rational
overflow intermediate representable`, `isapprox Rational OverflowError`,
`Rational fld OverflowError` and `Rational power zero exponent OverflowError`
found no matching issue (2026-11-14).

Assisted-by: AI

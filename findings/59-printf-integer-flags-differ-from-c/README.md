# 59: Printf integer conversions deviate from C in four flag rules (sign flags on unsigned conversions, precision 0 with zero, `#` with octal and hexadecimal zero, `0` flag with precision 0)

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Body

`@printf` is documented as C `printf` style with a pointer to the C
specification. Comparing `Printf.format` with glibc `snprintf` on random
specifications for `d i u o x X` finds four systematic differences:

```julia-repl
julia> using Printf

julia> @sprintf("%+x", 255), @sprintf("% u", 5), @sprintf("%+o", 8)
("+ff", " 5", "+10")        # C ignores + and space for unsigned conversions: "ff", "5", "10"

julia> @sprintf("%.0d", 0), @sprintf("%.0x", 0), @sprintf("%5.0d", 0)
("0", "0", "    0")         # C prints no digits for a zero value with precision 0: "", "", "     "

julia> @sprintf("%#o", 0), @sprintf("%#.7o", 1), @sprintf("%#x", 0)
("00", "00000001", "0x0")   # C: "0", "0000001" (# only forces a leading 0), "0" (no prefix for zero)

julia> @sprintf("%020.d", 1), @sprintf("%+08.0d", 99)
("00000000000000000001", "+0000099")   # C ignores the 0 flag when a precision is given
```

The last rule is fixed on master by JuliaLang/julia#64324 (backport 1.14);
the other three are the same on Julia 1.13.3 and nightly 1.15.0-DEV.720.
`stdlib/Printf/test/runtests.jl` asserts `"+1024"` for `%+u` and `"00"` for
`%#o` of zero, so some of this may be intended; if so, the deviations from C
could be listed in the `@printf` caveats next to the `Inf`/`NaN` one.
Related: `%#a` of zero prints `0x0p+0` where C prints `0x0.p+0` (the `#`
flag must force the radix point).

Found by comparing `Printf.format` with glibc `snprintf`; the same
divergences are recorded independently in the MilesCranmer/julia-in-lean
bug corpus (`printf-plus-unsigned`, `printf-integer-zero-precision`,
`printf-octal-alternate-precision`, `printf-hex-alternate-zero`,
`printf-hex-zero-alternate-point`). Reproducer:
`integer_flags_differ_from_c.jl` (prints REPRODUCED when any case differs).

Assisted-by: AI

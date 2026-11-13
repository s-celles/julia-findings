# 39: `intersect` of a Month/Year Date range with itself errors in the arithmetic StepRange specialization

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`intersect` of a Month/Year Date range with itself errors in the arithmetic StepRange specialization

# Body

```julia-repl
julia> using Dates

julia> r = Date(2020, 1, 31):Month(1):Date(2020, 2, 29);

julia> collect(r)
2-element Vector{Date}:
 2020-01-31
 2020-02-29

julia> intersect(r, r)
ERROR: promotion of types Day and Month failed to change any arguments

julia> intersect(collect(r), collect(r))
2-element Vector{Date}:
 2020-01-31
 2020-02-29

julia> invoke(intersect, Tuple{AbstractRange, AbstractRange}, r, r)
2-element Vector{Date}:
 2020-01-31
 2020-02-29
```

The specialized `intersect(r::StepRange, s::StepRange)` assumes affine
arithmetic: it applies `lcm`/`gcdx` to the steps and takes remainders of
endpoint differences by those steps. For this range the endpoint difference
is a `Day`, while the declared step is a `Month`; calendar Month/Year steps
are irregular and do not satisfy that model. The generic
`intersect(::AbstractRange, ::AbstractRange)` already returns the expected
elements.

#7760 originally reported missing intersection support for non-integer ranges,
including date ranges, and merged #7778 removed the type restriction because
`Period` implemented the arithmetic operations. That covers fixed Period
steps such as `Day`, but not irregular Month/Year steps. The currently open
#35203/#35279 is the analogous dispatch problem for optimized `findfirst`;
#64123 is a distinct integer-overflow bug in range intersection.

Reproduces on Julia 1.13.3 and official nightly 1.15.0-DEV.720 (commit
31cf85936ac). Searches for `intersect StepRange Date`, `intersect Date range
Month`, `promotion of types Day and Month`, `RangeStepIrregular intersect`,
and `intersect Period StepRange` found no direct issue or PR (2026-11-13).

Assisted-by: AI

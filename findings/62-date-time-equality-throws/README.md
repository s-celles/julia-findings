# 62: `==` and `isequal` between a `Date`/`DateTime` and a `Time` throw a promotion error instead of returning `false`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Body

Comparing a calendar value with a `Time` throws, while comparing it with any
other unrelated value returns `false`:

```julia-repl
julia> using Dates

julia> Date(2020) == Time(1)
ERROR: promotion of types Date and Time failed to change any arguments

julia> isequal(Date(2020), Time(1))
ERROR: promotion of types Date and Time failed to change any arguments

julia> Date(2020) == 1, Date(2020) == "x", Date(2020) == DateTime(2020)
(false, false, true)
```

`isequal` is expected to be total (it is what `Dict`, `Set`, `in`, `unique`
and `==` on containers rely on), so heterogeneous containers holding both
kinds of values can throw where they should compare unequal:

```julia-repl
julia> Date(2020) in Any[Time(1)]
ERROR: promotion of types Time and Date failed to change any arguments

julia> Any[Date(2020)] == Any[Time(1)]
ERROR: promotion of types Date and Time failed to change any arguments
```

Cause: `Dates` defines `==(::TimeType, ::TimeType)` through `promote`, and
there is no promotion rule between `Time` and `Date`/`DateTime`. A
`==(::Time, ::Union{Date, DateTime}) = false` method (and the symmetric one)
would make the comparison total. Same on Julia 1.13.3 and nightly
1.15.0-DEV.720.

Found by a probe checking that `==` and `isequal` are total over pairs of
corner values (`experiments/phase4/roundtrip_contracts.jl`). Reproducer:
`date_time_equality_throws.jl` (prints REPRODUCED when a comparison throws).

Assisted-by: AI

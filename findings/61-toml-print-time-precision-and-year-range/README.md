# 61: `TOML.print` silently drops sub-millisecond `Time` digits and writes dates outside years 0000-9999 that `TOML.parse` rejects

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Body

Two round-trip failures of `TOML.print` followed by `TOML.parse`:

```julia-repl
julia> using TOML, Dates

julia> TOML.print(Dict("t" => Time(12, 0, 0, 0, 5)))       # 5 microseconds
t = 12:00:00.000

julia> TOML.parse("t = 12:00:00.000")["t"] == Time(12, 0, 0, 0, 5)
false                                                        # the fraction is gone

julia> TOML.print(Dict("d" => Date(-5, 1, 1), "e" => DateTime(10000, 1, 1)))
d = -0005-01-01
e = 10000-01-01T00:00:00.000Z

julia> TOML.parse("d = -0005-01-01")
ERROR: TOML Parser error:
none:1:5 error: parsing date/time value failed
```

TOML allows an arbitrary number of fractional-second digits, so the printer
could write the full fraction (`12:00:00.000005`) instead of truncating the
value to milliseconds without notice. Years outside 0000 to 9999 have no TOML
representation (the grammar requires four digits), so the printer could raise
an error, as it does for unsupported types, instead of producing a document
that the stdlib's own parser rejects. Same on Julia 1.13.3 and nightly
1.15.0-DEV.720.

Found by a probe round-tripping random TOML documents
(`experiments/phase4/roundtrip_contracts.jl`). Reproducer:
`toml_print_unparseable_or_lossy.jl` (prints REPRODUCED when any round trip
fails).

Assisted-by: AI

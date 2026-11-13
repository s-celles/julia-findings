# 45: `iterate(::SubString, i)` past the end throws `BoundsError` where `iterate(::String, i)` returns `nothing`

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`iterate(::SubString, i)` past the end throws `BoundsError` where `iterate(::String, i)` returns `nothing`

# Body

```julia-repl
julia> s = "abc"; sub = SubString("xabcy", 2, 4);

julia> iterate(s, 5)            # 5 > ncodeunits(s) + 1

julia> iterate(sub, 5)
ERROR: BoundsError: attempt to access 3-codeunit SubString{String} at index [5]

julia> iterate(codeunits(s), 5)
```

`iterate(s::String, i::Int)` starts with `i > ncodeunits(s) && return nothing`,
so any state past the end terminates the iteration. `iterate(s::SubString, i)`
instead does `@boundscheck checkbounds(s, i)` after the `i == ncodeunits(s) + 1`
test, so a state two or more past the end throws. Generic code that resumes a
string iterator from a saved state, or that walks several strings with one
index, sees the two types behave differently. `Test.GenericString` follows the
`String` convention (`nothing`).

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches for
`iterate SubString BoundsError past end` found no matching issue or PR
(2026-11-13).

Assisted-by: AI

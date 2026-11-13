# 55: Comment on JuliaLang/julia#60130: `Complex{Int8} // Complex{Int8}` still returns wrong components on Julia 1.13.3 (backport candidate)

- Kind: comment for `JuliaLang/julia#60130`
- Status: not posted

# Body

On the released Julia 1.13.3 the overflow fixed by this pull request is still
present and gives silently wrong results, not only errors:

```julia-repl
julia> Complex{Int8}(1, 0) // Complex{Int8}(12, 0)       # exact: 1//12
-3//28 + 0//1*im

julia> Complex{Int8}(3, 4) // Complex{Int8}(100, 0)      # exact: 3//100 + 1//25*im
75//4 + 25//1*im

julia> Complex{Int8}(1, 0) // Complex{Int8}(0, 16)       # exact: -1//16*im
ERROR: ArgumentError: invalid rational: zero(Int8)//zero(Int8)
```

`abs2` of the divisor wraps in `Int8` (`12^2 = 144` becomes `-112`, `16^2`
becomes `0`). On nightly 1.15.0-DEV.720 the dedicated
`//(::Complex{<:Integer}, ::Complex{<:Integer})` method returns the exact
components. Since the wrong results are silent on the current stable
release, this seems worth a backport to 1.13 (and 1.12 if it applies there).

Found by a probe of `Complex{T}` arithmetic against `Complex{BigInt}` for
`Int8`, `UInt8`, `Int16` and `Int64` parts.

Assisted-by: AI

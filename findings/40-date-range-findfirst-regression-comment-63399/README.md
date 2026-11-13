# 40: Comment on JuliaLang/julia#63399: This change introduced a regression for Date/DateTime ranges whose fixed

- Kind: comment for `JuliaLang/julia#63399`
- Status: not posted

This change introduced a regression for Date/DateTime ranges whose fixed
`Period` steps worked before. The new `maybe_unsigned` call only accepts
integers, but subtracting two dates produces a `Period`:

```julia-repl
julia> using Dates

julia> r = Date(2020, 1, 1):Day(1):Date(2020, 1, 3);

julia> findfirst(==(first(r)), r)
ERROR: MethodError: no method matching maybe_unsigned(::Day)

julia> findfirst(==(last(r)), r)
ERROR: MethodError: no method matching maybe_unsigned(::Day)

julia> findlast(==(first(r)), r)
ERROR: MethodError: no method matching maybe_unsigned(::Day)

julia> findfirst(==(first(r)), collect(r))
1
```

The same regression occurs for `DateTime` ranges with `Hour` or
`Millisecond` steps (`maybe_unsigned(::Millisecond)`). These calls return the
expected indices on Julia 1.13.3, before merge commit 85908d8a2e50, and fail
on official nightly 1.15.0-DEV.720 (commit 31cf85936ac).

The existing #35203 is about Month/Year ranges, whose irregular calendar
steps already failed for a different reason. This regression extends the
failure to regular Date/DateTime ranges that previously worked. A generic
fallback for non-integer step/difference types, or restricting the unsigned
overflow path to integer ranges, appears necessary.

Assisted-by: AI

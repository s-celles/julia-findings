# 44: Comment on JuliaLang/julia#36768: `findprev` on `String` accepts invalid and out-of-bounds start indices that the generic `AbstractString` path rejects

- Kind: comment for `JuliaLang/julia#36768`
- Status: not posted

# Body

A related inconsistency between the `String` fast paths and the generic
`AbstractString` methods, found by running the same searches on a `String`
and on `Test.GenericString` of the same contents:

```julia-repl
julia> using Test

julia> s = "aé,b"; g = Test.GenericString(s);

julia> findprev('a', s, 3)        # 3 is inside 'é'
1

julia> findprev('a', g, 3)
ERROR: StringIndexError: invalid index [3], valid nearby indices [2]=>'é', [4]=>','

julia> findprev("ab", s, 8)       # 8 is past the end (5 code units)

julia> findprev("ab", g, 8)
ERROR: BoundsError: attempt to access 5-codeunit GenericString at index [8]

julia> findprev("ab", s, 11)      # on a longer string: a match is returned from an invalid start
```

On Julia 1.13.3 the same leniency exists for `findnext` with a string pattern
(`findnext("ab", s, 3)` returns `nothing` where the generic method throws
`StringIndexError`); on nightly 1.15.0-DEV.720 `findnext` was made strict for
`String` too, but `findprev` still differs for both `Char` and string
patterns. `findlast("", Test.GenericString(""))` threw `BoundsError` on 1.13.3
where `String` returns `1:0`; that one is fixed on the nightly.

Whichever convention is intended (throw, or return `nothing`), the two
implementations should agree; the `String` methods currently bypass the index
checks that the generic code performs.

Observed with a differential probe over ~64,000 string operations on Julia
1.13.3 and nightly 1.15.0-DEV.720.

Assisted-by: AI

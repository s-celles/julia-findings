# 64: `Unicode.isequal_normalized` returns `false` for canonically equivalent strings whose combining marks are not in canonical order

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Body

`isequal_normalized(s1, s2)` is documented to return whether the strings are
canonically equivalent, but a string whose combining marks are stored out of
canonical order compares unequal to its own NFD and NFC forms:

```julia-repl
julia> using Unicode

julia> s = "à̖";          # grave (ccc 230) before combining grave below (ccc 220)

julia> nfd = Unicode.normalize(s, :NFD)   # "à̖": canonical reordering
"à̖"

julia> Unicode.isequal_normalized(s, nfd), Unicode.isequal_normalized(nfd, s)
(false, false)

julia> Unicode.isequal_normalized("࿆̀", "࿆̀")
false

julia> Unicode.isequal_normalized("à̖", "à̖"),
       Unicode.isequal_normalized("ȩ́", "ȩ́")
(true, true)
```

Every pair that does not involve U+0300 reorders correctly (U+0301/U+0327,
U+0301/U+0316, U+0301/U+031B, the case fixed by JuliaLang/julia#52447 for
JuliaLang/julia#52408), and `normalize(s) == normalize(nfd)` is `true` in all
cases. The cause is an off-by-one in `stdlib/Unicode/src/Unicode.jl`:

```julia
combining_class(uc::Integer) =
    0x000301 ≤ uc ≤ 0x10ffff ? unsafe_load(ccall(:utf8proc_get_property, Ptr{UInt16}, (UInt32,), uc), 2) : 0x0000
```

The first combining character is U+0300, so the lower bound should be
`0x000300`; with `0x000301` the function reports class 0 for U+0300
COMBINING GRAVE ACCENT (utf8proc says 230), the chunking loop of
`_isequal_normalized!` treats the grave accent as a starter, and the marks
after it are never reordered against it. Same on Julia 1.13.3 and nightly
1.15.0-DEV.720. The open JuliaLang/julia#64173 and the pull request
JuliaLang/julia#64457 concern the `stripmark = true` path of the same
comparison, not this bound.

Found by a probe comparing Unicode normalization with Python's
`unicodedata` and checking the documented identities
(`experiments/phase4/unicode_contracts.jl`). Reproducer:
`isequal_normalized_reordering.jl` (prints REPRODUCED when a canonically
equivalent pair compares unequal).

Assisted-by: AI

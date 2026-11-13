# 46: `titlecase(::AbstractString)` never title-cases cased non-letters and capitalizes the letter after them

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

`titlecase(::AbstractString)` never title-cases cased non-letters (small Roman numerals, circled letters) and capitalizes the letter after them

# Body

```julia-repl
julia> titlecase('ⅰ'), titlecase("ⅰ")      # U+2170 SMALL ROMAN NUMERAL ONE, category Nl
('Ⅰ', "ⅰ")

julia> titlecase("ⅰx")
"ⅰX"

julia> uppercasefirst("ⅰ")
"Ⅰ"

julia> titlecase('ⓐ'), titlecase("ⓐ")      # U+24D0 CIRCLED LATIN SMALL LETTER A, category So
('Ⓐ', "ⓐ")

julia> islowercase('ⅰ'), isletter('ⅰ')
(true, false)
```

`titlecase(s::AbstractString; wordsep = !isletter, strict = true)` treats
every character for which `wordsep` is true as a separator: it is printed
unchanged and the next character starts a word. The default `!isletter` is
true for the 16 small Roman numerals (U+2170 to U+217F, `Nl`), the 26 circled
Latin small letters (U+24D0 to U+24E9, `So`) and U+0345 COMBINING GREEK
YPOGEGRAMMENI (`Mn`), all of which are `islowercase` and have a titlecase
mapping that `titlecase(::Char)` applies. So for a one-character string
`titlecase(string(c)) != string(titlecase(c))` for exactly these 43 code
points (checked exhaustively over U+0000 to U+10FFFF), and a word that
starts with one of them keeps it in lowercase while its second character is
capitalized, which is wrong in both directions. `uppercasefirst` does not
have the problem because it maps the first character unconditionally.

Using `!Base.Unicode.iscased(c) && !isletter(c)` as the default separator, or
testing `islowercase(c) || isuppercase(c)` before treating a character as a
separator, would make the string and character versions agree.

Reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches for
`titlecase isletter`, `titlecase Char String differ`, `titlecase roman
numeral` found no matching issue or PR (2026-11-13).

Assisted-by: AI

# titlecase(::AbstractString) treats every non-letter as a word separator, so cased
# non-letters (small Roman numerals, circled letters, U+0345) are never title-cased and the
# letter after them is capitalized instead; titlecase(::Char) maps them.
@assert titlecase('ⅰ') == 'Ⅰ'
@assert titlecase("ⅰ") == "ⅰ"
@assert titlecase("ⅰx") == "ⅰX"
@assert uppercasefirst("ⅰ") == "Ⅰ"
@assert titlecase('ⓐ') == 'Ⓐ' && titlecase("ⓐ") == "ⓐ"
@assert islowercase('ⅰ') && !isletter('ⅰ')
n = count(c -> isvalid(c) && string(titlecase(c)) != titlecase(string(c)), Char(0x0):Char(0x10FFFF))
@assert n == 43
println("REPRODUCED")

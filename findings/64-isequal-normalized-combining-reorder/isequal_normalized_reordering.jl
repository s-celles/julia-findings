# Unicode.isequal_normalized returns false for canonically equivalent strings when the combining
# marks of one argument are not in canonical order: "࿆̀" (grave, ccc 230, then Tibetan
# padma gdan, ccc 220) is canonically equivalent to its NFD "࿆̀", but the streaming
# comparison does not reorder. The already ordered input "̖̀" compares fine. Related to
# JuliaLang/julia#52408 (fixed in #52447 for one reordering case). Prints REPRODUCED on failure.
using Unicode
cases = ["࿆̀", "à࿆", "̖̀", "à̖", "̖̀", "ȩ́"]
ok = true
for s in cases
    nfd = Unicode.normalize(s, :NFD)
    nfc = Unicode.normalize(s, :NFC)
    r = (Unicode.isequal_normalized(s, nfd), Unicode.isequal_normalized(s, nfc), Unicode.isequal_normalized(nfd, s))
    println(rpad(join(string.(UInt32.(collect(s)); base = 16), " "), 14), " vs NFD ", rpad(join(string.(UInt32.(collect(nfd)); base = 16), " "), 14),
        " isequal_normalized(s, NFD), (s, NFC), (NFD, s) = ", r)
    global ok &= all(r)
end
println(ok ? "AGREE on " : "REPRODUCED on ", VERSION)

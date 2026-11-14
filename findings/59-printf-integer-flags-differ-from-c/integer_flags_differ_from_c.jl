# Printf integer conversions differ from the C library in four flag rules: the `+` and space flags
# are applied to the unsigned conversions `u`, `o`, `x`, `X` (C ignores them there); a zero value
# with precision 0 prints "0" (C prints no digits); `#` with `o` always prepends a 0 (C only raises
# the precision when the first digit is not already 0); `#` with `x`/`X` prints a 0x prefix for a
# zero value (C adds the prefix only to nonzero results); and the `0` flag is honoured when the
# precision is 0 (C ignores `0` whenever a precision is given). Prints REPRODUCED when any case
# differs.
using Printf
function csnprintf(fmt, x::Int64)
    buf = Vector{UInt8}(undef, 256)
    cfmt = replace(fmt, r"([diouxX])$" => s"l\1")   # Int64 is a C long
    n = ccall(:snprintf, Cint, (Ptr{UInt8}, Csize_t, Cstring, Clong...), buf, length(buf), cfmt, x)
    return String(buf[1:n])
end
cases = [("%+x", 255), ("% u", 5), ("%+o", 8), ("%+#X", 255),
    ("%.0d", 0), ("%.0u", 0), ("%.x", 0), ("%5.0d", 0),
    ("%#o", 0), ("%#.7o", 1), ("%#o", 8),
    ("%#x", 0), ("%#X", 0), ("%#.0x", 0),
    ("%020.d", 1), ("%#09.0i", -10), ("%+08.0d", 99), ("%08.3d", 7)]
same = true
for (fmt, x) in cases
    j = Printf.format(Printf.Format(fmt), x)
    c = csnprintf(fmt, x)
    global same &= j == c
    println(rpad(fmt, 7), " ", rpad(repr(x), 5), " julia=", rpad(repr(j), 12), " c=", repr(c))
end
println(same ? "AGREE on " : "REPRODUCED on ", VERSION)

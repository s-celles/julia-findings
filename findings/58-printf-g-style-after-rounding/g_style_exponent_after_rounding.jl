# Printf `%g` picks the fixed or exponential style from the decimal exponent of the value rounded
# to P + 1 significant digits (Printf.jl calls Ryu.writeexp with precision `prec` instead of
# `prec - 1`), while C uses the exponent X of the value rounded to P significant digits. When the
# rounding carries into the next decade the style is wrong: `%.1g` of 9.5 prints "10" (two
# significant digits) where C prints "1e+01", and `%.2g` of 9.95e-5 prints "1e-04" where C prints
# "0.0001". Compares with the C library's snprintf; prints REPRODUCED when they differ.
using Printf
function csnprintf(fmt, x::Float64)
    buf = Vector{UInt8}(undef, 256)
    n = ccall(:snprintf, Cint, (Ptr{UInt8}, Csize_t, Cstring, Cdouble...), buf, length(buf), fmt, x)
    return String(buf[1:n])
end
cases = [("%.1g", 9.5), ("%.2g", 99.5), ("%.3g", 999.5), ("%g", 999999.5), ("%.0g", 9.5), ("%#.2g", 99.5),
    ("%.2g", 9.95e-5), ("%.1g", 9.5e-5), ("%g", 9.9999995e-5)]
same = true
for (fmt, x) in cases
    j = Printf.format(Printf.Format(fmt), x)
    c = csnprintf(fmt, x)
    global same &= j == c
    println(rpad(fmt, 7), " ", rpad(repr(x), 14), " julia=", rpad(repr(j), 12), " c=", repr(c))
end
println(same ? "AGREE on " : "REPRODUCED on ", VERSION)

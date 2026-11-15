# quantile with a Rational probability returns a Rational that is not the documented value: the
# default alpha = beta = 1.0 are Float64 and enter the exact arithmetic, so the result carries a
# float-derived denominator (the same mechanism as the overflow of JuliaStats/Statistics.jl#136).
# With alpha = beta = 1//1 the result is exact. A Rational alpha with the integer probabilities 0
# or 1 throws InexactError. Prints REPRODUCED when any case differs from the documented value.
using Statistics
println("Statistics ", pkgversion(Statistics), " on Julia ", VERSION)
v = [1, 2, 3, 4]
got = quantile(v, 1//3)
println("quantile([1,2,3,4], 1//3)                    = ", got, "   expected 2")
exact = quantile(v, 1//3; alpha = 1//1, beta = 1//1)
println("quantile(..., 1//3; alpha=1//1, beta=1//1)   = ", exact)
r = try
    repr(quantile(v, 0; alpha = 1//2, beta = 1//2))
catch err
    "ERROR: " * first(sprint(showerror, err), 40)
end
println("quantile(..., 0; alpha=1//2, beta=1//2)      = ", r, "   expected 1")
ok = got == 2 && exact == 2 && r == "1//1"
println(ok ? "AGREE on " : "REPRODUCED on ", VERSION)

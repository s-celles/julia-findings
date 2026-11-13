# On Julia 1.13.3, Complex{Int8} // Complex{Int8} computes abs2 of the divisor in Int8, which
# wraps, and returns wrong components; fixed on the nightly by JuliaLang/julia#60130.
z, w = Complex{Int8}(1, 0), Complex{Int8}(12, 0)
got = z // w
fixed = got == (1 // 12) + (0 // 1) * im
wrong = got == (-3 // 28) + (0 // 1) * im
@assert fixed || wrong
if wrong
    @assert Complex{Int8}(3, 4) // Complex{Int8}(100, 0) == (75 // 4) + (25 // 1) * im  # exact: 3//100 + 1//25 im
    @assert (try Complex{Int8}(1, 0) // Complex{Int8}(0, 16) catch e; e end) isa ArgumentError  # "zero//zero"
    println("REPRODUCED (1.13 behaviour)")
else
    @assert Complex{Int8}(3, 4) // Complex{Int8}(100, 0) == (3 // 100) + (1 // 25) * im
    println("REPRODUCED (fixed: exact components)")
end

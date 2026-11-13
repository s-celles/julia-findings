# parse(Complex{T}, s) parses each part as a magnitude and negates it afterwards, so the
# string of typemin cannot be read back; and the "Inf*im" form that string() produces for an
# infinite imaginary part is not accepted either.
z = Complex{Int8}(-128, -128)
@assert (try parse(Complex{Int8}, string(z)) catch e; e end) isa OverflowError
@assert parse(Int8, "-128") == -128
@assert parse(Complex{Int8}, "-128im") == Complex{Int8}(0, -128)   # bare imaginary works
@assert (try parse(Complex{Int}, "0 - 9223372036854775808im") catch e; e end) isa OverflowError
w = 0.0 + Inf * im
@assert string(w) == "0.0 + Inf*im"
@assert (try parse(Complex{Float64}, string(w)) catch e; e end) isa ArgumentError
@assert parse(Complex{Float64}, "Inf + 1.0im") == Inf + 1.0im
println("REPRODUCED")

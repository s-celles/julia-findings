# Reversing an unsigned StepRange with a step above typemax(signed) throws InexactError.
r = UInt8(2):UInt8(255):UInt8(2)
@assert collect(r) == UInt8[2]
for f in (reverse, x -> collect(Iterators.reverse(x)), x -> foldr(-, x))
    got = try f(r) catch err; err end
    @assert got isa InexactError
end
@assert reverse(collect(r)) == UInt8[2]
println("REPRODUCED")

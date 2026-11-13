# iterate(::SubString, i) past the end throws BoundsError, iterate(::String, i) returns nothing.
s = "abc"
sub = SubString("xabcy", 2, 4)
@assert iterate(s, 5) === nothing
@assert (try iterate(sub, 5) catch e; e end) isa BoundsError
@assert iterate(Base.CodeUnits(s), 5) === nothing
println("REPRODUCED")

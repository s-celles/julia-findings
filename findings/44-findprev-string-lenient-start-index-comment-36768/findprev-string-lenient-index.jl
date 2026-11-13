# findprev on a String accepts an invalid or out-of-bounds start index and returns a result,
# while the generic AbstractString path (Test.GenericString) throws.
using Test
s = "aé,b"
g = Test.GenericString(s)
@assert findprev('a', s, 3) == 1            # 3 is inside 'é'
@assert (try findprev('a', g, 3) catch e; e end) isa StringIndexError
@assert findprev("ab", s, 8) === nothing    # 8 is past the end
@assert (try findprev("ab", g, 8) catch e; e end) isa BoundsError
println("REPRODUCED")

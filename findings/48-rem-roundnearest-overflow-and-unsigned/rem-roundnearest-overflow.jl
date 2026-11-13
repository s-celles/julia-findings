# rem(x, y, RoundNearest) goes through div(x, y, RoundNearest), so it throws DivideError when
# the quotient overflows although the remainder (0) is representable, and for unsigned types it
# returns a wrapped negative remainder.
@assert rem(typemin(Int), -1) == 0
@assert (try rem(typemin(Int), -1, RoundNearest) catch e; e end) isa DivideError
@assert (try rem(Int8(-128), Int8(-1), RoundNearest) catch e; e end) isa DivideError
@assert rem(UInt(2), UInt(3), RoundNearest) == typemax(UInt)   # exact remainder is -1
@assert rem(UInt8(2), UInt8(3), RoundNearest) == 0xff
@assert rem(2, 3, RoundNearest) == -1
println("REPRODUCED")

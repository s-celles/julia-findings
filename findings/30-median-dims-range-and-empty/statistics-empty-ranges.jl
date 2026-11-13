# Statistics on empty ranges return values where the array methods throw; cor/cov skip the
# empty check when both arguments are the same object, which equal ranges always are.
using Statistics
@assert isnan(median(1:0))
@assert (try median(Int[]) catch err; err end) isa ArgumentError
@assert cor(1:0, 1:0) == 1.0
@assert cov(1:0, 1:0) == 0.0
@assert (try cor(Int[], Int[]) catch err; err end) isa ArgumentError
v = Int[]
@assert cor(v, v) == 1.0
println("REPRODUCED")

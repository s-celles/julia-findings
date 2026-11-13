# var(::AbstractRange) uses the closed form abs2(step) * (l + 1) * l / 12 in the element type,
# which wraps for narrow integers and for long Int64 ranges.
using Statistics

r = Int8(-1):Int8(126):Int8(127)
@assert var(r) == -7934.0
@assert var(collect(r)) == 7938.0
@assert (try std(r) catch e; e end) isa DomainError
long = 1:3_000_000_000
@assert var(long) < 0
@assert (BigInt(length(long))^2 - 1) / 12 ≈ 7.5e17
println("REPRODUCED")

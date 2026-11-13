# median(r; dims=1) on a range tries to sort the range in place; median of an empty range is NaN.
using Statistics

got = try
    median(1:3; dims=1)
catch err
    err
end
@assert got isa CanonicalIndexError
@assert median([1, 2, 3]; dims=1) == [2.0]
@assert isnan(median(1:0))
@assert (try median(Int[]) catch e; e end) isa ArgumentError
println("REPRODUCED")

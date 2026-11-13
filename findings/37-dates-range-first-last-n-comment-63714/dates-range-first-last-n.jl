# first(r, n) and last(r, n) route Date ranges through checked_sub on Dates.
using Dates

r = Date(2020, 1, 1):Day(1):Date(2020, 1, 2)
@assert collect(r) == [Date(2020, 1, 1), Date(2020, 1, 2)]

for f in (x -> first(x, 2), x -> last(x, 2))
    got = try
        f(r)
    catch err
        err
    end
    @assert got isa MethodError
end

@assert first(collect(r), 2) == collect(r)
@assert last(collect(r), 2) == collect(r)
println("REPRODUCED")

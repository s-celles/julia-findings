# argmin/argmax assume that every AbstractRange step can be compared with 0.
using Dates

r = Date(2020, 1, 1):Day(1):Date(2020, 1, 2)
@assert collect(r) == [Date(2020, 1, 1), Date(2020, 1, 2)]

for f in (argmin, argmax)
    got = try
        f(r)
    catch err
        err
    end
    @assert got isa MethodError
end

@assert argmin(collect(r)) == 1
@assert argmax(collect(r)) == 2
println("REPRODUCED")

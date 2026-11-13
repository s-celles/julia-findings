# JuliaLang/julia#63399 regressed range findfirst/findlast for fixed Date periods.
using Dates

r = Date(2020, 1, 1):Day(1):Date(2020, 1, 3)
if VERSION < v"1.15.0-DEV"
    @assert findfirst(==(first(r)), r) == 1
    @assert findfirst(==(last(r)), r) == 3
    @assert findlast(==(first(r)), r) == 1
else
    for f in (
        x -> findfirst(==(first(x)), x),
        x -> findfirst(==(last(x)), x),
        x -> findlast(==(first(x)), x),
    )
        got = try
            f(r)
        catch err
            err
        end
        @assert got isa MethodError
    end
end

@assert findfirst(==(first(r)), collect(r)) == 1
@assert findfirst(==(last(r)), collect(r)) == 3
@assert findlast(==(first(r)), collect(r)) == 1
println("REPRODUCED")

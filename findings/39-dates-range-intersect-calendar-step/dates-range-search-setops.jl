# Calendar-period StepRanges reach arithmetic-only search and set-operation paths.
using Dates

r = Date(2020, 1, 31):Month(1):Date(2020, 2, 29)
expected = collect(r)
@assert expected == [Date(2020, 1, 31), Date(2020, 2, 29)]

found = try
    findfirst(==(first(r)), r)
catch err
    err
end
overlap = try
    intersect(r, r)
catch err
    err
end

@assert found isa Exception
@assert overlap isa Exception
@assert findfirst(==(first(r)), expected) == 1
@assert intersect(expected, expected) == expected
println("REPRODUCED")

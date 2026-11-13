# var(r; dims=1) on a range hits a kwcall ambiguity between the range and the array varm methods.
using Statistics

got = try
    var(1:3; dims=1)
catch err
    err
end
@assert got isa MethodError
@assert var([1, 2, 3]; dims=1) == [1.0]
println("REPRODUCED")

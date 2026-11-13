# Range-preserving broadcast can change elementwise values or throw before iteration.
float_range = range(Float16(0.1); step = Float16(0.1), length = 1)
@assert isnan(only(collect(float_range ./ Float16(0))))
@assert isinf(only(collect(float_range) ./ Float16(0)))

unsigned_range = UInt64(1):UInt64(2)
err = try
    unsigned_range ./ Int16(-2)
catch caught
    caught
end
@assert err isa InexactError
@assert collect(unsigned_range) ./ Int16(-2) == [-0.5, -1.0]
println("REPRODUCED")

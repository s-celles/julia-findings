# a:s:b with Float16 endpoints fails with InexactError when the length overflows Float16.
got = try Float16(-1):Float16(6e-8):Float16(1) catch err; err end
@assert got isa InexactError
@assert length(Float32(-1):Float32(6e-8):Float32(1)) == 33333335
println("REPRODUCED")

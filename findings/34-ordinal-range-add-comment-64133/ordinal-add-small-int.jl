r = UInt8(127):UInt8(128)
result = r + r
err = try
    collect(result)
    nothing
catch caught
    caught
end

@assert err isa InexactError
@assert collect(r) + collect(r) == UInt8[254, 0]
println("REPRODUCED")

# parse(T, s) consumes a leading sign only for signed T: "+5" parses as Int8 and BigInt but is
# rejected for unsigned types with a message that calls '+' an invalid digit.
@assert parse(Int8, "+5") == 5 && parse(BigInt, "+5") == 5 && parse(Int8, "-0x5") == -5
err = try parse(UInt8, "+5") catch e; e end
@assert err isa ArgumentError && occursin("invalid base 10 digit '+'", sprint(showerror, err))
@assert tryparse(UInt8, "+5") === nothing
@assert (try parse(UInt8, "-0") catch e; e end) isa ArgumentError   # the value 0 would fit
@assert parse(UInt8, "0x5") == 5                                   # prefixes are fine
println("REPRODUCED")

# A floating range can reject one of its own yielded elements, breaking subset reflexivity.
r = range(Float16(-32752); step = Float16(10), length = 2)
elements = collect(r)

@assert elements == Float16[-32752, -32736]
@assert !(elements[2] in r)
@assert !issubset(r, r)
@assert issubset(elements, elements)
println("REPRODUCED")

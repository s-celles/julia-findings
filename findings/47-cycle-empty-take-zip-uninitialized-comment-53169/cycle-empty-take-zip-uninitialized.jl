# Iterators.cycle of an empty collection reports IsInfinite, so take, first(…, n) and zip trust a
# length that the iteration never delivers; collect then returns uninitialized storage.
# (JuliaLang/julia#53169 reports first(cycle(Int[]), 5); these are the take, zip, tuple and String surfaces.)
t = collect(Iterators.take(Iterators.cycle(Int[]), 2))
@assert length(t) == 2                      # should be empty
z = collect(zip(Iterators.cycle(Int[]), 1:2))
@assert length(z) == 2                      # should be empty; values are whatever memory held
u = collect(Iterators.take(Iterators.cycle(()), 2))
@assert eltype(u) === Union{} && length(u) == 2 && !isassigned(u, 1)
c = collect(Iterators.take(Iterators.cycle(""), 2))
@assert length(c) == 2                      # two Chars read from uninitialized bytes
@assert isempty(collect(Iterators.cycle(Int[], 2)))   # the counted form is correct
println("REPRODUCED")

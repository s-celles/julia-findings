# issorted and unique on Float16 ranges describe the model, not the stored elements.
L = LinRange(Float16(6e-8), Float16(0), 5)
@assert issorted(L) && !issorted(collect(L))
S = range(Float16(16376); step=Float16(0.9995), length=5)
@assert length(unique(S)) == 5 && length(unique(collect(S))) == 1
println("REPRODUCED")

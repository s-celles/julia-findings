# A SymTridiagonal with a NaN off-diagonal entry cannot be broadcast at all: the structured copyto!
# verifies symmetry with ==, and NaN == NaN is false, so S .* 2, S .+ 0, identity.(S) all throw
# "broadcasted assignment breaks symmetry". Non-broadcast scaling and the dense path work. Prints REPRODUCED.
using LinearAlgebra
S = SymTridiagonal([1.0, 2.0, 3.0], [NaN, 5.0])
@assert (try S .* 2; false catch err; err isa ArgumentError end)        # broadcast: throws
@assert (try S .+ 0; false catch err; err isa ArgumentError end)
@assert S * 2 isa SymTridiagonal                                         # scaling: fine (control)
@assert size(Matrix(S) .* 2) == (3, 3)                                   # dense broadcast: fine (control)
@assert SymTridiagonal([1.0, 2.0, 3.0], [4.0, 5.0]) .* 2 isa SymTridiagonal   # no NaN: fine (control)
println("SymTridiagonal with NaN off-diagonal: S .* 2 throws ArgumentError (breaks symmetry); S * 2 works")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

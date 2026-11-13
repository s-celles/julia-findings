# transpose!(::BitMatrix, ::BitMatrix) ORs into a destination that it assumes is zeroed.
using LinearAlgebra

source = BitMatrix([false;;])
destination = BitMatrix([true;;])
result = transpose!(destination, source)

@assert result === destination
@assert only(destination) # Wrong: the false source bit did not clear the old true bit.

dense_source = Bool[false;;]
dense_destination = Bool[true;;]
dense_result = transpose!(dense_destination, dense_source)

@assert dense_result === dense_destination
@assert !only(dense_destination)
println("REPRODUCED")

# BitArray-specific kron! methods skip zero blocks instead of overwriting them.
using LinearAlgebra

vector_destination = trues(1)
vector_result = kron!(vector_destination, falses(1), trues(1))
@assert vector_result === vector_destination
@assert only(vector_destination) # Wrong: the zero product left the old true bit.
@assert !only(kron!(Bool[true], Bool[false], Bool[true]))

matrix_destination = trues(1, 1)
matrix_result = kron!(matrix_destination, falses(1, 1), trues(1, 1))
@assert matrix_result === matrix_destination
@assert only(matrix_destination) # The BitMatrix specialization has the same defect.
@assert !only(kron!(Bool[true;;], Bool[false;;], Bool[true;;]))

println("REPRODUCED")

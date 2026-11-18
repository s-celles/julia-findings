# Solving with a 1x1 covector left-hand side -- transpose(v) \ b or v' \ b where v is a length-1
# Vector -- throws MethodError (no method matching istriu(::Vector, ::Int)) instead of solving, while
# the dense 1x1 Matrix solves and the 1xn (n>=2) covector works. The square-\ path tests triangularity
# with istriu/istril, which forward to the parent Vector of the Transpose/Adjoint wrapper instead of
# treating it as a 1x1 matrix. Prints REPRODUCED.
using LinearAlgebra
v = [3.0]
@assert Matrix(transpose(v)) \ ones(1) == [1/3]        # dense 1x1: correct
@assert length(transpose([1.0,2.0]) \ ones(1)) == 2    # 1x2 covector: works (control)
t_threw = try transpose(v) \ ones(1); false catch err; err isa MethodError end
a_threw = try v' \ ones(1);          false catch err; err isa MethodError end
@assert t_threw                                        # transpose(v) 1x1: THROWS MethodError(istriu)
@assert a_threw
println("transpose(v)\\b threw MethodError=", t_threw, "  v'\\b threw=", a_threw, "  (dense gives [1/3])")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

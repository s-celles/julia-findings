# sylvester and lyap on matrices whose float type is not a BLAS type (Float16, ComplexF16, BigFloat,
# Complex{BigFloat}, Rational{BigInt}) overflow the stack: the generic method promotes the inputs to
# `float(eltype)` and calls itself, but only `BlasFloat` element types have a terminal method, so
# the promoted call hits the generic method again, forever. Prints REPRODUCED when a StackOverflowError
# is raised; the expected behaviour would be a result (a generic solver) or a MethodError.
using LinearAlgebra
results = String[]
for T in (Float16, ComplexF16, BigFloat, Rational{BigInt})
    A = T[3 1; 0 2]
    r = try
        lyap(A, A); "ok"
    catch err
        string(nameof(typeof(err)))
    end
    s = try
        sylvester(A, A, A); "ok"
    catch err
        string(nameof(typeof(err)))
    end
    println(rpad(string(T), 18), " lyap: ", rpad(r, 20), " sylvester: ", s)
    push!(results, r, s)
end
println("Float32 for comparison: ", typeof(lyap(Float32[3 1; 0 2], Float32[3 1; 0 2])))
println(any(==("StackOverflowError"), results) ? "REPRODUCED on " : "AGREE on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

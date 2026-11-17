# `\` and `inv` of a SymTridiagonal matrix with Rational elements use an unpivoted LDLᵀ
# factorization (ldlt), so a zero diagonal pivot makes them fail where the dense LU succeeds:
# on an INVERTIBLE matrix they throw ZeroPivotException, and on a SINGULAR matrix they return
# 1//0 (rational infinity) instead of raising SingularException. The dense Matrix path pivots
# and is correct in both cases. Same root cause as JuliaLang/LinearAlgebra.jl#601 (float case:
# inv returns NaN). Prints REPRODUCED.
using LinearAlgebra

# C1: invertible SymTridiagonal{Rational}, det = -1, but structured solve/inv throw.
S1 = SymTridiagonal(Rational{Int}[0, 0], Rational{Int}[1])      # [0 1; 1 0]
@assert det(S1) == -1          # invertible
dense1 = Matrix(S1) \ Rational{Int}[1, 1]
@assert dense1 == Rational{Int}[1, 1]                            # dense is correct
structured_threw = try
    S1 \ Rational{Int}[1, 1]
    false
catch err
    err isa LinearAlgebra.ZeroPivotException
end
inv_threw = try
    inv(S1); false
catch err
    err isa LinearAlgebra.ZeroPivotException
end

# C2: singular SymTridiagonal{Rational}, det = 0; dense raises, structured returns 1//0.
S2 = SymTridiagonal(Rational{Int}[-3, -2, 1], Rational{Int}[-3, 1])
@assert det(S2) == 0                                            # singular
dense_singular_raised = try
    Matrix(S2) \ Rational{Int}[1, 0, 1]; false
catch err
    err isa LinearAlgebra.SingularException
end
structured_x = S2 \ Rational{Int}[1, 0, 1]
structured_returned_inf = any(x -> x.den == 0, structured_x)    # 1//0 entries

@assert structured_threw                 "C1: structured solve should throw ZeroPivotException"
@assert inv_threw                        "C1: structured inv should throw ZeroPivotException"
@assert dense_singular_raised            "C2: dense should raise SingularException"
@assert structured_returned_inf          "C2: structured solve should return 1//0 entries"

println("C1 invertible: dense ", dense1, " ; structured \\ threw ZeroPivotException=", structured_threw, ", inv threw=", inv_threw)
println("C2 singular:   dense raised SingularException=", dense_singular_raised, " ; structured \\ = ", structured_x)
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

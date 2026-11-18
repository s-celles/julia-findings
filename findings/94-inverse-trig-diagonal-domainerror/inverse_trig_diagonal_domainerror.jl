# acos/asin/acosh/atanh of a real diagonal (dense) matrix whose entries lie outside the real domain of
# the scalar function throw DomainError, while the same matrices with one non-zero off-diagonal entry
# (or wrapped in Symmetric, for atanh on 1.13+) return the complex principal value. The isdiag fast
# path (JuliaLang/julia#56483, LinearAlgebra 1.12) applies the real scalar function without the
# complex promotion that sqrt/log/^ perform. Prints REPRODUCED.
using LinearAlgebra
function domainerror(f)
    try
        f(); return false
    catch e
        e isa DomainError || rethrow()
        return true
    end
end
# non-diagonal companions: complex principal values, as on Julia 1.10/1.11 for the diagonal inputs
@assert eltype(acosh([0.5 1; 0 2.0])) <: Complex
@assert eltype(asin([2.0 1; 0 2.0])) <: Complex
@assert eltype(acos([2.0 1; 0 2.0])) <: Complex
@assert eltype(acosh(Symmetric([0.5 0; 0 2.0]))) <: Complex       # the Symmetric path promotes
# the fixed class, for comparison: the diagonal fast path promotes to complex
@assert eltype(sqrt([-1.0 0; 0 2.0])) <: Complex
@assert eltype(log([-1.0 0; 0 2.0])) <: Complex
# diagonal dense inputs: DomainError
@assert domainerror(() -> acosh([0.5 0; 0 2.0]))                   # WRONG (Julia 1.10/1.11: complex result)
@assert domainerror(() -> asin([2.0 0; 0 2.0]))                    # WRONG (Julia 1.10/1.11: complex result)
@assert domainerror(() -> acos([2.0;;]))                           # WRONG (Julia 1.10/1.11: complex result)
@assert domainerror(() -> atanh([2.0;;]))                          # WRONG (all versions; Symmetric path is complex on 1.13+)
println("acosh([0.5 0; 0 2.0]) throws DomainError; acosh([0.5 1; 0 2.0]) returns the complex principal value")
println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

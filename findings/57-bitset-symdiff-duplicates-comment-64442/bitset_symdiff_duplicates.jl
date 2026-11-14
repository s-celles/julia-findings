# symdiff!(::BitSet, itr) toggles every element of `itr`, so a value repeated an even number of
# times in `itr` is dropped again, while Set and Vector treat `itr` as a set of distinct values.
# Reported upstream as JuliaLang/julia#64145 and fixed on master by JuliaLang/julia#64442
# (2026-11-11); still present on Julia 1.13.3. Prints REPRODUCED when the mismatch is observed.
function main()
    itr = [0, 0]
    bits = symdiff!(BitSet([1]), itr)
    set = symdiff!(Set([1]), itr)
    vec = symdiff([1], itr)
    println("symdiff!(BitSet([1]), [0, 0]) = ", bits)
    println("symdiff!(Set([1]), [0, 0])    = ", set)
    println("symdiff([1], [0, 0])          = ", vec)
    same = Set(bits) == set == Set(vec)
    same && println("AGREE on ", VERSION)
    if !same
        println("REPRODUCED on ", VERSION)
        @assert bits == BitSet([1]) && set == Set([0, 1]) && Set(vec) == Set([0, 1])
    end
end
main()

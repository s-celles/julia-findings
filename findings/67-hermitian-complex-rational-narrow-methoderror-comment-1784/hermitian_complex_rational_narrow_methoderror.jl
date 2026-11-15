# det, \ and bunchkaufman on a Hermitian matrix with Complex{Rational{Int16}} or Complex{Rational{Int32}}
# elements throw MethodError: no method matching generic_adr1!(::Char, ::Rational{Int64}, ...) on
# LinearAlgebra 1.13.0: the generic Bunch-Kaufman kernel mixes a Rational{Int64} scalar with the
# narrow complex rational storage. Complex{Rational{Int64}} and real Rational{Int16} work. Fixed on
# master by JuliaLang/LinearAlgebra.jl#1784 (generic Bunch-Kaufman rewrite). Prints REPRODUCED
# when the computation throws.
using LinearAlgebra
H = Hermitian(Complex{Rational{Int16}}[6 1//2-1//2im; 1//2+1//2im 3])
r = try
    repr(det(H))
catch err
    "ERROR: " * first(sprint(showerror, err), 90)
end
println("det(H)        = ", r)
s = try
    repr(H \ Complex{Rational{Int16}}[1, 2])
catch err
    "ERROR: " * first(sprint(showerror, err), 90)
end
println("H \\ b         = ", s)
println("det(Matrix(H))= ", det(Matrix(H)), "   Complex{Rational{Int64}}: det = ", det(Hermitian(Complex{Rational{Int64}}.(Matrix(H)))))
println(startswith(r, "ERROR") || startswith(s, "ERROR") ? "REPRODUCED on " : "AGREE on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra))

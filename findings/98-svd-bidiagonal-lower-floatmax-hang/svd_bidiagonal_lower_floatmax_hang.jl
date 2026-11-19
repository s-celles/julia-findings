# svd of a lower Bidiagonal with finite entries, Bidiagonal([1.0, floatmax(), 3.0], [2.0, floatmax()], :L),
# never returns: LAPACK bdsdc (uplo = 'L') rotates the matrix to upper form, the rotation overflows and
# dbdsqr loops forever on a NaN threshold (the mechanism of Reference-LAPACK/lapack#1409). The upper
# Bidiagonal, the dense matrix and svdvals return. The entries are finite, so the Inf/NaN checks added by
# JuliaLang/LinearAlgebra.jl#1798 do not trigger. The hanging call runs in a child process that is killed
# after a timeout, so this script always terminates. Prints REPRODUCED.
using LinearAlgebra
fm = floatmax(Float64)
dv, ev = [1.0, fm, 3.0], [2.0, fm]
BL, BU = Bidiagonal(dv, ev, :L), Bidiagonal(dv, ev, :U)
@assert all(isfinite, Matrix(BL))
svd(BU)                                     # upper form: returns (overflowed singular values)
svd(Matrix(BL))                             # dense: returns
svdvals(BL)                                 # lower form without vectors: returns
code = "using LinearAlgebra; fm = floatmax(Float64); svd(Bidiagonal([1.0, fm, 3.0], [2.0, fm], :L)); println(\"returned\")"
cmd = `$(Base.julia_cmd()) --startup-file=no -e $code`
out = IOBuffer()
p = run(pipeline(cmd; stdout=out, stderr=devnull); wait=false)
limit = 60.0; t0 = time()
while process_running(p) && time() - t0 < limit
    sleep(0.5)
end
if process_running(p)
    kill(p)
    println("svd(Bidiagonal([1.0, floatmax(), 3.0], [2.0, floatmax()], :L)) still running after $(limit) s (killed)")
    println("REPRODUCED on ", VERSION, " LinearAlgebra ", pkgversion(LinearAlgebra), " LAPACK ", LAPACK.version())
else
    println("child exited with code ", p.exitcode, ": ", String(take!(out)))
    println("NOT reproduced on ", VERSION)
end

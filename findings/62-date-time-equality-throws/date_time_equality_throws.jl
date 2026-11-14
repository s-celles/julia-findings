# `==` and `isequal` between a Date or DateTime and a Time throw a promotion error instead of
# returning false, so `in`, `==` on containers and `Set`/`Dict` lookups holding both kinds of
# values can throw. `Date == 1` and `Date == "x"` return false as expected.
# Prints REPRODUCED when any of the comparisons throws.
using Dates
function try_eval(label, f)
    r = try
        repr(f())
    catch err
        "ERROR: " * first(sprint(showerror, err), 70)
    end
    println(rpad(label, 34), " -> ", r)
    return !startswith(r, "ERROR")
end
checks = [
    ("Date(2020) == Time(1)", () -> Date(2020) == Time(1)),
    ("isequal(Date(2020), Time(1))", () -> isequal(Date(2020), Time(1))),
    ("DateTime(2020) == Time(1)", () -> DateTime(2020) == Time(1)),
    ("Date(2020) in Any[Time(1)]", () -> Date(2020) in Any[Time(1)]),
    ("Any[Date(2020)] == Any[Time(1)]", () -> Any[Date(2020)] == Any[Time(1)]),
    ("Date(2020) == 1", () -> Date(2020) == 1),
    ("Date(2020) == \"x\"", () -> Date(2020) == "x"),
    ("Date(2020) == DateTime(2020)", () -> Date(2020) == DateTime(2020)),
]
ok = [try_eval(l, f) for (l, f) in checks]
println(all(ok) ? "AGREE on " : "REPRODUCED on ", VERSION)

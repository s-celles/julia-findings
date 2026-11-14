# TOML.print writes values that TOML.parse cannot read back or reads back differently:
#  * a Time with microseconds or nanoseconds is written with three fractional digits, so the
#    sub-millisecond part is silently dropped ("12:00:00.000" for Time(12, 0, 0, 0, 5));
#  * a Date or DateTime outside years 0000 to 9999 is written as "-0005-01-01" or
#    "10000-01-01T00:00:00.000Z", which the parser rejects (TOML requires four-digit years).
# Prints REPRODUCED when any round trip fails.
using TOML, Dates
function roundtrip(v)
    s = sprint(TOML.print, Dict("v" => v))
    r = try
        TOML.parse(s)["v"]
    catch err
        "PARSE ERROR: " * first(sprint(showerror, err), 60)
    end
    println(rpad(repr(v), 40), " printed as ", repr(rstrip(s)), " -> ", repr(r))
    return isequal(r, v)
end
cases = Any[Time(12, 0, 0, 0, 5), Time(12, 0, 0, 0, 0, 7), Time(1, 2, 3, 4, 5, 6), Date(-5, 1, 1), Date(10000, 1, 1),
    DateTime(10000, 1, 1), DateTime(-1, 12, 31), Date(999, 1, 1), DateTime(2020, 1, 1, 12, 0, 0, 123), Time(1, 2, 3, 4)]
ok = map(roundtrip, cases)
println(all(ok) ? "AGREE on " : "REPRODUCED on ", VERSION)

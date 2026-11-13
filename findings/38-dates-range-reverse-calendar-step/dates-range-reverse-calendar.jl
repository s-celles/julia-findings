# Reversing Month/Year ranges is not element-preserving at calendar boundaries.
using Dates

months = Date(2020, 1, 31):Month(1):Date(2020, 2, 29)
@assert collect(months) == [Date(2020, 1, 31), Date(2020, 2, 29)]
@assert collect(reverse(months)) == [Date(2020, 2, 29), Date(2020, 1, 29)]
@assert collect(reverse(months)) != reverse(collect(months))

years = Date(2020, 2, 29):Year(1):Date(2021, 2, 28)
@assert collect(years) == [Date(2020, 2, 29), Date(2021, 2, 28)]
@assert collect(reverse(years)) == [Date(2021, 2, 28), Date(2020, 2, 28)]
@assert collect(reverse(years)) != reverse(collect(years))

descending = Date(2020, 3, 31):Month(-1):Date(2020, 2, 29)
@assert collect(sort(descending)) == [Date(2020, 2, 29), Date(2020, 3, 29)]
@assert collect(sort(descending)) != sort(collect(descending))
println("REPRODUCED")

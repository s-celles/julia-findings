# 31: Comment on JuliaLang/julia#29576: The ordinary unsigned-unit-step case from this issue now works, but a

- Kind: comment for `JuliaLang/julia#29576`
- Status: posted ([JuliaLang/julia#29576](https://github.com/JuliaLang/julia/issues/29576#issuecomment-6854592786))

The ordinary unsigned-unit-step case from this issue now works, but a
large-step `StepRange` still fails while being reversed:

```julia-repl
julia> r = UInt8(2):UInt8(255):UInt8(2);

julia> collect(r)
1-element Vector{UInt8}:
 0x02

julia> reverse(r)
ERROR: InexactError: convert(Int8, 0xff)

julia> collect(Iterators.reverse(r))
ERROR: InexactError: convert(Int8, 0xff)

julia> foldr(-, r)
ERROR: InexactError: convert(Int8, 0xff)
```

Reversing a `StepRange` negates its step. For an unsigned `T`, the negation
goes through the signed counterpart, so a step above `typemax(signed(T))`
cannot be converted. `UInt64` steps above `2^63` fail the same way. This also
affects `r[end:-1:1]` and `-r` for the same ranges.

The example reproduces on Julia 1.13.3 and nightly 1.15.0-DEV.720. The open
#64126 is another remaining unsigned-reversal case, in range slicing. Searches
for `reverse StepRange unsigned InexactError` initially missed this closed
issue; the broader query `reverse unsigned range` found #29576 and #64126.

Assisted-by: AI

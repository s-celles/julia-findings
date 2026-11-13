# 01: Indexing a `StepRange` by a range of a narrower signed type can compute the new step in the narrow type and wrap to zero

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

Indexing a `StepRange` by a range of a narrower signed type can compute the new step in the narrow type and wrap to zero

# Body

```julia
julia> r = 0xff:0x80:0xff        # one element: 0xff
0xff:0x80:0xff

julia> r[Int8(1):Int8(6):Int8(1)]  # selects element 1
ERROR: ArgumentError: step cannot be zero

julia> r[1:6:1]                    # same selection with Int indices
255:768:255

julia> collect(r)[Int8(1):Int8(6):Int8(1)]
1-element Vector{UInt8}:
 0xff
```

Expected: a one-element range containing `0xff`, as for `collect(r)` and for
`Int` indices.

Cause (Julia 1.13.0, `base/range.jl`, `getindex(r::StepRange, s::AbstractRange{T}) where {T<:Integer}`):

```julia
st = r.step       # 0x80 :: UInt8
st *= step(s)     # 0x80 * Int8(6) promotes to UInt8 and wraps to 0x00
...
return range(start, stop; step=st)   # step 0 -> ArgumentError
```

The product of the two steps is computed in `promote_type(typeof(r.step),
eltype(s))`, which can be narrower than the true step. When `length(s) <= 1`
the step of the result does not matter. Otherwise the wrapped step can also
give wrong elements, not only an error.

Possible fix: compute the new step in a type wide enough for the product (or
in `typeof(r.step)` with a checked multiply that falls back to a collected or
`StepRangeLen` result). For `length(s) <= 1`, keep `r.step`.

Reproduced on Julia 1.10, 1.12, 1.13.0 and master (1.15.0-DEV.581, commit 7959b61a8f2, 2026-11-07). Closest existing issue: #63679
(unsigned indices into a descending range), which is a different symptom.

Found with Concolic.jl, a concolic testing prototype, by comparing range
operations with the same operations on the collected vector.

Assisted-by: AI

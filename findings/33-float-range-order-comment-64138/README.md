# 33: Comment on JuliaLang/julia#64138: The same model-versus-elements gap also affects `issorted`, and reproduces

- Kind: comment for `JuliaLang/julia#64138`
- Status: posted ([JuliaLang/julia#64138](https://github.com/JuliaLang/julia/issues/64138#issuecomment-6854593861))

The same model-versus-elements gap also affects `issorted`, and reproduces
particularly compactly with `Float16`:

```julia-repl
julia> r = LinRange(Float16(6e-8), Float16(0), 5);

julia> collect(r)
5-element Vector{Float16}:
 6.0e-8
 6.0e-8
 0.0
 0.0
 0.0

julia> issorted(r), issorted(collect(r))
(true, false)
```

`issorted(::AbstractRange)` infers the answer from the sign of the modeled
step. Rounding makes the first two actual elements equal and the next element
smaller, so the collected sequence is not sorted in ascending order.

The probe also rediscovered the issue's `unique`/`allunique` family with
`StepRangeLen`, `LinRange`, and `range(a, b; length)`; those are exact
duplicates and are not separate findings. The `issorted` sibling reproduces
on Julia 1.13.3 and nightly 1.15.0-DEV.720. Searches for `issorted
AbstractRange step`, `LinRange issorted`, and `Float16 LinRange duplicate
values` found no more specific report; the broader `unique AbstractRange`
search found #64138.

Assisted-by: AI

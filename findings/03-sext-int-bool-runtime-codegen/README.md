# 03: Constant folding `Core.Intrinsics.sext_int(T, ::Bool)` disagrees with compiled code

- Kind: issue for `JuliaLang/julia`
- Status: not posted

# Title

Constant folding `Core.Intrinsics.sext_int(T, ::Bool)` disagrees with compiled code

# Body

```julia
b = Ref(true);

Base.invokelatest(Core.Intrinsics.sext_int, Int16, b[])  # dynamic C runtime call
# 1

f16(x::Bool) = Core.Intrinsics.sext_int(Int16, x)
f16(b[])  # compiled intrinsic
# -1

Base.invokelatest(Core.Intrinsics.sext_int, Int8, b[])
# ErrorException("SExt: output bitsize must be > input bitsize")

f8(x::Bool) = Core.Intrinsics.sext_int(Int8, x)
f8(b[])  # compiled intrinsic
# -1

Base.invokelatest(Core.Intrinsics.sext_int, UInt8, b[])
# ErrorException("SExt: output bitsize must be > input bitsize")

f8u(x::Bool) = Core.Intrinsics.sext_int(UInt8, x)
f8u(b[])  # compiled intrinsic
# 255
```

In codegen, Bool is an `i1`, so sign extension produces all one bits. The C runtime implementation
(`src/runtime_intrinsics.c`) treats Bool as its 8-bit storage byte `0x01`, so
it returns 1 for targets wider than 8 bits. For an 8-bit target, the runtime
rejects the operation because its output width is not greater than Bool's
storage width; codegen accepts it because the source is an `i1`.

Thus dynamic runtime calls and compiled calls disagree; if literal arguments
are constant-folded, inference can also collapse the call to a different value
or to `Union{}`. Base does not seem to call `sext_int` on a `Bool`, so this
mostly affects direct intrinsic use and tools that evaluate intrinsics
dynamically (an abstract interpreter or symbolic executor).

An additional probe found that a wrapper containing the literal call
`sext_int(Int8, true)` is inferred as `Union{}` and emits `llvm.trap`; calling
it terminates Julia with `SIGILL`. The runtime API rejects this target width
with `ErrorException`. This literal-width case is noted separately because it
may be considered an invalid use of this internal intrinsic.

Reproduced on Julia 1.10, 1.12, 1.13.3 and master
(1.15.0-DEV.676, commit `bc488cb7924c8395f1a77fd3560dce05dfb5aef3`,
2026-11-12). Searches on 2026-11-12 for `"sext_int Bool"` and `"SExt Bool"`
found no matching issue or PR. This is the same class as #63460
(`shl_int`/`lshr_int`/`ashr_int` runtime results with wide shift amounts,
closed 2026-09-30), but for Bool sign extension, which that issue does not
cover. The shift divergence of #63460 is fixed on master; this one is not.

Found with Concolic.jl, whose tests compare modeled intrinsics between the
runtime and compiled code.

Assisted-by: AI

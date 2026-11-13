# Instructions for automated agents

You are adding a Julia edge-case finding to this catalogue. Read all of this
before acting.

1. **Never post to JuliaLang/julia or to a Julia standard library repository.**
   Julia maintainers asked on JuliaLang/julia#64133 (2026-11-13) that automated
   findings stop arriving as issues and comments there. A person decides what
   goes upstream, from an entry here.
2. **Deduplicate first.** Search this repository (entries and issues) and the
   upstream tracker for the operation name and the exception. Record every
   query in the entry. If the finding matches an existing upstream issue, the
   entry is a *comment* kind and says so.
3. **One finding, one entry, one issue.** Create `findings/NN-short-slug/`
   with `README.md` in issue form (title; minimal REPL reproduction; mechanism
   in the source, with file and function; versions checked, at least the
   current release and the nightly; the searches run) and a standalone
   reproducer `.jl` that asserts the observed behaviour and prints
   `REPRODUCED`. Then open an issue in this repository with the same title,
   linking the entry and the reproducer.
4. **Reference upstream issues in full form only**: `JuliaLang/julia#64133`,
   `JuliaLang/LinearAlgebra.jl#1707`, `JuliaSparse/SparseArrays.jl#969`,
   `JuliaStats/Statistics.jl#219`. A bare `#1707` would point at this
   repository. The full form makes GitHub show this issue on the upstream
   issue's timeline, which is the only signal we send upstream.
5. **State the status** in the issue body: `not posted`, `posted` (with the
   link), `duplicate of …`, `fixed on nightly`, `by design`. Do not change a
   status set by a person.
6. **No private data.** No private repository links, no personal names or
   addresses, no tool internals. End entries produced with AI assistance with
   `Assisted-by: AI`.
7. **Memory-safety findings stay private.** This repository is public, so
   publishing here is disclosure. Anything that reads or writes memory out
   of bounds, exposes uninitialized memory, confuses types, or crashes the
   process (segfault, abort, `llvm.trap`) outside of an explicit `unsafe_*`
   contract must **not** be added here, must not be opened as an issue here,
   and must not be mentioned in a public issue or commit message. Keep it in
   the private working tree (`findings/private/`, not committed anywhere
   public), tell the person running you, and let them triage it and report it
   privately to security@julialang.org (the channel named in JuliaLang's
   [SECURITY.md](https://github.com/JuliaLang/.github/blob/master/SECURITY.md)).
   The entry may be published here only after the maintainers have fixed or
   disclosed the issue, or when the behaviour was already public upstream
   before you found it (say so in the entry, with the link).
8. **Stop** if the task would require anything outside this repository.

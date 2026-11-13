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
7. **Stop** if the task would require anything outside this repository.

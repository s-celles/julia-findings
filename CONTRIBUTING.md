# Contributing findings

This repository is the place to put Julia edge-case findings, for people and
for automated agents alike. Julia maintainers asked (JuliaLang/julia#64133,
2026-11-13) that automated findings not be posted as comments on the Julia
repository, so the rule is:

1. **Do not post to JuliaLang/julia or the stdlib repositories directly.**
   Put the finding here. A human may later open an upstream issue from an
   entry, after a look at duplicates.
2. **One finding, one entry, one issue.** Add a directory
   `findings/NN-short-slug/` with a `README.md` in issue form (title, minimal
   reproduction, mechanism in the source, versions checked, deduplication
   searches run) and a standalone reproducer script that prints `REPRODUCED`.
   Then open an issue in this repository with the same title.
3. **Reference upstream issues in full form** in the issue body:
   `JuliaLang/julia#64133`, `JuliaLang/LinearAlgebra.jl#1707`,
   `JuliaSparse/SparseArrays.jl#969`, `JuliaStats/Statistics.jl#219`. GitHub
   then shows the finding as a cross-reference on the upstream issue's
   timeline, which is how maintainers can discover it without any comment
   being posted. Never write a bare `#1707` in an issue here: it would point
   at this repository.
4. **State the status**: `not posted`, `posted` (with the link), `duplicate
   of <issue>`, `fixed on nightly`, or `by design` once someone decided so.
   Use the labels `julia`, `linearalgebra`, `sparsearrays`, `statistics`,
   `dates` for the component and `posted-upstream`, `related-upstream`,
   `fixed-on-nightly`, `needs-triage` for the state.
5. **Check before adding**: search this repository and the upstream tracker
   for the operation and the exception. Record the queries in the entry.
6. **Attribution**: entries produced with AI assistance end with
   `Assisted-by: AI`. Do not include private repository links or personal
   data in entries.

Automated agents: read this file first, follow the six points, and stop if
anything would require posting outside this repository.

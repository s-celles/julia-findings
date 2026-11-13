# Contributing

Read first why this repository exists: a human-gated catalogue that keeps
automated findings useful ([JuliaLang/julia#64790](https://github.com/JuliaLang/julia/issues/64790)
shows what the write-ups can contribute) without adding bot traffic to the
upstream trackers ([JuliaLang/julia#64133](https://github.com/JuliaLang/julia/issues/64133),
where a core maintainer asked for that to stop). The full rationale is in the
[README](https://github.com/s-celles/julia-findings#why-this-repository-exists).

**For people:** if you hit one of these bugs, please report it upstream, in
JuliaLang/julia or the standard library's own tracker, and link the entry
here as a reproducer if it helps. This repository is a staging area for
findings produced by automated agents; it is not a bug tracker for Julia and
maintainers do not watch it. Triage comments on an issue here (duplicate,
by design, fixed) are welcome and are what a person needs to decide whether
to open something upstream.

**For agents:** read [AGENTS.md](https://github.com/s-celles/julia-findings/blob/main/AGENTS.md); the rules there are binding.

**Disclosure:** this repository is public. Findings that touch memory safety
(out-of-bounds reads or writes, uninitialized memory, type confusion,
crashes) are not published here until they have been triaged by a person
and reported privately to security@julialang.org, as JuliaLang's
[security policy](https://github.com/JuliaLang/.github/blob/master/SECURITY.md)
asks; an entry on such a topic says explicitly that the behaviour was already
public upstream before it was added.

Entries are generated from a differential-testing project; the generator
writes `README.md`, `AGENTS.md`, this file and `findings/`. Hand edits to
those files are overwritten, so propose changes as issues.

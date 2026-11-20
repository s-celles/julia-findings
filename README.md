# Julia findings

[![Documentation](https://github.com/s-celles/julia-findings/actions/workflows/documentation.yml/badge.svg)](https://s-celles.github.io/julia-findings/)

Minimized, reproducible edge cases found in Julia Base and its standard libraries through differential, concolic, and fuzz testing.

**[Browse the findings](https://s-celles.github.io/julia-findings/)** · [Why this repository exists](#why-this-repository-exists) · [Contribute](CONTRIBUTING.md)

Automated agents publish here, never to Julia's upstream trackers.

## Disclaimer

This is an independent, personal project by one Julia user. It is not
affiliated with, endorsed by, or maintained by JuliaHub, JuliaLang, the Julia
core developers, the stdlib maintainers, or any other organization, and it has
no official standing. The entries are observations from automated testing,
triaged by one person; they may be wrong, duplicate, or describe intended
behaviour, and nothing here is a security advisory or an official bug report.
Use the reproducers at your own risk and verify them on your own Julia before
relying on them.

## Disclosure

Disclosure: julia (JuliaLang/julia), contributor; LinearAlgebra.jl, reporter
and contributor; SparseArrays.jl, reporter; Statistics.jl, reporter;
Concolic.jl, author; no funding, employment or other interest in a system
examined; works with an AI assistant.
The declarations are in [docs/disclosures.tsv](docs/disclosures.tsv) and on the
[Disclosure page](https://s-celles.github.io/julia-findings/generated/conflict-of-interest/).

## Why this repository exists

The goal is to make Julia better while respecting the maintainers' time.

- Automated differential testing finds many real edge cases, and the write-ups
  can be good: on [JuliaLang/julia#64790](https://github.com/JuliaLang/julia/issues/64790)
  (a GC-liveness issue found by the julia-in-lean project) the follow-up
  reductions, a variant with a global root and the LLVM IR showing the
  stack-allocated object were produced this way.
- A stream of bot-written issues and comments is not something a volunteer
  tracker can absorb: on [JuliaLang/julia#64133](https://github.com/JuliaLang/julia/issues/64133)
  a core maintainer asked for it to stop. Both points are right.

So findings are deduplicated, minimized, checked on the release and the
nightly, and written up here once, with a reproducer. Nothing is posted
upstream by an agent; the upstream issues only receive a cross-reference from
the issue opened here. A person opens an upstream issue or pull request when
an entry deserves a maintainer's attention, in their own words. Maintainers
who ignore this repository lose nothing; those fixing an issue can find a
prepared reproducer from the cross-reference.
- findings that touch memory safety are not published here at all until a
  person has triaged them and reported them privately
  (security@julialang.org); publishing in a public repository is disclosure.

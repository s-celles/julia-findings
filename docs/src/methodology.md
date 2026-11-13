# How we test

Julia often provides optimized representations that should preserve the observable behavior of a more direct reference representation. That gives us a useful differential oracle: perform the same operation through both paths, then classify any disagreement.

## Differential pairs

The current catalogue draws mainly from these comparisons:

| Optimized path | Reference path | Typical defects exposed |
|---|---|---|
| `AbstractRange` | `collect(range)` | overflow, invalid lazy ranges, search and ordering discrepancies |
| structured matrix | dense `Matrix` | narrow intermediates, invalid result wrappers, empty-shape errors |
| sparse array | dense array | promotion, indexing, and storage-specific behavior |
| narrow integer arithmetic | widened arithmetic | silent wraparound and conversion failures |

The harness classifies a mismatch by returned value, element type, concrete type, exception type, or return-versus-throw outcome. Candidate cases are then reduced and checked on both the current Julia release and an official nightly.

## Concolic and fuzz exploration

Concolic testing combines concrete execution with symbolic constraints, while structured fuzzing deliberately samples boundary-rich values and representations. In practice, this project uses both ideas alongside deterministic differential probes:

1. generate small inputs rich in extrema, empty shapes, mixed signs, and unusual steps;
2. execute optimized and materialized forms under the same operation;
3. save mismatches as standalone candidates;
4. minimize each candidate and inspect the dispatch path or closed form responsible;
5. search this catalogue and upstream trackers for duplicates;
6. publish the result here with its status and searches—not to an upstream tracker.

## Reading an entry

Each finding records a minimal REPL example, the source mechanism, versions checked, deduplication searches, and a status. A linked `.jl` reproducer asserts the observed behavior and prints `REPRODUCED`; an assertion failure usually means that the behavior changed on that Julia version.

“Comment” entries match an existing upstream issue. “Issue” entries had no direct match when researched. Neither label authorizes automated posting upstream.

## Disclaimer

This is an independent, personal project by one Julia user. It is not
affiliated with, endorsed by, or maintained by JuliaHub, JuliaLang, the Julia
core developers, the stdlib maintainers, or any other organization, and it has
no official standing. The entries are observations from automated testing,
triaged by one person; they may be wrong, duplicate, or describe intended
behaviour, and nothing here is a security advisory or an official bug report.
Use the reproducers at your own risk and verify them on your own Julia before
relying on them.

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

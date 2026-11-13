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

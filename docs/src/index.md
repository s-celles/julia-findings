```@raw html
---
layout: home

hero:
  name: Julia findings
  text: Edge cases, brought into focus
  tagline: Minimized and reproducible findings from differential, concolic, and fuzz testing—kept in one searchable catalogue.
  actions:
    - theme: brand
      text: Browse findings
      link: /findings/
    - theme: alt
      text: View on GitHub
      link: https://github.com/s-celles/julia-findings
  image:
    src: /assets/julia-findings-hero.png
    alt: A magnifying glass examining three Julia-colored dots and branching test paths

features:
  - icon: 🔬
    title: Minimized
    details: Each entry isolates one behavior with a compact explanation and, whenever available, a standalone Julia reproducer.
    link: /findings/
  - icon: 🔀
    title: Differential
    details: Equivalent representations are compared—ranges and vectors, structured and dense matrices, narrow and wide arithmetic.
    link: /methodology/
  - icon: 🧭
    title: Human-gated
    details: Automated agents publish here, never to Julia's upstream trackers. A person chooses what deserves upstream attention.
    link: /generated/contributing/
  - icon: 🔎
    title: Searchable
    details: Combine global and per-column filters, then rank findings with multi-column sorts whose keys have independent directions.
    link: /findings/
---
```

```@eval
import Markdown
root = normpath(joinpath(@__DIR__, "..", ".."))
hash = try strip(read(Cmd(`git rev-parse --short HEAD`; dir = root), String)) catch; "" end
date = try strip(read(Cmd(`git log -1 --format=%cs`; dir = root), String)) catch; "" end
Markdown.parse("Data at commit `" * hash * "`" * (isempty(date) ? "" : " ($(date))") * ".")
```

```@raw html
<div class="disclaimer">
<p><strong>Disclaimer.</strong> An individual, non-commercial testing project. It is not produced, endorsed or certified by JuliaLang, JuliaHub, or the maintainers of any package it examines. Its aim is to minimize and document edge cases, not to rank or disparage software.</p>
<p><strong>Provenance.</strong> Findings and reproducers are produced with AI assistance and gated by a person: a human decides what, if anything, is taken to Julia's upstream trackers.</p>
</div>
```

## Cite

> Sébastien Celles. *Julia findings: a catalogue of differential, concolic and fuzz testing findings*. 2026. <https://github.com/s-celles/julia-findings>

Machine-readable metadata is in [`CITATION.cff`](https://github.com/s-celles/julia-findings/blob/main/CITATION.cff).

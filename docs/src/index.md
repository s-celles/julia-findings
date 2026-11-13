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
    details: Filter the catalogue by operation, area, target, status, or exception, and sort every column in place.
    link: /findings/
---
```

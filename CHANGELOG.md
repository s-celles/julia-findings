# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- site-kit SPEC 0.4 (tag `v0.4.0`): the disclosure page is now
  `generated/disclosures/`, in the menu as Disclosures, the name of
  `docs/disclosures.tsv`; the SPEC 0.3 address `generated/conflict-of-interest/`
  redirects to it.
- site-kit SPEC 0.3 (tag `v0.3.1`) for the CI check and `just upstream`; the
  menu gains Disclosure after Methodology. In CONTRIBUTING, the memory-safety
  paragraph is now titled "Security-sensitive findings", and a new
  "Declarations" paragraph asks every change to come with its contributor's rows.

### Added

- A Disclosure page (site-kit SPEC 0.3, §15), generated from the committed
  declarations in `docs/disclosures.tsv`: the contributor's relation to every
  system examined (issues and pull requests per package), to the tool that
  produced the findings, any funding or other interest, and the use of an AI
  assistant, with a matrix of systems by contributors, what limits the bias and
  how to report a wrong declaration. Its one-line summary is on the home page,
  in every page footer, the README, `CITATION.cff` and `llms.txt`; the build
  fails if the README or `CITATION.cff` carry a stale summary.
- The home page citation and a BibTeX entry (`celles2026juliafindings`) are
  generated from `CITATION.cff`, which gains `date-released`.
- Julia tests for the declarations and citation helpers (`test/test_disclosures.jl`).

- Upstream states on the Upstream page: each cited issue and pull request
  shows its state (open, merged, closed, not planned), dates and the entries
  that cite it, from a committed snapshot (`data/upstream.tsv`) refreshed with
  `just upstream` (site-kit `upstream_status.py`); the build never reads the
  network. The upstream states are defined on the Statuses page.
- `scripts/upstream_refs.py`, with Python tests, lists the upstream reports of
  each entry's Status line for the snapshot.

### Fixed

- No em dash in the text the site generates (SPEC §15): the hero,
  Methodology, the sidebar titles of entries, `llms.txt`, and the empty
  Reproducer cell, which now reads "none". The Status lines of some entries
  still contain one.

- Status badges inside tables rendered as literal HTML text; the Upstream table
  is now raw HTML. The History stat tiles linked to `/history/...` paths under
  pretty URLs; they now use absolute links.

- A `fixed upstream` status, with its own badge and table filter, for findings
  whose upstream report was closed by a merged pull request; such findings
  count as reported upstream on the History page.

- Alignment with the shared [site-kit](https://github.com/s-celles/site-kit)
  specification v0.2: a Statuses page with status badges and a consistent tone
  per word, an Upstream page listing the cited issues and pull requests by
  repository, a server-rendered History time-series chart (static SVG enhanced
  by the shared `viz.js`), the shared menu order, and `site-kit.css`/`viz.js`.
- CI now checks the built site against the SPEC (`check_site.py`) and that the
  build is deterministic (`compare_builds.py`).

- `llms.txt` and `llms-full.txt` at the site root, and a `CITATION.cff` with a
  citation on the home page, for machine-readable and citable use (site-kit
  SK-LLMS, SK-HOME-CITE).
- A non-commercial disclaimer, an AI-provenance note, and a build-commit data
  stamp on the home page and the generated data pages (site-kit SK-HOME-STAMP,
  SK-HOME-DISCLAIMER, SK-HOME-PROVENANCE).
- History page with an interactive time-series chart of the catalogue's growth,
  stacking cumulative findings by Julia component, with a stat summary and an
  accessible cumulative table. Entry dates come from each finding's first commit.
- JavaScript tests for the history chart data helpers.
- Per-column catalogue filters, including categorical selectors for area,
  finding kind, target, status, and reproducer availability.
- Multi-column sorting with independent directions, visible priorities, and
  controls for reversing or removing individual sort keys.
- JavaScript tests for catalogue filtering and sorting behavior.

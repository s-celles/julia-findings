# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

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

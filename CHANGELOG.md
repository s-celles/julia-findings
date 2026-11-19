# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- History page with an interactive time-series chart of the catalogue's growth,
  stacking cumulative findings by Julia component, with a stat summary and an
  accessible cumulative table. Entry dates come from each finding's first commit.
- JavaScript tests for the history chart data helpers.
- Per-column catalogue filters, including categorical selectors for area,
  finding kind, target, status, and reproducer availability.
- Multi-column sorting with independent directions, visible priorities, and
  controls for reversing or removing individual sort keys.
- JavaScript tests for catalogue filtering and sorting behavior.

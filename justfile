default: check

julia := env_var_or_default("JULIA", "julia")

site_kit_tag := "v0.3.1"

test:
    node --test test/interactive-tables.test.js
    python3 -I -B -m unittest discover -s test -p 'test_*.py'
    {{julia}} test/test_disclosures.jl

docs:
    {{julia}} --project=docs docs/make.jl

check: test docs

# Refresh the committed upstream snapshot (data/upstream.tsv) from GitHub; needs `gh` or GITHUB_TOKEN.
upstream:
    #!/usr/bin/env bash
    set -euo pipefail
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    git clone --quiet --depth 1 --branch {{site_kit_tag}} https://github.com/s-celles/site-kit.git "$tmp/site-kit"
    python3 -I scripts/upstream_refs.py findings > "$tmp/refs.txt"
    python3 -I "$tmp/site-kit/tools/upstream_status.py" data/upstream.tsv --refs "$tmp/refs.txt"

default: check

julia := env_var_or_default("JULIA", "julia")

test:
    node --test test/interactive-tables.test.js

docs:
    {{julia}} --project=docs docs/make.jl

check: test docs

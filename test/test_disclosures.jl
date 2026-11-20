# Tests of docs/disclosures.jl: the declarations file (site-kit SPEC §15) and the citation (SPEC §3).
# Run with `julia test/test_disclosures.jl`; only the standard library is needed.
using Test

include(joinpath(@__DIR__, "..", "docs", "disclosures.jl"))

const HEAD = "contributor\torcid\tproject\tkind\trole\tnote\n"
const ONE = "# a comment before the header\n" * HEAD *
    "Jo Doe\t0000-0001-2345-6789\tFoo.jl\texamined system\treporter\tthree issues\n" *
    "# a comment between rows\n" *
    "Jo Doe\t0000-0001-2345-6789\tBar.jl\ttool\tauthor\t\n" *
    "Jo Doe\t0000-0001-2345-6789\tfunding, employment or other interest\tother\tnone\tindividual project\n" *
    "Jo Doe\t0000-0001-2345-6789\tan AI assistant\tAI assistance\tused to write the probes\treviewed by the contributor\n"

@testset "read_disclosures" begin
    rows = read_disclosures(ONE)
    @test length(rows) == 4
    @test rows[1].contributor == "Jo Doe"
    @test rows[1].orcid == "0000-0001-2345-6789"
    @test rows[1].project == "Foo.jl"
    @test rows[2].note == ""
    @test rows[4].kind == "AI assistance"
    @test_throws ErrorException read_disclosures("who\twhat\n")
    @test_throws ErrorException read_disclosures(HEAD * "Jo\t\tFoo.jl\ttool\n")
    # an empty ORCID is allowed (SPEC 0.3.1)
    @test read_disclosures(HEAD * "Al Roe\t\tnone\tother\tnone\t\n")[1].orcid == ""
end

@testset "disclosure_summary" begin
    s = disclosure_summary(read_disclosures(ONE))
    @test s == "Disclosure: Foo.jl, reporter; Bar.jl, author; no funding, employment or other interest; works with an AI assistant."
    @test !occursin('—', s)
    # several contributors: each one's clauses are named
    two = ONE * "Al Roe\t\tnone\tother\tnone\t\nAl Roe\t\tan AI assistant\tAI assistance\tx\ty\n"
    s2 = disclosure_summary(read_disclosures(two))
    @test startswith(s2, "Disclosure: Jo Doe: Foo.jl, reporter;")
    @test occursin("Al Roe: none", s2)
    @test endswith(s2, "works with an AI assistant.")
end

@testset "disclosure_page" begin
    page = disclosure_page(read_disclosures(ONE), ["Foo.jl", "Baz.jl"])
    @test occursin("# Disclosures", page)
    @test occursin(disclosure_summary(read_disclosures(ONE)), page)
    @test occursin("## Jo Doe", page)
    @test occursin("https://orcid.org/0000-0001-2345-6789", page)
    @test occursin("## Use of AI assistants", page)
    @test occursin("used to write the probes", page)
    @test occursin("## Relation of every contributor to every system", page)
    # every examined system and every declared tool has a matrix row; an undeclared one reads none
    @test occursin(r"\| Baz\.jl \| examined system \| none \|", page)
    @test occursin(r"\| Foo\.jl \| examined system \| reporter \|", page)
    @test occursin(r"\| Bar\.jl \| tool \| author \|", page)
    @test occursin("## What limits the bias", page)
    @test occursin("## Reporting", page)
    @test !occursin('—', page)
    # the AI assistance and none rows stay out of the per-contributor project table
    @test !occursin("| an AI assistant | AI assistance |", page)
end

const CFF = """
cff-version: 1.2.0
message: "If you use this catalogue, please cite it as below."
title: "Julia findings: a catalogue of findings"
abstract: >-
  Minimized findings.
type: dataset
authors:
  - family-names: Celles
    given-names: Sébastien
    alias: s-celles
date-released: 2026-11-13
repository-code: "https://github.com/s-celles/julia-findings"
url: "https://s-celles.github.io/julia-findings/"
license: MIT
"""

@testset "citation from CITATION.cff" begin
    c = read_cff(CFF)
    @test c.title == "Julia findings: a catalogue of findings"
    @test c.authors == [("Celles", "Sébastien")]
    @test c.year == "2026"
    @test c.repository == "https://github.com/s-celles/julia-findings"
    @test c.url == "https://s-celles.github.io/julia-findings/"
    @test citation_key(c) == "celles2026juliafindings"
    @test citation_text(c) == "Sébastien Celles. *Julia findings: a catalogue of findings*. 2026. <https://github.com/s-celles/julia-findings>"
    bib = citation_bibtex(c)
    @test startswith(bib, "@misc{celles2026juliafindings,")
    @test occursin("author = {Celles, Sébastien}", bib)
    @test occursin("year = {2026}", bib)
    @test occursin("url = {https://github.com/s-celles/julia-findings}", bib)
    @test citation_key((; c..., authors = [("Dupré-Éloi", "A")])) == "dupreeloi2026juliafindings"
end

@testset "redirect from the SPEC 0.3 address" begin
    html = redirect_html("https://example.org/generated/disclosures/")
    @test occursin("<meta http-equiv=\"refresh\" content=\"0; url=https://example.org/generated/disclosures/\">", html)
    @test occursin("<link rel=\"canonical\" href=\"https://example.org/generated/disclosures/\">", html)
    @test occursin("<a href=\"https://example.org/generated/disclosures/\">", html)
    @test !occursin('—', html)
    @test DISCLOSURE_PAGE == "disclosures"
    @test OLD_DISCLOSURE_PAGE == "conflict-of-interest"
end

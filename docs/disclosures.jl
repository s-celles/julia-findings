# The disclosure page and its one-line summary, from docs/disclosures.tsv (site-kit SPEC §15), and the
# home page citation, from CITATION.cff (SPEC §3). Standard library only, so that the tests in
# test/test_disclosures.jl run without the docs environment.
using Unicode

# The page name of SPEC §15 (SK-PAGE-DISCLOSURE); the one place to change if the SPEC renames it.
const DISCLOSURE_PAGE = "conflict-of-interest"

const DISCLOSURE_COLUMNS = ["contributor", "orcid", "project", "kind", "role", "note"]
const DISCLOSURES_URL = "https://github.com/s-celles/julia-findings/blob/main/docs/disclosures.tsv"
const REPOSITORY_URL = "https://github.com/s-celles/julia-findings"

"""
    read_disclosures(text) -> Vector{NamedTuple}

The rows of a declarations file: `#` lines are comments anywhere, then a header with
`DISCLOSURE_COLUMNS` and tab-separated rows. An empty ORCID is allowed.
"""
function read_disclosures(text::AbstractString)
    lines = [l for l in split(text, '\n') if !isempty(strip(l)) && !startswith(l, "#")]
    (isempty(lines) || split(lines[1], '\t') != DISCLOSURE_COLUMNS) &&
        error("docs/disclosures.tsv: the header is not $(join(DISCLOSURE_COLUMNS, ' '))")
    rows = NamedTuple{(:contributor, :orcid, :project, :kind, :role, :note), NTuple{6, String}}[]
    for (n, line) in enumerate(lines[2:end])
        f = split(rstrip(line, '\r'), '\t')
        length(f) == 6 || error("docs/disclosures.tsv: row $(n + 1) has $(length(f)) columns")
        push!(rows, (; zip((:contributor, :orcid, :project, :kind, :role, :note), String.(strip.(f)))...))
    end
    return rows
end

contributors(rows) = unique(r.contributor for r in rows)
is_ai(r) = r.kind == "AI assistance"
is_none(r) = lowercase(r.role) == "none" || lowercase(r.project) == "none"

function summary_clauses(rows)
    out = String[]
    for r in rows
        is_ai(r) && continue
        if lowercase(r.project) == "none"
            push!(out, "none")
        elseif lowercase(r.role) == "none"
            push!(out, "no " * r.project)
        else
            push!(out, "$(r.project), $(r.role)")
        end
    end
    return out
end

"""
    disclosure_summary(rows) -> String

The one-line summary of TEMPLATES.md: "Disclosure: {relations}; {interests}; works with an AI assistant."
"""
function disclosure_summary(rows)
    people = contributors(rows)
    parts = if length(people) == 1
        summary_clauses(rows)
    else
        [p * ": " * join(summary_clauses(filter(r -> r.contributor == p, rows)), "; ") for p in people]
    end
    any(is_ai, rows) && push!(parts, "works with an AI assistant")
    return "Disclosure: " * join(parts, "; ") * "."
end

cell(text) = replace(text, "|" => "\\|", '\n' => ' ')

"""
    disclosure_page(rows, systems) -> String

The Markdown of the disclosure page. `systems` are the examined systems present in the catalogue; the
matrix also has a row for every system, tool or source declared in `rows`.
"""
function disclosure_page(rows, systems)
    io = IOBuffer()
    print(io, """
    # Disclosure

    $(disclosure_summary(rows))

    Every contributor to this catalogue declares below their relation to the systems it examines and to
    the tools that produced the findings, in their own rows of [`docs/disclosures.tsv`]($(DISCLOSURES_URL))
    (a row with no relation is also a declaration). A change that adds or updates an entry comes with the
    rows of the person it is made for ([CONTRIBUTING.md]($(REPOSITORY_URL)/blob/main/CONTRIBUTING.md)).

    """)
    for p in contributors(rows)
        own = filter(r -> r.contributor == p, rows)
        orcid = first(own).orcid
        println(io, "## ", p, "\n")
        isempty(orcid) || println(io, "ORCID: [", orcid, "](https://orcid.org/", orcid, ")\n")
        println(io, "| project | kind | role | note |\n|---|---|---|---|")
        for r in own
            is_ai(r) || println(io, "| ", cell(r.project), " | ", cell(r.kind), " | ", cell(r.role), " | ", cell(r.note), " |")
        end
        println(io)
    end
    print(io, """
    ## Use of AI assistants

    Each contributor declares what an AI assistant did and how its output was reviewed; the model and
    the tool are not named. The reproducers are the evidence: every entry can be rerun without any
    assistant.

    | contributor | used for | review and limits |
    |---|---|---|
    """)
    ai = filter(is_ai, rows)
    for r in ai
        println(io, "| ", cell(r.contributor), " | ", cell(r.role), " | ", cell(r.note), " |")
    end
    isempty(ai) && println(io, "| none declared | | |")
    people = contributors(rows)
    matrix = [(s, "examined system") for s in systems]
    for r in rows
        (is_ai(r) || is_none(r) || r.kind == "other") && continue
        any(m -> m[1] == r.project, matrix) || push!(matrix, (r.project, r.kind))
    end
    print(io, """

    ## Relation of every contributor to every system

    One row per system examined in the catalogue and per declared tool or source, one column per
    contributor; a cell is the declared role, or *none*.

    | system or tool | kind | $(join(cell.(people), " | ")) |
    |---|---|$(repeat("---|", length(people)))
    """)
    for (name, kind) in matrix
        cells = map(people) do p
            roles = [r.role for r in rows if r.contributor == p && r.project == name && !is_none(r)]
            isempty(roles) ? "none" : cell(join(roles, "; "))
        end
        println(io, "| ", cell(name), " | ", cell(kind), " | ", join(cells, " | "), " |")
    end
    print(io, """

    ## What limits the bias

    - Every entry states the expected behaviour and comes with a standalone reproducer whenever one is
      available, so that a reader can rerun it and judge the finding without trusting the write-up.
    - Most findings are differential: two representations that Julia documents as equivalent (a range
      and a vector, a structured and a dense matrix, narrow and wide arithmetic) disagree. The oracle is
      the other representation or the documented contract, not a preference of the contributor.
    - The catalogue does not rank or score packages. The number of entries per package shows where the
      testing looked, not the quality of the package.
    - Upstream reports are deduplicated against the existing issues and pull requests and decided by a
      person; a maintainer's verdict (by design, duplicate, fixed) is recorded as the entry's status.
    - Funding, employment or any other interest in a system examined is declared in the same file. The
      project is individual and non-commercial.

    ## Reporting

    An entry that is wrong, unfair to a package, or intended behaviour, and a missing or wrong
    declaration, are bugs: open an issue or a pull request on the [repository]($(REPOSITORY_URL)).
    """)
    return String(take!(io))
end

# --- citation from CITATION.cff ----------------------------------------------------------------------

unquote(s) = (s = strip(s); length(s) >= 2 && first(s) in ('"', '\'') && last(s) == first(s) ? s[2:end-1] : s)

"""
    read_cff(text) -> NamedTuple

The fields of CITATION.cff that the citation needs: title, authors as (family, given) pairs, the year of
`date-released`, `repository-code` and `url`. A minimal reader for the flat layout of this repository.
"""
function read_cff(text::AbstractString)
    top = Dict{String, String}()
    authors = Tuple{String, String}[]
    in_authors = false
    for line in split(text, '\n')
        if (m = match(r"^([A-Za-z-]+):\s*(.*)$", line)) !== nothing
            key, value = m.captures
            in_authors = key == "authors"
            top[key] = unquote(value)
        elseif in_authors && (m = match(r"^\s*(-\s+)?(family-names|given-names):\s*(.+)$", line)) !== nothing
            isnothing(m.captures[1]) || push!(authors, ("", ""))
            fam, giv = last(authors)
            authors[end] = m.captures[2] == "family-names" ? (unquote(m.captures[3]), giv) : (fam, unquote(m.captures[3]))
        elseif in_authors && (m = match(r"^\s*-\s+", line)) !== nothing
            push!(authors, ("", ""))
        end
    end
    date = get(top, "date-released", "")
    return (title = get(top, "title", ""), authors = authors, year = length(date) >= 4 ? date[1:4] : "",
        repository = get(top, "repository-code", ""), url = get(top, "url", ""))
end

slug(s) = lowercase(filter(c -> isascii(c) && (isletter(c) || isdigit(c)), Unicode.normalize(s; stripmark = true)))

"The BibTeX key of SPEC §3: family name, year and the repository name, lowercase alphanumerics."
citation_key(c) = slug(first(c.authors)[1]) * c.year * slug(basename(rstrip(c.repository, '/')))

author_names(c) = join([strip("$giv $fam") for (fam, giv) in c.authors], ", ", " and ")

citation_text(c) = "$(author_names(c)). *$(c.title)*. $(c.year). <$(c.repository)>"

function citation_bibtex(c)
    return """
    @misc{$(citation_key(c)),
      author = {$(join(["$fam, $giv" for (fam, giv) in c.authors], " and "))},
      title = {$(c.title)},
      year = {$(c.year)},
      howpublished = {\\url{$(c.url)}},
      url = {$(c.repository)}
    }"""
end

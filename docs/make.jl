using Documenter
using DocumenterCodeBlocks
using DocumenterLandingPage

const ROOT = normpath(joinpath(@__DIR__, ".."))
const FINDINGS_ROOT = joinpath(ROOT, "findings")
const GENERATED_ROOT = joinpath(@__DIR__, "src", "generated")
const GENERATED_FINDINGS = joinpath(GENERATED_ROOT, "findings")

struct Finding
    number::Int
    slug::String
    title::String
    kind::String
    target::String
    status::String
    area::String
    scripts::Vector{String}
end

function field(text, name)
    matched = match(Regex("^- " * name * ":\\s*(.+)", "m"), text)
    isnothing(matched) && error("missing $name field")
    return matched.captures[1]
end

strip_ticks(text) = replace(strip(text), '`' => "")

function finding_area(target, title)
    occursin("LinearAlgebra", target) && return "LinearAlgebra"
    occursin("SparseArrays", target) && return "SparseArrays"
    occursin("Statistics", target) && return "Statistics"
    occursin(r"Date|Time|calendar|Month|Year", title) && return "Dates"
    occursin(r"Intrinsics|compiler|codegen", title) && return "Compiler"
    return "Base"
end

function read_finding(path)
    slug = basename(path)
    number = parse(Int, first(split(slug, '-')))
    text = read(joinpath(path, "README.md"), String)
    heading = match(r"^#\s+\d+:\s+(.+)$"m, text)
    isnothing(heading) && error("missing numbered heading in $path")
    title = strip(heading.captures[1])
    kind_line = strip_ticks(field(text, "Kind"))
    kind_match = match(r"^(issue|comment) for (.+)$", kind_line)
    isnothing(kind_match) && error("invalid Kind field in $path: $kind_line")
    kind, target = kind_match.captures
    status = field(text, "Status")
    scripts = sort(filter(name -> endswith(name, ".jl"), readdir(path)))
    return Finding(number, slug, title, kind, target, status,
        finding_area(target, title), scripts)
end

function issue_number(number)
    number == 28 && return 1
    number < 28 && return number + 1
    return number
end

escape_cell(text) = replace(text, "|" => "\\|", '\n' => ' ')

function prepare_sources(findings)
    rm(GENERATED_ROOT; recursive = true, force = true)
    mkpath(GENERATED_FINDINGS)

    rows = String[]
    finding_pages = Pair{String, String}[]
    for finding in findings
        destination = joinpath(GENERATED_FINDINGS, finding.slug)
        mkpath(destination)
        source = joinpath(FINDINGS_ROOT, finding.slug)
        cp(joinpath(source, "README.md"), joinpath(destination, "index.md"))
        for script in finding.scripts
            cp(joinpath(source, script), joinpath(destination, script))
        end

        entry = "generated/findings/$(finding.slug)/index.md"
        scripts = isempty(finding.scripts) ? "—" : join(
            ["[$script](generated/findings/$(finding.slug)/$script)" for script in finding.scripts],
            ", ",
        )
        issue = issue_number(finding.number)
        push!(rows, "| " * join((
            lpad(string(finding.number), 2, '0'),
            "[$(escape_cell(finding.title))]($entry)",
            finding.area,
            finding.kind,
            escape_cell(finding.target),
            escape_cell(finding.status),
            scripts,
            "[#$issue](https://github.com/s-celles/julia-findings/issues/$issue)",
        ), " | ") * " |")
        push!(finding_pages, "$(lpad(string(finding.number), 2, '0')) — $(finding.title)" => entry)
    end

    catalogue = """
    # Findings

    This catalogue is generated from the entry directories in [`findings/`](https://github.com/s-celles/julia-findings/tree/main/findings). Use the search field to filter all columns, or select a column heading to sort it. Every linked Julia script is standalone and asserts the observed behavior.

    | # | Finding | Area | Kind | Target | Status | Reproducer | Local issue |
    |---:|---|---|---|---|---|---|---|
    $(join(rows, "\n"))

    ## Status policy

    `not posted` means the finding exists only in this catalogue. `posted` records an earlier human- or bot-authored upstream report. New automated findings are never posted to Julia's upstream trackers; a person decides whether an entry is worth taking upstream.
    """
    write(joinpath(@__DIR__, "src", "findings.md"), catalogue)

    cp(joinpath(ROOT, "CONTRIBUTING.md"), joinpath(GENERATED_ROOT, "contributing.md"))
    cp(joinpath(ROOT, "AGENTS.md"), joinpath(GENERATED_ROOT, "AGENTS.md"))
    return finding_pages
end

finding_dirs = sort(filter(path -> isdir(path) && isfile(joinpath(path, "README.md")),
    readdir(FINDINGS_ROOT; join = true)))
findings = sort(read_finding.(finding_dirs); by = finding -> finding.number)
finding_pages = prepare_sources(findings)

makedocs(
    sitename = "Julia findings",
    authors = "Contributors to s-celles/julia-findings",
    checkdocs = :none,
    doctest = false,
    clean = true,
    format = Documenter.HTML(
        canonical = "https://s-celles.github.io/julia-findings/",
        edit_link = nothing,
        inventory_version = "dev",
        prettyurls = get(ENV, "CI", "false") == "true",
        assets = ["assets/custom.css", "assets/interactive-tables.js"],
        repolink = "https://github.com/s-celles/julia-findings",
        size_threshold = 2_000_000,
    ),
    plugins = [
        LandingPage(),
        CodeBlocks(reference_links = false, popups = false),
    ],
    pages = [
        "Home" => "index.md",
        "Findings" => "findings.md",
        "How we test" => "methodology.md",
        "Contributing" => "generated/contributing.md",
        "Agent policy" => "generated/AGENTS.md",
        (hide(page) for page in finding_pages)...,
    ],
)

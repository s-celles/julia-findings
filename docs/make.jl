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
        issue = issue_number(finding.number)
        issue_url = "https://github.com/s-celles/julia-findings/issues/$issue"
        page = read(joinpath(source, "README.md"), String)
        issue_link = "> **GitHub issue:** [s-celles/julia-findings#$issue]($issue_url)"
        page = replace(page, "\n" => "\n\n$issue_link\n"; count = 1)
        write(joinpath(destination, "index.md"), page)
        for script in finding.scripts
            cp(joinpath(source, script), joinpath(destination, script))
        end

        entry = "generated/findings/$(finding.slug)/index.md"
        scripts = isempty(finding.scripts) ? "—" : join(
            ["[$script](generated/findings/$(finding.slug)/$script)" for script in finding.scripts],
            ", ",
        )
        push!(rows, "| " * join((
            lpad(string(finding.number), 2, '0'),
            "[$(escape_cell(finding.title))]($entry)",
            finding.area,
            finding.kind,
            escape_cell(finding.target),
            escape_cell(finding.status),
            scripts,
            "[#$issue]($issue_url)",
        ), " | ") * " |")
        push!(finding_pages, "$(lpad(string(finding.number), 2, '0')) — $(finding.title)" => entry)
    end

    catalogue = """
    # Findings

    This catalogue is generated from the entry directories in [`findings/`](https://github.com/s-celles/julia-findings/tree/main/findings). Search all columns at once, or use the controls below each heading to combine column filters. Select a heading for a single-column sort; hold `Shift` while selecting additional headings to build a multi-column sort with an independent direction for each key. The numbered arrows show sort priority, and the controls above the table can reverse or remove any key. Every linked Julia script is standalone and asserts the observed behavior.

    | # | Finding | Area | Kind | Target | Status | Reproducer | GitHub issue |
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

const HISTORY_AREAS = ["LinearAlgebra", "SparseArrays", "Base", "Statistics", "Dates", "Compiler"]

# First-commit date (YYYY-MM-DD) of a finding's directory, i.e. when it entered the catalogue.
# Requires full git history (the docs workflow checks out with fetch-depth: 0).
function finding_date(slug)
    path = "findings/$slug/README.md"
    out = try
        read(Cmd(`git log --diff-filter=A --format=%aI --follow -- $path`; dir = ROOT), String)
    catch
        ""
    end
    lines = filter(!isempty, split(strip(out), '\n'))
    isempty(lines) && error("no git add-date for $slug (shallow checkout? use fetch-depth: 0)")
    return String(first(last(lines), 10))
end

json_str(s) = '"' * replace(string(s), '\\' => "\\\\", '"' => "\\\"") * '"'

function build_history(findings)
    dates = sort(unique(finding_date(f.slug) for f in findings))
    dindex = Dict(d => i for (i, d) in enumerate(dates))
    present = [a for a in HISTORY_AREAS if any(f -> f.area == a, findings)]
    added = Dict(a => zeros(Int, length(dates)) for a in present)
    for f in findings
        added[f.area][dindex[finding_date(f.slug)]] += 1
    end
    total = length(findings)
    reported = count(f -> startswith(strip(f.status), "posted"), findings)
    span = length(dates) == 1 ? dates[1] : "$(first(dates)) → $(last(dates))"

    # cumulative-by-area table (accessible fallback) and the embedded JSON for the charts
    cum = Dict(a => cumsum(added[a]) for a in present)
    header = "| Date | " * join(present, " | ") * " | Total |"
    sep = "|---|" * repeat("---:|", length(present) + 1)
    rows = String[]
    for (i, d) in enumerate(dates)
        tot = sum(cum[a][i] for a in present)
        push!(rows, "| $d | " * join((string(cum[a][i]) for a in present), " | ") * " | $tot |")
    end

    added_json = "{" * join(
        ("$(json_str(a)):[" * join(added[a], ",") * "]" for a in present), ",") * "}"
    data_json = "{" *
        "\"dates\":[" * join((json_str(d) for d in dates), ",") * "]," *
        "\"areas\":[" * join((json_str(a) for a in present), ",") * "]," *
        "\"addedByArea\":$added_json," *
        "\"total\":$total,\"reported\":$reported}"

    page = """
    # History

    How the catalogue has grown over time. Each entry is dated by the first commit that added it to
    [`findings/`](https://github.com/s-celles/julia-findings/tree/main/findings); the chart stacks the
    cumulative count by Julia component. See the full list on the [Findings](findings.md) page.

    ```@raw html
    <div class="jf-stat-row">
      <div class="jf-stat"><span class="jf-stat-value">$total</span><span class="jf-stat-label">findings</span></div>
      <div class="jf-stat"><span class="jf-stat-value">$(length(present))</span><span class="jf-stat-label">components</span></div>
      <div class="jf-stat"><span class="jf-stat-value">$reported</span><span class="jf-stat-label">reported upstream</span></div>
      <div class="jf-stat"><span class="jf-stat-value jf-stat-span">$span</span><span class="jf-stat-label">catalogue span</span></div>
    </div>
    <div id="jf-history-charts" class="jf-history-charts"></div>
    <script type="application/json" id="jf-history-data">$data_json</script>
    ```

    ## Cumulative findings by component

    The chart above is generated from this table; the figures are cumulative totals at each date.

    $header
    $sep
    $(join(rows, "\n"))
    """
    write(joinpath(@__DIR__, "src", "history.md"), page)
    return nothing
end

finding_dirs = sort(filter(path -> isdir(path) && isfile(joinpath(path, "README.md")),
    readdir(FINDINGS_ROOT; join = true)))
findings = sort(read_finding.(finding_dirs); by = finding -> finding.number)
finding_pages = prepare_sources(findings)
build_history(findings)

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
        assets = ["assets/custom.css", "assets/interactive-tables.js", "assets/history-charts.js"],
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
        "History" => "history.md",
        "How we test" => "methodology.md",
        "Contributing" => "generated/contributing.md",
        "Agent policy" => "generated/AGENTS.md",
        (hide(page) for page in finding_pages)...,
    ],
)

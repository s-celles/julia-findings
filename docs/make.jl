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

    $(data_stamp())
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

# Build-time commit stamp (SK-HOME-STAMP): full git history is available on CI (fetch-depth: 0).
const DATA_COMMIT = try strip(read(Cmd(`git rev-parse --short HEAD`; dir = ROOT), String)) catch; "" end
const DATA_DATE = try strip(read(Cmd(`git log -1 --format=%cs`; dir = ROOT), String)) catch; "" end
function data_stamp()
    isempty(DATA_COMMIT) && return ""
    suffix = isempty(DATA_DATE) ? "" : " ($(DATA_DATE))"
    return "```@raw html\n<p class=\"data-stamp\">Data at commit <code>$(DATA_COMMIT)</code>$(suffix).</p>\n```\n\n"
end

function build_history(findings)
    dates = sort(unique(finding_date(f.slug) for f in findings))
    n = length(dates)
    dindex = Dict(d => i for (i, d) in enumerate(dates))
    addTot = zeros(Int, n); addRep = zeros(Int, n)
    for f in findings
        i = dindex[finding_date(f.slug)]
        addTot[i] += 1
        status_word(f.status) in ("posted", "fixed upstream") && (addRep[i] += 1)
    end
    cumTot = cumsum(addTot); cumRep = cumsum(addRep)
    total = cumTot[end]; reported = cumRep[end]
    ncomp = length(unique(f.area for f in findings))
    span = n == 1 ? dates[1] : "$(first(dates)) → $(last(dates))"

    ymax = maximum(cumTot)
    step = let raw = ymax / 4, mag = 10.0^floor(log10(max(raw, 1)))
        Int(round((raw / mag >= 5 ? 5 : raw / mag >= 2 ? 2 : 1) * mag))
    end
    ticks = collect(0:step:(ymax + step - 1))
    ytop = max(ticks[end], 1)
    md(d) = d[6:end]
    xof(i) = 60 + (n == 1 ? 0.0 : (i - 1) * 640 / (n - 1))
    yof(v) = 174 - (v / ytop) * 160
    r1(x) = round(x; digits = 1)

    io = IOBuffer()
    print(io, "<figure class=\"viz\"><svg class=\"viz-chart\" data-viz=\"dense\" tabindex=\"0\" viewBox=\"0 0 760 210\" role=\"img\" aria-label=\"Cumulative findings and upstream reports over time, $(first(dates)) to $(last(dates))\">")
    for t in ticks
        y = r1(yof(t))
        print(io, "<line class=\"viz-grid\" x1=\"44\" x2=\"700\" y1=\"$(y)\" y2=\"$(y)\"/><text class=\"viz-tick\" x=\"38\" y=\"$(y + 4)\" text-anchor=\"end\">$(t)</text>")
    end
    print(io, "<line class=\"viz-axis\" x1=\"44\" x2=\"700\" y1=\"174\" y2=\"174\"/>")
    for (i, d) in enumerate(dates)
        print(io, "<text class=\"viz-tick\" x=\"$(r1(xof(i)))\" y=\"192\" text-anchor=\"middle\">$(md(d))</text>")
    end
    for (label, series, var) in (("findings", cumTot, "--viz-1"), ("reported", cumRep, "--viz-2"))
        path = join(("$(j == 1 ? "M" : "L")$(r1(xof(j))),$(r1(yof(v)))" for (j, v) in enumerate(series)), " ")
        print(io, "<path class=\"viz-line\" style=\"stroke:var($(var))\" d=\"$(path)\"/>")
        for (i, v) in enumerate(series)
            cx = r1(xof(i)); cy = r1(yof(v))
            print(io, "<g class=\"viz-pt\" data-x-label=\"$(dates[i])\" aria-label=\"$(dates[i]), $(label): $(v)\"><circle class=\"viz-hit\" cx=\"$(cx)\" cy=\"$(cy)\" r=\"9\"/><circle class=\"viz-dot\" style=\"fill:var($(var))\" cx=\"$(cx)\" cy=\"$(cy)\" r=\"4\"/></g>")
        end
        print(io, "<text class=\"viz-label\" x=\"670\" y=\"$(r1(yof(series[end])))\">$(label) $(series[end])</text>")
    end
    print(io, "</svg><figcaption>Cumulative findings and upstream reports (y from 0). Tab to the chart, then use the arrow keys.</figcaption></figure>")
    svg = String(take!(io))

    tablerows = join(("| $(dates[i]) | $(cumTot[i]) | $(cumRep[i]) |" for i in 1:n), "\n")
    page = """
    # History

    $(data_stamp())How the catalogue has grown over time. Each entry is dated by the first commit that added it to [`findings/`](https://github.com/s-celles/julia-findings/tree/main/findings). The chart tracks the cumulative number of findings and of findings reported upstream.

    ```@raw html
    <div class="sk-stats"><a class="sk-stat" href="findings/"><strong>$(total)</strong><span>findings</span></a><a class="sk-stat" href="findings/"><strong>$(ncomp)</strong><span>components</span></a><a class="sk-stat" href="upstream/"><strong>$(reported)</strong><span>reported upstream</span></a><a class="sk-stat" href="history/"><strong>$(span)</strong><span>catalogue span</span></a></div>

    $(svg)
    ```

    ## Cumulative totals

    | Date | Findings | Reported upstream |
    |---|---:|---:|
    $(tablerows)
    """
    write(joinpath(@__DIR__, "src", "history.md"), page)
    return nothing
end

const SITE_URL = "https://s-celles.github.io/julia-findings"

# llms.txt / llms-full.txt at the site root (SK-LLMS): pitch, disclaimer, provenance, pages, registry.
function build_llms(findings)
    stamp = isempty(DATA_COMMIT) ? "" : "Data at commit $(DATA_COMMIT)" *
        (isempty(DATA_DATE) ? "" : " ($(DATA_DATE))") * ".\n"
    header = """
    # Julia findings

    > Minimized, reproducible findings from differential, concolic and fuzz testing of the Julia
    > language and its standard libraries, kept in one searchable catalogue with standalone reproducers.

    Disclaimer: an individual, non-commercial testing project. Not produced, endorsed or certified by
    JuliaLang, JuliaHub, or the maintainers of any package it examines.
    Provenance: findings and reproducers are produced with AI assistance and gated by a person before
    anything is taken to Julia's upstream trackers.
    $(stamp)
    ## Pages

    - Findings: $(SITE_URL)/findings/
    - History: $(SITE_URL)/history/
    - How we test: $(SITE_URL)/methodology/
    - Repository: https://github.com/s-celles/julia-findings
    - Citation: https://github.com/s-celles/julia-findings/blob/main/CITATION.cff
    """

    short = IOBuffer()
    print(short, header, "\n## Findings ($(length(findings)))\n\n")
    for f in findings
        println(short, "- $(lpad(f.number, 2, '0')): $(f.title) — $(f.area); $(f.status)")
    end
    write(joinpath(@__DIR__, "build", "llms.txt"), String(take!(short)))

    full = IOBuffer()
    print(full, header, "\n## Findings ($(length(findings))) — full text\n\n")
    for f in findings
        body = read(joinpath(FINDINGS_ROOT, f.slug, "README.md"), String)
        println(full, "----------------------------------------------------------------------\n")
        println(full, body, "\n")
    end
    write(joinpath(@__DIR__, "build", "llms-full.txt"), String(take!(full)))
    return nothing
end

# Canonical status word for a finding's Status line, and its badge tone (SPEC §5).
const STATUS_TONES = Dict(
    "not posted" => "neutral",
    "posted" => "info",
    "fixed upstream" => "good",
    "fixed on nightly" => "good",
    "by design" => "warn",
    "duplicate" => "alt",
)
const STATUS_MEANINGS = [
    "posted" => "An upstream report (issue or pull request) exists for this finding.",
    "fixed upstream" => "A fix has been merged upstream: the report was closed by a merged pull request.",
    "fixed on nightly" => "The behavior is already fixed on an official Julia nightly.",
    "by design" => "The behavior is intended; the entry documents the sharp edge.",
    "duplicate" => "The same behavior is recorded by an existing upstream report.",
    "not posted" => "The finding exists only in this catalogue; a person has not taken it upstream.",
]
function status_word(status)
    s = lowercase(strip(status))
    occursin("fixed upstream", s) && return "fixed upstream"
    startswith(s, "not posted") && return "not posted"
    startswith(s, "fixed on nightly") && return "fixed on nightly"
    startswith(s, "by design") && return "by design"
    startswith(s, "duplicate") && return "duplicate"
    startswith(s, "posted") && return "posted"
    (occursin("fix proposed", s) || occursin(r"\.jl#\d", s) || occursin("pull request", s)) && return "posted"
    return "not posted"
end
badge(word) = "<span class=\"sk-badge sk-tone--$(get(STATUS_TONES, word, "neutral"))\" data-status=\"$(word)\">$(word)</span>"

function build_statuses()
    rows = ["$(badge(w))\n: $(m)\n" for (w, m) in STATUS_MEANINGS]
    page = """
    # Statuses

    $(data_stamp())Every finding carries a status. Its badge always shows the word, so no meaning rests on color alone; the raw word is in `data-status` for filtering.

    ```@raw html
    <dl class="sk-status-list">
    $(join(("<dt>$(badge(w))</dt><dd>$(m)</dd>" for (w, m) in STATUS_MEANINGS), "\n"))
    </dl>
    ```

    See the [Findings](findings.md) table to filter by status, and the [Upstream](upstream.md) page for the reports themselves.
    """
    write(joinpath(@__DIR__, "src", "statuses.md"), page)
    return nothing
end

function build_upstream(findings)
    # collect (repo, kind, number) references from each finding's Status line
    refs = Dict{String, Vector{Tuple{String, Int, Finding}}}()  # repo => [(kind, number, finding)]
    rx = r"github\.com/([\w.\-]+/[\w.\-]+)/(issues|pull)/(\d+)"
    for f in findings
        for m in eachmatch(rx, f.status)
            repo, kindw, num = m.captures[1], m.captures[2], parse(Int, m.captures[3])
            kind = kindw == "pull" ? "pull request" : "issue"
            push!(get!(refs, repo, Tuple{String, Int, Finding}[]), (kind, num, f))
        end
    end
    secs = String[]
    for repo in sort(collect(keys(refs)))
        rows = String[]
        for (kind, num, f) in sort(refs[repo]; by = t -> t[2])
            url = "https://github.com/$repo/$(kind == "pull request" ? "pull" : "issues")/$num"
            entry = "generated/findings/$(f.slug)/index.md"
            push!(rows, "| [#$num]($url) | $kind | [$(lpad(f.number, 2, '0')): $(escape_cell(first(f.title, 70)))]($entry) |")
        end
        push!(secs, "## $repo\n\n| Reference | Kind | Finding |\n|---|---|---|\n$(join(rows, "\n"))\n")
    end
    total = sum(length(v) for v in values(refs); init = 0)
    page = """
    # Upstream

    $(data_stamp())$(total) upstream references (issues and pull requests) cited by the catalogue, by repository. A closed issue does not prove that a fix reached a release.

    $(join(secs, "\n"))
    """
    write(joinpath(@__DIR__, "src", "upstream.md"), page)
    return nothing
end

finding_dirs = sort(filter(path -> isdir(path) && isfile(joinpath(path, "README.md")),
    readdir(FINDINGS_ROOT; join = true)))
findings = sort(read_finding.(finding_dirs); by = finding -> finding.number)
finding_pages = prepare_sources(findings)
build_history(findings)
build_statuses()
build_upstream(findings)

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
        assets = ["assets/site-kit.css", "assets/custom.css", "assets/interactive-tables.js", "assets/viz.js"],
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
        "Upstream" => "upstream.md",
        "History" => "history.md",
        "Methodology" => "methodology.md",
        "Statuses" => "statuses.md",
        "Contributing" => "generated/contributing.md",
        "Agent policy" => "generated/AGENTS.md",
        (hide(page) for page in finding_pages)...,
    ],
)

build_llms(findings)

# Post-build: give the home page's data stamp the `.data-stamp` class (SK-HOME-STAMP). Documenter escapes
# raw HTML inside @eval, so the stamp is emitted as a Markdown paragraph and the class is added here.
let home = joinpath(@__DIR__, "build", "index.html")
    if isfile(home)
        html = read(home, String)
        html = replace(html, "<p>Data at commit <code>" => "<p class=\"data-stamp\">Data at commit <code>")
        write(home, html)
    end
end

#!/usr/bin/env python3
"""List the upstream issues and pull requests that the catalogue reports, for the site-kit
upstream snapshot (SPEC.md §6).

    python3 -I scripts/upstream_refs.py [FINDINGS_DIR] > refs.txt

Only the `- Status:` line of each `findings/NN-slug/README.md` is read: it holds the upstream
reports of the entry, while the body also cites related issues found by the deduplication
searches. Each output line is `owner/repo#N ENTRY...`, the format of
`site-kit/tools/upstream_status.py --refs`.
"""
import pathlib
import re
import sys

REF = re.compile(r"https://github\.com/([\w.-]+/[\w.-]+)/(?:issues|pull)/(\d+)")


def status_refs(line):
    """[(repo, number)] of the GitHub issue and pull request URLs of a Status line, in order."""
    out = []
    for repo, num in REF.findall(line):
        ref = (repo, int(num))
        if ref not in out:
            out.append(ref)
    return out


def refs_lines(findings_dir):
    """Lines `owner/repo#N ENTRY...`, sorted by repository and number."""
    cited = {}
    for readme in sorted(pathlib.Path(findings_dir).glob("*/README.md")):
        entry = readme.parent.name.split("-", 1)[0]
        status = next((l for l in readme.read_text().splitlines() if l.startswith("- Status:")), "")
        for ref in status_refs(status):
            cited.setdefault(ref, set()).add(entry)
    return [f"{repo}#{num} " + " ".join(sorted(cited[(repo, num)]))
            for repo, num in sorted(cited, key=lambda r: (r[0].lower(), r[1]))]


if __name__ == "__main__":
    findings = sys.argv[1] if len(sys.argv) > 1 else "findings"
    print("\n".join(refs_lines(findings)))

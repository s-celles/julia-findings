import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent / "scripts"))
import upstream_refs  # noqa: E402


class StatusRefsTest(unittest.TestCase):
    def test_issue_and_pull_urls_in_order_without_duplicates(self):
        line = ("- Status: posted ([JuliaLang/LinearAlgebra.jl#1899](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1899)); "
                "fixed upstream by [JuliaLang/LinearAlgebra.jl#1915](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1915) "
                "(see https://github.com/JuliaLang/LinearAlgebra.jl/issues/1899)")
        self.assertEqual(upstream_refs.status_refs(line),
                         [("JuliaLang/LinearAlgebra.jl", 1899), ("JuliaLang/LinearAlgebra.jl", 1915)])

    def test_comment_anchor_keeps_the_issue(self):
        line = "- Status: posted ([comment](https://github.com/JuliaLang/LinearAlgebra.jl/pull/1784#issuecomment-7032050223))"
        self.assertEqual(upstream_refs.status_refs(line), [("JuliaLang/LinearAlgebra.jl", 1784)])

    def test_not_posted_has_no_refs(self):
        self.assertEqual(upstream_refs.status_refs("- Status: not posted"), [])

    def test_refs_lines_use_the_entry_number_and_only_the_status_line(self):
        with tempfile.TemporaryDirectory() as d:
            root = pathlib.Path(d)
            for slug, status, body in (
                ("25-a", "posted ([x](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1875))",
                 "body cites https://github.com/JuliaLang/julia/issues/1"),
                ("73-b", "posted ([x](https://github.com/JuliaLang/LinearAlgebra.jl/issues/1875))", ""),
                ("05-c", "not posted", ""),
            ):
                (root / slug).mkdir()
                (root / slug / "README.md").write_text(f"# t\n\n- Kind: issue for `X`\n- Status: {status}\n\n# Body\n{body}\n")
            self.assertEqual(upstream_refs.refs_lines(root), ["JuliaLang/LinearAlgebra.jl#1875 25 73"])


if __name__ == "__main__":
    unittest.main()

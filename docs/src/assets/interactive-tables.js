document.addEventListener("DOMContentLoaded", () => {
  const collator = new Intl.Collator(undefined, {
    numeric: true,
    sensitivity: "base",
  });

  document.querySelectorAll("article table").forEach((table, tableIndex) => {
    const body = table.tBodies[0];
    const headerRow = table.tHead?.rows[0] ?? table.rows[0];
    const headers = Array.from(headerRow?.cells ?? []);
    if (!body || !headerRow || headers.length === 0 || table.rows.length < 3) return;

    const rows = Array.from(table.rows).filter((row) => row !== headerRow);
    rows.forEach((row, index) => (row.dataset.originalIndex = String(index)));
    table.classList.add("interactive-table");

    const tools = document.createElement("div");
    tools.className = "table-tools";

    const input = document.createElement("input");
    input.className = "table-filter";
    input.type = "search";
    input.placeholder = "Filter this table…";
    input.setAttribute("aria-label", "Filter table rows");

    const count = document.createElement("span");
    count.className = "table-count";
    count.setAttribute("aria-live", "polite");

    const updateCount = () => {
      const visible = rows.filter((row) => !row.hidden).length;
      count.textContent = `${visible} of ${rows.length} rows`;
    };

    input.addEventListener("input", () => {
      const terms = input.value.toLocaleLowerCase().trim().split(/\s+/).filter(Boolean);
      rows.forEach((row) => {
        const haystack = row.textContent.toLocaleLowerCase();
        row.hidden = !terms.every((term) => haystack.includes(term));
      });
      updateCount();
    });

    tools.append(input, count);
    table.parentElement.insertBefore(tools, table);
    updateCount();

    headers.forEach((header, columnIndex) => {
      header.tabIndex = 0;
      header.setAttribute("role", "button");
      header.setAttribute("aria-sort", "none");

      const sort = () => {
        const descending = header.getAttribute("aria-sort") === "ascending";
        headers.forEach((item) => item.setAttribute("aria-sort", "none"));
        header.setAttribute("aria-sort", descending ? "descending" : "ascending");

        rows.sort((left, right) => {
          const a = left.cells[columnIndex]?.textContent.trim() ?? "";
          const b = right.cells[columnIndex]?.textContent.trim() ?? "";
          const compared = collator.compare(a, b);
          if (compared !== 0) return descending ? -compared : compared;
          return Number(left.dataset.originalIndex) - Number(right.dataset.originalIndex);
        });
        rows.forEach((row) => body.appendChild(row));
      };

      header.addEventListener("click", sort);
      header.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          sort();
        }
      });
    });

    input.id = `table-filter-${tableIndex + 1}`;
  });
});

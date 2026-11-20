(function () {
  "use strict";

  const SELECT_FILTER_COLUMNS = new Set([
    "area",
    "kind",
    "target",
    "status",
    "reproducer",
  ]);

  const FILTER_LABELS = {
    available: "Available",
    "by design": "By design",
    duplicate: "Duplicate",
    "fixed on nightly": "Fixed on nightly",
    "fixed upstream": "Fixed upstream",
    none: "None",
    "not posted": "Not posted",
    posted: "Posted",
  };

  function normalizeText(value) {
    return String(value ?? "")
      .toLocaleLowerCase()
      .replace(/\s+/g, " ")
      .trim();
  }

  function filterValueForColumn(headerText, cellText) {
    const header = normalizeText(headerText);
    const value = normalizeText(cellText);

    if (header === "status") {
      if (value.includes("fixed upstream")) return "fixed upstream";
      if (value.startsWith("not posted")) return "not posted";
      if (value.startsWith("fixed on nightly")) return "fixed on nightly";
      if (value.startsWith("by design")) return "by design";
      if (value.startsWith("duplicate")) return "duplicate";
      if (value.startsWith("posted")) return "posted";
    }
    if (header === "reproducer") {
      return value === "" || value === "—" || value === "none" ? "none" : "available";
    }
    return value;
  }

  function rowMatchesFilters(record, globalQuery, columnFilters) {
    const terms = normalizeText(globalQuery).split(/\s+/).filter(Boolean);
    if (!terms.every((term) => record.searchText.includes(term))) return false;

    return columnFilters.every((filter, columnIndex) => {
      if (!filter?.value) return true;
      const value = record.filterValues[columnIndex] ?? "";
      return filter.exact ? value === filter.value : value.includes(filter.value);
    });
  }

  function updateSortKeys(sortKeys, columnIndex, additive) {
    const existingIndex = sortKeys.findIndex((key) => key.columnIndex === columnIndex);

    if (!additive) {
      if (sortKeys.length !== 1 || existingIndex !== 0) {
        return [{ columnIndex, direction: "ascending" }];
      }
      if (sortKeys[0].direction === "ascending") {
        return [{ columnIndex, direction: "descending" }];
      }
      return [];
    }

    if (existingIndex === -1) {
      return [...sortKeys, { columnIndex, direction: "ascending" }];
    }
    if (sortKeys[existingIndex].direction === "ascending") {
      return sortKeys.map((key, index) =>
        index === existingIndex ? { ...key, direction: "descending" } : key,
      );
    }
    return sortKeys.filter((_, index) => index !== existingIndex);
  }

  function compareRowRecords(left, right, sortKeys, collator) {
    for (const key of sortKeys) {
      const compared = collator.compare(
        left.values[key.columnIndex] ?? "",
        right.values[key.columnIndex] ?? "",
      );
      if (compared !== 0) {
        return key.direction === "descending" ? -compared : compared;
      }
    }
    return left.originalIndex - right.originalIndex;
  }

  function filterOptionLabel(headerText, value, originalValue) {
    if (FILTER_LABELS[value]) return FILTER_LABELS[value];
    return String(originalValue ?? value).replace(/\s+/g, " ").trim();
  }

  function normalizeTableSections(table) {
    const headerRow = table.tHead?.rows[0] ?? table.rows[0];
    if (!headerRow) return { headerRow: null, body: null };
    if (!table.tHead) table.createTHead().appendChild(headerRow);
    return { headerRow, body: table.tBodies[0] ?? null };
  }

  function enhanceTable(table, tableIndex) {
    const { headerRow, body } = normalizeTableSections(table);
    const headers = Array.from(headerRow?.cells ?? []);
    if (!body || !headerRow || headers.length === 0 || body.rows.length < 2) return;

    const collator = new Intl.Collator(undefined, {
      numeric: true,
      sensitivity: "base",
    });
    const rows = Array.from(body.rows);
    const headerNames = headers.map((header) => header.textContent.trim());
    const records = rows.map((row, originalIndex) => {
      const values = headers.map((_, columnIndex) =>
        row.cells[columnIndex]?.textContent.trim() ?? "",
      );
      return {
        row,
        originalIndex,
        values,
        filterValues: values.map((value, columnIndex) =>
          filterValueForColumn(headerNames[columnIndex], value),
        ),
        searchText: normalizeText(row.textContent),
      };
    });

    table.classList.add("interactive-table");
    table.id ||= `interactive-table-${tableIndex + 1}`;

    const pageSize = 20;
    let page = 0;
    let sortKeys = [];
    let filteredRecords = records.slice();
    const columnFilters = Array(headers.length).fill(null);
    const filterControls = [];

    const tools = document.createElement("div");
    tools.className = "table-tools";

    const searchGroup = document.createElement("div");
    searchGroup.className = "table-search-group";

    const input = document.createElement("input");
    input.className = "table-filter";
    input.type = "search";
    input.placeholder = "Search all columns…";
    input.setAttribute("aria-label", "Search all table columns");
    input.setAttribute("aria-controls", table.id);
    input.id = `table-filter-${tableIndex + 1}`;

    const clearFilters = document.createElement("button");
    clearFilters.className = "table-clear-filters";
    clearFilters.type = "button";
    clearFilters.textContent = "Clear filters";
    clearFilters.setAttribute("aria-controls", table.id);
    clearFilters.disabled = true;
    searchGroup.append(input, clearFilters);

    const count = document.createElement("span");
    count.className = "table-count";
    count.setAttribute("aria-live", "polite");

    const pagination = document.createElement("div");
    pagination.className = "table-pagination";

    const previous = document.createElement("button");
    previous.type = "button";
    previous.textContent = "← Previous";
    previous.setAttribute("aria-controls", table.id);

    const pageLabel = document.createElement("span");
    pageLabel.className = "table-page";
    pageLabel.setAttribute("aria-live", "polite");

    const next = document.createElement("button");
    next.type = "button";
    next.textContent = "Next →";
    next.setAttribute("aria-controls", table.id);

    pagination.append(previous, pageLabel, next);

    const summary = document.createElement("div");
    summary.className = "table-summary";
    summary.append(count, pagination);

    const sortPanel = document.createElement("div");
    sortPanel.className = "table-sort-panel";

    const sortHint = document.createElement("span");
    sortHint.className = "table-sort-hint";
    sortHint.textContent = "Sort: click a heading; Shift+click adds another key.";

    const sortList = document.createElement("div");
    sortList.className = "table-sort-list";
    sortList.setAttribute("aria-live", "polite");

    const clearSort = document.createElement("button");
    clearSort.className = "table-clear-sort";
    clearSort.type = "button";
    clearSort.textContent = "Clear sort";
    clearSort.setAttribute("aria-controls", table.id);
    clearSort.hidden = true;

    sortPanel.append(sortHint, sortList, clearSort);
    tools.append(searchGroup, summary, sortPanel);
    table.parentElement.insertBefore(tools, table);

    const filterRow = document.createElement("tr");
    filterRow.className = "table-column-filters";

    headers.forEach((header, columnIndex) => {
      const filterCell = document.createElement("th");
      filterCell.scope = "col";
      const headerName = headerNames[columnIndex];
      const normalizedHeader = normalizeText(headerName);
      let control;

      if (SELECT_FILTER_COLUMNS.has(normalizedHeader)) {
        control = document.createElement("select");
        const allOption = document.createElement("option");
        allOption.value = "";
        allOption.textContent = `All ${headerName.toLocaleLowerCase()}`;
        control.appendChild(allOption);

        const options = new Map();
        records.forEach((record) => {
          const value = record.filterValues[columnIndex];
          if (!value || options.has(value)) return;
          options.set(
            value,
            filterOptionLabel(headerName, value, record.values[columnIndex]),
          );
        });
        Array.from(options.entries())
          .sort((left, right) => collator.compare(left[1], right[1]))
          .forEach(([value, label]) => {
            const option = document.createElement("option");
            option.value = value;
            option.textContent = label;
            control.appendChild(option);
          });
      } else {
        control = document.createElement("input");
        control.type = "search";
        control.placeholder = `Filter ${headerName}`;
      }

      control.className = "table-column-filter";
      control.setAttribute("aria-label", `Filter by ${headerName}`);
      control.setAttribute("aria-controls", table.id);
      control.addEventListener("click", (event) => event.stopPropagation());
      control.addEventListener("keydown", (event) => event.stopPropagation());
      const updateColumnFilter = () => {
        const value = normalizeText(control.value);
        columnFilters[columnIndex] = value
          ? { value, exact: control.tagName === "SELECT" }
          : null;
        page = 0;
        applyState();
      };
      control.addEventListener(
        control.tagName === "SELECT" ? "change" : "input",
        updateColumnFilter,
      );

      filterControls.push(control);
      filterCell.appendChild(control);
      filterRow.appendChild(filterCell);
    });
    headerRow.parentElement.appendChild(filterRow);

    function renderSortControls() {
      headers.forEach((header, columnIndex) => {
        const keyIndex = sortKeys.findIndex((key) => key.columnIndex === columnIndex);
        delete header.dataset.sortDirection;
        delete header.dataset.sortPriority;
        header.setAttribute("aria-sort", "none");
        header.setAttribute(
          "aria-label",
          `${headerNames[columnIndex]}; activate to sort. Shift+activate to add a sort key.`,
        );
        if (keyIndex === -1) return;

        const key = sortKeys[keyIndex];
        header.dataset.sortDirection = key.direction;
        header.dataset.sortPriority = String(keyIndex + 1);
        header.setAttribute("aria-sort", keyIndex === 0 ? key.direction : "other");
        header.setAttribute(
          "aria-label",
          `${headerNames[columnIndex]}; ${key.direction}, sort priority ${keyIndex + 1}. ` +
            "Activate to change this sort; Shift+activate preserves the other keys.",
        );
      });

      sortList.replaceChildren();
      sortKeys.forEach((key, keyIndex) => {
        const chip = document.createElement("span");
        chip.className = "table-sort-key";

        const direction = document.createElement("button");
        direction.type = "button";
        direction.className = "table-sort-direction";
        const arrow = key.direction === "ascending" ? "↑" : "↓";
        direction.textContent = `${keyIndex + 1}. ${headerNames[key.columnIndex]} ${arrow}`;
        direction.title = `Reverse ${headerNames[key.columnIndex]} sort direction`;
        direction.setAttribute("aria-controls", table.id);
        direction.addEventListener("click", () => {
          sortKeys = sortKeys.map((candidate, index) =>
            index === keyIndex
              ? {
                  ...candidate,
                  direction:
                    candidate.direction === "ascending" ? "descending" : "ascending",
                }
              : candidate,
          );
          page = 0;
          applyState();
        });

        const remove = document.createElement("button");
        remove.type = "button";
        remove.className = "table-sort-remove";
        remove.textContent = "×";
        remove.title = `Remove ${headerNames[key.columnIndex]} from the sort`;
        remove.setAttribute(
          "aria-label",
          `Remove ${headerNames[key.columnIndex]} from the sort`,
        );
        remove.setAttribute("aria-controls", table.id);
        remove.addEventListener("click", () => {
          sortKeys = sortKeys.filter((_, index) => index !== keyIndex);
          page = 0;
          applyState();
        });

        chip.append(direction, remove);
        sortList.appendChild(chip);
      });
      clearSort.hidden = sortKeys.length === 0;
    }

    function render() {
      const pageCount = Math.max(1, Math.ceil(filteredRecords.length / pageSize));
      page = Math.min(page, pageCount - 1);
      const start = page * pageSize;
      const end = Math.min(start + pageSize, filteredRecords.length);
      const visibleRows = new Set(
        filteredRecords.slice(start, end).map((record) => record.row),
      );

      records.forEach((record) => (record.row.hidden = !visibleRows.has(record.row)));
      count.textContent =
        filteredRecords.length === 0
          ? `0 of ${records.length} rows`
          : `${start + 1}–${end} of ${filteredRecords.length} rows${
              filteredRecords.length === records.length ? "" : ` (${records.length} total)`
            }`;
      pageLabel.textContent = `Page ${page + 1} of ${pageCount}`;
      previous.disabled = page === 0;
      next.disabled = page + 1 >= pageCount;
      pagination.hidden = filteredRecords.length <= pageSize;
      clearFilters.disabled =
        normalizeText(input.value) === "" && columnFilters.every((filter) => !filter);
    }

    function applyState() {
      const orderedRecords = records.slice();
      if (sortKeys.length > 0) {
        orderedRecords.sort((left, right) =>
          compareRowRecords(left, right, sortKeys, collator),
        );
      }
      orderedRecords.forEach((record) => body.appendChild(record.row));
      filteredRecords = orderedRecords.filter((record) =>
        rowMatchesFilters(record, input.value, columnFilters),
      );
      renderSortControls();
      render();
    }

    input.addEventListener("input", () => {
      page = 0;
      applyState();
    });
    clearFilters.addEventListener("click", () => {
      input.value = "";
      filterControls.forEach((control, columnIndex) => {
        control.value = "";
        columnFilters[columnIndex] = null;
      });
      page = 0;
      applyState();
      input.focus();
    });
    previous.addEventListener("click", () => {
      page -= 1;
      render();
    });
    next.addEventListener("click", () => {
      page += 1;
      render();
    });
    clearSort.addEventListener("click", () => {
      sortKeys = [];
      page = 0;
      applyState();
    });

    headers.forEach((header, columnIndex) => {
      header.tabIndex = 0;
      header.setAttribute("role", "button");

      const sort = (additive) => {
        sortKeys = updateSortKeys(sortKeys, columnIndex, additive);
        page = 0;
        applyState();
      };

      header.addEventListener("click", (event) => sort(event.shiftKey));
      header.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          sort(event.shiftKey);
        }
      });
    });

    applyState();
  }

  const api = {
    compareRowRecords,
    filterValueForColumn,
    normalizeTableSections,
    normalizeText,
    rowMatchesFilters,
    updateSortKeys,
  };

  if (typeof module !== "undefined" && module.exports) module.exports = api;
  if (typeof document !== "undefined") {
    document.addEventListener("DOMContentLoaded", () => {
      document
        .querySelectorAll("article table")
        .forEach((table, tableIndex) => enhanceTable(table, tableIndex));
    });
  }
})();

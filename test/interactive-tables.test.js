const test = require("node:test");
const assert = require("node:assert/strict");

const {
  compareRowRecords,
  filterValueForColumn,
  normalizeTableSections,
  rowMatchesFilters,
  updateSortKeys,
} = require("../docs/src/assets/interactive-tables.js");

const collator = new Intl.Collator("en", {
  numeric: true,
  sensitivity: "base",
});

test("global and per-column filters are combined", () => {
  const row = {
    searchText: "12 cumsum structured matrices linearalgebra issue posted",
    filterValues: ["12", "cumsum structured matrices", "linearalgebra", "issue", "posted"],
  };

  assert.equal(
    rowMatchesFilters(row, "structured posted", [
      null,
      null,
      { value: "linear", exact: false },
      { value: "issue", exact: true },
      null,
    ]),
    true,
  );
  assert.equal(
    rowMatchesFilters(row, "structured posted", [
      null,
      null,
      { value: "base", exact: true },
      { value: "issue", exact: true },
      null,
    ]),
    false,
  );
});

test("status and reproducer filters use stable categories", () => {
  assert.equal(
    filterValueForColumn("Status", "posted (JuliaLang/LinearAlgebra.jl#1865)"),
    "posted",
  );
  assert.equal(filterValueForColumn("Status", "not posted"), "not posted");
  assert.equal(filterValueForColumn("Reproducer", "—"), "none");
  assert.equal(filterValueForColumn("Reproducer", "example.jl"), "available");
});

test("Documenter tables without thead are normalized before enhancement", () => {
  const headerRow = { id: "header" };
  const body = { rows: [{ id: "data" }] };
  const head = {
    rows: [],
    appendChild(row) {
      this.rows.push(row);
    },
  };
  const table = {
    tHead: null,
    tBodies: [body],
    rows: [headerRow, ...body.rows],
    createTHead() {
      this.tHead = head;
      return head;
    },
  };

  assert.deepEqual(normalizeTableSections(table), { headerRow, body });
  assert.deepEqual(head.rows, [headerRow]);
});

test("additive sorting keeps independent directions and priorities", () => {
  let keys = updateSortKeys([], 2, false);
  assert.deepEqual(keys, [{ columnIndex: 2, direction: "ascending" }]);

  keys = updateSortKeys(keys, 5, true);
  assert.deepEqual(keys, [
    { columnIndex: 2, direction: "ascending" },
    { columnIndex: 5, direction: "ascending" },
  ]);

  keys = updateSortKeys(keys, 2, true);
  assert.deepEqual(keys, [
    { columnIndex: 2, direction: "descending" },
    { columnIndex: 5, direction: "ascending" },
  ]);

  keys = updateSortKeys(keys, 5, true);
  assert.deepEqual(keys, [
    { columnIndex: 2, direction: "descending" },
    { columnIndex: 5, direction: "descending" },
  ]);
});

test("multi-column comparison applies each direction in priority order", () => {
  const rows = [
    { values: ["LinearAlgebra", "10"], originalIndex: 0 },
    { values: ["Base", "2"], originalIndex: 1 },
    { values: ["Base", "11"], originalIndex: 2 },
  ];
  const keys = [
    { columnIndex: 0, direction: "ascending" },
    { columnIndex: 1, direction: "descending" },
  ];

  rows.sort((left, right) => compareRowRecords(left, right, keys, collator));
  assert.deepEqual(rows.map((row) => row.originalIndex), [2, 1, 0]);
});

test("a plain click replaces the existing sort while repeated clicks cycle", () => {
  let keys = [
    { columnIndex: 1, direction: "descending" },
    { columnIndex: 2, direction: "ascending" },
  ];

  keys = updateSortKeys(keys, 4, false);
  assert.deepEqual(keys, [{ columnIndex: 4, direction: "ascending" }]);
  keys = updateSortKeys(keys, 4, false);
  assert.deepEqual(keys, [{ columnIndex: 4, direction: "descending" }]);
  keys = updateSortKeys(keys, 4, false);
  assert.deepEqual(keys, []);
});

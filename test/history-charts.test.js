const test = require("node:test");
const assert = require("node:assert/strict");

const {
  computeStacks,
  stackTops,
  niceTicks,
  linScale,
  shortDate,
  AREA_ORDER,
} = require("../docs/src/assets/history-charts.js");

test("computeStacks accumulates per area and overall totals", () => {
  const dates = ["2026-11-13", "2026-11-14", "2026-11-15"];
  const areas = ["LinearAlgebra", "Base"];
  const addedByArea = { LinearAlgebra: [3, 0, 2], Base: [1, 4, 0] };
  const { cumulativeByArea, totals } = computeStacks(dates, areas, addedByArea);
  assert.deepEqual(cumulativeByArea.LinearAlgebra, [3, 3, 5]);
  assert.deepEqual(cumulativeByArea.Base, [1, 5, 5]);
  assert.deepEqual(totals, [4, 8, 10]);
});

test("computeStacks tolerates a missing/short area series", () => {
  const dates = ["a", "b"];
  const { cumulativeByArea, totals } = computeStacks(dates, ["X", "Y"], { X: [2] });
  assert.deepEqual(cumulativeByArea.X, [2, 2]);
  assert.deepEqual(cumulativeByArea.Y, [0, 0]);
  assert.deepEqual(totals, [2, 2]);
});

test("stackTops produces monotonically increasing stacked edges across areas", () => {
  const dates = ["a", "b"];
  const areas = ["LinearAlgebra", "Base"];
  const cumulativeByArea = { LinearAlgebra: [3, 5], Base: [1, 2] };
  const tops = stackTops(dates, areas, cumulativeByArea);
  assert.deepEqual(tops.LinearAlgebra, [3, 5]);
  assert.deepEqual(tops.Base, [4, 7]); // stacked on top of LinearAlgebra
});

test("niceTicks starts at 0, covers the max, uses a 1/2/5 grid", () => {
  const ticks = niceTicks(98, 5);
  assert.equal(ticks[0], 0);
  assert.ok(ticks[ticks.length - 1] >= 98);
  const step = ticks[1] - ticks[0];
  assert.ok([1, 2, 5, 10, 20, 25, 50].includes(step), `unexpected step ${step}`);
});

test("niceTicks handles small and zero maxima without looping", () => {
  assert.deepEqual(niceTicks(0, 5)[0], 0);
  assert.ok(niceTicks(3, 5).length >= 2);
});

test("linScale maps domain ends onto range ends", () => {
  const s = linScale(0, 10, 100, 200);
  assert.equal(s(0), 100);
  assert.equal(s(10), 200);
  assert.equal(s(5), 150);
});

test("linScale is safe on a degenerate domain", () => {
  const s = linScale(5, 5, 0, 100);
  assert.equal(s(5), 0);
});

test("shortDate formats ISO dates and passes others through", () => {
  assert.equal(shortDate("2026-11-13"), "Nov 13");
  assert.equal(shortDate("2026-01-01"), "Jan 1");
  assert.equal(shortDate("not-a-date"), "not-a-date");
});

test("AREA_ORDER is the fixed palette assignment order", () => {
  assert.equal(AREA_ORDER[0], "LinearAlgebra");
  assert.equal(new Set(AREA_ORDER).size, AREA_ORDER.length);
});

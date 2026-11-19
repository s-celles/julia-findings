// Renders the catalogue history time-series charts from data embedded in the page
// (a <script type="application/json" id="jf-history-data"> element). The pure data
// helpers are exported for the node test suite; the DOM rendering runs only in a browser.
(function () {
  "use strict";

  // Fixed area -> categorical slot (dataviz validated palette). Assigned by entity, never by rank.
  const AREA_ORDER = [
    "LinearAlgebra",
    "SparseArrays",
    "Base",
    "Statistics",
    "Dates",
    "Compiler",
  ];
  const PALETTE = {
    light: ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300"],
    dark: ["#3987e5", "#d95926", "#199e70", "#c98500", "#d55181", "#0ca30c"],
  };

  // --- pure helpers (exported, tested) ---

  // Cumulative running totals per area and the overall running total, over the ordered dates.
  function computeStacks(dates, areas, addedByArea) {
    const cumulativeByArea = {};
    const totals = new Array(dates.length).fill(0);
    for (const area of areas) {
      const added = addedByArea[area] || [];
      const running = [];
      let acc = 0;
      for (let i = 0; i < dates.length; i++) {
        acc += added[i] || 0;
        running.push(acc);
        totals[i] += acc;
      }
      cumulativeByArea[area] = running;
    }
    return { cumulativeByArea, totals };
  }

  // Stacked upper edges: for each date, the cumulative sum across areas in order, so
  // stackedTops[a][i] is the top y-value of area a's band at date i.
  function stackTops(dates, areas, cumulativeByArea) {
    const tops = {};
    const baseline = new Array(dates.length).fill(0);
    for (const area of areas) {
      const running = cumulativeByArea[area] || [];
      const top = [];
      for (let i = 0; i < dates.length; i++) {
        baseline[i] += running[i] || 0;
        top.push(baseline[i]);
      }
      tops[area] = top;
    }
    return tops;
  }

  // "Nice" axis ticks from 0 to >= maxValue, about targetCount steps, on a 1/2/5 * 10^k grid.
  function niceTicks(maxValue, targetCount) {
    const max = Math.max(1, maxValue);
    const count = Math.max(2, targetCount || 5);
    const rawStep = max / count;
    const mag = Math.pow(10, Math.floor(Math.log10(rawStep)));
    const norm = rawStep / mag;
    const step = (norm >= 5 ? 5 : norm >= 2 ? 2 : 1) * mag;
    const ticks = [];
    for (let v = 0; v <= max + step * 0.5; v += step) {
      ticks.push(Math.round(v * 1e6) / 1e6);
    }
    return ticks;
  }

  // Linear scale factory mapping [d0,d1] onto [r0,r1].
  function linScale(d0, d1, r0, r1) {
    const span = d1 - d0 || 1;
    return (v) => r0 + ((v - d0) / span) * (r1 - r0);
  }

  // "2026-11-13" -> "Nov 13"
  function shortDate(iso) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(iso));
    if (!m) return String(iso);
    return months[parseInt(m[2], 10) - 1] + " " + parseInt(m[3], 10);
  }

  const exported = { computeStacks, stackTops, niceTicks, linScale, shortDate, AREA_ORDER, PALETTE };
  if (typeof module !== "undefined" && module.exports) {
    module.exports = exported;
  }

  // --- DOM rendering (browser only) ---
  if (typeof document === "undefined") return;

  const SVG = "http://www.w3.org/2000/svg";
  const el = (name, attrs, parent) => {
    const node = document.createElementNS(SVG, name);
    if (attrs) for (const k in attrs) node.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(node);
    return node;
  };
  const isDark = () =>
    /theme--(documenter-dark|catppuccin)/.test(document.documentElement.className);

  function render() {
    const dataNode = document.getElementById("jf-history-data");
    const mount = document.getElementById("jf-history-charts");
    if (!dataNode || !mount) return;
    let data;
    try {
      data = JSON.parse(dataNode.textContent);
    } catch (e) {
      return;
    }
    const areas = (data.areas || []).filter((a) => AREA_ORDER.indexOf(a) !== -1);
    const dates = data.dates || [];
    if (!dates.length || !areas.length) return;

    const colorsFor = () => {
      const ramp = isDark() ? PALETTE.dark : PALETTE.light;
      const map = {};
      areas.forEach((a) => (map[a] = ramp[AREA_ORDER.indexOf(a)]));
      return map;
    };

    const { cumulativeByArea, totals } = computeStacks(dates, areas, data.addedByArea || {});
    const tops = stackTops(dates, areas, cumulativeByArea);
    const yMax = totals.length ? totals[totals.length - 1] : 0;

    mount.textContent = "";

    // legend
    const legend = document.createElement("div");
    legend.className = "jf-chart-legend";
    const colors = colorsFor();
    areas.forEach((a) => {
      const item = document.createElement("span");
      item.className = "jf-legend-item";
      const sw = document.createElement("span");
      sw.className = "jf-legend-swatch";
      sw.style.background = colors[a];
      item.appendChild(sw);
      item.appendChild(document.createTextNode(a));
      legend.appendChild(item);
    });
    mount.appendChild(legend);

    // chart
    const W = 760, H = 340, m = { t: 16, r: 16, b: 34, l: 40 };
    const iw = W - m.l - m.r, ih = H - m.t - m.b;
    const svg = el("svg", {
      viewBox: `0 0 ${W} ${H}`,
      class: "jf-chart-svg",
      role: "img",
      "aria-label": "Cumulative findings by component over time",
    });
    svg.style.width = "100%";
    svg.style.height = "auto";
    mount.appendChild(svg);

    const x = linScale(0, Math.max(1, dates.length - 1), m.l, m.l + iw);
    const y = linScale(0, Math.max(1, yMax), m.t + ih, m.t);
    const ink = isDark() ? "#c4c4c0" : "#4a4a46";
    const grid = isDark() ? "#333330" : "#e6e6e2";

    // y grid + ticks
    niceTicks(yMax, 5).forEach((t) => {
      el("line", { x1: m.l, y1: y(t), x2: m.l + iw, y2: y(t), stroke: grid, "stroke-width": 1 }, svg);
      const lbl = el("text", { x: m.l - 6, y: y(t) + 3, "text-anchor": "end", class: "jf-tick" }, svg);
      lbl.textContent = String(t);
      lbl.setAttribute("fill", ink);
    });
    // x ticks
    dates.forEach((d, i) => {
      const lbl = el("text", { x: x(i), y: m.t + ih + 20, "text-anchor": "middle", class: "jf-tick" }, svg);
      lbl.textContent = shortDate(d);
      lbl.setAttribute("fill", ink);
    });

    // stacked areas, drawn top area first so lower bands sit in front at the 2px gap
    const reversed = areas.slice().reverse();
    reversed.forEach((area) => {
      const idx = areas.indexOf(area);
      const upper = tops[area];
      const lowerArea = idx > 0 ? areas[idx - 1] : null;
      const lower = lowerArea ? tops[lowerArea] : null;
      let d = "";
      for (let i = 0; i < dates.length; i++) d += (i ? "L" : "M") + x(i) + "," + y(upper[i]);
      if (lower) {
        for (let i = dates.length - 1; i >= 0; i--) d += "L" + x(i) + "," + y(lower[i]);
      } else {
        for (let i = dates.length - 1; i >= 0; i--) d += "L" + x(i) + "," + y(0);
      }
      d += "Z";
      el("path", { d, fill: colors[area], "fill-opacity": 0.85, stroke: isDark() ? "#1a1a19" : "#fcfcfb", "stroke-width": 2, "stroke-linejoin": "round" }, svg);
    });

    // hover crosshair + tooltip
    const crosshair = el("line", { y1: m.t, y2: m.t + ih, stroke: ink, "stroke-width": 1, "stroke-dasharray": "3 3", opacity: 0 }, svg);
    const tip = document.createElement("div");
    tip.className = "jf-chart-tip";
    tip.style.opacity = "0";
    mount.appendChild(tip);
    const overlay = el("rect", { x: m.l, y: m.t, width: iw, height: ih, fill: "transparent" }, svg);
    overlay.style.cursor = "crosshair";
    const nearestIndex = (px) => {
      let best = 0, bestd = Infinity;
      for (let i = 0; i < dates.length; i++) {
        const dd = Math.abs(x(i) - px);
        if (dd < bestd) { bestd = dd; best = i; }
      }
      return best;
    };
    overlay.addEventListener("mousemove", (ev) => {
      const r = svg.getBoundingClientRect();
      const px = ((ev.clientX - r.left) / r.width) * W;
      const i = nearestIndex(px);
      crosshair.setAttribute("x1", x(i));
      crosshair.setAttribute("x2", x(i));
      crosshair.setAttribute("opacity", 1);
      const cmap = colorsFor();
      let rows = `<strong>${shortDate(dates[i])}</strong><span class="jf-tip-total">${totals[i]} total</span>`;
      areas.slice().reverse().forEach((a) => {
        rows += `<span class="jf-tip-row"><span class="jf-legend-swatch" style="background:${cmap[a]}"></span>${a}<b>${cumulativeByArea[a][i]}</b></span>`;
      });
      tip.innerHTML = rows;
      tip.style.opacity = "1";
      const left = (x(i) / W) * 100;
      tip.style.left = `calc(${left}% + ${left > 60 ? "-12.5rem" : "0.75rem"})`;
    });
    overlay.addEventListener("mouseleave", () => {
      crosshair.setAttribute("opacity", 0);
      tip.style.opacity = "0";
    });
  }

  const start = () => {
    render();
    // re-render on Documenter theme toggle so colors track light/dark
    const obs = new MutationObserver(render);
    obs.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();

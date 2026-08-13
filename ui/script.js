'use strict';

const root      = document.getElementById('root');
const body      = document.getElementById('body');
const tabsEl    = document.getElementById('tabs');
const classpick = document.getElementById('classpick');

let activeTab = 'standings';
let activeClass = 'S';
let lastData = [];
let filterText = '';

const searchbar    = document.getElementById('searchbar');
const searchInput  = document.getElementById('searchInput');
const searchCount  = document.getElementById('searchCount');
const SEARCHABLE = { standings: true, classes: true, records: true };

const RES = () => (typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'spz-leaderboard');
const inNui = () => typeof GetParentResourceName === 'function';

function esc(s) { return String(s == null ? '' : s).replace(/[&<>]/g, c => ({ '&':'&amp;','<':'&lt;','>':'&gt;' }[c])); }
function fmtNum(n) { return (Number(n) || 0).toLocaleString(); }

// ── NUI fetch ────────────────────────────────────────────────────────────────
async function fetchTab(tab, cls) {
  if (!inNui()) return MOCK[tab] || [];
  try {
    const res = await fetch(`https://${RES()}/lbFetch`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tab, class: cls }),
    });
    return await res.json();
  } catch (e) { return []; }
}

// ── Renderers ────────────────────────────────────────────────────────────────
function topClass(i) { return i === 1 ? 'top1' : i === 2 ? 'top2' : i === 3 ? 'top3' : ''; }

// Top-3 get the winged trophy emblem; everyone else a plain rank number.
const MEDAL = { 1: 'gold', 2: 'silver', 3: 'brozen' };
function rankCell(rk) {
  const m = MEDAL[rk];
  return m
    ? `<div class="rk rk-medal"><img src="Assets/${m}.png" alt="#${rk}" draggable="false"></div>`
    : `<div class="rk">${rk}</div>`;
}

function renderStandings(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty"><span>No standings recorded yet.</span></div>`;
  
  const header = `
    <div class="table-header">
      <div style="width: 32px; text-align: center;">#</div>
      <div style="flex: 1; margin-left: 16px;">DRIVER</div>
      <div style="width: 48px; text-align: center;">TIER</div>
      <div style="width: 70px; text-align: right;">iRATING</div>
      <div style="width: 70px; text-align: right;">SAFETY</div>
      <div style="width: 70px; text-align: right;">POINTS</div>
    </div>`;

  const items = rows.map((r, idx) => {
    const rk = r.rank || idx + 1;
    const tier = esc(r.tier || 'D');
    const name = esc(r.name || 'Racer');
    const title = esc(r.rank_title || 'D-5');
    const lvl = r.level || 1;
    const ir = fmtNum(r.iRating || 1000);
    const sr = (Number(r.sr) || 3.0).toFixed(2);
    const pts = fmtNum(r.points || 0);

    return `<div class="row ${topClass(rk)}">
      ${rankCell(rk)}
      <div class="who">
        <div class="nm">${name}</div>
        <div class="meta">${title} · LVL ${lvl}</div>
      </div>
      <span class="chip ${tier}">${tier}</span>
      <div class="stat"><div class="v">${ir}</div><div class="l">iR</div></div>
      <div class="stat"><div class="v">${sr}</div><div class="l">SR</div></div>
      <div class="stat"><div class="v">${pts}</div><div class="l">PTS</div></div>
    </div>`;
  }).join('');

  return header + items;
}

function renderClasses(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty"><span>No racers in this class yet.</span></div>`;
  
  const header = `
    <div class="table-header">
      <div style="width: 32px; text-align: center;">#</div>
      <div style="flex: 1; margin-left: 16px;">DRIVER</div>
      <div style="width: 70px; text-align: right;">WINS</div>
      <div style="width: 70px; text-align: right;">WIN %</div>
      <div style="width: 70px; text-align: right;">POINTS</div>
    </div>`;

  const items = rows.map((r, idx) => {
    const rk = r.rank || idx + 1;
    const name = esc(r.name || 'Racer');
    const races = r.total_races || 0;
    const wins = r.wins || 0;
    const wr = r.win_rate != null ? Math.round(r.win_rate * 100) + '%' : '0%';
    const pts = fmtNum(r.points || 0);

    return `<div class="row ${topClass(rk)}">
      ${rankCell(rk)}
      <div class="who">
        <div class="nm">${name}</div>
        <div class="meta">${races} races driven</div>
      </div>
      <div class="stat"><div class="v pos">${wins}</div><div class="l">Wins</div></div>
      <div class="stat"><div class="v">${wr}</div><div class="l">Win%</div></div>
      <div class="stat"><div class="v">${pts}</div><div class="l">CP</div></div>
    </div>`;
  }).join('');

  return header + items;
}

function renderRecords(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty"><span>No track records established yet.</span></div>`;
  
  const header = `
    <div class="table-header">
      <div style="width: 48px; text-align: center;">CLASS</div>
      <div style="flex: 1; margin-left: 16px;">TRACK / HOLDER</div>
      <div style="width: 100px; text-align: right;">BEST LAP</div>
    </div>`;

  const items = rows.map(r => {
    const cls = esc(r.car_class || r.class || 'S');
    const track = esc(r.track_name || r.track || 'Track');
    const holder = esc(r.player_name || r.holder || 'Racer');
    const time = esc(r.lap_time_f || r.best_time_f || '--:--');

    return `<div class="row">
      <span class="chip ${cls}">${cls}</span>
      <div class="who">
        <div class="nm">${track}</div>
        <div class="meta">Record Holder: ${holder}</div>
      </div>
      <div class="stat"><div class="v time">${time}</div><div class="l">Record</div></div>
    </div>`;
  }).join('');

  return header + items;
}

function renderActivity(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty"><span>No recent activity feed.</span></div>`;
  
  return rows.map(r => {
    const title = esc(r.title || (r.player ? r.player + ' ' + (r.action || 'raced at') + ' ' + (r.detail || 'Track') : 'Race Result'));
    const when = r.raced_at || r.timestamp ? String(r.raced_at || r.timestamp).slice(0, 16).replace('T', ' ') : 'Just now';
    return `<div class="row">
      <div class="who">
        <div class="nm">${title}</div>
        <div class="meta">${esc(when)}</div>
      </div>
    </div>`;
  }).join('');
}

function renderMe(s) {
  if (!s) return `<div class="lb-empty"><span>No stats profile data available.</span></div>`;
  const cell = (v, l) => `<div class="mscell"><div class="v">${v}</div><div class="l">${l}</div></div>`;
  const wr = s.total_races ? Math.round((s.wins || 0) / s.total_races * 100) + '%' : '0%';
  return `<div class="mystats">
    ${cell(fmtNum(s.total_races || 0), 'Races Completed')}
    ${cell(fmtNum(s.wins || 0), 'Victories')}
    ${cell(fmtNum(s.podiums || 0), 'Podium Finishes')}
    ${cell(wr, 'Win Ratio')}
    ${cell(fmtNum(s.iRating || 1000), 'iRating Score')}
    ${cell((Number(s.sr) || 3.0).toFixed(2), 'Safety Rating')}
  </div>`;
}

const RENDER = {
  standings: renderStandings,
  classes:   renderClasses,
  records:   renderRecords,
  activity:  renderActivity,
  me:        renderMe,
};

// ── Filtering ─────────────────────────────────────────────────────────────────
function matches(r, f) {
  if (!f) return true;
  const hay = (activeTab === 'records')
    ? ((r.track_name || r.track || '') + ' ' + (r.player_name || r.holder || ''))
    : (r.name || '');
  return hay.toLowerCase().includes(f);
}

function renderCurrent() {
  // Non-searchable tabs (My Stats is an object, not a list) render as-is.
  if (!SEARCHABLE[activeTab] || !Array.isArray(lastData)) {
    body.innerHTML = RENDER[activeTab](lastData);
    return;
  }
  const rows = lastData;
  const filtered = filterText ? rows.filter(r => matches(r, filterText)) : rows;
  body.innerHTML = RENDER[activeTab](filtered);
  if (searchCount) searchCount.textContent = filterText ? `${filtered.length}/${rows.length}` : '';
}

// ── Load a tab ───────────────────────────────────────────────────────────────
async function loadTab() {
  classpick.classList.toggle('hidden', activeTab !== 'classes' && activeTab !== 'records');
  searchbar.classList.toggle('hidden', !SEARCHABLE[activeTab]);
  filterText = '';
  if (searchInput) searchInput.value = '';
  if (searchCount) searchCount.textContent = '';

  body.innerHTML = `
    <div class="lb-loading">
      <div class="spinner"></div>
      <span>Loading Telemetry...</span>
    </div>`;
  lastData = await fetchTab(activeTab, activeClass);
  renderCurrent();
}

// ── Event Handlers ────────────────────────────────────────────────────────────
tabsEl.addEventListener('click', e => {
  const b = e.target.closest('.tab');
  if (!b) return;
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
  b.classList.add('active');
  activeTab = b.dataset.tab;
  loadTab();
});

classpick.addEventListener('click', e => {
  const b = e.target.closest('.cls-btn');
  if (!b) return;
  document.querySelectorAll('.cls-btn').forEach(t => t.classList.remove('active'));
  b.classList.add('active');
  activeClass = b.dataset.cls;
  loadTab();
});

function close() {
  root.classList.add('hidden');
  if (inNui()) fetch(`https://${RES()}/lbClose`, { method: 'POST', body: '{}' }).catch(() => {});
}

if (searchInput) {
  searchInput.addEventListener('input', e => {
    filterText = String(e.target.value || '').trim().toLowerCase();
    renderCurrent();
  });
}

document.getElementById('closeBtn').addEventListener('click', close);
document.addEventListener('keydown', e => { if (e.key === 'Escape') close(); });

window.addEventListener('message', e => {
  const m = e.data || {};
  if (m.action === 'open') { root.classList.remove('hidden'); loadTab(); }
  else if (m.action === 'close') { root.classList.add('hidden'); }
});

// ── Browser preview mock ─────────────────────────────────────────────────────
const MOCK = {
  standings: [
    { rank: 1, name: 'SPICEZ', tier: 'S', rank_title: 'Legend', level: 24, iRating: 1840, sr: 3.42, points: 12500 },
    { rank: 2, name: 'ItzSteve', tier: 'A', rank_title: 'Pro', level: 18, iRating: 1620, sr: 2.98, points: 9800 },
    { rank: 3, name: 'Ghost', tier: 'A', rank_title: 'Pro', level: 15, iRating: 1510, sr: 2.10, points: 8100 },
  ],
  classes: [
    { rank: 1, name: 'SPICEZ', wins: 42, total_races: 60, win_rate: 0.7, points: 400 },
    { rank: 2, name: 'Ghost', wins: 20, total_races: 55, win_rate: 0.36, points: 260 },
  ],
  records: [
    { track: 'Downtown GP', car_class: 'S', player_name: 'SPICEZ', lap_time_f: '01:12.45' },
    { track: 'Docks Lines', car_class: 'A', player_name: 'Ghost', lap_time_f: '01:44.02' },
  ],
  activity: [
    { title: 'SPICEZ won Downtown GP (S)', raced_at: '2026-07-13 20:11' },
    { title: 'Ghost set a record on Docks Lines', raced_at: '2026-07-13 19:40' },
  ],
  me: { total_races: 60, wins: 42, podiums: 51, iRating: 1840, sr: 3.42 },
};

if (!inNui()) { root.classList.remove('hidden'); loadTab(); }

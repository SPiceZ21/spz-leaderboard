'use strict';

const root      = document.getElementById('root');
const body      = document.getElementById('body');
const tabsEl    = document.getElementById('tabs');
const classpick = document.getElementById('classpick');

let activeTab = 'standings';
let activeClass = 'S';

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

function renderStandings(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty">No standings yet.</div>`;
  return rows.map((r, idx) => {
    const rk = r.rank || idx + 1;
    const crew = r.crewTag ? `<span class="crew">[${esc(r.crewTag)}]</span>` : '';
    return `<div class="row ${topClass(rk)}">
      <div class="rk">${rk}</div>
      <span class="chip ${esc(r.tier || 'D')}">${esc(r.tier || 'D')}</span>
      <div class="who">
        <div class="nm">${crew}${esc(r.name || 'Racer')}</div>
        <div class="meta">${esc(r.rank_title || '')} · LVL ${r.level || 1}</div>
      </div>
      <div class="stat"><div class="v">${fmtNum(r.iRating)}</div><div class="l">iR</div></div>
      <div class="stat"><div class="v">${(Number(r.sr)||0).toFixed(2)}</div><div class="l">SR</div></div>
      <div class="stat"><div class="v">${fmtNum(r.points)}</div><div class="l">PTS</div></div>
    </div>`;
  }).join('');
}

function renderClasses(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty">No racers in this class yet.</div>`;
  return rows.map((r, idx) => {
    const rk = r.rank || idx + 1;
    const crew = r.crewTag ? `<span class="crew">[${esc(r.crewTag)}]</span>` : '';
    const wr = r.win_rate != null ? Math.round(r.win_rate * 100) + '%' : '—';
    return `<div class="row ${topClass(rk)}">
      <div class="rk">${rk}</div>
      <div class="who">
        <div class="nm">${crew}${esc(r.name || 'Racer')}</div>
        <div class="meta">${r.total_races || 0} races</div>
      </div>
      <div class="stat"><div class="v pos">${r.wins || 0}</div><div class="l">Wins</div></div>
      <div class="stat"><div class="v">${wr}</div><div class="l">Win%</div></div>
      <div class="stat"><div class="v">${fmtNum(r.points)}</div><div class="l">CP</div></div>
    </div>`;
  }).join('');
}

function renderRecords(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty">No track records set.</div>`;
  return rows.map(r => {
    const cls = r.car_class || r.class || 'D';
    return `<div class="row">
      <span class="chip ${esc(cls)}">${esc(cls)}</span>
      <div class="who">
        <div class="nm">${esc(r.track || r.track_name || 'Track')}</div>
        <div class="meta">${esc(r.player_name || r.holder || '—')}</div>
      </div>
      <div class="stat"><div class="v time">${esc(r.lap_time_f || r.best_time_f || '--:--')}</div><div class="l">Record</div></div>
    </div>`;
  }).join('');
}

function renderActivity(rows) {
  if (!rows || !rows.length) return `<div class="lb-empty">No recent activity.</div>`;
  return rows.map(r => {
    const when = r.raced_at ? String(r.raced_at).slice(0, 16).replace('T', ' ') : '';
    return `<div class="row">
      <div class="who">
        <div class="nm">${esc(r.text || r.title || 'Race result')}</div>
        <div class="meta">${esc(when)}</div>
      </div>
    </div>`;
  }).join('');
}

function renderMe(s) {
  if (!s) return `<div class="lb-empty">No stats yet.</div>`;
  const cell = (v, l) => `<div class="mscell"><div class="v">${v}</div><div class="l">${l}</div></div>`;
  const wr = s.total_races ? Math.round((s.wins || 0) / s.total_races * 100) + '%' : '0%';
  return `<div class="mystats">
    ${cell(fmtNum(s.total_races || 0), 'Races')}
    ${cell(fmtNum(s.wins || 0), 'Wins')}
    ${cell(fmtNum(s.podiums || 0), 'Podiums')}
    ${cell(wr, 'Win Rate')}
    ${cell(fmtNum(s.iRating || 1000), 'iRating')}
    ${cell((Number(s.sr) || 0).toFixed(2), 'Safety')}
  </div>`;
}

const RENDER = {
  standings: renderStandings,
  classes:   renderClasses,
  records:   renderRecords,
  activity:  renderActivity,
  me:        renderMe,
};

// ── Load a tab ───────────────────────────────────────────────────────────────
async function loadTab() {
  classpick.classList.toggle('hidden', activeTab !== 'classes');
  body.innerHTML = `<div class="lb-loading">Loading…</div>`;
  const data = await fetchTab(activeTab, activeClass);
  body.innerHTML = RENDER[activeTab](data);
}

// ── Events ───────────────────────────────────────────────────────────────────
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
    { rank: 1, name: 'SPICEZ', crewTag: 'SPZ', tier: 'S', rank_title: 'Legend', level: 24, iRating: 1840, sr: 3.42, points: 12500 },
    { rank: 2, name: 'ItzSteve', tier: 'A', rank_title: 'Pro', level: 18, iRating: 1620, sr: 2.98, points: 9800 },
    { rank: 3, name: 'Ghost', crewTag: 'NOS', tier: 'A', rank_title: 'Pro', level: 15, iRating: 1510, sr: 2.10, points: 8100 },
  ],
  classes: [
    { rank: 1, name: 'SPICEZ', crewTag: 'SPZ', wins: 42, total_races: 60, win_rate: 0.7, points: 400 },
    { rank: 2, name: 'Ghost', wins: 20, total_races: 55, win_rate: 0.36, points: 260 },
  ],
  records: [
    { track: 'Downtown GP', car_class: 'S', player_name: 'SPICEZ', lap_time_f: '01:12.45' },
    { track: 'Docks Lines', car_class: 'A', player_name: 'Ghost', lap_time_f: '01:44.02' },
  ],
  activity: [
    { text: 'SPICEZ won Downtown GP (S)', raced_at: '2026-07-13T20:11' },
    { text: 'Ghost set a record on Docks Lines', raced_at: '2026-07-13T19:40' },
  ],
  me: { total_races: 60, wins: 42, podiums: 51, iRating: 1840, sr: 3.42 },
};

if (!inNui()) { root.classList.remove('hidden'); loadTab(); }

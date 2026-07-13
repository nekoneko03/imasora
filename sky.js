/* ===============================================================
   いま空 - 空の色エンジン (sky.js)
   緯度・経度・時刻から太陽高度・明るさ・空の色を計算する純粋関数群。
   ブラウザ (script タグ) でも Node (require) でも動く。
   Swift 版 (ios/Widget/SkyMath.swift) はこのロジックの移植なので、
   数式を変更したら両方を必ず合わせること。
   =============================================================== */
(function (root) {
  "use strict";
  const RAD = Math.PI / 180;
  const clamp = (v, a, b) => Math.max(a, Math.min(b, v));
  const lerp = (a, b, t) => a + (b - a) * t;

  /* ===== 太陽高度（緯度・経度・時刻から） ===== */
  function jdays(date) { return date.getTime() / 86400000 + 2440587.5 - 2451545.0; }
  function sunElevation(date, lat, lon) {
    const d = jdays(date);
    const g = (357.529 + 0.98560028 * d) * RAD;
    const q = 280.459 + 0.98564736 * d;
    const L = q + 1.915 * Math.sin(g) + 0.020 * Math.sin(2 * g);
    const Lr = L * RAD, e = (23.439 - 0.00000036 * d) * RAD;
    const ra = Math.atan2(Math.cos(e) * Math.sin(Lr), Math.cos(Lr)) / RAD;
    const dec = Math.asin(Math.sin(e) * Math.sin(Lr)) / RAD;
    const gmst = (280.46061837 + 360.98564736629 * d) % 360;
    const H = (((gmst + lon - ra) % 360)) * RAD;
    const dr = dec * RAD, lr = lat * RAD;
    return Math.asin(Math.sin(lr) * Math.sin(dr) + Math.cos(lr) * Math.cos(dr) * Math.cos(H)) / RAD;
  }
  /* 大気差（見かけの高度） */
  function refract(h) { if (h < -1) return h; return h + (1 / Math.tan((h + 7.31 / (h + 4.4)) * RAD)) / 60; }

  /* ===== 照度・明るさ ===== */
  const TWILIGHT = [[3, 3.65], [0, 2.60], [-6, 0.53], [-12, -2.10], [-18, -3.22]];
  const L_MIN = -3.22, L_MAX = Math.log10(133800);
  function log10Ill(h) {
    if (h >= 3) return Math.log10(133800 * Math.pow(Math.sin(Math.max(h, 0.5) * RAD), 1.15));
    if (h <= -18) return L_MIN;
    for (let i = 0; i < TWILIGHT.length - 1; i++) {
      const [h1, e1] = TWILIGHT[i], [h2, e2] = TWILIGHT[i + 1];
      if (h <= h1 && h >= h2) return e1 + (e2 - e1) * ((h - h1) / (h2 - h1));
    }
    return L_MIN;
  }
  const brightness = h => clamp((log10Ill(h) - L_MIN) / (L_MAX - L_MIN), 0, 1);

  /* ===== 空の色（色相と明るさを分離して合成） ===== */
  const SKY_STOPS = [
    [-18, [0.06, 0.10, 0.30], [0.09, 0.13, 0.34], '夜'],
    [-12, [0.10, 0.16, 0.42], [0.20, 0.22, 0.50], '天文薄明'],
    [-8, [0.20, 0.28, 0.62], [0.48, 0.36, 0.66], '航海薄明'],
    [-4, [0.35, 0.40, 0.75], [1.00, 0.52, 0.46], '市民薄明'],
    [0, [0.45, 0.55, 0.86], [1.00, 0.62, 0.35], '日の出/日の入り'],
    [3, [0.45, 0.63, 0.96], [1.00, 0.78, 0.55], 'ゴールデンアワー'],
    [10, [0.42, 0.66, 0.98], [0.75, 0.86, 1.00], '朝夕'],
    [30, [0.30, 0.55, 1.00], [0.60, 0.80, 1.00], '昼'],
    [60, [0.26, 0.50, 1.00], [0.55, 0.75, 1.00], '真昼'],
  ];
  function skyTint(h) {
    const S = SKY_STOPS; let lo = S[0], hi = S[S.length - 1];
    if (h <= S[0][0]) return { top: S[0][1], bottom: S[0][2], phase: S[0][3] };
    if (h >= hi[0]) return { top: hi[1], bottom: hi[2], phase: hi[3] };
    for (let i = 0; i < S.length - 1; i++) { if (h >= S[i][0] && h < S[i + 1][0]) { lo = S[i]; hi = S[i + 1]; break; } }
    const t = (h - lo[0]) / (hi[0] - lo[0]);
    const mix = (a, b) => [lerp(a[0], b[0], t), lerp(a[1], b[1], t), lerp(a[2], b[2], t)];
    return { top: mix(lo[1], hi[1]), bottom: mix(lo[2], hi[2]), phase: t < 0.5 ? lo[3] : hi[3] };
  }
  const AMBIENT = [5, 7, 18];
  function skyColors(h) {
    const tint = skyTint(h), B = brightness(h);
    const ap = c => [AMBIENT[0] + c[0] * B * 255, AMBIENT[1] + c[1] * B * 255, AMBIENT[2] + c[2] * B * 255];
    return { top: ap(tint.top), bottom: ap(tint.bottom), phase: tint.phase, B, lux: Math.pow(10, log10Ill(h)) };
  }
  const css = c => `rgb(${clamp(c[0] | 0, 0, 255)},${clamp(c[1] | 0, 0, 255)},${clamp(c[2] | 0, 0, 255)})`;

  /* ===== ゴールデンアワー/マジックアワーの時刻を求める =====
     指定日 (Date, ローカルの0:00付近) と緯度経度から、
     その日の朝と夕方の各フェーズの中心時刻を1分刻みで探索して返す。 */
  function findSkyEvents(baseDate, lat, lon) {
    const dayStart = new Date(baseDate); dayStart.setHours(0, 0, 0, 0);
    const elev = [];
    for (let m = 0; m <= 1440; m++) {
      const d = new Date(dayStart.getTime() + m * 60000);
      elev.push(refract(sunElevation(d, lat, lon)));
    }
    // 高度がしきい値を上向き/下向きに横切る分を探す
    function crossings(th) {
      const up = [], down = [];
      for (let m = 1; m <= 1440; m++) {
        if (elev[m - 1] < th && elev[m] >= th) up.push(m);
        if (elev[m - 1] >= th && elev[m] < th) down.push(m);
      }
      return { up, down };
    }
    const toDate = m => new Date(dayStart.getTime() + m * 60000);
    const events = [];
    // マジックアワー(市民薄明の中心 -3°) と ゴールデンアワー(高度 +4°) の朝夕
    const cMagic = crossings(-3), cGolden = crossings(4);
    if (cMagic.up[0] != null) events.push({ key: 'magic_morning', label: '朝のマジックアワー', at: toDate(cMagic.up[0]) });
    if (cGolden.up[0] != null) events.push({ key: 'golden_morning', label: '朝のゴールデンアワー', at: toDate(cGolden.up[0]) });
    if (cGolden.down.length) events.push({ key: 'golden_evening', label: '夕のゴールデンアワー', at: toDate(cGolden.down[cGolden.down.length - 1]) });
    if (cMagic.down.length) events.push({ key: 'magic_evening', label: '夕のマジックアワー', at: toDate(cMagic.down[cMagic.down.length - 1]) });
    return events;
  }

  const api = {
    RAD, clamp, lerp,
    sunElevation, refract, log10Ill, brightness,
    skyTint, skyColors, css, findSkyEvents, SKY_STOPS,
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  root.Sky = api;
})(typeof window !== 'undefined' ? window : globalThis);

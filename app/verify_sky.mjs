// 空の色エンジンの数値検証（sky.js の妥当性チェック）
// 使い方: node verify_sky.mjs
// SkyMath.swift を変更したら、このスクリプトの出力と Swift の出力を突き合わせること。
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const Sky = require('./www/sky.js');

const cases = [
  ['Tokyo noon', Date.UTC(2026, 6, 7, 3, 0, 0), 35.6895, 139.6917],
  ['Tokyo midnight', Date.UTC(2026, 6, 6, 15, 0, 0), 35.6895, 139.6917],
  ['Tokyo golden', Date.UTC(2026, 6, 7, 9, 45, 0), 35.6895, 139.6917],
  ['Reykjavik', Date.UTC(2026, 6, 7, 3, 0, 0), 64.1466, -21.9426],
  ['Sydney', Date.UTC(2026, 6, 7, 3, 0, 0), -33.8688, 151.2093],
];
for (const [n, ts, la, lo] of cases) {
  const h = Sky.refract(Sky.sunElevation(new Date(ts), la, lo));
  const s = Sky.skyColors(h);
  console.log(n.padEnd(16), 'elev=' + h.toFixed(3), 'top=' + Sky.css(s.top), 'bot=' + Sky.css(s.bottom), s.phase);
}
console.log('--- sky events (Tokyo, local) ---');
for (const e of Sky.findSkyEvents(new Date(2026, 6, 7), 35.6895, 139.6917)) {
  console.log(e.key.padEnd(16), e.at.toTimeString().slice(0, 5), e.label);
}

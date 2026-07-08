//  SkyMath.swift
//  いま空 - 空の色エンジン（www/sky.js の Swift 移植）
//  数式を変更したら sky.js と必ず一致させること。
//  ※ このファイルはウィジェット拡張ターゲットに追加する。

import Foundation
import SwiftUI

enum SkyMath {
    static let RAD = Double.pi / 180.0

    static func clamp(_ v: Double, _ a: Double, _ b: Double) -> Double { max(a, min(b, v)) }
    static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }

    // ユリウス日（J2000起点）
    static func jdays(_ date: Date) -> Double {
        return date.timeIntervalSince1970 / 86400.0 + 2440587.5 - 2451545.0
    }

    // 太陽高度（度）
    static func sunElevation(_ date: Date, lat: Double, lon: Double) -> Double {
        let d = jdays(date)
        let g = (357.529 + 0.98560028 * d) * RAD
        let q = 280.459 + 0.98564736 * d
        let L = q + 1.915 * sin(g) + 0.020 * sin(2 * g)
        let Lr = L * RAD
        let e = (23.439 - 0.00000036 * d) * RAD
        let ra = atan2(cos(e) * sin(Lr), cos(Lr)) / RAD
        let dec = asin(sin(e) * sin(Lr)) / RAD
        let gmst = (280.46061837 + 360.98564736629 * d).truncatingRemainder(dividingBy: 360)
        let H = ((gmst + lon - ra).truncatingRemainder(dividingBy: 360)) * RAD
        let dr = dec * RAD, lr = lat * RAD
        return asin(sin(lr) * sin(dr) + cos(lr) * cos(dr) * cos(H)) / RAD
    }

    // 大気差（見かけの高度）
    static func refract(_ h: Double) -> Double {
        if h < -1 { return h }
        return h + (1 / tan((h + 7.31 / (h + 4.4)) * RAD)) / 60.0
    }

    // 照度（log10 lux）
    static let TWILIGHT: [(Double, Double)] = [(3, 3.65), (0, 2.60), (-6, 0.53), (-12, -2.10), (-18, -3.22)]
    static let L_MIN = -3.22
    static let L_MAX = log10(133800.0)
    static func log10Ill(_ h: Double) -> Double {
        if h >= 3 { return log10(133800.0 * pow(sin(max(h, 0.5) * RAD), 1.15)) }
        if h <= -18 { return L_MIN }
        for i in 0..<(TWILIGHT.count - 1) {
            let (h1, e1) = TWILIGHT[i], (h2, e2) = TWILIGHT[i + 1]
            if h <= h1 && h >= h2 { return e1 + (e2 - e1) * ((h - h1) / (h2 - h1)) }
        }
        return L_MIN
    }
    static func brightness(_ h: Double) -> Double {
        return clamp((log10Ill(h) - L_MIN) / (L_MAX - L_MIN), 0, 1)
    }

    // 空の色ストップ
    struct Stop { let h: Double; let top: [Double]; let bottom: [Double]; let phase: String }
    static let SKY_STOPS: [Stop] = [
        Stop(h: -18, top: [0.06, 0.10, 0.30], bottom: [0.09, 0.13, 0.34], phase: "夜"),
        Stop(h: -12, top: [0.10, 0.16, 0.42], bottom: [0.20, 0.22, 0.50], phase: "天文薄明"),
        Stop(h: -8,  top: [0.20, 0.28, 0.62], bottom: [0.48, 0.36, 0.66], phase: "航海薄明"),
        Stop(h: -4,  top: [0.35, 0.40, 0.75], bottom: [1.00, 0.52, 0.46], phase: "市民薄明"),
        Stop(h: 0,   top: [0.45, 0.55, 0.86], bottom: [1.00, 0.62, 0.35], phase: "日の出/日の入り"),
        Stop(h: 3,   top: [0.45, 0.63, 0.96], bottom: [1.00, 0.78, 0.55], phase: "ゴールデンアワー"),
        Stop(h: 10,  top: [0.42, 0.66, 0.98], bottom: [0.75, 0.86, 1.00], phase: "朝夕"),
        Stop(h: 30,  top: [0.30, 0.55, 1.00], bottom: [0.60, 0.80, 1.00], phase: "昼"),
        Stop(h: 60,  top: [0.26, 0.50, 1.00], bottom: [0.55, 0.75, 1.00], phase: "真昼"),
    ]

    struct Tint { let top: [Double]; let bottom: [Double]; let phase: String }
    static func skyTint(_ h: Double) -> Tint {
        let S = SKY_STOPS
        if h <= S[0].h { return Tint(top: S[0].top, bottom: S[0].bottom, phase: S[0].phase) }
        let last = S[S.count - 1]
        if h >= last.h { return Tint(top: last.top, bottom: last.bottom, phase: last.phase) }
        var lo = S[0], hi = last
        for i in 0..<(S.count - 1) {
            if h >= S[i].h && h < S[i + 1].h { lo = S[i]; hi = S[i + 1]; break }
        }
        let t = (h - lo.h) / (hi.h - lo.h)
        func mix(_ a: [Double], _ b: [Double]) -> [Double] {
            [lerp(a[0], b[0], t), lerp(a[1], b[1], t), lerp(a[2], b[2], t)]
        }
        return Tint(top: mix(lo.top, hi.top), bottom: mix(lo.bottom, hi.bottom), phase: t < 0.5 ? lo.phase : hi.phase)
    }

    static let AMBIENT: [Double] = [5, 7, 18]
    struct SkyResult { let top: Color; let bottom: Color; let phase: String; let lux: Double; let elevation: Double }

    static func skyColors(_ date: Date, lat: Double, lon: Double) -> SkyResult {
        let h = refract(sunElevation(date, lat: lat, lon: lon))
        let tint = skyTint(h)
        let B = brightness(h)
        func ap(_ c: [Double]) -> Color {
            let r = clamp(AMBIENT[0] + c[0] * B * 255, 0, 255)
            let g = clamp(AMBIENT[1] + c[1] * B * 255, 0, 255)
            let b = clamp(AMBIENT[2] + c[2] * B * 255, 0, 255)
            return Color(red: r / 255, green: g / 255, blue: b / 255)
        }
        return SkyResult(top: ap(tint.top), bottom: ap(tint.bottom),
                         phase: tint.phase, lux: pow(10, log10Ill(h)), elevation: h)
    }
}

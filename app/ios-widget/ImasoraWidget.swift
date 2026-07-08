//  ImasoraWidget.swift
//  いま空 - ホーム画面ウィジェット（今の空の色を表示）
//
//  セットアップ:
//  1. Xcode で File > New > Target > Widget Extension（名前: ImasoraWidget）を追加
//  2. 生成された雛形の中身をこのファイルで置き換え、SkyMath.swift も同ターゲットに追加
//  3. アプリ本体・ウィジェット両ターゲットに App Group（例 group.com.kanekoyu.imasora.shared）を追加
//  4. 下の APP_GROUP をその App Group ID に合わせる
//
//  データ共有: アプリが Capacitor Preferences（group 設定）で
//  "CapacitorStorage.imasora_lat" / "...imasora_lon" に緯度経度を保存し、
//  ウィジェットはそれを読んで、現在時刻の空の色を自分で計算して描画する。

import WidgetKit
import SwiftUI

private let APP_GROUP = "group.com.kanekoyu.imasora.shared"

// Capacitor Preferences はキー名に "CapacitorStorage." を前置する
private func sharedDouble(_ key: String) -> Double? {
    guard let d = UserDefaults(suiteName: APP_GROUP) else { return nil }
    if let v = d.string(forKey: "CapacitorStorage." + key) { return Double(v) }
    if let v = d.string(forKey: key) { return Double(v) }
    let n = d.double(forKey: "CapacitorStorage." + key)
    return n != 0 ? n : nil
}
private func sharedString(_ key: String) -> String? {
    guard let d = UserDefaults(suiteName: APP_GROUP) else { return nil }
    return d.string(forKey: "CapacitorStorage." + key) ?? d.string(forKey: key)
}

struct SkyEntry: TimelineEntry {
    let date: Date
    let top: Color
    let bottom: Color
    let phase: String
    let sub: String
    let timeText: String
}

struct Provider: TimelineProvider {
    // 東京をデフォルト
    private let defaultLat = 35.6895, defaultLon = 139.6917

    private func makeEntry(_ date: Date, lat: Double, lon: Double, sub: String) -> SkyEntry {
        let sky = SkyMath.skyColors(date, lat: lat, lon: lon)
        let f = DateFormatter(); f.locale = Locale(identifier: "ja_JP"); f.dateFormat = "HH:mm"
        return SkyEntry(date: date, top: sky.top, bottom: sky.bottom,
                        phase: sky.phase, sub: sub, timeText: f.string(from: date))
    }

    func placeholder(in context: Context) -> SkyEntry {
        makeEntry(Date(), lat: defaultLat, lon: defaultLon, sub: "現在地")
    }

    func getSnapshot(in context: Context, completion: @escaping (SkyEntry) -> Void) {
        let lat = sharedDouble("imasora_lat") ?? defaultLat
        let lon = sharedDouble("imasora_lon") ?? defaultLon
        let sub = sharedString("imasora_sub") ?? "現在地"
        completion(makeEntry(Date(), lat: lat, lon: lon, sub: sub))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SkyEntry>) -> Void) {
        let lat = sharedDouble("imasora_lat") ?? defaultLat
        let lon = sharedDouble("imasora_lon") ?? defaultLon
        let sub = sharedString("imasora_sub") ?? "現在地"

        // これから3時間、10分刻みで色が変わるエントリを用意
        var entries: [SkyEntry] = []
        let now = Date()
        for step in stride(from: 0, through: 180, by: 10) {
            let d = now.addingTimeInterval(Double(step) * 60)
            entries.append(makeEntry(d, lat: lat, lon: lon, sub: sub))
        }
        // 3時間後に再読み込み
        completion(Timeline(entries: entries, policy: .after(now.addingTimeInterval(180 * 60))))
    }
}

struct ImasoraWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [entry.top, entry.bottom],
                           startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 2) {
                Text("いまの空色")
                    .font(.system(size: family == .systemSmall ? 13 : 15, weight: .heavy))
                    .kerning(1.5)
                Spacer()
                Text(entry.timeText)
                    .font(.system(size: family == .systemSmall ? 30 : 40, weight: .thin))
                    .monospacedDigit()
                Text(entry.phase)
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.9)
                if family != .systemSmall {
                    Text(entry.sub)
                        .font(.system(size: 10))
                        .opacity(0.7)
                        .lineLimit(1)
                }
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 1)
            .padding(14)
        }
    }
}

@main
struct ImasoraWidget: Widget {
    let kind = "ImasoraWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                ImasoraWidgetEntryView(entry: entry)
                    .containerBackground(.clear, for: .widget)
            } else {
                ImasoraWidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("いまの空色")
        .description("今の空の色を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

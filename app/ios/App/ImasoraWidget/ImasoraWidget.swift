//  ImasoraWidget.swift
//  いまの空色 - ホーム画面ウィジェット（今の空の色を表示）
//
//  長押し → 「ウィジェットを編集」で表示地点を切り替えられる（SelectPlaceIntent）。
//  「現在地」はアプリが最後に保存した緯度経度を使用。App Group 未設定時は東京。

import WidgetKit
import SwiftUI

struct SkyEntry: TimelineEntry {
    let date: Date
    let top: Color
    let bottom: Color
    let phase: String
    let sub: String
}

struct Provider: AppIntentTimelineProvider {
    // 東京をデフォルト
    private let defaultLat = 35.6895, defaultLon = 139.6917

    private func resolve(_ place: PlaceEntity?) -> (lat: Double, lon: Double, sub: String) {
        if let p = place, p.id != "here" {
            return (p.lat, p.lon, p.name)
        }
        // 現在地: アプリが保存した座標。無ければ東京
        let lat = SharedStore.double("imasora_lat") ?? defaultLat
        let lon = SharedStore.double("imasora_lon") ?? defaultLon
        let sub = SharedStore.string("imasora_sub") ?? "現在地"
        return (lat, lon, sub)
    }

    private func makeEntry(_ date: Date, lat: Double, lon: Double, sub: String) -> SkyEntry {
        let sky = SkyMath.skyColors(date, lat: lat, lon: lon)
        return SkyEntry(date: date, top: sky.top, bottom: sky.bottom, phase: sky.phase, sub: sub)
    }

    func placeholder(in context: Context) -> SkyEntry {
        makeEntry(Date(), lat: defaultLat, lon: defaultLon, sub: "現在地")
    }

    func snapshot(for configuration: SelectPlaceIntent, in context: Context) async -> SkyEntry {
        let r = resolve(configuration.place)
        return makeEntry(Date(), lat: r.lat, lon: r.lon, sub: r.sub)
    }

    func timeline(for configuration: SelectPlaceIntent, in context: Context) async -> Timeline<SkyEntry> {
        let r = resolve(configuration.place)
        // これから3時間、10分刻みで色が変わるエントリを用意
        var entries: [SkyEntry] = []
        let now = Date()
        for step in stride(from: 0, through: 180, by: 10) {
            let d = now.addingTimeInterval(Double(step) * 60)
            entries.append(makeEntry(d, lat: r.lat, lon: r.lon, sub: r.sub))
        }
        return Timeline(entries: entries, policy: .after(now.addingTimeInterval(180 * 60)))
    }
}

struct ImasoraWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: 2) {
                Text("いまの空色")
                    .font(.system(size: family == .systemSmall ? 12 : 14, weight: .heavy))
                    .kerning(1.2)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: family == .systemSmall ? 30 : 40, weight: .thin))
                    .monospacedDigit()
                Text(entry.phase)
                    .font(.system(size: 12, weight: .semibold))
                    .opacity(0.9)
                Text(entry.sub)
                    .font(.system(size: 10))
                    .opacity(0.7)
                    .lineLimit(1)
            }
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

struct ImasoraWidget: Widget {
    let kind = "ImasoraWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectPlaceIntent.self, provider: Provider()) { entry in
            ImasoraWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: [entry.top, entry.bottom],
                                   startPoint: .top, endPoint: .bottom)
                }
        }
        .configurationDisplayName("いまの空色")
        .description("選んだ地点の、今の空の色を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

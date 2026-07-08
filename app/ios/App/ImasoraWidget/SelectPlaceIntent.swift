//  SelectPlaceIntent.swift
//  いまの空色 - ウィジェットの「編集」メニューで地点を選ぶための設定インテント
//  選択肢: 現在地 + アプリで登録した地点（App Group 経由で共有された imasora_places）

import AppIntents
import WidgetKit
import Foundation

let APP_GROUP = "group.com.kanekoyu.imasora.shared"

struct WidgetPlace: Codable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
}

enum SharedStore {
    static func string(_ key: String) -> String? {
        guard let d = UserDefaults(suiteName: APP_GROUP) else { return nil }
        return d.string(forKey: "CapacitorStorage." + key) ?? d.string(forKey: key)
    }
    static func double(_ key: String) -> Double? {
        guard let v = string(key) else { return nil }
        return Double(v)
    }
    static func places() -> [WidgetPlace] {
        guard let raw = string("imasora_places"), let data = raw.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([WidgetPlace].self, from: data)) ?? []
    }
}

struct PlaceEntity: AppEntity {
    var id: String
    var name: String
    var lat: Double
    var lon: Double

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "地点"
    static var defaultQuery = PlaceQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    static let here = PlaceEntity(id: "here", name: "現在地", lat: 0, lon: 0)
}

struct PlaceQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [PlaceEntity] {
        allOptions().filter { identifiers.contains($0.id) }
    }
    func suggestedEntities() async throws -> [PlaceEntity] {
        allOptions()
    }
    func defaultResult() async -> PlaceEntity? {
        PlaceEntity.here
    }
    private func allOptions() -> [PlaceEntity] {
        [PlaceEntity.here] + SharedStore.places().map {
            PlaceEntity(id: $0.id, name: $0.name, lat: $0.lat, lon: $0.lon)
        }
    }
}

struct SelectPlaceIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "地点を選ぶ"
    static var description = IntentDescription("ウィジェットに表示する地点を選びます。")

    @Parameter(title: "地点")
    var place: PlaceEntity?
}

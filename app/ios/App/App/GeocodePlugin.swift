//  GeocodePlugin.swift
//  いま空 - 緯度経度から市区町村名を得る（iOS標準 CLGeocoder）
//  Capacitor 6 方式: CAPBridgedPlugin 準拠 + capacitor.config.json の packageClassList に登録
//  JS からは Capacitor.Plugins.Geocode.reverse({lat, lon}) で呼ぶ。

import Foundation
import Capacitor
import CoreLocation

@objc(GeocodePlugin)
public class GeocodePlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "GeocodePlugin"
    public let jsName = "Geocode"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "reverse", returnType: CAPPluginReturnPromise)
    ]

    private let geocoder = CLGeocoder()

    @objc func reverse(_ call: CAPPluginCall) {
        let lat = call.getDouble("lat") ?? 0
        let lon = call.getDouble("lon") ?? 0
        let loc = CLLocation(latitude: lat, longitude: lon)
        let locale = Locale(identifier: "ja_JP")

        geocoder.reverseGeocodeLocation(loc, preferredLocale: locale) { placemarks, error in
            if let error = error {
                call.reject(error.localizedDescription)
                return
            }
            guard let p = placemarks?.first else {
                call.reject("no placemark")
                return
            }
            // 表示用の短い名前: 区/町 > 市 > 都道府県
            let name = p.subLocality ?? p.locality ?? p.administrativeArea ?? p.name ?? ""
            // 説明用のフル表記: 東京都 渋谷区 など
            var parts: [String] = []
            if let admin = p.administrativeArea { parts.append(admin) }
            if let locality = p.locality, locality != p.administrativeArea { parts.append(locality) }
            if let sub = p.subLocality, sub != p.locality { parts.append(sub) }

            call.resolve([
                "name": name,
                "admin": p.administrativeArea ?? "",
                "locality": p.locality ?? "",
                "subLocality": p.subLocality ?? "",
                "full": parts.joined(separator: " ")
            ])
        }
    }
}

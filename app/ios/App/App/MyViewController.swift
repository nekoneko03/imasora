//  MyViewController.swift
//  いま空 - カスタムプラグインをコードで登録する
//  （capacitor.config.json の packageClassList は cap sync のたびに
//   上書きされるため、この方式で確実に登録する）

import UIKit
import Capacitor

class MyViewController: CAPBridgeViewController {
    override func capacitorDidLoad() {
        bridge?.registerPluginInstance(GeocodePlugin())
    }
}

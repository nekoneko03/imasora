# いま空 — iOS アプリ（Capacitor + WidgetKit）

現在地の空の色を自動表示し、ゴールデンアワー/マジックアワーを通知し、
ホーム画面ウィジェットにも今の空の色を出す iOS アプリです。

```
app/
├─ www/
│  ├─ index.html      # アプリ本体（現在地・比較・通知UI）
│  └─ sky.js          # 空の色エンジン（純粋関数）
├─ ios-widget/
│  ├─ SkyMath.swift       # sky.js の Swift 移植（ウィジェット用）
│  └─ ImasoraWidget.swift # WidgetKit ウィジェット
├─ package.json
├─ capacitor.config.json
└─ README.md
```

> ⚠️ `com.yourname.imasora` と App Group `group.com.yourname.imasora` は
> 自分の Bundle ID に置き換えてください（3ファイル: capacitor.config.json /
> www/index.html の `APP_GROUP` / ios-widget/*.swift の `APP_GROUP`）。

---

## 1. 前提

- macOS + Xcode（App Store から無料）
- Node.js / npm
- CocoaPods（`sudo gem install cocoapods`）
- App Store 配信には Apple Developer Program（年 $99）が必要

## 2. Capacitor プロジェクトを作る

```bash
cd app
npm install
npx cap init "いま空" com.yourname.imasora --web-dir=www   # ← 済ならスキップ
npx cap add ios
npx cap sync
npx cap open ios      # Xcode が開く
```

`npm install` に列挙済みのプラグイン: Geolocation / LocalNotifications /
Preferences / WidgetsBridge。`cap sync` で iOS 側に取り込まれます。

## 3. Info.plist に権限説明を追加

Xcode で App ターゲット → Info、または `ios/App/App/Info.plist` に追記:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>現在地の空の色を表示するために位置情報を使用します。</string>
```

通知は `LocalNotifications.requestPermissions()` を初回タップ時に呼ぶので
plist 追記は不要です（iOS の許可ダイアログが出ます）。

## 4. App Group を設定（ウィジェットとのデータ共有）

1. Xcode → App ターゲット → Signing & Capabilities → **+ Capability → App Groups**
2. `group.com.yourname.imasora` を追加
3. あとで作るウィジェット拡張ターゲットにも **同じ App Group** を追加

アプリは Capacitor Preferences をこの App Group に向けて緯度経度を保存し
（`www/index.html` の `saveForWidget`）、ウィジェットが同じ領域から読み取ります。

## 5. ウィジェット拡張を追加

1. Xcode → File → New → Target → **Widget Extension**（名前: `ImasoraWidget`、
   "Include Configuration Intent" はオフ）
2. 生成された `ImasoraWidget.swift` の中身を `ios-widget/ImasoraWidget.swift` で置き換え
3. `ios-widget/SkyMath.swift` を **ウィジェットtarget** に追加
   （File → Add Files… で Target Membership に ImasoraWidget をチェック）
4. ウィジェットターゲットにも App Group Capability を追加（手順4と同じID）
5. 両ファイル冒頭の `APP_GROUP` を自分のIDに合わせる

> ウィジェットは太陽高度を自前で計算するので、アプリが起動していなくても
> タイムライン更新（10分刻み・3時間分）で色が変わります。位置は最後にアプリが
> 保存した現在地を使います。

## 6. 実機で動作確認 → 申請

```bash
# www を変更したら毎回
npx cap copy ios
```

- Xcode で実機ビルド（現在地・通知はシミュレータだと挙動が限定的なので実機推奨）
- アイコン(1024²) / 起動画面 / スクショ / 説明文 / プライバシーポリシーを用意
- Product → Archive → App Store Connect にアップロード → 審査提出

### 審査メモ（ガイドライン 4.2 対策）
現在地表示・ローカル通知・ホーム画面ウィジェットという 3 つのネイティブ機能を
実装済みなので「ただの Web ページ」判定は受けにくい構成です。申請時の
"App Review Information" に、位置情報と通知の使いどころを一言添えると通りやすいです。

---

## 開発メモ

- 空の色の数式は `www/sky.js` と `ios-widget/SkyMath.swift` の**両方**にあります。
  片方を変えたら必ずもう片方も合わせてください（`verify_sky.mjs` で数値照合可能）。
- 位置情報を拒否された場合は東京を仮表示します。
- 通知は「今日と明日」のイベントの15分前に予約します。アプリを開くたび再スケジュール
  するのが確実です（iOS のローカル通知は最大64件の制限あり）。

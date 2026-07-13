# いまの空色 — App Store 申請素材（提出用・完成版）

App Store Connect の入力欄ごとに、そのままコピペできる形でまとめています。

---

## 1. アプリ情報（App Information）

| 項目 | 入力内容 |
|---|---|
| 名前（30字以内） | いまの空色 |
| サブタイトル（30字以内） | いまこの瞬間の、空の色を手のひらに |
| プライマリカテゴリ | 天気 |
| セカンダリカテゴリ | ライフスタイル |
| コンテンツ権利 | 「サードパーティコンテンツを含まない」を選択 |
| 年齢制限指定 | 全質問「なし」→ 4+ |
| Copyright | © 2026 金子裕亮 |

## 2. 価格および配信状況

| 項目 | 入力内容 |
|---|---|
| 価格 | 無料（¥0） |
| 配信地域 | すべての国と地域（推奨。日本のみでも可） |

## 3. プロモーションテキスト（170字以内・審査なしでいつでも変更可）

現在地の空の色を、太陽の位置から計算してそのまま表示。日の出前の群青、ゴールデンアワーの金色、暮れていく藍色。世界の都市といまの空を比べたり、時間を動かしたり。ホーム画面ウィジェットにも空の色を。

## 4. 説明文（4000字以内）

「いまの空色」は、いまこの瞬間の空の色を表示するアプリです。

カメラも天気予報も使いません。あなたのいる場所の緯度・経度と時刻から太陽の高度を計算し、空の色・明るさ・薄明のフェーズを描き出します。窓のない部屋にいても、地下鉄の中でも、空の色はそこにあります。

◆ 特徴

・現在地の空の色を自動表示。地名と明るさ（ルクス）、太陽高度も
・時刻スライダーは現在が中央。左右に動かすと今日の空の移ろいを再生。中央付近ほど細かく動く精密操作つき
・日付を変えれば、過去や未来の空も再現
・世界の都市・47都道府県と、いまの空を上下に並べて比較。時刻は各都市の現地時間で表示
・よく見る場所を地点登録してすぐ切り替え
・ホーム画面ウィジェットで、いつでも空の色がそばに。地点はウィジェットごとに選べます
・完全オフライン計算。アカウント登録も広告もなし

◆ こんなときに

・夕焼けを見逃したくないとき（ゴールデンアワーの近づきがわかります）
・海外の家族や友人の「いまの空」を感じたいとき
・写真撮影のマジックアワーの計画に
・ただ、きれいなグラデーションを眺めたいときに

◆ プライバシー

位置情報は空の色の計算だけに使い、端末の外には送信しません（地名表示のための Apple のサービスへの送信を除く）。詳しくはアプリ内・Web のプライバシーポリシーをご覧ください。

表示される色と明るさは太陽の位置から計算した理論値です。雲や天候による実際の見え方とは異なる場合があります。

## 5. キーワード（100字以内・カンマ区切り）

夕焼け,朝焼け,ゴールデンアワー,マジックアワー,薄明,日の出,日の入り,日没,グラデーション,ウィジェット,時差,世界時計,写真,癒し

## 6. URL

| 項目 | URL |
|---|---|
| サポートURL | https://imasora.vercel.app/contact.html |
| マーケティングURL（任意） | https://imasora.vercel.app/app.html |
| プライバシーポリシーURL | https://imasora.vercel.app/privacy.html |
| 利用規約（EULA欄は空欄=標準EULAでOK。参考） | https://imasora.vercel.app/terms.html |

## 7. 新機能（このバージョンの最新情報 / What's New）v1.0.0

はじめまして、「いまの空色」です。

・現在地・登録地点の空の色をリアルタイム表示
・時刻スライダーと日付指定で、過去や未来の空も
・世界の都市との比較モード
・ホーム画面ウィジェット

## 8. スクリーンショット（アップロードするファイル）

6.9インチ（1320×2868）: `app/store/screenshots/final/` の5枚をこの順で。

1. 01_hero_sunset.png — いま、あなたの空は何色？
2. 02_compare_hokkaido_okinawa.png — 北海道は朝焼け、沖縄は真夜中
3. 03_twilight.png — 電波がなくても、世界中の空を（パリ）
4. 04_widget.png — ホーム画面で、空をいつも隣に
5. 05_places.png — 行きたい場所の空を、いつでも

6.5インチ等の小さいサイズは6.9インチから自動流用されるため追加不要。

## 9. App Review 情報（審査担当者向け）

| 項目 | 入力内容 |
|---|---|
| サインイン情報 | 「サインインが必要」のチェックを外す（アカウント不要のため） |
| 連絡先（名・姓・メール） | 裕亮 / 金子 / kaneko.yu03@gmail.com |
| 電話番号 | ※自分の番号を国番号付きで（例: +81 90xxxxxxxx） |

メモ（Notes）欄 — 以下をそのまま貼り付け:

---
This app displays the theoretical sky color computed on-device from the sun's elevation (latitude/longitude/time). No weather API, no camera, no account, no ads.

- Location permission is OPTIONAL. If denied, users can still select places manually from the built-in prefecture/world city lists.
- Location data is used only for on-device calculation and is never sent to our servers. Reverse geocoding uses Apple's standard CLGeocoder service.
- The home screen widget can be tested by long-pressing the home screen → adding the "いまの空色" widget. Its place can be changed via long-press → Edit Widget. Places registered in the app appear as widget options.
- Terms of use are shown on first launch and require agreement.
- The displayed colors are theoretical values and may differ from the actual sky under clouds; this is stated in the app description and FAQ.

（参考日本語: 本アプリは太陽高度から空の色を端末内で計算して表示します。位置情報は任意で、拒否しても都市リストから利用できます。位置情報の外部送信はありません。）
---

## 10. アプリのプライバシー（App Privacy）申告

- データ収集: **「いいえ、このアプリからデータを収集しません」**

根拠: 位置情報は端末内計算のみでサーバー送信なし。逆ジオコーディングは Apple の標準サービス（開発者はデータを受け取らない）。広告・解析SDKなし。アカウントなし。

## 11. 輸出コンプライアンス / 各種宣言

| 項目 | 対応 |
|---|---|
| 暗号化（Export Compliance） | Info.plist に `ITSAppUsesNonExemptEncryption = false` 設定済み → 質問は表示されない。もし聞かれたら「標準的な暗号化のみ使用/非対象」を選択 |
| コンテンツ配信の権利 | 自作コンテンツのみ |
| 広告識別子（IDFA） | 使用しない |
| EU デジタルサービス法（DSA）の事業者ステータス | 「非事業者（トレーダーではない）」を選択（個人・非営利開発のため）。※EU配信する場合のみ表示 |

## 12. 提出手順（承認後の流れ）

1. Xcode: Product → Archive → Distribute App → App Store Connect にアップロード
2. App Store Connect → マイアプリ → 「+」→ 新規アプリ（名前: いまの空色 / バンドルID: jp.kanekoyu.imasora / SKU: imasora / プラットフォーム: iOS）
3. 本書 1〜11 を各欄にコピペ、スクショ5枚をアップロード
4. ビルドを選択 → 審査へ提出（通常1〜2営業日）

## 審査前 最終チェックリスト

- [x] バンドルID: jp.kanekoyu.imasora
- [x] App Group: group.com.kanekoyu.imasora.shared（ウィジェット連携確認済み）
- [x] 初回起動時の利用規約同意
- [x] プライバシーポリシー等を公開済み（imasora.vercel.app）
- [x] スクリーンショット5枚（final/）
- [x] タイムゾーンバグ修正（時刻コントロール=メイン都市の現地時間）
- [ ] 実機で最終確認: 位置情報許可→現在地表示→地点登録→ウィジェット→時差都市の時刻
- [ ] Developer Program 承認 → Xcode の Signing で Team を設定（※ビルド前に必ず新Teamを選ぶこと）
- [ ] 電話番号を App Review 連絡先に入力

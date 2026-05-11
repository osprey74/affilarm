# affilarm — アファメーションアラーム

毎朝のアラームを「アファメーション（肯定的なフレーズ）」の読み上げに置き換える iOS アプリ。設定した時刻に好きなボイスでフレーズを読み上げ、ポジティブな意図を朝のルーチンに組み込みます。

**Swift / SwiftUI** で実装。認証は Firebase Authentication、フレーズ生成は BYOK（Bring Your Own Key）方式の Claude API 連携を採用。

> **ステータス: 開発中。** 設計書は [HANDOFF_affirmation-alarm.md](HANDOFF_affirmation-alarm.md) を参照。

---

## コンセプト

- **意図を持って起きる。** 一般的なアラーム音の代わりに、選んだボイスでアファメーションを読み上げ
- **反復で定着。** 1回 / 3回 / 5回 / 10回 / ループで繰り返し再生し、潜在意識に刻む
- **個人的かつプライベート。** フレーズはデバイス内に保存。ストリーク・統計用途のみ Firebase によるクラウド同期を提供（オプション）

---

## 機能計画

### v1.0 — MVP

- 複数アラーム（曜日繰り返し対応）
- フレーズの手動入力 + キュレーション済みプリセット
- TTS（ボイス選択・速度・ピッチ・音量）
- 繰り返しモード: 1回 / 3回 / 5回 / 10回 / ループ
- アラーム発動時のフレーズ表示画面
- Firebase Authentication（メール / Google / Apple / 匿名）

### v1.1

- BYOK 方式の Claude API 連携によるフレーズ生成（カテゴリ × 組み合わせ／列挙モード）
- カテゴリ別プリセットフレーズライブラリ（APIキー不要）
- 呼吸ガイド（3秒 / 5秒 / 7秒の円形アニメーション）
- BGM プリセット

### v1.2

- TTS 読み上げ位置と連動するテキストハイライト
- 連続記録（ストリーク）
- バッジ実績（3日 / 7日 / 21日 / 66日）

### v1.3

- 統計ビュー（カレンダー + フレーズランキング）
- ホーム画面ウィジェット（iOS）
- Apple Watch コンパニオン

---

## 技術スタック

| レイヤー | 選定 |
|---|---|
| アプリ | Swift / SwiftUI — iOS 専用 |
| ローカルDB | SwiftData |
| 認証 | Firebase Authentication |
| AI（オプション） | Claude API — BYOK のみ |
| バックエンド | Hono on Fly.io（Firebaseトークン検証のみ） |
| TTS | `AVSpeechSynthesizer` |
| 通知 | `UNUserNotificationCenter` |

Claude API は iOS Keychain に保存したユーザー自身のAPIキーを使って **アプリから直接** 呼び出します。AIリクエスト用のプロキシサーバーは経由しません。

---

## なぜ BYOK 方式なのか

Anthropic の利用ポリシー（2026年2月更新）により、サードパーティアプリから Claude アカウントの OAuth でユーザー認証することは禁止されています。許可されているのは開発者APIキー方式のみ。運用コストをゼロに保ちつつポリシーに準拠するため、affilarm はユーザー自身の Anthropic APIキーをアプリ内で入力・ローカル保存して利用します。キー未登録時は同梱のプリセットフレーズライブラリにフォールバックします。

---

## リポジトリの状態

- 設計書: [HANDOFF_affirmation-alarm.md](HANDOFF_affirmation-alarm.md)
- タスク管理: [docs/tasks.md](docs/tasks.md)

---

## ライセンス

[MIT](LICENSE) © 2026 osprey74

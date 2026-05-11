# HANDOFF: affilarm — アファメーションアラームアプリ

## プロジェクト概要

毎朝のアファメーション習慣を目覚ましと統合したモバイルアプリ。
起床時刻に肯定的なフレーズをTTSで読み上げ、潜在意識への定着を促す。

- **アプリ名**: affilarm
- **プラットフォーム**: iOS
- **技術スタック**: Swift / SwiftUI
- **バックエンド**: Hono / Fly.io Tokyo（既存インフラ活用）
- **AI**: Claude API（フレーズ生成・開発者APIキー方式）
- **ユーザー認証**: Firebase Authentication（メール／Google／Apple）
- **ストア**: App Store

---

## 画面構成

```
TabBar
├── アラーム画面（ホーム）
├── フレーズ設定画面
├── AI生成画面
└── 設定画面
    └── ボイス設定
```

---

## 機能仕様

### 1. アラーム機能

#### 1-1. アラーム設定

- 複数アラームの登録・編集・削除
- 時刻設定（時/分）
- 曜日繰り返し設定
- 各アラームに対してフレーズセットを紐付け
- ON/OFFトグル

#### 1-2. アラーム発動時の画面

- 時刻・日付を大きく表示
- 今日のアファメーションフレーズを表示
- 「読み上げる」ボタン（手動開始）または自動再生
- 読み上げ中はテキストをハイライト表示（読み上げ位置に同期）
- 繰り返しカウンター表示（例：●●●○○）
- 「アラームを止める」ボタン

---

### 2. フレーズ生成機能

#### 2-1. カテゴリ選択

複数選択可能なチップUI。

| カテゴリ | アイコン | カラー |
|----------|----------|--------|
| ビジネス | briefcase | Blue |
| メンタル | brain | Purple |
| マネー | coin | Green |
| 人間関係 | heart | Pink |
| 健康 | run | Teal |

#### 2-2. 生成スタイル

| モード | 説明 |
|--------|------|
| **組み合わせ** | 選択したカテゴリを1文に融合して生成 |
| **列挙** | カテゴリごとに1文ずつ生成し連続読み上げ（1セット＝N文） |

#### 2-3. Claude APIへのプロンプト設計

```
システムプロンプト:
あなたはアファメーションフレーズ生成の専門家です。
以下のルールに従ってフレーズを生成してください。
- 現在形・言い切り形で書く（「〜できる」「〜である」）
- 1文は40字以内
- 自然な日本語
- 過度にポジティブすぎない、現実的なトーン
- JSON形式で返却

ユーザープロンプト（組み合わせモード）:
カテゴリ: [ビジネス, メンタル, マネー]
スタイル: 組み合わせ
上記カテゴリの要素を1文に融合したアファメーションフレーズを1つ生成してください。
{"phrase": "..."}

ユーザープロンプト（列挙モード）:
カテゴリ: [ビジネス, メンタル, マネー]
スタイル: 列挙
各カテゴリに対して1文ずつアファメーションフレーズを生成してください。
{"phrases": [{"category": "ビジネス", "phrase": "..."}, ...]}
```

#### 2-4. フレーズ管理

- 生成フレーズの保存・編集・削除
- お気に入り登録
- アラームへの紐付け
- 手動入力でオリジナルフレーズも登録可能

---

### 3. TTS（読み上げ）機能

#### 3-1. ボイス選択

| ボイス名 | 性別 | トーン |
|----------|------|--------|
| Hana | 女性 | 穏やか・温かみ |
| Sora | 女性 | 明るく・活発 |
| Ren | 男性 | 落ち着き・深み |
| Kai | 男性 | 爽やか・若々しい |

- iOS: `AVSpeechSynthesizer` + `ja-JP` ロケール音声から選択
- ボイス名はアプリ内の表示名。実際のシステム音声へのマッピングはOS依存

#### 3-2. 読み上げパラメータ

| パラメータ | 範囲 | デフォルト | API |
|------------|------|------------|-----|
| 速度 | 0.5× 〜 2.0× | 1.0× | `rate` |
| ピッチ | -5 〜 +5 | 0 | `pitchMultiplier` |
| 音量 | 0% 〜 100% | 80% | `volume` |

#### 3-3. 繰り返し設定

| モード | 動作 |
|--------|------|
| 1回のみ | 読み上げ後に通常アラームへ切替 |
| 3回 | 3回繰り返して終了 |
| 5回 | 5回繰り返して終了 |
| 10回 | 10回繰り返して終了 |
| ループ | 手動で止めるまで繰り返す |

- 列挙モードの場合は「全フレーズ読み上げ＝1セット」として繰り返す
- 繰り返し中は画面にカウンター表示（●●●○○ 形式）

---

### 4. 効果補助機能

#### 4-1. BGM（バックグラウンドミュージック）

- フレーズ読み上げ中にBGMを再生
- TTS音量とBGM音量は独立してスライダーで調整
- カテゴリ別プリセット:

| カテゴリ | BGMプリセット例 |
|----------|----------------|
| ビジネス | ローファイ・集中系 |
| メンタル | ヒーリング・自然音 |
| マネー | アップテンポ・ジャズ |
| 汎用 | ホワイトノイズ・無音 |

- 音源: アプリ同梱（ライセンスフリー）+ ユーザーが音楽アプリから選択（将来）

#### 4-2. 呼吸ガイド（読み上げ前）

- 読み上げ開始前に任意で「呼吸ガイド」を挿入
- 設定: ON/OFF + 秒数（3秒 / 5秒 / 7秒）
- 動作: 円形アニメーション（拡大＝吸う、縮小＝吐く）+ カウントダウン表示
- 完了後、自動でフレーズ読み上げ開始

#### 4-3. テキストハイライト同期

- 読み上げ中、発話位置に合わせてテキストをハイライト
- iOS: `AVSpeechSynthesizerDelegate.speechSynthesizer(_:willSpeakRangeOfSpeechString:utterance:)` を使用

---

### 5. 記録・統計機能

#### 5-1. 連続記録（ストリーク）

- アラームを止めるたびに「聴いた日」として記録
- 連続日数をホーム画面に表示
- 連続記録が途切れた場合の通知

#### 5-2. 統計

- 総再生回数
- フレーズ別再生回数ランキング
- カレンダービュー（達成日を色付け）

#### 5-3. バッジ（実績）

| バッジ名 | 条件 |
|----------|------|
| はじめの一歩 | 初めてアラームを聴く |
| 三日坊主を超えた | 3日連続 |
| 習慣の芽生え | 7日連続 |
| 本物の習慣 | 21日連続 |
| アファーマー | 66日連続 |

---

## 認証・API構成

### ユーザー認証方針

AnthropicはサードパーティアプリからのOAuthによるClaudeアカウントログインを**禁止**している（2026年2月ポリシー更新）。  
Claude APIの利用は開発者APIキー方式のみが公式に許可されている。

> 参考: https://docs.anthropic.com/en/policies/usage-policy

アプリ内のユーザー認証には **Firebase Authentication** を使用する。

| 認証方式 | 対応 | 備考 |
|----------|------|------|
| メール／パスワード | ✅ | 基本 |
| Googleログイン | ✅ | Android で特に親和性高い |
| Appleログイン | ✅ | iOS App Store 要件により必須 |
| 匿名認証 | ✅ | 初回起動時のオンボーディング用 |

---

### Claude API 利用方針

**採用方式: BYOK専用（ユーザー自身のAPIキー）**

フレーズ生成はユーザーが自分のAnthropicアカウントで取得したAPIキーを登録した場合のみ利用可能。  
APIキー未登録時はプリセットフレーズのみを使用する。開発者側のAPI費用負担はゼロ。

#### フレーズ選択フロー

```
アラーム設定 → フレーズ設定画面を開く
        │
        ├─ APIキー未登録
        │       └─ プリセットフレーズ一覧から選択
        │               （カテゴリ別に事前定義済みのフレーズ群）
        │
        └─ APIキー登録済み
                └─ AI生成モードが解放される
                        ├─ カテゴリ選択
                        ├─ 生成スタイル選択（組み合わせ／列挙）
                        └─ Claude API を呼び出してフレーズ生成
```

#### APIリクエスト経路

BYOKではユーザーキーをアプリから直接 Anthropic API に送信する。  
Honoバックエンドは Firebase認証のみに使用し、Claude APIのプロキシは行わない。

```
[モバイルアプリ]
     │  ユーザーの ANTHROPIC_API_KEY（Keychain/Keystore から取得）
     ▼
[Anthropic Claude API]  ※ アプリから直接呼び出し
     │  フレーズJSON返却
     ▼
[モバイルアプリ]
     └  フレーズをローカルDBに保存・キャッシュ
```

#### BYOK仕様

| 項目 | 仕様 |
|------|------|
| 入力UI | 設定画面にAPIキー入力欄を設置。入力後マスク表示 |
| 保存先 | iOS Keychain |
| バリデーション | 入力時に `/v1/models` エンドポイントで疎通確認。失敗時はエラーメッセージ表示 |
| エラー処理 | 無効キー・残高切れ・レート超過をそれぞれ日本語でユーザーに通知 |
| 削除 | 設定画面からキーを削除するとKeychain/Keystoreからも即時消去 |
| ガイド | Anthropic Consoleへのリンク＋APIキー取得手順をアプリ内に掲載 |
| キャッシュ | 生成済みフレーズはローカルDBに保存。同じ条件では再生成しない |

#### セキュリティ要件

- ユーザーAPIキーはiOS Keychainにのみ保存。ログ・クラッシュレポートに含めない
- 通信はHTTPS（Anthropic API エンドポイント）のみ。中間サーバーを経由しない
- Honoバックエンドへのリクエストは Firebase IDトークンで認証（フレーズ生成以外の用途）

---

## データ設計

### ローカルDB（SwiftData）

```
User
  uid: String           // Firebase UID
  email: String?
  displayName: String?
  createdAt: DateTime
  lastLoginAt: DateTime

Alarm
  id: String
  time: TimeOfDay
  weekdays: List<bool>  // 7要素
  isEnabled: bool
  phraseSetId: String
  repeatCount: int  // 0=ループ
  createdAt: DateTime

PhraseSet
  id: String
  name: String
  categories: List<Category>  // enum
  generationStyle: Style  // combine | list
  phrases: List<Phrase>
  voiceProfileId: String

Phrase
  id: String
  text: String
  category: Category
  isFavorite: bool
  playCount: int
  isAiGenerated: bool   // AI生成かプリセットか
  createdAt: DateTime

VoiceProfile
  id: String
  name: String
  voiceIdentifier: String  // OS音声ID
  rate: double
  pitch: double
  volume: double
  repeatMode: RepeatMode
  bgmTrack: String?
  bgmVolume: double
  breathingGuide: bool
  breathingDuration: int

PlayRecord
  id: String
  alarmId: String
  phraseSetId: String
  playedAt: DateTime
```

---

## リリース計画

### v1.0（MVP）

- [x] アラーム設定（複数登録、曜日繰り返し）
- [x] フレーズ手動入力・保存（プリセット付き）
- [x] TTS読み上げ（ボイス選択・速度・音量）
- [x] 繰り返し設定（1/3/5/10回・ループ）
- [x] アラーム発動時画面
- [x] Firebase Authentication（メール／Google／Apple）
- [x] 匿名認証によるオンボーディング（ログイン不要でまず試せる）

### v1.1

- [ ] BYOK対応（APIキー入力UI・Keychain/Keystore保存・疎通確認）
- [ ] APIキー登録済み時：Claude API フレーズ生成（カテゴリ選択・生成スタイル）
- [ ] APIキー未登録時：プリセットフレーズ選択UI（カテゴリ別）
- [ ] 呼吸ガイド
- [ ] BGM再生（プリセット音源）

### v1.2

- [ ] テキストハイライト同期（TTS読み上げ位置に連動）
- [ ] 記録・ストリーク表示
- [ ] バッジ実績

### v1.3

- [ ] 統計画面（カレンダービュー・フレーズ統計）
- [ ] ウィジェット対応（iOS・Android）
- [ ] Apple Watch 対応（バイブ＋フレーズ表示）

---

## 将来計画（高難易度・見送り）

以下の機能は効果が高いと考えられるが、実装難易度・工数・審査リスク等の理由から将来リリースに向けて保留する。

### 🔴 自分の声録音モード

**概要**: ユーザー自身がフレーズを録音し、アラーム時にその音声を再生する。自己関連性効果により潜在意識への定着率が高い。

**課題**:
- 録音ファイルのストレージ管理
- iOS/Android のマイクパーミッション管理
- 音質編集（ノイズ除去等）の実装
- App Store レビューでの音声録音機能の審査対応

**想定工数**: 3〜4週間

---

### 🔴 BGMユーザー選択（音楽アプリ連携）

**概要**: Spotify / Apple Music 等から好みのBGMを選択して再生できる。

**課題**:
- 各プラットフォームのAPI利用規約・SDK対応
- ストリーミング再生とTTSの音量ミックス
- サブスクリプション状態への依存

**想定工数**: 4〜6週間

---

### 🟡 AI音声（高品質TTS）

**概要**: ElevenLabs API や VOICEVOX 等の高品質音声合成を使用し、OSネイティブTTSより自然な読み上げを実現。

**課題**:
- API費用（従量課金）のユーザーへの転嫁設計
- オフライン動作不可（ネットワーク必須）
- VOICEVOX はモバイルへの組み込みが現状困難

**候補**:
- [ElevenLabs API](https://elevenlabs.io)（英語強い、日本語対応あり）
- [VOICEVOX](https://voicevox.hiroshiba.jp)（日本語特化、無料・商用可、ただしサーバーサイド運用が必要）

**想定工数**: 2〜3週間（ElevenLabs のみの場合）

---

### 🟡 AT Protocol バックアップ同期

**概要**: フレーズ・設定データを AT Protocol レコードとして保存し、デバイス間同期を実現。kazahana のノウハウを活用可能。

**課題**:
- AT Protocol のスキーマ設計（Lexicon定義）
- プライベートレコードの取り扱い方針
- PDS 選定（self-host vs Bluesky PDS）

**想定工数**: 2週間

---

## 開発環境・注意事項

- `UNUserNotificationCenter` でアラーム実装
- アラームの確実な発火には iOS のバックグラウンド実行制限に注意
- **Claude APIはアプリから直接呼び出す**（BYOKのためサーバープロキシ不要）。ユーザーキーはiOS Keychainのみに保存し、ログ・クラッシュレポートに絶対に含めない
- Firebase Authは統計・ストリーク等のクラウド同期用途のみ。フレーズ生成には不要なため、v1.0はローカル動作のみでも成立する
- Apple認証はApp Store提出要件のため必須実装
- 匿名認証ユーザーが後からログインした場合、ローカルデータをFirebase UIDに紐付けるマイグレーション処理が必要

---

## 将来計画（高難易度・見送り）

## 参考リンク

- AVSpeechSynthesizer: https://developer.apple.com/documentation/avfaudio/avspeechsynthesizer
- UNUserNotificationCenter: https://developer.apple.com/documentation/usernotifications/unusernotificationcenter
- SwiftData: https://developer.apple.com/documentation/swiftdata
- Claude API: https://docs.anthropic.com/en/api/getting-started
- Anthropic Usage Policy（OAuth禁止の根拠）: https://docs.anthropic.com/en/policies/usage-policy
- Firebase Authentication: https://firebase.google.com/docs/auth
- Firebase Admin SDK (Node.js): https://firebase.google.com/docs/admin/setup
- Hono: https://hono.dev
- VOICEVOX: https://voicevox.hiroshiba.jp
- ElevenLabs: https://elevenlabs.io/docs

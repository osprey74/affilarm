# affilarm

> affilarm is a cross-platform (iOS / Android) affirmation alarm app built with Flutter.

## Project Overview

- **Concept**: An alarm app that reads aloud affirmation phrases (TTS) at the configured wake-up time to anchor positive intent into the morning routine.
- **Stack**: Flutter (Dart) / Firebase Authentication / Claude API (BYOK) / Hono on Fly.io (auth only, no AI proxy).
- **Design spec**: See [HANDOFF_affirmation-alarm.md](HANDOFF_affirmation-alarm.md) — authoritative source for features, data model, and policy decisions.

## Task Management

- **task_file**: `docs/tasks.md`
- **done_marker**: `[x]`
- **progress_summary**: true（フェーズ表＋進捗サマリーの数値も更新）

## Documentation

- **docs_to_update**:
  - `README.md` (EN)
  - `README.ja.md` (JA)
- **doc_pairs**:
  - `README.md` ↔ `README.ja.md`

## Versioning

- **version_files**:
  - `pubspec.yaml`（Flutter プロジェクトスキャフォールド後に追加）
- **extra_version_files**: なし
- **cargo_lockfile**: false（Flutter のため `pubspec.lock` は別管理）

## CI/CD

- **cicd**: 未設定（Phase 0 で設計予定）
- **cicd_trigger**: 未定（タグプッシュを想定）
- **cicd_platform**: GitHub Actions（iOS / Android ビルド）

## SNS

- **sns_accounts**: なし（リリース後に検討）

## 重要な実装方針

- **Claude API は BYOK 専用**。アプリから直接呼び出し、Hono バックエンドはプロキシしない。ユーザー API キーは iOS Keychain / Android EncryptedSharedPreferences にのみ保存し、ログ・クラッシュレポートに **絶対に含めない**。
- **OAuth で Claude アカウント認証は不可**（Anthropic ポリシー 2026-02 更新）。ユーザー認証は Firebase Authentication で行う。
- **Apple ログインは App Store 提出要件として必須**。
- **匿名認証ユーザー** が後から正規ログインした場合、ローカルデータを Firebase UID に紐付けるマイグレーション処理が必要。
- **アラームの確実な発火** には iOS のバックグラウンド制限を考慮し、`flutter_local_notifications` + 必要に応じて `workmanager` の組み合わせを検討する。

# affilarm — Affirmation Alarm

An iOS app that wakes you up with affirmation phrases instead of a generic alarm tone. Read out loud via TTS at your set time to anchor positive intent into your morning routine.

Built with **Swift / SwiftUI**. Backed by Firebase Authentication and an optional BYOK (Bring Your Own Key) Claude API integration for phrase generation.

> **Status: in development.** The design document is at [HANDOFF_affirmation-alarm.md](HANDOFF_affirmation-alarm.md).

---

## Concept

- **Wake up with intent.** Replace your alarm with affirmation phrases read aloud in a chosen voice.
- **Repetition for retention.** Loop or repeat phrases (1 / 3 / 5 / 10 / loop) to anchor them.
- **Personal but private.** Phrases stay on your device. Optional cloud sync via Firebase for streaks / stats only.

---

## Planned Features

### v1.0 — MVP

- Multiple alarms with per-day-of-week repeat
- Manual phrase entry + curated preset library
- TTS with voice selection, speed, pitch, and volume controls
- Repeat modes: 1× / 3× / 5× / 10× / loop
- Alarm screen with phrase display
- Firebase Authentication (Email / Google / Apple / Anonymous)

### v1.1

- BYOK Claude API integration for phrase generation (categories × combine/list mode)
- Preset phrase library by category (no API key required)
- Breathing guide (3s / 5s / 7s circle animation before playback)
- Background music presets

### v1.2

- Synced text highlighting during TTS playback
- Streak tracking
- Achievement badges (3 / 7 / 21 / 66 days)

### v1.3

- Statistics view (calendar + phrase rankings)
- Home-screen widget (iOS)
- Apple Watch companion

---

## Tech Stack

| Layer | Choice |
|---|---|
| App | Swift / SwiftUI — iOS only |
| Local DB | SwiftData |
| Auth | Firebase Authentication |
| AI (optional) | Claude API — BYOK only |
| Backend | Hono on Fly.io (Firebase token verification only) |
| TTS | `AVSpeechSynthesizer` |
| Notifications | `UNUserNotificationCenter` |

The Claude API is called **directly from the app** using a user-supplied key stored in iOS Keychain. No proxy server is used for AI requests.

---

## Why BYOK for Claude API

Anthropic's Usage Policy (updated February 2026) prohibits third-party apps from authenticating users via Claude account OAuth. Only developer API keys are permitted. To keep operating costs at zero and stay policy-compliant, affilarm uses the user's own Anthropic API key — entered in-app and stored locally. Without a key, the app falls back to the bundled preset phrase library.

---

## Repository Status

- Design spec: [HANDOFF_affirmation-alarm.md](HANDOFF_affirmation-alarm.md)
- Task tracker: [docs/tasks.md](docs/tasks.md)

---

## License

[MIT](LICENSE) © 2026 osprey74

import AVFoundation
import SwiftUI

struct SettingsView: View {
    @State private var tts = TTSService()
    @State private var voices: [AVSpeechSynthesisVoice] = []

    @AppStorage("ttsRate") private var rate = 0.5 as Double
    @AppStorage("ttsPitch") private var pitch = 1.0 as Double
    @AppStorage("ttsVolume") private var volume = 0.8 as Double
    @AppStorage("ttsVoiceId") private var voiceId = ""

    var body: some View {
        NavigationStack {
            List {
                // Voice selection
                Section("ボイス") {
                    Picker("ボイス", selection: $voiceId) {
                        Text("デフォルト").tag("")
                        ForEach(voices, id: \.identifier) { voice in
                            Text(voiceDisplayName(voice))
                                .tag(voice.identifier)
                        }
                    }
                }

                // Voice settings
                Section("ボイス設定") {
                    VStack(alignment: .leading) {
                        HStack {
                            Label("速度", systemImage: "speedometer")
                            Spacer()
                            Text(String(format: "%.1fx", rate / 0.5))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $rate, in: 0.25...1.0, step: 0.05)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Label("ピッチ", systemImage: "tuningfork")
                            Spacer()
                            Text(String(format: "%.1f", pitch))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $pitch, in: 0.5...2.0, step: 0.1)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Label("音量", systemImage: "speaker.wave.2")
                            Spacer()
                            Text("\(Int(volume * 100))%")
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        Slider(value: $volume, in: 0.0...1.0, step: 0.05)
                    }
                }

                // Test
                Section("テスト") {
                    Button {
                        tts.speak(
                            "今日も素晴らしい一日が始まる。私は自分の力を信じている。",
                            rate: Float(rate),
                            pitch: Float(pitch),
                            volume: Float(volume),
                            voiceIdentifier: voiceId.isEmpty ? nil : voiceId
                        )
                    } label: {
                        Label(
                            tts.isSpeaking ? "読み上げ中…" : "読み上げテスト",
                            systemImage: tts.isSpeaking ? "stop.circle" : "play.circle"
                        )
                    }
                }

                // App info
                Section("アプリ情報") {
                    LabeledContent("バージョン", value: "1.0.0")
                }
            }
            .navigationTitle("設定")
            .onAppear {
                voices = tts.availableJapaneseVoices()
            }
        }
    }

    private func voiceDisplayName(_ voice: AVSpeechSynthesisVoice) -> String {
        let quality = switch voice.quality {
        case .enhanced: " (高品質)"
        case .premium: " (プレミアム)"
        default: ""
        }
        return "\(voice.name)\(quality)"
    }
}

#Preview {
    SettingsView()
}

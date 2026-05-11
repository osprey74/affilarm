import SwiftUI

struct AlarmFiringView: View {
    let phrases: [String]
    let repeatCount: Int // 0 = loop
    let onDismiss: () -> Void

    @State private var tts = TTSService()
    @State private var currentRepeat = 0
    @State private var currentPhraseIndex = 0
    @State private var isPlaying = false

    @AppStorage("ttsRate") private var rate = 0.5 as Double
    @AppStorage("ttsPitch") private var pitch = 1.0 as Double
    @AppStorage("ttsVolume") private var volume = 0.8 as Double

    private var totalRepeats: Int { repeatCount == 0 ? .max : repeatCount }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.purple.opacity(0.3), .blue.opacity(0.2), .black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Current time
                Text(Date.now, style: .time)
                    .font(.system(size: 56, weight: .light, design: .rounded))
                    .foregroundStyle(.white)

                Text(Date.now, style: .date)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                // Current phrase
                if !phrases.isEmpty {
                    let idx = currentPhraseIndex % phrases.count
                    Text(phrases[idx])
                        .font(.title2.weight(.medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .animation(.easeInOut, value: currentPhraseIndex)
                }

                // Repeat counter
                if repeatCount > 0 {
                    HStack(spacing: 6) {
                        ForEach(0..<repeatCount, id: \.self) { i in
                            Circle()
                                .fill(i < currentRepeat ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                } else {
                    Text("ループ中 — \(currentRepeat + 1)回目")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Play / Stop buttons
                if !isPlaying {
                    Button {
                        startPlayback()
                    } label: {
                        Label("読み上げる", systemImage: "play.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.white, in: Capsule())
                    }
                    .padding(.horizontal, 48)
                }

                Button {
                    stopAndDismiss()
                } label: {
                    Text("アラームを止める")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white.opacity(0.2), in: Capsule())
                }
                .padding(.horizontal, 48)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            startPlayback()
        }
        .persistentSystemOverlays(.hidden)
    }

    private func startPlayback() {
        guard !phrases.isEmpty else { return }
        isPlaying = true
        currentRepeat = 0
        currentPhraseIndex = 0
        speakCurrent()
    }

    private func speakCurrent() {
        guard isPlaying, !phrases.isEmpty else { return }

        let idx = currentPhraseIndex % phrases.count
        tts.onComplete = {
            advanceToNext()
        }
        tts.speak(
            phrases[idx],
            rate: Float(rate),
            pitch: Float(pitch),
            volume: Float(volume)
        )
    }

    private func advanceToNext() {
        guard isPlaying else { return }

        let nextPhraseIndex = currentPhraseIndex + 1

        if nextPhraseIndex >= phrases.count {
            // Completed one full set
            let nextRepeat = currentRepeat + 1
            if repeatCount != 0 && nextRepeat >= repeatCount {
                // All repeats done
                isPlaying = false
                return
            }
            currentRepeat = nextRepeat
            currentPhraseIndex = 0
        } else {
            currentPhraseIndex = nextPhraseIndex
        }
        speakCurrent()
    }

    private func stopAndDismiss() {
        isPlaying = false
        tts.stop()
        onDismiss()
    }
}

#Preview {
    AlarmFiringView(
        phrases: ["今日も素晴らしい一日が始まる", "私は自分の力を信じている", "穏やかな心で一日を始める"],
        repeatCount: 3,
        onDismiss: {}
    )
}

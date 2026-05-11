import Foundation
import SwiftData

@Model
final class VoiceProfile {
    var id: UUID
    var name: String
    var voiceIdentifier: String?
    var rate: Double    // 0.5–2.0
    var pitch: Double   // -5.0–5.0
    var volume: Double  // 0.0–1.0
    var repeatModeRaw: Int // PhraseRepeatMode raw value
    var bgmTrack: String?
    var bgmVolume: Double
    var breathingGuide: Bool
    var breathingDuration: Int // seconds

    var repeatMode: PhraseRepeatMode {
        get { PhraseRepeatMode(rawValue: repeatModeRaw) ?? .three }
        set { repeatModeRaw = newValue.rawValue }
    }

    init(
        name: String,
        voiceIdentifier: String? = nil,
        rate: Double = 1.0,
        pitch: Double = 0.0,
        volume: Double = 0.8,
        repeatMode: PhraseRepeatMode = .three,
        bgmTrack: String? = nil,
        bgmVolume: Double = 0.3,
        breathingGuide: Bool = false,
        breathingDuration: Int = 5
    ) {
        self.id = UUID()
        self.name = name
        self.voiceIdentifier = voiceIdentifier
        self.rate = rate
        self.pitch = pitch
        self.volume = volume
        self.repeatModeRaw = repeatMode.rawValue
        self.bgmTrack = bgmTrack
        self.bgmVolume = bgmVolume
        self.breathingGuide = breathingGuide
        self.breathingDuration = breathingDuration
    }
}

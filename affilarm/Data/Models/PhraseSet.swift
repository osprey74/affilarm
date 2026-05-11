import Foundation
import SwiftData

@Model
final class PhraseSet {
    var id: UUID
    var name: String
    var categoryRaws: [String]
    var generationStyleRaw: String
    var phrases: [Phrase]
    var voiceProfile: VoiceProfile?

    var categories: [PhraseCategory] {
        get { categoryRaws.compactMap { PhraseCategory(rawValue: $0) } }
        set { categoryRaws = newValue.map(\.rawValue) }
    }

    var generationStyle: GenerationStyle {
        get { GenerationStyle(rawValue: generationStyleRaw) ?? .combine }
        set { generationStyleRaw = newValue.rawValue }
    }

    init(
        name: String,
        categories: [PhraseCategory] = [],
        generationStyle: GenerationStyle = .combine,
        phrases: [Phrase] = []
    ) {
        self.id = UUID()
        self.name = name
        self.categoryRaws = categories.map(\.rawValue)
        self.generationStyleRaw = generationStyle.rawValue
        self.phrases = phrases
    }
}

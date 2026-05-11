import Foundation
import SwiftData

@Model
final class Phrase {
    var id: UUID
    var text: String
    var categoryRaw: String
    var isFavorite: Bool
    var playCount: Int
    var isAiGenerated: Bool
    var createdAt: Date

    var category: PhraseCategory {
        get { PhraseCategory(rawValue: categoryRaw) ?? .mental }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        text: String,
        category: PhraseCategory,
        isFavorite: Bool = false,
        isAiGenerated: Bool = false
    ) {
        self.id = UUID()
        self.text = text
        self.categoryRaw = category.rawValue
        self.isFavorite = isFavorite
        self.playCount = 0
        self.isAiGenerated = isAiGenerated
        self.createdAt = Date()
    }
}

import Foundation
import SwiftData

@Model
final class PlayRecord {
    var id: UUID
    var alarmId: UUID
    var phraseSetId: UUID
    var playedAt: Date

    init(alarmId: UUID, phraseSetId: UUID) {
        self.id = UUID()
        self.alarmId = alarmId
        self.phraseSetId = phraseSetId
        self.playedAt = Date()
    }
}

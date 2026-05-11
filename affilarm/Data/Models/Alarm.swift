import Foundation
import SwiftData

@Model
final class Alarm {
    var id: UUID
    var hour: Int
    var minute: Int
    var weekdays: [Bool] // 7 elements: Mon–Sun
    var isEnabled: Bool
    var phraseSet: PhraseSet?
    var repeatCount: Int // 0 = loop
    var createdAt: Date

    init(
        hour: Int = 7,
        minute: Int = 0,
        weekdays: [Bool] = Array(repeating: false, count: 7),
        isEnabled: Bool = true,
        phraseSet: PhraseSet? = nil,
        repeatCount: Int = 3
    ) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.weekdays = weekdays
        self.isEnabled = isEnabled
        self.phraseSet = phraseSet
        self.repeatCount = repeatCount
        self.createdAt = Date()
    }

    var timeString: String {
        String(format: "%02d:%02d", hour, minute)
    }

    var weekdaysSummary: String {
        let labels = ["月", "火", "水", "木", "金", "土", "日"]
        if weekdays.allSatisfy({ $0 }) { return "毎日" }
        if weekdays.allSatisfy({ !$0 }) { return "1回のみ" }
        return weekdays.enumerated()
            .filter { $0.element }
            .map { labels[$0.offset] }
            .joined(separator: " ")
    }
}

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var alarms: [Alarm]
    @Query private var phrases: [Phrase]
    @State private var firingAlarmID: UUID?

    var body: some View {
        ZStack {
            TabView {
                Tab("アラーム", systemImage: "alarm") {
                    AlarmListView()
                }
                Tab("フレーズ", systemImage: "text.quote") {
                    PhraseListView()
                }
                Tab("設定", systemImage: "gearshape") {
                    SettingsView()
                }
            }

            // Full-screen alarm firing overlay
            if firingAlarmID != nil {
                AlarmFiringView(
                    phrases: phrasesForFiringAlarm,
                    repeatCount: firingAlarm?.repeatCount ?? 3,
                    onDismiss: { firingAlarmID = nil }
                )
                .transition(.opacity)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .alarmFired)) { notification in
            if let id = notification.userInfo?["alarmID"] as? UUID {
                withAnimation { firingAlarmID = id }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .alarmTestFired)) { _ in
            // Test with all phrases
            withAnimation { firingAlarmID = UUID() }
        }
    }

    private var firingAlarm: Alarm? {
        alarms.first { $0.id == firingAlarmID }
    }

    private var phrasesForFiringAlarm: [String] {
        if let alarm = firingAlarm, let phraseSet = alarm.phraseSet {
            return phraseSet.phrases.map(\.text)
        }
        // Fallback: use all phrases if no specific set
        if phrases.isEmpty {
            return ["今日も素晴らしい一日が始まる"]
        }
        return phrases.prefix(5).map(\.text)
    }
}

extension Notification.Name {
    static let alarmFired = Notification.Name("alarmFired")
    static let alarmTestFired = Notification.Name("alarmTestFired")
}

#Preview {
    HomeView()
        .modelContainer(for: [Alarm.self, Phrase.self], inMemory: true)
}

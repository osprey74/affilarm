import SwiftUI

struct HomeView: View {
    var body: some View {
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
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Alarm.self, Phrase.self], inMemory: true)
}

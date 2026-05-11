import SwiftData
import SwiftUI

struct AlarmListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Alarm.hour, order: .forward) private var alarms: [Alarm]
    @State private var showingEditor = false

    var body: some View {
        NavigationStack {
            Group {
                if alarms.isEmpty {
                    ContentUnavailableView(
                        "アラームを追加しましょう",
                        systemImage: "alarm.waves.left.and.right",
                        description: Text("＋ボタンからアラームを作成できます")
                    )
                } else {
                    List {
                        ForEach(alarms) { alarm in
                            NavigationLink {
                                AlarmEditView(alarm: alarm)
                            } label: {
                                AlarmRow(alarm: alarm)
                            }
                        }
                        .onDelete(perform: deleteAlarms)
                    }
                }
            }
            .navigationTitle("affilarm")
            .onAppear {
                // Reschedule all alarms on launch (covers app updates & reinstalls)
                for alarm in alarms {
                    NotificationService.scheduleAlarm(alarm)
                }
                NotificationService.debugPrintPending()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                NavigationStack {
                    AlarmEditView(alarm: nil)
                }
            }
        }
    }

    private func deleteAlarms(at offsets: IndexSet) {
        for index in offsets {
            NotificationService.removeAlarm(alarms[index])
            modelContext.delete(alarms[index])
        }
    }
}

// MARK: - AlarmRow

private struct AlarmRow: View {
    @Bindable var alarm: Alarm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 40, weight: .light, design: .rounded))
                    .foregroundStyle(alarm.isEnabled ? .primary : .tertiary)
                Text(alarm.weekdaysSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: $alarm.isEnabled)
                .labelsHidden()
                .onChange(of: alarm.isEnabled) {
                    NotificationService.scheduleAlarm(alarm)
                }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AlarmListView()
        .modelContainer(for: Alarm.self, inMemory: true)
}

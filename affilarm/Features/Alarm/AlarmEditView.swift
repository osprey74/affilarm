import SwiftData
import SwiftUI

struct AlarmEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Phrase.createdAt, order: .reverse) private var allPhrases: [Phrase]

    let alarm: Alarm?

    @State private var hour: Int
    @State private var minute: Int
    @State private var weekdays: [Bool]
    @State private var repeatCount: Int
    @State private var selectedPhraseIDs: Set<UUID>

    private var isNew: Bool { alarm == nil }

    init(alarm: Alarm?) {
        self.alarm = alarm
        _hour = State(initialValue: alarm?.hour ?? 7)
        _minute = State(initialValue: alarm?.minute ?? 0)
        _weekdays = State(initialValue: alarm?.weekdays ?? Array(repeating: false, count: 7))
        _repeatCount = State(initialValue: alarm?.repeatCount ?? PhraseRepeatMode.three.rawValue)
        let ids = alarm?.phraseSet?.phrases.map(\.id) ?? []
        _selectedPhraseIDs = State(initialValue: Set(ids))
    }

    var body: some View {
        Form {
            Section {
                DatePicker(
                    "時刻",
                    selection: timeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }

            Section("繰り返し") {
                WeekdayPicker(weekdays: $weekdays)
            }

            Section("読み上げ回数") {
                Picker("回数", selection: $repeatCount) {
                    ForEach(PhraseRepeatMode.allCases) { mode in
                        Text(mode.label).tag(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Phrase selection
            Section("フレーズ") {
                if allPhrases.isEmpty {
                    Text("フレーズタブから先にフレーズを追加してください")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(allPhrases) { phrase in
                        Button {
                            togglePhrase(phrase.id)
                        } label: {
                            HStack {
                                Image(systemName: selectedPhraseIDs.contains(phrase.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedPhraseIDs.contains(phrase.id) ? phrase.category.color : .gray)
                                Text(phrase.text)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(isNew ? "アラーム追加" : "アラーム編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isNew {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("保存") { save() }
            }
        }
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                hour = components.hour ?? 7
                minute = components.minute ?? 0
            }
        )
    }

    private func togglePhrase(_ id: UUID) {
        if selectedPhraseIDs.contains(id) {
            selectedPhraseIDs.remove(id)
        } else {
            selectedPhraseIDs.insert(id)
        }
    }

    private func save() {
        let selectedPhrases = allPhrases.filter { selectedPhraseIDs.contains($0.id) }

        if let alarm {
            alarm.hour = hour
            alarm.minute = minute
            alarm.weekdays = weekdays
            alarm.repeatCount = repeatCount
            updatePhraseSet(for: alarm, phrases: selectedPhrases)
            NotificationService.scheduleAlarm(alarm)
        } else {
            let newAlarm = Alarm(
                hour: hour,
                minute: minute,
                weekdays: weekdays,
                repeatCount: repeatCount
            )
            modelContext.insert(newAlarm)
            updatePhraseSet(for: newAlarm, phrases: selectedPhrases)
            NotificationService.scheduleAlarm(newAlarm)
        }
        dismiss()
    }

    private func updatePhraseSet(for alarm: Alarm, phrases: [Phrase]) {
        if phrases.isEmpty {
            alarm.phraseSet = nil
            return
        }
        if let existing = alarm.phraseSet {
            existing.phrases = phrases
        } else {
            let set = PhraseSet(name: "アラーム用", phrases: phrases)
            modelContext.insert(set)
            alarm.phraseSet = set
        }
    }
}

// MARK: - WeekdayPicker

private struct WeekdayPicker: View {
    @Binding var weekdays: [Bool]
    private let labels = ["月", "火", "水", "木", "金", "土", "日"]

    var body: some View {
        HStack {
            ForEach(0..<7, id: \.self) { index in
                Button {
                    weekdays[index].toggle()
                } label: {
                    Text(labels[index])
                        .font(.subheadline.weight(.medium))
                        .frame(width: 36, height: 36)
                        .background(weekdays[index] ? Color.accentColor : Color.clear)
                        .foregroundStyle(weekdays[index] ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AlarmEditView(alarm: nil)
    }
    .modelContainer(for: [Alarm.self, Phrase.self, PhraseSet.self], inMemory: true)
}

import SwiftData
import SwiftUI

struct PhraseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Phrase.createdAt, order: .reverse) private var phrases: [Phrase]
    @State private var showingAddSheet = false
    @State private var showingPresets = false

    var body: some View {
        NavigationStack {
            Group {
                if phrases.isEmpty {
                    ContentUnavailableView(
                        "フレーズを追加しましょう",
                        systemImage: "text.quote",
                        description: Text("プリセットから選ぶか、自分で入力できます")
                    )
                } else {
                    List {
                        ForEach(phrases) { phrase in
                            PhraseRow(phrase: phrase)
                        }
                        .onDelete(perform: deletePhrases)
                    }
                }
            }
            .navigationTitle("フレーズ")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("自分で入力", systemImage: "pencil")
                        }
                        Button {
                            showingPresets = true
                        } label: {
                            Label("プリセットから選ぶ", systemImage: "list.star")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PhraseAddView()
            }
            .sheet(isPresented: $showingPresets) {
                PresetPhrasePickerView()
            }
        }
    }

    private func deletePhrases(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(phrases[index])
        }
    }
}

// MARK: - PhraseRow

private struct PhraseRow: View {
    @Bindable var phrase: Phrase

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: phrase.category.icon)
                .font(.title3)
                .foregroundStyle(phrase.category.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(phrase.text)
                    .lineLimit(2)
                Text(phrase.category.label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                phrase.isFavorite.toggle()
            } label: {
                Image(systemName: phrase.isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(phrase.isFavorite ? .pink : .gray)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - PhraseAddView

private struct PhraseAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var category = PhraseCategory.mental

    var body: some View {
        NavigationStack {
            Form {
                Section("フレーズ") {
                    TextField("アファメーションフレーズを入力", text: $text, axis: .vertical)
                        .lineLimit(2...4)
                }
                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $category) {
                        ForEach(PhraseCategory.allCases) { cat in
                            Label(cat.label, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("フレーズ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let phrase = Phrase(text: text.trimmingCharacters(in: .whitespacesAndNewlines), category: category)
                        modelContext.insert(phrase)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - PresetPhrasePickerView

struct PresetPhrasePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Set<String> = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(PresetPhrases.all, id: \.0) { category, phrases in
                    Section {
                        ForEach(phrases, id: \.self) { text in
                            Button {
                                if selected.contains(text) {
                                    selected.remove(text)
                                } else {
                                    selected.insert(text)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: selected.contains(text) ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selected.contains(text) ? category.color : .gray)
                                    Text(text)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    } header: {
                        Label(category.label, systemImage: category.icon)
                    }
                }
            }
            .navigationTitle("プリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加（\(selected.count)件）") {
                        addSelected()
                        dismiss()
                    }
                    .disabled(selected.isEmpty)
                }
            }
        }
    }

    private func addSelected() {
        for (category, phrases) in PresetPhrases.all {
            for text in phrases where selected.contains(text) {
                let phrase = Phrase(text: text, category: category)
                modelContext.insert(phrase)
            }
        }
    }
}

#Preview {
    PhraseListView()
        .modelContainer(for: Phrase.self, inMemory: true)
}

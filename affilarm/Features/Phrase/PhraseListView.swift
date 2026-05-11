import SwiftData
import SwiftUI

struct PhraseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Phrase.createdAt, order: .reverse) private var phrases: [Phrase]
    @State private var showingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if phrases.isEmpty {
                    ContentUnavailableView(
                        "フレーズを追加しましょう",
                        systemImage: "text.quote",
                        description: Text("アファメーションフレーズを登録できます")
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
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PhraseAddView()
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

#Preview {
    PhraseListView()
        .modelContainer(for: Phrase.self, inMemory: true)
}

import SwiftUI

enum PhraseCategory: String, Codable, CaseIterable, Identifiable {
    case business
    case mental
    case money
    case relationship
    case health

    var id: String { rawValue }

    var label: String {
        switch self {
        case .business: "ビジネス"
        case .mental: "メンタル"
        case .money: "マネー"
        case .relationship: "人間関係"
        case .health: "健康"
        }
    }

    var icon: String {
        switch self {
        case .business: "briefcase"
        case .mental: "brain"
        case .money: "yensign.circle"
        case .relationship: "heart"
        case .health: "figure.run"
        }
    }

    var color: Color {
        switch self {
        case .business: .blue
        case .mental: .purple
        case .money: .green
        case .relationship: .pink
        case .health: .teal
        }
    }
}

enum GenerationStyle: String, Codable, CaseIterable {
    case combine
    case list

    var label: String {
        switch self {
        case .combine: "組み合わせ"
        case .list: "列挙"
        }
    }

    var description: String {
        switch self {
        case .combine: "選択カテゴリを1文に融合"
        case .list: "カテゴリごとに1文ずつ"
        }
    }
}

enum PhraseRepeatMode: Int, Codable, CaseIterable, Identifiable {
    case once = 1
    case three = 3
    case five = 5
    case ten = 10
    case loop = 0

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .once: "1回"
        case .three: "3回"
        case .five: "5回"
        case .ten: "10回"
        case .loop: "ループ"
        }
    }
}

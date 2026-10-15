import Foundation

enum ChannelVerification: String, CaseIterable, Identifiable, Hashable {
    case correct
    case swapped
    case issue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .correct:
            return "CORRECT"

        case .swapped:
            return "SWAPPED"

        case .issue:
            return "ISSUE"
        }
    }

    var symbol: String {
        switch self {
        case .correct:
            return "checkmark"

        case .swapped:
            return "arrow.left.arrow.right"

        case .issue:
            return "exclamationmark"
        }
    }

    var score: Int {
        switch self {
        case .correct:
            return 100

        case .swapped:
            return 35

        case .issue:
            return 15
        }
    }

}

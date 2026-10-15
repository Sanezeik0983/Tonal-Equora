import SwiftUI

enum SessionScoreFilter:
    String,
    CaseIterable,
    Identifiable,
    Hashable {

    case all
    case excellent
    case solid
    case attention
    case unscored

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .all:
            return "All scores"

        case .excellent:
            return "85–100"

        case .solid:
            return "65–84"

        case .attention:
            return "Below 65"

        case .unscored:
            return "No score"
        }
    }

    var shortTitle: String {
        switch self {
        case .all:
            return "ALL"

        case .excellent:
            return "85+"

        case .solid:
            return "65–84"

        case .attention:
            return "<65"

        case .unscored:
            return "NONE"
        }
    }

    var controlTitle: String {
        switch self {
        case .all:
            return "ALL"

        case .excellent:
            return "85–100"

        case .solid:
            return "65–84"

        case .attention:
            return "<65"

        case .unscored:
            return "UNSCORED"
        }
    }

    func matches(
        _ score: Int?
    ) -> Bool {
        switch self {
        case .all:
            return true

        case .excellent:
            guard let score else {
                return false
            }

            return score >= 85

        case .solid:
            guard let score else {
                return false
            }

            return score >= 65 &&
                score < 85

        case .attention:
            guard let score else {
                return false
            }

            return score < 65

        case .unscored:
            return score == nil
        }
    }
}

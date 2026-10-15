import SwiftUI

enum SessionSortOrder:
    String,
    CaseIterable,
    Identifiable,
    Hashable {

    case newest
    case oldest
    case scoreHigh
    case scoreLow

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .newest:
            return "NEWEST"

        case .oldest:
            return "OLDEST"

        case .scoreHigh:
            return "SCORE ↓"

        case .scoreLow:
            return "SCORE ↑"
        }
    }

    var controlTitle: String {
        title
    }

    func compare(
        _ lhs: SessionLedgerEntry,
        _ rhs: SessionLedgerEntry
    ) -> Bool {
        switch self {
        case .newest:
            return lhs.createdAt >
                rhs.createdAt

        case .oldest:
            return lhs.createdAt <
                rhs.createdAt

        case .scoreHigh:
            let lhsScore = lhs.score ?? -1
            let rhsScore = rhs.score ?? -1

            if lhsScore == rhsScore {
                return lhs.createdAt >
                    rhs.createdAt
            }

            return lhsScore >
                rhsScore

        case .scoreLow:
            let lhsScore = lhs.score ?? 101
            let rhsScore = rhs.score ?? 101

            if lhsScore == rhsScore {
                return lhs.createdAt >
                    rhs.createdAt
            }

            return lhsScore <
                rhsScore
        }
    }
}

import SwiftUI

enum SessionPeriodFilter:
    String,
    CaseIterable,
    Identifiable,
    Hashable {

    case all
    case today
    case sevenDays
    case thirtyDays

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .all:
            return "Any time"

        case .today:
            return "Today"

        case .sevenDays:
            return "Last 7 days"

        case .thirtyDays:
            return "Last 30 days"
        }
    }

    var shortTitle: String {
        switch self {
        case .all:
            return "ALL"

        case .today:
            return "TODAY"

        case .sevenDays:
            return "7D"

        case .thirtyDays:
            return "30D"
        }
    }

    var controlTitle: String {
        switch self {
        case .all:
            return "ANY DATE"

        case .today:
            return "TODAY"

        case .sevenDays:
            return "7 DAYS"

        case .thirtyDays:
            return "30 DAYS"
        }
    }

    var startDate: Date? {
        let calendar = Calendar.autoupdatingCurrent

        switch self {
        case .all:
            return nil

        case .today:
            return calendar.startOfDay(
                for: .now
            )

        case .sevenDays:
            return calendar.date(
                byAdding: .day,
                value: -7,
                to: .now
            )

        case .thirtyDays:
            return calendar.date(
                byAdding: .day,
                value: -30,
                to: .now
            )
        }
    }
}

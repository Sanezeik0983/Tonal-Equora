import SwiftUI

enum SessionLedgerScope:
    String,
    CaseIterable,
    Identifiable {

    case all
    case calibration
    case music
    case position

    var id: String {
        rawValue
    }

    var indexNumber: String {
        switch self {
        case .all:
            return "01"

        case .calibration:
            return "02"

        case .music:
            return "03"

        case .position:
            return "04"
        }
    }

    var indexTitle: String {
        switch self {
        case .all:
            return "ALL"

        case .calibration:
            return "CHECKS"

        case .music:
            return "MUSIC"

        case .position:
            return "POSITION"
        }
    }

    func matches(
        _ entry: SessionLedgerEntry
    ) -> Bool {
        switch (self, entry) {
        case (.all, _):
            return true

        case (.calibration, .calibration):
            return true

        case (.music, .music):
            return true

        case (.position, .position):
            return true

        default:
            return false
        }
    }
}

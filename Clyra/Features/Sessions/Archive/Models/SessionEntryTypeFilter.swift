import SwiftUI

enum SessionEntryTypeFilter:
    String,
    CaseIterable,
    Identifiable,
    Hashable {

    case all
    case alignment
    case channel
    case center
    case spatial
    case noise
    case frequency
    case balance
    case roomScan
    case speakerMatch
    case position

    var id: String {
        rawValue
    }

    var shortTitle: String {
        switch self {
        case .all:
            return "ALL"

        case .alignment:
            return "ALIGN"

        case .channel:
            return "L/R"

        case .center:
            return "CENTER"

        case .spatial:
            return "FIELD"

        case .noise:
            return "NOISE"

        case .frequency:
            return "FREQ"

        case .balance:
            return "BAL"

        case .roomScan:
            return "ROOM SCAN"

        case .speakerMatch:
            return "SPEAKER MATCH"

        case .position:
            return "POSITION"
        }
    }

    var controlTitle: String {
        self == .all
            ? "ALL TESTS"
            : shortTitle
    }

    func supports(
        _ scope: SessionLedgerScope
    ) -> Bool {
        switch self {
        case .all:
            return true

        case .alignment,
             .channel,
             .center,
             .spatial,
             .noise,
             .frequency,
             .balance:
            return scope == .all ||
                scope == .calibration

        case .roomScan,
             .speakerMatch:
            return scope == .all ||
                scope == .music

        case .position:
            return scope == .all ||
                scope == .position
        }
    }

    func matches(
        _ entry: SessionLedgerEntry
    ) -> Bool {
        if self == .all {
            return true
        }

        switch (self, entry) {
        case (.alignment, .calibration(let record)):
            return record.kind == .alignment

        case (.channel, .calibration(let record)):
            return record.kind == .channel

        case (.center, .calibration(let record)):
            return record.kind == .center

        case (.spatial, .calibration(let record)):
            return record.kind == .spatial

        case (.noise, .calibration(let record)):
            return record.kind == .noise

        case (.frequency, .calibration(let record)):
            return record.kind == .frequency

        case (.balance, .calibration(let record)):
            return record.kind == .balance

        case (.roomScan, .music(let record)):
            return record.kind == .roomScan

        case (.speakerMatch, .music(let record)):
            return record.kind == .speakerMatch

        case (.position, .position):
            return true

        default:
            return false
        }
    }
}

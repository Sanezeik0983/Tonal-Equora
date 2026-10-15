import SwiftUI

enum SessionLedgerEntry:
    Identifiable {

    case calibration(AcousticSessionRecord)
    case music(MusicAssistRecord)
    case position(MusicListeningPositionRecord)

    var id: String {
        switch self {
        case .calibration(let record):
            return "calibration-\(record.id.uuidString)"

        case .music(let record):
            return "music-\(record.id.uuidString)"

        case .position(let record):
            return "position-\(record.id.uuidString)"
        }
    }

    var setupID: UUID {
        switch self {
        case .calibration(let record):
            return record.setupID

        case .music(let record):
            return record.setupID

        case .position(let record):
            return record.setupID
        }
    }

    var createdAt: Date {
        switch self {
        case .calibration(let record):
            return record.createdAt

        case .music(let record):
            return record.createdAt

        case .position(let record):
            return record.createdAt
        }
    }

    var score: Int? {
        switch self {
        case .calibration(let record):
            return record.score

        case .music,
             .position:
            return nil
        }
    }
}

import SwiftUI

enum MusicAssistMode:
    String,
    CaseIterable,
    Identifiable {

    case roomScan
    case speakerMatch

    var id: String {
        rawValue
    }

    var index: String {
        switch self {
        case .roomScan:
            return "01"

        case .speakerMatch:
            return "02"
        }
    }

    var title: String {
        switch self {
        case .roomScan:
            return "ROOM SCAN"

        case .speakerMatch:
            return "SPEAKER MATCH"
        }
    }

    var detail: String {
        switch self {
        case .roomScan:
            return "listening position"

        case .speakerMatch:
            return "left vs right"
        }
    }
}

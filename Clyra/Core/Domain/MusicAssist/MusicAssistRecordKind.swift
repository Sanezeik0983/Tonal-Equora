import Foundation
import Combine

enum MusicAssistRecordKind: String, Codable, CaseIterable, Hashable {
    case roomScan
    case speakerMatch

    var title: String {
        switch self {
        case .roomScan:
            return "ROOM SCAN"

        case .speakerMatch:
            return "SPEAKER MATCH"
        }
    }

    var symbol: String {
        switch self {
        case .roomScan:
            return "dot.radiowaves.left.and.right"

        case .speakerMatch:
            return "hifispeaker.2"
        }
    }
}

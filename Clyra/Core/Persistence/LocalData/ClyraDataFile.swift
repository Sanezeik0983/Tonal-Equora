import Foundation

enum ClyraDataFile: String, CaseIterable, Sendable {
    case setups = "setups.json"
    case sessions = "sessions.json"
    case musicAssistRecords = "music-assist.json"
    case listeningPositionRecords = "listening-positions.json"
}

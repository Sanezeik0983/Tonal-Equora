import Foundation
import Combine

struct MusicAssistRecord: Identifiable, Codable, Hashable {
    let id: UUID
    let setupID: UUID
    let kind: MusicAssistRecordKind
    let roomSnapshot: MusicRoomSnapshot?
    let speakerMatch: MusicSpeakerMatchSnapshot?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        setupID: UUID,
        roomSnapshot: MusicRoomSnapshot,
        createdAt: Date = .now
    ) {
        self.id = id
        self.setupID = setupID
        kind = .roomScan
        self.roomSnapshot = roomSnapshot
        speakerMatch = nil
        self.createdAt = createdAt
    }

    init(
        id: UUID = UUID(),
        setupID: UUID,
        speakerMatch: MusicSpeakerMatchSnapshot,
        createdAt: Date = .now
    ) {
        self.id = id
        self.setupID = setupID
        kind = .speakerMatch
        roomSnapshot = nil
        self.speakerMatch = speakerMatch
        self.createdAt = createdAt
    }
}
